// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_time_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(storedRunTime)
final storedRunTimeProvider = StoredRunTimeProvider._();

final class StoredRunTimeProvider
    extends $FunctionalProvider<AsyncValue<RunTime>, RunTime, FutureOr<RunTime>>
    with $FutureModifier<RunTime>, $FutureProvider<RunTime> {
  StoredRunTimeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storedRunTimeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storedRunTimeHash();

  @$internal
  @override
  $FutureProviderElement<RunTime> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<RunTime> create(Ref ref) {
    return storedRunTime(ref);
  }
}

String _$storedRunTimeHash() => r'1519d6364a7967caa3fb5c45aac2282fbfdbaa99';

/// The next occurrence of the stored run time, purely computed from it and
/// the current clock -- so it's visible in Settings without waiting for the
/// alarm to actually fire, and without needing to query the native side for
/// what it last scheduled.

@ProviderFor(nextScheduledRun)
final nextScheduledRunProvider = NextScheduledRunProvider._();

/// The next occurrence of the stored run time, purely computed from it and
/// the current clock -- so it's visible in Settings without waiting for the
/// alarm to actually fire, and without needing to query the native side for
/// what it last scheduled.

final class NextScheduledRunProvider
    extends
        $FunctionalProvider<AsyncValue<DateTime>, DateTime, FutureOr<DateTime>>
    with $FutureModifier<DateTime>, $FutureProvider<DateTime> {
  /// The next occurrence of the stored run time, purely computed from it and
  /// the current clock -- so it's visible in Settings without waiting for the
  /// alarm to actually fire, and without needing to query the native side for
  /// what it last scheduled.
  NextScheduledRunProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nextScheduledRunProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nextScheduledRunHash();

  @$internal
  @override
  $FutureProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DateTime> create(Ref ref) {
    return nextScheduledRun(ref);
  }
}

String _$nextScheduledRunHash() => r'c27f97d9d4e4170e717504cd9d89f261e9dda116';

@ProviderFor(RunTimeController)
final runTimeControllerProvider = RunTimeControllerProvider._();

final class RunTimeControllerProvider
    extends $NotifierProvider<RunTimeController, void> {
  RunTimeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runTimeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runTimeControllerHash();

  @$internal
  @override
  RunTimeController create() => RunTimeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$runTimeControllerHash() => r'f6aa2aa8b4685daa8ccb27fd079ad6db37133898';

abstract class _$RunTimeController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
