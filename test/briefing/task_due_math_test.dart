import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/briefing/task_due_math.dart';
import 'package:righthere_rightnow/domain/task_due.dart';

void main() {
  final now = DateTime(2026, 8, 26, 9);

  test('no due date means neither overdue nor upcoming', () {
    expect(overdueDays(null, now), isNull);
    expect(daysUntilDue(null, now), isNull);
  });

  test('a due date three days ago is overdue by three days', () {
    final due = TaskDue(
      date: DateTime(2026, 8, 23),
      hasTime: false,
      isRecurring: false,
    );

    expect(overdueDays(due, now), 3);
    expect(daysUntilDue(due, now), isNull);
  });

  test('due today is neither overdue nor "until due"', () {
    final due = TaskDue(
      date: DateTime(2026, 8, 26),
      hasTime: false,
      isRecurring: false,
    );

    expect(overdueDays(due, now), isNull);
    expect(daysUntilDue(due, now), 0);
  });

  test('a due date in three days is three days until due', () {
    final due = TaskDue(
      date: DateTime(2026, 8, 29),
      hasTime: false,
      isRecurring: false,
    );

    expect(overdueDays(due, now), isNull);
    expect(daysUntilDue(due, now), 3);
  });
}
