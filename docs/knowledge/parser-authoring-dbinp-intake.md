---
id: parser-authoring-dbinp-intake
title: Rule libraries, native builders and fileless MCP authoring are proposed investigations
answers:
  - are generic or parameterized LinkedSpec rules planned
  - can reusable rule libraries be shared between spec files
  - is a programmatic parser builder already implemented
  - does LinkedSpec require a physical spec file
  - can an agent create and debug a parser entirely through MCP
  - where are the DBINP parser authoring ideas tracked
date: 2026-09-08
status: proposed investigations; no implementation activation
tags: [authoring, generics, libraries, builder, mcp, roadmap, discussion]
evidence: "Director DBINP discussion preserved in commit d6f37492505661c87c06c112126da101308ec6e4; SESSION-STARTUP-READING.3.3.43 routes three proposals to PARSER-AUTHORING-APIS. Existing foundations are ADR 0013 design-only composition, ADR 0022 native in-memory source, ADR 0037 construction/runtime observability and ADR 0054 thin read-only MCP."
reverify: "rg -n 'PARSER-AUTHORING-APIS|proposed|DBINP|in-memory|read-only' docs/tasks/PARSER-AUTHORING-APIS.md docs/knowledge/spec-import-composition-contract.md docs/knowledge/native-in-memory-backend-contract.md docs/knowledge/mcp-native-server-topology.md"
---

# Three related proposals, with distinct existing foundations

`PARSER-AUTHORING-APIS` captures the director's brainstorming without activating implementation. Its three
investigations are proposed; approval of the separate format/language coverage matrix does not adopt these APIs.

| Owner | Proposal | Existing foundation and boundary |
| --- | --- | --- |
| `.1` | Reusable rule libraries and static rule parameters across specifications | ADR `0013` accepts the design of aliased imports and structured includes; those directives remain unimplemented. Parameterization adds specialization, naming, hygiene, state/result contracts and bounded recursion questions. |
| `.2` | Idiomatic native builders for dynamically assembled parser descriptions | ADR `0022` already permits in-memory source on all five backends without a physical `.spec` file. Public AST/compiler seams are structural foundations; they do not establish a stable cross-backend fluent builder. |
| `.3` | An agent constructs, inspects, executes and debugs parsers through native APIs and MCP | Current MCP exposes capabilities/query on host-registered immutable semantic indexes. Authoring, compilation, execution and complete debugger sessions are separate proposed capabilities. |

Illustrative generic factories such as `Separated<Item, Separator>` or `Delimited<Open, Body, Close>` are
discussion notation only. Investigation must distinguish static rule parameters from runtime value arguments,
preserve ordinary rule-entry and outgoing-edge semantics, define exports/private helpers and invocation-local
state, and retain result/capture/span contracts plus reproducible dependency and specialization fingerprints.

A builder would feed the same validated logical specification model as text parsing. Potential uses include
schema/configuration-derived grammars, protocol dialects, visual editors, grammar transformations and reusable
rule factories. Preserve full `.spec` support, portable actions, logical source/node identity and immutable
compiled snapshots. Semantic source export may aid review; objects without original source cannot promise exact
original formatting. No performance or hot-mutation guarantee is adopted.

The proposed agent loop is construct, validate, inspect, run, diagnose and revise. Native APIs would own every
operation, with thin MCP transport, separate operation capabilities, resource bounds and explicit revision/node/
run identity. Construction and execution tracing are valuable existing directions, but debugger stepping,
breakpoints and session lifecycle require their own defined semantics. A physical spec file need not be the
authoring input; this does not waive repository-local storage policy for any generated data a workflow creates.

Related: [[spec-import-composition-contract]], [[native-in-memory-backend-contract]],
[[mcp-native-server-topology]], [[post-parity-structured-text-program]].
