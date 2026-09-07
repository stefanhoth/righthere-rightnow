import 'package:drift/drift.dart' show OrderingTerm;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:righthere_rightnow/briefing/briefing_run_orchestrator.dart';
import 'package:righthere_rightnow/briefing/providers.dart';
import 'package:righthere_rightnow/data/calendar/calendar_reader.dart';
import 'package:righthere_rightnow/data/db/app_database.dart';
import 'package:righthere_rightnow/data/providers.dart';
import 'package:righthere_rightnow/data/settings/todoist_token_storage.dart';
import 'package:righthere_rightnow/data/todoist/todoist_client.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/priority.dart';
import 'package:righthere_rightnow/domain/ranked_agenda.dart';
import 'package:righthere_rightnow/domain/response_status.dart';
import 'package:righthere_rightnow/domain/task_due.dart';
import 'package:righthere_rightnow/inference/inference_engine.dart';
import 'package:righthere_rightnow/ui/agenda/agenda_controller.dart';
import 'package:righthere_rightnow/ui/agenda/daily_agenda_screen.dart';
import 'package:righthere_rightnow/ui/agenda/source_opener.dart';

import '../../support/fake_what_matters_repository.dart';

class _MockCalendarReader extends Mock implements CalendarReader {}

class _MockTodoistClient extends Mock implements TodoistClient {}

class _MockTodoistTokenStorage extends Mock implements TodoistTokenStorage {}

/// Records what the screen asked to open instead of leaving the app, which
/// no widget test can follow.
class _RecordingSourceOpener implements SourceOpener {
  final opened = <AgendaItem>[];
  final openedUrls = <Uri>[];
  bool succeeds = true;

  @override
  Future<bool> open(AgendaItem item) async {
    opened.add(item);
    return succeeds;
  }

  @override
  Future<bool> openUrl(Uri url) async {
    openedUrls.add(url);
    return succeeds;
  }
}

/// Resolves synchronously, unlike the real engine's platform-channel probe --
/// that probe's own internal timeout leaves a pending Timer past the end of
/// a widget test that doesn't know to wait for the fire-and-forget re-rank.
class _FakeUnavailableEngine implements InferenceEngine {
  @override
  Future<EngineAvailability> availability() async =>
      EngineAvailability.unsupported;

  @override
  Future<String> complete(
    String prompt, {
    Duration timeout = Duration.zero,
    int? maxOutputTokens,
  }) {
    throw UnimplementedError();
  }
}

class _FakeOrchestrator extends BriefingRunOrchestrator {
  _FakeOrchestrator(this._result)
    : super(
        calendarReader: _MockCalendarReader(),
        todoistClient: _MockTodoistClient(),
        todoistTokenStorage: _MockTodoistTokenStorage(),
        whatMattersRepository: stubWhatMattersRepository(),
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

Future<void> _pumpAgenda(
  WidgetTester tester,
  BriefingRunResult result, {
  int? notificationLaunchRunId,
  DateTime? lastBriefingRunCompletedAt,
  AppDatabase? database,
  SourceOpener? sourceOpener,
  bool modelRankingFailing = false,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        briefingRunOrchestratorProvider.overrideWithValue(
          _FakeOrchestrator(result),
        ),
        notificationLaunchRunIdProvider.overrideWith(
          (ref) async => notificationLaunchRunId,
        ),
        lastBriefingRunCompletedAtProvider.overrideWith(
          (ref) async => lastBriefingRunCompletedAt,
        ),
        modelRankingFailingProvider.overrideWith(
          (ref) async => modelRankingFailing,
        ),
        inferenceEngineProvider.overrideWithValue(_FakeUnavailableEngine()),
        if (database != null) appDatabaseProvider.overrideWithValue(database),
        if (sourceOpener != null)
          sourceOpenerProvider.overrideWithValue(sourceOpener),
      ],
      child: const MaterialApp(home: DailyAgendaScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

/// Opens the Briefing Run summary, which is collapsed to a single bar at
/// the foot of the screen until tapped.
Future<void> _openSummarySheet(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('briefingSummaryBar')));
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
      candidateItems: const [],
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
    await _openSummarySheet(tester);
    expect(find.byKey(const Key('lastRunTime')), findsOneWidget);
  });

  group('which ranker ran (Task 4.3)', () {
    BriefingRunResult resultRankedBy(RankedBy rankedBy) => BriefingRunResult(
      runId: 1,
      candidateItems: const [],
      agenda: RankedAgenda(
        items: [_commitment(id: 'cal:standup')],
        rankedBy: rankedBy,
      ),
      allDayCommitments: const [],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
    );

    testWidgets('the indicator names the deterministic ranker before the '
        'model has answered', (tester) async {
      await _pumpAgenda(tester, resultRankedBy(RankedBy.fallback));

      expect(find.byKey(const Key('rankerIndicator')), findsOneWidget);
      expect(find.text('Ranked by rules'), findsOneWidget);
    });

    testWidgets('the indicator names the model once it has re-ranked', (
      tester,
    ) async {
      await _pumpAgenda(tester, resultRankedBy(RankedBy.model));

      expect(find.byKey(const Key('rankerIndicator')), findsOneWidget);
      expect(find.text('Ranked by the model'), findsOneWidget);
    });

    testWidgets('no breakage banner after a single fallback run', (
      tester,
    ) async {
      await _pumpAgenda(tester, resultRankedBy(RankedBy.fallback));

      expect(find.byKey(const Key('modelFailingBanner')), findsNothing);
    });

    testWidgets('the breakage banner shows once the model has failed for '
        'several runs', (tester) async {
      await _pumpAgenda(
        tester,
        resultRankedBy(RankedBy.fallback),
        modelRankingFailing: true,
      );

      expect(find.byKey(const Key('modelFailingBanner')), findsOneWidget);
      expect(find.byKey(const Key('rankerIndicator')), findsOneWidget);
    });

    testWidgets('the stale banner speaks alone -- the model banner defers to '
        'it', (tester) async {
      await _pumpAgenda(
        tester,
        resultRankedBy(RankedBy.fallback),
        lastBriefingRunCompletedAt: DateTime.now().subtract(
          const Duration(hours: 48),
        ),
        modelRankingFailing: true,
      );

      expect(find.byKey(const Key('staleBanner')), findsOneWidget);
      expect(find.byKey(const Key('modelFailingBanner')), findsNothing);
    });
  });

  testWidgets('a Commitment pill names the day it falls on', (tester) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final commitment = _commitment(
      id: 'cal:tomorrow',
      title: 'Kickoff',
      start: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 8),
    );
    final result = BriefingRunResult(
      runId: 1,
      candidateItems: const [],
      agenda: RankedAgenda(items: [commitment], rankedBy: RankedBy.fallback),
      allDayCommitments: const [],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
    );

    await _pumpAgenda(tester, result);

    expect(find.textContaining('Tomorrow'), findsOneWidget);
  });

  testWidgets(
    'an overdue Task shows an overdue pill and unwrapped link title',
    (tester) async {
      final task = Task(
        id: 'td:1',
        title: '[Buy a pencil sharpener](https://example.com/p/123)',
        priority: Priority.p3,
        isRecurring: false,
        due: TaskDue(
          date: DateTime.now().subtract(const Duration(days: 19)),
          hasTime: false,
          isRecurring: false,
        ),
      );
      final result = BriefingRunResult(
        runId: 1,
        candidateItems: const [],
        agenda: RankedAgenda(items: [task], rankedBy: RankedBy.fallback),
        allDayCommitments: const [],
        startedAt: DateTime(2026, 8, 26, 9),
        completedAt: DateTime(2026, 8, 26, 9, 0, 5),
      );

      await _pumpAgenda(tester, result);

      expect(find.text('Buy a pencil sharpener'), findsOneWidget);
      expect(find.textContaining('https://'), findsNothing);
      expect(find.text('19d overdue'), findsOneWidget);
    },
  );

  testWidgets('shows the empty state when there is nothing to do', (
    tester,
  ) async {
    final result = BriefingRunResult(
      runId: 1,
      candidateItems: const [],
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
      candidateItems: const [],
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
      candidateItems: const [],
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
      candidateItems: const [],
      agenda: RankedAgenda(items: [commitment], rankedBy: RankedBy.fallback),
      allDayCommitments: const [],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
    );

    await _pumpAgenda(tester, result);

    expect(find.byKey(const Key('joinConferenceButton')), findsOneWidget);
  });

  testWidgets('shows a banner when opened from the Focus Pull notification', (
    tester,
  ) async {
    final result = BriefingRunResult(
      runId: 1,
      candidateItems: const [],
      agenda: const RankedAgenda(items: [], rankedBy: RankedBy.fallback),
      allDayCommitments: const [],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
    );

    await _pumpAgenda(tester, result, notificationLaunchRunId: 1);

    expect(
      find.byKey(const Key('openedFromNotificationBanner')),
      findsOneWidget,
    );
  });

  testWidgets('shows no banner when opened normally, not from a notification', (
    tester,
  ) async {
    final result = BriefingRunResult(
      runId: 1,
      candidateItems: const [],
      agenda: const RankedAgenda(items: [], rankedBy: RankedBy.fallback),
      allDayCommitments: const [],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
    );

    await _pumpAgenda(tester, result);

    expect(find.byKey(const Key('openedFromNotificationBanner')), findsNothing);
  });

  testWidgets('dragging an item persists the corrected order', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final runId = await database
        .into(database.briefingRuns)
        .insert(
          BriefingRunsCompanion.insert(
            startedAt: DateTime(2026, 8, 26, 9),
            completedAt: DateTime(2026, 8, 26, 9, 0, 5),
            rankedBy: RankedBy.fallback,
          ),
        );
    final commitment = _commitment(id: 'cal:standup');
    const task = Task(
      id: 'td:1',
      title: 'File taxes',
      priority: Priority.p1,
      isRecurring: false,
    );
    await database
        .into(database.snapshotItems)
        .insert(
          SnapshotItemsCompanion.insert(
            runId: runId,
            itemId: commitment.id,
            payloadJson: '{}',
            fallbackRank: 0,
            producedRank: 0,
          ),
        );
    await database
        .into(database.snapshotItems)
        .insert(
          SnapshotItemsCompanion.insert(
            runId: runId,
            itemId: task.id,
            payloadJson: '{}',
            fallbackRank: 1,
            producedRank: 1,
          ),
        );
    final result = BriefingRunResult(
      runId: runId,
      candidateItems: const [],
      agenda: RankedAgenda(
        items: [commitment, task],
        rankedBy: RankedBy.fallback,
      ),
      allDayCommitments: const [],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
    );

    final container = ProviderContainer(
      overrides: [
        briefingRunOrchestratorProvider.overrideWithValue(
          _FakeOrchestrator(result),
        ),
        inferenceEngineProvider.overrideWithValue(_FakeUnavailableEngine()),
        appDatabaseProvider.overrideWithValue(database),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: DailyAgendaScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // A drag gesture on ReorderableListView is fiddly to simulate reliably
    // in a widget test; this exercises the same controller method the
    // list's `onReorderItem` callback calls, through the same container the
    // widget reads from.
    await container.read(dailyAgendaControllerProvider.notifier).reorder(0, 1);
    await tester.pumpAndSettle();

    final items = await (database.select(
      database.snapshotItems,
    )..orderBy([(s) => OrderingTerm.asc(s.itemId)])).get();
    final byId = {for (final item in items) item.itemId: item};
    expect(byId[commitment.id]!.correctedRank, 1);
    expect(byId[task.id]!.correctedRank, 0);
    // Original ranks are never touched.
    expect(byId[commitment.id]!.fallbackRank, 0);
    expect(byId[task.id]!.producedRank, 1);
  });

  testWidgets('rating a run persists a thumbs up', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final runId = await database
        .into(database.briefingRuns)
        .insert(
          BriefingRunsCompanion.insert(
            startedAt: DateTime(2026, 8, 26, 9),
            completedAt: DateTime(2026, 8, 26, 9, 0, 5),
            rankedBy: RankedBy.fallback,
          ),
        );
    final result = BriefingRunResult(
      runId: runId,
      candidateItems: const [],
      agenda: const RankedAgenda(items: [], rankedBy: RankedBy.fallback),
      allDayCommitments: const [],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
    );

    await _pumpAgenda(tester, result, database: database);
    await _openSummarySheet(tester);
    await tester.tap(find.byKey(const Key('thumbsUpButton')));
    await tester.pumpAndSettle();

    final rating = await database.select(database.runRatings).getSingle();
    expect(rating.runId, runId);
    expect(rating.rating, 1);
    expect(find.text('Noted.'), findsOneWidget);
  });

  testWidgets('shows the framing line when the run has one', (tester) async {
    final result = BriefingRunResult(
      runId: 1,
      candidateItems: const [],
      agenda: const RankedAgenda(items: [], rankedBy: RankedBy.fallback),
      allDayCommitments: const [],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
      framingLine: 'Heavy meeting day -- protect the morning.',
    );

    await _pumpAgenda(tester, result);

    // The collapsed bar carries it, so the day's framing is readable
    // without opening anything.
    expect(
      tester.widget<Text>(find.byKey(const Key('briefingSummaryBarText'))).data,
      'Heavy meeting day -- protect the morning.',
    );

    await _openSummarySheet(tester);

    expect(find.byKey(const Key('framingLine')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('framingLineText'))).data,
      'Heavy meeting day -- protect the morning.',
    );
  });

  testWidgets('shows no framing line when the run has none', (tester) async {
    final result = BriefingRunResult(
      runId: 1,
      candidateItems: const [],
      agenda: const RankedAgenda(items: [], rankedBy: RankedBy.fallback),
      allDayCommitments: const [],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
    );

    await _pumpAgenda(tester, result);
    await _openSummarySheet(tester);

    expect(find.byKey(const Key('framingLine')), findsNothing);
  });

  testWidgets('shows a stale banner when the last run is over a day old', (
    tester,
  ) async {
    final result = BriefingRunResult(
      runId: 1,
      candidateItems: const [],
      agenda: const RankedAgenda(items: [], rankedBy: RankedBy.fallback),
      allDayCommitments: const [],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
    );

    await _pumpAgenda(
      tester,
      result,
      lastBriefingRunCompletedAt: DateTime.now().subtract(
        const Duration(days: 3),
      ),
    );

    expect(find.byKey(const Key('staleBanner')), findsOneWidget);
  });

  testWidgets('shows no stale banner when the last run is recent', (
    tester,
  ) async {
    final result = BriefingRunResult(
      runId: 1,
      candidateItems: const [],
      agenda: const RankedAgenda(items: [], rankedBy: RankedBy.fallback),
      allDayCommitments: const [],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
    );

    await _pumpAgenda(
      tester,
      result,
      lastBriefingRunCompletedAt: DateTime.now(),
    );

    expect(find.byKey(const Key('staleBanner')), findsNothing);
  });

  testWidgets('all-day Commitments render as a header, not a ranked item', (
    tester,
  ) async {
    final offsite = _commitment(id: 'cal:offsite', title: 'Company offsite');
    final result = BriefingRunResult(
      runId: 1,
      candidateItems: const [],
      agenda: const RankedAgenda(items: [], rankedBy: RankedBy.fallback),
      allDayCommitments: [offsite],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
    );

    await _pumpAgenda(tester, result);

    expect(find.byKey(const Key('allDayHeader')), findsOneWidget);
    expect(find.text('Company offsite'), findsOneWidget);
  });

  testWidgets('tapping a Commitment opens it where it came from', (
    tester,
  ) async {
    final commitment = _commitment(id: 'cal:4711:1756540800000');
    final opener = _RecordingSourceOpener();
    final result = BriefingRunResult(
      runId: 1,
      candidateItems: const [],
      agenda: RankedAgenda(items: [commitment], rankedBy: RankedBy.fallback),
      allDayCommitments: const [],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
    );

    await _pumpAgenda(tester, result, sourceOpener: opener);
    await tester.tap(find.text('Standup'));
    await tester.pumpAndSettle();

    expect(opener.opened, [commitment]);
  });

  testWidgets('tapping a Task opens it where it came from', (tester) async {
    const task = Task(
      id: 'td:6X4Vw2',
      title: 'File taxes',
      priority: Priority.p1,
      isRecurring: false,
    );
    final opener = _RecordingSourceOpener();
    final result = BriefingRunResult(
      runId: 1,
      candidateItems: const [],
      agenda: const RankedAgenda(items: [task], rankedBy: RankedBy.fallback),
      allDayCommitments: const [],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
    );

    await _pumpAgenda(tester, result, sourceOpener: opener);
    await tester.tap(find.text('File taxes'));
    await tester.pumpAndSettle();

    expect(opener.opened, [task]);
  });

  testWidgets('says so when nothing on the device can open the source', (
    tester,
  ) async {
    final opener = _RecordingSourceOpener()..succeeds = false;
    final result = BriefingRunResult(
      runId: 1,
      candidateItems: const [],
      agenda: RankedAgenda(
        items: [_commitment(id: 'cal:4711:1756540800000')],
        rankedBy: RankedBy.fallback,
      ),
      allDayCommitments: const [],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
    );

    await _pumpAgenda(tester, result, sourceOpener: opener);
    await tester.tap(find.text('Standup'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('couldNotOpenSourceSnackBar')), findsOneWidget);
  });

  testWidgets("a Markdown link in a Task's title opens separately", (
    tester,
  ) async {
    const task = Task(
      id: 'td:6X4Vw2',
      title: '[Buy a sharpener](https://example.com/sharpener)',
      priority: Priority.p1,
      isRecurring: false,
    );
    final opener = _RecordingSourceOpener();
    final result = BriefingRunResult(
      runId: 1,
      candidateItems: const [],
      agenda: const RankedAgenda(items: [task], rankedBy: RankedBy.fallback),
      allDayCommitments: const [],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
    );

    await _pumpAgenda(tester, result, sourceOpener: opener);
    await tester.tap(find.byKey(const Key('openTitleLinkButton')));
    await tester.pumpAndSettle();

    // The link button opens the URL; the row itself still goes to Todoist.
    expect(opener.openedUrls, [Uri.parse('https://example.com/sharpener')]);
    expect(opener.opened, isEmpty);
  });

  testWidgets('the summary stays collapsed until it is asked for', (
    tester,
  ) async {
    final result = BriefingRunResult(
      runId: 1,
      candidateItems: const [],
      agenda: const RankedAgenda(items: [], rankedBy: RankedBy.fallback),
      allDayCommitments: const [],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
    );

    await _pumpAgenda(tester, result);

    expect(find.byKey(const Key('briefingSummaryBar')), findsOneWidget);
    expect(find.byKey(const Key('briefingSummarySheet')), findsNothing);
    expect(find.byKey(const Key('thumbsUpButton')), findsNothing);
    expect(find.byKey(const Key('lastRunTime')), findsNothing);
  });

  testWidgets('swiping the collapsed bar up opens the summary', (tester) async {
    final result = BriefingRunResult(
      runId: 1,
      candidateItems: const [],
      agenda: const RankedAgenda(items: [], rankedBy: RankedBy.fallback),
      allDayCommitments: const [],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
    );

    await _pumpAgenda(tester, result);
    await tester.fling(
      find.byKey(const Key('briefingSummaryBar')),
      const Offset(0, -80),
      800,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('briefingSummarySheet')), findsOneWidget);
  });

  testWidgets('swiping the collapsed bar down leaves it alone', (tester) async {
    final result = BriefingRunResult(
      runId: 1,
      candidateItems: const [],
      agenda: const RankedAgenda(items: [], rankedBy: RankedBy.fallback),
      allDayCommitments: const [],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
    );

    await _pumpAgenda(tester, result);
    await tester.fling(
      find.byKey(const Key('briefingSummaryBar')),
      const Offset(0, 80),
      800,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('briefingSummarySheet')), findsNothing);
  });

  testWidgets('tapping the grip closes the summary again', (tester) async {
    final result = BriefingRunResult(
      runId: 1,
      candidateItems: const [],
      agenda: const RankedAgenda(items: [], rankedBy: RankedBy.fallback),
      allDayCommitments: const [],
      startedAt: DateTime(2026, 8, 26, 9),
      completedAt: DateTime(2026, 8, 26, 9, 0, 5),
    );

    await _pumpAgenda(tester, result);
    await _openSummarySheet(tester);
    expect(find.byKey(const Key('briefingSummarySheet')), findsOneWidget);

    await tester.tap(find.byKey(const Key('briefingSummarySheetHandle')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('briefingSummarySheet')), findsNothing);
  });
}
