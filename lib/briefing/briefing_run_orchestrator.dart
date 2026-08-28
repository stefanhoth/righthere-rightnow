import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:righthere_rightnow/briefing/candidate_set_assembly.dart';
import 'package:righthere_rightnow/briefing/clock.dart';
import 'package:righthere_rightnow/briefing/fallback_ranker.dart';
import 'package:righthere_rightnow/data/calendar/calendar_exception.dart';
import 'package:righthere_rightnow/data/calendar/calendar_reader.dart';
import 'package:righthere_rightnow/data/db/app_database.dart';
import 'package:righthere_rightnow/data/db/candidate_item_json.dart';
import 'package:righthere_rightnow/data/settings/todoist_token_storage.dart';
import 'package:righthere_rightnow/data/todoist/todoist_client.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/candidate_set.dart';
import 'package:righthere_rightnow/domain/ranked_agenda.dart';

/// What one Briefing Run produced.
@immutable
class BriefingRunResult {
  const BriefingRunResult({
    required this.runId,
    required this.agenda,
    required this.candidateItems,
    required this.allDayCommitments,
    required this.startedAt,
    required this.completedAt,
    this.calendarPermissionDenied = false,
    this.error,
    this.framingLine,
  });

  final int runId;
  final RankedAgenda agenda;

  /// The full Candidate Set, features included -- what an Inference Engine
  /// re-ranking this run needs to reason over (ADR-0003). Always in
  /// fallback-rank order, independent of [agenda]'s current order.
  final List<CandidateItem> candidateItems;

  final List<Commitment> allDayCommitments;
  final DateTime startedAt;
  final DateTime completedAt;

  /// Calendar permission was denied outright, rather than the read simply
  /// failing -- the UI has a dedicated state for this, distinct from a
  /// generic partial-data warning.
  final bool calendarPermissionDenied;

  /// Set when one or more sources failed. The run still produces an agenda
  /// from whatever succeeded.
  final String? error;

  /// One generated sentence framing the day, or null if inference hasn't
  /// produced one yet -- or never will for this run. Never shown on the
  /// lock screen (ADR-0006): the Focus Pull posts before any model runs.
  final String? framingLine;

  bool get isPartial => error != null;

  /// A copy with [agenda] and/or [framingLine] replaced -- the two things
  /// that change after the initial, fallback-ranked result: a successful
  /// model re-rank, and a successful framing-line generation. Each can
  /// complete independently and later than the other, so applying one must
  /// never lose whichever the other already applied.
  BriefingRunResult copyWith({RankedAgenda? agenda, String? framingLine}) {
    return BriefingRunResult(
      runId: runId,
      agenda: agenda ?? this.agenda,
      candidateItems: candidateItems,
      allDayCommitments: allDayCommitments,
      startedAt: startedAt,
      completedAt: completedAt,
      calendarPermissionDenied: calendarPermissionDenied,
      error: error,
      framingLine: framingLine ?? this.framingLine,
    );
  }
}

/// Wires a Briefing Run together: fetch Commitments and Tasks in parallel,
/// assemble the Candidate Set, rank it, persist the snapshot, and return the
/// resulting Daily Agenda.
///
/// One source failing never fails the run -- a Todoist outage still yields
/// an agenda of Commitments (and vice versa), with the failure recorded on
/// the result and in the persisted `briefing_runs` row.
class BriefingRunOrchestrator {
  BriefingRunOrchestrator({
    required this.calendarReader,
    required this.todoistClient,
    required this.todoistTokenStorage,
    required this.database,
    required this.clock,
  });

  final CalendarReader calendarReader;
  final TodoistClient todoistClient;
  final TodoistTokenStorage todoistTokenStorage;
  final AppDatabase database;
  final Clock clock;

  Future<BriefingRunResult> run() async {
    final startedAt = clock();
    final window = commitmentFetchWindow(clock);

    // Started together, not one after another: both futures begin running
    // before either is awaited.
    final commitmentsFuture = _fetchCommitments(window);
    final tasksFuture = _fetchTasks();
    final commitmentsOutcome = await commitmentsFuture;
    final tasksOutcome = await tasksFuture;

    // A dismissed Agenda Item is gone before ranking, not hidden after it:
    // it must not occupy one of the 25 candidate slots, reach the model, or
    // appear in the snapshot as something that competed.
    final dismissed = await database.dismissedItemIds();

    final assembler = CandidateSetAssembler(clock: clock, rank: fallbackScore);
    final candidateSet = assembler.assemble(
      fetchedCommitments: commitmentsOutcome.items
          .where((commitment) => !dismissed.contains(commitment.id))
          .toList(),
      fetchedTasks: tasksOutcome.items
          .where((task) => !dismissed.contains(task.id))
          .toList(),
    );

    final rankedItems = rankFallback(
      candidateSet.items.map((candidate) => candidate.item).toList(),
      clock,
    );

    final completedAt = clock();
    final error = [?commitmentsOutcome.error, ?tasksOutcome.error].join('; ');

    final runId = await _persist(
      startedAt: startedAt,
      completedAt: completedAt,
      candidateSet: candidateSet,
      rankedItems: rankedItems,
      error: error.isEmpty ? null : error,
    );

    return BriefingRunResult(
      runId: runId,
      agenda: RankedAgenda(items: rankedItems, rankedBy: RankedBy.fallback),
      candidateItems: candidateSet.items,
      allDayCommitments: candidateSet.allDayCommitments,
      startedAt: startedAt,
      completedAt: completedAt,
      calendarPermissionDenied: commitmentsOutcome.permissionDenied,
      error: error.isEmpty ? null : error,
    );
  }

  Future<_FetchOutcome<Commitment>> _fetchCommitments(
    CommitmentFetchWindow window,
  ) async {
    try {
      final commitments = await calendarReader.fetchCommitments(
        start: window.start,
        end: window.end,
      );
      return _FetchOutcome(items: commitments);
    } on CalendarPermissionDeniedException {
      return const _FetchOutcome(
        items: [],
        error: 'Calendar: permission denied',
        permissionDenied: true,
      );
    } on Exception catch (e) {
      return _FetchOutcome(items: const [], error: 'Calendar: $e');
    }
  }

  Future<_FetchOutcome<Task>> _fetchTasks() async {
    final token = await todoistTokenStorage.read();
    if (token == null) {
      return const _FetchOutcome(
        items: [],
        error: 'Todoist: no token configured',
      );
    }
    try {
      final tasks = await todoistClient.fetchTasks(token);
      return _FetchOutcome(items: tasks);
    } on Exception catch (e) {
      return _FetchOutcome(items: const [], error: 'Todoist: $e');
    }
  }

  Future<int> _persist({
    required DateTime startedAt,
    required DateTime completedAt,
    required CandidateSet candidateSet,
    required List<AgendaItem> rankedItems,
    required String? error,
  }) {
    return database.transaction(() async {
      final runId = await database
          .into(database.briefingRuns)
          .insert(
            BriefingRunsCompanion.insert(
              startedAt: startedAt,
              completedAt: completedAt,
              rankedBy: RankedBy.fallback,
              error: Value(error),
            ),
          );

      final rankPositionById = {
        for (final (index, item) in rankedItems.indexed) item.id: index,
      };

      for (final candidateItem in candidateSet.items) {
        final rank = rankPositionById[candidateItem.item.id] ?? 0;
        await database
            .into(database.snapshotItems)
            .insert(
              SnapshotItemsCompanion.insert(
                runId: runId,
                itemId: candidateItem.item.id,
                payloadJson: jsonEncode(candidateItemToJson(candidateItem)),
                fallbackRank: rank,
                producedRank: rank,
              ),
            );
      }

      return runId;
    });
  }
}

@immutable
class _FetchOutcome<T> {
  const _FetchOutcome({
    required this.items,
    this.error,
    this.permissionDenied = false,
  });

  final List<T> items;
  final String? error;
  final bool permissionDenied;
}
