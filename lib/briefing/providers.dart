import 'package:righthere_rightnow/briefing/briefing_run_orchestrator.dart';
import 'package:righthere_rightnow/briefing/framing_line_generator.dart';
import 'package:righthere_rightnow/briefing/model_reranker.dart';
import 'package:righthere_rightnow/briefing/what_matters_extractor.dart';
import 'package:righthere_rightnow/data/providers.dart';
import 'package:righthere_rightnow/inference/gemma_lite_rt_engine.dart';
import 'package:righthere_rightnow/inference/inference_engine.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
BriefingRunOrchestrator briefingRunOrchestrator(Ref ref) {
  return BriefingRunOrchestrator(
    calendarReader: ref.watch(calendarReaderProvider),
    todoistClient: ref.watch(todoistClientProvider),
    todoistTokenStorage: ref.watch(todoistTokenStorageProvider),
    whatMattersRepository: ref.watch(whatMattersRepositoryProvider),
    database: ref.watch(appDatabaseProvider),
    clock: DateTime.now,
  );
}

/// Kept alive: [GemmaLiteRtEngine] loads and caches ~2 GB of model weights
/// the first time inference is requested -- recreating it on every app open
/// would pay that cost every time.
///
/// `BuiltInAiEngine` (Gemini Nano) stays in the tree as the ADR-0004
/// fallback; see DECISIONS.md (2026-08-31) for why it is not the default.
@Riverpod(keepAlive: true)
InferenceEngine inferenceEngine(Ref ref) => GemmaLiteRtEngine();

@riverpod
ModelReranker modelReranker(Ref ref) {
  return ModelReranker(
    engine: ref.watch(inferenceEngineProvider),
    database: ref.watch(appDatabaseProvider),
  );
}

@riverpod
FramingLineGenerator framingLineGenerator(Ref ref) {
  return FramingLineGenerator(
    engine: ref.watch(inferenceEngineProvider),
    database: ref.watch(appDatabaseProvider),
  );
}

@riverpod
WhatMattersExtractor whatMattersExtractor(Ref ref) {
  return WhatMattersExtractor(
    engine: ref.watch(inferenceEngineProvider),
    database: ref.watch(appDatabaseProvider),
    clock: DateTime.now,
  );
}
