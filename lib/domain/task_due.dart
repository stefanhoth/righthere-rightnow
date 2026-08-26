import 'package:meta/meta.dart';

/// A Task's due constraint, as distinct from a Commitment's fixed schedule.
@immutable
class TaskDue {
  const TaskDue({
    required this.date,
    required this.hasTime,
    required this.isRecurring,
    this.timeZone,
  });

  /// The due date, or due date-and-time when [hasTime] is true.
  final DateTime date;

  /// False for a date-only due constraint (no time of day attached).
  final bool hasTime;

  /// The IANA zone the due time is fixed to, if any. Null when [hasTime] is
  /// false, or when the source gave a floating local time with no zone.
  final String? timeZone;

  final bool isRecurring;
}
