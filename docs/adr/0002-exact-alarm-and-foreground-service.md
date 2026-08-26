# Trigger the Briefing Run with an exact alarm driving a foreground service

The morning Briefing Run is started by an `AlarmManager` exact alarm
(`setExactAndAllowWhileIdle`, via `android_alarm_manager_plus`) whose receiver
immediately starts a `dataSync` foreground service that does the actual work.
WorkManager cannot express this: it has a 15-minute minimum interval and no
wall-clock guarantee, and overnight Doze defers jobs to maintenance windows that
grow rarer the longer the device sits idle — a 05:00 job can land after 06:30.

The alarm callback alone is not enough either. An allow-while-idle alarm grants
only a brief temporary power allowlist — seconds, undocumented — while a
Briefing Run needs two network syncs plus local inference. Exact alarms are
explicitly exempt from the Android 12+ foreground-service background-start
restriction, so the alarm may start one, and a foreground service is not subject
to Doze network suspension.

The alarm fires at a **fixed, user-configurable time**. `getNextAlarmClock()`
would be better — it reads whatever alarm the Clock app has set, needs no
permission, and would keep the briefing aligned with travel and weekends — but
it costs a platform channel, a manifest receiver for
`ACTION_NEXT_ALARM_CLOCK_CHANGED`, and re-arm-on-change logic. A fixed time
gets most of the value for a fraction of the work; see
[DECISIONS.md](../DECISIONS.md).

## Consequences

There is no exact repeating alarm API, so each run re-arms the next one, and
alarms are re-armed on `BOOT_COMPLETED`, `MY_PACKAGE_REPLACED`, `TIME_SET` and
`TIMEZONE_CHANGED`.

A foreground service must display a notification while running, so a transient
low-importance notification appears before the real Focus Pull notification.

The app declares `USE_EXACT_ALARM` (protection level `normal`, granted at
install) rather than `SCHEDULE_EXACT_ALARM` (denied by default on Android 14+,
requiring a settings round-trip). This is only available because the app is
sideloaded: Play polices `USE_EXACT_ALARM` at review time, not the OS, and a
daily-agenda app would likely fail that review. **Publishing to Play would
invalidate this decision.**

Delivery is never guaranteed — OEM battery management can suppress alarms, and
App Standby's Restricted bucket allows one alarm per day with no network. Every
run persists a timestamp and the UI surfaces staleness rather than failing
silently. The target device is a Pixel, where this risk is lowest.
