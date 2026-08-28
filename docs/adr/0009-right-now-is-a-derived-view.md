# Right Now is a derived view, not a second Briefing Run

The app's name promises an answer that changes as the hour changes, and the
Briefing Run does not provide one: it gathers, ranks and snapshots once each
morning. The obvious way to close that gap is to make the Briefing Run
recurring and re-rank through the day.

That would be a mistake. Every Briefing Run writes a snapshot, and the
one-run-per-day snapshot is the baseline the replay harness (Task 3.6) diffs
against. Runs every few minutes would multiply the history, destroy the
per-day comparison, and make the agreement metric meaningless — while
refetching Todoist and the calendar dozens of times to reorder a set that has
almost certainly not changed.

**Right Now re-scores the already-persisted Candidate Set in memory.** It
fetches nothing, runs no model, and writes no snapshot. Finished Commitments
drop out, the remaining hours of the day shrink what is plausible, and the gap
before the next Commitment decides what is worth starting. All of that is
arithmetic over data already in hand, so it is pure, cheap and unit-testable
against a fixed clock.

It is triggered at app-open and by a timer while the app is on screen. Nothing
else.

## Consequences

**The Focus Pull keeps carrying the morning ranking.** Putting Right Now on
the lock screen means a notification updated through the day, which is new
background work and a new argument with Doze — the opposite of what
[ADR-0006](0006-inference-runs-when-the-app-opens.md) just simplified away.
That remains the endgame and is listed as a deliberate omission in
[VISION.md](../VISION.md).

**A Right Now ordering is not persisted, so it cannot be replayed or
corrected.** Drag-to-reorder acts on the Daily Agenda. This is deliberate: the
Daily Agenda is the thing whose ranking is being improved, and Right Now is a
deterministic function of it plus the clock. The moment a Right Now ordering
itself needs judging, this decision is the one to reopen.

Because the re-score is deterministic and model-free, it is unaffected by
[ADR-0006](0006-inference-runs-when-the-app-opens.md)'s rule that inference
runs only in the foreground. It works whether or not an engine exists.
