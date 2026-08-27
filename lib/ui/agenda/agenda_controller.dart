import 'dart:async';

import 'package:righthere_rightnow/briefing/briefing_run_orchestrator.dart';
import 'package:righthere_rightnow/briefing/providers.dart';
import 'package:righthere_rightnow/data/providers.dart';
import 'package:righthere_rightnow/scheduling/notification_navigation.dart'
    as notification_navigation;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'agenda_controller.g.dart';

@riverpod
class DailyAgendaController extends _$DailyAgendaController {
  @override
  Future<BriefingRunResult> build() async {
    final result = await ref.read(briefingRunOrchestratorProvider).run();
    ref.invalidate(lastBriefingRunCompletedAtProvider);
    _rerankWithModel(result);
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
      _rerankWithModel(result);
    }
  }

  /// The deterministic agenda is already on screen by the time this is
  /// called (ADR-0006) -- this only ever reorders it in place once the
  /// model responds, and never blocks or replaces the initial render.
  void _rerankWithModel(BriefingRunResult fallbackResult) {
    unawaited(
      ref.read(modelRerankerProvider).rerank(fallbackResult).then((reranked) {
        if (reranked != null && ref.mounted) {
          state = AsyncData(reranked);
        }
      }),
    );
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
