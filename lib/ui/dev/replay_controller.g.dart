// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'replay_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Idle (data: null) until [run] is called -- this harness reasons over
/// stored history and the current prompt only; it never runs on its own.

@ProviderFor(ReplayController)
final replayControllerProvider = ReplayControllerProvider._();

/// Idle (data: null) until [run] is called -- this harness reasons over
/// stored history and the current prompt only; it never runs on its own.
final class ReplayControllerProvider
    extends $NotifierProvider<ReplayController, AsyncValue<ReplaySummary?>> {
  /// Idle (data: null) until [run] is called -- this harness reasons over
  /// stored history and the current prompt only; it never runs on its own.
  ReplayControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'replayControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$replayControllerHash();

  @$internal
  @override
  ReplayController create() => ReplayController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<ReplaySummary?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<ReplaySummary?>>(value),
    );
  }
}

String _$replayControllerHash() => r'0a73b0bcc958d63d4c90616293a5c0abc8208c60';

/// Idle (data: null) until [run] is called -- this harness reasons over
/// stored history and the current prompt only; it never runs on its own.

abstract class _$ReplayController
    extends $Notifier<AsyncValue<ReplaySummary?>> {
  AsyncValue<ReplaySummary?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<ReplaySummary?>, AsyncValue<ReplaySummary?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ReplaySummary?>,
                AsyncValue<ReplaySummary?>
              >,
              AsyncValue<ReplaySummary?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
