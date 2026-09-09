---
id: dart-staged-function-body-registry
title: Dart staged registry dispatches function-body parse jobs and stitches body_ast
answers:
  - "where is the Dart staged parser registry"
  - "does Dart dispatch function body parse jobs"
  - "how does Dart resolve actionir-body.spec"
  - "does Dart stitch body_ast"
  - "what Dart API parses specs with staged function bodies"
  - "what is DART-BACKEND-PARITY.5.1"
date: 2026-07-09
status: current
tags: [dart, staged-parsing, parser-registry, parse-jobs, user-functions, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.5.1 adds dart/lib/src/parser/staged_parser_registry.dart, exports the staged registry APIs from dart/lib/linkedspec_dart.dart, and adds test/staged_parser_registry_test.dart. Focused tests cover stable queue order, deterministic actionir-body.spec resolution, cache-key/compiled-parser record shape, body_ast stitching, wrapper parsing with staged function bodies, unsupported parser diagnostics, and stitching contract drift."
evidence_update_2026_08_26_general_dormant_red: "FUTURE-PARITY-BACKLOG.14.7.5.0 re-proves this v1 adapter unchanged inside the separate dormant general-v2 consumer. V1 still executes resolve/load/compile/execute, preserves cache/stitch policy and complete wrong-top context, and denies expr-v1 at resolve. The future authored parse_job form remains a generic runtime unknown-helper rejection; .14.7.5.1 owns its dedicated marker and typed provenance."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/staged_parser_registry_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings"
---

Dart's minimal staged parser registry lives in
`dart/lib/src/parser/staged_parser_registry.dart`.

The supported provider is intentionally narrow. `executeStagedParseJobs(...)`
validates and stable-sorts `StagedParseJob` values by `parent_ast_path`,
`source_span`, then `job_id`; resolves `parser_spec_id = actionir-body.spec` to
`builtin:actionir-body.spec`; records the fixed adapter digest
`sha256:87ca81d966bb41f7025d31e4bae426af101e2ec75ff2ac14e96517d97fbbf55c`;
compiles top rule `action_block` with the staged cache-key fields; and executes
the body text through Dart's `parseActionBlock(...)` adapter.

`dispatchFunctionBodyParseJobs(...)` stitches each staged result's
`action_block` JSON into the matching `FunctionDefinition.bodyAst` when the job
policy is `replace_field` / `body_ast`. `stitchFunctionBodyParseJobs(...)` is
the convenience form that returns only the stitched `SpecFile`.
`parseSpecWithStagedUserFunctionDefinitionAsts(...)` composes the existing
spec-returned function-definition projection with this body dispatch.

This does not implement public `parse_job(...)` authoring, filesystem/provider
search roots, multiple parser families, or recursive staged queues. Dart
user-function runtime execution is tracked separately in
[[dart-user-function-runtime-execution]].

Related facts: [[function-body-staged-registry-dispatch]],
[[dart-function-definition-shell-projection]], [[dart-function-registry]],
[[dart-actionir-ast-parser]], [[dart-staged-ast-enrichment-dormant-red]].

## 2026-09-09 — v1 registry reading and general-v2 distinction

`DART-STARTUP-READING.1.12` reads lines 1-677. This prefix normalizes and sorts jobs,
balances queue/per-job trace scopes, resolves the one builtin logical identity, constructs
load/compiled/cache-key records, invokes parseActionBlock and stitches validated function
jobs into bodyAst. Function checks distinguish fixed, variadic and final-codeblock metadata,
then verify body text and parser/top/result/failure policies. Remaining index/copy/equality
helpers begin at line 678 and belong to .1.13.

The v1 cache key here is a descriptor; this prefix builds metadata for each job and does
not perform a parser-plan cache lookup. Seventeen existing spec-parser/staged-registry
tests pass. The narrow v1 non-goals above must not be read as current whole-Dart limitations:
general v2 has a separate frozen registry, invocation-local plan cache and recursive
authority, with later exact assignment-form parse_job admission documented in
[[dart-staged-ast-enrichment-carriers-admission]] and
[[dart-staged-ast-enrichment-current-depth-authority]]. That general runtime is not newly
read or reverified by this v1 source/test selection; parked builder ideas stay parked.
