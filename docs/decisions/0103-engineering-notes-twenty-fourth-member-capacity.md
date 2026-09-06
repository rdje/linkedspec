# ADR 0103: Engineering-notes history admits its twenty-fourth bounded member

- Date: 2026-09-06
- Status: accepted under `SESSION-STARTUP-READING.3.2.21`
- Tags: documentation, history, rollover, routing, pressure, continuity, doctrine

## Routing-limit authorization

- Routed surface: `engineering_notes`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":23,"max_lines_per_file":4096,"max_total_bytes":3145728,"max_total_lines":27000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":24,"max_lines_per_file":4096,"max_total_bytes":3145728,"max_total_lines":27000}`

## Routing-contract authorization

- Routed surface: `engineering_notes`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":16384,"max_lines":22}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":16384,"max_lines":23}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Context

The required complete startup checkpoint takes the engineering-notes hot shard from 460 to 468 lines and crosses
its 90% rollover threshold. The governed rollover archives clean activation source
`ba9a494caa79fdd6fca7833d5bfc1fbce727fc9d` lines 238–460 as immutable segment `4984`:
223 lines / 22,371 bytes, SHA-256 `dd7eba212246efd893dbff32143a2c821576c7a704e1a697265213dc728d1f9a`.
Independent comparison proves exact clean-source bytes, source blob identity, and unchanged prior manifest records.

The resulting root is 245/512 lines and 20,216/65,536 bytes. The manifest contains 23 records and
13,782/16,384 bytes; 22 immutable segments plus root and manifest require 24 files. The collection totals
25,194/27,000 lines and 2,691,497/3,145,728 bytes. Every current-root, per-segment, manifest-byte, and aggregate
control has capacity; only the finite file-count and manifest-line slots require admission.

Complete older records have already moved out of the current view. Removing or rewriting accepted immutable
history cannot provide those missing slots while preserving the governing storage contract.

## Decision

Admit only `engineering_notes.limits.max_files` 23 to 24 and manifest `max_lines` 22 to 23. Preserve all byte
ceilings, root/per-segment/aggregate line ceilings, member patterns, owner, lifecycle, verifier, and ADR 0069
storage authority. This is one finite storage step for the mandatory complete-record rollover, with a newly
indexed exact-limit decision; it does not refresh a baseline or authorize another increase.

## Consequences

- Required continuity and all accepted history remain queryable on the repository volume.
- No immutable segment is changed, and the current view shrinks below both retained-root targets.
- Registry infrastructure requires receipt-bound canonical proof for this exact staged checkpoint.
- Product repairs and required full codebase/mdBook reading remain separately owned and incomplete.

## Links

- Store authority: `docs/decisions/0069-bounded-change-and-notes-history.md`
- Previous capacity: `docs/decisions/0101-engineering-notes-twenty-third-member-capacity.md`
- Owning task: `docs/tasks/SESSION-STARTUP-READING.md`
- Route registry: `doctrine/readme_stability/routes.jsonl`
- Manifest: `docs/history/development-notes/manifest.jsonl`
