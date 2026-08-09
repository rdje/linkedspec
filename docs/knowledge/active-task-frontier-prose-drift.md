---
id: active-task-frontier-prose-drift
title: Active task-tree authoritative prose can drift because the metadata doctrine checks completed frontiers only
answers:
  - "why did FUTURE PARITY BACKLOG retain a stale authoritative frontier"
  - "does the task tree metadata doctrine check active tree prose"
  - "what owns active task frontier freshness enforcement"
  - "which commit introduced the stale FUTURE PARITY BACKLOG frontier"
  - "why did check task tree metadata pass the stale active frontier"
date: 2026-08-09
status: immediate drift repaired; enforcement follow-up pending under TASK-TREE-METADATA-HYGIENE.5
tags: [task-trees, metadata, frontier, doctrine, continuity]
evidence: "During FUTURE-PARITY-BACKLOG.14.3.1.0 startup, the task node, central index, roadmaps, architecture, memory, and Knowledge agreed that .14.3.1.0 was next, but the same task file's Authoritative frontier still named .14.2.0.1. git blame assigns that prose to bd777ee8. scripts/check_task_tree_metadata.sh passed because its documented low-noise boundary examines Current Frontier table status cells only when the top tree is completed, plus two narrow pending-node contradictions."
reverify: "git blame -L 22820,22835 -- docs/tasks/FUTURE-PARITY-BACKLOG.md && bash scripts/check_task_tree_metadata.sh && rg -n 'completed task file|top_status|TASK-TREE-METADATA-HYGIENE[.]5' scripts/check_task_tree_metadata.sh docs/knowledge/task-tree-metadata-gate-boundary.md docs/tasks/TASK-TREE-METADATA-HYGIENE.md"
---

The future-backlog task file's prose frontier was not a competing authority. Its leaf statuses and every durable
resume/index projection had advanced through the complete typed-source rollout and transaction audit, while one
free-form `Authoritative frontier` paragraph remained at `.14.2.0.1`. Git history shows the paragraph was written
by `bd777ee8`; later work simply did not update that non-gated projection.

This escaped mechanically for a known reason: `scripts/check_task_tree_metadata.sh` deliberately avoids broad
historical metadata debt. It checks live status cells only for task files whose top status is done/completed/
exhausted, and it checks two exact pending-node evidence contradictions. `FUTURE-PARITY-BACKLOG` is active, and its
frontier is prose rather than the completed-tree table shape, so the check correctly implemented its old boundary
while failing to protect this newer continuity need.

The discovering transaction decision repairs the immediate prose. `TASK-TREE-METADATA-HYGIENE.5` owns a separate
task-tree-first audit and low-false-positive enforcement extension; no opportunistic broad prose parser is accepted.
