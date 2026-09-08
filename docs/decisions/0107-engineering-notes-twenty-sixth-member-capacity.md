# ADR 0107: Engineering-notes history admits its twenty-sixth bounded member

- Date: 2026-09-08
- Status: accepted under `SESSION-STARTUP-READING.3.3.61`
- Tags: documentation, history, rollover, routing, pressure, continuity, doctrine

## Routing-limit authorization

- Routed surface: `engineering_notes`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":25,"max_lines_per_file":4096,"max_total_bytes":3145728,"max_total_lines":27000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":26,"max_lines_per_file":4096,"max_total_bytes":3145728,"max_total_lines":27000}`

## Routing-contract authorization

- Routed surface: `engineering_notes`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":16384,"max_lines":24}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":16384,"max_lines":25}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Context

The scheduled startup checkpoint takes engineering notes from 459 to 463 lines, crossing the unchanged
90% rollover threshold. The governed tool archives exact clean activation
`165b74dc88cdb86c433807b0a692893a4e3998d6` lines 213–459 as segment `4982`:
247 lines / 25,964 bytes, SHA-256 `0cca6b887182b2d3abbd731a906726d05df4ab9916262d29dcef754f5d895b16`.
Independent comparison binds source blob `0aaead6dbca71b3da6a9992f8bc19096f844dd91`,
every prior manifest record byte-for-byte in order, and the retained source prefix plus this leaf's one new record.

The rollover yields 216 lines / 32,428 bytes; removing one final blank separator for Git whitespace hygiene
leaves 215 lines / 32,427 bytes. Immutable archive bytes are untouched. The manifest is 25 lines / 15,006 bytes.
Twenty-four immutable segments plus the current root and manifest require 26 files. The collection totals
25,619 lines / 2,748,212 bytes. The pressure checker identifies files 26/25 and manifest lines 25/24 under
the old controls; its separate stale Knowledge Map report is resolved by normal derived-index generation.

All byte ceilings and all root/per-segment/aggregate line ceilings have capacity. The required complete-record
rollover already moves older material out of the current root; deleting or rewriting accepted immutable history
cannot supply the missing count slots while preserving ADR 0069.

## Decision

Increase only `engineering_notes.limits.max_files` from 25 to 26 and manifest `max_lines` from 24 to 25.
Preserve root limits 512 lines / 65,536 bytes, segment limits 4,096 lines / 524,288 bytes, manifest byte
limit 16,384, aggregate limits 27,000 lines / 3,145,728 bytes, member patterns, owner, lifecycle, verifier
and ADR 0069 storage authority. This is one finite slot for this mandatory archive, with no baseline refresh
or authorization for a later increase.

## Consequences

- Exact current and prior history remain repository-local and queryable.
- No previous segment or manifest record changes.
- This storage-registry boundary requires receipt-bound canonical proof for the exact staged candidate.
- Reading, policy alignment and product repairs remain separately owned; parser behavior is unchanged.

## Links

- Store authority: `docs/decisions/0069-bounded-change-and-notes-history.md`
- Previous capacity: `docs/decisions/0105-engineering-notes-twenty-fifth-member-capacity.md`
- Owning task: `docs/tasks/SESSION-STARTUP-READING.md`
- Route registry: `doctrine/readme_stability/routes.jsonl`
- Manifest: `docs/history/development-notes/manifest.jsonl`
