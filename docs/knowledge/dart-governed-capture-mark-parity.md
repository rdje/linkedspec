---
id: dart-governed-capture-mark-parity
title: Dart executes governed capture and the complete named-mark contract exactly
answers:
  - "does Dart pass the exhaustive anonymous capture fixture"
  - "does Dart pass the exhaustive named mark fixture"
  - "does Dart implement mark entry start and mark match end"
  - "does Dart implement mark line mark col and clear mark"
  - "are Dart complete named mark names in the shared 246 name inventory"
  - "how does Dart store LinkedSpec marks"
  - "are Dart capture positions and lengths character based"
  - "does Dart preserve bare mark names symbolically"
  - "does Dart AND blind-call return ordered child values implicitly"
date: 2026-07-10
status: current
tags: [dart, capture, marks, blind-call, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.2 plus FUTURE-PARITY-BACKLOG.17.2; exact governed, implicit-result, rule-local-mark, multibyte-projection, and complete seven-helper locks in dart/test/runtime_interpreter_test.dart and dart/test/complete_named_mark_contract_test.dart; tools/run_dart_local.sh passes formatting, fatal analysis, 214 tests, 61x2 CLI, and 105/105 corpus."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/runtime_interpreter_test.dart -n 'capture fixture exactly|implicit AND blind-call|named marks rule-local|multibyte mark positions' test/complete_named_mark_contract_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings"
---

# Dart Governed Capture / Mark Parity

`FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.2` closes Dart execution of the governed anonymous and named capture sources.
The runtime stores capture anchors and rule-local named marks as Dart string code-unit offsets, the unit required by
`substring`, while public positions and lengths are projected in Unicode characters. Advancing helpers update an
anchor only after validating the requested span.

Bare mark arguments such as `mark_here(origin)` are symbolic names read from the typed argument, not scalar value
lookups. The runtime covers stable and advancing anonymous reads, anonymous-to-named bridging and reset, current
and input-boundary marks, mark copy/existence/position, stable and advancing named reads, and two-mark reads.

`FUTURE-PARITY-BACKLOG.17.2` adds the four entry/local edge writers, `mark_line`, `mark_col`, and `clear_mark` over
that same rule-local code-unit store. Missing positions and locations remain `undef`; line and column projections
are 1-based Unicode-character locations. Native execution, generated-plan execution, emitted-state
reconstruction, and the primary CLI return the exact neutral parent/child fixture.

The seven names now live in the shared `supportedActionIrCallNames` inventory, while
`completeNamedMarkActionIrCallNames` remains an exact focused-family view. Julia `.17.3` and Lua `.17.4` consume
the unchanged contract; `.17.5` admits all seven at 246 shared names and independently reverse-checks all 122
public Perl contracts so another symmetric omission fails.

The real fixture wrapper also proves implicit blind-call collection: a non-repeated `AND` blind-call parent with no
explicit return surfaces its ordered successful child values. An independent two-child regression locks that
contract separately from the capture family.

## September 10 bounded consumer reading

`DART-STARTUP-READING.1.37` completes all 92 lines of
`dart/test/complete_named_mark_contract_test.dart`. Its three tests pass in a selected
38-test suite. The exact seven-name inventory and neutral Unicode fixture pass native,
generated-plan, normalized-state reconstruction extracted from emitted source, and
in-process primary CLI routes. This consumer does not compile an independent emitted
module. Its different-label fixture does not establish same-label recursive isolation;
that distinction remains owned by [[complete-named-mark-perl-rust-parity]].
The neutral checker passes seven helpers and three drift mutations.

## September 10 interpreter fixture reading complete

`DART-STARTUP-READING.1.46` completes the interpreter consumer through line 1821.
The exact anonymous/named capture, pure, position and marker fixtures pass in the
68-test native selection. Ordinary cursor/input helpers use a BMP multibyte example;
no new astral helper-boundary proof follows from that example. Neutral named-mark
governance remains seven helpers/three mutations. Earlier emitted-carrier and
Unicode admission evidence remains distinct from this focused rerun.
