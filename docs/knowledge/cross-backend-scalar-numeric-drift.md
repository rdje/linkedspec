---
id: cross-backend-scalar-numeric-drift
title: Scalar numeric contract admission and the later Unicode-digit exception
answers:
  - "do scalar numeric helpers behave identically across Perl Rust Dart and Julia"
  - "are booleans valid numeric helper inputs"
  - "what happens when numeric comparisons receive invalid input"
  - "are subtraction and division variadic"
  - "how does signed modulo behave across backends"
  - "why must Lua numeric helpers wait for a neutral contract"
  - "do scalar numeric helpers match across all six runtime variants"
  - "where does Perl enforce numeric helper arity and finite results"
date: 2026-09-06
status: current
tags: [numeric, parity, perl, rust, dart, julia, lua, helpers, contract, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.3.1.0 used LinkedSpec::Get for a direct Perl matrix and inspected rust/linkedspec-{core,runtime}, dart/lib/src/runtime/interpreter.dart, julia/src/runtime/Interpreter.jl, and their focused tests. Perl accepts booleans as numeric and maps invalid comparisons to 0; Rust also converts booleans and maps invalid comparisons/unary calls to 0. Dart/Julia reject booleans and return null/nothing. Perl rejects extra sub/div operands, Rust ignores them, and Dart/Julia fold them. Numeric string grammars and signed remainder mechanisms also differ. The public catalog says invalid numeric inputs return undef, but no executable neutral scalar contract owns these edges."
policy_update_2026_07_12: "LUA-BACKEND-PARITY.4.3.3.1.1 and ADR 0029 adopt linkedspec-scalar-numeric-v1: strict finite decimal numbers/strings, booleans and aggregates invalid, explicit arities, invalid-to-null, numeric 1/0 comparisons, half-away rounding, and floor/Euclidean signed modulo. The 55-case neutral fixture and independent checker are recurring local-CI inputs; admitted-backend repair follows before Lua implementation."
implementation_update_2026_07_12: "LUA-BACKEND-PARITY.4.3.3.1.2-.4 align every runtime variant. Perl generated actions call LinkedSpec::Numeric; Rust, Dart, Julia, and Lua use strict helper-local adapters. All six variants enforce the same decimal grammar, exact/variadic arities, finite results, half-away rounding, floor signed modulo, and exact 55-case result. Generic scalar conversion remains separate."
reverify: "bash tools/check_scalar_numeric_six_runtime.sh"
---

Before the neutral contract, scalar numeric edge behavior differed:

- Perl and Rust coerce typed booleans to `1`/`0`; Dart and Julia reject booleans. The public helper catalog calls
  non-numeric inputs invalid, while primitive-literal doctrine treats booleans as a distinct typed scalar.
- Invalid Perl/Rust comparisons produce numeric `0`; Dart/Julia return null. Rust unary helpers also default invalid
  input to `0` instead of null.
- Extra subtraction/division arguments are rejected by Perl, ignored after operand two by Rust, and folded by
  Dart/Julia.
- Perl's generated numeric recognizer accepts strict untrimmed decimal strings such as `.5` but not signs-plus,
  exponent, whitespace, hex, or trailing-dot forms; other hosts delegate to broader parsers.
- Signed modulo follows different host remainder definitions unless specified explicitly.

The rollout adopted the versioned neutral scalar contract (`.4.3.3.1.1`), aligned Perl/Rust (`.2`) and Dart/Julia
(`.3`), then implemented Lua without delegating syntax, modulo, rounding, or invalid policy to `tonumber`, `%`, or
host truthiness (`.4`). The composed checker covers the 55 exact admitted cases across all six runtime variants. The September 6
startup finding [[scalar-numeric-unicode-digit-oracle-drift]] exposes a further input-language/coercion
disagreement outside that finite fixture; `SESSION-STARTUP-READING.20` owns authority review and repair.
Passing the original fixture does not establish equivalence for every accepted numeric string.
Aggregate reducers and receiver forms stay in their already-separated downstream leaves.

The September 6 `.3.2.38` checkpoint reads Numeric.pm 1–110. `evaluate` rejects unknown helper names
and invalid arities, converts each input through `scalar_number`, applies the owned arithmetic/comparison/
rounding rules, and normalizes nonfinite results to undef and signed zero to zero. `scalar_number` rejects
references and checks host numeric flags before the decimal-string recognizer; its Unicode-digit/coercion
disagreement remains the separately owned `.20` exception above. The managed Perl numeric suite passes nine
top-level tests and the neutral checker passes 55 cases / 18 helpers. Other runtime consumers are not rerun.

## 2026-09-09 — Dart finite-range exception beyond the admitted fixture

DART-STARTUP-READING.1.20 adds [[dart-large-number-helper-corruption]]: eleven paired
native/reconstructed Dart and Perl facade/source cases distinguish six corruptions from
five agreements. Direct positive/negative 1e20 survives in Dart, but helper normalization
and scalar-text conversion saturate; integer addition wraps and abs(min-int) remains
negative. .2.12 owns Dart repair alongside startup .55 numeric/text work. Fresh neutral
55/18 and the existing Dart fixture still pass; they do not cover these magnitude
boundaries or promise arbitrary-precision arithmetic. Unicode-digit .20 remains separate.

## 2026-09-11 — Julia finite-range exception beyond the admitted fixture

Julia .1.17 adds [[julia-large-number-and-slice-boundaries]]: native/reconstructed
source rejects a large integer literal, loses valid large integral-float helper
results, wraps max-int addition and leaves abs(min-int) negative. Perl Get preserves
the tested magnitudes;128 Julia and64 Perl assertions pin these boundaries and
ordinary controls. Julia .2.9 owns its numeric repair; startup .55.2 retains text
spelling and .20 Unicode grammar. The unchanged neutral55/18 and Julia numeric
fixture still pass and do not establish correctness across this larger domain.
