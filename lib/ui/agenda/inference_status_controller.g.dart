// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inference_status_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks what the model is doing for the Daily Agenda screen.
///
/// Kept beside the agenda rather than inside [BriefingRunResult]: inference
/// is fire-and-forget behind an agenda that is already rendered (ADR-0006),
/// so its progress is not part of the run's result and must not cause the
/// list to rebuild from a new result object.

@ProviderFor(InferenceStatusController)
final inferenceStatusControllerProvider = InferenceStatusControllerProvider._();

/// Tracks what the model is doing for the Daily Agenda screen.
///
/// Kept beside the agenda rather than inside [BriefingRunResult]: inference
/// is fire-and-forget behind an agenda that is already rendered (ADR-0006),
/// so its progress is not part of the run's result and must not cause the
/// list to rebuild from a new result object.
final class InferenceStatusControllerProvider
    extends $NotifierProvider<InferenceStatusController, InferenceStatus> {
  /// Tracks what the model is doing for the Daily Agenda screen.
  ///
  /// Kept beside the agenda rather than inside [BriefingRunResult]: inference
  /// is fire-and-forget behind an agenda that is already rendered (ADR-0006),
  /// so its progress is not part of the run's result and must not cause the
  /// list to rebuild from a new result object.
  InferenceStatusControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inferenceStatusControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inferenceStatusControllerHash();

  @$internal
  @override
  InferenceStatusController create() => InferenceStatusController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InferenceStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InferenceStatus>(value),
    );
  }
}

String _$inferenceStatusControllerHash() =>
    r'8e6ad1c23dc8f180b58a7e3b11a9e9dda7871064';

/// Tracks what the model is doing for the Daily Agenda screen.
///
/// Kept beside the agenda rather than inside [BriefingRunResult]: inference
/// is fire-and-forget behind an agenda that is already rendered (ADR-0006),
/// so its progress is not part of the run's result and must not cause the
/// list to rebuild from a new result object.

abstract class _$InferenceStatusController extends $Notifier<InferenceStatus> {
  InferenceStatus build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<InferenceStatus, InferenceStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<InferenceStatus, InferenceStatus>,
              InferenceStatus,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
