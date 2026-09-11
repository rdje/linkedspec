---
id: julia-runtime-matching-state
title: Julia runtime matching uses native PCRE with stable alternatives and entry/local registers
answers:
  - where is the Julia runtime matching code
  - does Julia support seek and consume regex matching
  - how does Julia track entry and local match state
  - does Julia expose character offsets for match positions
  - how does Julia detect zero-progress matches
  - does Julia need regex dialect normalization
  - does Julia Regex support Python named captures POSIX flags possessive and recursion
date: 2026-07-10
status: current
tags: [julia, runtime, regex, match-state, PCRE, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.4.1 adds julia/src/runtime/Matching.jl and exports LinkedSpecParseMode, RuntimeRegexAlternative, RuntimeRegexAlternation, RuntimeRegexMatch, RuntimeMatchRegisters, RuntimeLineColumn, match/offset/register helpers, and JSON projection. julia/test/runtests.jl verifies seek/consume behavior, stable alternative identity, compiled-rule patterns, full/compact/named captures, multibyte character offsets, line/column positions, entry/local register separation, cursor and capture anchors, zero-width/progress detection, immutable updates, and boundary/input guards. Direct Julia 1.12 native Regex probes accept (?P<name>), (?<name>), POSIX classes, inline/scoped flags, possessive quantifiers, and (?R) recursion without a dialect rewrite."
reverify: "bash tools/run_julia_project_data.sh --project=julia -e 'using Pkg; Pkg.test()'"
---

## Fact

Julia runtime matching lives in `julia/src/runtime/Matching.jl`.

`RuntimeRegexAlternation` compiles ordered patterns, including `CompiledRule.regex_patterns`, into native Julia
`Regex` values. `seek_match(...)` selects the earliest candidate and breaks same-position ties by lower source
alternative; `consume_match(...)` accepts only a match that starts at the code-unit cursor. Alternative indexes are
stable zero-based values and do not depend on a combined-regex branch side channel.

`RuntimeRegexMatch` records the full group-slot vector, compact participating captures, named captures, zero-based
Julia code-unit spans, public character offsets, line/column positions, and zero-width/progress state.
`RuntimeMatchRegisters` keeps entry and local matches separate across child dispatch, tracks cursor and capture-start
anchors, and returns updated immutable records.

Julia 1.12's native PCRE integration directly accepts the currently required Python/angle named captures, POSIX
classes, inline/scoped flags, possessive quantifiers, and recursive `(?R)`. Unlike Dart, this boundary does not need
a regex dialect-normalization or bounded structural-regex adapter.

Related facts: [[julia-runtime-cursor-boundary-helpers]], [[julia-runtime-rule-interpreter]],
[[julia-compiled-spec-state]], [[dart-runtime-matching-state]],
[[rust-entry-match-separation]], [[rust-char-based-offsets]], [[julia-backend-interpreter-first-plan]].

## 2026-09-11 — complete matching-source reading

Julia .1.19 completes Interpreter9116-9285 and Matching1-509. Matching constructs
one native PCRE per ordered alternative, selecting earliest position and source
order on seek ties, or the first at-cursor alternative in consume mode. Selected
slots retain structural identity, including duplicate patterns. Full group slots
retain empty placeholders, while compact captures carry live PCRE source spans;
the compatibility constructor grants no staged-capture provenance. Offset conversion
checks UTF-8 boundaries, public locations count characters and LF lines, and child
entry separates entry/local registers without discarding source identity.

[[julia-selected-slot-mode-validation-gap]] qualifies the low-level selected-slot
API: its invalid-mode rejection occurs after matching, so a miss bypasses validation.
Julia .2.12 owns repair. Ordinary runtime_match validates first; authored rule-local
mode and removed global parser options remain separate.

Exact focused replay passes714 assertions plus one selected-set equality:

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_READ19_SUITE'
using LinkedSpecJulia, JSON3, Test
const REPO_ROOT=pwd()
const CORPUS_ROOT=joinpath(REPO_ROOT,"tests","corpus")
const selected=Set(["Runtime regex matching state","Runtime structured diagnostics"])
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
include("julia/test/duplicate_regex_slot_identity_contract_test.jl")
include("julia/test/recognition_transaction_contract_test.jl")
include("julia/test/inter_match_gap_capture_contract_test.jl")
JULIA_READ19_SUITE
bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py
bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py
```
