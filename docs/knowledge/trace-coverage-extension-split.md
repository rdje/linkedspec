---
id: trace-coverage-extension-split
title: TRACE-OBSERVABILITY.3 split Perl trace coverage extension into generated-handler, repetition, ActionIR, and closeout leaves
answers:
  - "what is TRACE-OBSERVABILITY.3.1"
  - "how is trace coverage extension split"
  - "what comes after trace CLI control"
  - "when should Rust trace parity be split"
  - "what is next after TRACE-OBSERVABILITY.3.5"
date: 2026-07-04
status: current
tags: [trace, observability, task-tree, generated-handlers, actionir, rust]
evidence: "docs/tasks/TRACE-OBSERVABILITY.md .3 split; docs/TASK_TREE.md TRACE-OBSERVABILITY row; MEMORY.md next_action; TRACE-OBSERVABILITY.4.2-.4.4 Rust trace work"
reverify: "rg -n 'TRACE-OBSERVABILITY\\.3\\.5|TRACE-OBSERVABILITY\\.4\\.5|trace_generated_handler_branch|non-repetition generated|repetition|min/max|ActionIR owner|backend parity|rust_runtime:engine' docs/tasks/TRACE-OBSERVABILITY.md docs/TASK_TREE.md MEMORY.md LIVE_ACHIEVEMENT_STATUS.md perl/LinkedSpec/Trace.pm rust/linkedspec-runtime/src"
---

`TRACE-OBSERVABILITY.3` is a split parent, not an implementation leaf. `TRACE-OBSERVABILITY.3.1` has since closed
the smallest reusable Perl generated-handler trace helper seam before modifying branch templates.

The sequence is:

- `.3.1`: generated-handler trace helper contract/seam (done);
- `.3.2`: non-repetition generated handler dispatch decisions (done);
- `.3.3`: repetition/min/max/zero-progress paths (done);
- `.3.4`: compile/ActionIR owner ENTER/EXIT and branch decisions (split and done through `.3.4.6`);
- `.3.5`: coverage closeout docs/probes and the backend-parity split decision (done).

Rust trace parity is split into `.4.*`. `.4.1` mapped the neutral mdBook trace contract onto Rust entrypoints and
owner boundaries before code; `.4.2` through `.4.4` have since added Rust controls, compile/spec-parser/
staged-dispatch events, and runtime branch/mark/capture events. The active frontier is `TRACE-OBSERVABILITY.4.5`
for cross-variant trace parity proof and the future-variant checklist.
