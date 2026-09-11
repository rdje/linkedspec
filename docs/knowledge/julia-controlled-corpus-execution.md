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
evidence: "JULIA-BACKEND-PARITY.6.1 adds execution/result/query APIs, .6.2.5 adds function shells, and .6.3 permanently runs 99/99. .7.3.2.5 retains 99/99 with 1,017 assertions at runtime-corpus-primary-cli."
reverify: "bash tools/run_julia_project_data.sh --project=julia -e 'using Pkg; Pkg.test()'"
---

`execute_corpus_fixtures(path; spec_parser, trace_config, case_names, offset, limit)` first calls
`load_corpus_fixtures(path)`, then processes every manifest fixture in order through spec parsing,
`compile_spec(...)`, and `LinkedSpecRuntimeEngine` execution. The default path first tries rule-only
`parse_spec(...)`; after a source parse error it executes `specs/user_function_definition.spec` and composes its
neutral nodes with the existing staged body parser. Callers may still provide `spec_parser` to control parsing.

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

This composition underpins full corpus parity. At the July admission all three routed top-level function fixtures passed through the
spec-defined shell, and `.6.3` admitted the then-complete 99-fixture manifest with exact outputs.

`JULIA-BACKEND-PARITY.6.2.0` splits that rollout before behavior changes: `.6.2.1` owns bounded selection/reporting,
`.6.2.2` owns starter fixtures 0–39, `.6.2.3` owns non-function fixtures 40–67, and `.6.2.4.0` has split the
measured shipped-spec/parser-smoke boundary for fixtures 68–98; later mechanism leaves close that window at 31/31.
`.6.2.5` closes all three top-level function fixtures through the spec-defined shell. `.6.3` closes the separate
complete-manifest gate at 99/99. These mirror the stable Dart workload windows but do not assume Dart and Julia
share failure mechanisms.

Related facts: [[julia-full-corpus-gate]], [[julia-spec-driven-function-shell-parser]], [[julia-helper-regex-flag-normalization]], [[julia-logical-helper-execution]], [[julia-anonymous-capture-boundary-helpers]], [[julia-shipped-corpus-smoke-split]], [[julia-corpus-selection-reporting]], [[julia-corpus-manifest-io]], [[julia-core-spec-parser]],
[[julia-compiled-spec-state]],
[[julia-diagnostics-trace-boundary]], [[julia-user-function-runtime-execution]],
[[dart-controlled-corpus-execution]], [[statement-separator-semantics]].

September 11 `JULIA-STARTUP-READING.1.8` reads `CorpusManifest.jl` through EOF and
replays the existing controlled-execution testset: 58 assertions pass. The loader validates the
whole current manifest before selection; selected outcomes retain caller order, detached expected/actual
values, cursor, trace lines and structured runtime diagnostics. Per-fixture parse/validate/compile/
execute/unexpected failures are recorded without aborting later fixtures. The runner uses exits 0/1/2
for passing execution, fixture failure, and argument/manifest/selection failure respectively.
The current manifest has 105 fixtures (see [[julia-corpus-manifest-io]]); earlier 99 counts are historical.
The removed global cursor option is rejected before manifest IO, per [[julia-global-cursor-option-removal]].

Exact focused replay (supporting test execution grants no future physical-reading credit):

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_GROUP8_REPLAY'
using LinkedSpecJulia, JSON3, Test
const REPO_ROOT=pwd()
const CORPUS_ROOT=joinpath(REPO_ROOT,"rust/linkedspec-runtime/tests/corpus")
const selected=Set(["Controlled corpus execution"])
const seen=Set{String}()
for expression in Meta.parseall(read("julia/test/runtests.jl",String)).args
    expression isa Expr || continue
    if expression.head==:function
        Core.eval(Main,expression)
    elseif expression.head==:macrocall && expression.args[1]==Symbol("@testset") && expression.args[3] in selected
        Core.eval(Main,expression);push!(seen,expression.args[3])
    end
end
@test seen==selected
include("julia/test/spec_loader_test.jl")
include("julia/test/mcp_contract_julia_binding_test.jl")
JULIA_GROUP8_REPLAY
```

The direct-dependent removed-option replay passes 53 assertions:

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_GROUP8_OPTIONS'
using LinkedSpecJulia, JSON3, Test
const REPO_ROOT=pwd()
include("julia/test/rule_local_cursor_option_removal_test.jl")
JULIA_GROUP8_OPTIONS
```
