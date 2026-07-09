---
id: dart-runtime-value-control-tree-helpers
title: Dart runtime executes value blocks, controls, with-blocks, and tree traversal callbacks
answers:
  - does Dart execute expression valued blocks
  - does Dart keep return local inside value blocks
  - does Dart support attached if elseif else
  - does Dart support marker form if elseif else endif
  - does Dart support attached when otherwise
  - does Dart support attached switch case default
  - does Dart support attached while
  - does Dart support inline if and switch helpers
  - does Dart support helper with trailing blocks
  - does Dart support receiver with trailing blocks
  - does Dart support hash tree traversal callbacks
  - does Dart support array tree traversal callbacks
  - what callback variables does Dart tree traversal bind
date: 2026-07-09
status: current
tags: [dart, runtime, helpers, controls, tree-traversal, callbacks, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.4.3.5 extends dart/lib/src/action/action_parser.dart, dart/lib/src/runtime/interpreter.dart, test/action_ast_parser_test.dart, and test/runtime_interpreter_test.dart. Focused tests prove branch-continuation statement splitting, expression-valued blocks, block-local return, attached and inline controls, helper/receiver with trailing blocks, hash and array tree traversal callbacks, non-aggregate receiver behavior, and scoped binding restoration. DART-BACKEND-PARITY.6.2.2 adds grouped marker-form if/elseif/else/endif execution in action and value blocks."
reverify: "cd dart && dart test test/action_ast_parser_test.dart && dart test test/runtime_interpreter_test.dart && dart analyze --fatal-infos --fatal-warnings"
---

Dart runtime helper/control execution lives in
`dart/lib/src/runtime/interpreter.dart`, with one parser support seam in
`dart/lib/src/action/action_parser.dart` for adjacent attached branch
continuations.

`LinkedSpecRuntimeEngine` now evaluates expression-valued blocks in value
positions. A non-empty block yields its final expression unless a block-local
`return(...)` / `return_undef()` runs first. That local return skips later
statements inside the block without becoming the surrounding rule return.

Statement controls now execute inside action blocks: attached `if` / `elseif` /
`else`, marker-form `if(...)` / `elseif(...)` / `else()` / `endif()`, `when` /
`otherwise`, attached `switch` / `case` / `default`, and attached `while` with
the deterministic iteration guard. Value positions also support lazy inline
`if(...)` and `switch(...)`.

Trailing block helpers now execute for helper-form `with(value) { ... }` /
`with() { ... }` and receiver-form `.with() { ... }`. These forms scope `value`
while the callback block runs and restore any prior scalar/array/hash binding
afterward.

Receiver tree traversal callbacks now execute for hash and array receivers:
`walk_leaves`, `map_leaves`, and `reduce_leaves(initial)`. Hash traversal is
sorted-key depth-first, treats nested hashes as interiors, and treats arrays or
scalars as leaves. Array traversal is depth-first by zero-based index, treats
nested arrays as interiors, and treats hashes or scalars as leaves.

Callback frames bind scoped scalar `value`, `path`, and `depth`; hash callbacks
also bind `key`; array callbacks also bind `index`; reduce callbacks also bind
`acc`. Existing scalar, array, or hash bindings with those names are restored
after callback execution.

`BACKTRACK-SURFACE-RUST-ALIGNMENT.1` has since landed explicit cursor controls
and cursor/input helpers. Later `DART-BACKEND-PARITY` leaves closed the full
99-fixture corpus gate, wired focused Dart verification, deferred generated
source to a future source-emitter lane, and productized the Dart-specific CLI.
The remaining Dart parity frontier is final no-drift closeout.

Related facts: [[dart-runtime-hash-helpers]], [[dart-runtime-array-helpers]],
[[dart-runtime-rule-interpreter]], [[dart-runtime-backtrack-cursor-helpers]],
[[dart-starter-corpus-batch]],
[[terse-expression-valued-block-early-return]],
[[terse-trailing-block-arguments-final-state]], [[rust-hash-tree-traversal-receiver-blocks]],
[[rust-array-tree-traversal-receiver-blocks]].
