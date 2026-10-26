---
id: terse-number-receiver-value-chains
title: Number methods and ordinary numeric result continuations
answers:
  - "how do number receiver-dot value chains work"
  - "does score.abs().ceil().add work"
  - "does 5.mod(2) work"
  - "does 3.5.floor().add(1) work"
  - "are numeric comparison receiver methods terminal"
  - "can number terminal methods continue"
  - "are declare methods terse receiver methods"
  - "is declare a number receiver method"
  - "which task follows SPEC-FORMAT-TERSE.2.3.5.4"
  - "can scalar arithmetic results feed text methods"
  - "which task owns ordinary numeric arithmetic result flow"
date: 2026-10-26
status: comparison rollout checked; scalar arithmetic result extension frozen
tags: [number, numeric, receiver, scalar, result, spec-format-terse]
evidence: "scalar_numeric_contract.json; TYPE23.2.15/16 retained public Get/native/fresh/substitution and numeric-comparison-results.md/scalar-arithmetic-results.md."
reverify: "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_scalar_arithmetic_results.pl"
---

Short Number methods map to num_* helpers. Finite numbers/contracted untrimmed
decimal Strings are numeric; Bool/null/containers/bad inputs return null.
Arithmetic abs/floor/ceil/round/add/sub/mul/div/mod/min/max/clamp composes:
score.abs().ceil().add(2,3),5.mod(2),3.5.floor().add(1). Comparisons eq/ne/gt/ge/
lt/le return numeric1/0/invalid-null. Statement/lifecycle declare is not a method;
Array reducers have [[terse-array-numeric-reducer-receiver-methods]].

Comparison15.1-.5 is targeted-checked on all five current backends: Perl scalar
classification/String/Array handoffs, Rust selected-value dispatch, Dart/Julia
guard lists and Lua scalar marking/preflight preserve numeric kinds, strict
inputs, SOC/once-only, defaults/bridges and selector kinds. Declared Lua5.4/full
admission remain separate. Complete prior structural/proof detail and July1
historical pointer are preserved in this file at Git
3bfda7204a4c6b19d8d9f5a6145399afff8d6168.

Arithmetic16 freezes compatible ordinary result continuations as a new feature;
prior Number-only scope was intentional. Public Perl free/nested twelve numeric
results/texts, selected/call/count/reducer sources and min/max[3,4,ASO,5,4] already
work. Plain arithmetic-to-text/bridge/default/effect chains retain DSL and fail
handler compile; String-prefix arithmetic leaves raw trim. WHY: MethodLowering
_number_receiver_value_chain_return_family yields number; Number loop stops at
non-Number links, String numeric handoff only includes comparisons. Nested
5!/SOC/null and malformed abs/add/clamp no-effects already work. Freeze:
scalar-arithmetic-results.md; children23.3.16.1-.5, Perl first. No new numeric
domain/free shape/min-max overload/Array reducer95/deferred vocabulary policy.
Canonical num_* method names are outside this short-method result scope.

Two stale comparison-terminal overview paragraphs were corrected at16 freeze.
Block/user-function values dispatch on actual returned kind. Historical next
2.3.5.5 described block-yielded receiver work; current work follows MEMORY.md.
