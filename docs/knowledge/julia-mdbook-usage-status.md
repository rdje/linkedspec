---
id: julia-mdbook-usage-status
title: Julia mdBook usage and status describe the native 99 of 99 interpreter boundary
answers:
  - where does the mdBook document Julia usage
  - what Julia commands should the book show
  - how does the mdBook explain Julia parity status
  - does the mdBook include a Julia in-memory example
  - what limitations remain after Julia reaches 99 of 99
  - is generated Julia source part of current parity
  - does Julia claim compile and parser trace parity
  - what does JULIA-BACKEND-PARITY.7.1 prove
date: 2026-07-10
status: current
tags: [julia, mdbook, documentation, parity, embedding, limitations, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.7.1 documents native usage and 99/99; .7.3.2.4 documents stable primary failures and trace routing after execution/JSON. Current suite is 1,017; .7.3.2.5 owns direct no-drift."
reverify: "rg -n 'Julia Backend Commands, Embedding, and Status|Julia in-memory example|runtime-corpus-full|run_julia_local|LINKEDSPEC_RUN_JULIA|generated Julia source|compile/parser trace parity|JULIA-BACKEND-PARITY\.7\.3\.2\.1' docs/linkedspec-book/src/appendix/backend-handoff.md docs/linkedspec-book/src/public-api/get-and-get-parser.md docs/linkedspec-book/src/public-api/trace-api.md docs/linkedspec-book/src/overview/project-status.md docs/linkedspec-book/src/development/local-ci-and-regression.md docs/tasks/JULIA-BACKEND-PARITY.md && mdbook build docs/linkedspec-book"
---

The mdBook presents Julia as a native in-memory LinkedSpec backend, not as a command-line clone or an unfinished
scaffold. The backend handoff and public API pages show both rule-only `parse_spec(...)` and top-level-function
`parse_spec_with_staged_user_function_definitions(...)`, followed by native compilation and runtime execution.
The examples keep `.spec` source and input values in the Julia process and require no CLI, subprocess, temporary
file, or raw Julia function scanner.

The focused gate is:

```bash
bash tools/run_julia_local.sh
```

Direct package/full-corpus commands and opt-in shared CI through `LINKEDSPEC_RUN_JULIA=1` are also documented.
The accepted interpreter-first boundary is 99/99 exact corpus outputs, 1,017 package assertions, and package/CLI
status `runtime-corpus-full`.

The limitations are explicit. Generated Julia source is not part of the current interpreter gate; `.7.2` defers
it to the future split source-emitter lane under `FUTURE-PARITY-BACKLOG.3`. ADR `0023` makes it mandatory before
complete public parity. `.7.3.2.0` splits the exact primary CLI into five mechanisms; `.7.3.2.1` now closes shared-
emitter parse/validation/compile/function-shell/staged trace coverage. `.7.3.2.2` closes exact options/resolution/
loading, `.7.3.2.3` closes native execution/direct canonical JSON, and `.7.3.2.4` closes normalized errors/exits/
trace routing. `.7.3.2.5` remains active for direct-process no-drift. `JuliaFormatter`
and `JET` remain optional local tooling rather than behavior prerequisites.

Related facts: [[user-observable-backend-cli-parity-contract]], [[julia-generated-source-deferred]], [[julia-local-verification-gate]], [[julia-full-corpus-gate]],
[[julia-spec-driven-function-shell-parser]], [[native-in-memory-backend-contract]],
[[dart-mdbook-usage-status]], [[julia-primary-cli-mechanism-audit]],
[[julia-frontend-compiler-staged-trace-events]], [[julia-primary-cli-arguments-resolution-loading]],
[[julia-primary-cli-native-execution-canonical-json]],
[[julia-primary-cli-failure-trace-routing]].
