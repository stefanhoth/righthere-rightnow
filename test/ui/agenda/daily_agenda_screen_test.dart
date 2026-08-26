import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:righthere_rightnow/briefing/briefing_run_orchestrator.dart';
import 'package:righthere_rightnow/briefing/providers.dart';
import 'package:righthere_rightnow/data/calendar/calendar_reader.dart';
import 'package:righthere_rightnow/data/db/app_database.dart';
import 'package:righthere_rightnow/data/settings/todoist_token_storage.dart';
import 'package:righthere_rightnow/data/todoist/todoist_client.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/priority.dart';
import 'package:righthere_rightnow/domain/ranked_agenda.dart';
import 'package:righthere_rightnow/domain/response_status.dart';
import 'package:righthere_rightnow/ui/agenda/daily_agenda_screen.dart';

class _MockCalendarReader extends Mock implements CalendarReader {}

class _MockTodoistClient extends Mock implements TodoistClient {}

class _MockTodoistTokenStorage extends Mock implements TodoistTokenStorage {}

class _FakeOrchestrator extends BriefingRunOrchestrator {
  _FakeOrchestrator(this._result)
    : super(
        calendarReader: _MockCalendarReader(),
        todoistClient: _MockTodoistClient(),
        todoistTokenStorage: _MockTodoistTokenStorage(),
        database: AppDatabase.forTesting(NativeDatabase.memory()),
        clock: DateTime.now,
      );

  final BriefingRunResult _result;

  @override
  Future<BriefingRunResult> run() async => _result;
}

Commitment _commitment({
  required String id,
  String title = 'Standup',
  DateTime? start,
  DateTime? end,
  bool isOrganiser = false,
  String? conferenceUrl,
}) {
  final effectiveStart = start ?? DateTime(2026, 8, 26, 10);
  return Commitment(
    id: id,
    title: title,
    start: effectiveStart,
    end: end ?? effectiveStart.add(const Duration(minutes: 30)),
    isAllDay: false,
    attendeeCount: 2,
    isOrganiser: isOrganiser,
    myResponse: ResponseStatus.accepted,
    isRecurring: false,
    calendarName: 'Work',
    conferenceUrl: conferenceUrl,
  );
}

Future<void> _pumpAgenda(WidgetTester tester, BriefingRunResult result) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        briefingRunOrchestratorProvider.overrideWithValue(
          _FakeOrchestrator(result),
        ),
      ],
      child: const MaterialApp(home: DailyAgendaScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows a populated list of ranked items', (tester) async {
    final commitment = _commitment(id: 'cal:standup');
    const task = Task(
      id: 'td:1',
      title: 'File taxes',
      priority: Priority.p1,
      isRecurring: false,
    );
    final result = BriefingRunResult(
      runId: 1,
      agenda: RankedAgenda(
        items: [commitment, task],
        rankedBy: RankedBy.fallback,
      ),
      allDayCommitments: const [],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
    );

    await _pumpAgenda(tester, result);

    expect(find.text('Standup'), findsOneWidget);
    expect(find.text('File taxes'), findsOneWidget);
    expect(find.byKey(const Key('lastRunTime')), findsOneWidget);
  });

  testWidgets('shows the empty state when there is nothing to do', (
    tester,
  ) async {
    final result = BriefingRunResult(
      runId: 1,
      agenda: const RankedAgenda(items: [], rankedBy: RankedBy.fallback),
      allDayCommitments: const [],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
    );

    await _pumpAgenda(tester, result);

    expect(find.byKey(const Key('agendaEmpty')), findsOneWidget);
  });

  testWidgets('shows a dedicated state when calendar permission is denied', (
    tester,
  ) async {
    final result = BriefingRunResult(
      runId: 1,
      agenda: const RankedAgenda(items: [], rankedBy: RankedBy.fallback),
      allDayCommitments: const [],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
      calendarPermissionDenied: true,
      error: 'Calendar: permission denied',
    );

    await _pumpAgenda(tester, result);

    expect(
      find.byKey(const Key('calendarPermissionDeniedMessage')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('agendaEmpty')), findsNothing);
  });

  testWidgets('shows a partial-data warning when a source failed', (
    tester,
  ) async {
    final commitment = _commitment(id: 'cal:standup');
    final result = BriefingRunResult(
      runId: 1,
      agenda: RankedAgenda(items: [commitment], rankedBy: RankedBy.fallback),
      allDayCommitments: const [],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
      error: 'Todoist: 503',
    );

    await _pumpAgenda(tester, result);

    expect(find.byKey(const Key('partialDataBanner')), findsOneWidget);
    expect(find.text('Standup'), findsOneWidget);
  });

  testWidgets('a conference link renders as a tappable join affordance', (
    tester,
  ) async {
    final commitment = _commitment(
      id: 'cal:standup',
      conferenceUrl: 'https://meet.google.com/abc-defg-hij',
    );
    final result = BriefingRunResult(
      runId: 1,
      agenda: RankedAgenda(items: [commitment], rankedBy: RankedBy.fallback),
      allDayCommitments: const [],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
    );

    await _pumpAgenda(tester, result);

    expect(find.byKey(const Key('joinConferenceButton')), findsOneWidget);
  });

  testWidgets('all-day Commitments render as a header, not a ranked item', (
    tester,
  ) async {
    final offsite = _commitment(id: 'cal:offsite', title: 'Company offsite');
    final result = BriefingRunResult(
      runId: 1,
      agenda: const RankedAgenda(items: [], rankedBy: RankedBy.fallback),
      allDayCommitments: [offsite],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
    );

    await _pumpAgenda(tester, result);

    expect(find.byKey(const Key('allDayHeader')), findsOneWidget);
    expect(find.text('Company offsite'), findsOneWidget);
  });
}
