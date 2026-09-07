// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Shared, cross-cutting data-layer providers. Kept separate from any one
/// screen's controller so settings and the Daily Agenda don't have to
/// import each other just to share a token store or a database handle.

@ProviderFor(todoistTokenStorage)
final todoistTokenStorageProvider = TodoistTokenStorageProvider._();

/// Shared, cross-cutting data-layer providers. Kept separate from any one
/// screen's controller so settings and the Daily Agenda don't have to
/// import each other just to share a token store or a database handle.

final class TodoistTokenStorageProvider
    extends
        $FunctionalProvider<
          TodoistTokenStorage,
          TodoistTokenStorage,
          TodoistTokenStorage
        >
    with $Provider<TodoistTokenStorage> {
  /// Shared, cross-cutting data-layer providers. Kept separate from any one
  /// screen's controller so settings and the Daily Agenda don't have to
  /// import each other just to share a token store or a database handle.
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

@ProviderFor(calendarReader)
final calendarReaderProvider = CalendarReaderProvider._();

final class CalendarReaderProvider
    extends $FunctionalProvider<CalendarReader, CalendarReader, CalendarReader>
    with $Provider<CalendarReader> {
  CalendarReaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarReaderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarReaderHash();

  @$internal
  @override
  $ProviderElement<CalendarReader> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CalendarReader create(Ref ref) {
    return calendarReader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarReader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarReader>(value),
    );
  }
}

String _$calendarReaderHash() => r'2b7a5662cd37a99e714893405d5e5277f6e7806a';

@ProviderFor(runTimeStorage)
final runTimeStorageProvider = RunTimeStorageProvider._();

final class RunTimeStorageProvider
    extends $FunctionalProvider<RunTimeStorage, RunTimeStorage, RunTimeStorage>
    with $Provider<RunTimeStorage> {
  RunTimeStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runTimeStorageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runTimeStorageHash();

  @$internal
  @override
  $ProviderElement<RunTimeStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RunTimeStorage create(Ref ref) {
    return runTimeStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RunTimeStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RunTimeStorage>(value),
    );
  }
}

String _$runTimeStorageHash() => r'331efeecd6fc8b02ddb1438bc38dfac516c5050e';

@ProviderFor(selectedCalendarsStorage)
final selectedCalendarsStorageProvider = SelectedCalendarsStorageProvider._();

final class SelectedCalendarsStorageProvider
    extends
        $FunctionalProvider<
          SelectedCalendarsStorage,
          SelectedCalendarsStorage,
          SelectedCalendarsStorage
        >
    with $Provider<SelectedCalendarsStorage> {
  SelectedCalendarsStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedCalendarsStorageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedCalendarsStorageHash();

  @$internal
  @override
  $ProviderElement<SelectedCalendarsStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SelectedCalendarsStorage create(Ref ref) {
    return selectedCalendarsStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SelectedCalendarsStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SelectedCalendarsStorage>(value),
    );
  }
}

String _$selectedCalendarsStorageHash() =>
    r'd1dac90fa903515d6f2c048fe328c33d43768387';

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'949aad4bd88cefe20d76eb16900b182b5fcb494c';

@ProviderFor(whatMattersSettingsStorage)
final whatMattersSettingsStorageProvider =
    WhatMattersSettingsStorageProvider._();

final class WhatMattersSettingsStorageProvider
    extends
        $FunctionalProvider<
          WhatMattersSettingsStorage,
          WhatMattersSettingsStorage,
          WhatMattersSettingsStorage
        >
    with $Provider<WhatMattersSettingsStorage> {
  WhatMattersSettingsStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'whatMattersSettingsStorageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$whatMattersSettingsStorageHash();

  @$internal
  @override
  $ProviderElement<WhatMattersSettingsStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WhatMattersSettingsStorage create(Ref ref) {
    return whatMattersSettingsStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WhatMattersSettingsStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WhatMattersSettingsStorage>(value),
    );
  }
}

String _$whatMattersSettingsStorageHash() =>
    r'dadb09dd5ed7a8f552b97359683bcdb19ad72e70';

@ProviderFor(whatMattersClient)
final whatMattersClientProvider = WhatMattersClientProvider._();

final class WhatMattersClientProvider
    extends
        $FunctionalProvider<
          WhatMattersClient,
          WhatMattersClient,
          WhatMattersClient
        >
    with $Provider<WhatMattersClient> {
  WhatMattersClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'whatMattersClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$whatMattersClientHash();

  @$internal
  @override
  $ProviderElement<WhatMattersClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WhatMattersClient create(Ref ref) {
    return whatMattersClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WhatMattersClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WhatMattersClient>(value),
    );
  }
}

String _$whatMattersClientHash() => r'0998c1c040cd4ec5e3caa8e73cb77e1c9160f1db';

@ProviderFor(whatMattersRepository)
final whatMattersRepositoryProvider = WhatMattersRepositoryProvider._();

final class WhatMattersRepositoryProvider
    extends
        $FunctionalProvider<
          WhatMattersRepository,
          WhatMattersRepository,
          WhatMattersRepository
        >
    with $Provider<WhatMattersRepository> {
  WhatMattersRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'whatMattersRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$whatMattersRepositoryHash();

  @$internal
  @override
  $ProviderElement<WhatMattersRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WhatMattersRepository create(Ref ref) {
    return whatMattersRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WhatMattersRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WhatMattersRepository>(value),
    );
  }
}

String _$whatMattersRepositoryHash() =>
    r'fa1648d285ec23c354b6035de5412008b65cc46f';
