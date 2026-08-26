import 'package:righthere_rightnow/briefing/clock.dart';
import 'package:righthere_rightnow/briefing/task_due_math.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/priority.dart';

/// A short, human-readable reason an item ranked where it did -- what makes
/// the fallback ranker debuggable, and what a prompt change will later be
/// judged against.
String rankingExplanation(AgendaItem item, Clock clock) {
  final now = clock();
  return switch (item) {
    Commitment() => _commitmentExplanation(item, now),
    Task() => _taskExplanation(item, now),
  };
}

String _commitmentExplanation(Commitment commitment, DateTime now) {
  if (commitment.isOrganiser) {
    return "You're the organiser";
  }
  if (commitment.attendeeCount <= 2) {
    return 'Small meeting';
  }
  final minutesUntilStart = commitment.start.difference(now).inMinutes;
  if (minutesUntilStart >= 0 && minutesUntilStart <= 60) {
    return 'Starting soon';
  }
  return 'On your calendar';
}

String _taskExplanation(Task task, DateTime now) {
  final overdue = overdueDays(task.due, now);
  if (overdue != null) {
    return overdue == 1 ? 'Overdue by 1 day' : 'Overdue by $overdue days';
  }
  if (task.priority == Priority.p1) {
    return 'Top priority';
  }
  final dueIn = daysUntilDue(task.due, now);
  if (dueIn == 0) {
    return 'Due today';
  }
  if (dueIn != null) {
    return dueIn == 1 ? 'Due in 1 day' : 'Due in $dueIn days';
  }
  return 'On your list';
}
