import 'package:righthere_rightnow/briefing/clock.dart';
import 'package:righthere_rightnow/briefing/task_due_math.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/priority.dart';

/// The deterministic ranker that always works -- the safety net for the
/// model (ADR-0003), and in this milestone the only ranker.
///
/// Pure: no I/O, no `DateTime.now()`. The same inputs always yield the same
/// score.
///
/// [neverDecays] is the What Matters never-decays list (ADR-0007): a Task
/// whose title matches one of these phrases *escalates* with age past the
/// first overdue week instead of decaying. An empty set -- the default, and
/// what an unreadable What Matters degrades to -- reproduces the pure decay
/// behaviour exactly.
///
/// A *recurring* Task is the mirror image: its "overdue" days are the
/// recurrence interval of an instance that regenerated this morning, not a
/// consequence accruing, so its overdue contribution is capped low unless
/// it is also on the never-decays list.
int fallbackScore(
  AgendaItem item,
  Clock clock, {
  Set<String> neverDecays = const {},
}) {
  final now = clock();
  return switch (item) {
    Commitment() => _commitmentScore(item, now),
    Task() => _taskScore(item, now, neverDecays),
  };
}

/// Sorts [items] by [fallbackScore] descending, breaking ties on `id` so
/// the order is reproducible even between items that score identically.
List<AgendaItem> rankFallback(
  List<AgendaItem> items,
  Clock clock, {
  Set<String> neverDecays = const {},
}) {
  final ranked = [...items]
    ..sort((a, b) {
      final byScore = fallbackScore(
        b,
        clock,
        neverDecays: neverDecays,
      ).compareTo(fallbackScore(a, clock, neverDecays: neverDecays));
      if (byScore != 0) {
        return byScore;
      }
      return a.id.compareTo(b.id);
    });
  return ranked;
}

/// Whether a Task with [title] is on the never-decays list.
///
/// A phrase matches when every word in it also appears in the title,
/// case-insensitively and order-independently -- so "renew passport" catches
/// "Renew the passport before the trip". Word-set rather than substring so a
/// short phrase is not defeated by a filler word. A phrase with no words
/// (blank or punctuation only) never matches.
bool titleIsNeverDecay(String title, Set<String> neverDecays) {
  final titleWords = _words(title);
  if (titleWords.isEmpty) {
    return false;
  }
  for (final phrase in neverDecays) {
    final phraseWords = _words(phrase);
    if (phraseWords.isNotEmpty && phraseWords.every(titleWords.contains)) {
      return true;
    }
  }
  return false;
}

final _wordSplit = RegExp('[^a-z0-9]+');

Set<String> _words(String text) => text
    .toLowerCase()
    .split(_wordSplit)
    .where((word) => word.isNotEmpty)
    .toSet();

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

int _taskScore(Task task, DateTime now, Set<String> neverDecays) {
  var score = _priorityBonus(task.priority);
  final neverDecay = titleIsNeverDecay(task.title, neverDecays);

  final overdue = overdueDays(task.due, now);
  if (overdue != null) {
    // A recurring Task shown as overdue has almost always just regenerated
    // this morning -- the "overdue" days are its recurrence interval, not a
    // consequence piling up (ADR-0007 escalates by consequence, not age).
    // Unless it is on the never-decays list, don't let that phantom overdue
    // climb lift a daily chore above real deadlines: cap the contribution
    // so a p1/p2 with a genuine due date still outranks it.
    if (task.isRecurring && !neverDecay) {
      return score + (overdue > 3 ? 3 : overdue) * 50;
    }
    // The first week is urgent either way. After that the curves diverge:
    // a never-decays Task keeps climbing (ADR-0007 -- consequence, not age),
    // every other Task decays and by day 40 is deeply negative: dead, not
    // screaming.
    if (overdue <= 7) {
      return score + overdue * 200;
    }
    return neverDecay
        ? score + 1400 + (overdue - 7) * 60
        : score + 1400 - (overdue - 7) * 60;
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
