# SESSION-STARTUP-READING: Targeted Startup and Separate Reading Audit

## Metadata

- Tree ID: `SESSION-STARTUP-READING`
- Status: `active`
- Roadmap lane: `Targeted session continuity / separately tracked full-reading audit`
- Created: `2026-09-06`
- Last updated: `2026-10-03`
- Owner: repo-local workflow
- Reading baseline: `baeb984e36a94a15951cd23d4c52def5064cdaca`
- Partition authority: `docs/decisions/0125-startup-task-partitions.md`

## Task Tree

- ID: `SESSION-STARTUP-READING`
  Status: `active`
  Goal: Recover the repair frontier with targeted reading and preserve the separate full-reading audit.
  Children: Canonical child definitions and ID-scoped evidence live in the three semantic parts below.

## Current Frontier

The self-containment deferred-control diagnosis selects existing `.87.2` as a bounded
feature prerequisite from clean52763. Matches literal/string repair is complete under `.87.2`;
return after its clean commit to `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.1`. Other startup order
.94/.95/.51/.96 and the separate reading audit retain their ownership and priority.

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `SESSION-STARTUP-READING.87.2` | `done` | Bounded prerequisite verified; return to self-containment attached .0.5.1. |

Indexed-read .88 and compact-key .50 repairs are verified. The bounded scanner/helper
parent .86 is closed; independent helper/grouping repairs remain under .87.
The conformance full-reading audit remains 89/143 with .1.90 next in its own tree.
ADR0123 makes that audit separate from ordinary targeted startup and repair work.

## Semantic Part Index

| Stable top-level prefix | Canonical owner |
| --- | --- |
| `.1` through `.3` and their reading evidence | [SESSION-STARTUP-READING.01-03.md](SESSION-STARTUP-READING.01-03.md) |
| `.4` through `.49`, including .31 forward intake | [SESSION-STARTUP-READING.04-49.md](SESSION-STARTUP-READING.04-49.md) |
| `.50` through `.99` | [SESSION-STARTUP-READING.50-99.md](SESSION-STARTUP-READING.50-99.md) |
| Immutable original prelude/frontier/global history | [SESSION-STARTUP-READING.history.md](SESSION-STARTUP-READING.history.md) |

The strict schema-v1 index is `docs/tasks/SESSION-STARTUP-READING.index.jsonl`.
Ranges allocate ownership, not tasks: a missing ID is rejected even within a range.
All 395 original child definitions and all original source bytes are preserved.
The three semantic parts are mutable; the historical part is never an append target.
This current root is capped at 256 lines / 32768 bytes; each part at 5000 / 786432.

## Current Decisions and Blockers

- Use targeted, task-specific reading under ADR0123. Original audit ranges and reading
  credit remain in the semantic owners; historical instructions grant no new credit.
- RGX and its transitive dependencies are black boxes. Follow current AGENTS.md and
  published RGX integration contracts; older dependency-reading/build assumptions are historical.
- LS-004 is verified and published at fd3e328d5; the bounded local report activity is closed.
  ARCHOGEN owns downstream acceptance and any changes in its read-only repository.
- Startup .7 still owns the process-liveness repair. Recovery/purge remain prohibited.
- Keep all confirmed defects task-owned through repair; .89/.90/.91, census .93 and fallback verification .92 are verified; .94/.95/.51/.96 remain queued behind the director-selected feature work.
- Formal book/codebase reconciliation .4 and the separate reading audit remain open.
  Focused feature repairs keep their affected book sections and executable examples aligned.

## Retrieval

From the repository root, resolve the one bounded owner of a stable child:

```sh
perl tools/read_task_tree.pl --tree SESSION-STARTUP-READING --id SESSION-STARTUP-READING.92
```

After editing a mutable owner, refresh its current snapshot in the same slice:

```sh
perl tools/update_task_tree_index.pl --tree SESSION-STARTUP-READING
```

Both tools derive the root from their own location when invoked from another directory.
The task metadata doctrine checks source identity, immutable history, semantic ownership,
current digests, lookup, current frontier and the unchanged collection limits.
Planning/reconstruction evidence: `docs/knowledge/startup-task-partition-plan.md`.
