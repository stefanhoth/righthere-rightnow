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

/// The calendars the user could include in the Daily Agenda -- every
/// calendar the OS reports that is not hidden.

@ProviderFor(availableCalendars)
final availableCalendarsProvider = AvailableCalendarsProvider._();

/// The calendars the user could include in the Daily Agenda -- every
/// calendar the OS reports that is not hidden.

final class AvailableCalendarsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Calendar>>,
          List<Calendar>,
          FutureOr<List<Calendar>>
        >
    with $FutureModifier<List<Calendar>>, $FutureProvider<List<Calendar>> {
  /// The calendars the user could include in the Daily Agenda -- every
  /// calendar the OS reports that is not hidden.
  AvailableCalendarsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableCalendarsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availableCalendarsHash();

  @$internal
  @override
  $FutureProviderElement<List<Calendar>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Calendar>> create(Ref ref) {
    return availableCalendars(ref);
  }
}

String _$availableCalendarsHash() =>
    r'130a7ad619b01d6bc701ccd1397767c06ab259f2';

/// The calendars the user has chosen. An empty set means "every calendar in
/// [availableCalendars]" -- see [SelectedCalendarsStorage].

@ProviderFor(selectedCalendarIds)
final selectedCalendarIdsProvider = SelectedCalendarIdsProvider._();

/// The calendars the user has chosen. An empty set means "every calendar in
/// [availableCalendars]" -- see [SelectedCalendarsStorage].

final class SelectedCalendarIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          FutureOr<Set<String>>
        >
    with $FutureModifier<Set<String>>, $FutureProvider<Set<String>> {
  /// The calendars the user has chosen. An empty set means "every calendar in
  /// [availableCalendars]" -- see [SelectedCalendarsStorage].
  SelectedCalendarIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedCalendarIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedCalendarIdsHash();

  @$internal
  @override
  $FutureProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<String>> create(Ref ref) {
    return selectedCalendarIds(ref);
  }
}

String _$selectedCalendarIdsHash() =>
    r'f9ce4eb5c74da44702a3d1c8b423ff6be8e2e5fe';

@ProviderFor(SelectedCalendarsController)
final selectedCalendarsControllerProvider =
    SelectedCalendarsControllerProvider._();

final class SelectedCalendarsControllerProvider
    extends $NotifierProvider<SelectedCalendarsController, void> {
  SelectedCalendarsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedCalendarsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedCalendarsControllerHash();

  @$internal
  @override
  SelectedCalendarsController create() => SelectedCalendarsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$selectedCalendarsControllerHash() =>
    r'ac03de36d0e355766b77f9561dbae542c6aec845';

abstract class _$SelectedCalendarsController extends $Notifier<void> {
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
