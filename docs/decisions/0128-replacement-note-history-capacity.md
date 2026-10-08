# ADR 0128: Finite engineering-note capacity before selected replacement repair

- Date: 2026-10-08
- Status: accepted engineering maintenance decision under `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2`; exact canonical admission required
- Tags: documentation, history, capacity, continuity, verification

## Routing-limit authorization

- Routed surface: `engineering_notes`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":44,"max_lines_per_file":4096,"max_total_bytes":3407872,"max_total_lines":29000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":45,"max_lines_per_file":4096,"max_total_bytes":3407872,"max_total_lines":29000}`

## Routing-contract authorization

- Routed surface: `engineering_notes`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":26021,"max_lines":43}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":26633,"max_lines":44}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Decision-collection prerequisite authorization

- Routed surface: `decisions`
- Previous routed limits: `{"max_bytes_per_file":65536,"max_files":128,"max_lines_per_file":640,"max_total_bytes":2097152,"max_total_lines":13000}`
- New routed limits: `{"max_bytes_per_file":65536,"max_files":129,"max_lines_per_file":640,"max_total_bytes":2097152,"max_total_lines":13043}`

## Context

The full initial resulting-tree guard rejects this new decision at collection files129/128 and aggregate lines13035/13000. All prior accepted decision records are immutable. Removing an accepted record or omitting the required new indexed decision cannot meet the policy. Admit only this one additional decision file and its measured final aggregate-line allowance, with all other decision limits, ownership, lifecycle, verifier and bytes unchanged. The complete initial staged graph/delta and actual guarded RED remain retained, including the initial claim and its previously omitted continuity guard inputs.

The clean engineering-note root is 58,977 bytes. Its next complete maintenance record crosses the unchanged 90% rollover boundary. The existing 44-file history and 43-line/26,021-byte manifest controls are full. The root already routes to the canonical owner; shortening unrelated records or rewriting, deleting or repacking accepted history cannot meet ADR0069. README_POLICY requires a new exact indexed decision rather than a threshold change inside an ordinary feature leaf.

The current full-PNT instruction delegates routine engineering decisions and requires continued maintenance and per-leaf commits. This separately owned canonical infrastructure leaf makes the finite decision under that authority. Earlier finite director grants are not reused, and no new explicit director grant is asserted.

## Decision

Admit only files 44→45, manifest lines 43→44 and manifest bytes 26,021→26,633. Preserve every other engineering-note control and prior immutable byte; the two finite decision-store controls are separately authorized above. Stable responsibility remains LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3 under ADR0069.

The actual governed rollover retains clean 47444428a8ceb65cb0ced06625db4eb8a44b8209 lines 155–256, blob 9d5f65cb3cc1db7e3fb1ae2aaaf237f47381c453, as 102 lines/27,567 bytes under SHA-256 3def29fef6d27a7c86b97adf15917fc3e0d030ee14f50f45c6b3f3d03a910c40. The retained root is 157 lines/31,811 bytes; the resulting collection is 45 files/28,934 lines/3,225,109 bytes. The unchanged root, per-file and aggregate budgets fit. Independent reconstruction, actual threshold and authority denials, full retained command channels and exact staged canonical proof govern admission.

## Consequences

One archive member, one exact manifest row and one additional decision file are admitted under five exact scalar changes. This does not grant unlimited PNT reserve or future threshold changes. Existing history stays queryable and immutable; parser behavior, public teaching, tests, dependencies, hooks and checker implementations stay unchanged. Private occurrence handoff .3.1.0 resumes from the clean admitted commit.

## Links

- Policy: README_POLICY.md; docs/decisions/0069-bounded-change-and-notes-history.md
- Previous finite decision: docs/decisions/0127-legacy-diagnosis-note-capacity.md
- Owner: docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md
- Exact plan and actual channels: docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2-capacity-plan.json and docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2-capacity-actual.json
