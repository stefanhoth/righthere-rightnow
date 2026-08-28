# Milestone 0 — Spikes

Two assumptions are undocumented and could invalidate later work. Resolve both
before building on them. Spike code is throwaway — put it behind a debug screen
or a scratch branch, and do not let it set architectural precedent.

Neither spike blocks anything. Task 0.2 is worth five minutes before Milestone
1; Task 0.1 is now optional.

---

## Task 0.1 — Can inference run inside the foreground-service isolate?

> **No longer a blocker.**
> [ADR-0006](../adr/0006-inference-runs-when-the-app-opens.md) moved inference
> out of the background entirely — the model now runs at app-open, in the
> foreground. This spike only matters again if the notification's generated
> framing line is ever restored. Skip it unless that comes back.

**Why it mattered:** ADR-0004 originally assumed Gemini Nano could be invoked
from the background isolate that `flutter_foreground_task` runs inside a
foreground service. The ML Kit path is platform-channel based and needs a live
Flutter engine. No documentation confirms this works. If it does not, ADR-0004
flips to LiteRT-LM (pure `dart:ffi`, which should run in any isolate) and the
model becomes a ~0.5–2.6 GB runtime download.

**Steps**

1. Add `flutter_gemma` + `flutter_gemma_builtin_ai` (^0.2.0). Note
   `flutter_gemma` alone registers no engine and will throw at runtime.
2. Set `minSdkVersion 30` in `android/app/build.gradle.kts`. Nano needs only 26,
   but 30 keeps the LiteRT-LM fallback viable at no cost on a Pixel 9.
3. Add `ndk { abiFilters += listOf("arm64-v8a") }` — required if LiteRT-LM is
   ever used, harmless now.
4. Add `flutter_foreground_task` ^11.0.1. Start a `dataSync` foreground service
   from a debug button.
5. Inside the service's isolate, call `BuiltInAi.availability()`, then run one
   trivial prompt ("Reply with the word OK").
6. Log the result, the elapsed time, and any exception.

**Acceptance criteria**

- A written finding in this file's "Result" section below: does it work, how
  long did cold start take, what failed.
- If it fails, the exception and its message are recorded verbatim.

**Result** (release build, Pixel 9, Android 17 / SDK 37, 2026-08-28):

The isolate question is moot — [ADR-0006](../adr/0006-inference-runs-when-the-app-opens.md)
moved inference to app-open in the foreground. This section now records what an
engine does on the device.

*The engine runs, and the model ranked.* A Briefing Run on the device recorded
`rankedBy == model` — the Daily Agenda status line read "Ranked by the model",
confirmed by screenshot. The completion took **10.85 s** (3371 input tokens,
57 output tokens). The order was visibly the model's, not the fallback ranker's:
the block of 22-day-overdue items was gone from the top, replaced by near-due
work. Two earlier completions during the same session measured **8.76 s** and
**16.4 s**.

Five defects had to be cleared first, every one found on the device rather than
reasoned about:

1. **R8 stripped a reflectively-instantiated ML Kit constructor**, so the engine
   was never reachable. Fixed by the keep rule in PR #38 (merged).
2. **Two inferences raced on one native session.** Re-ranking and framing-line
   generation both called `createSession()`, each closing the other's session;
   the first failed with `Bad state: Session is closed`. Fixed by serialising
   `complete()` in the engine (PR #41).
3. **`maxOutputTokens` ceiling of 256.** ML Kit's GenAI Prompt API applies 256
   when none is passed and throws on any bound above it
   (`maxOutputTokens must be between 1 and 256`). A JSON array of 25 Agenda Item
   ids runs 250–300 tokens and was truncated mid-array on every run since
   PR #28, so `validateModelRanking` discarded it and the fallback ranker ran
   silently.
4. **Item numbers instead of ids.** The model now answers with a per-item
   number; the same run came back at 57 tokens, well inside 256 (PR #42).
5. **The renumbering did not reach the device.** The prompt is versioned data
   seeded once into Drift (ADR-0003), so the Pixel kept running the v1 text
   that asked for ids. The output-format contract is a contract with the
   validator, not a tuning knob, so it moved into `buildRankingPrompt` in code
   (PR #42).

Also recorded on the device: **`BACKGROUND_USE_BLOCKED` (ErrorCode 30)** —
Nano via ML Kit GenAI refuses to run unless the app is in the foreground. This
makes [ADR-0006](../adr/0006-inference-runs-when-the-app-opens.md) a hard
constraint of the engine, not a design preference: inference inside the morning
Briefing Run is impossible on Nano.

*Caveats.*

- The enabling code is the `fix/serialize-inference` → #45 stack (PRs #41–#45,
  from local branch `claude/ranking-output-budget`), not yet merged. Glance at a
  `main` release run once they land; the result above stands regardless.
- Working is not the same as good. In the confirmed run the model buried the two
  items that looked most consequential and floated a low-stakes one. Ranking
  *quality* is what Milestone 4's later tasks and What Matters address; this
  spike only asked whether the model runs and ranks at all, and it does.

---

## Task 0.2 — Where do Google Meet links actually live on-device?

**Why this matters:** ADR-0001 accepts regex-scraping conference links out of
the event description, because the Android Calendar Provider has no
conference-link column. But Google's sync adapter is closed source and may write
the link somewhere structured. Five minutes of looking could replace a regex
with a real field.

**Steps**

1. Create a calendar event with a Google Meet link; let it sync to the Pixel.
2. From a debug screen, query and dump for that event:
   - `CalendarContract.ExtendedProperties` — all `NAME`/`VALUE` pairs for the
     event id. (Writes are gated behind sync-adapter status; **reads are not**.)
   - `Events.CUSTOM_APP_PACKAGE` and `Events.CUSTOM_APP_URI`.
   - `Events.DESCRIPTION` in full.
3. Record whether the Meet URL appears anywhere other than the description.

**Acceptance criteria**

- The dump is recorded in the "Result" section below.
- A decision is stated: structured field (name it) or regex over description.

**Result:** _(not yet run)_
