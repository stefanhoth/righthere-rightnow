import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:righthere_rightnow/ui/dev/prompt_controller.dart';
import 'package:righthere_rightnow/ui/dev/replay_controller.dart';

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
            const Divider(height: 32),
            const _ReplaySection(),
          ],
        ),
      ),
    );
  }
}

/// "Edit prompt -> replay stored days -> diff orderings" (Task 3.6): runs
/// the harness against every stored Briefing Run under the prompt above,
/// without touching the network or writing a new Briefing Run.
class _ReplaySection extends ConsumerWidget {
  const _ReplaySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final replay = ref.watch(replayControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Replay', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        FilledButton(
          key: const Key('runReplayButton'),
          onPressed: replay.isLoading
              ? null
              : () => ref.read(replayControllerProvider.notifier).run(),
          child: replay.isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Replay against stored history'),
        ),
        const SizedBox(height: 8),
        switch (replay) {
          AsyncData(value: final summary?) => _ReplaySummaryView(
            summary: summary,
          ),
          AsyncError(:final error) => Text(
            'Replay failed: $error',
            key: const Key('replayError'),
          ),
          _ => const SizedBox.shrink(),
        },
      ],
    );
  }
}

class _ReplaySummaryView extends StatelessWidget {
  const _ReplaySummaryView({required this.summary});

  final ReplaySummary summary;

  @override
  Widget build(BuildContext context) {
    final agreement = summary.agreement;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      key: const Key('replaySummary'),
      children: [
        Text('Replayed ${summary.results.length} run(s).'),
        Text(
          agreement == null
              ? 'No corrected runs to measure agreement against.'
              : 'Agreement with corrected orders: '
                    '${(agreement * 100).round()}%',
        ),
        if (summary.nonDeterministicCount > 0)
          Text(
            '${summary.nonDeterministicCount} run(s) did not reproduce '
            'their original order under a matching prompt version -- the '
            'engine is not behaving deterministically.',
            key: const Key('nonDeterministicWarning'),
          ),
      ],
    );
  }
}
