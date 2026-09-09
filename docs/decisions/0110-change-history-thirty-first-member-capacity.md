# ADR 0110: Change history admits its thirty-first bounded member

- Date: 2026-09-09
- Status: accepted under `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.8`; director greenlight granted
- Tags: documentation, history, rollover, routing, capacity, continuity, doctrine

## Routing-limit authorization

- Routed surface: `change_history`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":30,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":31,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`

## Routing-contract authorization

- Routed surface: `change_history`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":16463,"max_lines":29}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":17039,"max_lines":30}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Context

DART-STARTUP-READING.1.7 measured a required rollover that would exceed exactly three
collection/manifest controls. That checkpoint preserved all earlier history and committed
a concise new record within the existing limits at f8b626f0. Intake .4 recorded the exact
proposal; the director subsequently answered “Greenlighted !”. This explicitly authorizes
the additional history exception beyond ADR 0109's earlier task/Knowledge capacity scope.

The governed rollover is remeasured from clean activation
`f8b626f0c0f16fd6168aa9a4633b1179fe09acc2`. The actual source/blob/range/hash and
full-byte preservation proof are recorded in the owning task and Knowledge fact before landing.

## Decision

Admit only change_history max_files 30 to 31, manifest max_lines 29 to 30, and
manifest max_bytes 16,463 to 17,039. This is exactly one additional immutable member
and its measured manifest record, with no future member reserved.
Stable responsibility remains LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3.

Keep root limits 512 lines / 65,536 bytes, segment limits 4,096 / 524,288 and
aggregate limits 55,000 / 4,194,304. Preserve routes, lifecycle, verifier, schema,
immutable identities, all prior manifest records and ADR 0069 storage authority.
No history is deleted, shortened or rewritten; complete clean-source suffix records
move through the governed rollover tool. Every further increase requires new authority.

## Consequences

- Prior history stays directly queryable on the repository volume with exact source provenance.
- Infrastructure and containment-parent closeout require canonical proof of the exact staged candidate.
- After the canonical commit and clean handoff, Dart .1.8 resumes required source reading.
- Parser repairs, recovery/purge and parked features retain their existing gates and owners.

## Links

- Storage authority: `docs/decisions/0069-bounded-change-and-notes-history.md`
- Previous capacity: `docs/decisions/0106-change-history-thirtieth-member-capacity.md`
- Proposal: `docs/knowledge/dart-reading-history-capacity-blocker.md`
- Owner: `docs/tasks/LIVE-DOCUMENT-PRESSURE-CONTAINMENT.md`, leaf .8
- Intake: `docs/tasks/DART-STARTUP-READING.md`, leaf .4
- Registry: `doctrine/readme_stability/routes.jsonl`
- Manifest: `docs/history/changes/manifest.jsonl`
