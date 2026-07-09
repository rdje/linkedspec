---
id: dart-runtime-structured-diagnostics
title: Dart runtime failures carry RuntimeDiagnostic payloads on RuntimeInterpreterException
answers:
  - does Dart runtime expose structured diagnostics
  - what is RuntimeDiagnostic
  - where are Dart runtime diagnostic fields
  - does Dart runtime change successful parse output for diagnostics
  - how does Dart preserve runtime rule attribution
date: 2026-07-09
status: current
tags: [dart, runtime, diagnostics, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.4.5.1 added RuntimeDiagnostic, RuntimeInterpreterException.diagnostic, optional LinkedSpecRuntimeEngine specName/specPath fields, runtime context rule-stack attribution, and focused runtime diagnostics tests."
reverify: "cd dart && dart test test/runtime_interpreter_test.dart && dart analyze --fatal-infos --fatal-warnings && rg -n 'RuntimeDiagnostic|RuntimeInterpreterException\\.diagnostic|DART-BACKEND-PARITY\\.4\\.5\\.1' dart/lib dart/test docs/tasks/DART-BACKEND-PARITY.md docs/linkedspec-book/src"
---

Dart runtime structured diagnostics live in `dart/lib/src/runtime/interpreter.dart`.

`RuntimeInterpreterException` now carries an optional `RuntimeDiagnostic` on its
`diagnostic` field. The diagnostic uses the backend-neutral mdBook fields:
`type`, `stage`, `owner_stage`, `summary`, `detail`, `top_rule`, `rule_label`,
`handler_source_label`, plus optional `spec_name` and `spec_path` when callers
provide source identity through `LinkedSpecRuntimeEngine(specName: ..., specPath:
...)`.

`LinkedSpecRuntimeEngine.parse(...)` preserves successful `RuntimeParseResult`
output. Diagnostics are attached only to runtime failures. Missing compiled-rule
lookup emits a specific `rule_lookup` diagnostic; ordinary rule execution wraps
plain runtime exceptions before the rule stack unwinds, so child-rule failures
keep child-rule attribution. The parse boundary remains a fallback wrapper and
preserves richer lower-level diagnostics when they already exist.

Related facts: [[dart-runtime-diagnostics-trace-split]],
[[runtimecontext-boundary]], [[trace-cross-variant-capability-contract]].
