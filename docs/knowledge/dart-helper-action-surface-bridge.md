---
id: dart-helper-action-surface-bridge
title: Dart bridges the shipped-smoke helper/action surfaces after the regex bridge
answers:
  - "does Dart support capture_slice"
  - "does Dart support print and say helpers"
  - "does Dart support logical and or not helpers"
  - "does Dart support exit_now"
  - "what does DART-BACKEND-PARITY.6.2.4.2 prove"
date: 2026-07-09
status: current
tags: [dart, helpers, action-parser, corpus, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.6.2.4.2 adds Dart runtime execution for direct anonymous capture-slice helpers, diagnostic print/print_each/say, logical and/or/not, and Rust-style terminating exit_now(...). It also fixes action_parser.dart delimiter matching so quoted helper string arguments containing delimiters no longer make calls such as print(\"...(\", ...) fall back to raw_perl. Focused action parser/runtime tests, full Dart tests, and the shipped-smoke diagnostic window prove the previous unsupported-helper/raw-print failures have moved to recursion/default-mode/output mismatches, deliberate exit_now diagnostic branches, and already routed PCRE structural regex blockers."
evidence_update_2026_07_17_logical_contract: "FUTURE-PARITY-BACKLOG.5.2.4 supersedes the bridge's short-circuit/empty-call semantics without changing helper availability. Dart now validates logical arity before effects, evaluates valid operands once left-to-right, shares runtimeLogicalTruth with lazy controls, and passes native/normalized/generated-plan/standalone-emitted/primary neutral proof at 3 complete / 5 pending."
reverify: "cd dart && dart test test/action_ast_parser_test.dart test/runtime_interpreter_test.dart && dart analyze --fatal-infos --fatal-warnings && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31 || true"
---

This leaf is a runtime bridge, not the final corpus-parity solution. The shipped
smoke window remains 2/31 green, but it no longer stops because Dart lacks the
helper/action surfaces below:

- Direct anonymous capture-slice helpers:
  `start_capture_slice`, `capture_slice`, `capture_slice_len`,
  `capture_slice_until_cursor`, `capture_slice_until_cursor_len`,
  `capture_slice_pos`, `capture_slice_line`, and `capture_slice_col`.
- Diagnostic output helpers: `print`, `print_each`, and `say`.
- Logical helpers: `and`, `or`, and `not`.
- Fatal diagnostic control helper: `exit_now(...)`, implemented as a terminating
  `RuntimeInterpreterException` matching the Rust runtime's error-style contract.
- Current helper-form parsing for quoted `print("...", "\n")` calls whose string
  arguments contain delimiters.

Remaining failures belong to later leaves: recursive/default-mode and delimiter
semantics in `.6.2.4.3`, residual output shape parity in `.6.2.4.4`, and PCRE
structural regex constructs in `.6.2.4.6`.

The original surface bridge deliberately inherited Dart's then-current short-circuit and empty-call behavior.
`FUTURE-PARITY-BACKLOG.5.2.4` now supersedes only those semantics with ADR `0043`: eager valid operands,
pre-effect arity diagnostics, real booleans, and one typed helper/control truth boundary. Helper names and parser
surface remain unchanged.

Related facts: [[dart-regex-dialect-bridge]],
[[dart-shipped-corpus-smoke-split]], [[rust-anonymous-capture-slice-family]],
[[dart-logical-helper-neutral-runtime]].
