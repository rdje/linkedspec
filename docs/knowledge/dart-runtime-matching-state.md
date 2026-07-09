---
id: dart-runtime-matching-state
title: Dart runtime matching state supports seek/consume regex matching, char offsets, and entry/local match registers
answers:
  - where is the Dart runtime matching code
  - does Dart support seek and consume regex matching
  - how does Dart track entry and local match state
  - does Dart expose char offsets for match positions
  - how does Dart detect zero-progress matches
date: 2026-07-09
status: current
tags: [dart, runtime, regex, match-state, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.4.1 adds dart/lib/src/runtime/matching.dart and exports RuntimeRegexAlternation, RuntimeRegexMatch, RuntimeMatchRegisters, LinkedSpecParseMode, and offset helpers. test/runtime_matching_test.dart verifies seek/consume behavior, compiled-rule regex-list input, stable alternative identity, captures, named captures, char-offset projection over code-unit spans, entry/local separation, cursor state, and zero-progress detection."
reverify: "cd dart && dart test test/runtime_matching_test.dart && dart analyze --fatal-infos --fatal-warnings"
---

Dart runtime matching lives in `dart/lib/src/runtime/matching.dart`.

`RuntimeRegexAlternation` compiles ordered regex pattern lists, including
`CompiledRule.regexPatterns`, and supports `seek` and `consume` matching through
`LinkedSpecParseMode`. It preserves stable alternative indexes without relying on
a combined-regex branch side channel.

`RuntimeRegexMatch` records the matched alternative, raw Dart code-unit spans,
full/capture-only groups, named captures, char-offset projection, line/column
projection, and zero-width/progress helpers.

`RuntimeMatchRegisters` is the handoff state used by the Dart rule interpreter.
It keeps entry and local matches separate, seeds child entry state from the
caller's local match, tracks cursor position, and exposes zero-progress
detection.

Related facts: [[dart-compiled-spec-state]], [[rust-entry-match-separation]],
[[rust-char-based-offsets]], [[dart-runtime-rule-interpreter]],
[[dart-backend-interpreter-first-plan]].
