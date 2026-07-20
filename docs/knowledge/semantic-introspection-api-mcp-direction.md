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
status: accepted direction; implementation pending
tags: [introspection, semantic-api, mcp, backends, provenance, explainability, FUTURE-PARITY-BACKLOG]
evidence: "Director proposed deep semantic introspection through a clean API and MCP; FUTURE-PARITY-BACKLOG.10.0 captures the direction and .10.1 owns design before implementation."
evidence_update_2026_07_20: "FUTURE-PARITY-BACKLOG.10.1 and ADR 0049 accept the exact linkedspec-semantic-model-v1 / linkedspec-semantic-query-v1 direction, native SemanticIndex ownership, immutable compilation/runtime snapshots, stable snapshot-local ids, normalized records/relations/shapes/evidence, deterministic pages/cost, structural source privacy, exact fixtures, and two-tool handle-only MCP projection. Implementation remains pending under .10.2-.10.10."
reverify: "rg -n 'linkedspec-semantic-model-v1|FUTURE-PARITY-BACKLOG.10.[2-9]|linkedspec_semantic_query' docs/decisions/0049-versioned-semantic-introspection-model-and-thin-mcp.md docs/tasks/FUTURE-PARITY-BACKLOG.md"
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

Related facts: [[native-in-memory-backend-contract]],
[[user-observable-backend-cli-parity-contract]],
[[canonical-primary-cli-trace-protocol]], [[actionir-lowering-stack]],
[[runtimecontext-boundary]].
