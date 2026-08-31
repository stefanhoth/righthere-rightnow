import 'package:meta/meta.dart';
import 'package:righthere_rightnow/briefing/inference_status.dart';
import 'package:righthere_rightnow/inference/inference_outcome.dart';

/// How many consecutive failed ranking attempts the Daily Agenda tolerates
/// before it shows a breakage banner.
///
/// Mirrors `staleAfter` in `staleness.dart`: one bad run is noise, a run of
/// them is a fault worth interrupting for. Kept low because the model only
/// runs at app-open -- three failures is three separate opens, not three
/// minutes.
const modelFailureRunsBeforeBanner = 3;

/// True when the last [modelFailureRunsBeforeBanner] recorded ranking
/// results were all [InferenceResultKind.failed] -- the signal for the Daily
/// Agenda's model-breakage banner.
///
/// Skipped attempts are never recorded (a device with no model is the quiet
/// indicator's job), so an all-skip history simply leaves too few results
/// here and the banner stays down. Fewer than the threshold results on
/// record is never a fault.
bool modelRankingPersistentlyFailing(
  List<InferenceResultKind> recentRankingResultsNewestFirst,
) {
  if (recentRankingResultsNewestFirst.length < modelFailureRunsBeforeBanner) {
    return false;
  }
  return recentRankingResultsNewestFirst
      .take(modelFailureRunsBeforeBanner)
      .every((result) => result == InferenceResultKind.failed);
}

/// One persisted inference attempt, as the dev screen's log reads it. Kept
/// separate from the Drift row so the presentation layer need not import the
/// database, and so the fields it shows are the only ones it can show.
@immutable
class InferenceAttemptRecord {
  const InferenceAttemptRecord({
    required this.work,
    required this.result,
    required this.attemptedAt,
    this.cause,
    this.durationMs,
  });

  final InferenceWork work;
  final InferenceResultKind result;
  final DateTime attemptedAt;

  /// The failure or availability name from Task 4.1's outcome type, or null
  /// when [result] is [InferenceResultKind.succeeded].
  final String? cause;

  /// Wall-clock milliseconds the attempt took, or null when it was skipped.
  final int? durationMs;
}
