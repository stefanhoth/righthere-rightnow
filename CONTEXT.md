# RightHere RightNow

A personal morning briefing. It gathers what the day demands from several
sources, and presents one ranked list. You then start the day without checking
a handful of separate tools.

## Language

**Agenda Item**:
A single thing that competes for attention today. The atomic unit of the app.
Every Agenda Item is either a Commitment or a Task.
_Avoid_: entry, thing, todo

**Commitment**:
An Agenda Item that is fixed in time and involves other people, derived from a
calendar. It has a start and an end that you cannot move unilaterally.
_Avoid_: meeting, appointment

**Task**:
An Agenda Item that you must do, but that is not fixed to a point in time,
derived from a task manager. It may have a due date, which is a constraint
rather than a schedule.
_Avoid_: todo, item, ticket

**Event**:
A calendar entry as it exists in the source system, before it becomes a
Commitment. Never use it to mean a Task.

**Daily Agenda**:
The ordered list of Agenda Items for one day, ranked most important first. The
app's primary output. The app derives Right Now from it.
_Avoid_: plan, schedule, list

**Right Now**:
The Daily Agenda re-scored against the current hour. It is what deserves
attention in the time available before the next Commitment. Derived from a
Daily Agenda. The app never produces it on its own.
_Avoid_: current view, live agenda

**Focus Pull**:
The highest-ranked slice of the Daily Agenda, currently the top two Agenda
Items. Shown outside the app, to orient the day at a glance.

**Briefing Run**:
One complete cycle of gathering from all sources, ranking, and producing a
Daily Agenda. It happens once each morning, and on demand. A Right Now
re-score is not a Briefing Run. It produces no new gathering, ranking or
snapshot.
_Avoid_: sync, refresh, update

**Candidate Set**:
The bounded collection of Agenda Items that a single Briefing Run considers,
after filtering and before ranking. A Briefing Run always returns a reordering
of what it received.

**What Matters**:
What the user works toward. The user states it as prose, in a document they own
outside the app. The only input to ranking that no source system can supply.
_Avoid_: priorities, intent, goals, context

**Project**:
Work that needs several Sessions before a deadline, and that no source system
represents. The user declares it in What Matters. A Todoist project is a
different thing. Always call it a `todoistProject`.
_Avoid_: initiative, endeavour, epic

**Session**:
One occasion of work on a Project. Counted from a matching calendar block, or
recorded in the app when there was no block.
_Avoid_: work block, sitting, focus time

**Pace**:
Whether a Project is on track. The app measures Sessions done against Sessions
needed and the days remaining. A Project behind Pace is the reason it enters a
Daily Agenda.

**Follow-up Suggestion**:
An Agenda Item inferred from a past Commitment, rather than read from a source
system. Work that a meeting appears to have created. It exists only inside this
app. You can always distinguish it from an Agenda Item that came from a source.

**Inference Engine**:
The on-device model behind a narrow interface: given a prompt, it returns
text. It starts as Gemini Nano. Every caller uses the interface, so the
concrete engine can change with no change to any caller.
_Avoid_: model, LLM (unless specifically discussing the underlying model)
