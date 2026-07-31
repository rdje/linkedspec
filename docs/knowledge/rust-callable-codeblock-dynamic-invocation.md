---
id: rust-callable-codeblock-dynamic-invocation
title: Rust invokes bound callable codeblocks in dynamic caller context
answers:
  - "does Rust execute cb args codeblock calls"
  - "how does Rust invoke a callable codeblock variable"
  - "do Rust codeblock parameters restore after an error"
  - "do Rust codeblock mutations affect caller variables"
  - "can a Rust codeblock result feed key access or a receiver chain"
  - "does a helper or function shadow a same named Rust codeblock"
  - "what diagnostics does Rust callable codeblock invocation emit"
  - "how does Rust reject direct and mutual codeblock recursion"
  - "does emitted Rust execute callable codeblocks"
date: 2026-07-30
status: current
tags: [rust, actionir, codeblock, callable, dynamic-scope, diagnostics, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.11.4.2 adds bound-codeblock fallback dispatch after static callables, once-only ordered argument evaluation, recursively copied temporary fixed/rest bindings, cleanup-safe restoration, caller-visible nonparameter stores, local results, typed value access, exact portable failures and ordered cycles, plus native/reconstructed/generated-plan/emitted-source proof against every neutral valid and invalid call."
reverify: "bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test callable_codeblock_literal_contract"
---

# Rust Callable Codeblock Dynamic Invocation

Rust resolves `cb(args)` as a bound codeblock only after controls, helpers, and registered user functions. A
same-named static callable therefore wins. If the name is bound to another runtime value kind, execution fails as
`value_not_callable`; an unbound ordinary call outside a codeblock retains the generic warning/`undef` behavior.

Positional arguments evaluate exactly once from left to right. Fixed arguments and a fresh rest array are deep
copies in temporary uniform bindings. Existing same-name scalar/array/harray bindings restore on success or
failure, while all nonparameter reads and mutations use the caller's current stores. The retained typed ActionIR
body yields its final expression or invocation-local `return(...)`; the result may enter typed key/index access,
continue through a receiver chain, or be discarded by a standalone call. No lexical environment or host closure
is captured.

The structured runtime envelope reports exact neutral codes and fields for `codeblock_arity_mismatch`,
`codeblock_keyword_arguments_unsupported`, `value_not_callable`, `unknown_helper`, and
`codeblock_recursion_unsupported`. The active-name stack preserves an ordered direct or mutual cycle including
the closing identity and is restored after failures.

Native execution, `CompiledSpec` JSON reconstruction, generated-plan execution, and independently compiled
emitted Rust all reuse the same engine and typed record. Generic attached/parenthesized final-block normalization
remains `FUTURE-PARITY-BACKLOG.11.4.3`; explicit invocation does not promote the full generic capability.

Related facts: [[rust-callable-codeblock-literal-state]], [[callable-codeblock-literal-contract]],
[[perl-callable-codeblock-dynamic-invocation]], [[variadic-callable-signature-seams]].
