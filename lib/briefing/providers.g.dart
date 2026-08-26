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
