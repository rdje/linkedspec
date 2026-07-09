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
status: current
tags: [dart, compiler, compiled-state, descriptor, dependency-regex, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.3.4 adds dart/lib/src/compiler/compiled_spec.dart and exports compileSpec plus CompiledSpec, CompiledRule, CompiledDependencyRegexState, and CompiledDescriptorState. DART-BACKEND-PARITY.5.3 expands test/compiled_spec_test.dart to prove staged function descriptor shape through parsed SpecFile.functions, compiled UserFunctionRegistry bodyParseJobs, descriptor functions records, stitched body_ast, function_order metadata, and runtime output. Existing tests also verify ordered rule state, redefinition metadata when validation is deliberately skipped, dependency-regex derivation, lifecycle/action ActionBlock payloads, registry-aware user-call contracts, source validation reuse, and descriptor-shaped JSON projection."
reverify: "cd dart && dart test test/compiled_spec_test.dart && dart analyze --fatal-infos --fatal-warnings"
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

The `.5.3` proof asserts that Dart preserves neutral user-function staged fields
through this projection: `body_payload`, normalized `body_parse_job`, stitched
`body_ast`, `function_order`, and executable runtime output from the same
compiled state.

Related facts: [[dart-function-registry]], [[dart-actionir-contract-resolver]],
[[dart-staged-function-descriptor-shape]], [[dart-backend-interpreter-first-plan]],
[[compilerstate-internal-model]].
