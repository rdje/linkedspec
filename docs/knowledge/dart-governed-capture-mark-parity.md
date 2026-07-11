---
id: dart-governed-capture-mark-parity
title: Dart executes the governed anonymous and named capture/mark fixtures exactly
answers:
  - "does Dart pass the exhaustive anonymous capture fixture"
  - "does Dart pass the exhaustive named mark fixture"
  - "how does Dart store LinkedSpec marks"
  - "are Dart capture positions and lengths character based"
  - "does Dart preserve bare mark names symbolically"
  - "does Dart AND blind-call return ordered child values implicitly"
date: 2026-07-10
status: current
tags: [dart, capture, marks, blind-call, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.2; exact governed, implicit-result, rule-local-mark, and multibyte projection locks in dart/test/runtime_interpreter_test.dart; tools/run_dart_local.sh passes formatting, fatal analysis, 160 tests, 61x2 CLI, and 99/99 corpus."
reverify: "cd dart && dart test test/runtime_interpreter_test.dart -n 'capture fixture exactly|implicit AND blind-call|named marks rule-local|multibyte mark positions' && dart analyze --fatal-infos --fatal-warnings"
---

# Dart Governed Capture / Mark Parity

`FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.2` closes Dart execution of the governed anonymous and named capture sources.
The runtime stores capture anchors and rule-local named marks as Dart string code-unit offsets, the unit required by
`substring`, while public positions and lengths are projected in Unicode characters. Advancing helpers update an
anchor only after validating the requested span.

Bare mark arguments such as `mark_here(origin)` are symbolic names read from the typed argument, not scalar value
lookups. The runtime covers stable and advancing anonymous reads, anonymous-to-named bridging and reset, current
and input-boundary marks, mark copy/existence/position, stable and advancing named reads, and two-mark reads.

The real fixture wrapper also proves implicit blind-call collection: a non-repeated `AND` blind-call parent with no
explicit return surfaces its ordered successful child values. An independent two-child regression locks that
contract separately from the capture family.
