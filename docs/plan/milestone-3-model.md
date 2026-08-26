# Milestone 3 — The model ranks and phrases

**Outcome:** Gemini Nano orders the Candidate Set and writes one framing line;
drag-to-reorder captures corrections; a replay harness makes prompt changes
testable against stored history.

Read [ADR-0003](../adr/0003-llm-ranks-under-a-permutation-contract.md) and
[ADR-0004](../adr/0004-gemini-nano-behind-an-engine-interface.md) first.
**Do not start before Spike 0.1 has a recorded result** — if inference cannot
run in the foreground-service isolate, the engine choice changes.

---

## Task 3.1 — Engine interface

Define a narrow interface and keep every caller behind it:

```dart
abstract class InferenceEngine {
  Future<bool> isAvailable();
  Future<String> complete(String prompt, {Duration timeout});
}
```

Implement `BuiltInAiEngine` over `flutter_gemma` + `flutter_gemma_builtin_ai`
(^0.2.0). `flutter_gemma` alone registers no engine and throws.

ML Kit GenAI is **Beta** with no SLA. The interface is what makes switching to
LiteRT-LM + a downloaded Gemma a configuration change. Do not let engine types
leak into `briefing/` or `domain/`.

**Acceptance criteria**

- `isAvailable()` returns false gracefully on an unsupported device rather than
  throwing.
- Every call site has a working path when `isAvailable()` is false.
- Engine cold-start time is logged (Spike 0.1 measured this; confirm it holds).

---

## Task 3.2 — Prompt as versioned data

Per ADR-0003 the prompt is **data, not a code constant**. Shipping a build per
experiment gives roughly one experiment a day, judged on a sample of one.

- Ship a default prompt; store the active prompt in Drift with a version.
- A dev screen edits it and bumps the version.
- Every Briefing Run records `promptVersion`.

**Acceptance criteria**

- Editing the prompt changes the next run's output with no rebuild.
- `briefing_runs.promptVersion` is populated on every run.
- Resetting to the shipped default is possible.

---

## Task 3.3 — Ranking under the permutation contract

**Input:** the full Candidate Set with all computed features — the model
reasons over rich data.

**Output:** an ordered list of Agenda Item IDs and nothing else.

**Validation — this is the whole point:**

1. Parse the response as a list of IDs.
2. Drop IDs not present in the Candidate Set.
3. Append missing IDs in fallback-rank order.
4. If parsing fails, or fewer than half the IDs are recognised, **discard the
   model's ranking entirely** and use the fallback.
5. Record `rankedBy` as `model` or `fallback` accordingly.

Nano exposes no native tool-calling API, so this is prompted output. Validation
is what makes that acceptable — never trust it.

Run inference with a **timeout**. If it expires, fall back. A late agenda is
worse than a deterministic one.

**Acceptance criteria**

- Unit tests for: valid permutation; hallucinated ID; missing IDs; unparseable
  output; timeout. Each asserts a sensible Daily Agenda still results.
- No input produces an empty or partial agenda.
- Fallback path is exercised in tests as thoroughly as the success path.

---

## Task 3.4 — The framing line

One generated sentence beneath the verbatim Focus Pull titles in the
notification (the Q14 answer: hybrid, facts verbatim, model adds framing).

- Titles stay verbatim. Only the framing line is generated.
- Hard length cap; truncate rather than wrap.
- If inference fails or is unavailable, **omit the line** — the notification
  still works.

**Acceptance criteria**

- Notification renders correctly with and without the framing line.
- Failure never blocks or delays the notification.

---

## Task 3.5 — Drag-to-reorder feedback

Per ADR-0003, a corrected order is the same shape as the model's output, so it
serves as both ground truth and few-shot example.

- Reorderable Daily Agenda list.
- Persist `correctedRank` alongside the existing `producedRank` — **keep both**,
  or improvement becomes unmeasurable.
- Coarse thumbs up/down per Briefing Run for days not worth reordering.

**Acceptance criteria**

- Reordering persists across restarts.
- Both the original and corrected orders are queryable for any past run.
- Reordering never mutates the underlying calendar or Todoist data.

---

## Task 3.6 — Replay harness

The payoff for snapshotting from day one: an experiment becomes edit prompt →
replay stored days → diff orderings. Seconds, judged against real history.

- Select stored Briefing Runs; re-run ranking against their persisted
  `payloadJson` using the current prompt.
- Diff produced order vs stored order vs corrected order.
- Report a simple agreement metric against corrected orders.
- **Replay must never touch the network or write a new Briefing Run.**

**Acceptance criteria**

- Replaying a stored run reproduces its original order when the prompt version
  matches (determinism check — flag it if the engine is non-deterministic).
- Replay works offline.
- Runs with no corrected order are excluded from the metric rather than scored
  as agreement.
