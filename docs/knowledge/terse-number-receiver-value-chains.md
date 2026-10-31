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
status: comparison checked; arithmetic result extensions targeted-checked on all current backends implemented
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

Arithmetic16 extends prior Number-only scope. Perl16.1 now classifies twelve
methods scalar_result and hands String-prefix Number methods to shared dispatch.
Native/fresh twelve/variadic/strict-domain/source/zero/default/bridge/selector
checks pass after raw-DSL compile RED, preserving SOC/once-only, ASO overloads,
copy and14 malformed no-effects. Hash default->Array view->successor additionally
needed the existing compatibility bridge for emitted do expressions; see
[[rust-coalesce-evaluation-drift]].29 current direct assertions, actual AST/
Phase0 named cases and syntax pass; source/expected/tests retain the controls.
Rust16.2 shares Number scalar dispatch and adds unambiguous shape guards; eleven
producer/shared/prefix/direct/named tests pass native/restored/plan after RED. Its
String loop also needed handoff before the String whitelist, fixing arithmetic/
comparison prefix[null,null,null] to[5!,1!,8]. Dart16.3 adds scalar marking/common shape guards:11 focused tests and fatal
analysis pass after scalar[]/28-effect RED; valid flow already worked.
Julia16.4 adds matching guards after scalar[]/28-effect RED;69 strict
native/plan/fresh assertions pass with Number/not-Bool kinds. Lua16.5 marks all scalar numeric results and adds common shape guards;
both available hosts pass native/plan/fresh and direct/named checks after
scalar[]/28-effect RED. All five bounded implementations are targeted-checked;
no numeric/free/min-max/Array
reducer95/deferred policy expansion. Canonical num_* method names stay outside
this short-method scope.

Two stale comparison-terminal overview paragraphs were corrected at16 freeze.
Block/user-function values dispatch on actual returned kind. Historical next
2.3.5.5 described block-yielded receiver work; current work follows MEMORY.md.

Canonical free arithmetic and short Number-prefix rejection state through later immediate with are separately repaired by Perl63.1: [[free-numeric-result-source-guards]]. Independent peers/full admission remain open; original16 producer/domain/min-max overload authority is unchanged.
