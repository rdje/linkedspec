---
id: dart-runtime-hash-helpers
title: Dart runtime executes hash helper family and receiver chains
answers:
  - does Dart runtime support hash receiver chains
  - does Dart runtime support sorted_keys sorted_values count_keys
  - does Dart runtime support merge_hash bare overlay
  - does Dart runtime support merge_hash bare base
  - does Dart runtime support set_key statement mutation
  - does Dart runtime keep receiver set_key pure
  - does Dart runtime support flat_hash
  - does Dart runtime support direct hash index assignment values
  - does Dart runtime splice flat hash values inside hash constructor
date: 2026-07-13
status: current
tags: [dart, runtime, helpers, hash, receiver-chains, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.4.3.4 extends dart/lib/src/runtime/interpreter.dart, test/runtime_interpreter_test.dart, and test/action_contracts_test.dart. Focused tests prove hash receiver chains, key/value views, sorted key/value arrays, key predicates, merge/drop/pick/rename/set helpers, direct hash-index assignment values, statement/value set_key boundaries, bare base/overlay merge behavior, flat_hash, and explicit flat-style hash splicing inside hash(...). FUTURE-PARITY-BACKLOG.12.1 later made bare typed bindings canonical and rejected exact aggregate selectors."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/runtime_interpreter_test.dart && bash ../tools/run_dart_project_data.sh test test/action_contracts_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings && bash ../tools/run_dart_project_data.sh run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --case terse_2_3_4_deep_pure_helper_composition"
---

Dart runtime hash helper execution lives in
`dart/lib/src/runtime/interpreter.dart`.

`LinkedSpecRuntimeEngine` now evaluates bare hash working variables as hash
snapshots in supported hash-consuming helper slots and compatible receiver
chains. This allows examples such as `meta.sorted_keys().join_values(",")`,
`meta.set_key("stage", "normalized").count_keys()`, and
`meta.rename_key("a", "aa").drop_keys("b").set_key("z", 4)`.

The supported hash helper slice includes `count_keys`, `sorted_keys`,
`sorted_values`, `has_key`, `merge_hash`, `set_key`, `rename_key`, `drop_keys`,
`pick_keys`, and `flat_hash`.

Statement-level `set_key(meta, key, value)` mutates the named working harray.
Value-form and receiver-form `set_key(...)` are pure unless the caller stores
the returned harray. Direct `meta[key] = value` expressions return the updated
harray snapshot.

`merge_hash(base, overlay)` consumes both bare typed harrays and later arguments
override earlier keys. `merge_hash(copy(base), overlay)` is the equivalent
explicit-copy spelling. Exact `hash(base)` is a removed selector and rejects
before execution. Multi-argument `hash(...)` construction splices explicit
`flat(...)` / `flat_hash(...)` harray arguments, while ordinary map field values
remain nested values.

`DART-BACKEND-PARITY.4.3.5` has since landed value blocks, structured controls,
with-blocks, and tree traversal callback helpers. `BACKTRACK-SURFACE-RUST-ALIGNMENT.1`
has since landed explicit cursor controls and cursor/input helpers.
Later Dart leaves landed tracing, staged function execution, full corpus output
parity, local verification wiring, mdBook/generation-source decision closeout,
and per-variant CLI productization in `DART-BACKEND-PARITY.7.4`.

Related facts: [[dart-runtime-array-helpers]],
[[dart-runtime-value-control-tree-helpers]],
[[dart-runtime-core-value-capture-helpers]], [[dart-runtime-backtrack-cursor-helpers]],
[[terse-hash-receiver-value-chains]],
[[terse-merge-hash-bare-overlay-boundary]], [[typed-wrapper-quoted-name-boundaries]].

## 2026-09-09 — constructor splicing qualification

The constructor support above is incomplete for positioned splices. _callHash pairs raw
arguments first, so leading/middle flat(meta) can become a container-text key and consume
the following field name. Its later map merge also overrides later authored duplicates.
flat_array is absent from hash splice classification and its list becomes one raw token.

[[dart-hash-splice-pairing-gap]] retains nine native/SpecFile-JSON cases and nine Perl
facade/source comparisons. Perl handles the flat_array control but lowers the six complete
map-splice bodies to its existing unsupported hash sentinel. Plain pairs and ordinary
nested maps succeed on both backends. DART-STARTUP-READING.2.11 owns Dart repair and
carrier proof with FUTURE-PARITY-BACKLOG.5's helper-context decisions; no repair or
fresh Dart emitted result is claimed by the .1.19 reading.

## 2026-09-09 — supplementary-character key order qualification

sorted_keys and sorted_values use host UTF-16 key ordering. U+10000 therefore precedes
U+E000, opposite the paired Perl reference; sorted_values follows the same reversed key
sequence. [[dart-helper-unicode-order-gap]] retains eight helper cases and gated .2.13
owns lexical contract reconciliation, affected consumers and carrier/public repair.
Constructor splice .2.11 remains separate; no fresh emitted ordering result is inferred.
