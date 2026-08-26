# Decisions

Smaller calls that shaped the repo but didn't warrant a full ADR. Newest
first. Add an entry in the same PR that makes the decision.

## 2026-08-26 — Fixed run time instead of reading the phone's wake alarm

The Briefing Run fires at a configurable time, defaulting to 05:30, rather
than tracking `AlarmManager.getNextAlarmClock()`.

Reading the Clock app's alarm and firing 20 minutes before is strictly better
behaviour — it needs no permission and follows travel, weekends and lie-ins
automatically. It also costs a platform channel, a manifest receiver for
`ACTION_NEXT_ALARM_CLOCK_CHANGED`, and re-arm-on-change logic, for a benefit
that only materialises when the wake time actually moves.

Backlog, not discarded. The trigger to revisit is the first morning the fixed
time is wrong — an early flight, or a weekend lie-in where the briefing is
already stale by the time it's read.

Note the exact alarm itself was **kept**: `USE_EXACT_ALARM` is one manifest
line at protection level `normal` for a sideloaded app, so relaxing it would
have saved nothing while letting Doze push the run past wake-up. See
[ADR-0002](adr/0002-exact-alarm-and-foreground-service.md).

## 2026-08-26 — No emulator-based E2E in CI

CI gates on unit and widget tests only. An Android emulator job needs a
non-verified third-party action, adds ~10 minutes per run, and — decisively —
**the behaviours that actually carry risk here cannot run on an emulator at
all**: exact alarms in release builds, Doze, and on-device inference.

An emulator suite would therefore cost real time while proving the least
risky part of the system. Verification of scheduling and inference stays
manual on the physical Pixel, and CLAUDE.md says so explicitly so a green CI
run is never mistaken for proof those work.

Revisit if the app grows UI complex enough that widget tests stop being
convincing. `patrol` is the current tool of choice if so.

## 2026-08-26 — Makefile over justfile for task running

`just` is the nicer tool and is ascendant in 2026, but it is a binary that is
not part of the Flutter toolchain, so CI would need an extra install step
(and the obvious action for it is unverified third-party). A Makefile needs
nothing anywhere.

The property that actually matters — CI and developers invoking *the same*
command — is satisfied either way.

## 2026-08-26 — Plain `.githooks/` over Lefthook

Lefthook v2 is what most professional teams use and is genuinely better. It
is also a Go binary each machine must install. For a solo repo, committed
shell hooks enabled by `make hooks` are zero-dependency, reviewable like any
other code, and sufficient.

`flutter test` runs on **pre-push**, not pre-commit: a pre-commit test hook
is slow enough to train you into `--no-verify`, which defeats the apparatus.

## 2026-08-26 — very_good_analysis 10.3.0 stable, not 11.0.0-rc.1

11.0.0-rc.1 targets Dart 3.13 exactly (our version) and adds useful rules,
but it is nine days old and still a release candidate. For a foundation whose
stated purpose is reliability, stable wins; Renovate will offer 11.0.0 when
it ships. Low-risk either way — this is a dev dependency with no runtime
surface.

## 2026-08-26 — APK signed with debug keys

The release workflow attaches a debug-signed APK. This is a personal
sideloaded app with no Play Store release, so there is no upload key to
protect, and a release keystore would mean a signing secret in CI for no
benefit.

Changes the moment a Play release is contemplated — which would also
invalidate [ADR-0002](adr/0002-exact-alarm-and-foreground-service.md).

## 2026-08-26 — Inline Flutter install in CI, not `subosito/flutter-action`

`subosito/flutter-action` is the de-facto standard (Very Good Ventures pin it
in production) and there is **no official Flutter setup action** — only
`dart-lang/setup-dart`, which installs Dart alone.

It is nonetheless an unverified third-party action with access to the
workflow. A local composite action at `.github/actions/setup-flutter`
downloads the pinned SDK from Google's release bucket and caches it with
GitHub-owned `actions/cache` — roughly 30 lines, and it verifies the
installed version matches `.flutter-version`.

Trade-off accepted: the action's cache-key templating is more sophisticated
than ours. If CI setup time becomes a problem, adopting it is a reasonable
reversal.

## 2026-08-26 — Coverage measured, not gated

CI produces `coverage/lcov.info` and uploads it, but no threshold fails the
build. A threshold set on a near-empty repo is aspirational, and an
aspirational gate is one that gets disabled.

Set a real floor once Milestone 1 lands, from what the suite actually
achieves, and ratchet upward. Expect to gate `lib/domain/` and `lib/data/`
hard while measuring — not gating — the UI layer.
