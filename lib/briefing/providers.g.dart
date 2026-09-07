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
    r'ce95c09662efedf6fd84b0ec493aa1435ea7f64f';

/// Kept alive: [GemmaLiteRtEngine] loads and caches ~2 GB of model weights
/// the first time inference is requested -- recreating it on every app open
/// would pay that cost every time.
///
/// `BuiltInAiEngine` (Gemini Nano) stays in the tree as the ADR-0004
/// fallback; see DECISIONS.md (2026-08-31) for why it is not the default.

@ProviderFor(inferenceEngine)
final inferenceEngineProvider = InferenceEngineProvider._();

/// Kept alive: [GemmaLiteRtEngine] loads and caches ~2 GB of model weights
/// the first time inference is requested -- recreating it on every app open
/// would pay that cost every time.
///
/// `BuiltInAiEngine` (Gemini Nano) stays in the tree as the ADR-0004
/// fallback; see DECISIONS.md (2026-08-31) for why it is not the default.

final class InferenceEngineProvider
    extends
        $FunctionalProvider<InferenceEngine, InferenceEngine, InferenceEngine>
    with $Provider<InferenceEngine> {
  /// Kept alive: [GemmaLiteRtEngine] loads and caches ~2 GB of model weights
  /// the first time inference is requested -- recreating it on every app open
  /// would pay that cost every time.
  ///
  /// `BuiltInAiEngine` (Gemini Nano) stays in the tree as the ADR-0004
  /// fallback; see DECISIONS.md (2026-08-31) for why it is not the default.
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

String _$inferenceEngineHash() => r'bf7ad61a8c2e4d96e5324d98183a9be486889774';

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

@ProviderFor(whatMattersExtractor)
final whatMattersExtractorProvider = WhatMattersExtractorProvider._();

final class WhatMattersExtractorProvider
    extends
        $FunctionalProvider<
          WhatMattersExtractor,
          WhatMattersExtractor,
          WhatMattersExtractor
        >
    with $Provider<WhatMattersExtractor> {
  WhatMattersExtractorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'whatMattersExtractorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$whatMattersExtractorHash();

  @$internal
  @override
  $ProviderElement<WhatMattersExtractor> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WhatMattersExtractor create(Ref ref) {
    return whatMattersExtractor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WhatMattersExtractor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WhatMattersExtractor>(value),
    );
  }
}

String _$whatMattersExtractorHash() =>
    r'3d50c002bd6804190c6c9ee5fb44afdf821f889c';
