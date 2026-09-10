# ADR 0111: Engineering-notes history admits its twenty-seventh bounded member

- Date: 2026-09-10
- Status: accepted under `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.9`; director approval granted
- Tags: documentation, history, rollover, routing, capacity, continuity, doctrine

## Routing-limit authorization

- Routed surface: `engineering_notes`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":26,"max_lines_per_file":4096,"max_total_bytes":3145728,"max_total_lines":27000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":27,"max_lines_per_file":4096,"max_total_bytes":3145728,"max_total_lines":27000}`

## Routing-contract authorization

- Routed surface: `engineering_notes`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":16384,"max_lines":25}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":16384,"max_lines":26}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Context

Dart reading .1.24 measured a mandatory engineering-history rollover that exceeded
exactly two count limits. It preserved every earlier byte and committed a concise
new summary at `4d5af8e9669b2204db1d394ee0ab01ce190ee1c9`, leaving 50 bytes below
mandatory rollover. Intake `DART-STARTUP-READING.5` proposed one archive slot and one
manifest line. The director answered “ok for increasing the allowance”, authorizing
these exact two controls beyond ADR0109's prior exception and ADR0110's separate
change-history scope.

This implementation remeasures the governed rollover from clean 4d5af8e9.
Actual source/blob/range/hash/count and complete-history preservation evidence
belong to .9 and the linked Knowledge record before landing. The historical .1.24
draft remains reproducible; its coordinates do not substitute for current evidence.

## Decision

Increase only engineering_notes max_files 26 to 27 and its manifest max_lines
25 to 26. Preserve manifest max_bytes 16,384; root 512 lines / 65,536 bytes;
segment 4,096 lines / 524,288 bytes; aggregate 27,000 lines / 3,145,728 bytes.
Stable responsibility remains LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3.

Keep owners, routes, lifecycle, verifier, schema and ADR0069 storage authority.
The governed tool moves only complete clean-source suffix records; every prior
manifest record and immutable byte remains exact. Routing the old suffix is
already required and cannot supply the missing count slot; rewriting accepted
history or dropping unique evidence is not a preserving alternative.

This admits one additional member only. Any further limit increase requires a
new decision; no parser repair, recovery/purge or parked feature is activated.

## Consequences

- Exact prior history stays queryable from repository-relative paths on its volume.
- .9 requires independent focused proof and the exact staged canonical receipt.
- After commit, brief clearing and clean proof, Dart .1.25 resumes required reading.
- All remaining startup prerequisites and pending defect owners remain in force.

## Links

- Storage authority: `docs/decisions/0069-bounded-change-and-notes-history.md`
- Previous capacity: `docs/decisions/0107-engineering-notes-twenty-sixth-member-capacity.md`
- Proposal and proof: `docs/knowledge/dart-reading-engineering-history-capacity-blocker.md`
- Owner: `docs/tasks/LIVE-DOCUMENT-PRESSURE-CONTAINMENT.md`, leaf .9
- Intake: `docs/tasks/DART-STARTUP-READING.md`, leaf .5
- Registry: `doctrine/readme_stability/routes.jsonl`
- Manifest: `docs/history/development-notes/manifest.jsonl`
