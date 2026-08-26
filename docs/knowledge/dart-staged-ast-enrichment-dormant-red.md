---
id: dart-staged-ast-enrichment-dormant-red
title: Dart general staged-AST enrichment began at one dormant dedicated-marker RED
answers:
  - "what is the Dart staged AST enrichment dormant RED"
  - "is general parse_job implemented in Dart"
  - "how do I run the Dart staged AST enrichment contract"
  - "why does Dart reject parse_job as an unknown helper"
  - "does Dart have STAGED_PARSE_JOB_MARKER"
  - "does Dart have staged_parse_job_v2 typed provenance"
  - "is the Dart staged AST consumer in ordinary tests or canonical CI"
  - "does function body staged parsing still work in Dart"
  - "what does FUTURE-PARITY-BACKLOG 14.7.5.0 establish"
date: 2026-08-26
status: historical boundary superseded by current private marker/provenance/recursive authority; consumer remains dormant
tags: [dart, staged-parsing, parse-job, dormant-red, source-location, generated-source, backend-parity]
evidence: "FUTURE-PARITY-BACKLOG.14.7.5.0 adds dart/test_dormant/staged_ast_enrichment_contract_test.dart and no production source. Fatal analysis passes. The exact opt-in run completes four tests covering the 85-mutation neutral inventory, unchanged function-body-v1 registry and wrong-top context, generic ActionCallExpr structure, native and SpecFile-JSON-reconstructed unknown-helper rejection, validated generated-plan rejection, and independently analyzed/executed emitted-source rejection. Its fifth and only failing test names the missing STAGED_PARSE_JOB_MARKER and staged_parse_job_v2 sidecar. The neutral checker requires the dormant path, proves the eventual final path and both canonical references absent, promotes no Dart rollout row, and keeps Julia/Lua absent. Ordinary dart test discovery omits test_dormant."
root_cause: "dart/lib/src/action/action_parser.dart lowers assignment-form parse_job(...) through the generic call parser into ActionAssignScalarExpr containing ActionCallExpr. No dedicated staged declaration node claims that syntax. dart/lib/src/runtime/interpreter.dart reaches _evaluateCall and emits the structured unknown_helper diagnostic because parse_job is neither a user function nor a known runtime helper. SpecFile JSON reconstruction and emitted-source v2 both recompile the same generic logical call, while executeGeneratedParserV2 wraps the same rejection as generated_execution_failed. The separate dart/lib/src/parser/staged_parser_registry.dart remains the narrow function-body-v1 adapter and independently rejects expr-v1 during resolve."
evidence_update_2026_08_26_marker_provenance: "FUTURE-PARITY-BACKLOG.14.7.5.1 supersedes only the missing-marker boundary: exact assignment lowers to ActionStagedParseJobExpr, strict literal/static and recognition-effect closure reject malformed/residual forms, and staged_parse_job.dart constructs one detached marker from typed direct/ordered-derived provenance. The same dormant consumer is seven GREEN groups and one .14.7.5.2 authority RED; ordinary/canonical references and Dart rollout remain zero/pending."
evidence_update_2026_08_26_current_depth_authority: "FUTURE-PARITY-BACKLOG.14.7.5.2 supersedes the caller-frozen-authority RED with a private one-depth resolver/cache/policy engine. The same excluded consumer is now +12/-1 and only .3 recurrence/bounds/rebasing remains RED; ordinary/canonical references, rollout, formats, v1, and outward truth remain unchanged."
evidence_update_2026_08_27_recursive_authority: "FUTURE-PARITY-BACKLOG.14.7.5.3 supersedes the recurrence RED with private breadth-first queues, lineage/resource bounds, expiring safe points, source rebasing, and complete-depth target reservation. The same excluded consumer is +18/-1 and only .4 fresh carriers/production/admission/rollout remain RED; ordinary/canonical references and public/outward truth remain unchanged."
last_verified: 2026-08-27
reverify:
  - "cd dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings test_dormant/staged_ast_enrichment_contract_test.dart"
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter expanded test_dormant/staged_ast_enrichment_contract_test.dart"
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "rg -n 'ActionStagedParseJobExpr|constructStagedParseJobMarker|stagedCaptureCodeUnitSpan|STAGED_PARSE_JOB_MARKER|staged_parse_job_v2' dart/lib/src dart/test_dormant/staged_ast_enrichment_contract_test.dart"
---

# Dart staged-AST enrichment dormant RED

Dart still ships the explicit function-body-v1 staged adapter unchanged. It accepts
`actionir-body.spec` / `action_block`, keeps stable queue and cache identity,
parses the body through `parseActionBlock(...)`, and stitches only
`replace_field` / `body_ast` / `fail`. A general `expr-v1` job remains a
resolve-time denial, so the dormant consumer grants no accidental parser
authority.

This card records the `.14.7.5.0` historical root cause. `.14.7.5.1` now claims
the exact assignment with a private dedicated node and detached typed
provenance; see [[dart-staged-ast-enrichment-marker-provenance]]. Generic and
non-assignment `parse_job` forms remain fail-closed rather than becoming an
ordinary callable helper.

The consumer lives under `dart/test_dormant/`, so ordinary package discovery
and canonical CI do not execute it. Its current first eighteen groups are
GREEN; the nineteenth and sole deliberate RED names `.14.7.5.4` fresh
carriers, production integration, admission, and Dart rollout.

Related: [[dart-staged-function-body-registry]],
[[general-staged-ast-enrichment-neutral-contract]],
[[general-staged-ast-current-boundary]],
[[dart-staged-ast-enrichment-current-depth-authority]],
[[dart-staged-ast-enrichment-recursive-authority]],
[[rust-staged-ast-enrichment-dormant-red]], and ADR `0088`.
