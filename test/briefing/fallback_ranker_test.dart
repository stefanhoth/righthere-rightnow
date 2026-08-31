import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/briefing/fallback_ranker.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/priority.dart';
import 'package:righthere_rightnow/domain/response_status.dart';
import 'package:righthere_rightnow/domain/task_due.dart';

DateTime clock() => DateTime(2026, 8, 26, 9);

Commitment _commitment({
  required String id,
  required DateTime start,
  int attendeeCount = 2,
  bool isOrganiser = false,
  bool isRecurring = false,
}) {
  return Commitment(
    id: id,
    title: id,
    start: start,
    end: start.add(const Duration(minutes: 30)),
    isAllDay: false,
    attendeeCount: attendeeCount,
    isOrganiser: isOrganiser,
    myResponse: ResponseStatus.accepted,
    isRecurring: isRecurring,
    calendarName: 'Work',
  );
}

Task _task({
  required String id,
  Priority priority = Priority.p3,
  TaskDue? due,
  String? title,
}) {
  return Task(
    id: id,
    title: title ?? id,
    priority: priority,
    isRecurring: false,
    due: due,
  );
}

TaskDue _overdueBy(int days) => TaskDue(
  date: clock().subtract(Duration(days: days)),
  hasTime: false,
  isRecurring: false,
);

void main() {
  test('the same input and clock always yield the same order', () {
    final items = [
      _commitment(id: 'cal:a', start: clock().add(const Duration(hours: 1))),
      _task(id: 'td:b', priority: Priority.p1),
      _commitment(id: 'cal:c', start: clock().add(const Duration(minutes: 10))),
    ];

    final first = rankFallback(items, clock).map((i) => i.id).toList();
    final second = rankFallback(items, clock).map((i) => i.id).toList();

    expect(first, second);
  });

  test('you as organiser is a strong boost', () {
    final notOrganiser = _commitment(
      id: 'cal:attendee',
      start: clock().add(const Duration(hours: 1)),
    );
    final organiser = _commitment(
      id: 'cal:organiser',
      start: clock().add(const Duration(hours: 1)),
      isOrganiser: true,
    );

    final ranked = rankFallback([notOrganiser, organiser], clock);

    expect(ranked.first.id, 'cal:organiser');
  });

  test('a small Commitment outranks a large recurring one', () {
    final oneOnOne = _commitment(
      id: 'cal:1-1',
      start: clock().add(const Duration(hours: 1)),
    );
    final allHands = _commitment(
      id: 'cal:all-hands',
      start: clock().add(const Duration(hours: 1)),
      attendeeCount: 87,
      isRecurring: true,
    );

    final ranked = rankFallback([allHands, oneOnOne], clock);

    expect(ranked.first.id, 'cal:1-1');
  });

  test('imminent Commitments rise as they approach', () {
    final soon = _commitment(
      id: 'cal:soon',
      start: clock().add(const Duration(minutes: 15)),
    );
    final later = _commitment(
      id: 'cal:later',
      start: clock().add(const Duration(hours: 3)),
    );

    final ranked = rankFallback([later, soon], clock);

    expect(ranked.first.id, 'cal:soon');
  });

  test('overdue is urgent for about a week, then decays', () {
    final freshlyOverdue = _task(
      id: 'td:fresh',
      due: TaskDue(
        date: clock().subtract(const Duration(days: 2)),
        hasTime: false,
        isRecurring: false,
      ),
    );
    final staleOverdue = _task(
      id: 'td:stale',
      due: TaskDue(
        date: clock().subtract(const Duration(days: 40)),
        hasTime: false,
        isRecurring: false,
      ),
    );

    final ranked = rankFallback([staleOverdue, freshlyOverdue], clock);

    expect(ranked.first.id, 'td:fresh');
  });

  test('a 40-day overdue Task is dead, not screaming', () {
    final deadOverdue = _task(
      id: 'td:dead',
      due: TaskDue(
        date: clock().subtract(const Duration(days: 40)),
        hasTime: false,
        isRecurring: false,
      ),
    );
    final dueSoon = _task(
      id: 'td:soon',
      due: TaskDue(
        date: clock().add(const Duration(days: 2)),
        hasTime: false,
        isRecurring: false,
      ),
    );

    final ranked = rankFallback([deadOverdue, dueSoon], clock);

    expect(ranked.first.id, 'td:soon');
  });

  test('explicit priority beats proximity inside a ~3-day window', () {
    final p1DueInThreeDays = _task(
      id: 'td:p1-later',
      priority: Priority.p1,
      due: TaskDue(
        date: clock().add(const Duration(days: 3)),
        hasTime: false,
        isRecurring: false,
      ),
    );
    final p4DueToday = _task(
      id: 'td:p4-today',
      priority: Priority.p4,
      due: TaskDue(date: clock(), hasTime: false, isRecurring: false),
    );

    final ranked = rankFallback([p4DueToday, p1DueInThreeDays], clock);

    expect(ranked.first.id, 'td:p1-later');
  });

  test('ties are broken deterministically by id', () {
    final a = _task(id: 'td:a');
    final b = _task(id: 'td:b');

    final ranked = rankFallback([b, a], clock);

    expect(ranked.map((i) => i.id), ['td:a', 'td:b']);
  });

  group('never-decays escalation (ADR-0007)', () {
    test('a 40-day-overdue Task on the list outranks a Task due today', () {
      final escalating = _task(
        id: 'td:passport',
        title: 'Renew the passport before the trip',
        due: _overdueBy(40),
      );
      final dueToday = _task(
        id: 'td:today',
        priority: Priority.p1,
        due: TaskDue(date: clock(), hasTime: false, isRecurring: false),
      );

      final ranked = rankFallback(
        [dueToday, escalating],
        clock,
        neverDecays: {'renew passport'},
      );

      expect(ranked.first.id, 'td:passport');
    });

    test('the same Task not on the list stays buried', () {
      final stale = _task(
        id: 'td:passport',
        title: 'Renew the passport before the trip',
        due: _overdueBy(40),
      );
      final dueToday = _task(
        id: 'td:today',
        priority: Priority.p1,
        due: TaskDue(date: clock(), hasTime: false, isRecurring: false),
      );

      final ranked = rankFallback([dueToday, stale], clock);

      expect(ranked.first.id, 'td:today');
      expect(
        fallbackScore(stale, clock),
        lessThan(0),
        reason: 'decayed, deeply negative',
      );
    });

    test('a non-matching list scores identically to no list', () {
      final task = _task(
        id: 'td:x',
        title: 'renew passport',
        due: _overdueBy(30),
      );

      expect(
        fallbackScore(task, clock, neverDecays: {'something else entirely'}),
        fallbackScore(task, clock),
      );
    });

    test('matching is a case-insensitive substring of the title', () {
      final task = _task(
        id: 'td:x',
        title: 'Call the ACCOUNTANT about Q3',
        due: _overdueBy(20),
      );

      expect(titleIsNeverDecay(task.title, {'call the accountant'}), isTrue);
      expect(titleIsNeverDecay(task.title, {'  '}), isFalse);
      expect(titleIsNeverDecay(task.title, {'dentist'}), isFalse);
    });

    test('the first overdue week is identical on or off the list', () {
      final task = _task(
        id: 'td:x',
        title: 'renew passport',
        due: _overdueBy(5),
      );

      expect(
        fallbackScore(task, clock, neverDecays: {'renew passport'}),
        fallbackScore(task, clock),
      );
    });

    test('an escalating Task keeps climbing with age', () {
      final at20 = _task(
        id: 'td:x',
        title: 'renew passport',
        due: _overdueBy(20),
      );
      final at40 = _task(
        id: 'td:x',
        title: 'renew passport',
        due: _overdueBy(40),
      );

      expect(
        fallbackScore(at40, clock, neverDecays: {'renew passport'}),
        greaterThan(
          fallbackScore(at20, clock, neverDecays: {'renew passport'}),
        ),
      );
    });
  });
}
