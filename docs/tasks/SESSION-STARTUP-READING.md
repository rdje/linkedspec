# SESSION-STARTUP-READING: Targeted Startup and Separate Reading Audit

## Metadata

- Tree ID: `SESSION-STARTUP-READING`
- Status: `active`
- Roadmap lane: `Targeted session continuity / separately tracked full-reading audit`
- Created: `2026-09-06`
- Last updated: `2026-10-27`
- Owner: repo-local workflow
- Reading baseline: `baeb984e36a94a15951cd23d4c52def5064cdaca`
- Partition authority: `docs/decisions/0125-startup-task-partitions.md`

## Task Tree

- ID: `SESSION-STARTUP-READING`
  Status: `active`
  Goal: Recover the repair frontier with targeted reading and preserve the separate full-reading audit.
  Children: Canonical child definitions and ID-scoped evidence live in the three semantic parts below.

## Current Frontier

Current feature selection (October27): derive HEAD and the exact active leaf from
MEMORY.md and TYPE-REFERENCE-BOOK's Current Frontier. Bounded scalar61.1/.2,
default62.1/.2 and TYPE selected/result families through scalar String23.3.19
are implemented/targeted-checked on their recorded routes/hosts. Optional substring
argument target23.2.20 and all three repairs20.1-.3 are targeted-checked. Remaining
fluent selection23.1.1 freezes reduction result continuations21; Perl21.1 is
targeted-checked and Rust21.2 independently assesses next.
Broad61.3/62.3/.4, declared Lua5.4, full domain/context/portable23.4 and the separate
reading audit remain open under their own acceptance. Feature-first ordinary
checks remain focused; no full reading audit is a prerequisite for these repairs.

The prior accumulated frontier and numeric return instructions are historical,
preserved exactly for this path at Git b73b56c36075e79472adbb822d6cdb5bb34a01e0.
TYPE23.2.20 owns this bounded continuity correction, not a startup-tree pivot.

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `TYPE-REFERENCE-BOOK.1.2.23.3.21.2` | `pending` | Independent Rust reduction accumulator result assessment; other backends follow separately. |

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
- Keep all confirmed defects task-owned through repair; .89/.90/.91, census .93 and fallback verification .92 are verified. Numeric .55.1 is verified; .94/.95/.51/.96 and independent helper repairs retain their existing owners.
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
