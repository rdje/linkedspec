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
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/runtime_matching_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings"
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

## 2026-09-09 — alternatives, capture provenance and structural dispatch

`DART-STARTUP-READING.1.22` reads matching.dart 1-900. Alternative-specific matching
preserves the authored index, seek selects its best candidate and consume takes
the first matching alternative. Whole groups keep absent positions as empty text;
compact captures retain only participating groups plus their original indexes.
Reindexing preserves those groups, names and regex options.

[[dart-staged-ast-enrichment-marker-provenance]] remains the capture-span authority:
lazy per-match instrumentation inserts uniquely named suffix probes, reruns with
the same option bits and checks whole boundaries/text plus each selected capture.
Unprovable patterns, including numeric backreferences, yield absent provenance;
ordinary matches do not run the probes. No indexOf-based span guess is introduced.

The structural bridge recognizes the shipped family signatures, derives canonical
Unicode rule-label atoms and routes bounded block/fluent/function/EBNF matchers.
[[dart-structural-pcre-parser-smoke-parity]] retains that limited scope; this does
not admit general PCRE. The range ends inside _matchEbnfReturnScalar, continued
by .1.23. All 132 selected tests and structural corpus 31/31 pass; no new defect
is established and previous regex limitations retain their owners.
