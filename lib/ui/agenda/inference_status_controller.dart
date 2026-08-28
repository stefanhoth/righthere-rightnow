import 'package:righthere_rightnow/briefing/inference_status.dart';
import 'package:righthere_rightnow/inference/inference_engine.dart';
import 'package:righthere_rightnow/inference/inference_outcome.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inference_status_controller.g.dart';

/// Tracks what the model is doing for the Daily Agenda screen.
///
/// Kept beside the agenda rather than inside the Briefing Run result:
/// inference
/// is fire-and-forget behind an agenda that is already rendered (ADR-0006),
/// so its progress is not part of the run's result and must not cause the
/// list to rebuild from a new result object.
// keepAlive: the agenda controller calls `started()` through
// `ref.read(...notifier)` before any widget watches this. Auto-disposed, the
// notifier is created, mutated, and thrown away in the same microtask, so
// the screen only ever watches a fresh empty status and shows nothing.
@Riverpod(keepAlive: true)
class InferenceStatusController extends _$InferenceStatusController {
  @override
  InferenceStatus build() => const InferenceStatus();

  void started(InferenceWork work) => state = state.starting(work);

  void settled(InferenceWork work, InferenceOutcome<Object?> outcome) =>
      state = state.finished(work, _note(work, outcome));

  /// Resets for a new Briefing Run, so yesterday's failure is not shown
  /// against today's agenda.
  void reset() => state = const InferenceStatus();

  static String? _note(InferenceWork work, InferenceOutcome<Object?> outcome) {
    final isRanking = work == InferenceWork.ranking;
    return switch (outcome) {
      // A framing line that arrived speaks for itself; a model ranking does
      // not, because a good fallback order looks exactly the same.
      InferenceSucceeded<Object?>() => isRanking ? 'Ranked by the model' : null,
      InferenceSkipped<Object?>(:final availability) => switch (availability) {
        EngineAvailability.notReady => 'Model still downloading',
        EngineAvailability.unsupported => 'Model unavailable on this device',
        EngineAvailability.ready => null,
      },
      InferenceFailed<Object?>(:final failure) => switch (failure) {
        InferenceFailure.timedOut =>
          isRanking
              ? 'Ranked by rules — the model timed out'
              : 'The model timed out',
        InferenceFailure.engineThrew => 'The model failed to run',
        InferenceFailure.unusableOutput =>
          isRanking
              ? 'Ranked by rules — the model’s answer was unusable'
              : 'The model’s answer was unusable',
        InferenceFailure.emptyOutput => 'The model returned nothing',
      },
    };
  }
}
