---
id: dart-staged-function-descriptor-shape
title: Dart preserves neutral staged function descriptor shape through compile and runtime
answers:
  - "does Dart preserve staged function descriptor shape"
  - "does Dart descriptor include body_payload"
  - "does Dart descriptor include body_parse_job"
  - "does Dart descriptor include stitched body_ast"
  - "does Dart compiled descriptor preserve function_order"
  - "what is DART-BACKEND-PARITY.5.3"
date: 2026-07-09
status: current
tags: [dart, descriptor, staged-parsing, user-functions, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.5.3 establishes staged descriptor preservation. FUTURE-PARITY-BACKLOG.4.3.1 adds the exact fixed-v1/variadic-v2 record union and proves typed signatures through descriptor, normalized emitted state, generated-plan execution, and reconstruction."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/compiled_spec_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings"
---

Dart's staged function descriptor-shape proof lives in
`dart/test/compiled_spec_test.dart`.

The `.5.3` test starts from the same neutral spec-returned
`function_definition` node shape used by the function-shell projection. It then
uses `parseSpecWithStagedUserFunctionDefinitionAsts(...)` so body parse jobs run
through the Dart staged registry before compile state is built.

The proof asserts:

- parsed `SpecFile.functions` preserve source-ordered function names
- compiled `UserFunctionRegistry.bodyParseJobs` preserves normalized job ids
- public descriptor `functions` records contain neutral `body_payload`
- public descriptor `functions` records contain normalized `body_parse_job`
- public descriptor `functions` records contain stitched `body_ast`
- descriptor `meta.function_order` and `meta.function_count` match registry order
- `LinkedSpecRuntimeEngine` can execute the same compiled state and return stable
  user-function output
- fixed v1 records expose `params`/`arity`; variadic v2 records replace them with `signature`

This is a shape-preservation proof, not general public `parse_job(...)` authoring
or full Dart corpus output parity.

Related facts: [[dart-compiled-spec-state]], [[dart-function-registry]],
[[dart-staged-function-body-registry]], [[dart-user-function-runtime-execution]],
[[function-body-staged-prototype-proof]].
