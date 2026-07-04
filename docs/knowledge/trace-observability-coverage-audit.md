---
id: trace-observability-coverage-audit
title: TRACE-OBSERVABILITY trace is usable but not exhaustive; CLI control and generated-handler helper seam are now closed, while template coverage and Rust parity remain gaps
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
evidence: "docs/tasks/TRACE-OBSERVABILITY.md Coverage Audit; rg trace call-site inventory; dump_parser_source probe showed generated while/unless branches without emitted trace_decision/trace_enter/trace_exit; rust/linkedspec-runtime trace search found no runtime trace API; TRACE-OBSERVABILITY.2 added bin/linkedspec CLI control; TRACE-OBSERVABILITY.3.1 added trace_generated_handler_branch"
reverify: "rg -n 'Coverage Audit|TRACE-OBSERVABILITY.1|TRACE-OBSERVABILITY.2|TRACE-OBSERVABILITY.3.2|trace_generated_handler_branch|Rust currently has no analogous trace|bin/linkedspec' docs/tasks/TRACE-OBSERVABILITY.md docs/TASK_TREE.md MEMORY.md docs/linkedspec-book/src/public-api/trace-api.md docs/linkedspec-book/src/user-model/runtime-context-and-tracing.md perl/LinkedSpec/Trace.pm t/trace_generated_handler_branch.t bin/linkedspec t/trace_cli.t"
---

`TRACE-OBSERVABILITY.1` is closed as a read-only coverage audit. The existing Perl reference trace framework is
real and useful: env/per-call/API controls configure `LinkedSpec::Trace`, and current output covers broad
`Get`/parser invocation scopes, per-rule runtime handler wrappers, selected compiler/resolver/validation decisions,
dumps, and mark/capture events.

It is not exhaustive. Generated handler bodies from `HandlerVariantEmitter` now have a reusable branch helper
contract available, but the templates still contain unwired `while`, `foreach`, `if`/`elsif`, `unless`,
acode/bcode dispatch, repetition min/max, zero-progress, no-match, `LX`, and `EX` paths. Most ActionIR owner
lowering branches also lack ENTER/EXIT or decision trace. The Rust runtime has no equivalent trace API/sink
surface.

`TRACE-OBSERVABILITY.2` has since closed the CLI discoverability gap with `bin/linkedspec` and mdBook/TOOLBOX
docs. `TRACE-OBSERVABILITY.3` has since split the coverage-extension work, and `.3.1` has added the emitted-handler
trace helper seam. PNT frontier is `TRACE-OBSERVABILITY.3.2`: wire non-repetition generated handler branches to
that helper.
