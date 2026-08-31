// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inference_status_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks what the model is doing for the Daily Agenda screen.
///
/// Kept beside the agenda rather than inside the Briefing Run result:
/// inference
/// is fire-and-forget behind an agenda that is already rendered (ADR-0006),
/// so its progress is not part of the run's result and must not cause the
/// list to rebuild from a new result object.
// keepAlive: the agenda controller calls `started()` through
// `ref.read(...notifier)` before any widget watches this. Auto-disposed, the
// notifier is created, mutated, and thrown away in the same microtask, so
// the screen only ever watches a fresh empty status and shows nothing.

@ProviderFor(InferenceStatusController)
final inferenceStatusControllerProvider = InferenceStatusControllerProvider._();

/// Tracks what the model is doing for the Daily Agenda screen.
///
/// Kept beside the agenda rather than inside the Briefing Run result:
/// inference
/// is fire-and-forget behind an agenda that is already rendered (ADR-0006),
/// so its progress is not part of the run's result and must not cause the
/// list to rebuild from a new result object.
// keepAlive: the agenda controller calls `started()` through
// `ref.read(...notifier)` before any widget watches this. Auto-disposed, the
// notifier is created, mutated, and thrown away in the same microtask, so
// the screen only ever watches a fresh empty status and shows nothing.
final class InferenceStatusControllerProvider
    extends $NotifierProvider<InferenceStatusController, InferenceStatus> {
  /// Tracks what the model is doing for the Daily Agenda screen.
  ///
  /// Kept beside the agenda rather than inside the Briefing Run result:
  /// inference
  /// is fire-and-forget behind an agenda that is already rendered (ADR-0006),
  /// so its progress is not part of the run's result and must not cause the
  /// list to rebuild from a new result object.
  // keepAlive: the agenda controller calls `started()` through
  // `ref.read(...notifier)` before any widget watches this. Auto-disposed, the
  // notifier is created, mutated, and thrown away in the same microtask, so
  // the screen only ever watches a fresh empty status and shows nothing.
  InferenceStatusControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inferenceStatusControllerProvider',
        isAutoDispose: false,
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
    r'278fc147a875301602d09fbe0b646129733dbbef';

/// Tracks what the model is doing for the Daily Agenda screen.
///
/// Kept beside the agenda rather than inside the Briefing Run result:
/// inference
/// is fire-and-forget behind an agenda that is already rendered (ADR-0006),
/// so its progress is not part of the run's result and must not cause the
/// list to rebuild from a new result object.
// keepAlive: the agenda controller calls `started()` through
// `ref.read(...notifier)` before any widget watches this. Auto-disposed, the
// notifier is created, mutated, and thrown away in the same microtask, so
// the screen only ever watches a fresh empty status and shows nothing.

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
