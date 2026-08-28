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
| 0 | [milestone-0-spikes.md](milestone-0-spikes.md) | Two unknowns resolved before they can invalidate the design | 0.1 has an on-device finding; 0.2 unrun |
| 1 | [milestone-1-agenda.md](milestone-1-agenda.md) | A useful Daily Agenda on demand, no AI, no scheduling | Complete |
| 2 | [milestone-2-briefing.md](milestone-2-briefing.md) | It arrives on its own, as a silent notification | Complete |
| 3 | [milestone-3-model.md](milestone-3-model.md) | The model ranks and phrases; feedback loop closes | Complete; model ranked on device 2026-08-28 (enabling PRs #41–#45 unmerged) |
| 4 | [milestone-4-what-matters.md](milestone-4-what-matters.md) | The model visibly runs; the user's own priorities reach the ranker | Next |

Milestone 1 is independently useful. Milestones 2 and 3 each add value without
being required by the one before.

**"Complete" means merged and tested, not proven on the Pixel.** Task 4.2 is the
exception: on 2026-08-28 a release build on the Pixel 9 (Android 17, SDK 37)
recorded a Briefing Run with `rankedBy == model` — status line "Ranked by the
model", screenshot-confirmed, 10.85 s, 57 output tokens, order visibly the
model's. Getting there needed five device-only fixes: the R8 keep rule (PR #38,
merged), serialised inference, the 256-token `maxOutputTokens` ceiling,
switching the ranking answer from ids to per-item numbers, and moving the
output-format contract out of the versioned prompt into code. The last four are
PRs #41–#45 (stack from `fix/serialize-inference`), not yet merged — worth one
glance at a `main` run once they land, but the question is settled. The
confirmed run also showed the model's ranking *quality* is poor (it buried the
two most consequential items); that is Milestone 4's later tasks. Separately,
`BACKGROUND_USE_BLOCKED` on the device makes ADR-0006 a hard engine constraint.
Milestone 0 spike 0.2 is still unrun; 0.1's Result section carries the full
on-device finding.
