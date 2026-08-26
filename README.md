# Right Here, Right Now

A personal morning briefing for Android. It reads your calendar and your task
manager, ranks everything competing for your attention today into one list, and
puts the top two on your lock screen before you wake up.

Single user, sideloaded, Android only. There is no backend and no Play Store
release — several architectural decisions depend on that.

---

## Start here

**If you are an AI agent or a developer new to this repo, read these three, in
this order, before writing any code:**

| Read | Why |
|------|-----|
| [CONTEXT.md](CONTEXT.md) | The domain glossary. Use this vocabulary in all code, types, comments and commit messages. |
| [docs/adr/](docs/adr/) | Four decisions that look arbitrary without their reasoning. |
| [docs/plan/](docs/plan/README.md) | The work, as ordered tasks with acceptance criteria. |

Then pick up the next unfinished task in the current milestone.

## Standing rules

These apply to every change, and exist because violating them silently produces
plausible-looking, wrong code.

1. **Use the glossary.** An `Agenda Item` is never an "entry". A calendar-derived
   item is a `Commitment`, never a "meeting". A `Briefing Run` is not a "sync".
2. **Do not revisit a decision an ADR settles.** If one seems wrong, stop and
   say so. Do not quietly change course.
3. **A task is done when its acceptance criteria demonstrably pass** — not when
   the code looks right.
4. **If acceptance criteria cannot be met, stop and report why.** Do not
   substitute a different approach.
5. **One topic per commit**, conventional commits.

## Non-negotiables

Load-bearing, and easy to skip under schedule pressure:

- **The deterministic fallback ranker always works.** The model is never the
  only path to a Daily Agenda. See [ADR-0003](docs/adr/0003-llm-ranks-under-a-permutation-contract.md).
- **Briefing Run snapshots persist from the very first run.** This data cannot
  be backfilled.
- **`lib/domain/` imports nothing but `dart:` and `package:meta`.** No Flutter,
  no platform channels, no third-party packages.

## How it fits together

```
Android Calendar Provider ─┐
                           ├─→ Candidate Set ─→ ranking ─→ Daily Agenda ─→ Focus Pull
Todoist API v1 ────────────┘                                                (notification)
```

A Briefing Run is triggered by an exact alarm set relative to your real wake
alarm, executes inside a `dataSync` foreground service, and posts a silent
notification carrying the top two Agenda Items. Ranking is done by an on-device
model constrained to returning a permutation of item IDs, with a deterministic
fallback whenever that output fails validation.

## Layout

```
lib/
  domain/     pure Dart. Types and rules. No I/O, no Flutter.
  data/       calendar, todoist, db, settings — everything that talks outward
  briefing/   candidate set assembly, ranking, orchestration
  ui/         screens and widgets
docs/
  adr/        architecture decision records
  plan/       milestones and tasks
```

## Development

Requires the Flutter stable channel and an Android SDK. Target device is a
Pixel 9 (`minSdk 30`, `arm64-v8a`).

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Before every commit:

```bash
flutter analyze && flutter test
```

Note that several behaviours **cannot be verified in debug or on an emulator**:
background alarm callbacks require a release build to prove tree-shaking hasn't
removed them, and on-device inference does not run on emulators.

## Status

Design and planning complete. Implementation has not started — begin with
[Milestone 0](docs/plan/milestone-0-spikes.md), whose two spikes resolve
assumptions that would otherwise invalidate later work.
