import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/briefing/inference_status.dart';

void main() {
  test('nothing to say before anything starts', () {
    expect(const InferenceStatus().summary, isNull);
    expect(const InferenceStatus().isRunning, isFalse);
  });

  test('names what it is waiting on, so the wait is visible', () {
    final status = const InferenceStatus().starting(InferenceWork.ranking);

    expect(status.isRunning, isTrue);
    expect(status.summary, 'Ranking your agenda…');
  });

  test('two queued jobs are both named', () {
    final status = const InferenceStatus()
        .starting(InferenceWork.ranking)
        .starting(InferenceWork.framing);

    expect(status.summary, contains('and'));
  });

  test('a finished job stops being waited on and reports its outcome', () {
    final status = const InferenceStatus()
        .starting(InferenceWork.ranking)
        .finished(InferenceWork.ranking, 'Ranked by rules — it timed out');

    expect(status.isRunning, isFalse);
    expect(status.summary, 'Ranked by rules — it timed out');
  });

  test('a null note means the outcome speaks for itself', () {
    final status = const InferenceStatus()
        .starting(InferenceWork.framing)
        .finished(InferenceWork.framing, null);

    expect(status.isRunning, isFalse);
    expect(status.summary, isNull);
  });

  test('running work outranks a finished note', () {
    // Ranking is still in flight; showing framing's result instead would
    // tell the user the model is done when it is not.
    final status = const InferenceStatus()
        .starting(InferenceWork.ranking)
        .starting(InferenceWork.framing)
        .finished(InferenceWork.framing, 'done');

    expect(status.summary, 'Ranking your agenda…');
  });

  test('the same failure is not reported twice', () {
    // Both jobs fail the same way when the engine itself is the problem.
    // That is one fact about the engine, not two.
    final status = const InferenceStatus()
        .starting(InferenceWork.ranking)
        .starting(InferenceWork.framing)
        .finished(InferenceWork.ranking, 'The model failed to run')
        .finished(InferenceWork.framing, 'The model failed to run');

    expect(status.summary, 'The model failed to run');
  });
}
