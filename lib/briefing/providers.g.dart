// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(briefingRunOrchestrator)
final briefingRunOrchestratorProvider = BriefingRunOrchestratorProvider._();

final class BriefingRunOrchestratorProvider
    extends
        $FunctionalProvider<
          BriefingRunOrchestrator,
          BriefingRunOrchestrator,
          BriefingRunOrchestrator
        >
    with $Provider<BriefingRunOrchestrator> {
  BriefingRunOrchestratorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'briefingRunOrchestratorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$briefingRunOrchestratorHash();

  @$internal
  @override
  $ProviderElement<BriefingRunOrchestrator> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BriefingRunOrchestrator create(Ref ref) {
    return briefingRunOrchestrator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BriefingRunOrchestrator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BriefingRunOrchestrator>(value),
    );
  }
}

String _$briefingRunOrchestratorHash() =>
    r'4c218fb2d134ea6fc131a1125e9af8e08e5b1802';

/// Kept alive: [BuiltInAiEngine] loads and caches the model once inference
/// is first requested (documented cold start of up to ~10s) -- recreating
/// it on every app open would pay that cost every time.

@ProviderFor(inferenceEngine)
final inferenceEngineProvider = InferenceEngineProvider._();

/// Kept alive: [BuiltInAiEngine] loads and caches the model once inference
/// is first requested (documented cold start of up to ~10s) -- recreating
/// it on every app open would pay that cost every time.

final class InferenceEngineProvider
    extends
        $FunctionalProvider<InferenceEngine, InferenceEngine, InferenceEngine>
    with $Provider<InferenceEngine> {
  /// Kept alive: [BuiltInAiEngine] loads and caches the model once inference
  /// is first requested (documented cold start of up to ~10s) -- recreating
  /// it on every app open would pay that cost every time.
  InferenceEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inferenceEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inferenceEngineHash();

  @$internal
  @override
  $ProviderElement<InferenceEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  InferenceEngine create(Ref ref) {
    return inferenceEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InferenceEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InferenceEngine>(value),
    );
  }
}

String _$inferenceEngineHash() => r'e4c0e6d23ae873fda4a6e75bf5b9e6988f4bde85';

@ProviderFor(modelReranker)
final modelRerankerProvider = ModelRerankerProvider._();

final class ModelRerankerProvider
    extends $FunctionalProvider<ModelReranker, ModelReranker, ModelReranker>
    with $Provider<ModelReranker> {
  ModelRerankerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'modelRerankerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$modelRerankerHash();

  @$internal
  @override
  $ProviderElement<ModelReranker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ModelReranker create(Ref ref) {
    return modelReranker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ModelReranker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ModelReranker>(value),
    );
  }
}

String _$modelRerankerHash() => r'1e3760ba4aab3b1790a7e8a03ba66878e4e311dc';

@ProviderFor(framingLineGenerator)
final framingLineGeneratorProvider = FramingLineGeneratorProvider._();

final class FramingLineGeneratorProvider
    extends
        $FunctionalProvider<
          FramingLineGenerator,
          FramingLineGenerator,
          FramingLineGenerator
        >
    with $Provider<FramingLineGenerator> {
  FramingLineGeneratorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'framingLineGeneratorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$framingLineGeneratorHash();

  @$internal
  @override
  $ProviderElement<FramingLineGenerator> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FramingLineGenerator create(Ref ref) {
    return framingLineGenerator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FramingLineGenerator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FramingLineGenerator>(value),
    );
  }
}

String _$framingLineGeneratorHash() =>
    r'60acabccd700ec2b3e26b19edcfe215ddc5d5f11';
