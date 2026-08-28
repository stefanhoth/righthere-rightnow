# What Matters is prose, read once and remembered

The user's intent enters the app as **prose** — a markdown file they own, read
over WebDAV from their own Nextcloud. Not a form, not front matter, not a
schema. A structured file you must maintain is a file you stop maintaining, and
an abandoned What Matters file makes the whole feature worthless.

Prose alone is not enough, though, because two things that depend on it are
arithmetic. Pace needs a deadline and a session count to compute "four sessions
behind". The escalation rule in
[ADR-0007](0007-overdue-escalates-by-consequence.md) needs a list. Neither can
be computed from a paragraph.

So there is a **separate extraction pass**. Once per Briefing Run, the
Inference Engine reads only the prose and returns structure — Projects with
deadlines and session counts, and the never-decays list. That structure is
written to Drift. The deterministic ranker reads the cache. **The ranking
prompt never contains the raw prose**, which also keeps it inside the engine's
4096-token budget alongside 25 items and their features.

## Consequences

**This amends the non-negotiable, and the amendment is narrower than it
sounds.** "The deterministic fallback ranker always works, and the model is
never the only path to a Daily Agenda" remains true: the fallback still ranks
calendar and Todoist features with no model involved, and still always produces
an agenda. What becomes model-dependent is **first contact with a changed What
Matters file**. Edit the prose on a device where no engine ever becomes
available, and the app keeps ranking against the previously understood version.
It degrades to yesterday's understanding of your priorities, not to none.

That is a real cost and it is the reason this is an ADR. The alternative —
feeding raw prose into the ranking prompt every run — makes What Matters
disappear entirely whenever inference fails, and turns Pace from a calculation
into a sentence the model wrote.

**Both the extraction and the raw prose are snapshotted into every Briefing
Run.** Without the extraction, replaying a three-week-old day scores it against
today's priorities and the diff in Task 3.6 means nothing. Without the prose,
there is no way to later tell whether a bad ranking came from a bad extraction
or a bad prompt. Neither is backfillable.

A WebDAV failure uses the last good copy, the same way a Todoist outage is
handled in Task 1.10. **A partial parse is never accepted** — a What Matters
file that silently loaded half the never-decays list is worse than one that did
not load at all, because the user has no way to notice.
