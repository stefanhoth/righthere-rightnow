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

**Result:** _(not yet run)_

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
