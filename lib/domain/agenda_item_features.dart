import 'package:meta/meta.dart';
import 'package:righthere_rightnow/domain/priority.dart';

/// Clock-derived features computed for one Agenda Item at Candidate Set
/// assembly time. Persisted alongside the item so a Briefing Run can be
/// replayed later without recomputing them against a different "now".
///
/// Fields that don't apply to an item's kind (e.g. [priority] for a
/// Commitment) are null rather than a placeholder value.
@immutable
class AgendaItemFeatures {
  const AgendaItemFeatures({
    required this.attendeeCount,
    required this.isOrganiser,
    required this.isRecurring,
    required this.isFollowUpCandidate,
    this.minutesUntilStart,
    this.durationMinutes,
    this.overdueDays,
    this.daysUntilDue,
    this.priority,
  });

  /// Commitments only.
  final int? minutesUntilStart;

  /// Commitments only.
  final int? durationMinutes;

  final int attendeeCount;
  final bool isOrganiser;
  final bool isRecurring;

  /// Tasks only. Set only when the Task is actually overdue.
  final int? overdueDays;

  /// Tasks only. Set only when the Task is not overdue (0 means due today).
  final int? daysUntilDue;

  /// Tasks only.
  final Priority? priority;

  /// A past Commitment that may have generated follow-up work. Milestone 3
  /// turns this into a Follow-up Suggestion; Milestone 1 only records it.
  final bool isFollowUpCandidate;
}
