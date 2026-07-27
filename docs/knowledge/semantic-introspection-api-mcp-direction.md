---
id: semantic-introspection-api-mcp-direction
title: Deep semantic introspection belongs to one backend-neutral native API with MCP as thin transport
answers:
  - does deep semantic introspection make sense for LinkedSpec
  - should LinkedSpec expose semantic introspection through MCP
  - where should LinkedSpec semantic introspection semantics live
  - should MCP own LinkedSpec semantic behavior
  - what should a LinkedSpec semantic introspection API expose
  - how should semantic introspection stay identical across backends
  - what task owns semantic introspection and MCP design
  - what did FUTURE-PARITY-BACKLOG.10.0 capture
date: 2026-07-20
status: neutral contract executable; backend rollout pending
tags: [introspection, semantic-api, mcp, backends, provenance, explainability, FUTURE-PARITY-BACKLOG]
evidence: "Director proposed deep semantic introspection through a clean API and MCP; FUTURE-PARITY-BACKLOG.10.0 captures the direction and .10.1 owns design before implementation."
evidence_update_2026_07_20: "FUTURE-PARITY-BACKLOG.10.1 and ADR 0049 accept the exact linkedspec-semantic-model-v1 / linkedspec-semantic-query-v1 direction, native SemanticIndex ownership, immutable compilation/runtime snapshots, stable snapshot-local ids, normalized records/relations/shapes/evidence, deterministic pages/cost, structural source privacy, exact fixtures, and two-tool handle-only MCP projection. Implementation remains pending under .10.2-.10.10."
evidence_update_2026_07_20_staged_schema: "Executable modeling in .10.2 exposed that ADR 0049 required staged payload/job/result provenance but named no staged record. ADR 0050 corrects v1 before implementation with explicit staged_artifact payload/parse_job/result records, consumes/produces relations, exact policy/status/value facts, source provenance, and a strict separation from generated_artifact."
evidence_update_2026_07_20_neutral_contract: "FUTURE-PARITY-BACKLOG.10.2 makes the model/query executable without backend behavior: six fixture groups, 20 independently derived digest-locked responses, record/relation/depth/page/source failures, exact staged topology, and unconditional canonical-CI registration. Correction .10.3.2.0 cross-gates static rules against linkedspec-rule-local-cursor-v1 and advances the mutation proof from 50 to 53. Neutral rollout is 1 complete / 8 pending; native backend admission remains 0 complete / 6 pending."
evidence_update_2026_07_21_generated_plan_correction: "FUTURE-PARITY-BACKLOG.10.3.3.0 cross-gates the calls snapshot's generated artifact against the actual generated-source-v2 authority. Exact emitted metadata says default, while the stale model said illegal and_acode. Correcting it and adding illegal/coordinated-family mutations advances the checker from 53 to 55 without changing query digests, behavior, rollout, or admission."
evidence_update_2026_07_21_spec_identity_correction: "FUTURE-PARITY-BACKLOG.10.3.3.1.0 derives spec names from caller logical identity after full calls RED found the model alone used short snapshot id calls instead of calls_and_staging. Direct and coordinated identity mutations advance the checker from 55 to 57 without changing any query digest, behavior, rollout, or admission."
evidence_update_2026_07_21_perl_admission: "FUTURE-PARITY-BACKLOG.10.3.6 composes the implemented Perl surface through one exact 12-role consumer, all 20 response digests, and path/role/driver/registration/admission mutation locks. The checker now rejects 65 mutations; only Perl advances, for rollout 2/9 and native admission 1/6."
reverify: "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py && rg -n 'linkedspec-semantic-model-v1|FUTURE-PARITY-BACKLOG.10.[2-9]|linkedspec_semantic_query' docs/decisions/0049-versioned-semantic-introspection-model-and-thin-mcp.md docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

Deep semantic introspection is a strong fit for LinkedSpec because the project already constructs and relates
grammar, rule, edge, lifecycle, helper/action, compiled-state, runtime, diagnostic, and generated-source semantics.
ADR `0049` now fixes the future neutral model as `linkedspec-semantic-model-v1` and its request/response protocol as
`linkedspec-semantic-query-v1`. The immutable `SemanticIndex` derives normalized records, relations, shapes,
diagnostics, and evidence from existing semantic authorities without serializing their backend layouts.

The semantic owner is the native in-memory index exposed through each variant's idiomatic API. Snapshot-local ids,
fixed ordering, page/budget accounting, source ceilings/redactions, schema evolution, optional caller-captured
runtime observations, and exact cross-backend answers are model behavior. A query is read-only and never runs a
parser, loads a path, or enables tracing.

The accepted design covers deterministic read-only queries for:

- rules, symbols, edges, calls, regex and lifecycle meaning;
- source spans, stable ids, and provenance through lowering/generated source;
- inferred value and target shapes plus helper/function resolution;
- diagnostics and explain-why paths for compile/runtime decisions;
- ordering, pagination/cost bounds, schema evolution, and privacy/source controls.

Every backend must return equivalent semantic answers through exact shared fixtures. Backend AST/IR layouts, host
object identities, compiled regex/callable values, undeclared source paths, and MCP-specific behavior are not part
of the contract. Read-only introspection precedes any mutation/refactoring API.

MCP has only native capabilities and query projections over a caller-registered opaque handle. It never compiles,
reads implicit files, derives records, or invents explanations. `.10.2-.10.8` own the executable neutral contract
and six-runtime rollout, `.10.9` owns that thin transport, and `.10.10` owns public no-drift. ADR `0049` and design
leaf `.10.1` change no current parser/compiler/runtime/descriptor/generated/CLI/trace/MCP behavior.

ADR `0050` amends the v1 vocabulary so staged payloads, parse jobs, and stitched results are
explicit `staged_artifact` records related by `consumes`, `produces`, `staged_by`, and `lowered_from`. They are not
misclassified as generated artifacts.

The neutral contract is executable through six fixture groups and 20 exact response digests; its independent
checker rejects 65 schema, identity, ordering, topology, privacy, budget, consumer, rollout, MCP-ownership, and
coordinated static-rule/generated-plan/model-hash mutations. The neutral contract and Perl reference are complete;
five native runtime admissions remain pending.

Related facts: [[native-in-memory-backend-contract]],
[[user-observable-backend-cli-parity-contract]],
[[canonical-primary-cli-trace-protocol]], [[actionir-lowering-stack]],
[[runtimecontext-boundary]].
