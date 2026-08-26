# Read calendars via the Android Calendar Provider, not the Google Calendar API

Commitments are read from the Android system Calendar Provider (via
`device_calendar_plus`), not from the Google Calendar REST API. The app is
single-user and sideloaded, so the provider route removes the entire OAuth
surface — no Cloud project, no client IDs, no per-variant SHA-1 fingerprints, no
consent screen, no token storage — while reading every account already synced on
the device through one code path, with recurrences pre-expanded by the OS.

## Consequences

The Calendar Provider has **no conference-link column**. Google Meet URLs arrive
only as plain text inside the event description, so links are extracted with a
regex (see ADR-0005). The REST API's structured `conferenceData` is the single
capability given up, and it is not worth reintroducing OAuth for.

`device_calendar_plus` does not project `Events.SELF_ATTENDEE_STATUS`,
`IS_ORGANIZER` or `ORGANIZER`, so "did I decline this?" and "did I organise
this?" are unanswerable through it — both of which the ranking needs. Since the
provider's `Instances` projection map is a copy of the `Events` one, all three
columns are queryable on the same `Instances` URI, and a small platform channel
supplies them, joined in Dart on `(eventId, begin)` — the plugin's `instanceId`.

`eventide` was rejected: it queries raw `Events` rather than `Instances`, so
recurring events are never expanded and are likely dropped entirely.
`device_calendar` was rejected as unmaintained.
