# ADR 0070: Engineering-notes history admits its eleventh bounded member

- Date: 2026-08-13
- Status: accepted under `INTER-MATCH-GAP-CAPTURE.1.2`
- Tags: documentation, history, rollover, routing, pressure, continuity, doctrine

## Routing-limit authorization

- Routed surface: `engineering_notes`
- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":10,"max_lines_per_file":4096,"max_total_bytes":3145728,"max_total_lines":27000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":11,"max_lines_per_file":4096,"max_total_bytes":3145728,"max_total_lines":27000}`

## Context

The required `DEVELOPMENT_NOTES.md` rollover for `INTER-MATCH-GAP-CAPTURE.1.2` created the ninth immutable history
segment. Together with the bounded current root and manifest, that is eleven controlled files. The existing
aggregate limits remain comfortable at 22,222/27,000 lines and 2,387,918/3,145,728 bytes, every archive remains
under 4,096 lines and 524,288 bytes, and the manifest remains exactly 10/10 lines. Only the collection member
count reached its earlier finite cap.

## Decision

Increase only `engineering_notes.limits.max_files` from 10 to 11. Preserve the same owner, lifecycle, control,
member patterns, member limits, aggregate line/byte ceilings, verifier, and ADR `0069` storage authority. This is
a reviewed capacity step for one content-addressed immutable segment, not a refreshed usage baseline or an
unbounded-growth exemption.

## Consequences

- The exact required rollover remains durable and queryable rather than being undone to satisfy a stale count.
- All byte, line, per-file, current-root, manifest, and aggregate pressure controls remain unchanged.
- The next member-count increase again requires a newly added, staged, indexed ADR with exact old/new limits.
- Parser, runtime, DSL, backend, README, CLI, storage-root, and public behavior do not change.

## Links

- Original bounded-store authority: `docs/decisions/0069-bounded-change-and-notes-history.md`
- Owning task: `docs/tasks/INTER-MATCH-GAP-CAPTURE.md`
- Route registry: `doctrine/readme_stability/routes.jsonl`
- Manifest: `docs/history/development-notes/manifest.jsonl`
