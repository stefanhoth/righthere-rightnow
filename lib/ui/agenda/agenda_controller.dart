import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:righthere_rightnow/briefing/briefing_run_orchestrator.dart';
import 'package:righthere_rightnow/briefing/inference_status.dart';
import 'package:righthere_rightnow/briefing/providers.dart';
import 'package:righthere_rightnow/data/providers.dart';
import 'package:righthere_rightnow/domain/ranked_agenda.dart';
import 'package:righthere_rightnow/inference/inference_outcome.dart';
import 'package:righthere_rightnow/scheduling/notification_navigation.dart'
    as notification_navigation;
import 'package:righthere_rightnow/ui/agenda/inference_status_controller.dart';
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
    }
  }

  /// The deterministic agenda is already on screen by the time this is
  /// called (ADR-0006) -- this only ever reorders it in place once the
  /// model responds, and never blocks or replaces the initial render.
  void _rerankWithModel(BriefingRunResult fallbackResult) {
    final status = ref.read(inferenceStatusControllerProvider.notifier)
      ..started(InferenceWork.ranking);
    unawaited(
      ref.read(modelRerankerProvider).rerank(fallbackResult).then((outcome) {
        _logOutcome('rerank', outcome);
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
    unawaited(
      ref.read(framingLineGeneratorProvider).generate(fallbackResult).then((
        outcome,
      ) {
        _logOutcome('framingLine', outcome);
        status.settled(InferenceWork.framing, outcome);
        final line = outcome.valueOrNull;
        if (line != null) {
          _mergeIntoState((current) => current.copyWith(framingLine: line));
        }
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
