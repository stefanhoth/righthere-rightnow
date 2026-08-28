# Milestone 4 — What Matters, and a model that visibly runs

**Outcome:** the model demonstrably runs on the device and says so when it does
not; the user's own priorities reach the ranker; long-horizon work claims time
before its deadline; and the Daily Agenda re-scores against the current hour.

This is the milestone that addresses the two failures named in
[VISION.md](../VISION.md). Milestones 1 through 3 are complete.

Read [ADR-0007](../adr/0007-overdue-escalates-by-consequence.md),
[ADR-0008](../adr/0008-what-matters-is-prose-with-a-cached-extraction.md) and
[ADR-0009](../adr/0009-right-now-is-a-derived-view.md) first.

> **Everything from Task 4.4 onward assumes an engine that works.** Tasks 4.1
> to 4.3 exist because that has never been demonstrated. Do not reorder them
> to the end.

---

## Task 4.1 — Typed inference outcomes, and an honest availability check

Two defects, both of which hide inference failure completely.

**`isAvailable()` lies.** `lib/inference/built_in_ai_engine.dart` returns true
for `downloadable` and `downloading`. On a device where AICore has not yet
fetched Nano, the reranker passes the check, calls `complete()`, and fails. The
availability check must distinguish *ready now* from *might be ready later*.

**Five failures share one `null`.** `ModelReranker.rerank()` returns `null`
when the engine is unavailable, when `complete()` throws, when it times out,
when the output will not parse, and when too few IDs are recognised.
`FramingLineGenerator` has four more. No caller can tell them apart.

Replace the nullable returns with a result type that names the cause. Keep the
existing behaviour otherwise: this task changes what callers *know*, not what
the app *does*.

**Acceptance criteria**

- `isAvailable()` returns false when the model is not yet downloaded, and a
  test covers each `BuiltInAiAvailability` value.
- Every failure path in `ModelReranker` and `FramingLineGenerator` produces a
  distinct, testable outcome.
- No behavioural change to ranking. The existing tests still pass unmodified,
  apart from the signature.

---

## Task 4.2 — Prove a model runs on the Pixel

Milestone 3 has 36 test files and green CI, and none of it is evidence that
any engine has ever returned a ranking on the device. `CLAUDE.md` says as much.
Both Milestone 0 spikes still read `**Result:** _(not yet run)_`.

**Steps**

1. Release build on the Pixel. Open the app. Record whether `rankedBy` becomes
   `model`, whether a framing line appears, and the engine cold-start time.
2. If it does not work, record the availability status and the verbatim
   exception in Task 0.1's Result section.
3. **If Nano is unavailable, switch to LiteRT-LM with a downloaded Gemma** —
   the path [ADR-0004](../adr/0004-gemini-nano-behind-an-engine-interface.md)
   already anticipates. Do not chase AICore provisioning: ML Kit GenAI is Beta
   with no SLA and its availability is not ours to fix. A downloaded model is a
   file we own.

The engine interface will need a third concept for "not ready yet, here is
progress". Task 4.1's availability fix exposes the same gap.

**Acceptance criteria**

- A written finding in `milestone-0-spikes.md`, including cold-start timing.
- At least one Briefing Run on the device records `rankedBy == model`.
- If Gemma is adopted: the download has visible progress, survives being
  interrupted, and the app is usable while it runs.

---

## Task 4.3 — Show which ranker ran

Today `rankedBy` is stored, carried through `agenda_controller.dart`, and
rendered nowhere.

- **Always:** a quiet indicator on the Daily Agenda naming the ranker that
  produced this order.
- **After repeated failure:** a banner. Follow the pattern already established
  by `staleAfter = 26h` in `lib/briefing/staleness.dart` — a single bad run
  never trips it, sustained failure always does.
- **Dev screen:** the last N attempts with cause and timing, from Task 4.1's
  outcome type.
- An absent framing line must be distinguishable from a line the model chose
  not to write.

> **One banner, not two.** A second banner firing on every single fallback run
> devalues the staleness banner within a week. The indicator is for the glance;
> the banner is for real breakage.

**Acceptance criteria**

- Widget tests: model-ranked, fallback-ranked, and repeated-failure states.
- The banner does not appear after one failed run, and does appear after N.
- The indicator is present in every state, including before inference returns.

---

## Task 4.4 — Read What Matters

A markdown file over WebDAV from Nextcloud. See the Decisions entry for why not
a Google Doc.

- One app password in `flutter_secure_storage` — the Todoist token pattern.
  **Never in Drift, never logged.**
- Settings: server URL, path, credential, and a verify button.
- Cache the last good copy in Drift with its fetch time.
- A fetch failure uses the cached copy and shows partial-data state, exactly as
  a Todoist outage does in Task 1.10.

**Acceptance criteria**

- A run with an unreachable server still produces a Daily Agenda, using the
  cached document.
- The credential never appears in a log statement.
- The cached copy survives restart, and its age is visible in settings.

---

## Task 4.5 — Extract structure from the prose

Per [ADR-0008](../adr/0008-what-matters-is-prose-with-a-cached-extraction.md):
once per Briefing Run, the engine reads **only the prose** and returns
Projects (name, deadline, sessions needed) and the never-decays list. Persist
the extraction. The deterministic ranker reads the persisted extraction, never
the prose.

- **The ranking prompt must not contain the raw prose.** The budget is 4096
  tokens total for instructions, 25 items with features, and the output.
- Re-extract only when the document's content has changed.
- **Never accept a partial extraction.** Keep the previous one instead.
- Snapshot both the extraction and the raw prose into the Briefing Run. Neither
  is backfillable.

**Acceptance criteria**

- Unit tests with fixture prose covering: a clean extraction, an unparseable
  response, a partial response, and an unavailable engine — each leaving the
  previous extraction intact.
- An unchanged document does not trigger a second extraction.
- `snapshot_items` or an equivalent carries both the prose and the extraction
  for every run.

---

## Task 4.6 — Overdue escalation by consequence

Per [ADR-0007](../adr/0007-overdue-escalates-by-consequence.md). The decay
curve in `lib/briefing/fallback_ranker.dart` stays as the default. Tasks
matching the never-decays list escalate with age instead.

Pure scoring, as the existing ranker is. No I/O, no `DateTime.now()`.

**Acceptance criteria**

- A 40-day-overdue Task on the list outranks a Task due today. The same Task
  not on the list stays buried.
- Existing decay tests still pass unchanged for non-matching Tasks.
- An empty or unavailable never-decays list reproduces today's behaviour
  exactly.

---

## Task 4.7 — Projects, Sessions and Pace

A Project is a third **source** of Agenda Items, alongside calendar and
Todoist — not a new `AgendaItem` subtype. It generates an Agenda Item, the way
a Follow-up Suggestion does, and is always distinguishable from a sourced item.

- **Counting Sessions:** a past Commitment whose title matches a Project's
  declared name counts as one. The Task 1.8 lookback window already covers the
  previous working day and the weekend. Match on the declared name, not a
  guess.
- **Manual Sessions:** one button, recorded in Drift, for work done without a
  calendar block. The app writes to its own database only — never to Todoist or
  the calendar.
- **Pace:** Sessions done, against Sessions needed, against days remaining.
  Pure arithmetic in `lib/domain/`, computed from an injected `Clock`.

> Session counting measures blocked time, not work done. That is a known and
> accepted weakness — Task 4.10's weekly question is what catches it.

**Acceptance criteria**

- Pace is unit-tested against a fixed clock: on pace, behind, ahead, deadline
  passed, and zero sessions done.
- A calendar block matching a Project name increments its Session count exactly
  once per occurrence.
- A Project-derived Agenda Item is visibly distinct from a sourced one.

---

## Task 4.8 — Make the user plan ahead

A Project that is on Pace still needs to be visible, and one with no time
booked needs to say so.

- **The band:** every Project, always, outside the ranked list — the pattern
  Task 1.8 already uses for all-day Commitments. Shows Sessions done against
  needed, and days remaining.
- **The item:** when nothing in the next seven calendar days matches a
  Project's name, it enters the *ranked* list as "block time for this", and
  competes with everything else.

> The band alone is not enough. A number you learn to skim past changes
> nothing; an item in the ranked list is what converts noticing into doing.

**Acceptance criteria**

- Widget test: the band renders with several Projects, and with none.
- A Project with a matching future calendar block produces no ranked item. The
  same Project without one does.
- The band never pushes a Commitment out of the ranked list.

---

## Task 4.9 — Right Now

Per [ADR-0009](../adr/0009-right-now-is-a-derived-view.md). A pure re-score of
the persisted Candidate Set against the current hour. **No fetch, no model, no
snapshot, no Briefing Run.**

- Finished Commitments drop out.
- The hours left in the day shrink what is plausible.
- The gap before the next Commitment decides what is worth starting.

Triggered at app-open and by a timer while the app is on screen. Nothing else.
This task depends on nothing above it and can be done at any point.

**Acceptance criteria**

- Unit tests with a fixed clock: same Candidate Set, several times of day,
  asserting the intended difference in order each time.
- Pure function. No I/O, no `DateTime.now()`, no writes.
- The Focus Pull still carries the morning ranking, unchanged.

---

## Task 4.10 — The weekly question

The success test from [VISION.md](../VISION.md), and the headline metric for
the whole app: **did the work you were avoiding get done?**

- One question, once a week, on a screen that also shows current Pace for every
  Project. The evidence and the answer in one place.
- Persist the answers. A trend over months is the point; a single answer is
  not.
- Do not add a second weekly notification. This shares the existing beat.

**Acceptance criteria**

- Answers persist and are queryable as a series.
- The screen renders with no Projects declared.
- Replay's agreement metric is reported alongside, clearly as the secondary
  number.
