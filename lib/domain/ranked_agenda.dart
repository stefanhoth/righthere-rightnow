import 'package:meta/meta.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';

/// Which ranker produced a [RankedAgenda].
enum RankedBy { fallback, model }

/// The ordered Daily Agenda produced by one Briefing Run.
@immutable
class RankedAgenda {
  const RankedAgenda({
    required this.items,
    required this.rankedBy,
    this.promptVersion,
  });

  final List<AgendaItem> items;
  final RankedBy rankedBy;

  /// Set only when [rankedBy] is [RankedBy.model].
  final String? promptVersion;
}
