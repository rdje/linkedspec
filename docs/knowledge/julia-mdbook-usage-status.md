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
evidence: "JULIA-BACKEND-PARITY.7.1 documents native usage and 99/99; FUTURE-PARITY-BACKLOG.1.5.4.2 documents canonical trace, 1,019 assertions, and 61/61 default/POSIX CLI identity."
reverify: "rg -n 'Julia Backend Commands, Embedding, and Status|Julia in-memory example|runtime-corpus-primary-cli|check_julia_primary_cli|run_julia_local|LINKEDSPEC_RUN_JULIA|generated Julia source' docs/linkedspec-book/src/appendix/backend-handoff.md docs/linkedspec-book/src/public-api/get-and-get-parser.md docs/linkedspec-book/src/public-api/trace-api.md docs/linkedspec-book/src/overview/project-status.md docs/linkedspec-book/src/development/local-ci-and-regression.md docs/tasks/JULIA-BACKEND-PARITY.md && mdbook build docs/linkedspec-book"
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
The current local boundary is 99/99 exact corpus outputs, 1,019 package assertions, nine direct process families,
and package/CLI status `runtime-corpus-primary-cli`.

The limitations are explicit. Generated Julia source is not part of the current interpreter gate; `.7.2` defers
it to the future split source-emitter lane under `FUTURE-PARITY-BACKLOG.3`. ADR `0023` makes it mandatory before
complete public parity. `.7.3.2.0` splits the exact primary CLI into five mechanisms; `.7.3.2.1` now closes shared-
emitter parse/validation/compile/function-shell/staged trace coverage. `.7.3.2.2` closes exact options/resolution/
loading, `.7.3.2.3` closes native execution/direct canonical JSON, `.7.3.2.4` closes normalized errors/exits/trace
routing, and `.7.3.2.5` closes direct-process no-drift. Global `.1.5.4.1`/`.2` then close exact boundary and
canonical trace at 61/61; `.1.5.4.3` now closes recurring matrix integration. The Julia root remains delegated to
global `.1.6` and `.3` rather than being presented as complete parity. `JuliaFormatter`
and `JET` remain optional local tooling rather than behavior prerequisites.

Related facts: [[user-observable-backend-cli-parity-contract]], [[julia-generated-source-deferred]], [[julia-local-verification-gate]], [[julia-full-corpus-gate]],
[[julia-spec-driven-function-shell-parser]], [[native-in-memory-backend-contract]],
[[dart-mdbook-usage-status]], [[julia-primary-cli-mechanism-audit]],
[[julia-frontend-compiler-staged-trace-events]], [[julia-primary-cli-arguments-resolution-loading]],
[[julia-primary-cli-native-execution-canonical-json]],
[[julia-primary-cli-failure-trace-routing]], [[julia-primary-cli-process-conformance]],
[[julia-scoped-parity-no-drift]], [[julia-canonical-primary-cli-trace]].
