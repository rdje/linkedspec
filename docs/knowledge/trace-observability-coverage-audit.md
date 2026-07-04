---
id: trace-observability-coverage-audit
title: TRACE-OBSERVABILITY trace is usable but not exhaustive; CLI and generated-handler template coverage are now partly closed, while ActionIR coverage and Rust parity remain gaps
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
evidence: "docs/tasks/TRACE-OBSERVABILITY.md Coverage Audit; rg trace call-site inventory; dump_parser_source probe showed generated while/unless branches without emitted trace_decision/trace_enter/trace_exit at .1 time; rust/linkedspec-runtime trace search found no runtime trace API; TRACE-OBSERVABILITY.2 added bin/linkedspec CLI control; TRACE-OBSERVABILITY.3.1 added trace_generated_handler_branch; TRACE-OBSERVABILITY.3.2/.3.3 wired non-REP and REP generated templates"
reverify: "rg -n 'Coverage Audit|TRACE-OBSERVABILITY.1|TRACE-OBSERVABILITY.2|TRACE-OBSERVABILITY.3.2|TRACE-OBSERVABILITY.3.3|trace_generated_handler_branch|Rust currently has no analogous trace|bin/linkedspec|ActionIR' docs/tasks/TRACE-OBSERVABILITY.md docs/TASK_TREE.md MEMORY.md docs/linkedspec-book/src/public-api/trace-api.md docs/linkedspec-book/src/user-model/runtime-context-and-tracing.md perl/LinkedSpec/Trace.pm perl/LinkedSpec/HandlerVariantEmitter.pm t/trace_generated_handler_branch.t t/trace_generated_nonrep_dispatch.t t/trace_generated_rep_dispatch.t bin/linkedspec t/trace_cli.t"
---

`TRACE-OBSERVABILITY.1` is closed as a read-only coverage audit. The existing Perl reference trace framework is
real and useful: env/per-call/API controls configure `LinkedSpec::Trace`, and current output covers broad
`Get`/parser invocation scopes, per-rule runtime handler wrappers, selected compiler/resolver/validation decisions,
dumps, and mark/capture events.

It is not exhaustive. `TRACE-OBSERVABILITY.3.2` and `.3.3` have since wired Perl reference generated handler
templates for non-repetition dispatch and repetition loop branches, including acode/bcode dispatch, no-match/`LX`,
min/max, iteration result, and bcode zero-progress decisions. Most ActionIR owner lowering branches still lack
ENTER/EXIT or decision trace. The Rust runtime has no equivalent trace API/sink surface.

`TRACE-OBSERVABILITY.2` closed the CLI discoverability gap with `bin/linkedspec` and mdBook/TOOLBOX docs.
`TRACE-OBSERVABILITY.3` split the coverage-extension work, `.3.1` added the emitted-handler trace helper seam,
`.3.2` wired non-repetition generated handler branches, and `.3.3` wired repetition generated handler branches.
PNT frontier after `.3.3` is `.3.4`: compile/ActionIR owner scopes and decisions.
