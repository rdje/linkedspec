---
id: dart-lossless-child-carrier-readiness
title: Dart lossless child readiness verifies returned ASTs and detached outcome records on six carriers
answers:
  - "does Dart preserve lossless segmentation with real child grammars"
  - "how does Dart lossless child proof inspect staged resource accounting"
  - "which Dart lossless carriers retain engines after child rejection"
  - "how are Dart emitted child readiness modules analyzed and executed"
date: 2026-09-28
status: bounded six-carrier proof verified; Julia and Lua separately owned
tags: [dart, language-readiness, lossless, staged-parsing, provenance, generated-source]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.2 uses the unchanged .spec/JSON corpus on six matched parent-child routes. The actual child constructs its AST; the host supplies frozen authority and span projection. Focused2 and selected88 tests pass, including strict fresh-package analysis and exact ten-module completion. Original13 cases twice, child4/15 and seven mutants preserve independent recognition, scalar slicing, reconstruction and provenance oracles."
reverify:
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter expanded test/nested_tree_readiness_test.dart --name lossless"
  - "cd dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings test/nested_tree_readiness_test.dart"
---

# Returned AST and execution outcome are separate public host outputs

The canonical ledger is `docs/language-readiness/lossless-child-parsing.md`; `.3.4.2` pins tested producer/source
and log hashes. Shared `dart_checks.dart` and `dart_carriers.dart` extend the existing readiness test. The current
scratch allocator is extracted into a reusable function in the same owning file, with unchanged root and prefix.

Dart returns the enriched AST directly and provides a detached complete record through the seed's outcome sink.
The test compares the two ASTs, exact original segments, child requests/results, sidecars, local/rebased spans,
fresh cache/call counters and no completed outcome on failure. It mutates both returned child data and a raw
sink-exposed source span before rechecking the original oracle on another invocation.

Compiled and SpecFile-JSON reconstructed engines each supply native/generated execution and retain the parent
and child engines. Public v2/fresh emitted pairs rebuild per call. Five in-process pairs agree on complete successful
outcome records. Ten emitted modules pass fatal analysis and execute the same independent corpus/mutants before
returning the required exact completion report. The checker, carrier producer and original JSON utility are copied unchanged into matching relative directories
and analyzed with the already-used test package available offline; no analysis suppression or off-package
standalone analyzer claim is used.

Missing identity/top/steps fail before child invocation; one-call exhaustion stops after one. No seed returns an
inert marker. Child rejection remains typed status1 and staged codes remain exact through execution wrappers.
This does not close diagnostic bytes (`.2.17`), extreme counters (`.2.18`), malformed provenance (`.2.19`) or the
whole-package SDK gate (`.2.25`) under DART-STARTUP-READING. It does not establish recursive resource or format safety.
