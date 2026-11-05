---
id: dart-count-result-source-guards
title: Dart Count continuations guard numeric results and preserve initial source policy
answers:
  - "how does Dart guard Count consumers before operands and with bodies"
  - "why does Dart Count preserveInitialCountSource skip only the common guard"
  - "does Dart Count guarding change scalarResult or copied-null index"
  - "where are Dart Count generated host modules and resolution inputs retained"
  - "why do initial Boolean Count sources return zero while copied Booleans reject"
  - "why is Dart Count formatting scoped to the fluent loop"
date: 2026-11-05
status: primary guards and initial Boolean source73.6.3 focused-checked; full admission remains open
tags: [dart, count, guards, source, copy, null, composition]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.73.3 retains original proof in count-guard-dart-2026-11-05/. Current73.6.3 retains25-case source/copy/Boolean RED/GREEN, fatal root/fresh analysis and actual direct first-execution input archives in docs/checkpoints/count-source-dart-2026-11-05/. Full closure stays23.4.2-owned."
reverify:
  - "From dart/: bash ../tools/run_dart_project_data.sh test --reporter expanded --concurrency=1 test/count_source_fallback_test.dart"
  - "From dart/: bash ../tools/run_dart_project_data.sh test --reporter expanded test/count_result_guard_composition_test.dart"
  - "From dart/: bash ../tools/run_dart_project_data.sh test --reporter expanded test/source_emitter_test.dart --name '^Count source guards in compiled emission$'"
  - "From dart/: bash ../tools/run_dart_project_data.sh test test/count_length_receivers_test.dart test/copied_null_index_composition_test.dart"
---

`_isOrdinaryCountResultChain` admits canonical positional free-one Count sources
and zero-extra receiver prefixes, excluding traversal and non-with trailing
blocks. Fluent dispatch joins the existing `kindGuardedResult` path. Container
rejection occurs before operands and later `with` bodies, while legitimate null
continues into `with` and numeric zero remains valid data.

At primary73.3, only an initial receiver Count without a prior result owner sets
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

Current73.6.3 also applies the existing first-source permission at the scalar
guard. Initial Boolean block sources can now reach Count's Number0 fallback;
the one-step flag is consumed before that call and does not grant later rights.
ScalarResult initialization/assignments and common guards are unchanged. Copied
or produced Booleans still reject Count, and unowned Booleans still reject Array
consumers before operands. Numeric zero continues through copy/default/add/with,
and function Boolean parameters were already healthy and remain unchanged.

Twenty-five native/restored/plan and compiled-emitted controls move22PASS3RED to
25PASS. Fatal targeted root/fresh analysis, Count/length2 and index-copy1 pass;
observed needed-error message/class stays exact. Direct declared pub/source/lock/
module/config inputs precede executions, without complete package/native closure
or general isolation. Evidence: docs/checkpoints/count-source-dart-2026-11-05/.

Owned loop formatting uses the established class-wrapper probe. Whole-owner
formatting still finds pre-existing _isFreeDefaultResultSource and
_isCanonicalSetResultSource layout drift, scheduled under P3 owner73.8 after
the P1s/P2 and before full23.4. Unrelated probe changes were restored from the
exact tested runtime archive; scoped proof confirms the owner stays byte-identical.
Rebuild Dart runtime/apps. Julia4/Lua5 and full admission remain separate.
