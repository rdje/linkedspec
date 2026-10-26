---
id: julia-runtime-string-numeric-helpers
title: Julia runtime executes current string/scalar and numeric helpers through one canonical dispatcher
answers:
  - why do Julia definedness result checks assert Bool identity
  - why do Julia string predicates need scalar arity and null operand guards
  - does Julia runtime support trim lowercase substr split
  - does Julia runtime support regex flags in matches
  - does Julia runtime support explicit string comparisons
  - does Julia runtime support numeric helpers
  - does Julia runtime support numeric aliases and symbol callees
  - does Julia runtime return nothing for invalid numeric input
  - does Julia runtime support string receiver chains
  - does Julia runtime support number receiver chains
date: 2026-10-26
status: current
tags: [julia, runtime, helpers, string, numeric, JULIA-BACKEND-PARITY]
evidence: "String/numeric4.3.2; predicate10.4/definedness11.4/numeric-comparison15.4 focused proof. Prior full fact and its historical replay/source pointer at Git03f0036a8093e87db4af7c82ef6518448c9d9ee7."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error -e 'using LinkedSpecJulia,JSON3,Test; include(\"julia/test/numeric_comparison_results_test.jl\"); include(\"julia/test/string_comparison_result_receivers_test.jl\")'"
---

Julia string/scalar and numeric helper execution lives in
`julia/src/runtime/Interpreter.jl`.

Function-form calls and receiver methods canonicalize through
`canonical_action_helper_name(...)` before sharing one pure-helper dispatcher.
The string/scalar surface includes concatenation, trimming and case transforms,
character length/substrings, literal prefix/suffix/contains/replace operations,
literal and regex splitting, regex matching with retained flags, lazy coalesce
variants, definedness/emptiness predicates, and explicit lexical `str_*`
comparisons.

The numeric surface includes arithmetic folds, integer modulo, unary rounding,
min/max/clamp, sum/average/median/range reducers, numeric comparisons, terse word
aliases, and arithmetic/comparison symbol callees. Runtime numeric conversion
accepts finite numbers and numeric-looking strings, rejects booleans and
aggregate values, normalizes integral results to Julia `Int`, and returns
`nothing` for invalid operands, bounds, modulo, failed integral conversions, or
zero divisors. This describes covered conversion paths, not safe arithmetic at
every magnitude; the September qualification below supersedes that broader inference.

Compatible string and number receiver chains prepend the current receiver to
the same helper call; receiver shapes and result boundaries still need independent guards. Array-aware
continuations and mutations remain owned by `JULIA-BACKEND-PARITY.4.3.3`.

Related facts: [[julia-runtime-core-value-capture-helpers]], [[julia-runtime-array-helpers]],
[[julia-runtime-rule-interpreter]], [[dart-runtime-string-numeric-helpers]],
[[terse-string-receiver-value-chains]], [[terse-number-receiver-value-chains]],
[[terse-string-comparison-bridge-contract]], [[terse-numeric-comparison-symbol-callees]].

## 2026-09-11 — numeric conversion and slice limits

Julia .1.17 physically reads Interpreter6116-7615. Strict numeric adapters reject
booleans/aggregates, but arithmetic can wrap before normalization, and integral
Float64 results outside Int range become nothing. Integer-literal parsing can
throw before runtime. [[julia-large-number-and-slice-boundaries]] preserves 128
native/reconstructed and 64 Perl assertions; Julia .2.9 owns these defects.
The same paired diagnostic proves unsafe substring/count arithmetic under .2.10.
Large float scalar text preserves magnitude via BigInt but uses decimal spelling;
startup .55.2 retains its comparison with Perl scientific spelling.

Existing text5/numeric4/string-numeric14 and adjacent aggregate/uniform/mutation
suites remain green. Exact selected replay is in [[julia-runtime-array-helpers]].
Regex handling retains imsx flags (g/o ignored), guarded substitution writeback
and capture expansion; this reading closes no pending regex or numeric repair.

Historical September11 replay and full10.4/11.4 guard detail are recoverable at
the Git pointer above. Predicate10.4 preserves numeric text flags/Bool matches
and SOC/SC while fixing null needles/scalar boundaries/one-operand effects.
Definedness11.4 keeps Bool identity/false0!/SC with zero-operand/scalar guards.

Numeric comparison15.4 adds six names to common one-RHS/scalar tuples only.
Independent producer/valid flow already works; scalar Array[]/24 effects fail.
Native/plan/fresh and direct lexical/aggregate42 strict assertions now pass,
including explicit Number/not-Bool guards, numeric selector kinds and source
SOC/copy. Numeric adapters/domains/aliases stay unchanged; full admission open.
