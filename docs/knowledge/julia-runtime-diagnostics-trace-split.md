---
id: julia-runtime-diagnostics-trace-split
title: Julia runtime diagnostics and trace controls are split into four implementation leaves
answers:
  - what owns Julia runtime diagnostics
  - what owns Julia trace controls
  - how is JULIA-BACKEND-PARITY.4.5 split
  - what is next after Julia cursor controls
  - where will Julia runtime trace instrumentation land
date: 2026-07-10
status: current
tags: [julia, runtime, diagnostics, trace, task-tree, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.4.5.0 splits the broad Julia runtime diagnostics/trace-controls leaf before code in docs/tasks/JULIA-BACKEND-PARITY.md and docs/TASK_TREE.md, following the portable mdBook trace checklist and the completed Dart mechanism split."
reverify: "rg -n 'JULIA-BACKEND-PARITY\\.4\\.5\\.(0|1|2|3|4)|structured runtime diagnostics|trace controls|runtime instrumentation|diagnostics/trace' docs/tasks/JULIA-BACKEND-PARITY.md docs/TASK_TREE.md ROADMAP_V2.md docs/knowledge/julia-runtime-diagnostics-trace-split.md"
---

`JULIA-BACKEND-PARITY.4.5` is a container, not one executable implementation
leaf.

The split is:

- `.4.5.0`: planning split before code;
- `.4.5.1`: done — structured runtime diagnostics and diagnostic-carrying exceptions;
- `.4.5.2`: done — ordered trace levels, configuration/environment controls,
  structured events, traced entrypoints, and stdout/routed-file/mirror sinks;
- `.4.5.3`: runtime interpreter rule/regex/dispatch/lifecycle/recursion/cursor/
  boundary trace instrumentation;
- `.4.5.4`: no-drift closeout across Julia status, mdBook, live docs, task-tree
  index, and Knowledge Map.

The active executable frontier after `.4.5.2` is
`JULIA-BACKEND-PARITY.4.5.3`. Julia-native exception, configuration, and I/O
types may differ from Dart and Rust, but each leaf maps to the same portable
diagnostic/trace capability contract.

Related facts: [[julia-runtime-cursor-boundary-helpers]],
[[julia-runtime-structured-diagnostics]],
[[julia-trace-controls-sinks]],
[[dart-runtime-diagnostics-trace-split]],
[[trace-cross-variant-capability-contract]], [[trace-backend-parity-split]].
