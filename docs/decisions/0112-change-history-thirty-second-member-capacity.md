# ADR 0112: Change history admits its thirty-second bounded member

- Date: 2026-09-10
- Status: accepted under `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.10`; director approval granted
- Tags: documentation, history, rollover, routing, capacity, continuity, doctrine

## Routing-limit authorization

- Routed surface: `change_history`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":31,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":32,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`

## Routing-contract authorization

- Routed surface: `change_history`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":17039,"max_lines":30}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":17615,"max_lines":31}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Context

Dart reading .1.36 measured a mandatory change-history rollover exceeding exactly
three controls. It restored every earlier history byte and committed a complete
concise record at `e55f7703ebc42ef6a66c385bec884b8d3692fc66`, leaving the root at
460 lines, below mandatory rollover. Intake `DART-STARTUP-READING.6` proposed one
archive member and its manifest record. The director answered “Granted”, approving
these exact limits beyond ADR0110's earlier single-member authority.

Implementation remeasures the governed rollover from clean e55f7703. Actual
source/blob/range/hash/count and complete preservation proof belong to .10 and
its Knowledge record; the historical .1.36 draft is retained as dated evidence.

## Decision

Increase only change_history max_files 31 to 32, manifest max_lines 30 to 31,
and manifest max_bytes 17,039 to 17,615. This admits exactly one additional
immutable member and its measured manifest record, with no future member reserved.
Stable responsibility remains LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3.

Keep root limits 512 lines / 65,536 bytes, segment limits 4,096 / 524,288 and
aggregate limits 55,000 / 4,194,304. Preserve owners, routes, lifecycle, verifier,
schema, ADR0069 storage authority, every prior manifest record and immutable byte.
The governed tool moves only complete clean-source suffix records. Routing that
suffix is already mandatory and cannot provide the missing count slot; rewriting
accepted history or dropping unique evidence is not a preserving alternative.
Every further increase requires new authority.

## Consequences

- Prior history remains directly queryable on the repository volume with exact Git provenance.
- Infrastructure and containment-parent closeout require the exact staged canonical receipt.
- After commit, brief clearing and clean proof, Dart .1.37 resumes required reading.
- No source-reading credit, parser repair, recovery/purge or parked-feature activation follows.

## Links

- Storage authority: `docs/decisions/0069-bounded-change-and-notes-history.md`
- Previous capacity: `docs/decisions/0110-change-history-thirty-first-member-capacity.md`
- Proposal and proof: `docs/knowledge/dart-reading-second-history-capacity-blocker.md`
- Owner: `docs/tasks/LIVE-DOCUMENT-PRESSURE-CONTAINMENT.md`, leaf .10
- Intake: `docs/tasks/DART-STARTUP-READING.md`, leaf .6
- Registry: `doctrine/readme_stability/routes.jsonl`
- Manifest: `docs/history/changes/manifest.jsonl`
