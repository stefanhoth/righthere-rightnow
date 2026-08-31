import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart' as litertlm;
import 'package:path_provider/path_provider.dart';
import 'package:righthere_rightnow/inference/inference_engine.dart';

/// The file the app expects a downloaded Gemma `.litertlm` model at.
///
/// It is delivered by hand -- `adb push <model>.litertlm` into the app's
/// external files directory -- so a single sideloaded Pixel needs no
/// download UI (see DECISIONS.md, 2026-08-31). Settings shows this path.
///
/// E2B, not E4B: on the Pixel 9, loading E4B's ~3.7 GB of weights alongside
/// normal phone usage drove the whole system into memory pressure. E2B is
/// ~2 GB and the DECISIONS entry always named it the fallback.
const gemmaModelFileName = 'gemma4-e2b.litertlm';

/// Absolute path of [gemmaModelFileName] under the app's external files dir,
/// or null on a platform with no such dir (never Android, which is the only
/// target).
Future<String?> defaultGemmaModelPath() async {
  final dir = await getExternalStorageDirectory();
  if (dir == null) {
    return null;
  }
  return '${dir.path}/models/$gemmaModelFileName';
}

/// What Settings shows about the hand-delivered model file.
class GemmaModelStatus {
  const GemmaModelStatus({this.expectedPath, this.sizeBytes});

  /// Where to `adb push` the file. Null only on a non-Android platform.
  final String? expectedPath;

  /// Size of the file if it is there, otherwise null.
  final int? sizeBytes;

  bool get isPresent => sizeBytes != null;
}

Future<GemmaModelStatus> readGemmaModelStatus() async {
  final path = await defaultGemmaModelPath();
  if (path == null) {
    return const GemmaModelStatus();
  }
  final file = File(path);
  return GemmaModelStatus(
    expectedPath: path,
    sizeBytes: file.existsSync() ? file.lengthSync() : null,
  );
}

/// A downloaded Gemma model run over LiteRT-LM (dart:ffi) -- see DECISIONS.md
/// (2026-08-31) and ADR-0004. Unlike Nano via ML Kit GenAI, the output length
/// is caller-set (no 256-token ceiling) and sampling is controllable, which
/// the What Matters extraction needs.
class GemmaLiteRtEngine implements InferenceEngine {
  GemmaLiteRtEngine({
    this.resolveModelPath = defaultGemmaModelPath,
    this.maxTokens = 6144,
  });

  /// Injected in tests; resolves the absolute model-file path.
  final Future<String?> Function() resolveModelPath;

  /// Context window handed to LiteRT-LM. Covers the ranking prompt (~3.4k
  /// tokens with 25 items, plus the What Matters extraction block and an
  /// id-list answer) and the extraction prompt (the prose plus a full
  /// structured answer); kept well below the model's 32k ceiling so the KV
  /// cache does not add to memory pressure.
  final int maxTokens;

  /// The loaded model. Shared across every completion and loaded at most
  /// once per process -- loading multi-GB weights is slow and must not be
  /// re-attempted per call. Reset to null only on a genuine load *error*
  /// (not a caller's timeout), so a broken push can be retried after a fix.
  Future<InferenceModel>? _model;

  /// Serialises completions. LiteRT-LM's FFI model holds a single live
  /// session; two overlapping completions would tear each other down, the
  /// same failure `BuiltInAiEngine` queues around.
  Future<void> _queue = Future<void>.value();

  @override
  Future<EngineAvailability> availability() async {
    try {
      final path = await resolveModelPath();
      if (path == null) {
        return EngineAvailability.unsupported;
      }
      return File(path).existsSync()
          ? EngineAvailability.ready
          : EngineAvailability.notReady;
    } on Exception {
      return EngineAvailability.unsupported;
    }
  }

  @override
  Future<String> complete(
    String prompt, {
    Duration timeout = const Duration(seconds: 30),
    int? maxOutputTokens,
  }) {
    final result = _queue.then(
      (_) => _completeExclusively(prompt, timeout, maxOutputTokens),
    );
    _queue = result.then<void>((_) {}).catchError((Object _) {});
    return result;
  }

  Future<String> _completeExclusively(
    String prompt,
    Duration timeout,
    int? maxOutputTokens,
  ) async {
    // The cold load is deliberately NOT bounded by [timeout]: it can take
    // longer than any single completion should wait, and it is shared, so
    // the first caller pays for it and later callers reuse it. Only the
    // generation below honours [timeout].
    final model = await _ensureModelLoaded();
    final session = await model.createSession(
      // Enough randomness to break the repetition loops greedy decoding
      // falls into, still tight enough for coherent JSON. `randomSeed`
      // defaults to a fixed value, so a replay of the same prompt still
      // reproduces the same answer.
      temperature: 0.6,
      topK: 40,
      topP: 0.9,
      maxOutputTokens: maxOutputTokens,
    );
    try {
      await session.addQueryChunk(Message(text: prompt, isUser: true));
      return await session.getResponse().timeout(timeout);
    } finally {
      await session.close();
    }
  }

  Future<InferenceModel> _ensureModelLoaded() {
    final pending = _model;
    if (pending != null) {
      return pending;
    }
    final loading = _loadModel();
    _model = loading;
    // Drop the reference only if the load itself failed, so the next
    // completion retries a fresh load rather than awaiting a dead future.
    unawaited(
      loading.then<void>((_) {}).catchError((Object _) {
        if (identical(_model, loading)) {
          _model = null;
        }
      }),
    );
    return loading;
  }

  Future<InferenceModel> _loadModel() async {
    final stopwatch = Stopwatch()..start();
    try {
      final path = await resolveModelPath();
      if (path == null || !File(path).existsSync()) {
        throw Exception('Gemma model file is not present at $path');
      }
      await FlutterGemma.initialize(
        inferenceEngines: const [litertlm.LiteRtLmEngine()],
      );
      await FlutterGemma.installModel(
        modelType: ModelType.gemma4,
        fileType: ModelFileType.litertlm,
      ).fromFile(path).install();
      return await FlutterGemma.getActiveModel(maxTokens: maxTokens);
    } finally {
      developer.log(
        'Cold start: ${stopwatch.elapsedMilliseconds}ms',
        name: 'GemmaLiteRtEngine',
      );
    }
  }
}
