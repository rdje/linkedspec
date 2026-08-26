# ADR 0091: Change history admits its twenty-third bounded member

- Date: 2026-08-26
- Status: accepted under `FUTURE-PARITY-BACKLOG.14.7.5.0`
- Tags: documentation, history, rollover, routing, pressure, continuity, doctrine

## Routing-limit authorization

- Routed surface: `change_history`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":22,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":23,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`

## Routing-contract authorization

- Routed surface: `change_history`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":16384,"max_lines":21}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":16384,"max_lines":22}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Context

The mandatory `CHANGES.md` rollover for `FUTURE-PARITY-BACKLOG.14.7.5.0` creates immutable content-addressed
segment `4990` from exact clean activation commit `94d20becf2c8a17438a2509538a9878ecd96c9b9`. Together with the
bounded current root, manifest, and twenty-one immutable segments, the controlled collection now contains
twenty-three files and the manifest contains twenty-two records. It remains below aggregate ceilings at
46,806/55,000 lines and 3,348,383/4,194,304 bytes. Every immutable segment remains at or below 4,096 lines and
524,288 bytes; the current root is 243/512 lines and 20,957/65,536 bytes; new segment `4990` is 224 lines and
20,421 bytes; and the manifest is 22 lines and 12,431/16,384 bytes. Only the finite file-count and manifest-line
controls were exceeded.

## Decision

Increase only `change_history.limits.max_files` from 22 to 23 and the manifest member's `max_lines` from 21 to
22. Preserve the same owner, lifecycle, control, member patterns, every byte limit, per-history-file line limit,
aggregate ceilings, verifier, and ADR `0069` storage authority. This is one reviewed finite capacity step for one
content-addressed immutable segment and its manifest record, not a refreshed baseline or growth waiver.

## Consequences

- The required complete-record rollover stays durable, content-addressed, queryable, and reconstruction-safe.
- All root, byte, per-history-file, and aggregate pressure controls remain unchanged.
- Any next file-count or manifest-line increase again requires a newly staged and indexed exact-limit ADR.
- The dormant-boundary slice requires receipt-bound canonical verification because resulting-tree infrastructure moved.
- Parser, compiler, runtime, DSL, backend, public API, README, CLI, storage-root, and path behavior do not change.

## Links

- Original bounded-store authority: `docs/decisions/0069-bounded-change-and-notes-history.md`
- Prior finite capacity step: `docs/decisions/0089-change-history-twenty-second-member-capacity.md`
- Owning task: `docs/tasks/FUTURE-PARITY-BACKLOG.14.6.5-8.md`
- Route registry: `doctrine/readme_stability/routes.jsonl`
- Manifest: `docs/history/changes/manifest.jsonl`
