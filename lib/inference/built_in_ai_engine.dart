import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_builtin_ai/flutter_gemma_builtin_ai.dart'
    as builtin_ai;
import 'package:meta/meta.dart';
import 'package:righthere_rightnow/inference/inference_engine.dart';

/// Gemini Nano via ML Kit GenAI (AICore) -- see ADR-0004. The model and its
/// registration are created once and reused; recreating them per call would
/// pay the (documented up to ~10s) engine cold start on every completion.
class BuiltInAiEngine implements InferenceEngine {
  BuiltInAiEngine({this.maxTokens = 4096});

  final int maxTokens;

  Future<InferenceModel>? _model;

  /// Serialises completions. The plugin's model holds a *single* native
  /// session -- `createSession()` closes the previous one -- so two
  /// overlapping completions destroy each other.
  Future<void> _queue = Future<void>.value();

  @override
  Future<EngineAvailability> availability() async {
    try {
      return engineAvailabilityFrom(await builtin_ai.BuiltInAi.availability());
    } on Exception {
      return EngineAvailability.unsupported;
    }
  }

  /// Completions are queued, never run in parallel.
  ///
  /// The Daily Agenda screen starts re-ranking and framing-line generation
  /// together. Both reach this method, both call `createSession()`, and the
  /// second closes the first's session -- the first then fails with
  /// `Bad state: Session is closed`, as an *unhandled* async error. Queueing
  /// is the engine's job: the interface promises `complete()` works, and no
  /// caller should have to know the native session is a singleton.
  ///
  /// [timeout] covers this completion only. It starts when the call reaches
  /// the front of the queue, so a slow completion ahead of it can never time
  /// this one out before it has begun.
  @override
  Future<String> complete(
    String prompt, {
    Duration timeout = const Duration(seconds: 30),
  }) {
    final result = _queue.then((_) => _completeExclusively(prompt, timeout));
    _queue = result.then<void>((_) {}).catchError((Object _) {});
    return result;
  }

  Future<String> _completeExclusively(String prompt, Duration timeout) async {
    final model = await (_model ??= _loadModel()).timeout(timeout);
    final session = await model.createSession();
    try {
      await session.addQueryChunk(Message(text: prompt, isUser: true));
      return await session.getResponse().timeout(timeout);
    } finally {
      await session.close();
    }
  }

  Future<InferenceModel> _loadModel() async {
    final stopwatch = Stopwatch()..start();
    try {
      await FlutterGemma.initialize(
        inferenceEngines: const [builtin_ai.BuiltInAiEngine()],
      );
      await builtin_ai.BuiltInAi.ensureReady();
      if (!FlutterGemma.hasActiveModel()) {
        await FlutterGemma.installModel(
          modelType: ModelType.general,
          fileType: ModelFileType.builtIn,
        ).fromBundled(builtin_ai.BuiltInAiModels.geminiNano.name).install();
      }
      return await FlutterGemma.getActiveModel(maxTokens: maxTokens);
    } catch (e) {
      // Let the next call retry instead of caching a failed load forever.
      _model = null;
      rethrow;
    } finally {
      developer.log(
        'Cold start: ${stopwatch.elapsedMilliseconds}ms',
        name: 'BuiltInAiEngine',
      );
    }
  }
}

/// Maps ML Kit's availability to ours.
///
/// `downloadable` and `downloading` were previously reported as available,
/// so on a device where AICore had not yet fetched Nano the caller passed
/// the check, called `complete()`, and failed. They are
/// [EngineAvailability.notReady]: the
/// model may arrive later, but it cannot answer a prompt now.
@visibleForTesting
EngineAvailability engineAvailabilityFrom(
  builtin_ai.BuiltInAiAvailability status,
) {
  return switch (status) {
    builtin_ai.BuiltInAiAvailability.available => EngineAvailability.ready,
    builtin_ai.BuiltInAiAvailability.downloadable ||
    builtin_ai.BuiltInAiAvailability.downloading => EngineAvailability.notReady,
    builtin_ai.BuiltInAiAvailability.unavailableDeviceUnsupported ||
    builtin_ai.BuiltInAiAvailability.unavailableOsTooOld ||
    builtin_ai.BuiltInAiAvailability.unavailableDisabled ||
    builtin_ai.BuiltInAiAvailability.unavailableOther =>
      EngineAvailability.unsupported,
  };
}
