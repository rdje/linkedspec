---
id: context-names-dart-carrier-readiness
title: Dart preserves closing-name context through six typed carriers and fresh emitted packages
answers:
  - do Dart generated and reconstructed parsers preserve context-name matching
  - how many Dart retained context-name recovery transitions are verified
  - how is the shared Dart readiness helper analyzed in package context
  - does Dart context-name proof close the whole-package SDK gate
date: 2026-09-27
status: bounded proof verified; cross-runtime milestone recorded separately
tags: [language-readiness, context, dart, generated-source, recovery]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.4 passes62 tests: four readiness and58 existing emitter/document checks. Six routes each execute90 context calls and three mutants, with136 retained recoveries. Both emitted packages pass offline preparation, fatal analysis and actual execution; strict metadata/plan/report checks preserve exact completion. Original nesting defaults and both fixture pairs remain unchanged."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test --reporter expanded test/nested_tree_readiness_test.dart test/source_emitter_test.dart test/sexpr_document_v1_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings test/nested_tree_readiness_test.dart"
---

`docs/language-readiness/context-names.md` owns exact scope. Native and SpecFile-JSON reconstructed engines each
run native and generated-plan parsing, retaining an engine across34 typed rejection/immediate-success pairs.
Public v2 and fresh emitted entries create an engine per call. RuntimeExitNow status must equal the authored
1/2/3; null-like success or another exception cannot count as rejection. Explicit fixture settings select
inventory, recovery control and span mutant; nesting defaults preserve all original checks.

The shared helper lives outside the Dart package. Direct analyzer invocation on that physical path reports an
unresolved package import and consequential missing exception types. Both fresh emitted packages copy the same
helper into lib and pass fatal analysis and actual execution. Main-test analysis runs in its package context.
This is a command-context limitation, not a parser defect or a reason to suppress analysis. Whole-package
SDK deprecations remain [[dart-component-gate-sdk-compatibility]] under DART-STARTUP-READING.2.25.
No runtime, grammar/oracle, lockfile, generated format, dependency or storage policy changes.
Related: [[context-names-rust-carrier-readiness]], [[context-names-public-native-readiness]],
[[nested-tree-dart-carrier-readiness]].

[[context-names-readiness-reconciliation]] records the complete bounded matrix, authoring costs and canonical milestone.
