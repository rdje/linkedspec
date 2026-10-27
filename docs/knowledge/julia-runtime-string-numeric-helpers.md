---
id: julia-runtime-string-numeric-helpers
title: Julia runtime executes current string/scalar and numeric helpers through one canonical dispatcher
answers:
  - why do Julia replacement and affix identities lose Number or Boolean kind
  - does Julia treat an explicit null substring width as omitted
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
date: 2026-10-27
status: current
tags: [julia, runtime, helpers, string, numeric, JULIA-BACKEND-PARITY]
evidence: "String/numeric4.3.2; comparison15.4/arithmetic16.4/scalar String19.4 focused proof. Prior full fact/guard and dated replay details at Gitbec537d5b05ebfdd7750930bfb13ca1588a4da5e."
reverify:
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error -e 'using LinkedSpecJulia,JSON3,Test;include(\"julia/test/scalar_string_results_test.jl\");include(\"julia/test/default_selected_receivers_test.jl\")'"
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error -e 'using LinkedSpecJulia,JSON3,Test; include(\"julia/test/scalar_arithmetic_results_test.jl\"); include(\"julia/test/numeric_comparison_results_test.jl\")'"
---

Interpreter.jl canonical_action_helper_name shares pure implementations across
function/word/symbol/receiver forms: strings include case/trim/cat/length/substr,
predicates, literal/regex split/replace, lazy defaults and generic predicates;
numeric includes arithmetic/rounding/min-max/clamp/reducers/comparisons. Numeric
conversion rejects Bool/containers/invalid inputs and returns Number or nothing;
normalization and strict domains remain unchanged by result dispatch work.

Predicate10.4 fixes null needles/scalar/one-RHS guards while preserving numeric
text flags/Bool matches and SOC. Definedness11.4 preserves Bool/false0!/SC with
zero-RHS/scalar guards. Comparison15.4 adds six canonical names to one-RHS/scalar
tuples; valid flow already worked but scalar Array[]/24 effects did not. Strict
native/plan/fresh tests assert Number && !Bool, numeric selector kinds and SOC.
Full prior lists/replay/guard detail remain at the exact Git pointer above.

Arithmetic16.4 independently confirms canonical/word/symbol/nested producers,
selector and String prefixes. Shared RED has scalar-container[] and28 malformed
effects; valid twelve/variadic/domain/default/copy/bridge/SOC/ASO already works.
Common unambiguous unary/binary/clamp/add-mul guards and arithmetic scalar tuple
repair both, preserving min/max modes.69 focused assertions across new arithmetic
and direct comparison/aggregate/default tests compile/pass native/plan/fresh;
strict raw/alias/symbol/counter kinds reject Bool lookalikes. Full admission open.

## Numeric and slice qualifications

September11 .1.17 strict diagnostic establishes arithmetic wrap before
normalization, out-of-Int-range integral Float64 -> nothing, and integer literal
parse throws. [[julia-large-number-and-slice-boundaries]] retains128 native/
reconstructed and64 Perl assertions; Julia2.9 owns these defects,2.10 owns unsafe
substring/count arithmetic. Large float text uses BigInt decimal spelling;
startup55.2 retains Perl scientific-spelling comparison. No all-magnitude claim.
Regex handling preserves imsx (g/o ignored), guarded substitution/captures;
this slice closes no separate regex/domain repair.

Related: [[julia-runtime-array-helpers]], [[julia-runtime-core-value-capture-helpers]],
[[terse-number-receiver-value-chains]], [[terse-string-comparison-bridge-contract]].

Scalar String19.4 independently observes coerced identities/nullAsEmpty and
scalar[]/SCA/malformed SAC on native/plan/fresh. Preserve Number originals
(including Bool identity), guard explicit null replacement/affix operands and
add eight-method scalar/shape tuples; other converted carriers keep text.
Registered new54/direct defaults9 strict assertions pass, including Number-not-
Bool/false/counters, typed selectors/matched keys/Unicode, SONC-SC-selectedS/
eager null/rejection/12 malformed effects and both mutation aliases. Slice null
source/start/fractions already work; null width remains omitted and Bool offset1.
P2 TYPE23.2.20 reconciles these domains after19.5 before portable admission.
No global numeric/int/selector/Unicode/callback/schema or large-slice2.10 change.
