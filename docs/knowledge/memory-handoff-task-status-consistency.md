---
id: memory-handoff-task-status-consistency
title: "MEMORY.md clean handoff fields are mechanically checked against task-tree status"
answers:
  - "why did MEMORY.md say a committed leaf was still uncommitted"
  - "what checks MEMORY.md next_action against task status"
  - "can a completed leaf remain staged in the resume pointer"
  - "how is a clean MEMORY.md handoff enforced"
  - "what does check_memory_handoff_state.py prove"
date: 2026-08-29
status: current
tags: [memory-architecture, continuity, task-tree, handoff, doctrine, mutation-testing]
evidence: "FUTURE-PARITY-BACKLOG.22.1; tools/check_memory_handoff_state.py; scripts/check_memory_architecture.sh; MEMORY_ARCHITECTURE.md §6/§9; COMMIT.md; committed b024ea3e reproduction"
reverify: "bash tools/run_python_project_data.sh tools/check_memory_handoff_state.py && bash scripts/check_memory_architecture.sh"
---

The clean pushed `.22` commit `b024ea3e` had a correct activation boundary but stale semantic fields:
`active_work_unit` still called `.22` a staged canonical boundary, `next_action` still scheduled its commit/push,
and `in_flight_uncommitted` still called its candidate uncommitted. Git, the promoted receipt, and the task tree
all proved that `.22` was already committed and pushed. The preceding `.13.1` commit carried the same class of
stale pointer, showing that this was a recurring enforcement gap rather than an isolated wording typo.

`scripts/check_memory_architecture.sh` had enforced only the pointer line cap, activation-commit ancestry, and
layer/bootstrap presence. `tools/check_memory_handoff_state.py` now composes the missing semantic boundary. It
requires `latest_completed_leaf` to resolve to a completed task-tree status; requires an idle pointer to have no
in-flight work; and, when the active leaf is complete, rejects pre-landing active wording, nonempty in-flight work,
or a same-leaf next action that schedules staging, committing, landing, or pushing again. Active, completed-clean,
and idle-clean fixtures pass; six destructive mutations prove each contradiction or referenced ambiguity is rejected.
