# ADR 0115: Finite history capacity for the remaining Julia reading plan

- Date: 2026-09-11
- Status: accepted under `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.12`; explicit director approval
- Tags: documentation, history, capacity, continuity, verification

## Context and authorization

The director explicitly answered **YES** to the six limits and .12-only focused
exception. The committed proposal at `107170da748f7f89d9cbdb26d4a6df888a067077`
contains the measured capacity need, preservation alternatives and both models:
`docs/knowledge/julia-reading-history-capacity-proposal.md`.

## Exact reviewed transitions

### change_history

- Routed surface: `change_history`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":32,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":36,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":17615,"max_lines":31}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":19919,"max_lines":35}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

### engineering_notes

- Routed surface: `engineering_notes`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":28,"max_lines_per_file":4096,"max_total_bytes":3145728,"max_total_lines":27000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":32,"max_lines_per_file":4096,"max_total_bytes":3145728,"max_total_lines":27000}`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":16384,"max_lines":27}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":18678,"max_lines":31}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Decision

Admit four additional archive slots per collection:
change_history files 32→36, manifest lines 31→35 and bytes 17,615→19,919;
engineering_notes files 28→32, manifest lines 27→31 and bytes 16,384→18,678.
Only these six registry scalars change.

Root limits remain 512 lines /65,536 bytes; segment limits remain 4,096 lines /
524,288 bytes. Change-history aggregates remain 55,000 lines /4,194,304 bytes;
engineering-note aggregates remain 27,000 lines /3,145,728 bytes.
Stable storage responsibility remains `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3`.
Owners, routes, lifecycle, schema, verifier, debt metadata, every other surface
and all previous immutable bytes remain unchanged.

The finite envelope is 55 future records of 14 lines /2,048 bytes, including
49 remaining Julia reading children and bounded capacity/closeout allowances.
It includes the proposal and this admission; it grants no runtime-repair, Lua
or unlimited future history budget. This is a conservative forecast, not an
instruction to compress or discard unique evidence. Each actual leaf is measured.
The two models agree on four rollovers per surface and a worst-case engineering
aggregate of 26,976 lines, leaving 24 lines below its unchanged ceiling.

## Proportionate governance

During this admission the director clarified that rules are necessary to prevent
disorder, and that size-containment policies must also support feature and product
implementation. Apply them with engineering judgment: measure the need, retain
clear ownership and evidence, and choose bounded adjustments with proportionate
checks. Plan capacity across a coherent activity to avoid repeated administrative
interruptions. Preserve useful safeguards and continuity as the activity grows.

This admission applies that principle through a forecast for the remaining Julia
reading work and six exact controls. Future work should carry this principle into
its own measured plan; the concrete allowance and verification exception granted
here retain their stated scope.

## One-time verification exception

The director's YES explicitly authorizes focused validation for containment .12
without the canonical CI receipt. Run exact six-scalar and source/history
preservation proof, actual-validator threshold and authorization mutations,
all nine normal doctrines, both history checks, Knowledge synchronization,
memory checks and rendered mdBook verification. Normal hooks remain enabled.

This exception applies only to .12. It changes no standing gate or policy and
grants no later canonical or push waiver. No canonical CI or PGEN/RGX build is
claimed. The build-on-submodule-update requirement remains separately owned by
`SESSION-STARTUP-READING.80`; no dependency or CI implementation changes here.

## Consequences

- Apply a governed rollover only where the complete candidate requires one.
  Preserve clean source coordinates, blob identity, counts, hashes and query order.
- Close the Julia .4 capacity parent after verified implementation; retain its
  .4.1 proposal as dated evidence.
- Commit, clear the brief and verify the clean boundary before Julia .1.4.
- Every existing parser defect and remaining startup prerequisite remains open.

## Links

- Owner: `docs/tasks/LIVE-DOCUMENT-PRESSURE-CONTAINMENT.md`, leaf .12
- Intake: `docs/tasks/JULIA-STARTUP-READING.md`, parent .4 and leaf .4.1
- Storage authority: `docs/decisions/0069-bounded-change-and-notes-history.md`
- Previous capacities: ADR0112 and ADR0113
- Implementation proof: `docs/knowledge/julia-reading-history-capacity-admission.md`
