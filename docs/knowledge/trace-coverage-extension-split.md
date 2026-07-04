---
id: trace-coverage-extension-split
title: TRACE-OBSERVABILITY.3 split Perl trace coverage extension into generated-handler, repetition, ActionIR, and closeout leaves
answers:
  - "what is TRACE-OBSERVABILITY.3.1"
  - "how is trace coverage extension split"
  - "what comes after trace CLI control"
  - "when should Rust trace parity be split"
date: 2026-07-04
status: current
tags: [trace, observability, task-tree, generated-handlers, actionir, rust]
evidence: "docs/tasks/TRACE-OBSERVABILITY.md .3 split; docs/TASK_TREE.md TRACE-OBSERVABILITY row; MEMORY.md next_action"
reverify: "rg -n 'TRACE-OBSERVABILITY\\.3\\.1|generated-handler trace helper|non-repetition generated|repetition|min/max|ActionIR owner|backend parity' docs/tasks/TRACE-OBSERVABILITY.md docs/TASK_TREE.md MEMORY.md LIVE_ACHIEVEMENT_STATUS.md"
---

`TRACE-OBSERVABILITY.3` is a split parent, not an implementation leaf. The next executable leaf is
`TRACE-OBSERVABILITY.3.1`: add the smallest reusable Perl generated-handler trace helper seam before modifying
branch templates.

The sequence is:

- `.3.1`: generated-handler trace helper contract/seam;
- `.3.2`: non-repetition generated handler dispatch decisions;
- `.3.3`: repetition/min/max/zero-progress paths;
- `.3.4`: compile/ActionIR owner ENTER/EXIT and branch decisions;
- `.3.5`: coverage closeout docs/probes and the backend-parity split decision.

Rust trace parity remains future work until the Perl reference trace semantics are concrete.
