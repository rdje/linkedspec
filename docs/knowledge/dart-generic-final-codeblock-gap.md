---
id: dart-generic-final-codeblock-gap
title: Dart generic final-codeblock normalization is metadata-owned
answers:
  - "why does Dart not support generic contextual final codeblock arguments"
  - "does Dart preserve callback codeblock parameter kinds"
  - "where does Dart hard code receiver trailing block names"
  - "does Dart distinguish attached and parenthesized contextual blocks"
  - "how did Dart implement FUTURE-PARITY-BACKLOG 11.5.3"
date: 2026-07-30
status: current
tags: [dart, actionir, codeblock, callable-contract, trailing-block, user-functions, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.11.5.3 preserves fixed_params/codeblock_param/parameter_kinds through Dart definition, staged, registry, semantic, and descriptor-v3 state; one post-registry callable contract converts admitted attached/parenthesized candidates to zero-positional codeblock_argument values and reuses the dynamic executor. Neutral 7/11/9/7/4/8, focused callable 21, and package 375 pass including independent emitted Dart."
reverify: "bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py && (cd dart && bash ../tools/run_dart_project_data.sh test test/user_function_definition_parser_test.dart test/user_function_definition_shell_test.dart test/action_ast_parser_test.dart test/function_registry_test.dart test/staged_parser_registry_test.dart test/runtime_interpreter_test.dart test/callable_codeblock_literal_contract_test.dart)"
---

# Dart Generic Final-Codeblock Normalization

The shared `specs/user_function_definition.spec` already recognizes a final `callback: codeblock` declaration and
returns the neutral `fixed_params`, `codeblock_param`, and sole-entry `parameter_kinds` records in the definition,
body payload, and body parse job. Dart now projects those records to ordered fixed parameters plus the final
codeblock parameter, validates both staged sidecars exactly, and retains `parameterKinds` in `FunctionDefinition`,
`StagedParseJob`, `UserFunctionEntry`, semantic signatures, compiled state, and the exact outward descriptor-v3
union. Mutated sidecar metadata fails before body stitching.

Action parsing still precedes the complete callable registry, so it records plain attached and parenthesized block
arguments as `ActionContextualCodeblockCandidateExpr` with authored syntax provenance but grants no semantics.
Receiver attachment is parsed generically rather than through a method-name allowlist. After the builtin and typed
user-function registry is complete, `action/callable_contract.dart` is the single authority: it validates the
number of value arguments before the declared final slot, converts an admitted candidate to one zero-positional
`ActionCodeblockArgumentExpr`, restores a noncontract parenthesized block to eager `ActionBlockValueExpr`, and
rejects an unknown attached callee.

The normalized value executes through the existing dynamic callable-codeblock evaluator. Helper and receiver
`with` install their scoped `value` only after resolving the callback expression; tree traversal keeps dynamic
`value`, `key`/`index`, `path`, `depth`, and `acc` bindings. An explicit `{|params| ...}` keeps and enforces its own
positional signature, while contextual `{ ... }` is zero-positional and reads those dynamic bindings. Attached
controls, eager blocks, harrays, static callable precedence, and portable malformed/non-codeblock/unknown/arity
diagnostics remain distinct across native, normalized reconstruction, generated plans, and independently compiled
emitted Dart.

Related facts: [[rust-generic-final-codeblock-normalization]], [[dart-runtime-value-control-tree-helpers]],
[[dart-function-registry]], [[dart-callable-codeblock-dynamic-invocation]],
[[final-codeblock-parameter-declaration]], [[callable-codeblock-literal-contract]].
