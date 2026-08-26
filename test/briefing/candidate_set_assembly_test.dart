import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/briefing/candidate_set_assembly.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/priority.dart';
import 'package:righthere_rightnow/domain/response_status.dart';
import 'package:righthere_rightnow/domain/task_due.dart';

Commitment _commitment({
  required String id,
  required DateTime start,
  required DateTime end,
  bool isAllDay = false,
  ResponseStatus myResponse = ResponseStatus.accepted,
}) {
  return Commitment(
    id: id,
    title: id,
    start: start,
    end: end,
    isAllDay: isAllDay,
    attendeeCount: 2,
    isOrganiser: false,
    myResponse: myResponse,
    isRecurring: false,
    calendarName: 'Work',
  );
}

void main() {
  group('commitmentFetchWindow', () {
    test('a Monday run looks back to Friday', () {
      DateTime clock() => DateTime(2026, 8, 31, 8);

      final window = commitmentFetchWindow(clock);

      expect(window.start, DateTime(2026, 8, 28));
      expect(window.end, DateTime(2026, 9, 2));
    });

    test('a midweek run looks back to the previous day', () {
      DateTime clock() => DateTime(2026, 8, 26, 8);

      final window = commitmentFetchWindow(clock);

      expect(window.start, DateTime(2026, 8, 25));
      expect(window.end, DateTime(2026, 8, 28));
    });
  });

  group('CandidateSetAssembler', () {
    test('a Monday run surfaces Friday, Saturday and Sunday Commitments', () {
      DateTime clock() => DateTime(2026, 8, 31, 9);
      final assembler = CandidateSetAssembler(
        clock: clock,
        rank: (item, clock) => 0,
      );
      final friday = _commitment(
        id: 'cal:friday',
        start: DateTime(2026, 8, 28, 10),
        end: DateTime(2026, 8, 28, 11),
      );
      final sunday = _commitment(
        id: 'cal:sunday',
        start: DateTime(2026, 8, 30, 10),
        end: DateTime(2026, 8, 30, 11),
      );
      final monday = _commitment(
        id: 'cal:monday',
        start: DateTime(2026, 8, 31, 8, 30),
        end: DateTime(2026, 8, 31, 9),
      );

      final candidateSet = assembler.assemble(
        fetchedCommitments: [friday, sunday, monday],
        fetchedTasks: const [],
      );

      expect(
        candidateSet.items.map((c) => c.item.id),
        containsAll(['cal:friday', 'cal:sunday', 'cal:monday']),
      );
    });

    test('drops declined Commitments', () {
      DateTime clock() => DateTime(2026, 8, 26, 9);
      final assembler = CandidateSetAssembler(
        clock: clock,
        rank: (item, clock) => 0,
      );
      final declined = _commitment(
        id: 'cal:declined',
        start: DateTime(2026, 8, 26, 10),
        end: DateTime(2026, 8, 26, 11),
        myResponse: ResponseStatus.declined,
      );

      final candidateSet = assembler.assemble(
        fetchedCommitments: [declined],
        fetchedTasks: const [],
      );

      expect(candidateSet.items, isEmpty);
    });

    test('separates all-day Commitments from the ranked items', () {
      DateTime clock() => DateTime(2026, 8, 26, 9);
      final assembler = CandidateSetAssembler(
        clock: clock,
        rank: (item, clock) => 0,
      );
      final offsite = _commitment(
        id: 'cal:offsite',
        start: DateTime(2026, 8, 26),
        end: DateTime(2026, 8, 27),
        isAllDay: true,
      );
      final standup = _commitment(
        id: 'cal:standup',
        start: DateTime(2026, 8, 26, 9),
        end: DateTime(2026, 8, 26, 9, 15),
      );

      final candidateSet = assembler.assemble(
        fetchedCommitments: [offsite, standup],
        fetchedTasks: const [],
      );

      expect(candidateSet.allDayCommitments.map((c) => c.id), ['cal:offsite']);
      expect(candidateSet.items.map((c) => c.item.id), ['cal:standup']);
    });

    test("includes only tomorrow's single earliest Commitment", () {
      DateTime clock() => DateTime(2026, 8, 26, 9);
      final assembler = CandidateSetAssembler(
        clock: clock,
        rank: (item, clock) => 0,
      );
      final earlyTomorrow = _commitment(
        id: 'cal:early-tomorrow',
        start: DateTime(2026, 8, 27, 8),
        end: DateTime(2026, 8, 27, 8, 30),
      );
      final laterTomorrow = _commitment(
        id: 'cal:later-tomorrow',
        start: DateTime(2026, 8, 27, 14),
        end: DateTime(2026, 8, 27, 15),
      );

      final candidateSet = assembler.assemble(
        fetchedCommitments: [laterTomorrow, earlyTomorrow],
        fetchedTasks: const [],
      );

      expect(candidateSet.items.map((c) => c.item.id), ['cal:early-tomorrow']);
    });

    test('caps ranked candidates at 25, trimming by the injected rank', () {
      DateTime clock() => DateTime(2026, 8, 26, 9);
      final tasks = List.generate(
        30,
        (i) => Task(
          id: 'td:$i',
          title: 'Task $i',
          priority: Priority.p4,
          isRecurring: false,
        ),
      );
      // Highest-index tasks rank best, so the cap should keep td:5..td:29.
      final assembler = CandidateSetAssembler(
        clock: clock,
        rank: (item, clock) => int.parse(item.id.split(':')[1]),
      );

      final candidateSet = assembler.assemble(
        fetchedCommitments: const [],
        fetchedTasks: tasks,
      );

      expect(candidateSet.items, hasLength(25));
      expect(candidateSet.items.map((c) => c.item.id), isNot(contains('td:0')));
      expect(candidateSet.items.map((c) => c.item.id), contains('td:29'));
    });

    test('a fully-passed Commitment is a follow-up candidate', () {
      DateTime clock() => DateTime(2026, 8, 26, 12);
      final assembler = CandidateSetAssembler(
        clock: clock,
        rank: (item, clock) => 0,
      );
      final pastMeeting = _commitment(
        id: 'cal:past',
        start: DateTime(2026, 8, 26, 9),
        end: DateTime(2026, 8, 26, 9, 30),
      );

      final candidateSet = assembler.assemble(
        fetchedCommitments: [pastMeeting],
        fetchedTasks: const [],
      );

      expect(candidateSet.items.single.features.isFollowUpCandidate, isTrue);
    });

    test('an ongoing Commitment is not a follow-up candidate', () {
      DateTime clock() => DateTime(2026, 8, 26, 12);
      final assembler = CandidateSetAssembler(
        clock: clock,
        rank: (item, clock) => 0,
      );
      final ongoing = _commitment(
        id: 'cal:ongoing',
        start: DateTime(2026, 8, 26, 11),
        end: DateTime(2026, 8, 26, 13),
      );

      final candidateSet = assembler.assemble(
        fetchedCommitments: [ongoing],
        fetchedTasks: const [],
      );

      expect(candidateSet.items.single.features.isFollowUpCandidate, isFalse);
    });

    test('an overdue Task reports overdueDays and no daysUntilDue', () {
      DateTime clock() => DateTime(2026, 8, 26, 9);
      final assembler = CandidateSetAssembler(
        clock: clock,
        rank: (item, clock) => 0,
      );
      final overdue = Task(
        id: 'td:overdue',
        title: 'Overdue',
        priority: Priority.p2,
        isRecurring: false,
        due: TaskDue(
          date: DateTime(2026, 8, 23),
          hasTime: false,
          isRecurring: false,
        ),
      );

      final candidateSet = assembler.assemble(
        fetchedCommitments: const [],
        fetchedTasks: [overdue],
      );

      final features = candidateSet.items.single.features;
      expect(features.overdueDays, 3);
      expect(features.daysUntilDue, isNull);
    });

    test('a Task due today reports daysUntilDue == 0', () {
      DateTime clock() => DateTime(2026, 8, 26, 9);
      final assembler = CandidateSetAssembler(
        clock: clock,
        rank: (item, clock) => 0,
      );
      final dueToday = Task(
        id: 'td:today',
        title: 'Due today',
        priority: Priority.p2,
        isRecurring: false,
        due: TaskDue(
          date: DateTime(2026, 8, 26),
          hasTime: false,
          isRecurring: false,
        ),
      );

      final candidateSet = assembler.assemble(
        fetchedCommitments: const [],
        fetchedTasks: [dueToday],
      );

      final features = candidateSet.items.single.features;
      expect(features.daysUntilDue, 0);
      expect(features.overdueDays, isNull);
    });
  });
}
