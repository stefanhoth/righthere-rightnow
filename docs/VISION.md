# Vision

What this app is for, and what it refuses to do. Read this before proposing a
feature. The mechanics live in [docs/plan/](plan/README.md); this is the thing
those tasks are in service of.

## The point

**Know what deserves your attention, here and now.**

Not "what is on today" — the calendar already answers that, and answers it
better. The app exists for the gap between what your tools can see and what
actually matters: your intent, the consequences of your choices, and the
shape of the hour you are actually in.

A morning briefing is the first surface, not the product. The product is a
daily driver for attention.

## The two failures it exists to fix

Everything here is downstream of two specific, named ways the day goes wrong.
A feature that serves neither is probably not for this app.

**1. Long work never gets a session.** A strategy document, a set of
performance reviews — work that needs several sittings across weeks. It loses
every single day to whatever is in the calendar, because a Commitment is
concrete and a deadline three weeks out scores nothing. Then the deadline is
close and there is no time left. Nothing in a calendar or a task manager
represents work that needs *repeated* attention, so nothing in them can raise
it before it is too late.

**2. The overdue task that is quietly becoming expensive.** Postponed enough
times that it stopped registering. Most old tasks really are dead, and burying
them is correct. Some are accumulating damage, and burying them is the worst
thing the app could do. Neither the calendar nor the task manager knows which
is which, because neither knows what it costs you to miss it.

Both failures share a cause: **the deciding information is not in the
connected tools.** No amount of ranking work on calendar and Todoist data
reaches either one. The information has to enter the system from somewhere
else.

## Right here

Location is the long-term answer and not the first one. Before GPS, the
calendar already knows the shape of your time: whether you are between
back-to-back meetings or have a clear afternoon. **The size of your next gap
is a better proxy for "what can I actually do here" than coordinates are**, it
needs no permission, and it is arithmetic over data the app already fetches.

Physical location adds feasibility on top of that — hiding what you cannot do
where you are. It does not replace it.

## Right now

The Daily Agenda is ranked once, in the morning, and snapshotted. **Right Now**
is a cheap deterministic re-score of that same set against the current hour:
finished Commitments drop out, the remaining day shrinks what is plausible, and
the gap before the next Commitment decides what is even worth starting.

It is derived, not a second Briefing Run. See
[ADR-0009](adr/0009-right-now-is-a-derived-view.md).

## What Matters

Your intent enters the app as prose you write, in one file you own, outside the
app. What you are working toward. Who matters. What breaks if you drop a thing.

It is prose because a form you have to fill in is a form you stop filling in.
The app reads it, extracts what it needs, and remembers — see
[ADR-0008](adr/0008-what-matters-is-prose-with-a-cached-extraction.md).

## How we will know it works

Ranking accuracy is not the test. Agreeing with your own drag-to-reorder only
proves the app agrees with you about the list it already showed you.

**The test is one question, once a week:** did the work you were avoiding get
done? The replay harness measures ranking agreement alongside it, but it is the
supporting number, not the headline.

## What it refuses to do

Deliberate omissions. Each has a stated trigger to revisit, and none of them is
"someone asked".

- **Background location.** Not until the gap-shaped version of "right here" has
  proved insufficient. It is the most expensive permission in the project.
  Revisit when you can name a real day where knowing your position would have
  changed the top of the list.
- **A lock screen that updates through the day.** The Focus Pull carries the
  morning ranking. Moving it onto Right Now means a notification updated all
  day, which is new background work and a new fight with Doze. This is the
  endgame, not version one.
- **Writing to Todoist or the calendar.** The app reads its sources and never
  changes them. It records its own data — Briefing Runs, Sessions, feedback —
  in its own database.
- **Being a task manager.** Todoist is where you decide what to do. This app
  is where you find out what to do *next*.
- **Multi-user, a backend, or a Play Store release.** Several decisions —
  notably [ADR-0002](adr/0002-exact-alarm-and-foreground-service.md) — are
  valid only because none of these is ever coming.
