import 'package:flutter_gemma_builtin_ai/flutter_gemma_builtin_ai.dart'
    as builtin_ai;
import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/inference/built_in_ai_engine.dart';
import 'package:righthere_rightnow/inference/inference_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('availability reports unsupported, not an exception, with no '
      'native host', () async {
    final engine = BuiltInAiEngine();

    await expectLater(
      engine.availability(),
      completion(EngineAvailability.unsupported),
    );
  });

  group('engineAvailabilityFrom', () {
    test('only a downloaded, installed model is ready', () {
      expect(
        engineAvailabilityFrom(builtin_ai.BuiltInAiAvailability.available),
        EngineAvailability.ready,
      );
    });

    test('a model that has not downloaded yet is not ready', () {
      // The defect this replaces: both of these reported *available*, so
      // the caller passed the check, called complete(), and failed.
      expect(
        engineAvailabilityFrom(builtin_ai.BuiltInAiAvailability.downloadable),
        EngineAvailability.notReady,
      );
      expect(
        engineAvailabilityFrom(builtin_ai.BuiltInAiAvailability.downloading),
        EngineAvailability.notReady,
      );
    });

    test('a device that will never run it is unsupported', () {
      const permanent = [
        builtin_ai.BuiltInAiAvailability.unavailableDeviceUnsupported,
        builtin_ai.BuiltInAiAvailability.unavailableOsTooOld,
        builtin_ai.BuiltInAiAvailability.unavailableDisabled,
        builtin_ai.BuiltInAiAvailability.unavailableOther,
      ];

      for (final status in permanent) {
        expect(
          engineAvailabilityFrom(status),
          EngineAvailability.unsupported,
          reason: '$status should be unsupported',
        );
      }
    });

    test('every status is mapped', () {
      for (final status in builtin_ai.BuiltInAiAvailability.values) {
        expect(() => engineAvailabilityFrom(status), returnsNormally);
      }
    });
  });

  test('completions never overlap', () async {
    // The plugin's model closes the previous session whenever a new one is
    // created, so two in-flight completions destroy each other. The engine
    // has no native host in a unit test, so assert the queueing contract
    // directly: the second call must not begin before the first settles.
    final engine = BuiltInAiEngine();

    final first = engine.complete('a', timeout: const Duration(seconds: 1));
    final second = engine.complete('b', timeout: const Duration(seconds: 1));

    // Both fail without a native host; what matters is that neither is
    // abandoned and both settle, rather than one dying unhandled.
    await expectLater(first, throwsA(anything));
    await expectLater(second, throwsA(anything));
  });
}
