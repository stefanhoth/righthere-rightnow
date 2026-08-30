# CLAUDE.md

Operating manual for agents and humans working in this repository.

## What this is

A personal morning briefing for Android. It reads calendar and Todoist. It
ranks everything into one Daily Agenda. It puts the top two on the lock screen
before you wake up. Single user, sideloaded, **Android only**, no backend.

Several decisions depend on our choice never to ship to Play. See
[ADR-0002](docs/adr/0002-exact-alarm-and-foreground-service.md).

## Read before writing code

0. [docs/VISION.md](docs/VISION.md). What the app is for, and what it refuses
   to do. Two named failures justify everything else.
1. [CONTEXT.md](CONTEXT.md). The glossary. Use this vocabulary everywhere:
   code, types, comments, commit messages, PR titles.
2. [docs/adr/](docs/adr/). Decisions that look arbitrary without their
   reasoning. **Do not revisit one. Object instead.**
3. [docs/plan/](docs/plan/README.md). Ordered tasks with acceptance criteria.

## Commands

Every command lives in the [Makefile](Makefile). CI calls the same targets, so
they cannot drift.

| Command | What |
|---|---|
| `make ci` | Everything CI runs: deps, format check, lint, test |
| `make lint` | `flutter analyze --fatal-infos --fatal-warnings lib test` |
| `make fmt` | Format in place |
| `make fmt-check` | Fail if unformatted (does not write) |
| `make test` | Tests, randomised ordering |
| `make coverage` | Tests + `coverage/lcov.info` |
| `make fix` | `dart fix --apply`. Review the diff, it edits semantics |
| `make hooks` | Enable git hooks (run once after cloning) |

## Stack

- **Flutter**, pinned in [.flutter-version](.flutter-version). CI installs that
  exact version.
- **Riverpod** for state, **Drift** for persistence, **mocktail** for mocks.
- **very_good_analysis** for lints, with all three `strict-*` modes on.

## Zero-warning policy

Warnings are errors. `make lint` runs with `--fatal-infos --fatal-warnings`,
because **nearly every Dart lint reports at info severity**. Without
`--fatal-infos`, a "clean" analysis enforces almost nothing.

You fix a new warning in the change that would introduce it, or you suppress it
**at the site** with a justification. Never silence one globally. The
`unnecessary_ignore` and `document_ignores` rules are on, so stale or
unexplained `// ignore:` comments are themselves failures.

## Testing

- **Unit tests for all pure logic**: ranking, parsing, window arithmetic,
  feature computation. `lib/domain/` is pure Dart precisely so this stays
  fast and possible.
- **Widget tests** for screen states.
- **No emulator E2E in CI.** See [DECISIONS.md](docs/DECISIONS.md). The
  behaviours that carry real risk here cannot run in CI at all.

**You cannot verify these in CI or debug builds.** They need a release build on
the physical Pixel:

- Background alarm callbacks (release-mode tree-shaking removes entry points
  that lack `@pragma('vm:entry-point')`).
- On-device inference (does not run on emulators).
- Doze / battery-optimisation behaviour.

Never report these as working because a CI run was green.

On-device status: a Pixel 9 Briefing Run recorded `rankedBy == model` on
2026-08-28 (screenshot-confirmed, per
[docs/plan/milestone-0-spikes.md](docs/plan/milestone-0-spikes.md) Task 0.1).
The enabling code is PRs #41–#45, not yet merged. Ranking quality is not yet
good, and Nano returns `BACKGROUND_USE_BLOCKED` unless the app is foreground —
inference in the morning Briefing Run is impossible on this engine.

## Non-negotiables

- **The deterministic fallback ranker always works.** The model is never the
  only path to a Daily Agenda.
  [ADR-0008](docs/adr/0008-what-matters-is-prose-with-a-cached-extraction.md)
  amends this: reading a *changed* What Matters document needs the model.
  Without it, the app ranks against the last understood version, never against
  nothing.
- **Briefing Run snapshots persist from the first run.** You cannot backfill
  them.
- **`lib/domain/` imports nothing but `dart:` and `package:meta`.**

## Workflow

- **One topic per PR.** Unrelated fixes spotted along the way become their own
  branch, not a bigger diff.
- **Conventional commits**, with scope: `feat(agenda): rank overdue by decay`.
  Commit incrementally, not one bundle at the end.
- The **PR title becomes the squash commit** on `main` and is a required
  check. Write it as a conventional commit.
- Ship a change like this:
  1. Branch from fresh `origin/main`.
  2. Run `make ci` green locally.
  3. Rebase, then push.
  4. Open the PR and enable auto-merge.
- Ship a series of three or more dependent PRs as a **stack** (`gh stack`):
  1. `gh stack init --base main <first-branch>`, then `gh stack add <branch>`
     per topic. One topic per layer still holds.
  2. `make ci` green on each layer before moving up.
  3. `gh stack submit --open` — pushes, opens, and links every PR at once.
  4. When `main` moves, `gh stack sync` — one cascading rebase and
     force-with-lease push for the whole stack. `git rerere` is on, so a
     conflict resolved once replays up the layers.
  5. Land it with `gh stack merge` (atomic, squash, one commit per PR) — not
     layer-by-layer.
  - Run every `gh stack` command from **one checkout**. A stack cannot span
    worktrees — `sync`, `rebase`, and `modify` check each layer out in turn.
    See [DECISIONS.md](docs/DECISIONS.md).
  - More than one stack in flight: `gh stack checkout` with no argument lists
    every stack with its number and merge status.
- `main` is protected: no direct pushes.

## Gotchas

- **`custom_lint` is archived.** Dart 3.10+ has a first-party plugin system
  using a **top-level `plugins:` key**. `riverpod_lint` already uses it. Every
  pre-2026 tutorial telling you to add `custom_lint` to `dev_dependencies` and
  run `dart run custom_lint` is obsolete.
- **`todo` is an info-level diagnostic**, so `--fatal-infos` would fail on
  every `// TODO`. analysis_options.yaml sets it to `ignore`.
- **Generated code** (`*.g.dart`, `*.drift.dart`, …): analysis excludes it. Do
  not edit it by hand, and do not add lint ignores to it.
- **`dart run build_runner` needs `--delete-conflicting-outputs`**, or it fails
  on stale outputs with a confusing error.
