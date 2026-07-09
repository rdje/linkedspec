---
id: dart-runtime-diagnostics-trace-split
title: Dart runtime diagnostics and trace controls are split into four implementation leaves
answers:
  - what owns Dart runtime diagnostics
  - what owns Dart trace controls
  - how is DART-BACKEND-PARITY.4.5 split
  - what is next after Dart cursor controls
  - where will Dart runtime trace instrumentation land
date: 2026-07-09
status: current
tags: [dart, runtime, diagnostics, trace, task-tree, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.4.5.0 split the broad .4.5 runtime diagnostics/trace-controls leaf before code in docs/tasks/DART-BACKEND-PARITY.md and docs/TASK_TREE.md."
reverify: "rg -n 'DART-BACKEND-PARITY\\.4\\.5\\.(0|1|2|3|4)|runtime diagnostics|trace controls|structured runtime diagnostics|runtime trace instrumentation' docs/tasks/DART-BACKEND-PARITY.md docs/TASK_TREE.md ROADMAP_V2.md docs/knowledge/dart-runtime-diagnostics-trace-split.md"
---

`DART-BACKEND-PARITY.4.5` is a container, not a single executable implementation leaf.

The split is:

- `.4.5.0`: done planning split before code;
- `.4.5.1`: done — structured runtime diagnostics and diagnostic-carrying runtime exceptions;
- `.4.5.2`: done — trace levels, controls, structured event classes, and stdout/routed-file/mirror sinks;
- `.4.5.3`: runtime interpreter branch, lifecycle, dispatch, and source-boundary trace instrumentation;
- `.4.5.4`: no-drift closeout across Dart README/CLI status, mdBook, live docs, task-tree index, and Knowledge Map.

The active executable frontier after `.4.5.2` is `DART-BACKEND-PARITY.4.5.3`.

Related facts: [[dart-runtime-rule-interpreter]], [[dart-runtime-backtrack-cursor-helpers]],
[[dart-runtime-structured-diagnostics]], [[dart-trace-controls-sinks]],
[[trace-cross-variant-capability-contract]].
