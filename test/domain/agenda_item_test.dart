import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/agenda_source.dart';
import 'package:righthere_rightnow/domain/priority.dart';
import 'package:righthere_rightnow/domain/response_status.dart';
import 'package:righthere_rightnow/domain/task_due.dart';

void main() {
  group('Commitment', () {
    Commitment build({required DateTime start, required DateTime end}) {
      return Commitment(
        id: 'cal:1:${start.millisecondsSinceEpoch}',
        title: 'Standup',
        start: start,
        end: end,
        isAllDay: false,
        attendeeCount: 3,
        isOrganiser: false,
        myResponse: ResponseStatus.accepted,
        isRecurring: false,
        calendarName: 'Work',
      );
    }

    test('source is always calendar', () {
      final commitment = build(
        start: DateTime(2026, 8, 26, 9),
        end: DateTime(2026, 8, 26, 9, 30),
      );

      expect(commitment.source, AgendaSource.calendar);
    });

    test('end may equal start (zero-duration Commitment)', () {
      final at = DateTime(2026, 8, 26, 9);

      expect(() => build(start: at, end: at), returnsNormally);
    });

    test('end before start violates the invariant', () {
      expect(
        () => build(
          start: DateTime(2026, 8, 26, 9),
          end: DateTime(2026, 8, 26, 8, 59),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('Task', () {
    test('source is always todoist', () {
      const task = Task(
        id: 'td:1',
        title: 'Write the report',
        priority: Priority.p2,
        isRecurring: false,
      );

      expect(task.source, AgendaSource.todoist);
    });

    test('carries an optional due constraint, not a schedule', () {
      final task = Task(
        id: 'td:2',
        title: 'File taxes',
        due: TaskDue(
          date: DateTime.utc(2026, 8, 30),
          hasTime: false,
          isRecurring: false,
        ),
        priority: Priority.p1,
        isRecurring: false,
      );

      expect(task.due?.hasTime, isFalse);
    });

    test('a task with no due date is a valid, undated Task', () {
      const task = Task(
        id: 'td:3',
        title: 'Someday maybe',
        priority: Priority.p4,
        isRecurring: false,
      );

      expect(task.due, isNull);
    });
  });
}
