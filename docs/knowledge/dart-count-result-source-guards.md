---
id: dart-count-result-source-guards
title: Dart Count continuations guard numeric results and preserve initial source policy
answers:
  - "how does Dart guard Count consumers before operands and with bodies"
  - "why does Dart Count preserveInitialCountSource skip only the common guard"
  - "does Dart Count guarding change scalarResult or copied-null index"
  - "where are Dart Count generated host modules and resolution inputs retained"
date: 2026-11-05
status: bounded Dart73.3 focused-checked; full admission and Count/copy assessment remain open
tags: [dart, count, guards, source, copy, null, composition]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.73.3; docs/checkpoints/count-guard-dart-2026-11-05/ retains unchanged baseline, frozen diagnostic/AST, actual direct and generated host inputs and candidate/final results."
reverify:
  - "From dart/: bash ../tools/run_dart_project_data.sh test --reporter expanded test/count_result_guard_composition_test.dart"
  - "From dart/: bash ../tools/run_dart_project_data.sh test --reporter expanded test/source_emitter_test.dart --name '^Count source guards in compiled emission$'"
  - "From dart/: bash ../tools/run_dart_project_data.sh test test/count_length_receivers_test.dart test/copied_null_index_composition_test.dart"
---

`_isOrdinaryCountResultChain` admits canonical positional free-one Count sources
and zero-extra receiver prefixes, excluding traversal and non-with trailing
blocks. Fluent dispatch joins the existing `kindGuardedResult` path. Container
rejection occurs before operands and later `with` bodies, while legitimate null
continues into `with` and numeric zero remains valid data.

Only an initial receiver Count without a prior result owner sets
`preserveInitialCountSource`. The common loop consumes that flag once and skips
only its common container guard for that first call. The scalar-result guard,
initialization and assignments remain unchanged. A Count result consumed by
another Count already has Number kind and rejects the Array-only consumer.
Copied-null Count and copied-null index retain their existing policies.

The pre-edit source-domain diagnostic is `[0,0,0,0,0,0,null]`; eighteen excluded
public source shapes are frozen before production. Native/restored/generated-plan,
independently compiled emitted modules and selected Count/length/copied-null
index controls pass. Needed source errors, source-once snapshots, default and
Array bridges remain covered. Fatal targeted analysis and scoped formatting pass.

The source-emitter test reuses its existing temporary owner and retains emitted
modules, manifest, runner, resolved lock and package-config bodies before host
execution. These direct inputs do not establish complete transitive generation
closure. Full23.4, registration, input custody and general isolation remain open.
The initial AST bootstrap failure is qualified separately from product REDs.
Rebuild Dart applications/runtime for the repair; independent Julia73.4 follows.
