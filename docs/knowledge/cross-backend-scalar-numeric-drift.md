---
id: cross-backend-scalar-numeric-drift
title: Scalar numeric helper edges drift across admitted backends without a neutral executable contract
answers:
  - "do scalar numeric helpers behave identically across Perl Rust Dart and Julia"
  - "are booleans valid numeric helper inputs"
  - "what happens when numeric comparisons receive invalid input"
  - "are subtraction and division variadic"
  - "how does signed modulo behave across backends"
  - "why must Lua numeric helpers wait for a neutral contract"
date: 2026-07-12
status: current
tags: [numeric, parity, perl, rust, dart, julia, lua, helpers, contract, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.3.1.0 used LinkedSpec::Get for a direct Perl matrix and inspected rust/linkedspec-{core,runtime}, dart/lib/src/runtime/interpreter.dart, julia/src/runtime/Interpreter.jl, and their focused tests. Perl accepts booleans as numeric and maps invalid comparisons to 0; Rust also converts booleans and maps invalid comparisons/unary calls to 0. Dart/Julia reject booleans and return null/nothing. Perl rejects extra sub/div operands, Rust ignores them, and Dart/Julia fold them. Numeric string grammars and signed remainder mechanisms also differ. The public catalog says invalid numeric inputs return undef, but no executable neutral scalar contract owns these edges."
policy_update_2026_07_12: "LUA-BACKEND-PARITY.4.3.3.1.1 and ADR 0029 adopt linkedspec-scalar-numeric-v1: strict finite decimal numbers/strings, booleans and aggregates invalid, explicit arities, invalid-to-null, numeric 1/0 comparisons, half-away rounding, and floor/Euclidean signed modulo. The 55-case neutral fixture and independent checker are recurring local-CI inputs; admitted-backend repair follows before Lua implementation."
reverify: "perl -Iperl -MLinkedSpec -e 'print LinkedSpec::call_spec_handler_subst(q{Top}, q{return(num_gt(\"x\", 2))}), qq{\\n}' && rg -n 'as_number|_numValue|_runtime_number|num_sub|num_mod|num_gt' rust/linkedspec-core/src/types.rs rust/linkedspec-runtime/src/engine.rs dart/lib/src/runtime/interpreter.dart julia/src/runtime/Interpreter.jl"
---

The current happy paths agree, but scalar numeric edge behavior does not:

- Perl and Rust coerce typed booleans to `1`/`0`; Dart and Julia reject booleans. The public helper catalog calls
  non-numeric inputs invalid, while primitive-literal doctrine treats booleans as a distinct typed scalar.
- Invalid Perl/Rust comparisons produce numeric `0`; Dart/Julia return null. Rust unary helpers also default invalid
  input to `0` instead of null.
- Extra subtraction/division arguments are rejected by Perl, ignored after operand two by Rust, and folded by
  Dart/Julia.
- Perl's generated numeric recognizer accepts strict untrimmed decimal strings such as `.5` but not signs-plus,
  exponent, whitespace, hex, or trailing-dot forms; other hosts delegate to broader parsers.
- Signed modulo follows different host remainder definitions unless specified explicitly.

Lua must not select one of these behaviors accidentally through `tonumber`, `%`, or host truthiness. The active
rollout first adopts a versioned neutral scalar contract (`.4.3.3.1.1`), then aligns Perl/Rust (`.2`), Dart/Julia
(`.3`), and finally PUC Lua/LuaJIT with exact six-runtime admission (`.4`). Aggregate reducers and receiver forms
remain in their already-separated downstream leaves.
