---
id: readme-debt-transition-owner-commit-boundary
title: README debt transition ownership stays active through its closeout commit
answers:
  - why did README routing pressure reject signoff complete closeout documentation
  - when may a README debt transition owner stop being active
  - does signoff complete authorize README debt surface growth
  - how does the README routing checker identify an active transition owner
  - what status must README policy closeout retain before commit
date: 2026-08-09
status: current mechanical commit-boundary rule
tags: [readme, routing, pressure, debt, task-tree, commit, transition, checker]
evidence: "During README-STABILITY-POLICY.4.2 closeout, the staged resulting-tree checker rejected growth in change_history, engineering_notes, live_status, and task_evidence after every README task status moved from active to signoff-complete. scripts/check_readme_routing_pressure.pl::task_owner_is_active requires the transition owner text and a literal Status: `active` in a task file; debt_growth_authorized compares the resulting tree with HEAD. Restoring .4.2 as active/signoff-complete pending its atomic commit preserves finite owner authority, after which the committed measurements become HEAD and successor containment work supplies its own active owner."
last_verified: 2026-08-09
reverify:
  - "sed -n '637,675p' scripts/check_readme_routing_pressure.pl"
  - "rg -n 'README-STABILITY-POLICY.4.2|Status: `active`' docs/tasks/README-STABILITY-POLICY.md docs/TASK_TREE.md"
  - "perl scripts/check_readme_routing_pressure.pl --report"
---

# Active ownership extends through the closeout commit

Debt authorization is evaluated against the staged resulting tree and current `HEAD`. A task that is logically
signoff-complete still owns the documentation growth used to record that signoff until the atomic commit lands.
Therefore its task file retains a mechanically active status, annotated as signoff-complete/pending commit, while
the final snapshot is staged and checked.

After the commit, those measurements are part of `HEAD`; the next task-tree-first transition supplies its own
active owner before any further debt-surface growth. Replacing `active` with `signoff-complete` before the commit
removes authority too early and correctly blocks the commit. This is a lifecycle rule, not a reason to raise a
limit, refresh a baseline, or weaken the checker.
