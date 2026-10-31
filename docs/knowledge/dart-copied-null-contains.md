---
id: dart-copied-null-contains
title: Dart nullable membership crosses both guards while rejection exits early
answers:
  - "does Dart copied null contains evaluate its needle and propagate errors"
  - "which Dart guards need the nullable membership exception"
  - "why was firstCall removed from Dart membership guards"
date: 2026-10-31
status: bounded71.6.3 targeted-checked; independent Julia-Lua/full admission separate
tags: [dart, contains, copy, null, rejection, runtime]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.71.6.3; copied-null-contains-dart-intake.json.gz retains actual unchanged11 before/after, eight runtime fixtures/four consumers/package config, sources/instruments/JSON phases and verbatim formatting source."
reverify: "From dart/: bash ../tools/run_dart_project_data.sh test test/copied_null_contains_composition_test.dart test/contains_result_guard_composition_test.dart test/copied_null_presence_composition_test.dart test/value_copy_test.dart"
---

Dart71.6.3 restores canonical copied-null membership: independent unchanged11 tests5PASS6RED become11PASS native/restoredSpec/in-process plan. All ten values/one needed needle error satisfy frozen shared11; five healthy wrong-kind/Array snapshot/flag/rejected-with/rejected-without observations remain exact. Copied-null/free-copy/free contains agree at numeric0/ABC; null source-needle snapshot0!/SNC/calls1/working Array, repeated copy, valid null with/numeric copy and binding_kind_mismatch needle error are restored. Reuse the existing pure canonical one-needle contains role for nullable consumption through both common-container and scalar-result guards. Remove obsolete firstCall state; scalarResult assignment/producer/with/preflight stay. Earlier incompatible consumers still return before later copy/needle/body effects. Equality/numeric flags/null-empty/copy depth/source snapshots/unknown/traversal/deferred/function/parser/schema remain. Nearest contains29/presence-copy11/value-copy4=44, fatal owner/new-normal analysis, new-normal format and verbatim changed-member format pass; runtime/analysis/format stderr empty, no whole-SDK format. Eight actual runtime fixtures derive from four URI consumers; package config/inline programs/per-phase identities and225 other activation inputs stay exact, not complete transitive generation closure. Actual sources/instruments/templates/inputs/raw JSON epochs retained in copied-null-contains-dart-intake.json.gz. Book/card/map/target/task/roadmap/live/resume/history align; rebuild Dart apps/runtime. Current checklist manually reviewed under23.4.3 path limit. Independent Julia71.6.4 then safe Lua71.6.5 next. No isolated emitted/peer fix/general nullable-Array policy/general rejection-isolation/exhaustive excluded-runtime/full23.4 admission; no full suite or push.

_evaluateFluentCallsWithValue uses the same canonical nullableMembership at common and scalar guards. The old firstCall gate skipped copied null; the scalar guard separately skipped legitimate null produced earlier in the chain. Both boundaries now recognize the existing one-needle role. Earlier rejection returns from the loop, so null itself never represents a poisoned value. No other Array consumer gains nullable input.
