# GitHub repository settings

One-time steps that cannot live in a file. Do these once; everything else in
this repo is configuration-as-code.

## 1. Import the branch-protection ruleset

**Settings → Rules → Rulesets → New ruleset → Import a ruleset**, and upload
[.github/rulesets/main-branch-protection.json](../.github/rulesets/main-branch-protection.json).

It enforces: PR required (0 approvals — solo repo, self-merge on green),
squash-only, linear history, no force-push, no deletion, and these required
status checks:

| Check | Workflow |
|---|---|
| `Lint` | ci.yml |
| `Test` | ci.yml |
| `Build` | ci.yml |
| `Audit` | ci.yml |
| `Conventional commit title` | pr-title.yml |

> **The check names are an API.** They must match the workflow jobs' `name:`
> fields verbatim. Renaming a job without updating the ruleset does not fail
> loudly — GitHub simply waits for a check that will never arrive, and every
> future PR becomes unmergeable.

## 2. Enable merge conveniences

**Settings → General → Pull Requests:**

- ✅ **Allow auto-merge** — required for green PRs to merge themselves.
- ✅ **Automatically delete head branches**.
- ✅ **Allow squash merging** — and set the squash commit message to
  **"Pull request title and description"**, so the conventional-commit title
  the PR-title check validated is what actually lands on `main`.
- ❌ Disable merge commits and rebase merging (the ruleset already restricts
  merges to squash; this keeps the UI consistent).

## 3. Install Renovate

Install the [Renovate GitHub App](https://github.com/apps/renovate) for this
repository. Config is [renovate.json](../renovate.json) — no dashboard setup
needed.

Renovate opens an onboarding PR first; merge it to activate.

## 4. Secrets

**None required.** The release workflow uses the built-in `github.token`, and
the APK is signed with debug keys deliberately (personal sideloaded app, no
Play Store release, so there is no upload key to protect).

If a Play Store release is ever added, this changes: a signing keystore and
its password become repository secrets, and
[ADR-0002](adr/0002-exact-alarm-and-foreground-service.md) must be revisited,
because `USE_EXACT_ALARM` is only permissible outside Play.

## 5. Verify

After importing the ruleset, open a throwaway PR and confirm all five checks
appear and are required. A check listed in the ruleset but missing from the
PR means a job name drifted — fix it before merging anything else.
