---
id: dart-callable-codeblock-literal-state
title: Dart preserves callable codeblock literals as inert typed state
answers:
  - "does Dart parse callable codeblock literals"
  - "can Dart construct a {|params| body } codeblock"
  - "what fields are in a Dart callable codeblock value"
  - "does constructing a Dart codeblock execute its body"
  - "does a Dart callable codeblock capture a closure or environment"
  - "are Dart callable codeblock spans UTF-16 or Unicode character offsets"
  - "does emitted Dart preserve callable codeblocks"
  - "does Dart semantic introspection report codeblock signatures"
  - "can a Dart variadic user function have a null rest parameter"
  - "can Dart invoke a codeblock variable with cb parentheses"
date: 2026-07-30
status: current
tags: [dart, actionir, codeblock, callable, generated-source, semantic-introspection, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.11.5.1 adds exact {| recognition, the neutral eight-field literal/fixed-rest signature record, containing Unicode-character-coordinate literal/body spans, inert plain-data runtime state, compiled JSON and generated-source preservation, and semantic codeblock shapes. Eight focused tests cover the neutral literal inventory, nine diagnostics, non-execution, user-function transport, the reconstructed variadic-user-function non-null-rest invariant, eager-dependency isolation, and descriptors; dynamic invocation remains .11.5.2."
reverify: "bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py && (cd dart && bash ../tools/run_dart_project_data.sh test test/callable_codeblock_literal_contract_test.dart) && bash tools/run_dart_local.sh"
---

# Dart Callable Codeblock Literal State

Dart recognizes exact `{|params| body }` and `{|| body }` before its existing harray and eager-block brace
classifiers. A valid literal is one plain serializable `codeblock_literal` record with exactly eight top-level
fields: `kind`, `version`, `signature`, `body_source`, `body_ast`, `source_text`, `source_span`, and `body_span`.
The shared signature type now represents fixed signatures with `rest_param = null` as well as final-rest
signatures; the retained body is typed ActionIR, not Dart source. That nullable representation applies to fixed
codeblock literals only: reconstructed variadic user-function signatures must still carry a non-null rest name,
and `validateSpec(...)` rejects a null value before runtime binding.

Literal and body spans are half-open Unicode character offsets in the containing ActionIR source. Nested literals
retain that same coordinate space even though Dart parses string indices as UTF-16 code-unit offsets internally.
Construction returns a recursively copied plain map, captures no environment, and never evaluates the body.
Action contract and removed-selector traversal likewise treat the retained body as a deferred leaf, so body calls
and `retv` reads cannot become eager construction-time dependencies.

The ordinary `CompiledSpec.toJson()` ActionIR payload carries the record. User functions can receive and return it
as ordinary data. Generated-plan execution reuses the compiled object, while emitted Dart embeds the normalized
`SpecFile`; reconstruction reparses the same authored literal through the ordinary compiler/runtime path. No Dart
closure, callback object, or second evaluator is introduced. Semantic binding projection reports
`kind = codeblock` plus the exact fixed/rest callable signature.

Construction/state is intentionally inert. Bound-variable dispatch such as `cb(args)` remains
`FUTURE-PARITY-BACKLOG.11.5.2`; generic attached/parenthesized final blocks remain `.11.5.3`.

Related facts: [[callable-codeblock-literal-contract]], [[dart-variadic-user-functions]],
[[rust-callable-codeblock-literal-state]], [[perl-callable-codeblock-literal-record]].
