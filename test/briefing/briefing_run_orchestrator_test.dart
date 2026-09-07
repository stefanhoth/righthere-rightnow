import 'package:drift/native.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:righthere_rightnow/briefing/briefing_run_orchestrator.dart';
import 'package:righthere_rightnow/data/calendar/calendar_exception.dart';
import 'package:righthere_rightnow/data/calendar/calendar_reader.dart';
import 'package:righthere_rightnow/data/db/app_database.dart';
import 'package:righthere_rightnow/data/settings/todoist_token_storage.dart';
import 'package:righthere_rightnow/data/todoist/todoist_client.dart';
import 'package:righthere_rightnow/data/what_matters/what_matters_document.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/priority.dart';
import 'package:righthere_rightnow/domain/ranked_agenda.dart';
import 'package:righthere_rightnow/domain/response_status.dart';

import '../support/fake_what_matters_repository.dart';

class _MockCalendarReader extends Mock implements CalendarReader {}

class _MockTodoistClient extends Mock implements TodoistClient {}

class _FakeSecureStoragePlatform extends FlutterSecureStoragePlatform {
  final Map<String, String> _values = {};

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    _values[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async {
    return _values[key];
  }

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async {
    return _values.containsKey(key);
  }

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {
    _values.remove(key);
  }

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async {
    return Map.of(_values);
  }

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {
    _values.clear();
  }
}

Commitment _commitment(String id, DateTime start) {
  return Commitment(
    id: id,
    title: id,
    start: start,
    end: start.add(const Duration(minutes: 30)),
    isAllDay: false,
    attendeeCount: 2,
    isOrganiser: false,
    myResponse: ResponseStatus.accepted,
    isRecurring: false,
    calendarName: 'Work',
  );
}

DateTime clock() => DateTime(2026, 8, 26, 9);

void main() {
  late _MockCalendarReader calendarReader;
  late _MockTodoistClient todoistClient;
  late TodoistTokenStorage tokenStorage;
  late AppDatabase database;
  late BriefingRunOrchestrator orchestrator;

  setUpAll(() {
    registerFallbackValue(DateTime(0));
  });

  setUp(() {
    calendarReader = _MockCalendarReader();
    todoistClient = _MockTodoistClient();
    FlutterSecureStoragePlatform.instance = _FakeSecureStoragePlatform();
    tokenStorage = TodoistTokenStorage();
    database = AppDatabase.forTesting(NativeDatabase.memory());
    orchestrator = BriefingRunOrchestrator(
      calendarReader: calendarReader,
      todoistClient: todoistClient,
      todoistTokenStorage: tokenStorage,
      whatMattersRepository: stubWhatMattersRepository(),
      database: database,
      clock: clock,
    );

    when(
      () => calendarReader.fetchCommitments(
        start: any(named: 'start'),
        end: any(named: 'end'),
      ),
    ).thenAnswer((_) async => []);
    when(() => todoistClient.fetchTasks(any())).thenAnswer((_) async => []);
  });

  tearDown(() => database.close());

  test('a dismissed Agenda Item never reaches the Candidate Set', () async {
    // Filtered before assembly, not hidden after ranking: a dismissed item
    // must not occupy one of the 25 candidate slots, reach the model, or be
    // snapshotted as something that competed.
    when(
      () => calendarReader.fetchCommitments(
        start: any(named: 'start'),
        end: any(named: 'end'),
      ),
    ).thenAnswer(
      (_) async => [
        _commitment('cal:kept', clock().add(const Duration(hours: 1))),
        _commitment('cal:dismissed', clock().add(const Duration(hours: 2))),
      ],
    );
    await database.dismissItem('cal:dismissed', at: clock());

    final result = await orchestrator.run();

    final ids = result.agenda.items.map((item) => item.id);
    expect(ids, contains('cal:kept'));
    expect(ids, isNot(contains('cal:dismissed')));
    expect(
      result.candidateItems.map((candidate) => candidate.item.id),
      isNot(contains('cal:dismissed')),
    );
  });

  test('undismissing brings an Agenda Item back', () async {
    when(
      () => calendarReader.fetchCommitments(
        start: any(named: 'start'),
        end: any(named: 'end'),
      ),
    ).thenAnswer(
      (_) async => [
        _commitment('cal:oops', clock().add(const Duration(hours: 1))),
      ],
    );
    await database.dismissItem('cal:oops', at: clock());
    await database.undismissItem('cal:oops');

    final result = await orchestrator.run();

    expect(result.agenda.items.map((item) => item.id), contains('cal:oops'));
  });

  test('rankedBy is always fallback in this milestone', () async {
    final result = await orchestrator.run();

    expect(result.agenda.rankedBy, RankedBy.fallback);
  });

  test('a failing Todoist client still produces an agenda of Commitments, with the error recorded', () async {
    await tokenStorage.write('a-token');
    when(
      () => calendarReader.fetchCommitments(
        start: any(named: 'start'),
        end: any(named: 'end'),
      ),
    ).thenAnswer(
      (_) async => [
        _commitment('cal:standup', clock().add(const Duration(hours: 1))),
      ],
    );
    when(() => todoistClient.fetchTasks(any())).thenThrow(Exception('503'));

    final result = await orchestrator.run();

    expect(result.agenda.items.map((i) => i.id), ['cal:standup']);
    expect(result.error, contains('Todoist'));
    expect(result.isPartial, isTrue);

    final storedRun = await database.select(database.briefingRuns).getSingle();
    expect(storedRun.error, contains('Todoist'));
  });

  test('an unreachable What Matters server still produces an agenda, with the error recorded', () async {
    when(
      () => calendarReader.fetchCommitments(
        start: any(named: 'start'),
        end: any(named: 'end'),
      ),
    ).thenAnswer(
      (_) async => [
        _commitment('cal:standup', clock().add(const Duration(hours: 1))),
      ],
    );
    final failing = BriefingRunOrchestrator(
      calendarReader: calendarReader,
      todoistClient: todoistClient,
      todoistTokenStorage: tokenStorage,
      whatMattersRepository: stubWhatMattersRepository(
        const WhatMattersReadResult(
          isStale: true,
          error: 'What Matters: WhatMattersException: HTTP 503',
        ),
      ),
      database: database,
      clock: clock,
    );

    final result = await failing.run();

    expect(result.agenda.items.map((i) => i.id), ['cal:standup']);
    expect(result.error, contains('What Matters'));
    expect(result.isPartial, isTrue);

    final storedRun = await database.select(database.briefingRuns).getSingle();
    expect(storedRun.error, contains('What Matters'));
  });

  test('a denied calendar permission is flagged distinctly', () async {
    when(
      () => calendarReader.fetchCommitments(
        start: any(named: 'start'),
        end: any(named: 'end'),
      ),
    ).thenThrow(const CalendarPermissionDeniedException());

    final result = await orchestrator.run();

    expect(result.calendarPermissionDenied, isTrue);
    expect(result.error, contains('Calendar'));
  });

  test('every run creates exactly one briefing_runs row and one snapshot_items row per candidate', () async {
    when(
      () => calendarReader.fetchCommitments(
        start: any(named: 'start'),
        end: any(named: 'end'),
      ),
    ).thenAnswer(
      (_) async => [
        _commitment('cal:a', clock().add(const Duration(hours: 1))),
        _commitment('cal:b', clock().add(const Duration(hours: 2))),
      ],
    );
    await tokenStorage.write('a-token');
    when(() => todoistClient.fetchTasks(any())).thenAnswer(
      (_) async => [
        const Task(
          id: 'td:x',
          title: 'x',
          priority: Priority.p2,
          isRecurring: false,
        ),
      ],
    );

    await orchestrator.run();
    await orchestrator.run();

    final runs = await database.select(database.briefingRuns).get();
    expect(runs, hasLength(2));

    final firstRunItems = await (database.select(
      database.snapshotItems,
    )..where((row) => row.runId.equals(runs.first.id))).get();
    expect(firstRunItems, hasLength(3));
  });
}
