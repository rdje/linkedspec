---
id: dart-staged-ast-enrichment-dormant-red
title: Dart general staged-AST enrichment is frozen at one dormant dedicated-marker RED
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
status: current dormant RED; FUTURE-PARITY-BACKLOG.14.7.5.1 owns the missing private marker and provenance
tags: [dart, staged-parsing, parse-job, dormant-red, source-location, generated-source, backend-parity]
evidence: "FUTURE-PARITY-BACKLOG.14.7.5.0 adds dart/test_dormant/staged_ast_enrichment_contract_test.dart and no production source. Fatal analysis passes. The exact opt-in run completes four tests covering the 85-mutation neutral inventory, unchanged function-body-v1 registry and wrong-top context, generic ActionCallExpr structure, native and SpecFile-JSON-reconstructed unknown-helper rejection, validated generated-plan rejection, and independently analyzed/executed emitted-source rejection. Its fifth and only failing test names the missing STAGED_PARSE_JOB_MARKER and staged_parse_job_v2 sidecar. The neutral checker requires the dormant path, proves the eventual final path and both canonical references absent, promotes no Dart rollout row, and keeps Julia/Lua absent. Ordinary dart test discovery omits test_dormant."
root_cause: "dart/lib/src/action/action_parser.dart lowers assignment-form parse_job(...) through the generic call parser into ActionAssignScalarExpr containing ActionCallExpr. No dedicated staged declaration node claims that syntax. dart/lib/src/runtime/interpreter.dart reaches _evaluateCall and emits the structured unknown_helper diagnostic because parse_job is neither a user function nor a known runtime helper. SpecFile JSON reconstruction and emitted-source v2 both recompile the same generic logical call, while executeGeneratedParserV2 wraps the same rejection as generated_execution_failed. The separate dart/lib/src/parser/staged_parser_registry.dart remains the narrow function-body-v1 adapter and independently rejects expr-v1 during resolve."
last_verified: 2026-08-26
reverify:
  - "cd dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings test_dormant/staged_ast_enrichment_contract_test.dart"
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter expanded test_dormant/staged_ast_enrichment_contract_test.dart"
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "rg -n 'parse_job|unknown_helper|ActionCallExpr|STAGED_PARSE_JOB_MARKER|staged_parse_job_v2' dart/lib/src/action dart/lib/src/runtime/interpreter.dart dart/test_dormant/staged_ast_enrichment_contract_test.dart"
---

# Dart staged-AST enrichment dormant RED

Dart still ships only the explicit function-body-v1 staged adapter. It accepts
`actionir-body.spec` / `action_block`, keeps stable queue and cache identity,
parses the body through `parseActionBlock(...)`, and stitches only
`replace_field` / `body_ast` / `fail`. A general `expr-v1` job remains a
resolve-time denial, so the dormant consumer grants no accidental parser
authority.

The future exact assignment form currently compiles as one ordinary
`assign_scalar` whose value is a generic `call` named `parse_job`. Native and
normalized-reconstructed execution reject that call with
`unknown_helper name="parse_job" rule_label="Top"`. Generated-plan and emitted
execution preserve the same rejection under their existing generated-source
error boundary. None produces an inert marker or typed provenance sidecar.

The consumer lives under `dart/test_dormant/`, so ordinary package discovery
and canonical CI do not execute it. Its first four tests are GREEN; the fifth
is the sole deliberate RED. `.14.7.5.1` must replace the generic call with one
private dedicated declaration node and detached direct/ordered-derived
provenance while retaining the same consumer and dormant topology. `.2-.4`
retain resolution/policies, recursive authority, and fresh carriers/admission
respectively.

Related: [[dart-staged-function-body-registry]],
[[general-staged-ast-enrichment-neutral-contract]],
[[general-staged-ast-current-boundary]],
[[rust-staged-ast-enrichment-dormant-red]], and ADR `0088`.
