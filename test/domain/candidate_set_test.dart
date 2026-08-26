import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/agenda_item_features.dart';
import 'package:righthere_rightnow/domain/candidate_set.dart';
import 'package:righthere_rightnow/domain/priority.dart';
import 'package:righthere_rightnow/domain/response_status.dart';

void main() {
  const task = Task(
    id: 'td:1',
    title: 'File taxes',
    priority: Priority.p1,
    isRecurring: false,
  );
  const features = AgendaItemFeatures(
    attendeeCount: 0,
    isOrganiser: false,
    isRecurring: false,
    isFollowUpCandidate: false,
    priority: Priority.p1,
  );

  test('holds the items a Briefing Run considered plus when it ran', () {
    const candidateItem = CandidateItem(item: task, features: features);
    final generatedAt = DateTime.utc(2026, 8, 26, 6);

    final candidateSet = CandidateSet(
      items: const [candidateItem],
      allDayCommitments: const [],
      generatedAt: generatedAt,
    );

    expect(candidateSet.items, [candidateItem]);
    expect(candidateSet.allDayCommitments, isEmpty);
    expect(candidateSet.generatedAt, generatedAt);
  });

  test('carries all-day Commitments separately from the ranked items', () {
    final offsite = Commitment(
      id: 'cal:1:0',
      title: 'Company offsite',
      start: DateTime.utc(2026, 8, 26),
      end: DateTime.utc(2026, 8, 27),
      isAllDay: true,
      attendeeCount: 0,
      isOrganiser: false,
      myResponse: ResponseStatus.accepted,
      isRecurring: false,
      calendarName: 'Work',
    );

    final candidateSet = CandidateSet(
      items: const [],
      allDayCommitments: [offsite],
      generatedAt: DateTime.utc(2026, 8, 26),
    );

    expect(candidateSet.allDayCommitments, [offsite]);
    expect(candidateSet.items, isEmpty);
  });

  test('can be empty', () {
    final candidateSet = CandidateSet(
      items: const [],
      allDayCommitments: const [],
      generatedAt: DateTime.utc(2026, 8, 26),
    );

    expect(candidateSet.items, isEmpty);
  });
}
