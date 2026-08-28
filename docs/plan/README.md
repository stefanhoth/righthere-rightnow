# Implementation Plan

Work through milestones in order. Within a milestone, tasks are ordered by
dependency — do them top to bottom.

## How to work this plan

0. Read [VISION.md](../VISION.md) — what the app is for, and what it refuses
   to do. A task that serves neither named failure needs justifying.
1. Read [CONTEXT.md](../../CONTEXT.md) next. Use its vocabulary in all code,
   types, and commit messages. An `Agenda Item` is never called an "entry"; a
   calendar-derived item is a `Commitment`, never a "meeting".
2. Read the ADRs in [../adr/](../adr/). They record decisions that look
   arbitrary without their reasoning. **Do not revisit a decision an ADR
   settles** — if it seems wrong, stop and say so rather than quietly changing
   course.
3. Do one task at a time. Each has explicit acceptance criteria. A task is done
   when its criteria demonstrably pass, not when the code looks right.
4. Commit per task, conventional commits, one topic per commit.
5. If a task's acceptance criteria cannot be met, stop and report why. Do not
   substitute a different approach silently.

## Definition of done for every task

- `make ci` passes — dependencies, format check, strict lint, tests.
- New logic has unit tests.
- The app still builds: `flutter build apk --debug`.

Lint runs with `--fatal-infos --fatal-warnings`; see
[ADR-0005](../adr/0005-zero-warning-quality-baseline.md) for why the flag
matters. Warnings are fixed in the change that introduces them, or suppressed
at the site with a justification — never globally silenced.

## Non-negotiables

These are load-bearing and easy to skip when moving fast:

- **The deterministic fallback ranker must always exist and always work.** The
  model is never the only path to a Daily Agenda. Amended by
  [ADR-0008](../adr/0008-what-matters-is-prose-with-a-cached-extraction.md):
  reading a *changed* What Matters document needs the model. Without it the app
  ranks against the last understood version — never against nothing.
- **Briefing Run snapshots are persisted from the very first run.** This data
  cannot be backfilled.
- **Nothing in `lib/domain/` may import Flutter, platform channels, or any
  package.** Pure Dart only — it must stay portable and unit-testable.

## Target environment

Single user, sideloaded, Android only. Target device is a Pixel 9. There is no
backend, no multi-user support, and no Play Store release. Several decisions
(notably `USE_EXACT_ALARM` in ADR-0002) are only valid because of this.

## Milestones

| # | File | Outcome | Status |
|---|------|---------|--------|
| 0 | [milestone-0-spikes.md](milestone-0-spikes.md) | Two unknowns resolved before they can invalidate the design | Neither spike run |
| 1 | [milestone-1-agenda.md](milestone-1-agenda.md) | A useful Daily Agenda on demand, no AI, no scheduling | Complete |
| 2 | [milestone-2-briefing.md](milestone-2-briefing.md) | It arrives on its own, as a silent notification | Complete |
| 3 | [milestone-3-model.md](milestone-3-model.md) | The model ranks and phrases; feedback loop closes | Complete, unproven on device |
| 4 | [milestone-4-what-matters.md](milestone-4-what-matters.md) | The model visibly runs; the user's own priorities reach the ranker | Next |

Milestone 1 is independently useful. Milestones 2 and 3 each add value without
being required by the one before.

**"Complete" means merged and tested, not proven on the Pixel.** Milestone 3
has never been demonstrated on the device — no Briefing Run is known to have
recorded `rankedBy == model`. Task 4.2 exists to find out. Both Milestone 0
spikes are still unrun.
