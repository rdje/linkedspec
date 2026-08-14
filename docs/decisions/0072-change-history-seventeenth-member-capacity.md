# ADR 0072: Change history admits its seventeenth bounded member

- Date: 2026-08-14
- Status: accepted under `INTER-MATCH-GAP-CAPTURE.3.4`
- Tags: documentation, history, rollover, routing, pressure, continuity, doctrine

## Routing-limit authorization

- Routed surface: `change_history`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":16,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":17,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`

## Context

The mandatory `CHANGES.md` rollover for `INTER-MATCH-GAP-CAPTURE.3.4` created immutable segment 4996. Together
with the bounded current root, manifest, and fourteen earlier immutable segments, the controlled collection now
contains seventeen files. The collection remains below its aggregate ceilings at 45,423/55,000 lines and
3,219,014/4,194,304 bytes; every immutable segment remains at or below 4,096 lines and 524,288 bytes, the current
root is 238/512 lines and 22,261/65,536 bytes, and the manifest is 16/16 lines and 8,975/16,384 bytes. Only the
collection member count exceeded its earlier finite cap.

## Decision

Increase only `change_history.limits.max_files` from 16 to 17. Preserve the same owner, lifecycle, control,
member patterns, all line and byte limits, aggregate ceilings, verifier, and ADR `0069` storage authority. This is
a reviewed finite capacity step for one content-addressed immutable segment, not a refreshed usage baseline or
growth waiver.

## Consequences

- The required complete-record rollover stays durable, content-addressed, queryable, and reconstruction-safe.
- All root, manifest, byte, per-history-file, and aggregate pressure controls remain unchanged.
- The next member-count increase again requires a newly staged and indexed exact-limit ADR; because the manifest
  is now at its line cap, that next rollover must review its manifest limit independently too.
- Parser, runtime, DSL, backend, README, CLI, storage-root, and public behavior do not change.

## Links

- Original bounded-store authority: `docs/decisions/0069-bounded-change-and-notes-history.md`
- Owning task: `docs/tasks/INTER-MATCH-GAP-CAPTURE.md`
- Route registry: `doctrine/readme_stability/routes.jsonl`
- Manifest: `docs/history/changes/manifest.jsonl`
