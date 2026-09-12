---
id: lua-mcp-runtime-server-reading-and-validation-gaps
title: Lua MCP runtime and server reading extends option and integer-copy repairs
answers:
  - what did Lua startup reading group fourteen cover
  - do Lua MCP option constructors reject false option tables
  - does the PUC integer JSON issue also affect MCP data cloning
  - did the Lua MCP integer observation change request ID bounds
  - where is the approved named user-function argument direction recorded
  - did the named argument discussion change the active startup reading frontier
date: 2026-09-12
status: exact group fourteen read; existing repairs extended; named-argument direction approved and parked
tags: [lua, reading, mcp, validation, json, integer, dbinp]
evidence: "LUA-STARTUP-READING.1.14 reads 1500 fragments /53162 bytes from 722674ef9d199876153832f3db258bd39ef7ac88. Both installed hosts pass 216 decoded-server, 247 stdio and 33 valid boundary assertions each, 992 total. Two false constructor defaults extend .2.8.7/.8; PUC integer-copy loss extends .2.11. Named-argument direction is approved but parked under PARSER-AUTHORING-APIS.4 with four design/planning children."
reverify:
  - "Run the exact managed boundary replay below on both hosts."
  - "bash tools/run_lua_project_data.sh puc lua/test/mcp_server_lua_dispatch_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/mcp_server_lua_dispatch_test.lua"
  - "bash tools/run_lua_project_data.sh puc lua/test/mcp_server_lua_stdio_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/mcp_server_lua_stdio_test.lua"
  - "bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py"
  - "bash tools/run_python_project_data.sh tools/check_callable_signature_contract.py"
  - "Run LUA_READING_COVERAGE in docs/knowledge/lua-startup-reading-coverage.md."
---

# Exact reading

Activation is `722674ef9d199876153832f3db258bd39ef7ac88`; source baseline remains
`baeb984e36a94a15951cd23d4c52def5064cdaca`. All coordinates are inclusive LF lines
under `lua/src/linkedspec`. Group fourteen covers 1,500 fragments /53,162 bytes,
with ordered-range SHA-256
`d157ca1471a6078386594be0911d4d5e2d56fe29ead9d692ecf0053fec58ed67`.

| File | Lines | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| mcp_contract.lua | 8–8 | 2 | 412ca345ccf75bf9c0806bce695be8de808b79984251a7a54d202cf6101dd451 |
| mcp_contract_runtime.lua | 1–413 | 13699 | 8b8b271ec30763c8505e201f9b377ff8c1557dda43f7b65d6855894c76987bfc |
| mcp_server.lua | 1–854 | 32192 | eeaef4aa61b7dfda007a5a5d0fdce5b02d2c2edf3768635dcfa7012d1f21671a |
| mcp_wire.lua | 1–232 | 7269 | 25667a743b2f629ea90b6753bb48f3b0e4f27a9091d029156856e6d321bc7028 |

The twelve complete untruncated viewing windows are:

- `mcp_contract.lua`: 8–8.
- `mcp_contract_runtime.lua`: 1–150, 151–300, 301–413.
- `mcp_server.lua`: 1–150, 151–300, 301–450, 451–600, 601–750, 751–854.
- `mcp_wire.lua`: 1–150, 151–232.

The generated module, contract runtime and decoded server are now fully read;
the wire suffix remains unread. Cumulative reading is 14/51 groups, 16,651
fragments /716,343 bytes, with 21 complete files and a partial wire module.
Running a complete stdio consumer grants no credit for that unread suffix.

# Comprehension and canonical reconciliation

On module loading, the contract runtime checks the generated bundle digest and typed data,
indexes semantic payloads and returns detached JSON copies. Its schema interpreter
handles local references, types, constants/enums, oneOf/allOf, closed object fields,
required/property-name constraints, array prefixes/items, string scalar/byte limits,
pinned patterns and numeric bounds. Schema matching contains failures through pcall;
public frame/contract helpers retain cloned data and Lua response identity.
Tool-success construction validates semantic response shape, copies structured
content and produces matching canonical text. The copy route inherits the existing
integer formatter defect measured below.

The decoded server retains immutable public objects over weak private state tables.
Budget fields validate portable integers; policy and registration constructors
validate optional fields after whole-table normalization. Production construction
uses the native system module; a separate test seam supplies controlled dependencies.
Registration requires a native semantic index, validates its capabilities, applies
explicit lowering policy, handles expiry/capacity and stores the index with registry
metadata. Shutdown clears both handles and active response state.

Dispatch clones requests, classifies envelopes and methods, validates the named
schema and preserves typed request IDs. Capabilities receive the allowed projection;
queries pass unchanged when their explicitly supplied policy components permit them.
Native response validation and cloning precede tool response construction. Prepared
response state supports cancellation through the separate wire callbacks. Stdio
entry requires caller-owned streams, a distinct optional log and plain options,
then delegates to the wire module.

The wire prefix owns UTF-8 escape and surrogate decoding, strict number token
scanning, JSON-pointer escaping and an explicit container stack. It records numeric
tokens at governed integer paths so later decoding can preserve their lexical kind.
The scope ends inside parse_value; later container completion, integer restoration,
framing and I/O code have not received physical reading credit here.

Canonical retrieval preceded diagnosis: [[lua-native-mcp-server-plan]],
[[lua-mcp-decoded-server]], [[lua-mcp-implementation-admission]] and
[[mcp-2026-07-28-stdio-contract]]. Existing [[variadic-user-function-contract]]
and [[lua-variadic-v2-signature-state]] ground the separate DBINP discussion.
An attempted lua-mcp-strict-stdio.md lookup found no file; Knowledge retrieval
returned the actual existing homes above. No missing-card or runtime claim follows.

# Existing option repair gains MCP constructor children

Both installed hosts accept deployment_policy(false) and registration_options(false)
as protected default objects. Omitted and empty tables are valid; true, zero, string
and json.null table arguments reject with the established plain-table error. False
page/source-detail/budget/lifetime/policy fields also reject, and valid constructor
fields retain their values and identities.

mcp_server.lua lines 142 and 180 replace false with an empty table before validation.
New pending `.2.8.7/.2.8.8` own these two constructor repairs and independent proof
under existing .2.8. The correct nil-only register_index and serve_stdio boundaries
remain compatibility controls. The package-private test dependency defaults require
a separately qualified census if repair scope reaches them. This observation does
not establish a policy elevation, malformed wire acceptance or parser failure.

# Existing integer repair gains a measured MCP copy carrier

On installed PUC5.5.1, `runtime.clone_data` changes already represented integer
9007199254740993 to 9007199254740992. A synthetic graph-list semantic response with
that exact value in record.order passes the current response schema, but its
constructed tool response contains the changed number in both structured content
and decoded text. Caller payload and the retained canonical fixture remain intact.

This follows the encode/decode copy at mcp_contract_runtime.lua 17–23 and the
structured/text response paths at 341–342. Server line 741 uses the same copy helper;
the fresh reproduction exercises the helper and response builder, not an assertion
that a native semantic query produces such an order. Existing `.2.11` and its
independent carrier proof retain this precise domain qualification. Two equally
rounded projections do not prove preservation of the original number.

LuaJIT already represents that input as 9007199254740992; copying retains its
represented value. No additional LuaJIT precision-loss claim follows. The response
uses request ID 42, and the large value rejects as a request ID on both hosts.
The unchanged request-ID domain remains ±9007199254740991. Ordinary represented
integers, fractions, false and Unicode clone controls pass.

# Approved named-argument direction remains parked

The director introduced this through DBINP, then explicitly accepted the assessment.
`docs/tasks/PARSER-AUTHORING-APIS.md` .4 durably owns the approved direction and four
unactivated children: grammar/binding, defaults/definition choices, representation
compatibility and bounded implementation planning. The current reading frontier
continues; approval does not activate syntax or change the portable callable contract.

The accepted first-version direction allows each fixed parameter by position or
name, positions before names, strict unknown/duplicate/collision/missing errors,
once-only caller-scope evaluation in written order, and positional-only rest
collection. Defaults remain a separate design step. Parameter names become public
API: renaming one can break a named call even when positional callers still work.
The proposed worked examples, compatibility obligation and future backend/carrier
proof are in .4. The existing neutral callable checker still passes 3 definitions,
9 calls and 7 invalid definitions; that is current-contract proof, not named-call proof.

# Fresh proof and replay

The unchanged decoded consumer passes 216 and the stdio consumer passes 247
assertions per installed host. The new probe passes 33 valid controls per host;
defect observations are counted separately. Total: 992 assertions. All six managed
native executions completed and their outputs/cleanup were consumed. Admission
registry validation rejects 141 mutations. No declared PUC5.4, full corpus,
six-runtime execution, full CI or repair completion is claimed. All eleven local
repair roots, startup .37.1/.28.7 and startup .3/.4/.5 prerequisites remain.

Executed scratch payload: 3,690 bytes, SHA-256
`ff7d20ed4747b26f8e0189abe305809d90e5e63c21f7afe01e29d4570e441ec1`.
Recreate it exactly, then run both managed hosts:

```bash
bash tools/project_data_run.sh python3 - <<'LUA_MCP_BOUNDARY_14'
from pathlib import Path
path = Path('.linkedspec-data/scratch/lua114/mcp-boundary-proof.lua')
path.parent.mkdir(parents=True, exist_ok=True)
path.write_text('local json = require("linkedspec.json")\nlocal runtime = require("linkedspec.mcp_contract_runtime")\nlocal mcp = require("linkedspec.mcp_server")\nlocal controls = 0\nlocal function check(value, label)\n  assert(value, label)\n  controls = controls + 1\nend\nfor _, row in ipairs({\n  { "deployment_policy", mcp.deployment_policy },\n  { "registration_options", mcp.registration_options },\n}) do\n  local name, constructor = row[1], row[2]\n  check(getmetatable(constructor()) == "protected", name .. " omitted")\n  check(getmetatable(constructor({})) == "protected", name .. " empty")\n  for _, invalid in ipairs({ true, 0, "", json.null }) do\n    local ok, message = pcall(constructor, invalid)\n    check(not ok and tostring(message):find("options must be a plain table", 1, true) ~= nil,\n      name .. " rejects invalid option table")\n  end\n  local ok, result = pcall(constructor, false)\n  assert(ok and getmetatable(result) == "protected", "expected existing false default observation")\n  io.write("OBSERVED ", name, "(false) accepts default options\\n")\nend\nfor _, row in ipairs({\n  { mcp.deployment_policy, { page_max = false } },\n  { mcp.deployment_policy, { source_detail_ceiling = false } },\n  { mcp.deployment_policy, { budget_maxima = false } },\n  { mcp.registration_options, { lifetime_ms = false } },\n  { mcp.registration_options, { policy = false } },\n}) do\n  check(not pcall(row[1], row[2]), "false field still rejected")\nend\nlocal limits = mcp.budget_limits({ max_records = 0, max_relations = 1, max_depth = 2 })\nlocal policy = mcp.deployment_policy({ page_max = 1, budget_maxima = limits })\nlocal registration = mcp.registration_options({ lifetime_ms = 1, policy = policy })\ncheck(policy.page_max == 1 and policy.budget_maxima == limits, "valid policy retained")\ncheck(registration.lifetime_ms == 1 and registration.policy == policy, "valid registration retained")\nfor _, value in ipairs({ 0, 1, -1, 9007199254740991, 1.5, false, "é" }) do\n  check(runtime.clone_data(value) == value, "exact ordinary clone")\nend\nlocal value = json.decode("9007199254740993")\nlocal is_exact_integer = math.type ~= nil and math.type(value) == "integer"\nlocal payload = runtime.payload("graph_list_rules")\npayload.records[1].order = value\ncheck(runtime.validate_named("semanticQueryResponse", payload), "synthetic payload fits current schema")\nlocal response = runtime.tool_success_response(42, payload)\ncheck(runtime.validate_frame(response), "response remains schema valid")\ncheck(response.id == 42, "request id remains in its existing domain")\ncheck(not runtime.validate_named("requestId", value), "wide integer is outside request id domain")\nlocal copied = runtime.clone_data(value)\nlocal structured = response.result.structuredContent.records[1].order\nlocal text_value = json.decode(response.result.content[1].text).records[1].order\ncheck(structured == copied and text_value == copied, "text and structured projections agree")\nif is_exact_integer then\n  assert(tostring(value) == "9007199254740993")\n  assert(tostring(copied) == "9007199254740992" and copied ~= value)\n  io.write("OBSERVED exact PUC integer changes in clone and synthetic semantic response: ",\n    tostring(value), " -> ", tostring(copied), "\\n")\nelse\n  assert(copied == value)\n  io.write("QUALIFIED host input already represented as ", runtime.canonical_json(value),\n    "; clone preserves that represented value\\n")\nend\ncheck(payload.records[1].order == value, "caller payload not mutated")\nlocal detached = runtime.payload("graph_list_rules")\ncheck(detached.records[1].order == 0, "canonical fixture remains detached")\nio.write("PASS ", tostring(controls), " valid MCP boundary controls; defect observations counted separately\\n")\n')
LUA_MCP_BOUNDARY_14
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua114/mcp-boundary-proof.lua
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua114/mcp-boundary-proof.lua
```

The source/range audit, independent completed-node total, prior evidence/repair
preservation, memory, Knowledge, both histories, rendered book and normal doctrine
hooks govern landing. The proposed design adds no implementation or extra capacity
approval; the actual candidate remains subject to ADR0118's existing controls.

The activation comparison preserves 1,388 prior source/Knowledge/decision/history
and selected policy files byte-for-byte, 2,465 prior task nodes, all 63 prior Known
headings, exact history suffixes and the live-history query section. Seven existing
nodes change only within the reading, repair-extension and proposal-parent scope;
new nodes are two pending MCP repair/proof children and five proposed named-call
parent/design nodes. Memory remains 60 lines; history roots are 312 and 459 lines.
The book renders; its existing search-index warning remains owned by startup .41.9.
