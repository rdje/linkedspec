---
id: mcp-all-twenty-transport-blocker
title: "The three-case public MCP transport blocker and its atomic repair"
answers:
  - "why is recurring MCP all twenty identity blocked"
  - "which semantic query cases fail through MCP"
  - "why does calls_symbols_and_shapes fail through MCP"
  - "why can MCP not return semantic_query_contract_unsupported"
  - "why can MCP not return semantic_query_source_detail_forbidden"
  - "which MCP schema fact keys are missing"
  - "does MCP currently preserve all twenty semantic responses"
  - "what must change before thin_mcp_transport promotion"
date: 2026-07-29
status: verified blocker repaired under .10.9.7.1.1.1; all-twenty consumer proof complete; routed rollout pending
tags: [mcp, semantic-introspection, schema, policy, conformance, blocker]
evidence: "FUTURE-PARITY-BACKLOG.10.9.7.1.0 proved capabilities plus 16/19 query identities and root-caused missing effects/return_shape output keys, const query-contract input, and default-policy preemption. Authorized leaf .10.9.7.1.1.1 derives the exact 72-key semantic fact union, admits nonempty query-contract strings through 128 characters/128 UTF-8 bytes, and keys pre-dispatch denial to explicit component presence in all five servers. Leaf .10.9.7.1.1.2 proves capabilities plus all nineteen queries preserve direct-native/MCP structured/text/decoded/digest identity on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT; complete canonical CI is green. Neutral MCP remains 35/10/10/76 with byte-fresh bindings 83,411/83,225/83,214/120,030/83,166. Formal state remains 5/5 implementations + 6/6 runtimes, rollout pending/114 until routed governance promotes thin transport."
last_verified: 2026-07-30
reverify:
  - "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py"
  - "rg -n 'recordFacts|effects|return_shape|semanticQueryRequest|maxUtf8Bytes|explicit_overlay_component_presence_only' capability_conformance/mcp_semantic_transport/schema.json capability_conformance/mcp_semantic_transport_contract.json tools/materialize_mcp_semantic_transport_contract.py"
  - "rg -n '_request_within_policy|policy_denied|query_neutral|semantic_query_neutral' perl/LinkedSpec/MCPServer.pm rust/linkedspec-runtime/src/mcp_server.rs dart/lib/src/mcp/mcp_server.dart julia/src/mcp/McpServer.jl lua/src/linkedspec/mcp_server.lua"
---

# MCP all-twenty transport blocker

Native semantic admission proved all twenty ordered cases, but the pre-repair public MCP boundary preserved only
capabilities plus sixteen of the nineteen query cases unchanged. The remaining three were rejected before the
native semantic response could become MCP structured content and canonical text:

- `calls_symbols_and_shapes`: the valid response contains `effects` and `return_shape` facts absent from the MCP
  `recordFacts.propertyNames` enum, so tool-success validation becomes a sanitized internal error;
- `unsupported_contract`: the MCP input schema requires the supported contract with `const`, so the native query
  layer cannot return its governed `semantic_query_contract_unsupported` response; and
- `source_ceiling_forbidden`: the server applies the default native-derived ceiling as a pre-dispatch deployment
  policy, so the native query layer cannot return its governed `semantic_query_source_detail_forbidden` response.

This was shared by the one neutral schema and five native implementations. A consumer-only workaround would not
have proved the public API and was therefore invalid. The director-authorized atomic correction is now
implemented under `.10.9.7.1.1.1`: the exact governed fact-key union is admitted, bounded contract strings reach
native version handling, and only explicitly supplied deployment-overlay components own pre-dispatch denial.
Inherited native limits still govern the semantic index, but they now report through native portable diagnostics.
Unrelated partial overlays do not acquire authority over omitted components.

The non-selected alternative was to weaken the claim to seventeen direct/MCP identities plus three distinct
transport outcomes. The transport blocker is repaired and `.1.1.2` now proves all twenty identities on all six
runtimes. `thin_mcp_transport` remains pending until `.1.1.3` composes that evidence through the rooted recurring
gate, adds omission-sensitive governance, and performs the coordinated promotion.
