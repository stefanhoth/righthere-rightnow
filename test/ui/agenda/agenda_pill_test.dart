import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/priority.dart';
import 'package:righthere_rightnow/domain/response_status.dart';
import 'package:righthere_rightnow/domain/task_due.dart';
import 'package:righthere_rightnow/ui/agenda/agenda_pill.dart';

final _now = DateTime(2026, 8, 27, 9);

Commitment _commitment({required DateTime start}) => Commitment(
  id: 'cal:1',
  title: 'Sync',
  start: start,
  end: start.add(const Duration(minutes: 30)),
  isAllDay: false,
  attendeeCount: 3,
  isOrganiser: false,
  myResponse: ResponseStatus.accepted,
  isRecurring: false,
  calendarName: 'Work',
);

Task _task({TaskDue? due, Priority priority = Priority.p3}) => Task(
  id: 'td:1',
  title: 'x',
  priority: priority,
  isRecurring: false,
  due: due,
);

TaskDue _dueOn(DateTime date) =>
    TaskDue(date: date, hasTime: false, isRecurring: false);

void main() {
  test('a Commitment still to come reads as an info-toned start time', () {
    final pill = agendaPillFor(
      _commitment(start: _now.add(const Duration(hours: 3))),
      _now,
    );

    expect(pill?.tone, PillTone.info);
    expect(pill?.label, contains('Today'));
  });

  test('a Commitment that already started is toned down to neutral', () {
    final pill = agendaPillFor(
      _commitment(start: _now.subtract(const Duration(days: 1))),
      _now,
    );

    expect(pill?.tone, PillTone.neutral);
    expect(pill?.label, contains('Yesterday'));
  });

  test('a Task overdue by a week or more is urgent', () {
    final pill = agendaPillFor(
      _task(due: _dueOn(_now.subtract(const Duration(days: 19)))),
      _now,
    );

    expect(pill, isNotNull);
    expect(pill!.label, '19d overdue');
    expect(pill.tone, PillTone.urgent);
  });

  test('a Task overdue by less than a week is only a warning', () {
    final pill = agendaPillFor(
      _task(due: _dueOn(_now.subtract(const Duration(days: 3)))),
      _now,
    );

    expect(pill!.label, '3d overdue');
    expect(pill.tone, PillTone.warning);
  });

  test('a Task due today is a warning', () {
    final pill = agendaPillFor(_task(due: _dueOn(_now)), _now);

    expect(pill!.label, 'Due today');
    expect(pill.tone, PillTone.warning);
  });

  test('a top-priority Task with no due date still gets a pill', () {
    final pill = agendaPillFor(_task(priority: Priority.p1), _now);

    expect(pill!.label, 'Top priority');
    expect(pill.tone, PillTone.warning);
  });

  test('a Task due later carries a neutral countdown', () {
    final pill = agendaPillFor(
      _task(due: _dueOn(_now.add(const Duration(days: 2)))),
      _now,
    );

    expect(pill!.label, 'Due in 2d');
    expect(pill.tone, PillTone.neutral);
  });

  test('a dateless, normal-priority Task has no pill', () {
    expect(agendaPillFor(_task(), _now), isNull);
  });
}
