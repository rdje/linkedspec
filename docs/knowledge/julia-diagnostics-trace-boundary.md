---
id: julia-diagnostics-trace-boundary
title: Julia runtime diagnostics and trace boundary is closed; parser and compiler trace remain active
answers:
  - is Julia diagnostics trace no-drift closed
  - what is the Julia frontier after JULIA-BACKEND-PARITY.4.5.4
  - does Julia have structured runtime diagnostics and trace events
  - does Julia claim full trace parity after diagnostics trace closeout
  - what Julia trace coverage remains before primary CLI trace options
date: 2026-07-10
status: current
tags: [julia, diagnostics, trace, runtime, task-tree, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.4.5.4 closes the runtime diagnostics/trace container. The later .7.3.2.0 primary-CLI audit confirms compile/spec-parser/function-shell/staged trace remains outside that scoped claim and assigns it to active .7.3.2.1."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()' && rg -n 'JULIA-BACKEND-PARITY\.4\.5\.4|JULIA-BACKEND-PARITY\.7\.3\.2\.1|runtime-trace-events|RuntimeDiagnostic|LinkedSpecTrace' docs/tasks/JULIA-BACKEND-PARITY.md docs/TASK_TREE.md julia/README.md julia/src docs/linkedspec-book/src/public-api/trace-api.md docs/linkedspec-book/src/overview/project-status.md docs/linkedspec-book/src/appendix/backend-handoff.md MEMORY.md ROADMAP_V2.md"
---

`JULIA-BACKEND-PARITY.4.5.4` closes the Julia diagnostics/trace no-drift
sweep.

The implemented boundary is:

- structured runtime diagnostics through exported `RuntimeDiagnostic` on
  `RuntimeInterpreterException.diagnostic`;
- trace levels, config/environment controls, event/scope primitives, and
  stdout/routed-file/mirror sinks;
- traced runtime entrypoints that preserve parse output;
- runtime interpreter trace events for parse/rule scopes, regex decisions,
  action/blind child dispatch, lifecycle marks, cursor/source-boundary marks,
  and recursion cutoffs.

The historical package/CLI status at this boundary was the precise
`runtime-trace-events`. This closeout does not overclaim complete compile/parser
trace parity. `.7.3.2.0` later audited that residual for the exact primary CLI and
made `.7.3.2.1` active for source parse/validation/compile, function-shell, and
staged-dispatch events through the same trace controls/sinks. `.5.1` added the minimal staged registry
provider, `.5.2` has since added registered function execution, `.5.3` has closed descriptor-shape parity, and
`.6.1` added controlled corpus execution; the interpreter corpus has since reached 99/99.

Related facts: [[julia-runtime-structured-diagnostics]],
[[julia-trace-controls-sinks]], [[julia-runtime-trace-events]],
[[julia-staged-function-body-registry]],
[[julia-user-function-runtime-execution]],
[[trace-cross-variant-capability-contract]], [[julia-primary-cli-mechanism-audit]].
