import 'dart:async';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:righthere_rightnow/briefing/briefing_run_orchestrator.dart';
import 'package:righthere_rightnow/briefing/model_ranking.dart';
import 'package:righthere_rightnow/briefing/model_reranker.dart';
import 'package:righthere_rightnow/data/calendar/calendar_reader.dart';
import 'package:righthere_rightnow/data/db/app_database.dart';
import 'package:righthere_rightnow/data/settings/todoist_token_storage.dart';
import 'package:righthere_rightnow/data/todoist/todoist_client.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/priority.dart';
import 'package:righthere_rightnow/domain/ranked_agenda.dart';
import 'package:righthere_rightnow/domain/task_due.dart';
import 'package:righthere_rightnow/inference/inference_engine.dart';
import 'package:righthere_rightnow/inference/inference_outcome.dart';

class _MockCalendarReader extends Mock implements CalendarReader {}

class _MockTodoistClient extends Mock implements TodoistClient {}

class _FakeInferenceEngine implements InferenceEngine {
  _FakeInferenceEngine({this.available = true, this.response, this.error});

  final bool available;
  final String? response;
  final Exception? error;

  @override
  Future<EngineAvailability> availability() async =>
      available ? EngineAvailability.ready : EngineAvailability.notReady;

  @override
  Future<String> complete(
    String prompt, {
    Duration timeout = Duration.zero,
    int? maxOutputTokens,
  }) async {
    if (error != null) {
      throw error!;
    }
    return response!;
  }
}

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

DateTime clock() => DateTime(2026, 8, 26, 9);

void main() {
  late AppDatabase database;
  late BriefingRunResult fallbackResult;

  setUpAll(() {
    registerFallbackValue(DateTime(0));
  });

  setUp(() async {
    final calendarReader = _MockCalendarReader();
    final todoistClient = _MockTodoistClient();
    FlutterSecureStoragePlatform.instance = _FakeSecureStoragePlatform();
    final tokenStorage = TodoistTokenStorage();
    database = AppDatabase.forTesting(NativeDatabase.memory());

    when(
      () => calendarReader.fetchCommitments(
        start: any(named: 'start'),
        end: any(named: 'end'),
      ),
    ).thenAnswer((_) async => []);
    await tokenStorage.write('a-token');
    when(() => todoistClient.fetchTasks(any())).thenAnswer(
      (_) async => [
        Task(
          id: 'td:1',
          title: 'File taxes',
          priority: Priority.p1,
          isRecurring: false,
          due: TaskDue(date: clock(), hasTime: false, isRecurring: false),
        ),
        const Task(
          id: 'td:2',
          title: 'Water the plants',
          priority: Priority.p4,
          isRecurring: false,
        ),
      ],
    );

    final orchestrator = BriefingRunOrchestrator(
      calendarReader: calendarReader,
      todoistClient: todoistClient,
      todoistTokenStorage: tokenStorage,
      database: database,
      clock: clock,
    );
    fallbackResult = await orchestrator.run();
  });

  tearDown(() => database.close());

  test('a valid model ranking is applied and persisted', () async {
    final ids = fallbackResult.agenda.items.map((i) => i.id).toList().reversed;
    final reranker = ModelReranker(
      engine: _FakeInferenceEngine(response: jsonEncode(ids.toList())),
      database: database,
    );

    final result = await reranker.rerank(fallbackResult);

    expect(result, isA<InferenceSucceeded<BriefingRunResult>>());
    final reranked = result.valueOrNull!;
    expect(reranked.agenda.rankedBy, RankedBy.model);
    expect(reranked.agenda.promptVersion, 'v1');
    expect(reranked.agenda.items.map((item) => item.id), ids);

    final storedRun = await (database.select(
      database.briefingRuns,
    )..where((r) => r.id.equals(fallbackResult.runId))).getSingle();
    expect(storedRun.rankedBy, RankedBy.model);
    expect(storedRun.promptVersion, 'v1');
  });

  test('an unavailable engine leaves the fallback result untouched', () async {
    final reranker = ModelReranker(
      engine: _FakeInferenceEngine(available: false),
      database: database,
    );

    final result = await reranker.rerank(fallbackResult);

    expect(result, _skippedBecause(EngineAvailability.notReady));
    final storedRun = await (database.select(
      database.briefingRuns,
    )..where((r) => r.id.equals(fallbackResult.runId))).getSingle();
    expect(storedRun.rankedBy, RankedBy.fallback);
  });

  test('a timing-out engine leaves the fallback result untouched', () async {
    final reranker = ModelReranker(
      engine: _FakeInferenceEngine(
        error: TimeoutException('too slow', const Duration(seconds: 1)),
      ),
      database: database,
    );

    final result = await reranker.rerank(fallbackResult);

    expect(result, _failedWith(InferenceFailure.timedOut));
  });

  test(
    'an engine that throws is distinguishable from one that times out',
    () async {
      final reranker = ModelReranker(
        engine: _FakeInferenceEngine(error: Exception('AICore is not there')),
        database: database,
      );

      final result = await reranker.rerank(fallbackResult);

      expect(result, _failedWith(InferenceFailure.engineThrew));
    },
  );

  test(
    'unparseable model output leaves the fallback result untouched',
    () async {
      final reranker = ModelReranker(
        engine: _FakeInferenceEngine(response: 'not json'),
        database: database,
      );

      final result = await reranker.rerank(fallbackResult);

      expect(result, _failedWith(InferenceFailure.unusableOutput));
      final storedRun = await (database.select(
        database.briefingRuns,
      )..where((r) => r.id.equals(fallbackResult.runId))).getSingle();
      expect(storedRun.rankedBy, RankedBy.fallback);
    },
  );

  test('the ranking answer is given room for every id', () async {
    // ML Kit defaults to 256 output tokens when no bound is passed, which
    // truncates a 25-item permutation mid-array. The bound has to scale with
    // the number of items, not be a constant.
    expect(rankingMaxOutputTokens(25), greaterThan(256));
    expect(rankingMaxOutputTokens(25), greaterThan(rankingMaxOutputTokens(5)));
  });

  test('an unusable answer is kept, so it can be diagnosed', () async {
    final reranker = ModelReranker(
      engine: _FakeInferenceEngine(response: '["td:1", "td:2'),
      database: database,
    );

    final result = await reranker.rerank(fallbackResult);

    expect(
      result,
      isA<InferenceFailed<BriefingRunResult>>().having(
        (outcome) => outcome.detail,
        'detail',
        '["td:1", "td:2',
      ),
    );
  });
}

Matcher _skippedBecause(EngineAvailability availability) =>
    isA<InferenceSkipped<BriefingRunResult>>().having(
      (outcome) => outcome.availability,
      'availability',
      availability,
    );

Matcher _failedWith(InferenceFailure failure) =>
    isA<InferenceFailed<BriefingRunResult>>().having(
      (outcome) => outcome.failure,
      'failure',
      failure,
    );
