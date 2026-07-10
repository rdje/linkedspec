---
id: julia-controlled-corpus-execution
title: Julia controlled corpus execution composes validation through runtime
answers:
  - how does Julia execute controlled corpus fixtures
  - what does execute_corpus_fixtures return
  - how does Julia compare expected corpus output
  - does Julia corpus execution continue after failures
  - does Julia corpus execution preserve trace lines
  - does Julia corpus execution preserve structured diagnostics
  - how do Julia controlled fixtures parse staged function shells
  - what is JULIA-BACKEND-PARITY.6.1
  - how is the Julia 99 fixture corpus rollout split
  - what is JULIA-BACKEND-PARITY.6.2.0
date: 2026-07-10
status: current
tags: [julia, corpus, runtime, diagnostics, trace, user-functions, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.6.1 adds execution/result/query APIs in julia/src/corpus/CorpusManifest.jl and 24 focused assertions in julia/test/runtests.jl. Full Pkg.test() passes with 715 assertions and package status runtime-controlled-corpus."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'"
---

`execute_corpus_fixtures(path; parse_mode, spec_parser, trace_config)` first calls
`load_corpus_fixtures(path)`, then processes every manifest fixture in order through spec parsing,
`compile_spec(...)`, and `LinkedSpecRuntimeEngine` execution. The default parser is rule-only
`parse_spec(...)`; controlled tests may provide `spec_parser` for an already-projected staged function shell.

Each runtime output is compared structurally to `Any[fixture.expected_json]`. That single wrapper is the accepted
backend-neutral top-rule output shape. A fixture succeeds only when it matches and the complete wrapped output is
equal. A failure does not abort the run: parse, validate, compile, execute, no-match, output-mismatch, and unexpected
failures become `CorpusFixtureExecutionResult` records, and later fixtures still execute.

Every result retains the expected value, actual value/output when available, match/cursor state, captured trace
lines, structured runtime diagnostic when present, and failure text. `CorpusExecutionResult` query helpers expose
overall pass state, passed count, failures, and name-based lookup. Runtime engines receive the fixture name and
`input.spec` path so diagnostics remain attributable.

The controlled proof covers scalar output, nested arrays/hashes/null/boolean values, blind AND rule dispatch,
lifecycle return shape, exact-arity staged function calls, boundary capture plus debug trace evidence, runtime
diagnostics, output mismatch reporting, and continuation after failures. Multiline fixtures use newline statement
separation with no trailing semicolons.

This is a library execution surface, not full corpus parity. The Julia CLI and corpus-runner `--execute` command
remain deliberately unavailable, and the checked-in 99-fixture manifest is owned by later `.6` batches.

`JULIA-BACKEND-PARITY.6.2.0` splits that rollout before behavior changes: `.6.2.1` owns bounded selection/reporting,
`.6.2.2` owns starter fixtures 0–39, `.6.2.3` owns non-function fixtures 40–67, `.6.2.4` owns shipped-spec/parser-
smoke fixtures 68–98, and `.6.2.5` owns top-level function fixtures through the spec-defined shell. These mirror
the stable Dart workload windows but do not assume Dart and Julia share failure mechanisms.

Related facts: [[julia-corpus-manifest-io]], [[julia-core-spec-parser]], [[julia-compiled-spec-state]],
[[julia-diagnostics-trace-boundary]], [[julia-user-function-runtime-execution]],
[[dart-controlled-corpus-execution]], [[statement-separator-semantics]].
