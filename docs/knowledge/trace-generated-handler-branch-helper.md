---
id: trace-generated-handler-branch-helper
title: TRACE-OBSERVABILITY.3.1 added the generated-handler branch trace helper contract
answers:
  - "what is trace_generated_handler_branch"
  - "how should generated handler branch tracing be emitted"
  - "does the generated handler trace helper change branch behavior"
  - "are generated handler templates instrumented yet"
  - "what follows TRACE-OBSERVABILITY.3.1"
date: 2026-07-04
status: current
tags: [trace, observability, generated-handlers, perl, task-tree, mdbook]
evidence: "perl/LinkedSpec/Trace.pm trace_generated_handler_branch; t/trace_generated_handler_branch.t; docs/linkedspec-book/src/public-api/trace-api.md; docs/tasks/TRACE-OBSERVABILITY.md .3.1"
reverify: "perl -c -Iperl perl/LinkedSpec/Trace.pm && perl -c -Iperl t/trace_generated_handler_branch.t && prove -v -Iperl t/trace_generated_handler_branch.t && prove -v -Iperl t/trace_generated_nonrep_dispatch.t && rg -n 'trace_generated_handler_branch|generated_handler_branch|TRACE-OBSERVABILITY\\.3\\.3' docs/tasks/TRACE-OBSERVABILITY.md docs/TASK_TREE.md MEMORY.md docs/linkedspec-book/src/public-api/trace-api.md docs/linkedspec-book/src/user-model/runtime-context-and-tracing.md"
---

`LinkedSpec::Trace::trace_generated_handler_branch(%args)` is the Perl reference helper contract for generated
handler branch decisions.

Contract:

- returns the normalized original `taken` boolean;
- emits `DECISION generated_handler_branch:<handler_kind>:<rule_label>:<branch> => TAKEN|SKIPPED` when the event
  level is enabled;
- records rule, handler kind, branch, and optional emitted metadata such as `match_index`, `call`, `pos`,
  `loop_count`, `rep_min`, and `rep_max`;
- evaluates `details => sub { ... }` only when tracing is enabled;
- captures detail-builder errors in trace text instead of perturbing parser behavior.

`TRACE-OBSERVABILITY.3.2` now wires non-repetition generated handler call sites through this helper.
`TRACE-OBSERVABILITY.3.3` owns repetition/min/max/zero-progress paths.
