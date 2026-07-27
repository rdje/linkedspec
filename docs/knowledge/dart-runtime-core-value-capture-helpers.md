---
id: dart-runtime-core-value-capture-helpers
title: Dart runtime core value stores and capture helpers preserve typed shapes
answers:
  - does Dart runtime preserve scalar array hash null boolean number shapes
  - does Dart support hash stores in the runtime interpreter
  - does Dart support hash index assignment
  - does Dart support nested access reads
  - does Dart nested value path assignment autovivify
  - does Dart nested value path assignment return the updated root
  - when does Dart nested value path assignment evaluate index expressions
  - does Dart runtime support entry_named and match_named
  - does Dart runtime support entry_map and match_map
  - does Dart runtime support capture position helpers
date: 2026-07-13
status: current
tags: [dart, runtime, helpers, values, captures, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.4.3.1 extends dart/lib/src/runtime/interpreter.dart and test/runtime_interpreter_test.dart. Focused tests prove scalar assignment, array append, hash reset/mutation, variable-held array/hash reads, non-numeric map keys, nested access reads, bare capture-name lookup, named capture maps, compact capture groups, and start/end position helper values. DART-BACKEND-PARITY.4.3.6 closes helper/value no-drift by aligning Dart nested value-path assignment with the Perl/Rust contract. FUTURE-PARITY-BACKLOG.12.1 later replaced the public typed-wrapper snapshot model with uniform bare bindings and hard-rejected exact aggregate selectors."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/runtime_interpreter_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings"
---

Dart runtime core value and capture helper execution lives in
`dart/lib/src/runtime/interpreter.dart`.

`LinkedSpecRuntimeEngine` may retain private scalar/array/hash stores, but a
`.spec` name exposes one current typed value. The evaluator preserves scalar,
array, harray, `null`, boolean, and number shapes through bare assignment,
array append, hash-index mutation, shape literals, bare reads, and `copy(name)`.
Exact `array(name)` and `hash(name)` selectors are rejected before execution.

Indexed and nested reads support array indexes plus string-key map access, so
forms such as `meta["key"]` and `payload["children"][1]["name"]` evaluate inside
the Dart interpreter. Nested value-path assignment now mirrors the Perl/Rust
contract: successful writes return the updated root value, missing or wrong-shape
intermediate paths return `null` without mutation, final hash keys may be
created, final array indexes may replace or append exactly at the current
length, missing intermediate containers are not autovivified, and segment index
expressions are evaluated before the RHS value expression.

The capture-reader subset now includes `entry_named`, `match_named`,
`entry_has`, `match_has`, `entry_map`, `match_map`, `entry_len`, `match_len`,
`entry_start_pos`, `entry_end_pos`, `match_start_pos`, and `match_end_pos`.
Bare capture names such as `entry_named(name)` are treated as capture keys, not
scalar variable reads.

Related facts: [[dart-runtime-hash-helpers]], [[dart-runtime-string-numeric-helpers]],
[[dart-runtime-rule-interpreter]], [[dart-runtime-matching-state]],
[[typed-wrapper-quoted-name-boundaries]], [[terse-direct-access-explicit-segments]],
[[terse-nested-value-path-assignment]], [[rust-capture-group-helper-indexing]].
