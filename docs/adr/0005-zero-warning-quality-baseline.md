# Zero-warning quality baseline, enforced by CI

Lints, formatting, tests and a dependency audit gate every PR, and a warning
is a build failure. `very_good_analysis` replaces `flutter_lints`, all three
`strict-*` analyzer modes are on, and analysis runs with `--fatal-infos
--fatal-warnings`. A Makefile is the single source of truth for commands so CI
and developers cannot drift apart.

The `--fatal-infos` flag is the load-bearing part, and the reason this is
written down: **nearly every Dart lint reports at info severity, and
`flutter analyze` does not fail on infos by default.** Before this change the
repo reported "No issues found" while enforcing essentially nothing. Anyone
who removes that flag to quiet a noisy build will silently disable the whole
policy.

## Consequences

`--fatal-infos` makes the build sensitive to the SDK: `deprecated_member_use`
fires the moment Flutter deprecates an API in use. This is why the Flutter
version is pinned in `.flutter-version` and CI installs exactly that — an
unpinned SDK plus fatal infos means Flutter's release cadence randomly
redlines `main`. Deprecations are demoted to `warning` and cleared with
`make fix` at upgrade time.

`todo` is demoted to `ignore`, since it is an info-level diagnostic that would
otherwise fail the build on every `// TODO`.

Generated code is excluded from analysis by glob. Modern generators also emit
`// ignore_for_file: type=lint` themselves.

`flutter_lints` was rejected: it contributes only ten Flutter-specific rules
on top of the Dart baseline, and the request for an official strict variant
has been open and unaddressed since 2024. No serious Flutter project uses it
as-is; its download count reflects `flutter create` inertia.

Smaller choices made alongside this — task runner, git hooks, coverage
gating, CI Flutter installation, E2E scope — are recorded in
[DECISIONS.md](../DECISIONS.md) rather than here.
