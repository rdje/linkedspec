---
id: julia-staged-ast-enrichment-dormant-red
title: Julia general staged-AST enrichment stops at one exact dormant marker/provenance RED
answers:
  - "what is the Julia staged AST enrichment dormant RED"
  - "where is the Julia staged AST enrichment contract test"
  - "how do I run the Julia staged AST enrichment dormant consumer"
  - "does ordinary Julia test discovery run staged AST enrichment"
  - "does canonical CI run the Julia staged AST enrichment consumer"
  - "how does Julia currently compile parse_job"
  - "what happens when Julia executes parse_job today"
  - "which Julia carriers preserve the staged AST enrichment RED"
  - "does Julia function body staged parsing still work"
  - "why did the staged AST availability sentence still say Dart was dormant"
  - "why did the staged AST Dart runtime command fail from repository root"
  - "what does FUTURE-PARITY-BACKLOG 14.7.6.0 own"
date: 2026-08-27
status: current dormant RED; production and ordinary/canonical admission remain unchanged
tags: [julia, staged-parsing, parse-job, red-test, generated-source, governance, drift]
evidence: "FUTURE-PARITY-BACKLOG.14.7.6.0 adds julia/test/staged_ast_enrichment_contract_test.jl at its predeclared final path but omits it from julia/test/runtests.jl and tools/run_ci_local.sh. Its explicit repository-routed run passes 86 assertions over the complete 92-mutation neutral inventory, unchanged function-body-v1 resolve/load/compile/execute/cache/stitch behavior and wrong-top context, generic ActionAssignScalarExpr(ActionCallExpr name=parse_job) structure, narrow expr-v1 registry denial, and native/SpecFile-JSON reconstructed/validated generated-plan/independently included emitted-module unsupported-helper observations. The only failure is the labeled missing STAGED_PARSE_JOB_MARKER/staged_parse_job_v2 assertion. The neutral checker advances only Julia from pending_absent to dormant_red and keeps Julia rollout pending. Git blame and exact Dart command execution also root-cause two inherited Dart-admission governance defects: structured Dart rows were complete while the duplicated availability string remained dormant, and the ordinary Dart command omitted the package working directory required by pubspec discovery. The leaf corrects both, adds an availability regression mutation, and changes no Julia production, generated format, public/outward surface, or backend behavior."
reverify:
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no julia/test/staged_ast_enrichment_contract_test.jl 2>&1 | rg '86 passed, 1 failed|LINKEDSPEC_STAGED_AST_ENRICHMENT_JULIA_RED'"
  - "(cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/staged_ast_enrichment_contract_test.dart)"
  - "rg -n 'parse_job|STAGED_PARSE_JOB_MARKER|staged_parse_job_v2|staged_ast_enrichment_contract_test' julia/test/staged_ast_enrichment_contract_test.jl capability_conformance/staged_ast_enrichment_contract.json tools/check_staged_ast_enrichment_contract.py"
---

# Julia staged-AST enrichment dormant boundary

Julia still parses the reserved assignment-form `parse_job(...)` expression as an ordinary scalar assignment whose
value is one generic `ActionCallExpr`. The narrow function-body-v1 registry continues to accept only
`actionir-body.spec` / `action_block`; it rejects general `expr-v1` at resolve without gaining discovery, loading,
or compilation authority.

Native and normalized `SpecFile`-JSON reconstructed execution therefore return the same typed runtime failure:
`unsupported runtime helper 'parse_job' in rule Top`. Validated generated-plan execution preserves that detail
inside `GeneratedExecutionFailedCode`, and an independently included emitted module reaches the same generated
boundary. Neither compiled JSON nor emitted source contains a dedicated marker or typed v2 sidecar.

The exact consumer is deliberately dormant at
`julia/test/staged_ast_enrichment_contract_test.jl`: the path exists, but `julia/test/runtests.jl` does not include
it and canonical CI does not require, log, or invoke it. Its explicit run is 86 GREEN / one intentional RED. Leaf
`.14.7.6.1` exclusively owns replacing that generic assignment with one private dedicated marker plus live-proven
direct/ordered-derived provenance; later `.2-.4` retain authority, recursion, carriers, and admission.

The same audit corrected two inherited executable-governance drifts without changing Dart behavior. The neutral
availability sentence now agrees with its already-complete Dart backend/rollout rows, and the recorded Dart runtime
command now enters the package directory before invoking the repository-local storage wrapper. A dedicated
`authored_availability` mutation prevents the stale prose from silently returning.

Related: [[general-staged-ast-enrichment-neutral-contract]], [[julia-staged-function-body-registry]],
[[julia-progressive-span-dispatch-dormant-red]], and [[dart-staged-ast-enrichment-carriers-admission]].
