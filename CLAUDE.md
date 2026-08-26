# CLAUDE.md

Operating manual for agents and humans working in this repository.

## What this is

A personal morning briefing for Android: reads calendar and Todoist, ranks
everything into one Daily Agenda, and puts the top two on the lock screen
before you wake up. Single user, sideloaded, **Android only**, no backend.

Several decisions depend on never shipping to Play — see
[ADR-0002](docs/adr/0002-exact-alarm-and-foreground-service.md).

## Read before writing code

1. [CONTEXT.md](CONTEXT.md) — the glossary. Use this vocabulary everywhere:
   code, types, comments, commit messages, PR titles.
2. [docs/adr/](docs/adr/) — decisions that look arbitrary without their
   reasoning. **Do not revisit one; object instead.**
3. [docs/plan/](docs/plan/README.md) — ordered tasks with acceptance criteria.

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
| `make fix` | `dart fix --apply` — review the diff, it edits semantics |
| `make hooks` | Enable git hooks (run once after cloning) |

## Stack

- **Flutter** pinned in [.flutter-version](.flutter-version); CI installs that
  exact version.
- **Riverpod** for state, **Drift** for persistence, **mocktail** for mocks.
- **very_good_analysis** for lints, with all three `strict-*` modes on.

## Zero-warning policy

Warnings are errors. `make lint` runs with `--fatal-infos --fatal-warnings`
because **nearly every Dart lint reports at info severity** — without
`--fatal-infos`, a "clean" analysis is enforcing almost nothing.

A new warning is fixed in the change that would introduce it, or suppressed
**at the site** with a justification. Never globally silenced. The
`unnecessary_ignore` and `document_ignores` rules are on, so stale or
unexplained `// ignore:` comments are themselves failures.

## Testing

- **Unit tests for all pure logic** — ranking, parsing, window arithmetic,
  feature computation. `lib/domain/` is pure Dart precisely so this stays
  fast and possible.
- **Widget tests** for screen states.
- **No emulator E2E in CI** — see [DECISIONS.md](docs/DECISIONS.md). The
  behaviours that carry real risk here cannot run in CI at all.

**Cannot be verified in CI or debug builds** — these need a release build on
the physical Pixel:

- Background alarm callbacks (release-mode tree-shaking removes entry points
  that lack `@pragma('vm:entry-point')`).
- On-device inference (does not run on emulators).
- Doze / battery-optimisation behaviour.

Never report these as working on the basis of a green CI run.

## Non-negotiables

- **The deterministic fallback ranker always works.** The model is never the
  only path to a Daily Agenda.
- **Briefing Run snapshots persist from the first run.** Not backfillable.
- **`lib/domain/` imports nothing but `dart:` and `package:meta`.**

## Workflow

- **One topic per PR.** Unrelated fixes spotted along the way become their own
  branch, not a bigger diff.
- **Conventional commits**, with scope: `feat(agenda): rank overdue by decay`.
  Commit incrementally, not one bundle at the end.
- The **PR title becomes the squash commit** on `main` and is a required
  check — write it as a conventional commit.
- Branch from fresh `origin/main`, run `make ci` green locally, rebase, push,
  open the PR, enable auto-merge.
- `main` is protected: no direct pushes.

## Gotchas

- **`custom_lint` is archived.** Dart 3.10+ has a first-party plugin system
  using a **top-level `plugins:` key**. `riverpod_lint` already uses it. Every
  pre-2026 tutorial telling you to add `custom_lint` to `dev_dependencies` and
  run `dart run custom_lint` is obsolete.
- **`todo` is an info-level diagnostic**, so `--fatal-infos` would fail on
  every `// TODO`. It is set to `ignore` in analysis_options.yaml.
- **Generated code** (`*.g.dart`, `*.drift.dart`, …) is excluded from
  analysis. Do not hand-edit it, and do not add lint ignores to it.
- **`dart run build_runner` needs `--delete-conflicting-outputs`** or it fails
  confusingly on stale outputs.
