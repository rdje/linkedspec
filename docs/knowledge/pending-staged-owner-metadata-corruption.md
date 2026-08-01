---
id: pending-staged-owner-metadata-corruption
title: Pending staged owner .2 contains two proven cross-slice Lua cursor metadata insertions
answers:
  - "why does FUTURE-PARITY-BACKLOG.2 mention Lua rule local cursor admission"
  - "which commits corrupted FUTURE-PARITY-BACKLOG.2 metadata"
  - "is FUTURE-PARITY-BACKLOG.2 actually complete"
  - "which task repairs the staged owner metadata corruption"
  - "what supersedes broad staged owner FUTURE-PARITY-BACKLOG.2"
date: 2026-08-01
status: repaired and guarded under FUTURE-PARITY-BACKLOG.24.0.1; provenance retained
tags: [task-tree, provenance, staged-parsing, metadata-drift, git-history, FUTURE-PARITY-BACKLOG]
evidence: "Git blame and exact commit diffs prove two independent misplaced task-tree patches. Commit e96d389e (Lua global cursor option removal) changed pending FUTURE-PARITY-BACKLOG.2 Commit from pending to the unrelated completed .9.1.7.4 identity. Commit 7dd70a2d (Lua rule-local cursor admission) replaced .2 Verification with .9.1.7.6 activation/admission detail. The .2 ID, pending status, goal, and acceptance remained unchanged from original commit 59cbf0be. FUTURE-PARITY-BACKLOG.24.0.1 marks .2 superseded without implementation by active parent .14, progressive .14.6, and staged .14.7; repairs four current node/frontier/authority-card references while preserving dated history; and extends TASK-TREE-METADATA with in-memory fixtures denying pending activation claims and foreign same-tree Commit ids."
reverify: "git show --format= --unified=20 e96d389e -- docs/tasks/FUTURE-PARITY-BACKLOG.md && git show --format= --unified=20 7dd70a2d -- docs/tasks/FUTURE-PARITY-BACKLOG.md && git show 59cbf0be:docs/tasks/FUTURE-PARITY-BACKLOG.md | rg -n -C 6 'FUTURE-PARITY-BACKLOG.2' && bash scripts/check_task_tree_metadata.sh && rg -n 'FUTURE-PARITY-BACKLOG.14|General public.*parse_job' docs/tasks/STAGED-LINKED-PARSING.md docs/knowledge/staged-linked-parsing-architecture.md docs/knowledge/structural-progressive-staged-authoring-doctrine.md docs/decisions/0056-typed-source-location-and-cursor-algebra.md"
---

This is not historical proof for `.2`; it is task-tree metadata corruption caused by broad patch context selecting
the first `Verification`/`Commit` pair near an unrelated leaf. The current capability checker sees only that `.2`
exists, so neither the corrupt prose nor the superseded owner relationship affects its green 80/0/0 result.

`FUTURE-PARITY-BACKLOG.24.0.1` repairs the node as `superseded` without implementation, preserves both introducing
commits as provenance, and reconciles the broad placeholder under active parent `.14`, progressive `.14.6`, and
staged `.14.7`. The task-metadata guard now rejects a pending node that claims task-tree-first activation or names
a different same-tree ID as its own commit. Four in-memory fixtures keep that boundary mutation-sensitive without
opening a broad historical cleanup gate. No parser, runtime, manifest, capability row, or public language behavior
belongs to this repair.

Related: [[capability-exclusion-freshness-model]], [[structural-progressive-staged-authoring-doctrine]].
