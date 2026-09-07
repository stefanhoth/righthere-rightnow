import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/briefing/inference_health.dart';
import 'package:righthere_rightnow/briefing/inference_status.dart';
import 'package:righthere_rightnow/inference/inference_outcome.dart';
import 'package:righthere_rightnow/ui/dev/inference_log.dart';

void main() {
  InferenceAttemptRecord record({
    InferenceWork work = InferenceWork.ranking,
    InferenceResultKind result = InferenceResultKind.succeeded,
    String? cause,
    int? durationMs,
  }) {
    return InferenceAttemptRecord(
      work: work,
      result: result,
      attemptedAt: DateTime.utc(2026, 8, 28, 5, 31).toLocal(),
      cause: cause,
      durationMs: durationMs,
    );
  }

  test('a successful ranking names the work and its timing', () {
    final line = describeInferenceAttempt(record(durationMs: 10850));

    expect(line, contains('Ranking'));
    expect(line, contains('ran'));
    expect(line, contains('10850 ms'));
  });

  test('a failure carries the cause', () {
    final line = describeInferenceAttempt(
      record(result: InferenceResultKind.failed, cause: 'timedOut'),
    );

    expect(line, contains('failed (timedOut)'));
  });

  test('a framing attempt that returned nothing reads as the model declining, '
      'not as a failure', () {
    final line = describeInferenceAttempt(
      record(
        work: InferenceWork.framing,
        result: InferenceResultKind.failed,
        cause: 'emptyOutput',
      ),
    );

    expect(line, contains('model wrote no line'));
    expect(line, isNot(contains('failed')));
  });

  test('the same empty output from ranking is still a failure', () {
    final line = describeInferenceAttempt(
      record(result: InferenceResultKind.failed, cause: 'emptyOutput'),
    );

    expect(line, contains('failed (emptyOutput)'));
  });

  test('an attempt with no recorded duration omits the timing', () {
    final line = describeInferenceAttempt(record());

    expect(line, isNot(contains('ms')));
  });
}
