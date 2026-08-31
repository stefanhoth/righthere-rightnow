import 'package:flutter/material.dart';
import 'package:righthere_rightnow/domain/ranked_agenda.dart';

/// The one-glance label naming which ranker produced the order on screen.
String rankerLabel(RankedBy rankedBy) => switch (rankedBy) {
  RankedBy.fallback => 'Ranked by rules',
  RankedBy.model => 'Ranked by the model',
};

/// A quiet, always-present line on the Daily Agenda naming the ranker behind
/// the current order (Task 4.3).
///
/// It shows in every state, including before the model has responded -- until
/// then the order is the deterministic one, and the label says so. It is
/// deliberately understated: the banner is for breakage, this is for the
/// glance.
class RankerIndicator extends StatelessWidget {
  const RankerIndicator({required this.rankedBy, super.key});

  final RankedBy rankedBy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      key: const Key('rankerIndicator'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          Icon(
            rankedBy == RankedBy.model ? Icons.auto_awesome : Icons.rule,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            rankerLabel(rankedBy),
            key: const Key('rankerIndicatorText'),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
