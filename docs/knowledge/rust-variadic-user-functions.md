---
id: rust-variadic-user-functions
title: Rust preserves v1 fixed functions and executes v2 variadic functions natively and from generated state
answers:
  - "does the Rust variadic contract target independently compile emitted source"
  - "does Rust support variadic user functions"
  - "where does Rust bind a rest parameter"
  - "does Rust evaluate variadic arguments left to right"
  - "are Rust rest arrays fresh per invocation"
  - "does Rust preserve variadic signatures in staged records"
  - "does Rust generated source preserve callable signatures"
  - "why did Rust variadic result length return zero"
  - "does Rust length work on array values"
date: 2026-09-08
status: current
tags: [rust, functions, variadic, rest-parameter, descriptor, staged-parsing, generated-source, length, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.4.2.2 updates rust/linkedspec-core AST/compiler/validation/descriptor models and rust/linkedspec-runtime parser/engine execution. The seven tests in variadic_user_function_contract.rs execute native, reconstructed compiled-state and generated-plan paths; emitted-signature evidence is source-text inspection."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test variadic_user_function_contract && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-core"
---

Rust accepts `fn name(fixed, ...rest) { ... }` through the shared spec-defined definition parser. The parser
requires exact version-2 `callable_signature` fields and identical signature copies in the staged body payload and
parse job. Internally, `FunctionDefinition` and `CompiledUserFunction` retain normalized fixed-prefix `params` and
minimum `arity` alongside a typed `CallableSignature`; validation proves those derived execution fields agree.
The public descriptor remains an exact union: fixed v1 records expose `params`/`arity`, while variadic v2 records
omit those keys and expose only `signature`.

Registered calls check the typed minimum before evaluating arguments. Accepted arguments evaluate once
left-to-right in caller scope. The existing function-local store swap binds fixed prefix values and then installs a
new `RuntimeValue::Array` under the rest name for each invocation, including an empty array when there are no
extras. Nested arrays/hashes, booleans, and null remain individual array members. Fixed calls retain exact arity;
recursion diagnostics and result/standalone behavior use the existing registry-first path.

Compiled JSON carries the typed signature, so emitted Rust source embeds it and generated-plan execution
deserializes and runs the same semantics. The neutral receiver case exposed a pre-existing drift:
`all_values(1, 2, 3).length()` returned `0` because the generic scalar helper converted an array to empty text.
`length` now returns array cardinality for array values and continues to count Unicode characters for scalar text.

September reading `SESSION-STARTUP-READING.3.3.21` confirms the array-cardinality
branch, but literal-undef and unbound-name controls return zero rather than the
reference null. [[rust-scalar-helper-null-and-empty-drift]] and repair `.61`
qualify scalar edge behavior; the July variadic suite is not rerun by this update.

## September 8 variadic consumer reading

`SESSION-STARTUP-READING.3.3.66` reconciles all 214 lines and seven tests in
`rust/linkedspec-runtime/tests/variadic_user_function_contract.rs`. The exact v1/v2
unions survive definition records, staged payload/job copies and descriptor keys.
Native controls exercise mixed/empty rest values, receiver chaining, once-only
left-to-right arguments, fresh rest arrays and distinct fixed/minimum-arity errors.
Five malformed rest spellings fail parsing; duplicate/reserved names reach and fail
semantic validation. Reconstructed compiled state and a generated-plan helper
execute the neutral fixture. Emitted source is inspected for signature text; no
independent emitted module is compiled in this target.

Fresh callable-signature neutral checking covers three definitions, nine calls
and seven invalid signatures. These reading and neutral results do not refresh the
historical native suite or alter the separately owned scalar-null repair `.61`.
