# ADR 0096: Change history admits its twenty-fifth bounded member

- Date: 2026-08-29
- Status: accepted under `FUTURE-PARITY-BACKLOG.15.2`
- Tags: documentation, history, rollover, routing, pressure, continuity, doctrine

## Routing-limit authorization

- Routed surface: `change_history`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":24,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":25,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`

## Routing-contract authorization

- Routed surface: `change_history`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":16384,"max_lines":23}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":16384,"max_lines":24}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Context

The mandatory `CHANGES.md` rollover for `FUTURE-PARITY-BACKLOG.15.2` creates immutable content-addressed
segment `4988` from exact clean activation commit `9321357507a7dd39d49793b5674c130b5b805ca4`. Together with the
bounded current root, manifest, and twenty-three immutable segments, the controlled collection now contains
twenty-five files and the manifest contains twenty-four records. The rollover oracle passes, then the routing-
pressure doctrine rejects only 25 files versus 24 and 24 manifest lines versus 23.

The resulting collection remains below its aggregate ceilings at 47,264/55,000 lines and
3,390,743/4,194,304 bytes. Every immutable segment remains at or below 4,096 lines and 524,288 bytes; the current
root is 252/512 lines and 22,201/65,536 bytes; the new segment is 216 lines and 19,833 bytes; and the manifest is
24 lines and 13,583/16,384 bytes. Only the finite file-count and manifest-line controls were exceeded.

## Decision

Increase only `change_history.limits.max_files` from 24 to 25 and the manifest member's `max_lines` from 23 to
24. Preserve the same owner, lifecycle, control, member patterns, every byte limit, per-history-file line limit,
aggregate ceilings, verifier, and ADR `0069` storage authority. This is one reviewed finite capacity step for one
content-addressed immutable segment and its manifest record, not a refreshed baseline or growth waiver.

## Consequences

- The required complete-record rollover stays durable, content-addressed, queryable, and reconstruction-safe.
- All root, byte, per-history-file, and aggregate pressure controls remain unchanged.
- Any next file-count or manifest-line increase again requires a newly staged and indexed exact-limit ADR.
- The `.15.2` closeout already requires receipt-bound canonical verification because cross-backend/public,
  self-hosted, recurring-gate, parent-closeout, and push-boundary state moves.
- Parser, compiler, runtime semantics, DSL, admission, README, CLI, storage-root, and path behavior do not change
  as a consequence of this capacity step.

## Links

- Original bounded-store authority: `docs/decisions/0069-bounded-change-and-notes-history.md`
- Prior finite capacity step: `docs/decisions/0093-change-history-twenty-fourth-member-capacity.md`
- Owning task: `docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md`
- Route registry: `doctrine/readme_stability/routes.jsonl`
- Manifest: `docs/history/changes/manifest.jsonl`
