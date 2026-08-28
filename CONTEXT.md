# Right Here, Right Now

A personal morning briefing. It gathers what the day demands from several
sources and presents one ranked list, so the day can start without checking a
handful of separate tools.

## Language

**Agenda Item**:
A single thing competing for attention today. The atomic unit of the app.
Every Agenda Item is either a Commitment or a Task.
_Avoid_: entry, thing, todo

**Commitment**:
An Agenda Item that is fixed in time and involves other people — derived from a
calendar. Has a start and an end that cannot be moved unilaterally.
_Avoid_: meeting, appointment

**Task**:
An Agenda Item that needs doing but is not fixed to a point in time — derived
from a task manager. May have a due date, which is a constraint rather than a
schedule.
_Avoid_: todo, item, ticket

**Event**:
A calendar entry as it exists in the source system, before it becomes a
Commitment. Never used to mean a Task.

**Daily Agenda**:
The ordered list of Agenda Items for one day, ranked most important first. The
app's primary output, and the thing Right Now is derived from.
_Avoid_: plan, schedule, list

**Right Now**:
The Daily Agenda re-scored against the current hour — what deserves attention
in the time actually available before the next Commitment. Derived from a
Daily Agenda, never produced independently of one.
_Avoid_: current view, live agenda

**Focus Pull**:
The highest-ranked slice of the Daily Agenda — currently the top two Agenda
Items — surfaced outside the app to orient the day at a glance.

**Briefing Run**:
One complete cycle of gathering from all sources, ranking, and producing a
Daily Agenda. Happens once each morning, and on demand. A Right Now re-score
is not a Briefing Run — it produces no new gathering, ranking or snapshot.
_Avoid_: sync, refresh, update

**Candidate Set**:
The bounded collection of Agenda Items a single Briefing Run considers, after
filtering and before ranking. What comes out of a Briefing Run is always a
reordering of what went in.

**What Matters**:
What the user is working toward, stated by the user as prose in a document they
own outside the app. The only input to ranking that no source system can
supply.
_Avoid_: priorities, intent, goals, context

**Project**:
Work that needs several Sessions before a deadline, and that no source system
represents. Declared in What Matters. A Todoist project is a different thing
and is always called a `todoistProject`.
_Avoid_: initiative, endeavour, epic

**Session**:
One occasion of working on a Project. Counted from a matching calendar block,
or recorded in the app when there was no block.
_Avoid_: work block, sitting, focus time

**Pace**:
Whether a Project is on track — Sessions done, measured against Sessions needed
and the days remaining. A Project behind Pace is the reason it enters a Daily
Agenda.

**Follow-up Suggestion**:
An Agenda Item inferred from a past Commitment rather than read from a source
system — work a meeting appears to have created. It exists only inside this app
and is always distinguishable from an Agenda Item that came from a source.

**Inference Engine**:
The on-device model behind a narrow interface: given a prompt, it returns
text. Starts as Gemini Nano; every caller goes through the interface so the
concrete engine can change without touching them.
_Avoid_: model, LLM (unless specifically discussing the underlying model)
