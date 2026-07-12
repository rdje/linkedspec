---
id: scalar-to-text-coercion-cross-backend-gap
title: Scalar-to-text helper coercion is not yet identical across LinkedSpec variants
answers:
  - does cat convert booleans identically on all LinkedSpec backends
  - does cat accept null arrays hashes identically on all variants
  - how does cat stringify 1.0 across backends
  - what task owns scalar string coercion parity
  - is concat still an alias for cat
date: 2026-07-11
status: current
tags: [scalar, string, coercion, cat, perl, rust, dart, julia, lua, parity]
evidence: "LUA-BACKEND-PARITY.4.3.2.1.1 source audit found three unguided host seams. Perl MethodLowering cat rejects undefined or references, while Rust RuntimeValue::to_str and Dart/Julia null-as-empty conversion produce empty fragments for undefined/containers. Perl/Rust render booleans as 1/0 while Dart/Julia host string interpolation renders true/false. Perl/Rust collapse integral numeric values such as 1.0 to 1 while Dart/Julia preserve the host literal/runtime type spelling 1.0. Lua .1.1 keeps stable PUC/LuaJIT reference-oriented spelling but cannot make the existing variants identical. `.4.3.2.1.3` owns the neutral fixture and coordinated repair. `concat` is retired and must remain rejected."
reverify: "rg -n 'cat_ok|__ls_cat_parts|helper_name == \"cat\"|\"cat\" =>' perl/LinkedSpec/ActionIR/MethodLowering.pm rust/linkedspec-runtime/src/engine.rs dart/lib/src/runtime/interpreter.dart julia/src/runtime/Interpreter.jl && rg -n 'fn to_str|_scalarString|_runtime_scalar_string' rust/linkedspec-core/src/types.rs dart/lib/src/runtime/interpreter.dart julia/src/runtime/Interpreter.jl"
---

## Fact

String-helper coercion currently inherits host policies instead of one language contract. The important drifts are:

- Perl `cat` rejects undefined values and references, while Rust, Dart, and Julia currently turn undefined and
  aggregate fragments into empty text.
- Perl and Rust stringify booleans as `1`/`0`; Dart and Julia stringify them as `true`/`false`.
- Perl and Rust stringify an integral numeric value such as `1.0` as `1`; Dart and Julia may preserve `1.0` because
  their ActionIR literal types distinguish integer from floating-point input.

The Lua implementation makes these conversions deterministic across PUC Lua and LuaJIT, but no Lua-local choice
can satisfy mutually inconsistent existing hosts. `LUA-BACKEND-PARITY.4.3.2.1.3` owns a neutral fixture and one
coordinated six-variant decision. Portable specs should pass explicit strings to text helpers in the meantime.

`cat` is the current helper name. The old `concat` spelling was retired and is not part of the parity repair.
