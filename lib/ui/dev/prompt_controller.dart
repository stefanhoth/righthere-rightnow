import 'package:righthere_rightnow/briefing/prompt.dart';
import 'package:righthere_rightnow/data/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'prompt_controller.g.dart';

/// A single query for both the active prompt's text and version -- reading
/// them from two separate providers would let both see no prompt yet and
/// each seed the shipped default, disagreeing on the version.
@riverpod
Future<ActivePrompt> activePrompt(Ref ref) {
  return ref.watch(appDatabaseProvider).activePrompt();
}

/// Kept alive: nothing ever watches this controller's (void) state -- only
/// its `.notifier` methods are called -- so the default autoDispose would
/// tear it down between the `await` inside [save]/[resetToDefault] and its
/// use of `ref` afterwards.
@Riverpod(keepAlive: true)
class PromptEditController extends _$PromptEditController {
  @override
  void build() {}

  Future<void> save(String text) async {
    await ref.read(appDatabaseProvider).updatePrompt(text);
    ref.invalidate(activePromptProvider);
  }

  Future<void> resetToDefault() async {
    await ref.read(appDatabaseProvider).resetPromptToDefault();
    ref.invalidate(activePromptProvider);
  }
}
