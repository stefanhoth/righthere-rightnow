# Start with Gemini Nano, behind an engine interface

Inference uses the OS-provided Gemini Nano (ML Kit GenAI, via
`flutter_gemma_builtin_ai`) on the target Pixel 9. The alternative — a
downloaded Gemma through `flutter_gemma_litertlm` — costs a 0.5–2.6 GB runtime
download, storage management, and for Gemma 3 a HuggingFace token and licence
acceptance flow. The model's jobs here are ordering ~20 items and writing one
framing line; neither justifies that.

ML Kit GenAI is Beta, carries no SLA or deprecation policy, and only runs on
recent Pixel and Galaxy devices. Inference is therefore placed behind an engine
interface so switching to LiteRT-LM with a downloaded Gemma is a configuration
change rather than a rewrite.

## Consequences

Gemini Nano cannot be fine-tuned — the OS owns the weights and there is no LoRA
path. Improvement comes from prompt refinement and few-shot examples only. A
downloaded Gemma does support LoRA adapters, which is a further reason to keep
the interface.

Nano exposes no native tool-calling API, so function calling through this engine
is prompt-based. This is tolerable only because of the permutation contract in
ADR-0003, which validates output rather than trusting it.

~~**Unverified, and the first thing to spike:** whether either engine runs
inside the foreground-service isolate.~~ **Superseded by
[ADR-0006](0006-inference-runs-when-the-app-opens.md):** inference no longer
runs in the background at all, so this is no longer a risk to this decision.
It becomes relevant again only if the notification's generated framing line is
ever restored.
