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
status: current metadata defect; repair and supersession reconciliation pending under FUTURE-PARITY-BACKLOG.24.0.1
tags: [task-tree, provenance, staged-parsing, metadata-drift, git-history, FUTURE-PARITY-BACKLOG]
evidence: "Git blame and exact commit diffs prove two independent misplaced task-tree patches. Commit e96d389e (Lua global cursor option removal) changed pending FUTURE-PARITY-BACKLOG.2 Commit from pending to the unrelated completed .9.1.7.4 identity. Commit 7dd70a2d (Lua rule-local cursor admission) replaced .2 Verification with .9.1.7.6 activation/admission detail. The .2 ID, pending status, goal, and acceptance remained unchanged from original commit 59cbf0be. Closed STAGED-LINKED-PARSING later names FUTURE-PARITY-BACKLOG.14 as the broader owner; ADR 0056/current task split refine progressive and staged execution under .14.6-.7."
reverify: "git blame -L 1428,1442 -- docs/tasks/FUTURE-PARITY-BACKLOG.md && git show --format= --unified=20 e96d389e -- docs/tasks/FUTURE-PARITY-BACKLOG.md && git show --format= --unified=20 7dd70a2d -- docs/tasks/FUTURE-PARITY-BACKLOG.md && rg -n 'FUTURE-PARITY-BACKLOG.14|General public.*parse_job' docs/tasks/STAGED-LINKED-PARSING.md docs/decisions/0056-typed-source-location-and-cursor-algebra.md"
---

This is not historical proof for `.2`; it is task-tree metadata corruption caused by broad patch context selecting
the first `Verification`/`Commit` pair near an unrelated leaf. The current capability checker sees only that `.2`
exists, so neither the corrupt prose nor the superseded owner relationship affects its green 80/0/0 result.

`FUTURE-PARITY-BACKLOG.24.0.1` owns the exact repair: preserve both introducing commits as provenance, restore the
node's truthful history, reconcile the broad placeholder as superseded by active `.14`/`.14.6-.7`, and add a
narrow metadata guard for the proven pending-node contamination class before exclusion governance consumes task
statuses. No parser, runtime, manifest, capability row, or public language behavior belongs to that repair.

Related: [[capability-exclusion-freshness-model]], [[structural-progressive-staged-authoring-doctrine]].
