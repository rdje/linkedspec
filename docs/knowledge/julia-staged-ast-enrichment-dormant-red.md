---
id: julia-staged-ast-enrichment-dormant-red
title: Julia general staged-AST enrichment historical dormant marker/provenance RED
answers:
  - "what is the Julia staged AST enrichment dormant RED"
  - "where is the Julia staged AST enrichment contract test"
  - "how do I run the Julia staged AST enrichment dormant consumer"
  - "does ordinary Julia test discovery run staged AST enrichment"
  - "does canonical CI run the Julia staged AST enrichment consumer"
  - "how did Julia compile parse_job before its dedicated marker"
  - "what happened at the Julia parse_job dormant boundary"
  - "which Julia carriers preserve the staged AST enrichment RED"
  - "does Julia function body staged parsing still work"
  - "why did the staged AST availability sentence still say Dart was dormant"
  - "why did the staged AST Dart runtime command fail from repository root"
  - "what does FUTURE-PARITY-BACKLOG 14.7.6.0 own"
date: 2026-08-27
status: historical .14.7.6.0 baseline; .14.7.6.1-.4 supersede it through private production admission
tags: [julia, staged-parsing, parse-job, red-test, generated-source, governance, drift]
evidence: "FUTURE-PARITY-BACKLOG.14.7.6.0 adds julia/test/staged_ast_enrichment_contract_test.jl at its predeclared final path but omits it from julia/test/runtests.jl and tools/run_ci_local.sh. Its explicit repository-routed run passes 86 assertions over the complete 92-mutation neutral inventory, unchanged function-body-v1 resolve/load/compile/execute/cache/stitch behavior and wrong-top context, generic ActionAssignScalarExpr(ActionCallExpr name=parse_job) structure, narrow expr-v1 registry denial, and native/SpecFile-JSON reconstructed/validated generated-plan/independently included emitted-module unsupported-helper observations. The only failure is the labeled missing STAGED_PARSE_JOB_MARKER/staged_parse_job_v2 assertion. The neutral checker advances only Julia from pending_absent to dormant_red and keeps Julia rollout pending. Git blame and exact Dart command execution also root-cause two inherited Dart-admission governance defects: structured Dart rows were complete while the duplicated availability string remained dormant, and the ordinary Dart command omitted the package working directory required by pubspec discovery. The leaf corrects both, adds an availability regression mutation, and changes no Julia production, generated format, public/outward surface, or backend behavior."
evidence_update_2026_08_27_marker_provenance: "FUTURE-PARITY-BACKLOG.14.7.6.1 supersedes only the missing-marker/provenance behavior: exact scalar assignment now lowers to a dedicated inert node and four logical routes return detached live-proven markers at 131 GREEN/one .2 authority RED. The consumer remains dormant, neutral lifecycle/mutations and Julia rollout remain unchanged, and this card retains the exact historical .0 root cause."
evidence_update_2026_08_27_current_depth_authority: "FUTURE-PARITY-BACKLOG.14.7.6.2 supersedes only the missing current-depth behavior: a separate tuple-frozen caller-prepared registry/cache now performs pure selection, complete-depth target reservation/order/isolation, detachment, and every result/failure policy. The consumer is 309 GREEN/one .3 recursive-authority RED; dormancy, neutral lifecycle/92 mutations, rollout, formats, public/outward truth, and this historical .0 root cause remain unchanged."
evidence_update_2026_08_27_recursive_authority: "FUTURE-PARITY-BACKLOG.14.7.6.3 supersedes only the missing recursive behavior with a separate breadth-first entrypoint, exact lineage/cycle/decrease checks, shared resources, expiring safe points, and direct/ordered-derived source projection. The consumer is 386 GREEN/one .4 fresh-carrier/production/admission/rollout RED; dormancy, neutral lifecycle/92 mutations, formats, public/outward truth, and this historical .0 root cause remain unchanged."
evidence_update_2026_08_27_carrier_admission: "FUTURE-PARITY-BACKLOG.14.7.6.4 supersedes the remaining dormant boundary with a fresh host-only seed across four production routes, 491/491 GREEN assertions, exact ordinary/canonical admission, Julia rollout completion, and 97 mutation guards. This card retains the historical .0 root cause."
reverify:
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "git show 3b3d4eacc7f70f20bf689cdf9ab8f392198e45b3:julia/test/staged_ast_enrichment_contract_test.jl | rg 'missing dedicated marker and typed provenance|unsupported runtime helper'"
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no julia/test/staged_ast_enrichment_contract_test.jl"
  - "(cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/staged_ast_enrichment_contract_test.dart)"
  - "rg -n 'parse_job|STAGED_PARSE_JOB_MARKER|staged_parse_job_v2|staged_ast_enrichment_contract_test' julia/test/staged_ast_enrichment_contract_test.jl capability_conformance/staged_ast_enrichment_contract.json tools/check_staged_ast_enrichment_contract.py"
---

# Julia staged-AST enrichment dormant boundary

At `.14.7.6.0`, Julia parsed the reserved assignment-form `parse_job(...)` expression as an ordinary scalar assignment whose
value is one generic `ActionCallExpr`. The narrow function-body-v1 registry continues to accept only
`actionir-body.spec` / `action_block`; it rejects general `expr-v1` at resolve without gaining discovery, loading,
or compilation authority.

Native and normalized `SpecFile`-JSON reconstructed execution therefore returned the same typed runtime failure:
`unsupported runtime helper 'parse_job' in rule Top`. Validated generated-plan execution preserves that detail
inside `GeneratedExecutionFailedCode`, and an independently included emitted module reaches the same generated
boundary. Neither compiled JSON nor emitted source contains a dedicated marker or typed v2 sidecar.

The exact consumer remains at `julia/test/staged_ast_enrichment_contract_test.jl`. The historical `.0` run was
86 GREEN / one marker RED and deliberately omitted ordinary/canonical discovery.
Leaf `.14.7.6.1` now replaces that generic assignment with one private dedicated marker plus live-proven direct/
ordered-derived provenance. Leaf `.2` adds the separate caller-frozen resolution/cache/current-depth policy engine,
and `.3` adds private breadth-first recurrence, shared resources, safe points, and source projection. Leaf `.4`
adds the fresh production seam and admits the same consumer at 491/491 through ordinary/canonical discovery.

The same audit corrected two inherited executable-governance drifts without changing Dart behavior. The neutral
availability sentence now agrees with its already-complete Dart backend/rollout rows, and the recorded Dart runtime
command now enters the package directory before invoking the repository-local storage wrapper. A dedicated
`authored_availability` mutation prevents the stale prose from silently returning.

Related: [[julia-staged-ast-enrichment-marker-provenance]],
[[julia-staged-ast-enrichment-current-depth-authority]], [[general-staged-ast-enrichment-neutral-contract]], [[julia-staged-function-body-registry]],
[[julia-progressive-span-dispatch-dormant-red]], [[julia-staged-ast-enrichment-carriers-admission]], and
[[dart-staged-ast-enrichment-carriers-admission]].
