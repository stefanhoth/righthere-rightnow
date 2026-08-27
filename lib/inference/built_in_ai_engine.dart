import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_builtin_ai/flutter_gemma_builtin_ai.dart'
    as builtin_ai;
import 'package:righthere_rightnow/inference/inference_engine.dart';

/// Gemini Nano via ML Kit GenAI (AICore) -- see ADR-0004. The model and its
/// registration are created once and reused; recreating them per call would
/// pay the (documented up to ~10s) engine cold start on every completion.
class BuiltInAiEngine implements InferenceEngine {
  BuiltInAiEngine({this.maxTokens = 4096});

  final int maxTokens;

  Future<InferenceModel>? _model;

  @override
  Future<bool> isAvailable() async {
    try {
      final status = await builtin_ai.BuiltInAi.availability();
      return switch (status) {
        builtin_ai.BuiltInAiAvailability.available ||
        builtin_ai.BuiltInAiAvailability.downloadable ||
        builtin_ai.BuiltInAiAvailability.downloading => true,
        builtin_ai.BuiltInAiAvailability.unavailableDeviceUnsupported ||
        builtin_ai.BuiltInAiAvailability.unavailableOsTooOld ||
        builtin_ai.BuiltInAiAvailability.unavailableDisabled ||
        builtin_ai.BuiltInAiAvailability.unavailableOther => false,
      };
    } on Exception {
      return false;
    }
  }

  @override
  Future<String> complete(
    String prompt, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
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
