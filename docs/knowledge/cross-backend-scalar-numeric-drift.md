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
implementation_update_2026_07_12: "LUA-BACKEND-PARITY.4.3.3.1.2-.3 align all four admitted backends. Perl generated actions call LinkedSpec::Numeric; Rust uses strict helper-local adapters; Dart and Julia enforce the same decimal grammar, exact/variadic arities, finite results, half-away rounding, and floor signed modulo. All four execute all 55 unchanged cases. Generic scalar conversion remains separate; Lua exact six-runtime admission is next."
reverify: "PERL5LIB= prove -Iperl t/scalar_numeric_contract.t && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test scalar_numeric_contract && cd dart && dart test test/runtime_interpreter_test.dart && cd ../ && JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:/Users/richarddje/.julia /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'"
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

Lua must not select one of these behaviors accidentally through `tonumber`, `%`, or host truthiness. The rollout
adopted the versioned neutral scalar contract (`.4.3.3.1.1`) and aligned Perl/Rust (`.2`) plus Dart/Julia (`.3`);
PUC Lua/LuaJIT exact six-runtime admission (`.4`) remains. Aggregate reducers and receiver forms stay in
their already-separated downstream leaves.
