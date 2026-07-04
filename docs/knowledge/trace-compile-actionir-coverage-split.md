---
id: trace-compile-actionir-coverage-split
title: TRACE-OBSERVABILITY.3.4 splits compile and ActionIR trace coverage before code
answers:
  - "how is compile ActionIR trace coverage split"
  - "what comes after generated handler trace coverage"
  - "what is TRACE-OBSERVABILITY.3.4.1"
  - "why is MethodLowering trace instrumentation separate"
  - "which ActionIR owners need trace instrumentation"
date: 2026-07-04
status: current
tags: [trace, observability, actionir, ruleir, task-tree]
evidence: "docs/tasks/TRACE-OBSERVABILITY.md .3.4 split; read-only owner sizing with wc -l; rg trace call-site inventory"
reverify: "rg -n 'TRACE-OBSERVABILITY\\.3\\.4|TRACE-OBSERVABILITY\\.3\\.4\\.1|MethodLowering|EmitContext|RuleIR planning|scanner/canonical' docs/tasks/TRACE-OBSERVABILITY.md docs/TASK_TREE.md MEMORY.md CHANGES.md DEVELOPMENT_NOTES.md LIVE_ACHIEVEMENT_STATUS.md"
---

`TRACE-OBSERVABILITY.3.4` is split before code because compile/ActionIR trace coverage spans too many owners for
one signoff slice.

Execution order:

- `.3.4.1`: RuleIR planning decisions;
- `.3.4.2`: EmitContext owner bridge and rewrite orchestration boundaries;
- `.3.4.3`: scanner, canonical events, diagnostics, and rewrite-pipeline decisions;
- `.3.4.4`: compact value/flow/control/declaration/array lowering owners;
- `.3.4.5`: `ActionIR::MethodLowering` as a separate large-owner leaf;
- `.3.4.6`: compile/ActionIR coverage closeout probes and docs.

`MethodLowering.pm` is separate because it is the largest ActionIR owner and contains many helper-family,
assignment/mutation, receiver-chain, AST-vs-string fallback, and unsupported-form branch decisions.
