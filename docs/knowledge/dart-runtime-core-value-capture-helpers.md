---
id: dart-runtime-core-value-capture-helpers
title: Dart runtime core value stores and capture helpers preserve typed shapes
answers:
  - does Dart runtime preserve scalar array hash null boolean number shapes
  - does Dart support hash stores in the runtime interpreter
  - does Dart support hash index assignment
  - does Dart support nested access reads
  - does Dart runtime support entry_named and match_named
  - does Dart runtime support entry_map and match_map
  - does Dart runtime support capture position helpers
date: 2026-07-09
status: current
tags: [dart, runtime, helpers, values, captures, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.4.3.1 extends dart/lib/src/runtime/interpreter.dart and test/runtime_interpreter_test.dart. Focused tests prove scalar assignment, array append, hash reset/mutation, typed wrapper snapshots, variable-held array/hash reads, non-numeric map keys, nested access reads, bare capture-name lookup, named capture maps, compact capture groups, and start/end position helper values."
reverify: "cd dart && dart test test/runtime_interpreter_test.dart && dart analyze --fatal-infos --fatal-warnings"
---

Dart runtime core value and capture helper execution lives in
`dart/lib/src/runtime/interpreter.dart`.

`LinkedSpecRuntimeEngine` now maintains scalar, array, and hash working stores.
The evaluator preserves scalar, array, hash, `null`, boolean, and number shapes
through scalar assignment, array append, hash-index mutation, shape literals, and
typed wrapper snapshots. `set(hash(name), value)` writes hash storage, while
`hash(name)` and `copy(hash(name))` snapshot it. `array(name)` / `hash(name)` can
also snapshot variable-held list/map values, and `copy(name)` snapshots aggregate
stores when the bare name is a type-implying read.

Indexed and nested reads support array indexes plus string-key map access, so
forms such as `meta["key"]` and `payload["children"][1]["name"]` evaluate inside
the Dart interpreter.

The capture-reader subset now includes `entry_named`, `match_named`,
`entry_has`, `match_has`, `entry_map`, `match_map`, `entry_len`, `match_len`,
`entry_start_pos`, `entry_end_pos`, `match_start_pos`, and `match_end_pos`.
Bare capture names such as `entry_named(name)` are treated as capture keys, not
scalar variable reads.

Related facts: [[dart-runtime-rule-interpreter]], [[dart-runtime-matching-state]],
[[typed-wrapper-quoted-name-boundaries]], [[terse-direct-access-explicit-segments]],
[[rust-capture-group-helper-indexing]].
