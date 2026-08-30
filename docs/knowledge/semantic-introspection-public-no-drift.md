---
id: semantic-introspection-public-no-drift
title: Semantic introspection and MCP have one governed public current state
answers:
  - is semantic introspection public rollout complete
  - what closes FUTURE-PARITY-BACKLOG.10.10
  - which public semantic introspection documents are governed
  - where are the worked semantic query examples
  - which semantic example families are required
  - how is stale semantic or MCP documentation rejected
  - does public closeout create backend companion books
  - are the backend companion mdBooks scaffolded
  - which recurring semantic and MCP drivers are public authorities
  - how many semantic introspection mutations are rejected now
date: 2026-07-30
status: current; public rollout and semantic parent complete
tags: [semantic-introspection, mcp, public-api, documentation, no-drift, conformance, mdbook]
evidence: "FUTURE-PARITY-BACKLOG.10.10 extends the independent semantic contract checker with a public contract over 28 current surfaces, nine worked example families, both recurring drivers, and the separately task-owned companion-book boundary. The checker rejects 128 mutations and closes semantic rollout at 9/9 with native admission 6/6; MCP remains 5/5 implementations + 6/6 runtimes complete/141."
evidence_update_2026_08_30_mdbook_reconciliation: "FUTURE-PARITY-BACKLOG.23.2 adds the exact former descriptor-introspection statement that advertised the 50-mutation/no-backend `.10.2` boundary to the forbidden-current-claim set. The page already carries the correct 128-mutation, 9/9, 6/6, and descriptor-versus-semantic boundary; no semantic model, evaluator, transport, runtime, or mutation total changes."
reverify:
  - bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py
  - bash tools/check_semantic_introspection_six_runtime.sh
  - bash tools/check_mcp_six_runtime.sh
  - bash scripts/check_memory_architecture.sh
  - bash knowledge-map/scripts/check_knowledge_map.sh
---

# Semantic introspection public no-drift

LinkedSpec now has one governed public current state for deep semantic introspection and its thin MCP transport.
The normative semantic answers remain in `semantic_introspection_contract.json` and its model; public closeout does
not create a second model, evaluator, server, or response oracle.

The independent checker requires 28 current surfaces: the Perl user guide; Rust, Dart, Julia, and Lua READMEs; the
capability guide; both roadmaps; live architecture/toolbox/task state; ADRs `0049`, `0054`, `0055`, and `0062`;
the direction, neutral, recurring, MCP-topology, MCP-protocol, and MCP-ledger Knowledge cards plus this card; and
the neutral mdBook's semantic API, project status, backend handoff, descriptor boundary, and navigation pages.
Missing markers and exact stale current claims fail before a backend can be described as complete.

The neutral mdBook owns nine worked example families: graph, resolution, provenance, diagnostics, explanation,
privacy, pagination, runtime observation, and MCP. The examples use the exact neutral envelope and emphasize the
authority boundary: queries inspect immutable projections; caller-captured observations derive a new index; MCP
forwards registered native answers; no surface reads implicit paths, executes from a query, exposes backend IR, or
lets transport invent semantics.

Both recurring proof owners remain explicit. `tools/check_semantic_introspection_six_runtime.sh` composes the six
native admissions; `tools/check_mcp_six_runtime.sh` composes the all-twenty MCP identities, five generated
bindings, six runtime consumers, ledger, and primary no-drift. Eighteen public omissions and rollbacks extend the
110 prior mutations to 128.

ADR `0040` and `docs/tasks/BACKEND-COMPANION-BOOKS.md` remain the exact companion-book boundary. Five companion
mdBooks are accepted but not scaffolded; their templates, navigation, ownership rules, gates, and content remain
separate `BACKEND-COMPANION-BOOKS.1+` work. This closeout governs the current neutral book and backend READMEs
without prematurely creating or populating those companions.

Related facts: [[semantic-introspection-api-mcp-direction]], [[semantic-introspection-neutral-contract]],
[[semantic-introspection-recurring-gate]], [[mcp-native-server-topology]],
[[mcp-2026-07-28-stdio-contract]], [[mcp-implementation-admission-ledger]], and
[[backend-companion-book-architecture]].
