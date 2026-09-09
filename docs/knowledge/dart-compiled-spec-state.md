---
id: dart-compiled-spec-state
title: Dart compileSpec builds compiled rule, dependency-regex, and descriptor state
answers:
  - where is the Dart compiled spec state
  - does Dart have compileSpec
  - how does Dart project descriptor JSON
  - where does Dart build dependency regex data
  - does Dart compiled state carry action payload ASTs
date: 2026-07-09
status: current through rule-local cursor descriptor v1
tags: [dart, compiler, compiled-state, descriptor, dependency-regex, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.3.4 adds dart/lib/src/compiler/compiled_spec.dart and exports compileSpec plus CompiledSpec, CompiledRule, CompiledDependencyRegexState, and CompiledDescriptorState. DART-BACKEND-PARITY.5.3 expands test/compiled_spec_test.dart to prove staged function descriptor shape through parsed SpecFile.functions, compiled UserFunctionRegistry bodyParseJobs, descriptor functions records, stitched body_ast, function_order metadata, and runtime output. Existing tests also verify ordered rule state, redefinition metadata when validation is deliberately skipped, dependency-regex derivation, lifecycle/action ActionBlock payloads, registry-aware user-call contracts, source validation reuse, and descriptor-shaped JSON projection."
evidence_update_2026_07_18: "FUTURE-PARITY-BACKLOG.9.1.5.3 migrates CompiledDescriptorState to the rule_local_cursor_v1 outward variant. Root metadata identifies the cursor contract and every rule derives family, cursor policy, aggregate ownership, and exact ordered semantic edge rows from normalized CompiledRule state; direct, normalized SpecFile-JSON, and loaded projections agree."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/compiled_spec_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings"
---

Dart compiled-state construction lives in
`dart/lib/src/compiler/compiled_spec.dart`.

`compileSpec(...)` validates a parsed `SpecFile` by default, then builds
`CompiledSpec` with deterministic `definitionOrder`, `compiledRuleOrder`,
`rulesByLabel`, `redefinedRuleLabels`, and the carried `UserFunctionRegistry`.
Each `CompiledRule` records regex patterns, `dependency_refs`, rule mode
metadata, action/blind edges, lifecycle/plain/edge `ActionBlock` payloads, and
registry-aware ActionIR contract results.

`CompiledDependencyRegexState` derives structured dependency-regex data from
child rule regex slots. Dart stores that as dependency refs plus pattern strings
until the runtime interpreter owns executable match dispatch.

`CompiledDescriptorState` projects the public mdBook descriptor shape:
`spec`, `functions`, `dependency_regex_map`, and `meta`.

Its cursor metadata is now a pure rule-local projection. Root metadata identifies
`linkedspec-rule-local-cursor-v1`; per-rule metadata derives family, cursor
policy, ownership, and resolved semantic edges from the same normalized
compiled state used by normal execution. Dart has no descriptor-input decoder;
normalized `SpecFile` JSON reconstruction recompiles before projection.

The `.5.3` proof asserts that Dart preserves neutral user-function staged fields
through this projection: `body_payload`, normalized `body_parse_job`, stitched
`body_ast`, `function_order`, and executable runtime output from the same
compiled state.

## Compiler prefix reading — 2026-09-09

DART-STARTUP-READING.1.6 reads compiled_spec.dart through line 457. Construction
validates source by default, normalizes callable function bodies against declared
metadata, builds ordered rule state, resolves dependency regexes, then invokes
compiled-state validators before returning. Reading those validators' remaining
bodies belongs to .1.7. Entry selection remains explicit selector, first marker,
then first compiled authored rule; zero and unknown selection keep distinct
portable diagnostics. Duplicate-slot validation checks typed child and parent
indices rather than deduplicating regex pattern text. Existing canonical root
and regex-slot facts remain authoritative; this leaf's 27 selected tests are
bounded proof, not a fresh complete generated/emitted or shared-matrix admission.

Related facts: [[dart-function-registry]], [[dart-actionir-contract-resolver]],
[[dart-staged-function-descriptor-shape]], [[dart-backend-interpreter-first-plan]],
[[compilerstate-internal-model]].

## Compiler completion reading — 2026-09-09

DART-STARTUP-READING.1.7 completes compiled_spec.dart through EOF. The remaining validators walk serialized payloads and specific function bodies; compilation normalizes bare edges by family, preserves named/indexed slot provenance, expands dependency patterns and projects descriptors from compiled state. Optional edge payload code selects an explicit block when present, otherwise joins its fluent calls; the separate fluent chain remains carried. The special observation closure follows explicit calls/functions but omits structural edges. [[dart-recognition-effect-integration-gap]] owns the confirmed bypass and disconnected generic classifier; 74 selected tests do not close those defects.
