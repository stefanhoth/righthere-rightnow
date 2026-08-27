import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:righthere_rightnow/ui/dev/prompt_controller.dart';

/// Dev screen for Task 3.2 -- the prompt is versioned data (ADR-0003), so
/// editing it here changes the next Briefing Run's output with no rebuild.
class PromptScreen extends ConsumerStatefulWidget {
  const PromptScreen({super.key});

  @override
  ConsumerState<PromptScreen> createState() => _PromptScreenState();
}

class _PromptScreenState extends ConsumerState<PromptScreen> {
  final _controller = TextEditingController();

  /// Only ever set from the DB's own value, either on first load or right
  /// after a reset -- never touched by a `ref.watch` rebuild, so a
  /// save-triggered refetch can't stomp on text the user is mid-edit on.
  bool _loadedInitialText = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activePrompt = ref.watch(activePromptProvider);
    final prompt = activePrompt.value;

    if (prompt == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_loadedInitialText) {
      _controller.text = prompt.text;
      _loadedInitialText = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ranking prompt')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active version: v${prompt.version}',
              key: const Key('activePromptVersion'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                key: const Key('promptField'),
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                FilledButton(
                  key: const Key('savePromptButton'),
                  onPressed: () => ref
                      .read(promptEditControllerProvider.notifier)
                      .save(_controller.text),
                  child: const Text('Save'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  key: const Key('resetPromptButton'),
                  onPressed: () async {
                    await ref
                        .read(promptEditControllerProvider.notifier)
                        .resetToDefault();
                    final restored = await ref.read(
                      activePromptProvider.future,
                    );
                    if (context.mounted) {
                      setState(() => _controller.text = restored.text);
                    }
                  },
                  child: const Text('Reset to default'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
