---
id: lua-mcp-decoded-server
title: Lua MCP decoded dispatch is one protected source on PUC Lua and LuaJIT
answers:
  - is the Lua MCP decoded server implemented
  - what does linkedspec mcp_server do
  - how does Lua MCP store authorization
  - how are Lua MCP handles generated
  - what native authority does Lua MCP use
  - does Lua MCP dispatch compile or execute parsers
  - is Lua MCP formally admitted
  - how many Lua MCP decoded tests pass
  - when was Lua MCP formally admitted
date: 2026-07-29
status: decoded implementation, strict wire, and exact one-source dual-ABI admission complete
tags: [lua, luajit, mcp, decoded-dispatch, security, handles, policy, native-system]
evidence: "FUTURE-PARITY-BACKLOG.10.9.6.1 adds the generated 82,827-byte literal binding, frozen runtime, protected registry/server, lazy root API, and one common C99 native system source. Binding/runtime proof passes 111 assertions and decoded/security proof passes 210 assertions identically on PUC Lua and LuaJIT; governance rejects 94 mutations while the formal ledger remains 4/5 + 4/6 pending .2-.3."
evidence_update_2026_07_29_stdio: "FUTURE-PARITY-BACKLOG.10.9.6.2 adds one private iterative strict wire and public caller-owned serve_stdio method. The same source passes 247 framing/lexical/canonical/cancellation/lifecycle assertions on each ABI; governance rejects 98 mutations while formal admission remains pending under .3."
evidence_update_2026_07_29_admission: "FUTURE-PARITY-BACKLOG.10.9.6.3 runs one exact 202-assertion twelve-role consumer unchanged on PUC Lua and LuaJIT. The formal checker reaches 5/5 implementations + 6/6 runtimes with rollout pending and 114 rejected mutations; no production source or transport byte changes."
last_verified: 2026-07-30
reverify:
  - "bash tools/run_lua_local.sh"
  - "bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py"
  - "rg -n 'mcp_server|register_index|query_neutral|mcp_system' lua/src/linkedspec lua/native tools/build_lua_native.sh"
---

# Lua MCP Decoded Server

`lua/src/linkedspec/mcp_server.lua` is one Lua-5.1-compatible implementation shared unchanged by PUC Lua and
LuaJIT. The root package lazily exports `mcp_server`, budget/policy/registration constructors, and typed error
inspection. Protected weak-key state keeps server, registry, policy, limit, registration, and error internals
non-iterable and immutable.

Production registration accepts only an existing native Lua `SemanticIndex`. It copies and bounds the caller's
opaque authorization string, retains only its binary SHA-256 digest, compares exactly 32 digest bytes, creates a
43-character unpadded base64url handle from 32 OS-random bytes, and expires state against monotonic milliseconds.
Unknown, unauthorized, expired, and revoked handles are deliberately indistinguishable. Registry capacity is the
contract's 1,024 live entries; revoke and shutdown release retained indexes.

Decoded dispatch clones caller input, implements modern discovery/list/two-tool/cancellation classifications,
projects canonical detached results, and sanitizes native failures. Policy can only lower native source detail,
digest visibility, page limit, and budget maxima. Production calls are limited to `index:capabilities()` and
`index:query_neutral(request)`; the server has no source/path/parser/compiler/executor/trace/cache/filesystem/
environment/network/process/async/SDK or primary-CLI authority.

`lua/native/mcp_system.c` is compiled separately for each ABI from the same C99 source. It exposes only fixed
32-byte entropy and monotonic milliseconds, using `arc4random_buf` on Darwin/BSD, an EINTR-safe complete
`getrandom` loop on Linux, and `CLOCK_MONOTONIC`. Unsupported platforms and runtime failures stop closed; there is
no filesystem or weak fallback.

Private `mcp_wire.lua` and public `server:serve_stdio` now own bounded LF/CRLF/final-EOF framing, iterative
duplicate-safe UTF-8/JSON admission, numeric-token paths, canonical LF, cancellation through flush, fixed optional
diagnostics, and terminal release without closing caller streams. Exact `.3` now runs one 202-assertion consumer
unchanged on both ABIs and advances the existing owners to 5/5 implementations plus 6/6 runtime admissions.
Recurring `.10.9.7.1.1.3` subsequently composes all six runtimes and completes shared rollout at 141 mutations.

Related facts: [[lua-native-mcp-server-plan]], [[mcp-native-server-topology]],
[[lua-mcp-implementation-admission]], [[mcp-implementation-admission-ledger]], [[lua-semantic-query-public-api]], and
[[lua-project-data-ssd-storage]].
