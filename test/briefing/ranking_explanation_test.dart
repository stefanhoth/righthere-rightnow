import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/briefing/ranking_explanation.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/domain/priority.dart';
import 'package:righthere_rightnow/domain/response_status.dart';
import 'package:righthere_rightnow/domain/task_due.dart';

DateTime clock() => DateTime(2026, 8, 26, 9);

void main() {
  test('explains an organiser Commitment', () {
    final commitment = Commitment(
      id: 'cal:1',
      title: 'Planning',
      start: clock().add(const Duration(hours: 1)),
      end: clock().add(const Duration(hours: 2)),
      isAllDay: false,
      attendeeCount: 10,
      isOrganiser: true,
      myResponse: ResponseStatus.accepted,
      isRecurring: false,
      calendarName: 'Work',
    );

    expect(rankingExplanation(commitment, clock), "You're the organiser");
  });

  test('explains an overdue Task', () {
    const task = Task(
      id: 'td:1',
      title: 'x',
      priority: Priority.p3,
      isRecurring: false,
    );
    final overdueTask = Task(
      id: task.id,
      title: task.title,
      priority: task.priority,
      isRecurring: task.isRecurring,
      due: TaskDue(
        date: clock().subtract(const Duration(days: 2)),
        hasTime: false,
        isRecurring: false,
      ),
    );

    expect(rankingExplanation(overdueTask, clock), 'Overdue by 2 days');
  });

  test('explains a top-priority Task', () {
    const task = Task(
      id: 'td:2',
      title: 'x',
      priority: Priority.p1,
      isRecurring: false,
    );

    expect(rankingExplanation(task, clock), 'Top priority');
  });

  test('explains a Task due today', () {
    final task = Task(
      id: 'td:3',
      title: 'x',
      priority: Priority.p3,
      isRecurring: false,
      due: TaskDue(date: clock(), hasTime: false, isRecurring: false),
    );

    expect(rankingExplanation(task, clock), 'Due today');
  });
}
