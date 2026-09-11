---
id: julia-mcp-pattern-terminal-newline-gap
title: Julia MCP schema patterns accept a forbidden trailing newline
answers:
  - does Julia MCP reject a handle with a trailing newline
  - why does Julia return handle unavailable instead of invalid params for a malformed MCP handle
  - do Julia MCP handle and digest patterns use complete matching
  - which repair owns Julia MCP pattern terminal newline handling
date: 2026-09-11
status: confirmed-open; repair owned by JULIA-STARTUP-READING.2.4
tags: [julia, mcp, schema, patterns, validation, startup]
evidence: "JULIA-STARTUP-READING.1.10 reads McpContractRuntime and McpServer. Native/public20 assertions show a trailing LF passes handle/sourceReference digest patterns; decoded and stdio malformed-handle responses are handle_unavailable. Eight neutral SchemaRuntime outcomes reject every nonempty suffix. Existing binding53/dispatch145/stdio170 pass without covering the gap."
reverify: "Run the managed native and neutral replay blocks below."
---

# Exact mechanism and repair ownership

Activation: `9431f6c8aeac4b95933c3683b5fa77bf5054acb0`.
`julia/src/mcp/McpContractRuntime.jl:6-7` defines dollar-anchored handle/digest expressions;
its string validator at 227 dispatches them through `occursin` at 238/240. Those matches
accept the otherwise valid string before one final LF. The independent neutral schema
runtime at `tools/check_mcp_semantic_transport_contract.py:380` uses `re.fullmatch`
and rejects that suffix. Perl's schema runtime also adds absolute start/end boundaries.

The host validator at `julia/src/mcp/McpServer.jl:564` separately checks exact handle length, so it
rejects the malformed string. Public tool dispatch at 355 relies on the schema validator
before lookup and therefore returns `linkedspec_mcp_handle_unavailable` for this malformed
input; exact invalid syntax should produce JSON-RPC `-32602`. The decoded and stdio
routes produce equal complete responses. Both use an empty server and caller-owned IO.
The digest observation is a direct `sourceReference` schema result, not a demonstrated
native semantic producer emitting a malformed digest.

| Suffix after an otherwise valid value | Julia schema handle/digest | Host handle syntax | Neutral handle/digest |
| --- | --- | --- | --- |
| Empty | Accept | Accept | Accept |
| LF | Accept | Reject | Reject |
| CRLF | Reject | Reject | Reject |
| Extra ASCII character | Reject | Reject | Reject |

Repair `.2.4.1` owns complete matching and RED/GREEN controls; `.2.4.2` owns public
route recurrence and exact claims. Startup `.3/.4/.5` remain prerequisites. The six
competing metadata errors are separately owned by startup `.36`; no new duplicate
precedence owner is created. Existing Julia MCP suites pass 53/145/170 (368 assertions),
which preserves their finite evidence without closing this uncovered boundary.

# Native and public reproduction

These assertions lock the observed defect for diagnosis, not desired repaired behavior.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_MCP_PATTERN_PROBE'
using LinkedSpecJulia, JSON3, Test
const auth=UInt8[0x61]
@testset "MCP trailing newline pattern diagnostic" begin
 server=McpServer()
 for (suffix,pattern_ok,expected) in [("",true,"unavailable"),("\n",true,"unavailable"),("\r\n",false,"invalid"),("X",false,"invalid")]
  handle=repeat("A",43)*suffix
  @test LinkedSpecJulia._mcp_validate_named("handle",handle)==pattern_ok
  @test LinkedSpecJulia._mcp_valid_handle(handle)==isempty(suffix)
  req=LinkedSpecJulia._mcp_frame("capabilities_call_request");req["params"]["arguments"]["handle"]=handle
  result=dispatch_mcp(server,req,auth)
  category=haskey(result,"error") ? "invalid" : "unavailable"
  @test category==expected
  wire=McpServer();out=IOBuffer()
  serve_mcp_stdio!(wire,IOBuffer(JSON3.write(req)*"\n"),out,auth)
  @test JSON3.read(String(take!(out)),Dict{String,Any})==result
  println(JSON3.write(Dict("suffix"=>suffix,"schema"=>pattern_ok,"host"=>LinkedSpecJulia._mcp_valid_handle(handle),"result"=>result)))
 end
 shutdown_mcp!(server)
 for (suffix,expected) in [("",true),("\n",true),("\r\n",false),("x",false)]
  source=Dict{String,Any}("content_digest"=>"sha256:"*repeat("a",64)*suffix,"excerpt"=>nothing,"logical_name"=>nothing,"provenance_ids"=>Any[],"source_id"=>nothing,"span"=>nothing)
  @test LinkedSpecJulia._mcp_validate_named("sourceReference",source)==expected
 end
end
JULIA_MCP_PATTERN_PROBE
```

# Independent frozen-validator comparison

```bash
bash tools/project_data_run.sh python3 - <<'PY_MCP_PATTERN_NEUTRAL'
import sys,json
from pathlib import Path
sys.path.insert(0,'tools')
from check_mcp_semantic_transport_contract import SchemaRuntime
schema=json.loads(Path('capability_conformance/mcp_semantic_transport/schema.json').read_text())
runtime=SchemaRuntime(schema)
for suffix in ['', '\n', '\r\n', 'X']:
 handle='A'*43+suffix
 source={'content_digest':'sha256:'+'a'*64+suffix,'excerpt':None,'logical_name':None,'provenance_ids':[],'source_id':None,'span':None}
 actual=[runtime.matches(handle,schema['$defs']['handle']),runtime.matches(source,schema['$defs']['sourceReference'])]
 assert actual==[not suffix,not suffix]
 print(json.dumps({'suffix':suffix,'neutral_handle':actual[0],'neutral_source_reference':actual[1]}))
print('PASS eight exact neutral pattern outcomes')
PY_MCP_PATTERN_NEUTRAL
```
