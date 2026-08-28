# Overdue escalates by consequence, not by age

The fallback ranker treats an overdue Task as urgent for about a week and then
decays it — by day 40 it scores deeply negative, on the reasoning that a task
ignored that long is dead rather than screaming. That is right for most old
tasks and it is what keeps the Daily Agenda short.

It is exactly wrong for the small number of Tasks that are *accumulating
damage* while being ignored, which is one of the two failures the app exists
to fix (see [VISION.md](../VISION.md)). Under decay alone, the app buries the
user's worst failure mode a little deeper every day.

**Age does not separate the two cases. Consequence does.** A 40-day-overdue
"read that article" is dead. A 40-day-overdue "renew the passport" is a crisis
being assembled. Todoist has no field for this, and `priority` is a poor
stand-in: it records how urgent something felt when it was written, not what
breaks if it is missed.

So the decay curve stays as the default, and What Matters names the projects
and labels that escalate with age instead of decaying. Consequence is stated by
the user, because it is not derivable from any source system.

## Consequences

The ranker now has two overdue curves rather than one, and which curve applies
is data, not code. The escalating branch depends on What Matters being
readable — [ADR-0008](0008-what-matters-is-prose-with-a-cached-extraction.md)
covers what the app does when it is not, and the answer is that it falls back
to the last understood version rather than to decay-for-everything.

**The failure mode to watch is a never-decays list that grows to include
everything.** At that point every old Task escalates, the Daily Agenda fills
with ancient work, and the rule has inverted the problem it was added to solve
rather than fixing it. If the list gets long, the honest reading is that the
Tasks on it are not actually consequential — not that the ranker needs another
rule.

This deliberately revisits a rule agreed in Task 1.9 and implemented in
`lib/briefing/fallback_ranker.dart`. It is recorded here rather than edited
quietly into the plan, because the two rules read as a contradiction without
the reasoning above.
