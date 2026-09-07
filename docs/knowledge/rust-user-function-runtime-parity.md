---
id: rust-user-function-runtime-parity
title: SPEC-FORMAT-TERSE.4.3.2 Rust user-function runtime parity
answers:
  - "does Rust execute user-defined functions"
  - "does Rust resolve user functions before helper fallback"
  - "how are Rust user function arguments evaluated"
  - "how are Rust user function locals scoped"
  - "do Rust user functions feed receiver-dot chains"
  - "do standalone Rust user function calls discard results"
  - "what happens for Rust user function recursion"
  - "which oracle fixture covers Rust user function runtime parity"
date: 2026-09-07
status: current
tags: [spec-format-terse, rust, user-functions, runtime, oracle]
evidence: "SPEC-FORMAT-TERSE.4.3.2 added RuntimeContext variable-store snapshots and active user-function tracking in rust/linkedspec-runtime/src/runtime.rs, plus Engine::execute_user_function in rust/linkedspec-runtime/src/engine.rs. Expr::Call now resolves registered CompiledUserFunction entries before ordinary helper fallback, checks exact arity, evaluates args eagerly in caller context, binds params into fresh scalar/array/hash stores, evaluates the compiled CodeBlock body, restores caller stores, rejects direct/mutual recursion, and returns values into compatible receiver chains. Focused tests in rust/linkedspec-runtime/tests/integration_test.rs cover value calls, local scope, receiver chains, standalone discard, wrong arity, and recursion diagnostics. The shared oracle fixture terse_4_3_2_user_function_runtime brings the corpus to 54 fixtures."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_4_3_2 -- --nocapture && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle -- --nocapture"
---

`SPEC-FORMAT-TERSE.4.3.2` makes the Rust backend execute the user-function registry
landed in `.4.3.1`.

Runtime behavior:

- registered `Expr::Call` names resolve against `CompiledSpec.functions` before ordinary helper fallback
- arity mismatches diagnose with the expected/got argument counts
- arguments evaluate eagerly in the caller context
- function params bind into fresh function-local scalar stores; array/hash values also populate local aggregate
  stores for wrapper and receiver-chain compatibility
- the compiled function `CodeBlock` returns its final expression or `return(expr)` payload
- caller scalar/array/hash stores are restored after return, so params and locals do not leak
- returned arrays, hashes, strings, and numbers feed compatible receiver-dot chains
- standalone registered calls execute and discard their result
- direct and mutual recursion diagnose instead of recursing

The shared Perl/Rust oracle fixture is `terse_4_3_2_user_function_runtime`; the
original July milestone brought the Rust corpus oracle to 54 fixtures. This is
historical evidence, not the current corpus size or a September native rerun.

## September 7 engine invocation reading

`SESSION-STARTUP-READING.3.3.18` reads the complete call dispatcher and
`execute_user_function`. Registered function calls reject keywords, check minimum
arity for a signature or exact legacy arity, then evaluate arguments in caller
context. A typed final codeblock parameter is checked before entering the function.
The executor rejects active-name recursion before taking the caller's variable
stores, installs fresh fixed/rest bindings, suspends rule-declaration tracking,
and evaluates the body. It resumes tracking, restores all caller stores and exits
the active-name entry before returning the body's Result with function context.
Callable codeblocks use a separate parameter-only scope, documented in
[[rust-callable-codeblock-dynamic-invocation]]. The store implementations and body
evaluator retain their later reading owners. Fresh neutral callable proof passes
7 literals/11 calls/23 mutations; native counts above remain dated.
