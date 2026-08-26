import 'package:meta/meta.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/agenda_item_features.dart';

/// One Agenda Item as a Briefing Run's Candidate Set considered it, paired
/// with the features computed for it.
@immutable
class CandidateItem {
  const CandidateItem({required this.item, required this.features});

  final AgendaItem item;
  final AgendaItemFeatures features;
}

/// The bounded collection of Agenda Items one Briefing Run considers, after
/// filtering and before ranking. What comes out of a Briefing Run is always
/// a reordering of what went into its Candidate Set.
@immutable
class CandidateSet {
  const CandidateSet({
    required this.items,
    required this.allDayCommitments,
    required this.generatedAt,
  });

  /// Ranked candidates -- never includes an all-day Commitment. Capped at 25
  /// items.
  final List<CandidateItem> items;

  /// All-day Commitments are day context, not ranked items: shown as a
  /// header rather than mixed into the ranked list.
  final List<Commitment> allDayCommitments;

  /// When this Candidate Set was assembled.
  final DateTime generatedAt;
}
