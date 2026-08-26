# Milestone 2 — The briefing arrives on its own

**Outcome:** a Briefing Run happens each morning without being asked, and a
silent notification carrying the Focus Pull is waiting on the lock screen. Tap
it to land on the Daily Agenda.

Read [ADR-0002](../adr/0002-exact-alarm-and-foreground-service.md) before
starting. It explains why WorkManager is not used, and why the app may declare
`USE_EXACT_ALARM`.

---

## Task 2.1 — Alarm scheduling

Dependencies: `android_alarm_manager_plus: ^5.1.1`.

**Manifest:** declare `USE_EXACT_ALARM` — **not** `SCHEDULE_EXACT_ALARM`. If
both are declared on API 33+, `SCHEDULE_EXACT_ALARM` is ignored.
`USE_EXACT_ALARM` is protection level `normal`: granted at install, no prompt,
no settings round-trip. This is only legitimate because the app is sideloaded.

Schedule with:

```dart
AndroidAlarmManager.oneShotAt(
  when, id, callback,
  exact: true, allowWhileIdle: true, wakeup: true, rescheduleOnReboot: true,
);
```

**There is no exact repeating alarm API.** Re-arm the next occurrence from
inside the callback. Also re-arm on `BOOT_COMPLETED`, `MY_PACKAGE_REPLACED`,
`TIME_SET` and `TIMEZONE_CHANGED` — all four are on the implicit-broadcast
exception list, so a manifest receiver is allowed.

**Background isolate rules — the #1 source of "works in debug, fails in
release":**

- The callback must be **top-level or static** and annotated
  `@pragma('vm:entry-point')`, or release-mode tree-shaking removes it.
- It runs in a **fresh isolate** with no access to main-isolate memory,
  globals, singletons or providers. Re-initialise everything inside it.

**Acceptance criteria**

- Alarm fires in a **release** build (debug-only success proves nothing here).
- Survives reboot.
- Survives app update.
- Re-arms itself for the following day.

---

## Task 2.2 — Schedule relative to the real wake alarm

Fixed 05:00 is a poor default. `AlarmManager.getNextAlarmClock()` returns the
next alarm set by **any** app, including the Clock app — and needs **no
permission**.

- Schedule the Briefing Run for **wake alarm minus 20 minutes**.
- Fall back to **05:00** when `getNextAlarmClock()` returns null.
- Register a manifest receiver for `ACTION_NEXT_ALARM_CLOCK_CHANGED` and re-arm
  whenever the wake alarm changes.

Expose this via the platform channel from Task 1.7 or a sibling channel.

**Acceptance criteria**

- Changing the phone alarm re-arms the Briefing Run within seconds.
- Removing all alarms falls back to 05:00.
- The chosen next-run time is visible in Settings, so it can be verified without
  waiting a day.

---

## Task 2.3 — Foreground service for the run

The alarm callback itself gets only a brief temporary power allowlist —
seconds, undocumented — while a Briefing Run needs two network calls (and later,
inference). Deep Doze suspends network outside that grant.

Exact alarms are explicitly exempt from the Android 12+ foreground-service
background-start restriction, so the alarm receiver may start one.

- `flutter_foreground_task: ^11.0.1` (**not** `flutter_background_service` — no
  release in 20 months, 225 open issues).
- Service type `dataSync`; declare `FOREGROUND_SERVICE_DATA_SYNC` and
  `android:foregroundServiceType="dataSync"` (required since Android 14).
- Run the Milestone 1 orchestration inside it, then `stopSelf()`.
- Android 15+ caps `dataSync` at 6h per 24h cumulative — irrelevant at ~60s/day.

The service must display a notification while running. Use a minimal
low-importance one on a **separate channel** from the Focus Pull.

**Acceptance criteria**

- A full Briefing Run completes from the alarm with the screen off and the
  device idle overnight.
- Network succeeds (this is what the foreground service exists to guarantee).
- The service stops afterwards; it is not left running.

---

## Task 2.4 — The Focus Pull notification

Dependency: `flutter_local_notifications: ^22.3.0`.

**Architectural trap:** `zonedSchedule` schedules a *notification* natively — it
does **not** run Dart at the scheduled time. Since the run must fetch and rank
first, the alarm runs Dart (Task 2.1) and only then calls `show()`.

**Channel — importance is immutable after creation.** Once created, the user
owns it; you can never raise or lower it in code. **Version the channel id from
day one: `daily_briefing_v1`.**

Settings for silent-but-visible:

```dart
importance: Importance.low,   // no sound, no heads-up, still on lock screen
priority: Priority.low,
playSound: false, enableVibration: false, silent: true,
visibility: NotificationVisibility.public,
onlyAlertOnce: true,
```

`Importance.min` is **too** quiet — it is absent from the lock screen. Request
`POST_NOTIFICATIONS` (Android 13+).

**Content** (per the agreed Q14 answer): the **verbatim titles** of the top two
Agenda Items. No generated text in this milestone. Facts are correct by
construction — the lock screen is the worst place for a hallucination.

**Acceptance criteria**

- Notification appears silently, is present on the lock screen, and shows
  content rather than "1 notification".
- Titles match the top two ranked items exactly.
- No sound or vibration.

---

## Task 2.5 — Notification tap → Daily Agenda

- **Cold start:** `getNotificationAppLaunchDetails()` at startup →
  `didNotificationLaunchApp` + `payload` → navigate.
- **Warm:** `onDidReceiveNotificationResponse` → navigate via a
  `GlobalKey<NavigatorState>` or a router stream.
- **Do not** attempt navigation from `onDidReceiveBackgroundNotificationResponse`
  — it runs in a separate isolate with no UI. Use it only for action-button side
  effects.
- Payload carries the `runId`, so the app opens the exact agenda advertised.

**Acceptance criteria**

- Tapping from a cold start lands on the Daily Agenda for that run.
- Tapping while backgrounded does the same.
- Launching normally (not via notification) shows the latest agenda.

---

## Task 2.6 — Staleness surfacing

Delivery is never guaranteed. OEM battery management can suppress alarms, and
App Standby's Restricted bucket permits one alarm per day with no network. A
Pixel is the best case, but silence must never look like success.

- Persist the last successful run timestamp.
- If the newest Briefing Run is older than ~26 hours, show a banner explaining
  it and linking to battery settings.
- Offer `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` during onboarding — this also
  exempts the app from Doze and from FGS background-start restrictions. Check
  state with `PowerManager.isIgnoringBatteryOptimizations()`.

**Acceptance criteria**

- Banner appears when runs are stale, disappears after a successful run.
- Battery-optimisation state is visible in Settings.
