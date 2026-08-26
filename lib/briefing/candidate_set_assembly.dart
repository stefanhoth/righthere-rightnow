import 'package:righthere_rightnow/briefing/clock.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/agenda_item_features.dart';
import 'package:righthere_rightnow/domain/candidate_set.dart';
import 'package:righthere_rightnow/domain/response_status.dart';

/// Scores an item for the purpose of the Candidate Set's 25-item cap --
/// higher is more important. Injected rather than imported so this module
/// doesn't depend on the fallback ranker's concrete rules; the Briefing Run
/// orchestrator wires the real one in.
typedef ImportanceScorer = int Function(AgendaItem item, Clock clock);

/// The window of Commitments a Briefing Run should fetch: from the start of
/// the previous working day through the end of tomorrow.
///
/// [CandidateSetAssembler.assemble] then picks "today and before" plus
/// tomorrow's single earliest Commitment out of what's fetched -- fetching
/// the whole span up front means one calendar query covers both windows.
class CommitmentFetchWindow {
  const CommitmentFetchWindow({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

CommitmentFetchWindow commitmentFetchWindow(Clock clock) {
  final now = clock();
  final today = DateTime(now.year, now.month, now.day);

  var previousWorkingDay = today.subtract(const Duration(days: 1));
  while (previousWorkingDay.weekday == DateTime.saturday ||
      previousWorkingDay.weekday == DateTime.sunday) {
    previousWorkingDay = previousWorkingDay.subtract(const Duration(days: 1));
  }

  return CommitmentFetchWindow(
    start: previousWorkingDay,
    end: today.add(const Duration(days: 2)),
  );
}

/// Assembles a Candidate Set from already-fetched Commitments and Tasks.
///
/// Pure: given the same clock and the same fetched lists, it always
/// produces the same Candidate Set. Fetching itself -- and deciding the
/// window to fetch -- is the Briefing Run orchestrator's job.
class CandidateSetAssembler {
  const CandidateSetAssembler({required this.clock, required this.rank});

  static const maxCandidates = 25;

  final Clock clock;
  final ImportanceScorer rank;

  CandidateSet assemble({
    required List<Commitment> fetchedCommitments,
    required List<Task> fetchedTasks,
  }) {
    final now = clock();
    final endOfToday = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));

    final notDeclined = fetchedCommitments.where(
      (commitment) => commitment.myResponse != ResponseStatus.declined,
    );

    final todayAndBefore = notDeclined
        .where((commitment) => commitment.start.isBefore(endOfToday))
        .toList();
    final tomorrow =
        notDeclined
            .where((commitment) => !commitment.start.isBefore(endOfToday))
            .toList()
          ..sort((a, b) => a.start.compareTo(b.start));
    final firstTomorrow = tomorrow
        .where((commitment) => !commitment.isAllDay)
        .firstOrNullValue;

    final commitmentCandidates = [...todayAndBefore, ?firstTomorrow];

    final allDayCommitments = commitmentCandidates
        .where((commitment) => commitment.isAllDay)
        .toList();
    final rankedCommitments = commitmentCandidates.where(
      (commitment) => !commitment.isAllDay,
    );

    final allItems = <AgendaItem>[...rankedCommitments, ...fetchedTasks];
    var candidateItems = allItems
        .map(
          (item) =>
              CandidateItem(item: item, features: _featuresFor(item, now)),
        )
        .toList();

    if (candidateItems.length > maxCandidates) {
      candidateItems.sort(
        (a, b) => rank(b.item, clock).compareTo(rank(a.item, clock)),
      );
      candidateItems = candidateItems.take(maxCandidates).toList();
    }

    return CandidateSet(
      items: candidateItems,
      allDayCommitments: allDayCommitments,
      generatedAt: now,
    );
  }

  AgendaItemFeatures _featuresFor(AgendaItem item, DateTime now) {
    return switch (item) {
      Commitment() => AgendaItemFeatures(
        minutesUntilStart: item.start.difference(now).inMinutes,
        durationMinutes: item.end.difference(item.start).inMinutes,
        attendeeCount: item.attendeeCount,
        isOrganiser: item.isOrganiser,
        isRecurring: item.isRecurring,
        isFollowUpCandidate: !item.isAllDay && item.end.isBefore(now),
      ),
      Task() => AgendaItemFeatures(
        attendeeCount: 0,
        isOrganiser: false,
        isRecurring: item.isRecurring,
        isFollowUpCandidate: false,
        priority: item.priority,
        overdueDays: _overdueDays(item, now),
        daysUntilDue: _daysUntilDue(item, now),
      ),
    };
  }

  int? _overdueDays(Task task, DateTime now) {
    final due = task.due;
    if (due == null) {
      return null;
    }
    final daysPastDue = _dateOnly(now).difference(_dateOnly(due.date)).inDays;
    return daysPastDue > 0 ? daysPastDue : null;
  }

  int? _daysUntilDue(Task task, DateTime now) {
    final due = task.due;
    if (due == null) {
      return null;
    }
    final daysPastDue = _dateOnly(now).difference(_dateOnly(due.date)).inDays;
    return daysPastDue > 0 ? null : -daysPastDue;
  }

  DateTime _dateOnly(DateTime dateTime) =>
      DateTime(dateTime.year, dateTime.month, dateTime.day);
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNullValue => isEmpty ? null : first;
}
