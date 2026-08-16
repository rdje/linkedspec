# ADR 0078: Change history admits its nineteenth bounded member

- Date: 2026-08-16
- Status: accepted under `INTER-MATCH-GAP-CAPTURE.7.0`
- Tags: documentation, history, rollover, routing, pressure, continuity, doctrine

## Routing-limit authorization

- Routed surface: `change_history`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":18,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":19,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`

## Routing-contract authorization

- Routed surface: `change_history`
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":16384,"max_lines":17}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":16384,"max_lines":18}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

## Context

`INTER-MATCH-GAP-CAPTURE.7.0` begins with `CHANGES.md` at 459/512 lines and 41,846/65,536 bytes. Its required
complete record crosses the 90% line threshold and therefore requires the official content-addressed rollover.
Before that record, the controlled collection contains the bounded current root, manifest, and sixteen immutable
segments: eighteen files total. The manifest has its metadata record plus sixteen segment records: seventeen lines.
Aggregate use is 45,878/55,000 lines and 3,261,450/4,194,304 bytes, and every existing member remains below its
individual line and byte ceiling. The new immutable segment exceeds only the finite file-count and manifest-line
controls.

## Decision

Increase only `change_history.limits.max_files` from 18 to 19 and the manifest member's `max_lines` from 17 to
18. Preserve the same owner, lifecycle, control, member patterns, byte limits, per-history-file line limit,
aggregate ceilings, verifier, and ADR `0069` storage authority. This is one reviewed finite capacity step for one
content-addressed immutable segment and its manifest record, not a refreshed baseline or a growth waiver.

## Consequences

- The complete `.7.0` change record can roll through the official recovery-safe lifecycle.
- Root, byte, per-history-file, aggregate, queryability, and immutability controls remain unchanged.
- Any next file-count or manifest-line increase again requires a newly staged and indexed exact-limit ADR.
- Parser, compiler, runtime, DSL, backend, public API, README, CLI, storage-root, and path behavior do not change.

## Links

- Original bounded-store authority: `docs/decisions/0069-bounded-change-and-notes-history.md`
- Prior finite capacity step: `docs/decisions/0076-change-history-eighteenth-member-capacity.md`
- Owning task: `docs/tasks/INTER-MATCH-GAP-CAPTURE.md`
- Route registry: `doctrine/readme_stability/routes.jsonl`
- Manifest: `docs/history/changes/manifest.jsonl`
