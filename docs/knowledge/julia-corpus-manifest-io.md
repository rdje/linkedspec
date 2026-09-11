---
id: julia-corpus-manifest-io
title: Julia corpus manifest IO and drift guard
answers:
  - how does Julia validate the corpus manifest
  - does Julia load the current 105 fixture corpus
  - why do older Julia corpus records say 99 fixtures
  - does Julia detect missing stale fixture directories
  - does Julia parse expected.json yet
  - does Julia corpus execute all fixtures
date: 2026-07-10
status: accepted
tags: [julia, corpus, manifest, json, backend]
evidence: "JULIA-BACKEND-PARITY.1.3 adds strict manifest IO and .6.3 permanently executes 99/99 through the runner. .7.3.2.5 retains 99/99 with 1,017 assertions at runtime-corpus-primary-cli."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'"
---

## Fact

`JULIA-BACKEND-PARITY.1.3` adds JSON3-backed corpus manifest IO for Julia. `load_corpus_fixtures(path)` validates
the corpus directory, manifest format `1`, `case_count`, case-name shape, duplicate names, missing/stale fixture
directories, required `input.spec` / `input.txt` / `expected.json` files, and expected JSON syntax.

The July admission loaded 99 fixtures under `rust/linkedspec-runtime/tests/corpus`. The Julia CLI and
corpus-runner non-execute commands report the validated fixture count. `JULIA-BACKEND-PARITY.6.1` now composes
this loader into the library-level `execute_corpus_fixtures(...)` controlled executor. `.6.2.1` adds selected CLI
execution/reporting. `.6.3` now locks the complete validated manifest at 99/99 exact outputs and enables bare
`--execute` as the full run.

Related facts: [[julia-full-corpus-gate]], [[julia-controlled-corpus-execution]], [[julia-corpus-selection-reporting]].

The September 11 `JULIA-STARTUP-READING.1.7` intake replays the existing `Corpus manifest IO`
testset: 20 assertions pass, plus one selected-testset equality assertion. The current loader and
validation-only CLI report 105 fixtures. The 99-fixture statements above are historical admission
evidence. This reading slice does not rerun complete corpus execution or grant reading credit to
the unread loader suffix. `CorpusManifest.jl:1-161` defines manifest/fixture/result records,
pass/failure helpers and the beginning of CLI parsing; its continuation is owned by `.1.8`.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_CORPUS_IO_REPLAY'
using LinkedSpecJulia, JSON3, Test
const REPO_ROOT=pwd()
const CORPUS_ROOT=joinpath(REPO_ROOT,"rust/linkedspec-runtime/tests/corpus")
const selected=Set(["Corpus manifest IO"])
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
JULIA_CORPUS_IO_REPLAY
```
