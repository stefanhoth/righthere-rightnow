import 'package:meta/meta.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';

/// The bounded collection of Agenda Items one Briefing Run considers, after
/// filtering and before ranking. What comes out of a Briefing Run is always
/// a reordering of what went into its Candidate Set.
@immutable
class CandidateSet {
  const CandidateSet({required this.items, required this.generatedAt});

  final List<AgendaItem> items;

  /// When this Candidate Set was assembled.
  final DateTime generatedAt;
}
