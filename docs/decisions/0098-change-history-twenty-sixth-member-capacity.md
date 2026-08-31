# ADR 0098: Change history admits its twenty-sixth bounded member

- Date: 2026-08-31
- Status: accepted under `FUTURE-PARITY-BACKLOG.19.2.2`
- Tags: documentation, history, rollover, routing, pressure, continuity, doctrine

## Routing-limit authorization

- Routed surface: `change_history`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":25,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":26,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`

## Routing-contract authorization

- Routed surface: `change_history`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":16384,"max_lines":24}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":16384,"max_lines":25}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Context

The mandatory `CHANGES.md` record for `FUTURE-PARITY-BACKLOG.19.2.2` crosses the bounded hot shard's 90% rollover
threshold. The governed rollover creates immutable content-addressed segment `4987` from exact clean activation
commit `be3d58dda7e89919e63c380c70180432b303dbbe`. Together with the bounded current root, manifest, and twenty-four
immutable segments, the controlled collection now contains twenty-six files and the manifest contains twenty-five
records. The rollover oracle passes; the routing-pressure doctrine then rejects only 26 files versus 25 and 25
manifest lines versus 24.

The resulting collection remains below its aggregate ceilings at 47,493/55,000 lines and
3,412,036/4,194,304 bytes. Every immutable segment remains at or below 4,096 lines and 524,288 bytes; the current
root is 259/512 lines and 23,275/65,536 bytes; the new segment is 221 lines and 19,643 bytes; and the manifest is
25 lines and 14,159/16,384 bytes. Only the finite file-count and manifest-line controls were exceeded.

## Decision

Increase only `change_history.limits.max_files` from 25 to 26 and the manifest member's `max_lines` from 24 to
25. Preserve the same owner, lifecycle, control, member patterns, every byte limit, per-history-file line limit,
aggregate ceilings, verifier, and ADR `0069` storage authority. This is one reviewed finite capacity step for one
content-addressed immutable segment and its manifest record, not a refreshed baseline or growth waiver.

## Consequences

- The required complete-record rollover stays durable, content-addressed, queryable, and reconstruction-safe.
- All root, byte, per-history-file, and aggregate pressure controls remain unchanged.
- Any next file-count or manifest-line increase again requires a newly staged and indexed exact-limit ADR.
- This infrastructure movement upgrades `.19.2.2` from focused to receipt-bound canonical verification.
- Parser/runtime semantics beyond the already-owned Perl `map_leaves!` slice, README, CLI, storage-root, and path
  behavior do not change as a consequence of this capacity step.

## Links

- Original bounded-store authority: `docs/decisions/0069-bounded-change-and-notes-history.md`
- Prior finite capacity step: `docs/decisions/0096-change-history-twenty-fifth-member-capacity.md`
- Owning task: `docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md`
- Route registry: `doctrine/readme_stability/routes.jsonl`
- Manifest: `docs/history/changes/manifest.jsonl`
