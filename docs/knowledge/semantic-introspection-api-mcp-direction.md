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
date: 2026-07-10
status: proposed
tags: [introspection, semantic-api, mcp, backends, provenance, explainability, FUTURE-PARITY-BACKLOG]
evidence: "Director proposed deep semantic introspection through a clean API and MCP; FUTURE-PARITY-BACKLOG.10.0 captures the direction and .10.1 owns design before implementation."
reverify: "rg -n 'FUTURE-PARITY-BACKLOG.10|semantic introspection|MCP is a thin' docs/tasks/FUTURE-PARITY-BACKLOG.md ROADMAP.md ROADMAP_V2.md docs/linkedspec-book/src/overview/project-status.md docs/linkedspec-book/src/appendix/backend-handoff.md"
---

Deep semantic introspection is a strong fit for LinkedSpec because the project
already constructs and relates grammar, rule, edge, lifecycle, helper/action,
compiled-state, runtime, diagnostic, and generated-source semantics. A deliberate
query surface can make those relationships usable by embedding applications,
IDEs, agents, parity tools, visualizers, and debuggers without exposing raw trace
streams or requiring callers to understand backend internals.

The semantic owner must be a versioned backend-neutral model exposed through each
variant's idiomatic in-memory API. MCP, CLIs, IDE adapters, and agents should all
project or consume that same model. MCP is transport—not the place where semantic
facts are derived or interpreted.

The pending design should cover deterministic read-only queries for:

- rules, symbols, edges, calls, regex and lifecycle meaning;
- source spans, stable ids, and provenance through lowering/generated source;
- inferred value and target shapes plus helper/function resolution;
- diagnostics and explain-why paths for compile/runtime decisions;
- ordering, pagination/cost bounds, schema evolution, and privacy/source controls.

Every backend must return equivalent semantic answers through exact shared
fixtures. Backend AST/IR layouts, host object identities, source paths outside the
declared provenance model, and MCP-specific behavior must not become the public
contract. Read-only introspection should precede any mutation/refactoring API.

`FUTURE-PARITY-BACKLOG.10.1` owns design and later implementation splitting. The
capture leaf `.10.0` changes no parser/compiler/runtime/MCP behavior and does not
pivot the active `.1.5.1.6` UTF-8 CLI frontier.

Related facts: [[native-in-memory-backend-contract]],
[[user-observable-backend-cli-parity-contract]],
[[canonical-primary-cli-trace-protocol]], [[actionir-lowering-stack]],
[[runtimecontext-boundary]].
