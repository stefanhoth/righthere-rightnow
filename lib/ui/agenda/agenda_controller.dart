import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:righthere_rightnow/briefing/briefing_run_orchestrator.dart';
import 'package:righthere_rightnow/briefing/inference_health.dart';
import 'package:righthere_rightnow/briefing/inference_status.dart';
import 'package:righthere_rightnow/briefing/providers.dart';
import 'package:righthere_rightnow/data/providers.dart';
import 'package:righthere_rightnow/domain/ranked_agenda.dart';
import 'package:righthere_rightnow/inference/inference_outcome.dart';
import 'package:righthere_rightnow/scheduling/notification_navigation.dart'
    as notification_navigation;
import 'package:righthere_rightnow/ui/agenda/inference_status_controller.dart';
import 'package:righthere_rightnow/ui/agenda/source_opener.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'agenda_controller.g.dart';

@riverpod
class DailyAgendaController extends _$DailyAgendaController {
  @override
  Future<BriefingRunResult> build() async {
    final result = await ref.read(briefingRunOrchestratorProvider).run();
    ref.invalidate(lastBriefingRunCompletedAtProvider);
    ref.read(inferenceStatusControllerProvider.notifier).reset();
    _rerankWithModel(result);
    _generateFramingLine(result);
    _extractWhatMatters(result);
    return result;
  }

  Future<void> refresh() async {
    state = const AsyncLoading<BriefingRunResult>();
    state = await AsyncValue.guard(
      () => ref.read(briefingRunOrchestratorProvider).run(),
    );
    ref.invalidate(lastBriefingRunCompletedAtProvider);
    final result = state.value;
    if (result != null) {
      ref.read(inferenceStatusControllerProvider.notifier).reset();
      _rerankWithModel(result);
      _generateFramingLine(result);
      _extractWhatMatters(result);
    }
  }

  /// The deterministic agenda is already on screen by the time this is
  /// called (ADR-0006) -- this only ever reorders it in place once the
  /// model responds, and never blocks or replaces the initial render.
  void _rerankWithModel(BriefingRunResult fallbackResult) {
    final status = ref.read(inferenceStatusControllerProvider.notifier)
      ..started(InferenceWork.ranking);
    final stopwatch = Stopwatch()..start();
    unawaited(
      ref.read(modelRerankerProvider).rerank(fallbackResult).then((outcome) {
        stopwatch.stop();
        _logOutcome('rerank', outcome);
        _recordAttempt(
          fallbackResult.runId,
          InferenceWork.ranking,
          outcome,
          stopwatch.elapsed,
        );
        status.settled(InferenceWork.ranking, outcome);
        final reranked = outcome.valueOrNull;
        if (reranked != null) {
          _mergeIntoState(
            (current) => current.copyWith(agenda: reranked.agenda),
          );
        }
      }),
    );
  }

  /// Generated once per Briefing Run, alongside re-ranking -- never on
  /// every widget rebuild, and never a second time for the same run once
  /// this method has run for it.
  void _generateFramingLine(BriefingRunResult fallbackResult) {
    final status = ref.read(inferenceStatusControllerProvider.notifier)
      ..started(InferenceWork.framing);
    final stopwatch = Stopwatch()..start();
    unawaited(
      ref.read(framingLineGeneratorProvider).generate(fallbackResult).then((
        outcome,
      ) {
        stopwatch.stop();
        _logOutcome('framingLine', outcome);
        _recordAttempt(
          fallbackResult.runId,
          InferenceWork.framing,
          outcome,
          stopwatch.elapsed,
        );
        status.settled(InferenceWork.framing, outcome);
        final line = outcome.valueOrNull;
        if (line != null) {
          _mergeIntoState((current) => current.copyWith(framingLine: line));
        }
      }),
    );
  }

  /// Reads structure out of the What Matters prose once per Briefing Run
  /// (ADR-0008), only if the document has changed. Fire-and-forget: it feeds
  /// the *next* run's deterministic ranker, so nothing on screen waits for
  /// it. Recorded as an attempt for the dev screen; kept out of the status
  /// line by [InferenceStatusController].
  void _extractWhatMatters(BriefingRunResult fallbackResult) {
    if (fallbackResult.whatMatters == null) {
      // No What Matters document -- nothing to extract, and nothing worth
      // logging an attempt for.
      return;
    }
    final status = ref.read(inferenceStatusControllerProvider.notifier)
      ..started(InferenceWork.extraction);
    final stopwatch = Stopwatch()..start();
    unawaited(
      ref
          .read(whatMattersExtractorProvider)
          .extract(fallbackResult.whatMatters)
          .then((outcome) {
            stopwatch.stop();
            _logOutcome('whatMattersExtraction', outcome);
            _recordAttempt(
              fallbackResult.runId,
              InferenceWork.extraction,
              outcome,
              stopwatch.elapsed,
            );
            status.settled(InferenceWork.extraction, outcome);
          }),
    );
  }

  /// Persists one inference attempt with its cause and timing, then refreshes
  /// the model-health check that backs the Daily Agenda's breakage banner.
  ///
  /// A skipped attempt is not recorded: on a device with no model every
  /// app-open would skip, and a log of nothing-happened tells the dev screen
  /// less than the runs it would push out. "Unavailable here" is the live
  /// indicator's job, not the log's.
  ///
  /// Best-effort: a failed write must not take the agenda down with it.
  void _recordAttempt<T>(
    int runId,
    InferenceWork work,
    InferenceOutcome<T> outcome,
    Duration elapsed,
  ) {
    if (outcome is InferenceSkipped<T>) {
      return;
    }
    final (cause, detail) = switch (outcome) {
      InferenceFailed<T>(:final failure, :final detail) => (
        failure.name,
        detail,
      ),
      _ => (null, null),
    };
    unawaited(
      ref
          .read(appDatabaseProvider)
          .recordInferenceAttempt(
            runId: runId,
            work: work,
            result: inferenceResultKind(outcome),
            attemptedAt: DateTime.now(),
            cause: cause,
            detail: detail,
            duration: elapsed,
          )
          .then((_) {
            ref
              ..invalidate(modelRankingFailingProvider)
              ..invalidate(recentInferenceAttemptsProvider);
          })
          .catchError((Object error) {
            debugPrint('DailyAgendaController: attempt not recorded ($error)');
          }),
    );
  }

  /// Records why inference produced nothing, so Task 4.2's device check has
  /// something to read. Task 4.3 puts this on screen; until then the log is
  /// the only place a silent failure is visible at all.
  void _logOutcome<T>(String what, InferenceOutcome<T> outcome) {
    final detail = switch (outcome) {
      InferenceSucceeded<T>() => null,
      InferenceSkipped<T>(:final availability) =>
        'skipped: engine ${availability.name}',
      InferenceFailed<T>(:final failure, :final detail) =>
        'failed: ${failure.name}${detail == null ? '' : ' <<$detail>>'}',
    };
    if (detail != null) {
      // debugPrint, not developer.log: the latter never reached logcat in a
      // release build, which is where these failures actually happen. Only
      // the outcome is logged -- never the prompt, which carries calendar
      // and task content.
      debugPrint('DailyAgendaController: $what $detail');
    }
  }

  /// Applies [merge] to whatever the current state holds, not to the
  /// fallback result each fire-and-forget task started from -- reranking
  /// and framing-line generation complete independently, and each must
  /// preserve whatever the other has already applied.
  void _mergeIntoState(
    BriefingRunResult Function(BriefingRunResult current) merge,
  ) {
    final current = state.value;
    if (current != null && ref.mounted) {
      state = AsyncData(merge(current));
    }
  }

  /// A human dragged an Agenda Item to a new position. Updates the screen
  /// immediately with the chosen order, and persists it as
  /// `correctedRank` -- alongside, never over, the fallback and produced
  /// ranks (ADR-0003), so both the original and the corrected order stay
  /// queryable for any past run. Never touches calendar or Todoist data.
  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = state.value;
    if (current == null) {
      return;
    }

    final reordered = [...current.agenda.items];
    reordered.insert(newIndex, reordered.removeAt(oldIndex));

    state = AsyncData(
      current.copyWith(
        agenda: RankedAgenda(
          items: reordered,
          rankedBy: current.agenda.rankedBy,
          promptVersion: current.agenda.promptVersion,
        ),
      ),
    );

    await ref
        .read(appDatabaseProvider)
        .recordCorrectedOrder(
          runId: current.runId,
          correctedOrder: reordered.map((item) => item.id).toList(),
        );
  }

  /// The user says this Agenda Item needs nothing further.
  ///
  /// Only offered for past Commitments: they are on the list because a
  /// finished meeting may have created work, and "it did not" is a real
  /// answer. Removes it from the screen at once and remembers it, so the
  /// next Briefing Run does not put it back.
  ///
  /// Never touches the calendar -- this is the app's own note, not an edit
  /// to the event.
  Future<void> dismiss(String itemId) async {
    final current = state.value;
    if (current == null) {
      return;
    }

    state = AsyncData(
      current.copyWith(
        agenda: RankedAgenda(
          items: current.agenda.items
              .where((item) => item.id != itemId)
              .toList(),
          rankedBy: current.agenda.rankedBy,
          promptVersion: current.agenda.promptVersion,
        ),
      ),
    );

    await ref.read(appDatabaseProvider).dismissItem(itemId, at: DateTime.now());
  }

  /// Puts a dismissed Agenda Item back. Backs the undo action on the
  /// confirmation, so a mis-swipe costs one tap rather than a day.
  Future<void> undismiss(String itemId) async {
    await ref.read(appDatabaseProvider).undismissItem(itemId);
    await refresh();
  }

  /// A coarse thumbs up/down for this run, for a day not worth reordering.
  Future<void> rate(int rating) async {
    final current = state.value;
    if (current == null) {
      return;
    }
    await ref
        .read(appDatabaseProvider)
        .rateRun(runId: current.runId, rating: rating);
  }
}

/// The runId of the Focus Pull notification that cold-started the app, if
/// any. `getNotificationAppLaunchDetails()` reports the same launch for the
/// life of the process, so this is safe to read more than once.
@riverpod
Future<int?> notificationLaunchRunId(Ref ref) {
  return notification_navigation.notificationLaunchRunId();
}

/// When the newest Briefing Run finished, read fresh whenever
/// [DailyAgendaController] completes one -- including the live run it
/// triggers on every open, so a successful open always clears staleness.
@riverpod
Future<DateTime?> lastBriefingRunCompletedAt(Ref ref) {
  return ref.watch(appDatabaseProvider).latestBriefingRunCompletedAt();
}

/// Overridden in widget tests: every real path here leaves the app.
@riverpod
SourceOpener sourceOpener(Ref ref) => SourceOpener();

/// True while the model has failed to rank at
/// [modelFailureRunsBeforeBanner] consecutive app-opens -- the Daily Agenda
/// shows a breakage banner for as long as it holds. Re-read after every
/// recorded attempt. A device with no model at all reports skips, not
/// failures, and never trips this.
@riverpod
Future<bool> modelRankingFailing(Ref ref) async {
  final results = await ref.watch(appDatabaseProvider).recentRankingResults();
  return modelRankingPersistentlyFailing(results);
}

/// The most recent inference attempts, newest first -- the dev screen's
/// log of what the model did and how long it took (Task 4.3).
@riverpod
Future<List<InferenceAttemptRecord>> recentInferenceAttempts(Ref ref) {
  return ref.watch(appDatabaseProvider).recentInferenceAttempts();
}
