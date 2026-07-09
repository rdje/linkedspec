---
id: dart-runtime-backtrack-cursor-helpers
title: Dart runtime implements explicit cursor controls and cursor/input helpers
answers:
  - does Dart runtime support BACKTRACK
  - does Dart runtime support IBACKTRACK
  - does Dart runtime support save_cursor restore_cursor
  - does Dart runtime support rewind_match_start rewind_entry_start
  - what does IBACKTRACK mean
  - does Dart runtime support cursor_pos cursor_rest input_slice
  - how does Dart implement local cursor rewind
date: 2026-07-09
status: current
tags: [dart, runtime, cursor, helpers, BACKTRACK-SURFACE-RUST-ALIGNMENT, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.4.4 first landed Dart cursor/input helper execution. BACKTRACK-SURFACE-RUST-ALIGNMENT.1 replaces the ambiguous public backtrack surface with explicit cursor controls in dart/lib/src/action/action_contracts.dart, dart/lib/src/runtime/interpreter.dart, and test/runtime_interpreter_test.dart. Focused tests prove save_cursor()/restore_cursor() stack semantics, rewind_match_start()/rewind_entry_start() anchor rewinds, consume mode from a rewound cursor, and char-based cursor/input helper values. Old BACKTRACK/IBACKTRACK and lowercase backtrack(label)/ibacktrack(label) are not current API."
reverify: "cd dart && dart test test/runtime_interpreter_test.dart test/runtime_matching_test.dart && dart analyze --fatal-infos --fatal-warnings"
---

Dart runtime cursor-control and cursor/input helper execution lives in
`dart/lib/src/runtime/interpreter.dart` on top of the match-register state in
`dart/lib/src/runtime/matching.dart`.

The current user-facing cursor controls are:

- `save_cursor()` pushes the current live cursor onto an explicit stack.
- `restore_cursor()` pops that stack and restores the live cursor when present.
- `rewind_match_start()` rewinds the live cursor to the start of the current
  local match.
- `rewind_entry_start()` rewinds the live cursor to the start of the
  initial/entry match for the current context.

`BACKTRACK()` / `IBACKTRACK()` and lowercase `backtrack(label)` /
`ibacktrack(label)` are not current portable API. The old `I` in `IBACKTRACK`
referred to the Initial/`I` lifecycle context, not case-insensitivity; current
specs should write `rewind_entry_start()` for that anchor rewind.

These helpers update the live parser cursor and register cursor. They do not
roll back match records, variables, arrays, hashes, accumulators, lifecycle
effects, or branch decisions.

Dart exposes cursor/input helpers with user-facing char offsets and slices:
`cursor_pos`, `cursor_line`, `cursor_col`, `cursor_rest`, `cursor_rest_len`,
`input_text`, `input_len`, `input_slice`, `input_end_pos`, `input_end_line`, and
`input_end_col`. Internally, Dart still stores cursors as UTF-16 code-unit
offsets and converts at helper boundaries.

Related facts: [[dart-runtime-matching-state]], [[dart-runtime-rule-interpreter]],
[[dart-runtime-core-value-capture-helpers]], [[dart-runtime-value-control-tree-helpers]].
