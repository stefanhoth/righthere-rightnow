import 'package:righthere_rightnow/briefing/clock.dart';

/// An OEM can suppress the alarm entirely, or App Standby's Restricted
/// bucket can cut it to one per day -- either way, this is long enough that
/// a single slow day never trips it, but real silence always does.
const staleAfter = Duration(hours: 26);

/// True if the most recent Briefing Run is old enough that delivery might
/// be broken, not just running a little behind schedule.
///
/// A never-run app (no Briefing Run yet at all) is not stale -- there is
/// nothing to have gone silent yet.
bool isStale({required DateTime? lastRunCompletedAt, required Clock clock}) {
  if (lastRunCompletedAt == null) {
    return false;
  }
  return clock().difference(lastRunCompletedAt) > staleAfter;
}
