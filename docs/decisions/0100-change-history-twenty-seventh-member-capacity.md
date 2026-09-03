# ADR 0100: Change history admits its twenty-seventh bounded member

- Date: 2026-09-03
- Status: accepted under `FUTURE-PARITY-BACKLOG.19.5.2`
- Tags: documentation, history, rollover, routing, pressure, continuity, doctrine

## Routing-limit authorization

- Routed surface: `change_history`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":26,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":27,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`

## Routing-contract authorization

- Routed surface: `change_history`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":16384,"max_lines":25}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":16384,"max_lines":26}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Context

The mandatory complete `CHANGES.md` record for `FUTURE-PARITY-BACKLOG.19.5.2` takes the bounded hot shard to
465/512 lines and crosses its 90% rollover threshold. The governed rollover creates immutable content-addressed
segment `4986` from exact clean activation commit `5b3d7adc0cce9bc862b9b3aa00cbbce924dbf916`. Together with the
bounded current root, manifest, and twenty-five immutable segments, the controlled collection now contains
twenty-seven files and the manifest contains twenty-six records. The rollover oracle passes; the routing-pressure
doctrine then rejects only 27 files versus 26 and 26 manifest lines versus 25.

The final candidate collection remains below its aggregate ceilings at 47,709/55,000 lines and
3,432,532/4,194,304 bytes. Every immutable segment remains at or below 4,096 lines and 524,288 bytes; the current
root is 261/512 lines and 23,891/65,536 bytes; the new segment is 213 lines and 19,304 bytes; and the manifest is
26 lines and 14,735/16,384 bytes. Only the finite file-count and manifest-line controls were exceeded.

## Decision

Increase only `change_history.limits.max_files` from 26 to 27 and the manifest member's `max_lines` from 25 to
26. Preserve the same owner, lifecycle, control, member patterns, every byte limit, per-history-file line limit,
aggregate ceilings, verifier, and ADR `0069` storage authority. This is one reviewed finite capacity step for one
content-addressed immutable segment and its manifest record, not a refreshed baseline or growth waiver.

## Consequences

- The required complete-record rollover stays durable, content-addressed, queryable, and reconstruction-safe.
- All root, byte, per-history-file, and aggregate pressure controls remain unchanged.
- Any next file-count or manifest-line increase again requires a newly staged and indexed exact-limit ADR.
- This infrastructure movement upgrades `.19.5.2` from focused to receipt-bound canonical verification.
- Julia mutation semantics, README, CLI, storage-root, and path behavior do not change because of this capacity step.

## Links

- Original bounded-store authority: `docs/decisions/0069-bounded-change-and-notes-history.md`
- Prior finite capacity step: `docs/decisions/0098-change-history-twenty-sixth-member-capacity.md`
- Owning task: `docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md`
- Route registry: `doctrine/readme_stability/routes.jsonl`
- Manifest: `docs/history/changes/manifest.jsonl`
