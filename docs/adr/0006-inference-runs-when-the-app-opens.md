# Inference runs when the app opens, not during the Briefing Run

The morning Briefing Run fetches, ranks deterministically, and posts the
notification. **No model runs in the background.** When the app is opened, the
model re-ranks the Daily Agenda and writes its framing, in the foreground,
where a short spinner is acceptable.

The original design put inference inside the `dataSync` foreground service at
wake time. That made the whole morning path depend on the one genuinely
undocumented assumption in this project — whether an on-device engine can run
inside a background isolate at all — and added roughly ten seconds of engine
cold start to a job that otherwise takes about five.

Since the Focus Pull already shows **verbatim** Agenda Item titles
(ADR-0003's reasoning: the lock screen is the worst place for a
hallucination), the notification's facts are produced by deterministic code
regardless. Only the generated framing line depended on background inference.

## Consequences

**The lock-screen notification loses its generated framing line.** It shows
the top two titles and their times, and nothing else written by a model. This
is the price of the simplification and the thing to re-examine first if the
result feels flat.

The model's ranking is not what the notification reflects. The notification
shows the *deterministic* top two; opening the app may reorder them. If that
proves jarring, the fix is to persist the model's ranking from the previous
open and use it to seed the next morning — not to move inference back.

Spike 0.1 stops being a blocker. Whether inference runs in a background
isolate no longer gates anything, because it no longer happens there. The
spike is retained as optional, since the answer matters again if the framing
line is ever restored.

The Briefing Run still needs its foreground service: network during Doze is
required for fetching, independent of inference.
