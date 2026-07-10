---
id: julia-runtime-structured-diagnostics
title: Julia runtime failures carry RuntimeDiagnostic payloads on RuntimeInterpreterException
answers:
  - does Julia runtime expose structured diagnostics
  - what is Julia RuntimeDiagnostic
  - where are Julia runtime diagnostic fields
  - does Julia runtime change successful parse output for diagnostics
  - how does Julia preserve runtime child rule attribution
date: 2026-07-10
status: current
tags: [julia, runtime, diagnostics, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.4.5.1 adds exported RuntimeDiagnostic, RuntimeInterpreterException.diagnostic, optional LinkedSpecRuntimeEngine spec_name/spec_path fields, context top-rule identity, direct rule-lookup diagnostics, and fallback-preserving rule/parse wrapping. Seven focused assertions and the full 588-assertion Julia suite prove neutral JSON fields, successful-output preservation, child-rule attribution, and unchanged textual errors."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'"
---

Julia runtime structured diagnostics live in
`julia/src/runtime/Interpreter.jl`.

`RuntimeInterpreterException` carries an optional exported `RuntimeDiagnostic`
on its `diagnostic` field. The payload uses the backend-neutral fields `type`,
`stage`, `owner_stage`, `summary`, `detail`, `top_rule`, `rule_label`,
`handler_source_label`, plus optional `spec_name` and `spec_path` supplied by
`LinkedSpecRuntimeEngine`.

Successful `RuntimeParseResult` values and JSON are unchanged. Existing textual
exception display still prints only the message. Diagnostics appear on runtime
failures and have deterministic JSON projection through `to_json(...)`.

Missing compiled-rule lookup emits a specific `rule_lookup` payload. Ordinary
rule failures receive `runtime_execution` attribution before the rule context
unwinds, so nested failures retain the child rule and
`julia_runtime:rule:<label>` handler identity. Parent and parse wrappers preserve
an existing richer payload instead of replacing it.

Related facts: [[julia-runtime-diagnostics-trace-split]],
[[julia-runtime-rule-interpreter]], [[dart-runtime-structured-diagnostics]],
[[trace-cross-variant-capability-contract]].
