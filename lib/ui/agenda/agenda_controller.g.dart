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
    r'5de141bf2a68c982b8ad942e74e5361f3ae9c7b4';

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

/// When the newest Briefing Run finished, read fresh whenever
/// [DailyAgendaController] completes one -- including the live run it
/// triggers on every open, so a successful open always clears staleness.

@ProviderFor(lastBriefingRunCompletedAt)
final lastBriefingRunCompletedAtProvider =
    LastBriefingRunCompletedAtProvider._();

/// When the newest Briefing Run finished, read fresh whenever
/// [DailyAgendaController] completes one -- including the live run it
/// triggers on every open, so a successful open always clears staleness.

final class LastBriefingRunCompletedAtProvider
    extends
        $FunctionalProvider<
          AsyncValue<DateTime?>,
          DateTime?,
          FutureOr<DateTime?>
        >
    with $FutureModifier<DateTime?>, $FutureProvider<DateTime?> {
  /// When the newest Briefing Run finished, read fresh whenever
  /// [DailyAgendaController] completes one -- including the live run it
  /// triggers on every open, so a successful open always clears staleness.
  LastBriefingRunCompletedAtProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastBriefingRunCompletedAtProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastBriefingRunCompletedAtHash();

  @$internal
  @override
  $FutureProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DateTime?> create(Ref ref) {
    return lastBriefingRunCompletedAt(ref);
  }
}

String _$lastBriefingRunCompletedAtHash() =>
    r'72e695d4a5dfbb313dc5f7f0b031cce793f616b6';
