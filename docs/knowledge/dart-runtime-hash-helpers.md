---
id: dart-runtime-hash-helpers
title: Dart runtime executes hash helper family and receiver chains
answers:
  - does Dart runtime support hash receiver chains
  - does Dart runtime support sorted_keys sorted_values count_keys
  - does Dart runtime support merge_hash bare overlay
  - does Dart runtime support set_key statement mutation
  - does Dart runtime keep receiver set_key pure
  - does Dart runtime support flat_hash
  - does Dart runtime support direct hash index assignment values
  - does Dart runtime splice flat hash values inside hash constructor
date: 2026-07-09
status: current
tags: [dart, runtime, helpers, hash, receiver-chains, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.4.3.4 extends dart/lib/src/runtime/interpreter.dart, test/runtime_interpreter_test.dart, and test/action_contracts_test.dart. Focused tests prove hash receiver chains, key/value views, sorted key/value arrays, key predicates, merge/drop/pick/rename/set helpers, direct hash-index assignment values, statement/value set_key boundaries, bare-overlay merge behavior, flat_hash, and explicit flat-style hash splicing inside hash(...)."
reverify: "cd dart && dart test test/runtime_interpreter_test.dart && dart test test/action_contracts_test.dart && dart analyze --fatal-infos --fatal-warnings"
---

Dart runtime hash helper execution lives in
`dart/lib/src/runtime/interpreter.dart`.

`LinkedSpecRuntimeEngine` now evaluates bare hash working variables as hash
snapshots in supported hash-consuming helper slots and compatible receiver
chains. This allows examples such as `meta.sorted_keys().join_values(",")`,
`meta.set_key("stage", "normalized").count_keys()`, and
`hash(meta).rename_key("a", "aa").drop_keys("b").set_key("z", 4)`.

The supported hash helper slice includes `count_keys`, `sorted_keys`,
`sorted_values`, `has_key`, `merge_hash`, `set_key`, `rename_key`, `drop_keys`,
`pick_keys`, and `flat_hash`.

Statement-level `set_key(meta, key, value)` and `set_key(hash(meta), key,
value)` mutate named working hashes. Value-form and receiver-form
`set_key(...)` are pure unless the caller stores the returned hash. Direct
`meta[key] = value` expressions return the updated hash snapshot.

`merge_hash(copy(hash(base)), overlay)` consumes the later bare `overlay` hash,
matching the documented bare-overlay boundary. A bare first argument remains a
scalar/value read and is not treated as the base hash. `hash(...)` splices
explicit `flat(...)` / `flat_hash(...)` hash arguments, while ordinary map field
values remain nested values.

`DART-BACKEND-PARITY.4.3.5` has since landed value blocks, structured controls,
with-blocks, and tree traversal callback helpers. `DART-BACKEND-PARITY.4.4` has
since landed BACKTRACK/IBACKTRACK cursor rewinds and cursor/input helpers.
Tracing, staged function execution, full corpus output parity, and per-variant
CLI productization remain later Dart leaves.

Related facts: [[dart-runtime-array-helpers]],
[[dart-runtime-value-control-tree-helpers]],
[[dart-runtime-core-value-capture-helpers]], [[dart-runtime-backtrack-cursor-helpers]],
[[terse-hash-receiver-value-chains]],
[[terse-merge-hash-bare-overlay-boundary]], [[typed-wrapper-quoted-name-boundaries]].
