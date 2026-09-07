import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/briefing/inference_health.dart';
import 'package:righthere_rightnow/inference/inference_outcome.dart';

void main() {
  const failed = InferenceResultKind.failed;
  const succeeded = InferenceResultKind.succeeded;

  group('modelRankingPersistentlyFailing', () {
    test('a fresh install with no history is not a fault', () {
      expect(modelRankingPersistentlyFailing(const []), isFalse);
    });

    test('one bad run does not trip the banner', () {
      expect(modelRankingPersistentlyFailing(const [failed]), isFalse);
    });

    test('fewer failures than the threshold does not trip it', () {
      expect(modelRankingPersistentlyFailing(const [failed, failed]), isFalse);
    });

    test('the threshold in consecutive failures trips it', () {
      expect(
        modelRankingPersistentlyFailing(const [failed, failed, failed]),
        isTrue,
      );
    });

    test('a recent success inside the window keeps it down', () {
      expect(
        modelRankingPersistentlyFailing(const [failed, succeeded, failed]),
        isFalse,
      );
    });

    test(
      'only the newest results count -- older successes do not clear it',
      () {
        expect(
          modelRankingPersistentlyFailing(const [
            failed,
            failed,
            failed,
            succeeded,
            succeeded,
          ]),
          isTrue,
        );
      },
    );

    test('the newest result recovering clears it immediately', () {
      expect(
        modelRankingPersistentlyFailing(const [
          succeeded,
          failed,
          failed,
          failed,
        ]),
        isFalse,
      );
    });

    test('the threshold is the documented constant', () {
      expect(modelFailureRunsBeforeBanner, 3);
    });
  });
}
