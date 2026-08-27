import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/ui/agenda/day_label.dart';

void main() {
  // A Monday, so the lookback window reaches back to the previous Friday.
  final now = DateTime(2026, 8, 24, 9);

  test('labels the current day "Today" regardless of time', () {
    expect(dayLabel(DateTime(2026, 8, 24, 23, 30), now), 'Today');
  });

  test('labels the next day "Tomorrow"', () {
    expect(dayLabel(DateTime(2026, 8, 25, 8), now), 'Tomorrow');
  });

  test('labels the previous day "Yesterday"', () {
    expect(dayLabel(DateTime(2026, 8, 23, 18), now), 'Yesterday');
  });

  test('labels an intervening weekend day by weekday name', () {
    expect(dayLabel(DateTime(2026, 8, 21, 15), now), 'Fri');
    expect(dayLabel(DateTime(2026, 8, 22, 10), now), 'Sat');
  });

  test('falls back to a short date beyond a week', () {
    expect(dayLabel(DateTime(2026, 9, 3, 10), now), 'Sep 3');
    expect(dayLabel(DateTime(2026, 8, 10, 10), now), 'Aug 10');
  });
}
