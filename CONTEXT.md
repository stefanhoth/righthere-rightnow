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
app's primary output.
_Avoid_: plan, schedule, list

**Focus Pull**:
The highest-ranked slice of the Daily Agenda — currently the top two Agenda
Items — surfaced outside the app to orient the day at a glance.

**Briefing Run**:
One complete cycle of gathering from all sources, ranking, and producing a
Daily Agenda. Happens once each morning, and on demand.
_Avoid_: sync, refresh, update

**Candidate Set**:
The bounded collection of Agenda Items a single Briefing Run considers, after
filtering and before ranking. What comes out of a Briefing Run is always a
reordering of what went in.

**Follow-up Suggestion**:
An Agenda Item inferred from a past Commitment rather than read from a source
system — work a meeting appears to have created. It exists only inside this app
and is always distinguishable from an Agenda Item that came from a source.

**Inference Engine**:
The on-device model behind a narrow interface: given a prompt, it returns
text. Starts as Gemini Nano; every caller goes through the interface so the
concrete engine can change without touching them.
_Avoid_: model, LLM (unless specifically discussing the underlying model)
