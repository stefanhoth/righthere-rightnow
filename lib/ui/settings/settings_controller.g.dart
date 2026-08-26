// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(todoistTokenStorage)
final todoistTokenStorageProvider = TodoistTokenStorageProvider._();

final class TodoistTokenStorageProvider
    extends
        $FunctionalProvider<
          TodoistTokenStorage,
          TodoistTokenStorage,
          TodoistTokenStorage
        >
    with $Provider<TodoistTokenStorage> {
  TodoistTokenStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoistTokenStorageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoistTokenStorageHash();

  @$internal
  @override
  $ProviderElement<TodoistTokenStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TodoistTokenStorage create(Ref ref) {
    return todoistTokenStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodoistTokenStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodoistTokenStorage>(value),
    );
  }
}

String _$todoistTokenStorageHash() =>
    r'17ea5fbfb37688ccefe3a363da62197e805cef4f';

@ProviderFor(todoistClient)
final todoistClientProvider = TodoistClientProvider._();

final class TodoistClientProvider
    extends $FunctionalProvider<TodoistClient, TodoistClient, TodoistClient>
    with $Provider<TodoistClient> {
  TodoistClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoistClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoistClientHash();

  @$internal
  @override
  $ProviderElement<TodoistClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TodoistClient create(Ref ref) {
    return todoistClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodoistClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodoistClient>(value),
    );
  }
}

String _$todoistClientHash() => r'0b7cd236f2dcf48dfdccfedcd273aa77cbceb79e';

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
    r'8a96421915ebc8bfaa005e9fceba568e16ca30a4';

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
