---
id: trace-observability-coverage-audit
title: TRACE-OBSERVABILITY Perl reference trace coverage is closed through contract no-drift; Rust trace parity remains open
answers:
  - "what does trace observability cover today"
  - "is linkedspec trace exhaustive"
  - "are generated handler branches traced"
  - "what is next after TRACE-OBSERVABILITY.1"
  - "what is next after TRACE-OBSERVABILITY.2"
  - "does rust have linkedspec trace"
date: 2026-07-04
status: current
tags: [trace, observability, task-tree, runtime, generated-handlers, rust]
evidence: "docs/tasks/TRACE-OBSERVABILITY.md Coverage Audit and .3.5 closeout; rg trace call-site inventory; TRACE-OBSERVABILITY.2 added bin/linkedspec CLI control; TRACE-OBSERVABILITY.3.1-.3.4.6 wired generated-handler, RuleIR, EmitContext, ActionIR pipeline, compact lowerer, and MethodLowering trace coverage; TRACE-OBSERVABILITY.3.5 no-drift suite; Rust trace search excluding corpus fixtures found no trace API/control hits"
reverify: "perl bin/linkedspec --help && prove -v -Iperl t/trace_cli.t t/trace_generated_handler_branch.t t/trace_generated_nonrep_dispatch.t t/trace_generated_rep_dispatch.t t/trace_ruleir_planning.t t/trace_emit_context_bridge.t t/trace_actionir_pipeline.t t/trace_actionir_compact_lowerers.t t/trace_actionir_method_lowering.t && rg -n 'TRACE-OBSERVABILITY\\.4\\.1|Rust currently has no analogous trace|variant-neutral trace contract' docs/tasks/TRACE-OBSERVABILITY.md docs/TASK_TREE.md MEMORY.md docs/linkedspec-book/src/public-api/trace-api.md docs/linkedspec-book/src/user-model/runtime-context-and-tracing.md"
---

`TRACE-OBSERVABILITY.1` is closed as a read-only coverage audit. The existing Perl reference trace framework is
real and useful: env/per-call/API controls configure `LinkedSpec::Trace`, and current output covers broad
`Get`/parser invocation scopes, per-rule runtime handler wrappers, selected compiler/resolver/validation decisions,
dumps, and mark/capture events.

The Perl reference gap sequence has since closed through `.3.5`: generated handler templates, RuleIR planning,
EmitContext owner bridge, ActionIR scanner/canonical/diagnostic/rewrite pipeline, compact lowerers, MethodLowering,
and no-drift contract probes are covered by focused tests and docs.

`TRACE-OBSERVABILITY.2` closed the CLI discoverability gap with `bin/linkedspec` and mdBook/TOOLBOX docs.
`TRACE-OBSERVABILITY.3` split the coverage-extension work, `.3.1` added the emitted-handler trace helper seam,
`.3.2` wired non-repetition generated handler branches, `.3.3` wired repetition generated handler branches, `.3.4.*`
closed compile/ActionIR coverage, and `.3.5` closed no-drift/contract docs.

The remaining observability gap is cross-variant trace parity. Rust has no equivalent trace API/sink surface outside
corpus fixture text, so `TRACE-OBSERVABILITY.4.1` owns Rust trace contract/design inventory before code.
