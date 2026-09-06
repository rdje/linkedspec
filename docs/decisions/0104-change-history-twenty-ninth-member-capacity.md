# ADR 0104: Change history admits its twenty-ninth bounded member

- Date: 2026-09-06
- Status: accepted under `SESSION-STARTUP-READING.3.2.41`
- Tags: documentation, history, rollover, routing, pressure, continuity, doctrine

## Routing-limit authorization

- Routed surface: `change_history`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":28,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":29,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`

## Routing-contract authorization

- Routed surface: `change_history`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":16384,"max_lines":27}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":16384,"max_lines":28}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Context

The required complete reading checkpoint takes CHANGES.md from 459 to 464 lines, crossing its 90% rollover
threshold. The governed rollover archives exact clean activation source
`e548ce4be5d3164ab8be54dc3d63dece2dda0ffb` lines 248–459 as segment `4984`:
212 lines / 19,054 bytes, SHA-256 `d720d564937dc8d5f5d14a2942335ec874a481dda01e8824b2956a0742e9c69f`.
Independent comparison proves source bytes, Git blob `daf0f6f1a571377da88009f340a844ff627ff10f`,
counts, and SHA-256. Every prior segment record remains byte-identical; only the manifest header count advances.

The resulting root is 252 lines / 18,277 bytes immediately after rollover. Removing its final redundant blank
line for ordinary diff hygiene leaves 251/512 lines and 18,276/65,536 bytes; immutable segment bytes are unchanged.
The manifest is 28 lines / 15,887 bytes. Twenty-seven immutable segments plus root and manifest require 29 files.
The final collection totals 48,131/55,000 lines and 3,467,471/4,194,304 bytes.

All current-root, per-segment, manifest-byte, and aggregate controls have capacity. Complete older records have
already moved out of the current view. Removing or rewriting accepted immutable history cannot supply the
missing finite file/manifest slots while preserving ADR 0069's storage and retrieval contract.

## Decision

Admit only `change_history.limits.max_files` 28 to 29 and manifest member `max_lines` 27 to 28.
Retain every byte ceiling, root/per-segment/aggregate line ceiling, member/route pattern, owner, lifecycle,
verifier, and ADR 0069 storage authority. Stable responsibility remains `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3`;
the mandatory startup checkpoint owns this one finite capacity admission. Any later increase needs another
newly indexed exact-limit decision.

## Consequences

- Accepted history remains exact and queryable on the repository volume.
- The current view falls below both retained-root targets without rewriting any archive.
- Route-registry infrastructure requires receipt-bound canonical verification of the exact staged checkpoint.
- Product repairs and full codebase/mdBook reading remain separately owned and incomplete.

## Links

- Store authority: `docs/decisions/0069-bounded-change-and-notes-history.md`
- Previous capacity: `docs/decisions/0102-change-history-twenty-eighth-member-capacity.md`
- Owning task: `docs/tasks/SESSION-STARTUP-READING.md`
- Route registry: `doctrine/readme_stability/routes.jsonl`
- Manifest: `docs/history/changes/manifest.jsonl`
