// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agenda_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DailyAgendaController)
final dailyAgendaControllerProvider = DailyAgendaControllerProvider._();

final class DailyAgendaControllerProvider
    extends $AsyncNotifierProvider<DailyAgendaController, BriefingRunResult> {
  DailyAgendaControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailyAgendaControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyAgendaControllerHash();

  @$internal
  @override
  DailyAgendaController create() => DailyAgendaController();
}

String _$dailyAgendaControllerHash() =>
    r'1da6fa7a51dc0939a7e28203eedcad9a9996f11a';

abstract class _$DailyAgendaController
    extends $AsyncNotifier<BriefingRunResult> {
  FutureOr<BriefingRunResult> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<BriefingRunResult>, BriefingRunResult>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BriefingRunResult>, BriefingRunResult>,
              AsyncValue<BriefingRunResult>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The runId of the Focus Pull notification that cold-started the app, if
/// any. `getNotificationAppLaunchDetails()` reports the same launch for the
/// life of the process, so this is safe to read more than once.

@ProviderFor(notificationLaunchRunId)
final notificationLaunchRunIdProvider = NotificationLaunchRunIdProvider._();

/// The runId of the Focus Pull notification that cold-started the app, if
/// any. `getNotificationAppLaunchDetails()` reports the same launch for the
/// life of the process, so this is safe to read more than once.

final class NotificationLaunchRunIdProvider
    extends $FunctionalProvider<AsyncValue<int?>, int?, FutureOr<int?>>
    with $FutureModifier<int?>, $FutureProvider<int?> {
  /// The runId of the Focus Pull notification that cold-started the app, if
  /// any. `getNotificationAppLaunchDetails()` reports the same launch for the
  /// life of the process, so this is safe to read more than once.
  NotificationLaunchRunIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationLaunchRunIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationLaunchRunIdHash();

  @$internal
  @override
  $FutureProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int?> create(Ref ref) {
    return notificationLaunchRunId(ref);
  }
}

String _$notificationLaunchRunIdHash() =>
    r'd2b103a4a32dd0b926aeafc5874b48d936b3a711';
