# Milestone 1 — A Daily Agenda on demand

**Outcome:** open the app, tap Refresh, see a ranked Daily Agenda built from
real calendar and Todoist data. No scheduling, no notification, no model.

At the end of this milestone the app is genuinely useful. Everything after is
additive.

---

## Task 1.1 — Project skeleton

Replace the generated counter app and establish structure.

**Dependencies** (`pubspec.yaml`):

```
flutter_riverpod: ^3.0.0      riverpod_annotation
drift  +  drift_flutter  +  sqlite3_flutter_libs
flutter_secure_storage: ^9.2.4
device_calendar_plus: ^0.8.0
http: ^1.2.0
intl
dev: build_runner, drift_dev, riverpod_generator, mocktail
```

`very_good_analysis` is already wired up — do not add `flutter_lints`.

> **`custom_lint` is archived — do not add it.** Dart 3.10+ ships a
> first-party analyzer plugin system using a **top-level `plugins:` key**,
> and `riverpod_lint` has already migrated to it. Enable Riverpod's lints with:
>
> ```yaml
> plugins:
>   riverpod_lint: ^3.1.8
> ```
>
> in `analysis_options.yaml` — *not* as a `dev_dependency` with a separate
> `dart run custom_lint` step. Every tutorial written before 2026 gets this
> wrong. Plugin lints are disabled by default and must be enabled explicitly.

**Structure** — create these directories with a placeholder each:

```
lib/
  main.dart
  domain/        pure Dart only. No Flutter, no packages, no platform.
  data/
    calendar/    device_calendar_plus + platform channel
    todoist/     API client
    db/          drift
    settings/    secure storage
  briefing/      candidate set assembly, ranking, orchestration
  ui/            screens and widgets
```

**Android config** (`android/app/build.gradle.kts`): `minSdk = 30`,
`ndk { abiFilters += listOf("arm64-v8a") }`.

**Acceptance criteria**

- App launches to an empty "Daily Agenda" scaffold; no counter remains.
- `ProviderScope` wraps the app.
- `flutter analyze` clean.

---

## Task 1.2 — Domain model

**Pure Dart. No imports outside `dart:` and `package:meta`.** This is enforced
by review — if you need a Flutter type here, the model is wrong.

Types (use CONTEXT.md vocabulary exactly):

- `AgendaItem` — sealed base. `id` (stable, source-prefixed e.g. `cal:123:456`,
  `td:789`), `title`, `source`.
- `Commitment extends AgendaItem` — `start`, `end`, `isAllDay`, `location`,
  `description`, `attendeeCount`, `isOrganiser`, `myResponse`
  (`ResponseStatus` enum: `none/accepted/declined/invited/tentative`),
  `isRecurring`, `conferenceUrl`, `calendarName`.
- `Task extends AgendaItem` — `due` (`TaskDue?`), `priority` (`Priority` enum —
  see 1.5 on inversion), `projectName`, `labels`, `isRecurring`, `parentId`.
- `TaskDue` — `date`, `hasTime`, `timeZone?`, `isRecurring`.
- `CandidateSet` — the items considered by one Briefing Run, plus `generatedAt`.
- `RankedAgenda` — ordered `List<AgendaItem>` plus `rankedBy`
  (`fallback | model`) and `promptVersion?`.

**Acceptance criteria**

- Unit tests construct each type and assert invariants (e.g. a `Commitment`'s
  `end` is not before `start`).
- No file under `lib/domain/` imports `package:flutter` or any third-party
  package.

---

## Task 1.3 — Drift database

Tables:

- `briefing_runs` — `id`, `startedAt`, `completedAt`, `rankedBy`,
  `promptVersion?`, `error?`.
- `snapshot_items` — `runId`, `itemId`, `payloadJson` (the full item **with its
  computed features**), `fallbackRank`, `producedRank`, `correctedRank?`.
- `run_ratings` — `runId`, `rating`, `notedAt`.

`payloadJson` stores the item as the ranker saw it. This is the replay input —
if a feature is not in here, it cannot be replayed later.

**Acceptance criteria**

- Migration strategy defined with `schemaVersion = 1`.
- A test writes a Briefing Run with items and reads it back identically.
- The DB opens from a background isolate (`drift_flutter`'s
  `driftDatabase(name:)` is isolate-safe). Add a test or a documented note.

---

## Task 1.4 — Settings and credentials

- Todoist personal API token stored via `flutter_secure_storage`. **Never in
  Drift, never in SharedPreferences, never logged.**
- Settings screen: paste token, verify it, show calendar permission state.
- Token verification: `GET /api/v1/projects?limit=1` → 200 means valid.

Get the token from Todoist → Settings → Integrations → Developer. OAuth is not
needed for single-user (ADR context: personal app).

**Acceptance criteria**

- Token persists across restarts.
- Invalid token shows a clear error and is not saved.
- Token never appears in any log statement.

---

## Task 1.5 — Todoist client

Hand-rolled; there is no Dart SDK for Todoist (verified — pub.dev returns zero
packages).

- Base URL **`https://api.todoist.com/api/v1`**. REST v2 and Sync v9 return
  **HTTP 410 Gone** — they are shut down, not deprecated. Do not use them.
- Auth header: `Authorization: Bearer <token>`.
- Fetch: `GET /tasks/filter?query=<q>&limit=200&cursor=<c>`.
- Query: **`due before: +10 days`** — per Todoist docs this already includes
  overdue tasks. Verify that empirically on first run; if it does not, use
  `overdue | due before: +10 days`.
- `query` is required, 1–1024 chars. The **comma operator is not supported** on
  this endpoint (it works only in the Todoist UI).
- Pagination: response is `{results: [...], next_cursor: string|null}`. Loop
  until `next_cursor` is null. Treat the cursor as opaque; reuse identical other
  params; never persist it.

**Three parsing traps — get these wrong and the agenda is silently wrong:**

1. **`priority` is inverted.** API `4` = urgent = the UI's "p1"; API `1` =
   normal = UI "p4". Map to the `Priority` enum by meaning, not by number, and
   unit-test all four.
2. **`due.date` has three shapes**, distinguished by the string itself — there
   is no separate `datetime` field:
   - `"2016-12-01"` — all-day
   - `"2016-12-01T12:00:00.000000"` — floating local time, **not RFC 3339**
   - `"2016-12-06T13:00:00.000000Z"` with a `timezone` field — fixed zone
3. **Labels use `%` in filter queries, not `@`.** `@` is being retired.

**Acceptance criteria**

- Unit tests parse all three `due.date` shapes from fixture JSON.
- Unit test asserts priority inversion in both directions.
- Pagination test with a two-page fixture.
- 401 surfaces as a typed "invalid token" error, not a crash.

---

## Task 1.6 — Calendar reader

Use `device_calendar_plus`. It queries `CalendarContract.Instances`, so the OS
expands recurring events for you — do not attempt RRULE expansion yourself.

- Request `READ_CALENDAR`; handle denial with a clear UI state.
- Retrieve calendars, then events per calendar for the window from Task 1.8.
- Map to `Commitment`. `instanceId` is `(eventId, begin)` — keep it, Task 1.7
  joins on it.
- Skip calendars the user has hidden.

**Acceptance criteria**

- Recurring events appear once per occurrence in the window, not once per
  series.
- All-day events are flagged, not treated as midnight-to-midnight.
- Mapping is unit-tested against fixture data (mock the plugin).

---

## Task 1.7 — Platform channel for RSVP and organiser

`device_calendar_plus` does not expose these, and the ranking needs both. It
also **actively drops the organiser attendee row**, so attendees cannot answer
it either.

The Calendar Provider builds its `Instances` projection map as a copy of the
`Events` one, so all three columns are queryable on the `Instances` URI:

```kotlin
val projection = arrayOf(
    CalendarContract.Instances.EVENT_ID,
    CalendarContract.Instances.BEGIN,
    CalendarContract.Events.SELF_ATTENDEE_STATUS, // 0 none 1 accepted 2 declined 3 invited 4 tentative
    CalendarContract.Events.IS_ORGANIZER,         // "1" / "0"
    CalendarContract.Events.ORGANIZER,            // email
)
```

Query the same window as Task 1.6, key results by `(eventId, begin)`, join in
Dart onto the `Commitment` list. Add an R8 keep rule for the channel class
(the plugin already ships one for its own package).

**Acceptance criteria**

- A declined meeting reports `myResponse == declined`.
- A meeting you created reports `isOrganiser == true`.
- Missing/unjoinable rows degrade to `ResponseStatus.none` and
  `isOrganiser == false` — never throw.

---

## Task 1.8 — Candidate Set assembly

**Time windows** — implement exactly:

- **Commitments, lookback:** from the start of the previous working day through
  now, *including intervening weekend days*. On a Monday this covers Fri, Sat
  and Sun. Empty weekends contribute nothing; a Sunday commitment still
  surfaces. (This is deliberate — see the note in Milestone 1's history.)
- **Commitments, forward:** all of today, plus **tomorrow's first Commitment**
  (an 08:00 meeting tomorrow changes tonight).
- **Tasks:** due through today + 10 days, plus all overdue.

**Filtering:**

- Drop Commitments where `myResponse == declined`.
- All-day Commitments are **day context, not ranked items** — carry them on the
  `CandidateSet` separately so the UI can show them as a header.
- Cap the ranked candidates at **25 items**; if over, trim by fallback rank.
  (The model in Milestone 3 must receive a bounded set.)

**Computed features** — attach to each item and persist in `payloadJson`:
`minutesUntilStart`, `durationMinutes`, `attendeeCount`, `isOrganiser`,
`isRecurring`, `overdueDays`, `daysUntilDue`, `priority`, `isFollowUpCandidate`
(a past Commitment, for Milestone 3).

**Acceptance criteria**

- Unit tests with a fixed clock covering: a Monday run (Fri/Sat/Sun lookback), a
  midweek run, a declined meeting excluded, an all-day event separated out, and
  the 25-item cap.
- Windows are computed from an injected `Clock`, never `DateTime.now()` inline.

---

## Task 1.9 — Deterministic fallback ranker

**This must always work.** Per ADR-0003 it is the safety net for the model, and
for this milestone it is the only ranker.

Rules, agreed:

- Declined Commitments are already excluded upstream.
- **You as organiser is a strong boost** — you owe preparation.
- **Small Commitments outrank large recurring ones** — a 1:1 (≤2 attendees)
  beats an 87-person all-hands.
- **Overdue decays:** urgent for ~7 days, then treated as **stale and pushed
  down**, not escalated. A 40-day-overdue task is dead, not screaming.
- **Explicit priority beats proximity inside a ~3-day window** — a p1 due in 3
  days outranks a p4 due today.
- Imminent Commitments rise as they approach.

Implement as a pure scoring function: `int score(AgendaItem, Clock)`. Stable
sort, deterministic tie-break on `id` so output is reproducible.

**Acceptance criteria**

- Same input + same clock always yields identical order (test it twice).
- A test per rule above, each asserting the intended pairwise ordering.
- Pure function — no I/O, no `DateTime.now()`.

---

## Task 1.10 — Briefing Run orchestration

Wire it together: fetch both sources in parallel → assemble Candidate Set →
fallback rank → persist snapshot → expose `RankedAgenda`.

- **Persist the snapshot on every run, before rendering.** Non-negotiable —
  this data cannot be backfilled.
- One source failing must not fail the run: a Todoist outage still yields an
  agenda of Commitments, with a visible partial-data warning.
- Record `startedAt`, `completedAt`, and any `error`.

**Acceptance criteria**

- A run with a failing Todoist client still produces a Daily Agenda and records
  the error.
- Every run creates exactly one `briefing_runs` row and one `snapshot_items` row
  per candidate.
- `rankedBy == fallback` for this milestone.

---

## Task 1.11 — Daily Agenda screen

- Ranked list, Commitments and Tasks visually distinct but in one order.
- All-day context shown as a header, not in the ranked list.
- Per item: title, the time or due information, and *why it ranked* (e.g.
  "you're the organiser", "overdue 2 days") — this is what makes the ranking
  debuggable and is what you will judge prompt changes against later.
- Pull-to-refresh triggers a Briefing Run; show last-run time.
- Empty, loading, permission-denied and partial-data states all handled.

**Acceptance criteria**

- Widget tests for: populated list, empty state, permission denied, partial
  data.
- Conference links (Task 1.12) render as a tappable join affordance.

---

## Task 1.12 — Conference link extraction

Android's Calendar Provider has **no conference-link column** — Meet URLs arrive
as plain text in the description. Unless Spike 0.2 found otherwise, regex it:

- `https://meet\.google\.com/[a-z]{3}-[a-z]{4}-[a-z]{3}`
- Zoom: `https://[\w-]*\.?zoom\.us/j/\d+`
- Teams: `https://teams\.microsoft\.com/l/meetup-join/\S+`

Extract into `Commitment.conferenceUrl`. **Do not mutate the description** —
that is the bug that disqualified `eventide`.

**Acceptance criteria**

- Unit tests for each pattern, plus a description containing no link, plus a
  description containing two (first wins).
- `description` is returned unchanged in every case.
