---
id: dart-callable-codeblock-dynamic-invocation
title: Dart invokes bound callable codeblocks in dynamic caller context
answers:
  - "does Dart execute cb args codeblock calls"
  - "how does Dart invoke a callable codeblock variable"
  - "do Dart codeblock parameters restore after an error"
  - "do Dart codeblock mutations affect caller variables"
  - "can a Dart codeblock result feed key access or a receiver chain"
  - "does a helper or function shadow a same named Dart codeblock"
  - "what diagnostics does Dart callable codeblock invocation emit"
  - "how does Dart reject direct and mutual codeblock recursion"
  - "does emitted Dart execute callable codeblocks"
date: 2026-07-30
status: current
tags: [dart, actionir, codeblock, callable, dynamic-scope, diagnostics, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.11.5.2 adds bound-codeblock fallback dispatch after static callables, once-only ordered argument evaluation, recursively copied temporary fixed/rest bindings, cleanup-safe restoration, caller-visible nonparameter stores, local results, typed value access, exact portable failures and ordered cycles, plus native/reconstructed/generated-plan/emitted-source proof against every neutral valid and invalid call."
reverify: "bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py && (cd dart && bash ../tools/run_dart_project_data.sh test test/callable_codeblock_literal_contract_test.dart test/action_ast_parser_test.dart test/variadic_user_function_contract_test.dart) && bash tools/run_dart_local.sh"
---

# Dart Callable Codeblock Dynamic Invocation

Dart resolves `cb(args)` as a bound codeblock only after existing controls, helpers, and registered user functions.
A colliding static callable therefore wins. A bound non-codeblock fails as `value_not_callable`; an unbound call
fails through the portable `unknown_helper` diagnostic instead of falling into a host-language callback path.

Positional arguments evaluate exactly once from left to right. Fixed arguments and a fresh final-rest array are
recursively copied into the runtime's established scoped variable bindings. Those bindings restore prior
same-name scalar/array/harray state in reverse order on success or failure. Other reads and writes use the caller's
current stores, so nonparameter mutation persists. Invocation executes the retained typed ActionIR body, keeps
`return(...)` local, copies the result before restoration, and permits the result to enter typed key/index access,
continue through a receiver chain, or be discarded.

The structured runtime envelope reports `codeblock_arity_mismatch`,
`codeblock_keyword_arguments_unsupported`, `value_not_callable`, `unknown_helper`, and
`codeblock_recursion_unsupported` with the neutral `callable_name`, `expected`, `got`, `value_kind`, `name`, and
ordered `cycle` fields as applicable. A separate active-codeblock stack rejects direct and mutual recursion while
cleanup remains exception-safe. Narrow colon-keyword parsing supplies the governed rejection and does not convert
legacy `name = value` argument expressions into keywords.

Native execution, normalized emitted-payload reconstruction, generated-plan execution, and independently compiled
emitted Dart all reuse the same parser/compiler/runtime and plain eight-field record. Generic attached or
parenthesized final-block normalization remains `FUTURE-PARITY-BACKLOG.11.5.3`; explicit invocation does not
promote the complete generic capability.

Related facts: [[dart-callable-codeblock-literal-state]], [[callable-codeblock-literal-contract]],
[[perl-callable-codeblock-dynamic-invocation]], [[rust-callable-codeblock-dynamic-invocation]],
[[variadic-callable-signature-seams]].

## 2026-09-09 — helper-mediated recursion identity qualification

DART-STARTUP-READING.1.18 confirms that with/tree callback dispatch supplies the helper
name as the active-codeblock identity. Distinct nested with/map_leaves callbacks
are falsely rejected, and cb recursing through with(v, cb) reports with -> with instead
of cb -> cb. Direct bound recursion retains cb identity. Nine native/SpecFile-JSON controls,
including three successful single/sequential/different-helper controls, live in
[[dart-callback-helper-recursion-identity-gap]]. Gated repair .2.10 owns identity retention
and broader carrier proof; the 140 selected test passes do not cover this new boundary.
