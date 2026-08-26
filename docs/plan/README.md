# Implementation Plan

Work through milestones in order. Within a milestone, tasks are ordered by
dependency — do them top to bottom.

## How to work this plan

1. Read [CONTEXT.md](../../CONTEXT.md) first. Use its vocabulary in all code,
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

- `flutter analyze` reports no issues.
- New logic has unit tests; `flutter test` passes.
- The app still builds: `flutter build apk --debug`.

## Non-negotiables

These are load-bearing and easy to skip when moving fast:

- **The deterministic fallback ranker must always exist and always work.** The
  model is never the only path to a Daily Agenda.
- **Briefing Run snapshots are persisted from the very first run.** This data
  cannot be backfilled.
- **Nothing in `lib/domain/` may import Flutter, platform channels, or any
  package.** Pure Dart only — it must stay portable and unit-testable.

## Target environment

Single user, sideloaded, Android only. Target device is a Pixel 9. There is no
backend, no multi-user support, and no Play Store release. Several decisions
(notably `USE_EXACT_ALARM` in ADR-0002) are only valid because of this.

## Milestones

| # | File | Outcome |
|---|------|---------|
| 0 | [milestone-0-spikes.md](milestone-0-spikes.md) | Two unknowns resolved before they can invalidate the design |
| 1 | [milestone-1-agenda.md](milestone-1-agenda.md) | A useful Daily Agenda on demand, no AI, no scheduling |
| 2 | [milestone-2-briefing.md](milestone-2-briefing.md) | It arrives on its own, as a silent notification |
| 3 | [milestone-3-model.md](milestone-3-model.md) | The model ranks and phrases; feedback loop closes |

Milestone 1 is independently useful. Milestones 2 and 3 each add value without
being required by the one before.
