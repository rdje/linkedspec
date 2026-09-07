# ADR 0105: Engineering-notes history admits its twenty-fifth bounded member

- Date: 2026-09-07
- Status: accepted under `SESSION-STARTUP-READING.3.3.12`
- Tags: documentation, history, rollover, routing, pressure, continuity, doctrine

## Routing-limit authorization

- Routed surface: `engineering_notes`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":24,"max_lines_per_file":4096,"max_total_bytes":3145728,"max_total_lines":27000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":25,"max_lines_per_file":4096,"max_total_bytes":3145728,"max_total_lines":27000}`

## Routing-contract authorization

- Routed surface: `engineering_notes`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":16384,"max_lines":23}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":16384,"max_lines":24}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Context

The required startup checkpoint takes the engineering-notes hot shard from 458 to 462 lines, crossing
its 90% rollover threshold. The governed rollover archives clean activation source
`75ce8db839888a5091d25ee4e5e1c3c501daf3b8` lines 253–458 as immutable segment `4983`:
206 lines / 17,316 bytes, SHA-256 `274cdb2ddc2b6672965d365d2cb98b0f7800db1e84f491bb2ec4436c2d98a6d1`.
Independent comparison proves exact clean-source bytes and blob
`20a8202bafbcdb83a06be8c956fdafea33c18060`, unchanged prior manifest records, and the retained source prefix
plus only this checkpoint's new current record.

The retained hot-shard EOF separator is trimmed by one newline for the whitespace gate; the immutable
segment and all prior records remain exact. After updating the current record and that separator, the root is 255/512 lines and
26,100/65,536 bytes. The manifest contains 24 lines and
14,394/16,384 bytes; 23 immutable segments plus root and manifest require 25 files.
The collection totals 25,411/27,000 lines and 2,715,309/3,145,728 bytes.
The pressure checker independently fails only the old 24-file and 23-manifest-line controls.

Every current-root, per-segment, manifest-byte, and aggregate control has capacity. Complete older records
have already moved out of the current view; removing or rewriting accepted immutable history cannot provide
the missing count slots while preserving ADR 0069.

## Decision

Admit only `engineering_notes.limits.max_files` 24 to 25 and manifest `max_lines` 23 to 24. Preserve all byte
ceilings, root/per-segment/aggregate line ceilings, member patterns, owner, lifecycle, verifier, and ADR 0069
storage authority. This is one finite storage step for the mandatory complete-record rollover, with a newly
indexed exact-limit decision; it does not refresh a baseline or authorize another increase.

## Consequences

- Required continuity and all accepted history remain queryable on the repository volume.
- No prior immutable segment changes, and the current view meets both retained-root targets.
- Registry infrastructure requires receipt-bound canonical proof for this exact staged checkpoint.
- Product repairs and remaining codebase reading/formal mdBook alignment remain separately owned.

## Links

- Store authority: `docs/decisions/0069-bounded-change-and-notes-history.md`
- Previous capacity: `docs/decisions/0103-engineering-notes-twenty-fourth-member-capacity.md`
- Owning task: `docs/tasks/SESSION-STARTUP-READING.md`
- Route registry: `doctrine/readme_stability/routes.jsonl`
- Manifest: `docs/history/development-notes/manifest.jsonl`
