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
status: decoded server and strict stdio implemented, exactly admitted, and parent-closed
tags: [julia, mcp, semantic-introspection, embedding, handles, security, generated-data]
evidence: julia/src/mcp/McpContract.jl; julia/src/mcp/McpContractRuntime.jl; julia/src/mcp/McpServer.jl; julia/src/mcp/McpWire.jl; julia/src/LinkedSpecJulia.jl; julia/test/mcp_contract_julia_binding_test.jl; julia/test/mcp_server_julia_dispatch_test.jl; julia/test/mcp_server_julia_stdio_test.jl; tools/generate_julia_mcp_contract.py; capability_conformance/mcp_implementation_admission.json
reverify: "bash tools/run_python_project_data.sh tools/generate_julia_mcp_contract.py && bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, Test; const REPO_ROOT=pwd(); include(\"julia/test/mcp_contract_julia_binding_test.jl\"); include(\"julia/test/mcp_server_julia_dispatch_test.jl\"); include(\"julia/test/mcp_server_julia_stdio_test.jl\")' && bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py"
---

# Julia Decoded MCP Server

`FUTURE-PARITY-BACKLOG.10.9.5.1` implements the public Julia `McpServer`. A host creates an immutable
`SemanticIndex`, registers that exact value with 1–4,096 copied opaque authorization bytes and optional lower-only
limits, then passes already-decoded JSON-like requests to `dispatch_mcp`. The server invokes only fresh
`semantic_capabilities(index)` and `semantic_query_neutral(index, request)` plus detached `to_json`; it cannot
load source or paths, compile or execute, enable trace, open a file, start a process, use a socket, or retain a
semantic response cache.

`tools/generate_julia_mcp_contract.py` renders the Base64-only `McpContract.jl` from the same
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

Focused decoded proof covers the generated digest and clone boundary, the exact frozen schema profile, all canonical
decoded classifications, native payload identity, lower-only policy, authorization isolation, expiry, revocation,
capacity, entropy/clock/collision failure, cancellation, sanitation, shutdown, opacity, and production authority
fences at 48 + 139 assertions. Strict byte/token/framing behavior and public `serve_mcp_stdio!` are now implemented
by `.10.9.5.2` at 170 further assertions. Exact twelve-role admission `.3` alone may move Julia to 4/5
implementations and 4/6 runtimes; that admission and unchanged parent closeout are now complete. Shared Lua and
recurring leaves subsequently complete the formal 5/5 implementation + 6/6 runtime rollout.

Related facts: [[julia-native-mcp-server-plan]], [[julia-mcp-strict-stdio]], [[julia-semantic-query-public-api]],
[[mcp-2026-07-28-stdio-contract]], [[mcp-native-server-topology]], and
[[mcp-implementation-admission-ledger]].

September 11 `JULIA-STARTUP-READING.1.8` reads generated `McpContract.jl:1-372`, including
format 1, the canonical bundle digest and encoded frame/schema literals. The unchanged generator's
check-only mode confirms 120,030 current source bytes are byte-fresh; the old 119,538 count belongs
to the earlier admission. Existing binding/runtime tests pass 53 assertions, including clone isolation,
canonical frame classification, schema closure and recursive JSON ordering. The owning suffix and
runtime/server physical reading remain pending; these finite tests grant no additional reading or
server signoff credit. Exact replay lives in [[julia-controlled-corpus-execution]].

```bash
bash tools/run_python_project_data.sh tools/generate_julia_mcp_contract.py
```

September 11 `.1.9` extends physical binding reading through line 1002. The neutral checker
passes 35 canonical frames (28 accepted /7 rejected), 10 raw inputs, 10 lifecycle cases and 76 rejected
mutations; the existing Julia binding suite passes 53. Independent decoding confirms an 82,882-byte
UTF-8 bundle, 35 canonical frame entries and 48 schema definitions, with SHA-256
`a1d2857c57ef93ea0e62403977105fdf6380f6fcb4d7a89ed5749c1bfdd64001`.
Whole-bundle mechanical proof does not imply physical reading of its remaining generated suffix.

```bash
bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_GROUP9_BINDING'
using LinkedSpecJulia, Test
const REPO_ROOT=pwd()
include("julia/test/mcp_contract_julia_binding_test.jl")
JULIA_GROUP9_BINDING
bash tools/project_data_run.sh python3 - <<'PY_MCP_DECODE9'
from pathlib import Path
import re,base64,hashlib,json
s=Path('julia/src/mcp/McpContract.jl').read_text()
payload=re.search(r'const _MCP_BUNDLE_BASE64 = string\(\n(.*?)\n\)',s,re.S).group(1)
raw=base64.b64decode(''.join(re.findall(r'"([A-Za-z0-9+/=]+)"',payload)),validate=True)
expected=re.search(r'_MCP_BUNDLE_SHA256 = "([0-9a-f]+)"',s).group(1)
assert hashlib.sha256(raw).hexdigest()==expected
bundle=json.loads(raw)
assert len(raw)==82882 and len(bundle['canonical_frames'])==35 and len(bundle['schema']['$defs'])==48
print('PASS current generated MCP bundle identity and shape:',len(raw),expected)
PY_MCP_DECODE9
```

## September 11 executable consumer reading

Julia .1.10 fully reads `julia/src/mcp/McpContractRuntime.jl` and
`julia/src/mcp/McpServer.jl`. Runtime loading digest-checks the embedded bundle;
JSON cloning rejects cycles, nonfinite numbers and duplicate normalized keys.
Host registration copies authorization into a digest and binds random opaque
handles to native immutable indexes, monotonic expiry and lower-only limits.
Preparation, active-request cancellation and shutdown preserve separate lifecycles.
Existing binding53/dispatch145/stdio170 pass (368 assertions). The check-only
generator remains120030 bytes and neutral transport35/10/10/76 passes.
Targeted pattern20 and precedence12 probes identify uncovered boundaries; exact
replay and repair ownership live in `docs/knowledge/julia-mcp-pattern-terminal-newline-gap.md`
and `docs/knowledge/perl-mcp-validation-error-order-drift.md`. Neither defect is closed.
2026-09-11 Julia .1.37 exact reading and focused replay: `docs/tasks/JULIA-STARTUP-READING.md`, section `Reading evidence .1.37`.
