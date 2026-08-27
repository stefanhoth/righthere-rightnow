import 'package:righthere_rightnow/briefing/briefing_run_orchestrator.dart';
import 'package:righthere_rightnow/briefing/model_reranker.dart';
import 'package:righthere_rightnow/data/providers.dart';
import 'package:righthere_rightnow/inference/built_in_ai_engine.dart';
import 'package:righthere_rightnow/inference/inference_engine.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
BriefingRunOrchestrator briefingRunOrchestrator(Ref ref) {
  return BriefingRunOrchestrator(
    calendarReader: ref.watch(calendarReaderProvider),
    todoistClient: ref.watch(todoistClientProvider),
    todoistTokenStorage: ref.watch(todoistTokenStorageProvider),
    database: ref.watch(appDatabaseProvider),
    clock: DateTime.now,
  );
}

/// Kept alive: [BuiltInAiEngine] loads and caches the model once inference
/// is first requested (documented cold start of up to ~10s) -- recreating
/// it on every app open would pay that cost every time.
@Riverpod(keepAlive: true)
InferenceEngine inferenceEngine(Ref ref) => BuiltInAiEngine();

@riverpod
ModelReranker modelReranker(Ref ref) {
  return ModelReranker(
    engine: ref.watch(inferenceEngineProvider),
    database: ref.watch(appDatabaseProvider),
  );
}
