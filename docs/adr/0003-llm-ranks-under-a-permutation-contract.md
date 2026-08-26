# The model ranks, but may only return a permutation of item IDs

Ranking Agenda Items is genuinely fuzzy — "what matters today" resists being
enumerated as rules — so the model does it, and the ranking is improved by
refining the prompt over time rather than by adding branches to a rule engine.

The model's **output** is nonetheless constrained to an ordered list of Agenda
Item IDs: a permutation of the candidate set it was given. It receives the full
candidate set with all features attached, so it reasons over rich data; it just
may not author any. A permutation is verifiable in one line — every returned ID
known, every supplied ID present — whereas structured Agenda Items emitted by
the model could carry an invented due date that no validation would catch.

This matters because no on-device engine available here offers constrained
decoding; schema-conforming output cannot be guaranteed, only checked.

## Consequences

A deterministic fallback ranker must exist. Unknown IDs are dropped, missing IDs
appended in fallback order, and unusable output discards the model's ranking
entirely. The app therefore always produces a Daily Agenda, and the fallback
ranker — not the model — is the first milestone.

The prompt is stored as versioned data, not a code constant, and every Briefing
Run records the prompt version, its candidate set, and the resulting order. This
makes a prompt change testable by replaying stored history instead of waiting a
day per experiment.

Feedback is captured as drag-to-reorder, because a corrected order is the same
shape as the model's output and is therefore directly usable both as ground
truth for replay and as a few-shot example.
