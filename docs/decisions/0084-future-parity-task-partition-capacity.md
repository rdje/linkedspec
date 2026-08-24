# ADR 0084: Future parity task evidence adds one bounded semantic member

- Date: 2026-08-18
- Status: accepted under `.0`; implemented and canonical-verified under `.1`; independent `.2` pending
- Tags: documentation, task-tree, partition, retrieval, routing, pressure, continuity, doctrine

## Routing-contract authorization

- Routed surface: `task_evidence`
- Previous routed limits: `{"max_bytes_per_file":1048576,"max_files":128,"max_lines_per_file":8000,"max_total_bytes":8388608,"max_total_lines":80000}`
- New routed limits: unchanged
- Previous semantic topology: seven mutable semantic members plus one immutable history member; strict schema-v1
  metadata plus eight part records; index limit 9 lines / 16,384 bytes.
- New semantic topology: eight mutable semantic members plus one immutable history member; strict schema-v1
  metadata plus nine part records; index limit 10 lines / 16,384 bytes.
- New bounded member: `docs/tasks/FUTURE-PARITY-BACKLOG.14.6.5-8.md`, limited to 5,000 lines / 786,432 bytes.
- Retained member limit: `docs/tasks/FUTURE-PARITY-BACKLOG.14.md` remains limited to 5,000 lines / 786,432 bytes.

The implementation leaf changes the route authority from ADR `0068` to this ADR, adds only the new member limit,
and changes only the index member's line limit from 9 to 10. Collection file, per-file, aggregate-line,
aggregate-byte, member-byte, and semantic-member-line ceilings remain unchanged.

## Context

Clean commit `3ccaf7c3ab1be95bf427818414f6aa5c83e22836` closes private Dart progressive dispatch and hands the
roadmap to pending Julia parent `FUTURE-PARITY-BACKLOG.14.6.5`. Its current stable-ID owner,
`docs/tasks/FUTURE-PARITY-BACKLOG.14.md`, is exactly 5,000 lines / 544,542 bytes. The update tool and partition
checker correctly reject another line, so task-tree-first Julia planning cannot begin without a bounded topology
change.

The current schema has no overflow member. Appending to immutable history would violate its positive-evidence
contract, while raising the 5,000-line member ceiling would hide unbounded growth. The first unstarted semantic
boundary is `.14.6.5`: all completed evidence through `.14.6.4.3` can remain in the current member, and the existing
pending `.14.6.5-.14.8` blocks can move unchanged before Julia children are added.

## Decision

Add one mutable semantic member at `docs/tasks/FUTURE-PARITY-BACKLOG.14.6.5-8.md` in
`FUTURE-PARITY-PARTITION-CAPACITY.1`. Preserve stable IDs and route them as follows:

- `docs/tasks/FUTURE-PARITY-BACKLOG.14.md`, partition id `14.0-6.4`, owns the `.14` root, `.14.0-.14.6.4.*`,
  and the `.14.6` parent;
- `docs/tasks/FUTURE-PARITY-BACKLOG.14.6.5-8.md`, partition id `14.6.5-8`, owns `.14.6.5-.14.6.8` and
  `.14.7-.14.8`.

Move the exact current 12-line / 1,379-byte pending block at lines 4,988-4,999, SHA-256
`7143ee5b31634bbb480a507f5b003e6e36aa7fe62e8af2e7ac91f4449a7ef920`. Preserve the source comment in each
mutable member. The clean `99fe03f3` provenance separates at the corresponding original boundary:

| Partition | Source lines | Source bytes | Source SHA-256 |
| --- | ---: | ---: | --- |
| `.14` root through `.14.6.4` | `17123-21064` (3,942 lines) | 357,142 | `6f04e2a0a87ed56b0e3545b802a2bc8ac7fa1facf44ea479c22dc73a8eb9c6cf` |
| `.14.6.5-.14.8` | `21065-21074` (10 lines) | 542 | `a2b8419807573b431392956b280705d4192bc020682546da65b46ff3b7e382a5` |

Keep `schema_version: 1`: record shape and source-accounting semantics do not change. Atomically update the strict
index, root navigation, `tools/read_task_tree.pl`, `tools/update_task_tree_index.pl`,
`tools/build_task_tree_partitions.pl`, `scripts/check_task_tree_partitions.pl` plus its mutations, README route
registry, and the capability-conformance all-semantic-parts census. Exact unique-ID, source range/count/digest,
lookup-both-sides, metadata mutation, bounded-route, outside-CWD, and consumer checks must pass before landing.

## Consequences

- Julia `.14.6.5` regains task-tree-first growth only after the canonical `.1` implementation and independent `.2`
  recomposition land cleanly.
- After `.1`, the future tree will have eight bounded mutable semantic members and one immutable history member;
  the index will have ten JSONL records.
- No stable ID, status, dependency, committed evidence, original source byte, or immutable history byte is lost or
  duplicated.
- No parser, compiler, runtime, backend, generated format, `.spec` syntax, public API, semantic/MCP/CLI/README, or
  progressive rollout behavior changes.
- Before `.1` lands, rollback is deletion/revert of this independent planning tree. After landing, rollback is the
  exact atomic commit revert; partial topology rollback is forbidden.

## Links

- Original partition authority: `docs/decisions/0068-future-parity-task-partitions.md`
- Owning task: `docs/tasks/FUTURE-PARITY-PARTITION-CAPACITY.md`
- Current index: `docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl`
- Route registry: `doctrine/readme_stability/routes.jsonl`
