---
id: trace-generated-nonrep-dispatch
title: TRACE-OBSERVABILITY.3.2 instruments non-repetition generated handler dispatch branches
answers:
  - "which generated handler branches are traced now"
  - "does trace cover non-repetition generated dispatch"
  - "are repetition generated handler branches traced yet"
  - "what branch names do generated handlers emit"
  - "how do I reverify generated non-repetition dispatch trace coverage"
date: 2026-07-04
status: current
tags: [trace, observability, generated-handlers, perl, task-tree, mdbook]
evidence: "perl/LinkedSpec/HandlerVariantEmitter.pm; t/trace_generated_nonrep_dispatch.t; docs/linkedspec-book/src/public-api/trace-api.md; docs/tasks/TRACE-OBSERVABILITY.md .3.2"
reverify: "perl -c -Iperl perl/LinkedSpec/HandlerVariantEmitter.pm && perl -c -Iperl t/trace_generated_nonrep_dispatch.t && prove -v -Iperl t/trace_generated_nonrep_dispatch.t && rg -n 'generated_handler_branch|non-repetition generated|TRACE-OBSERVABILITY\\.3\\.3|bcode_child_result|acode_index' docs/tasks/TRACE-OBSERVABILITY.md docs/TASK_TREE.md TOOLBOX.md docs/linkedspec-book/src/public-api/trace-api.md docs/linkedspec-book/src/user-model/runtime-context-and-tracing.md perl/LinkedSpec/HandlerVariantEmitter.pm"
---

`TRACE-OBSERVABILITY.3.2` wires Perl reference non-repetition generated handlers through
`LinkedSpec::Trace::trace_generated_handler_branch(...)`.

Covered non-repetition branches:

- regex match/miss checks: `match`, `no_match_lx`;
- acode dispatch: `acode_index_<n>`;
- AND single/sequence checks: `required_index_0`, `required_sequence_index`;
- bcode dispatch/result checks: `bcode_call_<Rule>`, `bcode_child_result`, and `bcode_no_child_match`.

These events are debug-level `DECISION generated_handler_branch:<handler_kind>:<rule_label>:<branch>` trace lines.
`TRACE-OBSERVABILITY.3.3` still owns repetition min/max, loop continuation, and zero-progress branch tracing.
