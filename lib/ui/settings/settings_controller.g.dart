// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(storedTodoistToken)
final storedTodoistTokenProvider = StoredTodoistTokenProvider._();

final class StoredTodoistTokenProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  StoredTodoistTokenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storedTodoistTokenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storedTodoistTokenHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return storedTodoistToken(ref);
  }
}

String _$storedTodoistTokenHash() =>
    r'001f9e768e8e4bb82f427c724e90e5772f5fa576';

@ProviderFor(calendarPermissionStatus)
final calendarPermissionStatusProvider = CalendarPermissionStatusProvider._();

final class CalendarPermissionStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<CalendarPermissionStatus>,
          CalendarPermissionStatus,
          FutureOr<CalendarPermissionStatus>
        >
    with
        $FutureModifier<CalendarPermissionStatus>,
        $FutureProvider<CalendarPermissionStatus> {
  CalendarPermissionStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarPermissionStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarPermissionStatusHash();

  @$internal
  @override
  $FutureProviderElement<CalendarPermissionStatus> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CalendarPermissionStatus> create(Ref ref) {
    return calendarPermissionStatus(ref);
  }
}

String _$calendarPermissionStatusHash() =>
    r'9ef88401c9ca294b41da9aeeb3cf08fad0d518d4';

@ProviderFor(batteryOptimizationStatus)
final batteryOptimizationStatusProvider = BatteryOptimizationStatusProvider._();

final class BatteryOptimizationStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<PermissionStatus>,
          PermissionStatus,
          FutureOr<PermissionStatus>
        >
    with $FutureModifier<PermissionStatus>, $FutureProvider<PermissionStatus> {
  BatteryOptimizationStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'batteryOptimizationStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$batteryOptimizationStatusHash();

  @$internal
  @override
  $FutureProviderElement<PermissionStatus> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PermissionStatus> create(Ref ref) {
    return batteryOptimizationStatus(ref);
  }
}

String _$batteryOptimizationStatusHash() =>
    r'58af76a862f73c1996ac1fbf33287d17e55719e1';

@ProviderFor(TokenEntryController)
final tokenEntryControllerProvider = TokenEntryControllerProvider._();

final class TokenEntryControllerProvider
    extends $NotifierProvider<TokenEntryController, TokenEntryStatus> {
  TokenEntryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenEntryControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenEntryControllerHash();

  @$internal
  @override
  TokenEntryController create() => TokenEntryController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TokenEntryStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TokenEntryStatus>(value),
    );
  }
}

String _$tokenEntryControllerHash() =>
    r'be33434617e66aff2d843f63a3b64f308f36ef53';

abstract class _$TokenEntryController extends $Notifier<TokenEntryStatus> {
  TokenEntryStatus build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TokenEntryStatus, TokenEntryStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TokenEntryStatus, TokenEntryStatus>,
              TokenEntryStatus,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
