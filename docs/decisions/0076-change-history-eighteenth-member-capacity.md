# ADR 0076: Change history admits its eighteenth bounded member

- Date: 2026-08-15
- Status: accepted under `INTER-MATCH-GAP-CAPTURE.5.1`
- Tags: documentation, history, rollover, routing, pressure, continuity, doctrine

## Routing-limit authorization

- Routed surface: `change_history`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":17,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":18,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`

## Routing-contract authorization

- Routed surface: `change_history`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":16384,"max_lines":16}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":16384,"max_lines":17}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Context

The mandatory `CHANGES.md` rollover for `INTER-MATCH-GAP-CAPTURE.5.1` created immutable segment 4995. Together
with the bounded current root, manifest, and fifteen earlier immutable segments, the controlled collection now
contains eighteen files and the manifest contains seventeen records. The collection remains below its aggregate
ceilings at 45,656/55,000 lines and 3,240,997/4,194,304 bytes; every immutable segment remains at or below 4,096
lines and 524,288 bytes, the current root is 237/512 lines and 21,393/65,536 bytes, and the manifest is 17 lines
and 9,551/16,384 bytes. Only the finite file-count and manifest-line controls were exceeded.

## Decision

Increase only `change_history.limits.max_files` from 17 to 18 and the manifest member's `max_lines` from 16 to
17. Preserve the same owner, lifecycle, control, member patterns, all byte limits, per-history-file line limit,
aggregate ceilings, verifier, and ADR `0069` storage authority. This is a reviewed finite capacity step for one
content-addressed immutable segment and its one manifest record, not a refreshed usage baseline or growth waiver.

## Consequences

- The required complete-record rollover stays durable, content-addressed, queryable, and reconstruction-safe.
- All root, byte, per-history-file, and aggregate pressure controls remain unchanged.
- Any next file-count or manifest-line increase again requires a newly staged and indexed exact-limit ADR.
- Parser, runtime, DSL, backend, README, CLI, storage-root, and public behavior do not change.

## Links

- Original bounded-store authority: `docs/decisions/0069-bounded-change-and-notes-history.md`
- Prior finite capacity step: `docs/decisions/0072-change-history-seventeenth-member-capacity.md`
- Owning task: `docs/tasks/INTER-MATCH-GAP-CAPTURE.md`
- Route registry: `doctrine/readme_stability/routes.jsonl`
- Manifest: `docs/history/changes/manifest.jsonl`
