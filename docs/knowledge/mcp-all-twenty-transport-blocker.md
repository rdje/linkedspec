---
id: mcp-all-twenty-transport-blocker
title: "Three neutral semantic cases cannot currently cross the public MCP boundary unchanged"
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
status: verified blocker; recommended repair director-authorized 2026-07-30; implementation and rollout pending
tags: [mcp, semantic-introspection, schema, policy, conformance, blocker]
evidence: "FUTURE-PARITY-BACKLOG.10.9.7.1.0 extends the committed Perl MCP admission consumer only long enough to dispatch all twenty governed native responses, then removes the exploratory diff. Capabilities plus 16/19 query cases retain exact direct/MCP/digest identity. calls_symbols_and_shapes becomes a sanitized internal error because the shared MCP recordFacts propertyNames omit valid effects and return_shape keys. unsupported_contract becomes invalid params because semanticQueryRequest.contract is a const. source_ceiling_forbidden becomes linkedspec_mcp_policy_denied because the default native-derived policy is enforced before native query dispatch. The same neutral schema and policy ordering are implemented by all five servers, so this is a shared contract boundary rather than a Perl-only test defect. The director authorized the recommended exact repair on 2026-07-30. Child .10.9.7.1.1.0 freezes one atomic contract/bindings/five-server correction before six-runtime identity proof and later promotion; no behavior has changed yet and rollout remains pending."
last_verified: 2026-07-30
reverify:
  - "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py"
  - "rg -n 'recordFacts|effects|return_shape|semanticQueryRequest|const.*linkedspec-semantic-query-v1' capability_conformance/mcp_semantic_transport/schema.json tools/materialize_mcp_semantic_transport_contract.py"
  - "rg -n '_request_within_policy|policy_denied|query_neutral|semantic_query_neutral' perl/LinkedSpec/MCPServer.pm rust/linkedspec-runtime/src/mcp_server.rs dart/lib/src/mcp/mcp_server.dart julia/src/mcp/McpServer.jl lua/src/linkedspec/mcp_server.lua"
---

# MCP all-twenty transport blocker

Native semantic admission proves all twenty ordered cases, but the current public MCP boundary can preserve only
capabilities plus sixteen of the nineteen query cases unchanged. The remaining three are rejected before the
native semantic response can become MCP structured content and canonical text:

- `calls_symbols_and_shapes`: the valid response contains `effects` and `return_shape` facts absent from the MCP
  `recordFacts.propertyNames` enum, so tool-success validation becomes a sanitized internal error;
- `unsupported_contract`: the MCP input schema requires the supported contract with `const`, so the native query
  layer cannot return its governed `semantic_query_contract_unsupported` response; and
- `source_ceiling_forbidden`: the server applies the default native-derived ceiling as a pre-dispatch deployment
  policy, so the native query layer cannot return its governed `semantic_query_source_detail_forbidden` response.

This is shared by the one neutral schema and five native implementations. A consumer-only workaround would not
prove the public API and is therefore invalid. The recommended correction is to admit all semantic fact keys in
the MCP output schema, accept a bounded query-contract string so the native portable error remains reachable, and
apply pre-dispatch ceiling denial only for an explicit deployment overlay while preserving strict default/native
and explicit-policy security. That correction changes contract artifacts/digests and identical behavior in five
servers. The director authorized it on 2026-07-30; task `.10.9.7.1.1.1` owns the atomic repair.

The non-selected alternative was to weaken the claim to seventeen direct/MCP identities plus three distinct
transport outcomes. Until the authorized path is implemented and proven, `thin_mcp_transport` remains pending.
