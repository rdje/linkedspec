---
id: nested-tree-dart-carrier-readiness
title: Dart nesting proof preserves JSON kinds and typed rejection across six routes
answers:
  - which Dart nesting carriers preserve values and Unicode spans
  - does Dart nesting recovery retain the same engine
  - how is the Dart nesting emitted package verified
  - does Dart nesting proof mean the complete component gate passes
date: 2026-09-27
status: bounded carrier proof verified; existing SDK deprecations remain separately owned
tags: [language-readiness, dart, generated-source, recovery, spans]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.3 passes two new tests and58 emitter/document tests. Six routes each execute40 original calls and three mutations; four retained-engine routes prove56 recoveries. Fresh child offline preparation, fatal analysis and execution exit0; new-file analysis and format pass. Whole-package analysis retains two known .2.25 deprecations."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/nested_tree_readiness_test.dart test/source_emitter_test.dart test/sexpr_document_v1_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings test/nested_tree_readiness_test.dart"
---

Native and SpecFile-JSON reconstructed engines each run native and generated-plan parsing on one retained engine.
Public executeGeneratedParserV2 and emitted execute create an engine per call. Only the first four routes establish
same-engine rejection recovery. The shared checker requires RuntimeExitNow status1; even a returned null cannot
masquerade as rejection. It compares JSON kinds, values and Unicode scalar spans against unchanged fixture data.

Three controlled grammar mutations remove prefix rejection, remove gap rejection or corrupt the list start span.
The independent emitted package copies data as files, uses a relative dependency, and checks actual process success
for offline resolution, fatal analysis and execution. Its four-module completion report is verified exactly.
Owned scratch is removed afterward; all data remains repository-local. Plans and v2 metadata/source identities
are checked. Runtime code, dependency lockfiles and fixture bytes are unchanged.

Whole-package analysis still exits2 at matching.dart:732/1203 with deprecated_implement; this matches the existing
[[dart-component-gate-sdk-compatibility]] owner DART-STARTUP-READING.2.25. Changed-file and emitted analysis pass.
No complete component-gate or standard-format admission is claimed. [[nested-tree-readiness-reconciliation]] records the completed cross-runtime evidence and bounded milestone.
Related: [[nested-tree-public-native-readiness]], [[nested-tree-rust-carrier-readiness]].
