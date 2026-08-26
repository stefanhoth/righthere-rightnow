import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/scheduling/next_run_time.dart';

void main() {
  test('before the run time today, the next run is later today', () {
    final now = DateTime(2026, 8, 26, 4);

    final next = nextRunTime(now, hour: 5, minute: 30);

    expect(next, DateTime(2026, 8, 26, 5, 30));
  });

  test('after the run time today, the next run is tomorrow', () {
    final now = DateTime(2026, 8, 26, 6);

    final next = nextRunTime(now, hour: 5, minute: 30);

    expect(next, DateTime(2026, 8, 27, 5, 30));
  });

  test('exactly at the run time, the next run is tomorrow', () {
    final now = DateTime(2026, 8, 26, 5, 30);

    final next = nextRunTime(now, hour: 5, minute: 30);

    expect(next, DateTime(2026, 8, 27, 5, 30));
  });

  test('rolling over a month boundary', () {
    final now = DateTime(2026, 8, 31, 6);

    final next = nextRunTime(now, hour: 5, minute: 30);

    expect(next, DateTime(2026, 9, 1, 5, 30));
  });
}
