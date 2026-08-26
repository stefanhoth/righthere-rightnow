import 'package:righthere_rightnow/briefing/clock.dart';
import 'package:righthere_rightnow/briefing/task_due_math.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/priority.dart';

/// The deterministic ranker that always works -- the safety net for the
/// model (ADR-0003), and in this milestone the only ranker.
///
/// Pure: no I/O, no `DateTime.now()`. The same item and the same clock
/// always yield the same score.
int fallbackScore(AgendaItem item, Clock clock) {
  final now = clock();
  return switch (item) {
    Commitment() => _commitmentScore(item, now),
    Task() => _taskScore(item, now),
  };
}

/// Sorts [items] by [fallbackScore] descending, breaking ties on `id` so
/// the order is reproducible even between items that score identically.
List<AgendaItem> rankFallback(List<AgendaItem> items, Clock clock) {
  final ranked = [...items]
    ..sort((a, b) {
      final byScore = fallbackScore(
        b,
        clock,
      ).compareTo(fallbackScore(a, clock));
      if (byScore != 0) {
        return byScore;
      }
      return a.id.compareTo(b.id);
    });
  return ranked;
}

int _commitmentScore(Commitment commitment, DateTime now) {
  var score = 0;

  // Imminent Commitments rise as they approach; one already under way or
  // finished gets no proximity boost.
  final minutesUntilStart = commitment.start.difference(now).inMinutes;
  if (minutesUntilStart >= 0) {
    score += 3000 - minutesUntilStart;
  }

  // You as organiser is a strong boost -- you owe preparation.
  if (commitment.isOrganiser) {
    score += 5000;
  }

  // Small Commitments outrank large ones; recurring ones are further
  // discounted, so a small one-off beats a large recurring meeting of
  // similar size.
  score -= commitment.attendeeCount * 20;
  if (commitment.isRecurring) {
    score -= 300;
  }

  return score;
}

int _taskScore(Task task, DateTime now) {
  var score = _priorityBonus(task.priority);

  final overdue = overdueDays(task.due, now);
  if (overdue != null) {
    // Urgent for about a week, then decaying -- stale, not escalating. By
    // day 40 this is deeply negative: dead, not screaming.
    return score + (overdue <= 7 ? overdue * 200 : 1400 - (overdue - 7) * 60);
  }

  final dueIn = daysUntilDue(task.due, now);
  if (dueIn != null && dueIn <= 10) {
    // Proximity matters, but not as much as explicit priority: the p1/p4
    // gap below is bigger than the gap this can produce inside a ~3-day
    // window, so a p1 due in 3 days still outranks a p4 due today.
    score += (10 - dueIn) * 30;
  }

  return score;
}

int _priorityBonus(Priority priority) {
  return switch (priority) {
    Priority.p1 => 500,
    Priority.p2 => 300,
    Priority.p3 => 150,
    Priority.p4 => 0,
  };
}
