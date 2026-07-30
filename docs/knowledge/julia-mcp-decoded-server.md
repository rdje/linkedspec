---
id: julia-mcp-decoded-server
title: Julia has a native decoded MCP server around SemanticIndex
answers:
  - "is the Julia LinkedSpec MCP decoded server implemented"
  - "how do I register a Julia SemanticIndex with MCP"
  - "how do I call Julia dispatch_mcp"
  - "which Julia files implement the MCP decoded server"
  - "how does Julia MCP generate and authorize handles"
  - "does Julia MCP read contract files at runtime"
  - "is Julia MCP stdio implemented yet"
  - "is the Julia MCP implementation admitted yet"
date: 2026-07-29
status: decoded server implemented; strict stdio and formal admission pending
tags: [julia, mcp, semantic-introspection, embedding, handles, security, generated-data]
evidence: julia/src/mcp/McpContract.jl; julia/src/mcp/McpContractRuntime.jl; julia/src/mcp/McpServer.jl; julia/src/LinkedSpecJulia.jl; julia/test/mcp_contract_julia_binding_test.jl; julia/test/mcp_server_julia_dispatch_test.jl; tools/generate_julia_mcp_contract.py; capability_conformance/mcp_implementation_admission.json
reverify: "bash tools/run_python_project_data.sh tools/generate_julia_mcp_contract.py && bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, Test; const REPO_ROOT=pwd(); include(\"julia/test/mcp_contract_julia_binding_test.jl\"); include(\"julia/test/mcp_server_julia_dispatch_test.jl\")' && bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py"
---

# Julia Decoded MCP Server

`FUTURE-PARITY-BACKLOG.10.9.5.1` implements the public Julia `McpServer`. A host creates an immutable
`SemanticIndex`, registers that exact value with 1–4,096 copied opaque authorization bytes and optional lower-only
limits, then passes already-decoded JSON-like requests to `dispatch_mcp`. The server invokes only fresh
`semantic_capabilities(index)` and `semantic_query_neutral(index, request)` plus detached `to_json`; it cannot
load source or paths, compile or execute, enable trace, open a file, start a process, use a socket, or retain a
semantic response cache.

`tools/generate_julia_mcp_contract.py` renders the stable 119,538-byte Base64-only `McpContract.jl` from the same
digest-verified neutral bundle as Perl, Rust, and Dart. `McpContractRuntime.jl` verifies the decoded canonical
bundle SHA before JSON3, implements the frozen schema profile, clones JSON-like values, owns recursive key-sorted
canonical JSON, and constructs Julia-identity responses without runtime artifact reads. `McpServer.jl` owns the
public types, secure registry, decoded dispatch, and native semantic calls.

Production handles contain exactly 256 bits from `RandomDevice`, encoded as 43 unpadded base64url characters.
The server retains only an SHA-256 authorization digest, performs a fixed-work 32-byte comparison against either
the stored or dummy digest, measures absolute expiry with elapsed monotonic `time_ns()` milliseconds, bounds live
handles at 1,024, prunes expired entries, and clears retained indexes on shutdown. Unknown, expired, revoked, and
unauthorized handles are externally indistinguishable. Policy may lower source detail, content-digest access,
page size, and budgets but cannot elevate native limits.

Focused proof covers the generated digest and clone boundary, the exact frozen schema profile, all canonical
decoded classifications, native payload identity, lower-only policy, authorization isolation, expiry, revocation,
capacity, entropy/clock/collision failure, cancellation, sanitation, shutdown, opacity, and production authority
fences at 48 + 139 assertions. Strict byte/token/framing behavior and public `serve_mcp_stdio!` remain
`.10.9.5.2`. Exact twelve-role admission `.3` alone may move Julia to 4/5 implementations and 4/6 runtimes; the
formal ledger remains 3/5 + 3/6 with shared rollout pending.

Related facts: [[julia-native-mcp-server-plan]], [[julia-semantic-query-public-api]],
[[mcp-2026-07-28-stdio-contract]], [[mcp-native-server-topology]], and
[[mcp-implementation-admission-ledger]].
