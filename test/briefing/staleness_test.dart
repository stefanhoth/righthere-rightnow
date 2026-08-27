import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/briefing/staleness.dart';

void main() {
  DateTime clock() => DateTime(2026, 8, 27, 9);

  test('a run with no history at all is not stale', () {
    expect(isStale(lastRunCompletedAt: null, clock: clock), isFalse);
  });

  test('a run just under 26 hours old is not stale', () {
    final lastRun = clock().subtract(const Duration(hours: 25, minutes: 59));

    expect(isStale(lastRunCompletedAt: lastRun, clock: clock), isFalse);
  });

  test('a run just over 26 hours old is stale', () {
    final lastRun = clock().subtract(const Duration(hours: 26, minutes: 1));

    expect(isStale(lastRunCompletedAt: lastRun, clock: clock), isTrue);
  });
}
