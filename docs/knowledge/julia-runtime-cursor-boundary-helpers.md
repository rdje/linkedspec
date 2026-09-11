---
id: julia-runtime-cursor-boundary-helpers
title: Julia runtime implements explicit cursor controls and non-consuming boundary capture
answers:
  - does Julia runtime support save_cursor restore_cursor
  - does Julia runtime support rewind_match_start rewind_entry_start
  - does Julia runtime support capture_until_boundary
  - how does Julia keep runtime cursor and match registers synchronized
  - are Julia cursor and input helper offsets character based
  - does a Julia cursor rewind roll back variables or matches
  - what happens when Julia capture_until_boundary cannot resolve a boundary rule
date: 2026-07-10
status: current
tags: [julia, runtime, cursor, boundary-lookahead, helpers, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.4.4 extends julia/src/runtime/Interpreter.jl with an explicit cursor stack, centralized live/register cursor updates, direct match/entry anchor rewinds, character-based cursor/input helpers, overflow-safe input slicing, and earliest usable named-rule boundary capture. Fourteen focused assertions in julia/test/runtests.jl and the full 581-assertion Pkg.test() run prove consume-mode continuation, multibyte public offsets, preserved match/store state, non-consumption, EOF fallback, and unresolved-rule no-op behavior."
reverify: "bash tools/run_julia_project_data.sh --project=julia -e 'using Pkg; Pkg.test()'"
---

Julia runtime cursor-control and cursor/input helper execution lives in
`julia/src/runtime/Interpreter.jl` on top of the immutable match-register state
in `julia/src/runtime/Matching.jl`.

`save_cursor()` pushes the current internal code-unit cursor onto an explicit
LIFO stack. `restore_cursor()` pops and restores it when present; an empty stack
is a no-op. `rewind_match_start()` and `rewind_entry_start()` move directly to
the current local-match or initial/entry-match start and do not use the stack.

All four controls update the live execution cursor and
`RuntimeMatchRegisters.cursor_codeunit` together. They do not roll back or
replace entry/local match records, variables, arrays, hashes, accumulators,
lifecycle effects, or branch decisions. Normal matching after the move retains
the engine's configured seek or consume mode.

Julia stores the internal cursor as a zero-based UTF-8 code-unit offset. Public
`cursor_*` and `input_*` helpers return character-based offsets, lengths, and
slices plus 1-based line/column values.

`capture_until_boundary(rule[, ...])` seeks every usable named boundary rule
from the live cursor and selects the earliest match while leaving that boundary
unconsumed. If usable rules exist but none matches later, it captures through
EOF and moves there. If no requested rule resolves to regex patterns, it
returns `nothing` and leaves the cursor unchanged.

Related facts: [[julia-runtime-matching-state]], [[julia-runtime-rule-interpreter]],
[[julia-runtime-value-control-tree-helpers]], [[julia-runtime-diagnostics-trace-split]],
[[cursor-boundary-lookahead-helper]],
[[dart-runtime-backtrack-cursor-helpers]].

## 2026-09-11 — current typed adapters and exact source reading

Julia .1.18 reads Interpreter7616-9115. Anonymous/named capture projection validates
typed same-source spans before advancing marks. Named arguments stay symbolic;
mark_copy deletes a target when its source mark is absent. Cursor changes update
both live and register state, while boundary lookahead selects the earliest usable
rule without consuming that boundary and falls back to EOF only for usable rules.

The historical overflow-safe input-slicing statement is now measured at Int maximum:
width is clipped to remaining source length before addition. Separate wrong-arity
and large-float conversion failures remain open in
[[julia-input-slice-arity-and-count-boundaries]]. Portable authoring uses exactly
input_slice(start, length), or input_text() for the whole input.

Exact focused replay (886 assertions plus one selection equality):

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_READ18_SUITE'
using LinkedSpecJulia, JSON3, Test
const REPO_ROOT=pwd()
const CORPUS_ROOT=joinpath(REPO_ROOT,"tests","corpus")
const selected=Set(["Runtime core value stores and capture helpers","Governed anonymous and named capture fixtures","Named capture mark scope and character projection","Runtime cursor controls and boundary capture"])
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
include("julia/test/complete_named_mark_contract_test.jl")
include("julia/test/diagnostic_output_contract_test.jl")
include("julia/test/logical_helper_contract_test.jl")
include("julia/test/typed_source_location_contract_test.jl")
include("julia/test/write_vivification_contract_test.jl")
JULIA_READ18_SUITE
bash tools/run_python_project_data.sh tools/check_logical_helper_contract.py
bash tools/run_python_project_data.sh tools/check_write_vivification_contract.py
bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py
```

## September 11 complete mark and cursor consumer reading (.1.43)

Anonymous/named fixtures2860–2924 pass2, mark scope2926–2969 passes3 and cursor
controls3297–3528 passes17 assertions. They preserve character projection, local
named marks, LIFO restoration without binding rollback, empty-stack no-op,
entry/local rewind separation and progressive anonymous take anchors. Earliest
usable boundary stays unconsumed; EOF fallback differs from unresolved-rule
no-op. Wrong input_slice arity/count repair .2.11 remains open. Exact replay
and neutral typed231 proof: [[julia-runtime-array-helpers]], .1.43 below.
