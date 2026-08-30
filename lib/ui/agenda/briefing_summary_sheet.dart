import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:righthere_rightnow/briefing/briefing_run_orchestrator.dart';
import 'package:righthere_rightnow/ui/agenda/agenda_controller.dart';
import 'package:righthere_rightnow/ui/agenda/inference_status_controller.dart';

/// Everything about the Briefing Run itself -- its framing line, what the
/// model did, when it finished, and whether the ranking was any good.
///
/// It used to sit above the first Agenda Item, which put four rows of
/// commentary between opening the app and reading the one thing that matters
/// most. It is talk *about* the Daily Agenda, not part of it, so it now
/// collapses to a single tappable bar and expands on demand.

/// The collapsed bar: one line of the day's framing, or failing that
/// whatever the model is currently doing.
class BriefingSummaryBar extends ConsumerWidget {
  const BriefingSummaryBar({required this.result, super.key});

  final BriefingRunResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(inferenceStatusControllerProvider);
    final theme = Theme.of(context);
    final line =
        result.framingLine ??
        status.summary ??
        'Last updated ${DateFormat.jm().format(result.completedAt)}';

    return Material(
      key: const Key('briefingSummaryBar'),
      color: theme.colorScheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: () => showBriefingSummarySheet(context, result),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
            child: Row(
              children: [
                if (status.isRunning) ...[
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      key: const Key('briefingSummaryBarSpinner'),
                      strokeWidth: 2,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    line,
                    key: const Key('briefingSummaryBarText'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_up,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens the expanded sheet. Separate from [BriefingSummaryBar] so anything
/// else that wants the detail can ask for it.
Future<void> showBriefingSummarySheet(
  BuildContext context,
  BriefingRunResult result,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => _BriefingSummarySheet(result: result),
  );
}

class _BriefingSummarySheet extends StatelessWidget {
  const _BriefingSummarySheet({required this.result});

  final BriefingRunResult result;

  @override
  Widget build(BuildContext context) {
    final framingLine = result.framingLine;

    return SafeArea(
      key: const Key('briefingSummarySheet'),
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (framingLine != null) _FramingLine(text: framingLine),
            const _InferenceStatusLine(),
            const SizedBox(height: 16),
            _LastRunLine(completedAt: result.completedAt),
            const Divider(height: 32),
            const _RatingRow(),
          ],
        ),
      ),
    );
  }
}

class _FramingLine extends StatelessWidget {
  const _FramingLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const Key('framingLine'),
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        key: const Key('framingLineText'),
        // Three lines, not one. Task 3.4 called for a hard cap and truncation
        // over wrapping, and on the device that showed about a third of the
        // sentence -- useless. The cap now lives where it belongs, on
        // generation (framingLineMaxOutputTokens), so the screen can afford
        // to show what it asked for.
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

/// Says what the model is doing, or what it did.
///
/// Inference runs behind an agenda that is already on screen (ADR-0006), so
/// without this the screen looks identical whether the model is thinking,
/// finished, or was never reachable at all.
class _InferenceStatusLine extends ConsumerWidget {
  const _InferenceStatusLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(inferenceStatusControllerProvider);
    final summary = status.summary;
    if (summary == null) {
      return const SizedBox.shrink();
    }

    final style = Theme.of(context).textTheme.bodySmall;
    return Padding(
      key: const Key('inferenceStatus'),
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          if (status.isRunning) ...[
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                key: const Key('inferenceSpinner'),
                strokeWidth: 2,
                color: style?.color,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              summary,
              key: const Key('inferenceStatusText'),
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}

class _LastRunLine extends StatelessWidget {
  const _LastRunLine({required this.completedAt});

  final DateTime completedAt;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Last updated ${DateFormat.jm().format(completedAt)}',
      key: const Key('lastRunTime'),
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

class _RatingRow extends ConsumerWidget {
  const _RatingRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Was this order right?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        IconButton(
          key: const Key('thumbsUpButton'),
          icon: const Icon(Icons.thumb_up_outlined),
          tooltip: 'Good ranking',
          onPressed: () => _rate(context, ref, 1),
        ),
        IconButton(
          key: const Key('thumbsDownButton'),
          icon: const Icon(Icons.thumb_down_outlined),
          tooltip: "Not worth reordering, but wasn't great",
          onPressed: () => _rate(context, ref, -1),
        ),
      ],
    );
  }

  /// Closes the sheet on the way out: rating is the last thing anyone does
  /// in here, and leaving it open hides the agenda it was a verdict on.
  Future<void> _rate(BuildContext context, WidgetRef ref, int rating) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(dailyAgendaControllerProvider.notifier).rate(rating);
    if (navigator.canPop()) {
      navigator.pop();
    }
    messenger.showSnackBar(const SnackBar(content: Text('Noted.')));
  }
}
