---
id: dart-runtime-backtrack-cursor-helpers
title: Dart runtime implements BACKTRACK/IBACKTRACK local cursor rewinds and cursor/input helpers
answers:
  - does Dart runtime support BACKTRACK
  - does Dart runtime support IBACKTRACK
  - what does IBACKTRACK mean
  - does Dart support lowercase backtrack ibacktrack
  - does Dart runtime support cursor_pos cursor_rest input_slice
  - how does Dart implement local cursor rewind
date: 2026-07-09
status: current
tags: [dart, runtime, backtrack, cursor, helpers, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.4.4 extends dart/lib/src/action/action_contracts.dart, dart/lib/src/runtime/interpreter.dart, dart/lib/src/runtime/matching.dart, test/action_contracts_test.dart, and test/runtime_interpreter_test.dart. Focused tests prove BACKTRACK rewinds to the current local match start, IBACKTRACK rewinds to the initial/entry I-context match start, lowercase backtrack(label)/ibacktrack(label) canonicalize to the same helpers, consume mode continues from the rewound cursor, and cursor/input helpers expose char-based values."
reverify: "cd dart && dart test test/runtime_interpreter_test.dart test/runtime_matching_test.dart && dart analyze --fatal-infos --fatal-warnings"
---

Dart runtime cursor rewind and cursor/input helper execution lives in
`dart/lib/src/runtime/interpreter.dart` on top of the match-register state in
`dart/lib/src/runtime/matching.dart`.

`BACKTRACK()` and `IBACKTRACK()` are distinct user-facing helpers for parity
with the Perl/Rust contract:

- `BACKTRACK()` rewinds the live cursor to the start of the current local match.
- `IBACKTRACK()` rewinds the live cursor to the start of the initial/entry match
  for the current context. The `I` is the Initial/`I` lifecycle context, not
  case-insensitivity.

Both helpers are cursor-only rewinds. They update the live parser cursor and
register cursor; they do not roll back match records, variables, arrays, hashes,
accumulators, lifecycle effects, or branch decisions.

Dart also recognizes the legacy lowercase spellings `backtrack(label)` and
`ibacktrack(label)` through ActionIR canonicalization. The label argument is
ignored, matching the Perl compatibility contract; the active cursor context
selects the target anchor.

Dart exposes cursor/input helpers with user-facing char offsets and slices:
`cursor_pos`, `cursor_line`, `cursor_col`, `cursor_rest`, `cursor_rest_len`,
`input_text`, `input_len`, `input_slice`, `input_end_pos`, `input_end_line`, and
`input_end_col`. Internally, Dart still stores cursors as UTF-16 code-unit
offsets and converts at helper boundaries.

Related facts: [[dart-runtime-matching-state]], [[dart-runtime-rule-interpreter]],
[[dart-runtime-core-value-capture-helpers]], [[dart-runtime-value-control-tree-helpers]].
