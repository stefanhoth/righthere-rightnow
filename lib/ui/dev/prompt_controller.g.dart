// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prompt_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A single query for both the active prompt's text and version -- reading
/// them from two separate providers would let both see no prompt yet and
/// each seed the shipped default, disagreeing on the version.

@ProviderFor(activePrompt)
final activePromptProvider = ActivePromptProvider._();

/// A single query for both the active prompt's text and version -- reading
/// them from two separate providers would let both see no prompt yet and
/// each seed the shipped default, disagreeing on the version.

final class ActivePromptProvider
    extends
        $FunctionalProvider<
          AsyncValue<ActivePrompt>,
          ActivePrompt,
          FutureOr<ActivePrompt>
        >
    with $FutureModifier<ActivePrompt>, $FutureProvider<ActivePrompt> {
  /// A single query for both the active prompt's text and version -- reading
  /// them from two separate providers would let both see no prompt yet and
  /// each seed the shipped default, disagreeing on the version.
  ActivePromptProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activePromptProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activePromptHash();

  @$internal
  @override
  $FutureProviderElement<ActivePrompt> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ActivePrompt> create(Ref ref) {
    return activePrompt(ref);
  }
}

String _$activePromptHash() => r'da0a70627606d8ef630033ab7224ca5cd87b1d8c';

/// Kept alive: nothing ever watches this controller's (void) state -- only
/// its `.notifier` methods are called -- so the default autoDispose would
/// tear it down between the `await` inside [save]/[resetToDefault] and its
/// use of `ref` afterwards.

@ProviderFor(PromptEditController)
final promptEditControllerProvider = PromptEditControllerProvider._();

/// Kept alive: nothing ever watches this controller's (void) state -- only
/// its `.notifier` methods are called -- so the default autoDispose would
/// tear it down between the `await` inside [save]/[resetToDefault] and its
/// use of `ref` afterwards.
final class PromptEditControllerProvider
    extends $NotifierProvider<PromptEditController, void> {
  /// Kept alive: nothing ever watches this controller's (void) state -- only
  /// its `.notifier` methods are called -- so the default autoDispose would
  /// tear it down between the `await` inside [save]/[resetToDefault] and its
  /// use of `ref` afterwards.
  PromptEditControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'promptEditControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$promptEditControllerHash();

  @$internal
  @override
  PromptEditController create() => PromptEditController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$promptEditControllerHash() =>
    r'f8e722f5b81f4e93556be43a7d25d1f28857c187';

/// Kept alive: nothing ever watches this controller's (void) state -- only
/// its `.notifier` methods are called -- so the default autoDispose would
/// tear it down between the `await` inside [save]/[resetToDefault] and its
/// use of `ref` afterwards.

abstract class _$PromptEditController extends $Notifier<void> {
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
