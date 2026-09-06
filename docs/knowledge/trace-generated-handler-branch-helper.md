---
id: trace-generated-handler-branch-helper
title: TRACE-OBSERVABILITY.3.1 added the generated-handler branch trace helper contract
answers:
  - "what is trace_generated_handler_branch"
  - "how should generated handler branch tracing be emitted"
  - "does the generated handler trace helper change branch behavior"
  - "what helper should generated handler templates use"
  - "what follows TRACE-OBSERVABILITY.3.1"
date: 2026-07-04
status: current
tags: [trace, observability, generated-handlers, perl, task-tree, mdbook]
evidence: "perl/LinkedSpec/Trace.pm trace_generated_handler_branch; t/trace_generated_handler_branch.t; docs/linkedspec-book/src/public-api/trace-api.md; docs/tasks/TRACE-OBSERVABILITY.md .3.1"
reverify: "perl -c -Iperl perl/LinkedSpec/Trace.pm && perl -c -Iperl t/trace_generated_handler_branch.t && prove -v -Iperl t/trace_generated_handler_branch.t && prove -v -Iperl t/trace_generated_nonrep_dispatch.t && prove -v -Iperl t/trace_generated_rep_dispatch.t && rg -n 'trace_generated_handler_branch|generated_handler_branch|TRACE-OBSERVABILITY\\.3\\.4' docs/tasks/TRACE-OBSERVABILITY.md docs/TASK_TREE.md MEMORY.md docs/linkedspec-book/src/public-api/trace-api.md docs/linkedspec-book/src/user-model/runtime-context-and-tracing.md"
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
- captures detail-builder errors in trace text and retains the branch result. Direct lazy callbacks
  currently overwrite incoming Perl exception state; `SESSION-STARTUP-READING.24` owns that defect.

`TRACE-OBSERVABILITY.3.2` wires non-repetition generated handler call sites through this helper, and
`TRACE-OBSERVABILITY.3.3` wires repetition/min/max/zero-progress paths through the same helper. Remaining coverage
work starts at `TRACE-OBSERVABILITY.3.4` for compile/ActionIR owner scopes and branches.

## September 6 exception-state qualification

`SESSION-STARTUP-READING.3.2.48` reads the complete Trace owner and the complete 130-line helper test.
The old “does not perturb” wording was broader than the test: its outer eval proves callback errors
do not escape and the branch result survives, but does not preserve an incoming `$@` for comparison.
Direct versus OwnerDispatch controls, including object identity and nested details, are recorded in
[[perl-lazy-trace-exception-state-drift]]. The generated emitter uses the direct owner call.

The three managed existing suites pass 11 top-level tests in 23 seconds:
`bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/trace_generated_handler_branch.t t/trace_generated_nonrep_dispatch.t t/trace_generated_rep_dispatch.t`.
This current success coexists with the incoming-exception defect; no runtime change is installed.
