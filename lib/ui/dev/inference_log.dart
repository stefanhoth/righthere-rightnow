import 'package:righthere_rightnow/briefing/inference_health.dart';
import 'package:righthere_rightnow/briefing/inference_status.dart';
import 'package:righthere_rightnow/inference/inference_outcome.dart';

/// A one-line summary of one persisted inference attempt for the dev screen's
/// log (Task 4.3): the time it started, what it was, what became of it, and
/// how long it took.
///
/// A framing attempt that ran but returned nothing is reported as the model
/// *declining* to write a line -- deliberately distinct from inference
/// failing, so an absent framing line is never ambiguous after the fact.
String describeInferenceAttempt(InferenceAttemptRecord attempt) {
  final work = switch (attempt.work) {
    InferenceWork.ranking => 'Ranking',
    InferenceWork.framing => 'Framing',
  };
  final outcome = switch (attempt.result) {
    InferenceResultKind.succeeded => 'ran',
    InferenceResultKind.skipped => 'skipped (${attempt.cause ?? 'unknown'})',
    InferenceResultKind.failed =>
      attempt.work == InferenceWork.framing && attempt.cause == 'emptyOutput'
          ? 'model wrote no line'
          : 'failed (${attempt.cause ?? 'unknown'})',
  };
  final timing = attempt.durationMs == null
      ? ''
      : ' · ${attempt.durationMs} ms';
  return '${_hhmm(attempt.attemptedAt)}  $work $outcome$timing';
}

String _hhmm(DateTime time) {
  final local = time.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(local.hour)}:${two(local.minute)}';
}
