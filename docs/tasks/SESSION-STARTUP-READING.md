# SESSION-STARTUP-READING: Targeted Startup and Separate Reading Audit

## Metadata

- Tree ID: `SESSION-STARTUP-READING`
- Status: `active`
- Roadmap lane: `Targeted session continuity / separately tracked full-reading audit`
- Created: `2026-09-06`
- Last updated: `2026-10-26`
- Owner: repo-local workflow
- Reading baseline: `baeb984e36a94a15951cd23d4c52def5064cdaca`
- Partition authority: `docs/decisions/0125-startup-task-partitions.md`

## Task Tree

- ID: `SESSION-STARTUP-READING`
  Status: `active`
  Goal: Recover the repair frontier with targeted reading and preserve the separate full-reading audit.
  Children: Canonical child definitions and ID-scoped evidence live in the three semantic parts below.

## Current Frontier

Current feature selection (October26): Scalar61.1/.61.2, bounded selected/copy rollout and ordinary Rust coalesce62.1 are implemented/targeted-checked. Ordinary nonempty62.2.1 is also implemented/targeted-checked; documented Rust receiver62.2.2 is implemented too. Discovered Perl exhausted-tail/numeric-selection62.2.3 is repaired too. TYPE23.2.2 count/count_keys/length result contract is frozen; Perl23.3.3.1 implementation is targeted-checked and Rust23.3.3.2 is implemented too; Dart23.3.3.3 is implemented/targeted-checked; Julia23.3.3.4 is implemented/targeted-checked; Lua23.3.3.5 is implemented/targeted-checked on available PUC5.5.1/LuaJIT; aggregate numeric result contract23.2.3 is frozen and Perl23.3.4.1 is implemented/targeted-checked; Rust23.3.4.2 is implemented/targeted-checked; Dart23.3.4.3 is implemented/targeted-checked; Julia23.3.4.4 is implemented/targeted-checked; Lua23.3.4.5 is implemented/targeted-checked on available PUC5.5.1/LuaJIT; join-result contract23.2.4 is frozen; Perl23.3.5.1 is implemented/targeted-checked; Rust23.3.5.2 is implemented/targeted-checked; Dart23.3.5.3 is implemented/targeted-checked; Julia23.3.5.4 is implemented/targeted-checked; Lua23.3.5.5 is implemented/targeted-checked on available PUC5.5.1/LuaJIT. Lua mutable-split false delimiter2.9.1.1 is repaired/targeted-checked on available hosts; container-default23.2.5 is frozen; Perl flow23.3.6.1.1 and literal repair1.2 are implemented/targeted-checked; Rust default flow2 is repaired/targeted-checked; Dart scalar default boundaries3 are repaired/targeted-checked; Julia scalar default boundaries4 are repaired/targeted-checked; Lua scalar default boundaries5 are repaired/targeted-checked on available hosts; index_of contract23.2.6 is frozen and Perl implementation23.3.7.1 is targeted-checked; Rust index implementation2 is targeted-checked; Dart index boundaries3 are targeted-checked; Julia index boundaries4 are targeted-checked; Lua index boundaries5 are targeted-checked on available hosts; has_key23.2.7 is frozen; Perl key-block23.3.8.1.1 and result flow1.2 are repaired/targeted-checked; Rust2 result/shape repair is targeted-checked; Dart3 scalar/shape repair is targeted-checked; Julia4 scalar/shape repair is targeted-checked; Lua5 result/shape repair is targeted-checked on available hosts; bounded has_key rollout is targeted-checked. is_empty/is_nonempty23.2.8 is frozen; bounded ordinary Perl producer23.3.9.1.1 is repaired/targeted-checked; result flow1.2 is repaired/targeted-checked too; Rust2 generic result/source/shape repair is targeted-checked; Dart3 scalar/shape repair is targeted-checked; Julia4 scalar/shape repair is targeted-checked; Lua5 result/shape repair is targeted-checked on installed hosts; bounded emptiness rollout is targeted-checked. String predicate assessment23.2.9 is next, with broader16 conditions/literal-consumer ownership retained. Broad61.3/62.3/.62.4, full suites/global scans and numeric/text maintenance remain deferred under director instruction. Older numeric handoff below is historical.

Numeric `.55.1` is verified from activation f0d974aa1; its exact canonical receipt
and normal hooks govern landing. Return to `TYPE-REFERENCE-BOOK.1.2.17.4` only
after the clean numeric commit. Portable text policy remains `.55.2`; `.55.3`
owns the broader numeric closeout. Other startup repairs retain their schedule.

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `TYPE-REFERENCE-BOOK.1.2.23.2.9` | `pending` | Assess existing String predicate result flow; broader16 stays open. |

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
