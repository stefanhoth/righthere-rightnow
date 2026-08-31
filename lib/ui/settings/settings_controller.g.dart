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

@ProviderFor(storedWhatMattersConnection)
final storedWhatMattersConnectionProvider =
    StoredWhatMattersConnectionProvider._();

final class StoredWhatMattersConnectionProvider
    extends
        $FunctionalProvider<
          AsyncValue<WhatMattersConnection?>,
          WhatMattersConnection?,
          FutureOr<WhatMattersConnection?>
        >
    with
        $FutureModifier<WhatMattersConnection?>,
        $FutureProvider<WhatMattersConnection?> {
  StoredWhatMattersConnectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storedWhatMattersConnectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storedWhatMattersConnectionHash();

  @$internal
  @override
  $FutureProviderElement<WhatMattersConnection?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WhatMattersConnection?> create(Ref ref) {
    return storedWhatMattersConnection(ref);
  }
}

String _$storedWhatMattersConnectionHash() =>
    r'61fc8b3592da2f4b00f79d57aea3c380685a9c85';

/// The last good What Matters copy, so settings can show its age -- distinct
/// from the connection, which may be set before the first successful fetch.

@ProviderFor(cachedWhatMatters)
final cachedWhatMattersProvider = CachedWhatMattersProvider._();

/// The last good What Matters copy, so settings can show its age -- distinct
/// from the connection, which may be set before the first successful fetch.

final class CachedWhatMattersProvider
    extends
        $FunctionalProvider<
          AsyncValue<WhatMattersDocument?>,
          WhatMattersDocument?,
          FutureOr<WhatMattersDocument?>
        >
    with
        $FutureModifier<WhatMattersDocument?>,
        $FutureProvider<WhatMattersDocument?> {
  /// The last good What Matters copy, so settings can show its age -- distinct
  /// from the connection, which may be set before the first successful fetch.
  CachedWhatMattersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cachedWhatMattersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cachedWhatMattersHash();

  @$internal
  @override
  $FutureProviderElement<WhatMattersDocument?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WhatMattersDocument?> create(Ref ref) {
    return cachedWhatMatters(ref);
  }
}

String _$cachedWhatMattersHash() => r'6244805d48cefa3a47c574f5ea625233cb97af5b';

/// Whether the hand-delivered Gemma model file is in place, and where it
/// should go if not (see DECISIONS.md, 2026-08-31).

@ProviderFor(gemmaModelStatus)
final gemmaModelStatusProvider = GemmaModelStatusProvider._();

/// Whether the hand-delivered Gemma model file is in place, and where it
/// should go if not (see DECISIONS.md, 2026-08-31).

final class GemmaModelStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<GemmaModelStatus>,
          GemmaModelStatus,
          FutureOr<GemmaModelStatus>
        >
    with $FutureModifier<GemmaModelStatus>, $FutureProvider<GemmaModelStatus> {
  /// Whether the hand-delivered Gemma model file is in place, and where it
  /// should go if not (see DECISIONS.md, 2026-08-31).
  GemmaModelStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gemmaModelStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gemmaModelStatusHash();

  @$internal
  @override
  $FutureProviderElement<GemmaModelStatus> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GemmaModelStatus> create(Ref ref) {
    return gemmaModelStatus(ref);
  }
}

String _$gemmaModelStatusHash() => r'e98cd40315ab779e25c3a0e357ec6cc4e8f7a35d';

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

/// Verifies a Nextcloud connection by fetching the file once, then persists
/// it. Mirrors [TokenEntryController]: `invalid` is a rejected credential,
/// `error` is a wrong path or an unreachable server.

@ProviderFor(WhatMattersEntryController)
final whatMattersEntryControllerProvider =
    WhatMattersEntryControllerProvider._();

/// Verifies a Nextcloud connection by fetching the file once, then persists
/// it. Mirrors [TokenEntryController]: `invalid` is a rejected credential,
/// `error` is a wrong path or an unreachable server.
final class WhatMattersEntryControllerProvider
    extends
        $NotifierProvider<WhatMattersEntryController, WhatMattersEntryStatus> {
  /// Verifies a Nextcloud connection by fetching the file once, then persists
  /// it. Mirrors [TokenEntryController]: `invalid` is a rejected credential,
  /// `error` is a wrong path or an unreachable server.
  WhatMattersEntryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'whatMattersEntryControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$whatMattersEntryControllerHash();

  @$internal
  @override
  WhatMattersEntryController create() => WhatMattersEntryController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WhatMattersEntryStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WhatMattersEntryStatus>(value),
    );
  }
}

String _$whatMattersEntryControllerHash() =>
    r'8fc73fd9887c6b237be8a52738defea992b1dcd8';

/// Verifies a Nextcloud connection by fetching the file once, then persists
/// it. Mirrors [TokenEntryController]: `invalid` is a rejected credential,
/// `error` is a wrong path or an unreachable server.

abstract class _$WhatMattersEntryController
    extends $Notifier<WhatMattersEntryStatus> {
  WhatMattersEntryStatus build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<WhatMattersEntryStatus, WhatMattersEntryStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WhatMattersEntryStatus, WhatMattersEntryStatus>,
              WhatMattersEntryStatus,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
