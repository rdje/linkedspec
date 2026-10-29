---
id: dart-pure-blind-dependency-regex-gap
title: Dart dependency-regex construction rejects declared pure-code blind targets
answers:
  - "why does Dart compileSpec require a regex for a pure code blind child after validation succeeds"
  - "which task repairs Dart dependency pattern construction for no regex blind rules"
date: 2026-10-29
status: confirmed; P1 repair48.3.3 after48.3.2 before48.4/admission
evidence: "dart-rule-accumulator-intake.json.gz retains public Perl4 source pairs, Dart pure-code compiler normal/stack, and separate qualified progress controls."
reverify: "Recover retained public probe and original blind_implicit_zero_progress.json; use routed Perl/Dart wrappers under owning48.3.3."
---

The existing blind declaration contract permits a pure-code Child containing
only `I{return("C")}`. Current public Perl native/emitted accept the three
repeated nonconsuming sources (null/null/[] at0) and a consuming empty-array
control ([[]] at1). Dart validation now accepts the declaration, but compileSpec
still tries to derive Child regex slot0 with0 slots. The actual public stack
identifies `_dependencyPatternFor` and `_buildDependencyRegexState` in
`dart/lib/src/compiler/compiled_spec.dart`.

48.3.3 owns this compiler repair immediately after48.3.2, before peers/admission.
Action-slot catalogs/indices/unknown-target diagnostics stay strict; do not invent
a regex for a blind call. The separate qualified progress fixture adds only a
zero-width `/(?=x)/` slot to the three Child definitions; it isolates the current
runtime cutoff and gives no pure-code compiler credit. Both actual fixture
epochs, source errors and reference results are retained.
