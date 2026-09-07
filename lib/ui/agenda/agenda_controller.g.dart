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
    r'94fca002185b1f60bbd1a5a2ad9c927c9e4775a0';

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

/// Overridden in widget tests: every real path here leaves the app.

@ProviderFor(sourceOpener)
final sourceOpenerProvider = SourceOpenerProvider._();

/// Overridden in widget tests: every real path here leaves the app.

final class SourceOpenerProvider
    extends $FunctionalProvider<SourceOpener, SourceOpener, SourceOpener>
    with $Provider<SourceOpener> {
  /// Overridden in widget tests: every real path here leaves the app.
  SourceOpenerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sourceOpenerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sourceOpenerHash();

  @$internal
  @override
  $ProviderElement<SourceOpener> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SourceOpener create(Ref ref) {
    return sourceOpener(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SourceOpener value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SourceOpener>(value),
    );
  }
}

String _$sourceOpenerHash() => r'0cfdc7b9727c5fa42cb41bbf5d748c0d47bebb73';

/// True while the model has failed to rank at
/// [modelFailureRunsBeforeBanner] consecutive app-opens -- the Daily Agenda
/// shows a breakage banner for as long as it holds. Re-read after every
/// recorded attempt. A device with no model at all reports skips, not
/// failures, and never trips this.

@ProviderFor(modelRankingFailing)
final modelRankingFailingProvider = ModelRankingFailingProvider._();

/// True while the model has failed to rank at
/// [modelFailureRunsBeforeBanner] consecutive app-opens -- the Daily Agenda
/// shows a breakage banner for as long as it holds. Re-read after every
/// recorded attempt. A device with no model at all reports skips, not
/// failures, and never trips this.

final class ModelRankingFailingProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// True while the model has failed to rank at
  /// [modelFailureRunsBeforeBanner] consecutive app-opens -- the Daily Agenda
  /// shows a breakage banner for as long as it holds. Re-read after every
  /// recorded attempt. A device with no model at all reports skips, not
  /// failures, and never trips this.
  ModelRankingFailingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'modelRankingFailingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$modelRankingFailingHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return modelRankingFailing(ref);
  }
}

String _$modelRankingFailingHash() =>
    r'847c8127e33480ac0ed1f95cb0ef1204c74bf838';

/// The most recent inference attempts, newest first -- the dev screen's
/// log of what the model did and how long it took (Task 4.3).

@ProviderFor(recentInferenceAttempts)
final recentInferenceAttemptsProvider = RecentInferenceAttemptsProvider._();

/// The most recent inference attempts, newest first -- the dev screen's
/// log of what the model did and how long it took (Task 4.3).

final class RecentInferenceAttemptsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InferenceAttemptRecord>>,
          List<InferenceAttemptRecord>,
          FutureOr<List<InferenceAttemptRecord>>
        >
    with
        $FutureModifier<List<InferenceAttemptRecord>>,
        $FutureProvider<List<InferenceAttemptRecord>> {
  /// The most recent inference attempts, newest first -- the dev screen's
  /// log of what the model did and how long it took (Task 4.3).
  RecentInferenceAttemptsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentInferenceAttemptsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentInferenceAttemptsHash();

  @$internal
  @override
  $FutureProviderElement<List<InferenceAttemptRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<InferenceAttemptRecord>> create(Ref ref) {
    return recentInferenceAttempts(ref);
  }
}

String _$recentInferenceAttemptsHash() =>
    r'39105c85364e297014b972c1b87f87900a0c8195';
