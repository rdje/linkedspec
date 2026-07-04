---
id: trace-generated-rep-dispatch
title: TRACE-OBSERVABILITY.3.3 instruments repetition generated handler loop branches
answers:
  - "are repetition generated handler branches traced yet"
  - "does trace cover REP min max loop decisions"
  - "which REP generated handler branch names are traced"
  - "how do I reverify generated repetition dispatch trace coverage"
  - "does generated trace cover zero progress cutoff"
date: 2026-07-04
status: current
tags: [trace, observability, generated-handlers, repetition, perl, task-tree, mdbook]
evidence: "perl/LinkedSpec/HandlerVariantEmitter.pm; t/trace_generated_rep_dispatch.t; t/trace_generated_nonrep_dispatch.t; docs/linkedspec-book/src/public-api/trace-api.md; docs/tasks/TRACE-OBSERVABILITY.md .3.3"
reverify: "perl -c -Iperl perl/LinkedSpec/HandlerVariantEmitter.pm && perl -c -Iperl t/trace_generated_rep_dispatch.t && prove -v -Iperl t/trace_generated_rep_dispatch.t && prove -v -Iperl t/trace_generated_nonrep_dispatch.t && rg -n 'loop_enter|iteration_result|miss_min_satisfied|max_continue|zero_progress' perl/LinkedSpec/HandlerVariantEmitter.pm t/trace_generated_rep_dispatch.t docs/tasks/TRACE-OBSERVABILITY.md docs/linkedspec-book/src/public-api/trace-api.md docs/linkedspec-book/src/user-model/runtime-context-and-tracing.md TOOLBOX.md"
---

`TRACE-OBSERVABILITY.3.3` wires Perl reference repetition generated handlers through
`LinkedSpec::Trace::trace_generated_handler_branch(...)`.

Covered REP branches:

- all REP families: `loop_enter`, `iteration_result`, `miss_min_satisfied`, and `max_continue`;
- `REP_ACODE`: `match` and `acode_index_<n>` in addition to the common REP loop branches;
- bcode REP families: `zero_progress` and `zero_progress_min_satisfied`.

These events are debug-level `DECISION generated_handler_branch:<handler_kind>:<rule_label>:<branch>` trace lines.
`REP_BCODE`, `REP_AND_BCODE`, `REP_AND_ACODE`, and `REP_ACODE` templates are source-locked by the focused test;
runtime probes lock representative `REP_ACODE` and `REP_AND_ACODE` behavior.
