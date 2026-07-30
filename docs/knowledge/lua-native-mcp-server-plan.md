---
id: lua-native-mcp-server-plan
title: Lua MCP is one literal-bound native server source admitted on PUC Lua and LuaJIT
answers:
  - how will LinkedSpec implement the Lua MCP server
  - does Lua MCP have one implementation or two
  - do PUC Lua and LuaJIT use the same MCP source
  - how does Lua MCP obtain secure random bytes
  - how does Lua MCP measure monotonic expiry
  - does Lua MCP read /dev/urandom
  - how does Lua MCP preserve JSON integer versus number kinds
  - why does Lua MCP read stdio one byte at a time
  - how is the MCP contract embedded in Lua
  - does Lua MCP use Base64 for the contract bundle
  - what is the public Lua MCP API
  - does Lua MCP require LuaRocks or an MCP SDK
  - when will Lua advance the MCP implementation ledger
date: 2026-07-29
status: architecture and decoded implementation complete; strict wire, admission, and closeout pending under FUTURE-PARITY-BACKLOG.10.9.6.2-.4
tags: [lua, luajit, mcp, generated-binding, json, stdio, security, dual-abi, parity]
evidence: "FUTURE-PARITY-BACKLOG.10.9.6.0 and ADR 0061 retrieve the admitted Lua semantic/JSON/SHA/toolchain owners and measure one exact implementation architecture on repository-routed PUC Lua 5.4.8 and LuaJIT 2.1 without changing behavior or the 4/5 + 4/6 MCP ledger."
evidence_update_2026_07_29_decoded: "FUTURE-PARITY-BACKLOG.10.9.6.1 implements the generated 82,827-byte literal binding, digest/schema-verifying frozen runtime, protected secure registry/decoded dispatch, lazy root API, and one common C99 entropy/monotonic-time module. Exact focused proof passes 111 + 210 assertions on each ABI; governance rejects 94 mutations while formal status remains 4/5 + 4/6 pending strict wire and admission."
last_verified: 2026-07-29
reverify:
  - "bash tools/run_lua_local.sh"
  - "bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py"
  - "rg -n 'one literal contract binding|secure_random_32|one byte at a time|5/5 implementations' docs/decisions/0061-lua-native-mcp-server-seams.md docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

# Lua Native MCP Server Plan

Lua will provide one native MCP implementation from one Lua-5.1-compatible source graph. PUC Lua and LuaJIT load
separately compiled native modules but execute the exact same generated binding, runtime, server, wire, consumer,
and ordered admission roles. The public server identity is `linkedspec-semantic-lua` on both ABIs; admission
reporting outside the wire distinguishes the runtimes.

The generated `mcp_contract.lua` stores the exact 82,543-byte canonical bundle in a deterministic long-bracket
literal. The generator selects the first delimiter level whose closing token is absent and emits no newline after
the opener. Private runtime code verifies the exact length and SHA-256, decodes through `linkedspec.json`, validates
the frozen schema profile, and exposes only detached clones. On both measured ABIs the existing pure-Lua JSON
codec round-trips the bundle byte-for-byte; pure-Lua SHA-256 is acceptable as a one-time initialization check.

Decoded values cannot preserve MCP wire number-token kind: PUC Lua normalizes integral floats when encoding, and
LuaJIT collapses `1`, `1.0`, and `1e0`. Private `mcp_wire.lua` therefore performs iterative bounded lexical
preflight before decoding, recording integer versus fraction/exponent tokens and enforcing the depth-64, duplicate
decoded-key, UTF-8, JSON, schema, and JSON-RPC-id rules identically. It reads caller-owned streams one byte at a
time because larger fixed reads block on interactive pipes; the measured cost for the maximum 1 MiB frame is
about 0.096 seconds on PUC Lua and 0.059 seconds on LuaJIT.

One tracked `lua/native/mcp_system.c` supplies only fixed 32-byte OS entropy and monotonic milliseconds. The
existing builder compiles it separately for both ABIs in repository-volume managed scratch. Darwin/BSD uses
`arc4random_buf`, Linux uses a complete EINTR-safe `getrandom` loop, and time uses `CLOCK_MONOTONIC`; unsupported
systems and failures stop closed. There is no `/dev/urandom`, filesystem, `math.random`, wall-clock, weak fallback,
LuaRocks package, MCP SDK, network, async runtime, or executable.

The implemented decoded root API is `mcp_server`, `mcp_budget_limits`, `mcp_deployment_policy`,
`mcp_registration_options`, `is_mcp_server_error`, and `mcp_server_error_to_json`. A protected server supports
`register_index`, `revoke_handle`, `dispatch`, and `shutdown`; `serve_stdio` remains `.2`. It accepts only an existing
protected semantic index and a copied nonempty binary authorization string of at most 4,096 bytes, stores only its
SHA-256 digest, uses fixed-work comparison and 43-character base64url handles, and calls only index
`capabilities()` or `query_neutral()`.

Implementation order is generated/runtime/decoded/native-system `.1` (complete), strict stdio `.2`, identical dual-ABI
admission `.3`, and unchanged closeout `.4`. Only `.3` may advance formal MCP status from 4/5 implementations plus
4/6 runtimes to 5/5 plus 6/6. Recurring rollout remains `.10.9.7`.

Related facts: [[mcp-native-server-topology]], [[mcp-implementation-admission-ledger]],
[[mcp-2026-07-28-stdio-contract]], [[lua-semantic-introspection-admission]],
[[lua-semantic-query-public-api]], and [[lua-toolchain-package-policy]].
