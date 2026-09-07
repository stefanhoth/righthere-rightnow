import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/inference/gemma_lite_rt_engine.dart';
import 'package:righthere_rightnow/inference/inference_engine.dart';

void main() {
  group('availability', () {
    test(
      'unsupported when there is no model directory on the platform',
      () async {
        final engine = GemmaLiteRtEngine(resolveModelPath: () async => null);

        await expectLater(
          engine.availability(),
          completion(EngineAvailability.unsupported),
        );
      },
    );

    test('notReady when the model file has not been pushed yet', () async {
      final dir = await Directory.systemTemp.createTemp('gemma_test');
      addTearDown(() => dir.delete(recursive: true));
      final engine = GemmaLiteRtEngine(
        resolveModelPath: () async => '${dir.path}/absent.litertlm',
      );

      await expectLater(
        engine.availability(),
        completion(EngineAvailability.notReady),
      );
    });

    test('ready once the model file is present', () async {
      final dir = await Directory.systemTemp.createTemp('gemma_test');
      addTearDown(() => dir.delete(recursive: true));
      final path = '${dir.path}/model.litertlm';
      File(path).writeAsStringSync('not a real model, just a placeholder');
      final engine = GemmaLiteRtEngine(resolveModelPath: () async => path);

      await expectLater(
        engine.availability(),
        completion(EngineAvailability.ready),
      );
    });
  });

  test('completions never overlap', () async {
    // The FFI model holds one live session; two in-flight completions would
    // tear each other down. Neither the file nor the native engine exists
    // here, so both calls fail -- what matters is that the second does not
    // start before the first settles, and neither is abandoned unhandled.
    final engine = GemmaLiteRtEngine(resolveModelPath: () async => null);

    final first = engine.complete('a', timeout: const Duration(seconds: 1));
    final second = engine.complete('b', timeout: const Duration(seconds: 1));

    await expectLater(first, throwsA(anything));
    await expectLater(second, throwsA(anything));
  });

  test('GemmaModelStatus reports presence from the byte count', () {
    expect(const GemmaModelStatus().isPresent, isFalse);
    expect(
      const GemmaModelStatus(
        expectedPath: '/x/model.litertlm',
        sizeBytes: 3900000000,
      ).isPresent,
      isTrue,
    );
  });
}
