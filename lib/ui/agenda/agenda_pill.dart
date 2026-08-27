import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:righthere_rightnow/briefing/task_due_math.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/priority.dart';
import 'package:righthere_rightnow/ui/agenda/day_label.dart';

/// How loud an [AgendaPill] should read. The widget layer maps each tone to
/// colours; the classification stays here so it can be unit-tested without
/// pulling in Flutter.
enum PillTone {
  /// Overdue by a week or more -- the only tone that borrows the error colour.
  urgent,

  /// Overdue by less than a week, due today, or top priority.
  warning,

  /// Due later, with a concrete date.
  neutral,

  /// A Commitment's time. Not urgency at all -- just when it starts.
  info,
}

/// The single status chip shown on an Agenda Item row: for a Commitment, when
/// it starts; for a Task, how close its due date is.
@immutable
class AgendaPill {
  const AgendaPill({required this.label, required this.tone});

  final String label;
  final PillTone tone;
}

/// The pill for [item], or null when there is nothing worth a chip -- a Task
/// with no due date and no standout priority carries its reason text alone.
AgendaPill? agendaPillFor(AgendaItem item, DateTime now) {
  return switch (item) {
    Commitment() => AgendaPill(
      label:
          '${dayLabel(item.start, now)} ${DateFormat.jm().format(item.start)}',
      tone: item.start.isBefore(now) ? PillTone.neutral : PillTone.info,
    ),
    Task() => _taskPill(item, now),
  };
}

AgendaPill? _taskPill(Task task, DateTime now) {
  final overdue = overdueDays(task.due, now);
  if (overdue != null) {
    return AgendaPill(
      label: '${overdue}d overdue',
      tone: overdue >= 7 ? PillTone.urgent : PillTone.warning,
    );
  }
  final dueIn = daysUntilDue(task.due, now);
  if (dueIn == 0) {
    return const AgendaPill(label: 'Due today', tone: PillTone.warning);
  }
  if (task.priority == Priority.p1) {
    return const AgendaPill(label: 'Top priority', tone: PillTone.warning);
  }
  if (dueIn != null) {
    return AgendaPill(label: 'Due in ${dueIn}d', tone: PillTone.neutral);
  }
  return null;
}
