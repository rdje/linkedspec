---
id: lua-staged-completion-reading-and-boundary-gaps
title: Lua staged completion reading identifies diagnostic, marker and capture admission gaps
answers:
  - "what exact Lua source did startup reading child 24 cover"
  - "can Lua staged diagnostics exceed max_diagnostic_bytes"
  - "does Lua reject exhausted staged call counts before incrementing"
  - "does Lua staged total_calls reject false"
  - "does Lua marker detachment reject cycles within bounded traversal"
  - "does Lua marker detachment preserve JSON null"
  - "why can Lua staged execution seeds accept malformed snapshot arrays"
  - "does Lua private capture provenance validate finite ordered ranges"
  - "which tasks own Lua staged diagnostic marker and capture repairs"
date: 2026-09-13
status: exact reading complete; three new repair roots and earlier extensions remain pending
tags: [lua, startup, staged-parsing, diagnostics, detachment, provenance, validation]
evidence: "LUA-STARTUP-READING.1.24; clean activation 8469d5ba11c56cc91e0d86b9b586feb68502f9ca. Three exact ranges /1500 fragments /56196 bytes in nine complete windows. Existing staged consumers pass 890 per installed host, 1780 total. Independent checks retain 102 complete observations, including the sparse-seed host difference and bounded marker traversal. .2.26 owns diagnostic bytes, .2.27 marker cycle/null handling, .2.28 capture admission; .2.8.15/.16 and .2.25 retain seeded-count and copy-before-validation extensions. Source remains unchanged."
reverify:
  - "Run LUA_STAGED_COMPLETION_READING_24 and the managed commands below; the independent verifier pins measured pre-repair behavior."
  - "bash tools/run_lua_project_data.sh puc lua/test/staged_ast_enrichment_contract_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/staged_ast_enrichment_contract_test.lua"
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py"
---

# Exact coverage and comprehension

Source baseline `baeb984e36a94a15951cd23d4c52def5064cdaca` remains unchanged.
The group contains 1,500 fragments /56,196 bytes with ordered SHA-256
`38f96a914d93193a8d3ebc02f24a4d806a12e36450859cc822bcec446daf5b82`.

| Repo-root source | Inclusive lines | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| `lua/src/linkedspec/staged_ast_enrichment.lua` | 779–2187 | 53155 | `f6a62f6047e45dd37cd2a31d97496f4f27820c3bb64b221732581a202aa0fc7d` |
| `lua/src/linkedspec/staged_capture_provenance.lua` | 1–42 | 1431 | `6242562c7f0031280944ec3b1caa5bb6df62972fb149a6538291fb2ab233ee97` |
| `lua/src/linkedspec/staged_parse_job.lua` | 1–49 | 1610 | `adfc54a19c396a70fb99b4947e3ff7e3d56ba72033454d19c2f6cc99769e22af` |

The nine complete windows are staged 779–978, 979–1178, 1179–1378, 1379–1578,
1579–1778, 1779–1978, 1979–2187; capture 1–42; declaration 1–49. Prior diagnostic
reads of the staged suffix grant no extra credit. Cumulative reading is 24/51,
31,651 fragments /1,234,956 bytes, with 43 complete files and the declaration
module partial. Its diagnostic read 175–218 grants no advance child 25 credit.

The staged suffix completes typed ordering, exact option parsing, marker discovery,
selected-top identities and frozen-plan preparation. Full-depth target reservation
checks prevent incompatible writes before callbacks. Four stitch policies operate
on an unpublished copy. Ordinary detachment validates finite acyclic plain data;
marker-specific handling keeps the existing atomic-node accounting. Callback
results/failures are represented separately from plans and caches.

Direct and ordered-derived provenance validate exact scalar extents, constrain
same-parser recurrence to strictly smaller contained segments, and rebase positions,
spans and diagnostic fields. Exact lineage tuples reject recurrence cycles.
Recursive dispatch shares steps, calls, result nodes and diagnostic bytes across
breadth-first depths; safe points observe per-job and invocation limits plus
cancellation/deadline. Context views expire after callbacks. Only successful
returned markers enter the next queue through the actual stitch destination.
The engine does not rescan the full stitched AST for old markers.

Host execution seeds copy logical snapshot/options and construct fresh registry,
callbacks, cache and invocation state after parent completion. Transaction-active
or reused execution states reject. The one-depth entrypoint remains separate.
Private capture storage uses weak match keys and copied endpoint pairs, without
adding public range fields. The declaration prefix sets up typed provenance
errors and source-authority imports; later materialization code remains child 25.

Retrieved [[lua-staged-ast-enrichment-recursive-carriers]], the prior marker and
current-depth cards, [[dart-staged-resource-boundary-gaps]],
[[julia-staged-diagnostic-byte-boundaries]],
[[julia-staged-result-isolation-test-gap]] and
[[lua-validator-staged-prefix-reading-and-array-gaps]] before relevant diagnostics.
The Julia isolation card describes a distinct test gap; this slice does not
retest Julia or infer a Lua returned-result aliasing defect. Existing dated
888-assertion evidence remains historical; fresh Lua consumers report 890 each.

# Diagnostic bytes and correctly guarded call exhaustion

`bounded_diagnostic` at staged 1790–1806 measures the complete diagnostic, substitutes
a truncation sentinel if oversized, measures that sentinel and returns it without
a second ceiling decision. The remaining byte counter clamps at zero.

| Allowance | Failures | Retained diagnostic bytes | Remaining |
| ---: | ---: | --- | ---: |
| 0 | 1 | rejected before callback | unavailable |
| 1 | 1 | 187 | 0 |
| 64 | 1 | 188 | 0 |
| 256 | 1 | 189 | 67 |
| 4096 | 1 | 1671 | 2425 |
| 64 | 2 | 188 +187 =375 | 0 |
| 4096 | 2 | 1671 +1671 =3342 | 754 |

The independent measurement uses canonical compact UTF-8 JSON per retained record,
excluding list wrappers and duplicate sidecar copies. Even this narrower count
exceeds three allowances. The second 64-byte sibling's sentinel reports
maximum_bytes 0. Parent ASTs retain original text, and sidecars retain the same
measured diagnostics. `.2.26.1-.3` own shared accounting reconciliation, implementation
and independent carrier proof, coordinated with Dart `.2.17.1` and Julia `.2.14`.
The shared Dart decision owner now references this separate Lua confirmation;
earlier backend evidence remains unchanged.

Lua's call admission at line 1779 checks the current count before incrementing. At
31/32 and maximum-minus-one/maximum it dispatches once and reaches the ceiling.
At 32/32 and maximum/maximum it dispatches zero callbacks and raises the exact
staged_call_limit_exceeded record. Here maximum is 9,007,199,254,740,991, the
module's exact-integer bound, not the larger native signed integer limit. The
maximum diagnostic saturates its candidate count without admitting work.
This positive result does not close the separate Dart/Rust call-count repairs.

The constructor's `config.total_calls or 0` at line 1462 still replaces explicit false
with zero. Absent/zero/one produce 0/0/1; true/fraction/text reject the total_calls
snapshot diagnostic. `.2.8.15/.16` own absent-only constructor defaulting and
independent seed/exhaustion proof. This is distinct from dispatch arithmetic.

# Marker traversal and snapshot-copy boundaries

The marker-specific `reject_live_keys` at line 1187 recurses before the ordinary walk's
active-table guard and before `copy_plain` performs its own cycle check. Two tiny
host-created root/nested cycles inside marker-shaped values reach the probe's
10,000-instruction guard. The ordinary cyclic object rejects with nodes 2 and
reason `<result>/loop` before that guard. No unbounded execution is run.
The isolated detachment probe disables LuaJIT compilation and restores its debug
hook after every case; this instrumentation establishes bounded traversal evidence,
not an uninstrumented timeout, process crash or authored parser loop.

A marker extension containing json.null rejects at `<result>/extension` because
this sentinel is a tagged table and the marker recursion treats it as a container.
An ordinary object containing null survives; marker false, ordinary valid marker
and finite acyclic extended marker controls pass. Function-valued marker content
correctly rejects. A marker with 100 finite extra array elements still counts as
one atomic node under a one-node allowance, consistent with the existing private
staged design; no new node-accounting defect is inferred. Arbitrary host marker
extensions are not thereby admitted as valid authored declaration options.

`.2.27.1/.2` own cycle-aware traversal and null preservation, with independent
proof `.2.27.3`. Parent/child and supported-carrier reachability remain for that
proof; these cases establish private detachment behavior only.

`execution_seed` at line 2072 copies snapshot data before the normal frozen-registry
validation. A malformed aliases array with an extra false member rejects when
frozen directly but is copied away and accepted as a seed on both hosts. A sparse
fourth member after two dense entries has host length 2 on PUC and 4 on LuaJIT:
PUC drops it and accepts; LuaJIT retains a malformed copy horizon and rejects.
Both direct freezes reject. The probe records original member counts and length
and executes no factory. Existing `.2.25` owns complete classification before
copying; this is an additional consumer of the same omission, not a new runtime
resolution or hashing defect.

# Private capture-range admission

The endpoint check at staged_capture_provenance.lua:16 accepts any number, and `ipairs`
copies only a dense prefix. Direct host calls therefore retain negative/reversed/
fractional endpoints and infinities/NaN, while string/false endpoints reject.
Extra named range members and a sparse third pair disappear. Copies remain detached:
mutating the original first start from 0 to 8 leaves both stored/copied starts 0.
The index predicate at line 33 rejects negative/fraction/string/false but accepts infinity
as an absent entry. Non-finite observations are explicitly encoded as strings
in the probe so measurement does not invoke the known JSON non-finite error.

Native matching.lua:210 supplies PCRE endpoint pairs and matching.lua:228 copies existing
provenance. Staged declaration line 187 retrieves them, then lines 193–217 converts both
endpoints through typed source authority and constructs an ordered span before
materializing text. The new host-input probes do not establish invalid native
PCRE output, ordinary spec reachability or a materialized-source consequence.
`.2.28.1` first owns the producer/consumer invariant census; `.2.28.2/.3` then own
validated private storage and independent provenance/carrier proof. Source-length
and UTF-8 ownership stay with the typed-source layer.

# Proof scope and exact replay

Fresh staged consumers pass 890 assertions per installed host, 1,780 total.
The separate 102 observations contain 18 resource/count, 15 detachment/seed and 18
capture cases per host. Full resource and capture outputs agree across hosts;
the sparse-seed difference is retained and explained by measured host lengths.
The independent verifier pins retained byte sizes, counter values, error records,
parent results, sidecars, callback counts, markers and copied endpoint controls.

The initial resource labels used host tostring, which formatted large numbers
differently despite equal exact numeric fields. The probe now uses stable decimal
labels and reruns both complete resource payloads. Seed probes were also rerun on
both hosts after adding the original array length/member census. The marker guard
is consumed by the expected protected call; all processes finish with exit 0.

Staged governance passes 9 complete legs, 123 semantic and 129 public mutations;
typed-source governance passes 14 complete/0 pending and 231 mutations. These are
neutral contract/topology checks, not additional runtime assertions. Existing
PUC 5.5 nil-error failures, declared-PUC 5.4 prerequisites, selector .28.7, earlier
repairs, build reuse and later full CI/push requirements remain open. No production,
test, contract or dependency source changes here.

```bash
bash tools/project_data_run.sh python3 - <<'LUA_STAGED_COMPLETION_READING_24'
from pathlib import Path
p=Path('.linkedspec-data/scratch/lua124'); p.mkdir(parents=True,exist_ok=True)
(p/'resources.lua').write_text('local json=require("linkedspec.json")\nlocal staged_ast_enrichment=require("linkedspec.staged_ast_enrichment")\nlocal function read(path)local f=assert(io.open(path,"rb"));local s=f:read("*a");f:close();return s end\nlocal contract=json.decode(read("capability_conformance/staged_ast_enrichment_contract.json"))\nlocal rows=json.array()\nlocal function observe(kind,name,fn)\n local ok,value=pcall(fn);local row=json.harray({kind=kind,case=name,ok=ok})\n if ok then row.value=value==nil and json.null or value\n elseif staged_ast_enrichment.is_error(value) then row.error=staged_ast_enrichment.to_json(value)\n else row.error=tostring(value) end\n rows[#rows+1]=row;return row\nend\nlocal function enrichment_options()\n  return json.harray({\n    declaring_spec_id = "grammar/main.spec",\n    caller_capabilities = json.array({\n      "staged-parse-job-v2",\n      "structured-result-v1",\n      "typed-source-location-v1",\n      "xml-v1",\n      "yaml-v1",\n    }),\n    caller_policy_modes = json.array({\n      "append_child",\n      "diagnostic_node",\n      "fail",\n      "keep_text",\n      "replace_field",\n      "replace_marker",\n      "sibling_field",\n      "trace",\n    }),\n    caller_ceilings = json.harray({\n      source_detail = "text",\n      max_steps = 200,\n      max_result_nodes = 128,\n      max_diagnostic_bytes = 8192,\n    }),\n    required_source_detail = "identity",\n    required_versions = json.harray({\n      spec_language_version = 2,\n      helper_contract_version = "actionir-v3",\n      staged_contract_version = 2,\n    }),\n  })\nend\n\nlocal function enrichment_marker(text, start_offset, result_policy, into, failure_policy, top_rule)\n  local sidecar = json.harray({\n    kind = "staged_parse_job_v2",\n    version = 2,\n    state = "declared",\n    effect = "staged_parse_job_declaration",\n    node_kind = "expression",\n    payload_kind = "embedded_expression",\n    parser_spec_id = "expr",\n    result_policy = result_policy,\n    failure_policy = failure_policy,\n    required_capabilities = json.array({ "typed-source-location-v1" }),\n    text = text,\n    provenance = json.harray({\n      kind = "direct_span",\n      source_id = "ascii",\n      start = start_offset,\n      ["end"] = start_offset + #text,\n      provenance = "capture",\n    }),\n    origin = "contract:parse_job",\n  })\n  if top_rule ~= false then sidecar.top_rule = top_rule or "Expr" end\n  if into ~= nil and into ~= json.null then sidecar.into = into end\n  return json.harray({\n    kind = "STAGED_PARSE_JOB_MARKER",\n    version = 2,\n    sidecar_kind = "staged_parse_job_v2",\n    effect = "staged_parse_job_declaration",\n    staged_parse_job_v2 = sidecar,\n  })\nend\n\nlocal function enrichment_callbacks(callback, snapshot)\n  snapshot = snapshot or contract.resolution_snapshot\n  local result = {}\n  for _, entry in ipairs(snapshot.entries) do result[entry.compiled_authority] = callback end\n  return result\nend\n\nlocal function enrichment_registry(callback, snapshot, callbacks)\n  snapshot = snapshot or contract.resolution_snapshot\n  return staged_ast_enrichment.freeze_registry(\n    snapshot,\n    callbacks or enrichment_callbacks(callback, snapshot)\n  )\nend\n\nlocal function recursive_authority(options)\n  options = options or {}\n  local config = json.harray({\n    cancellation_token = options.token or "cancel:open",\n    deadline = options.deadline or 100,\n    remaining_steps = options.remaining_steps == nil and 20 or options.remaining_steps,\n    required_steps = options.required_steps == nil and 1 or options.required_steps,\n    max_depth = options.max_depth or 4,\n    max_calls = options.max_calls or 10,\n  })\n  if options.total_calls ~= nil then config.total_calls = options.total_calls end\n  return staged_ast_enrichment.recursive_authority(\n    config,\n    options.cancelled or function() return false end,\n    options.clock or function() return 1 end\n  )\nend\n\nfor _,case in ipairs({{0,1},{1,1},{64,1},{256,1},{4096,1},{64,2},{4096,2}})do\n local ceiling,count=case[1],case[2];local calls=0\n local registry=enrichment_registry(function()calls=calls+1;return staged_ast_enrichment.child_failure(json.harray({code="large_child_failure",detail=string.rep("x",1024)}))end)\n local parent=json.harray({nodes=json.array()})\n for i=1,count do parent.nodes[i]=enrichment_marker("x",i-1,"replace_marker",nil,"keep_text")end\n local options=enrichment_options();options.caller_ceilings.max_diagnostic_bytes=ceiling\n local row=observe("diagnostic",tostring(ceiling).."/"..tostring(count),function()return staged_ast_enrichment.enrich_recursively(registry,parent,options,recursive_authority())end)\n row.callbacks=calls\n if row.ok then\n  row.sizes=json.array();row.retained_bytes=0\n  for i,d in ipairs(row.value.diagnostics)do local n=#json.encode(d);row.sizes[i]=n;row.retained_bytes=row.retained_bytes+n end\n end\nend\nlocal maximum=9007199254740991\nfor _,case in ipairs({{31,32},{32,32},{maximum-1,maximum},{maximum,maximum}})do\n local initial,cap=case[1],case[2];local calls=0\n local registry=enrichment_registry(function()calls=calls+1;return staged_ast_enrichment.child_success("ok")end)\n local row=observe("calls",string.format("%.0f/%.0f",initial,cap),function()return staged_ast_enrichment.enrich_recursively(registry,json.harray({payload=enrichment_marker("x",0,"replace_marker",nil,"fail")}),enrichment_options(),recursive_authority({total_calls=initial,max_calls=cap}))end)\n row.initial=initial;row.maximum=cap;row.callbacks=calls\nend\nfor _,case in ipairs({{"absent"},{"zero",0},{"one",1},{"false",false},{"true",true},{"fraction",1.5},{"text","1"}})do\n observe("initial_calls",case[1],function()\n  local a=recursive_authority({total_calls=case[2]})\n  return staged_ast_enrichment.enrich_recursively(enrichment_registry(function()error("unexpected callback")end),json.harray(),enrichment_options(),a).resources\n end)\nend\nio.write(json.encode(rows),"\\n")\n')
(p/'detachment.lua').write_text('local json=require("linkedspec.json")\nlocal staged_ast_enrichment=require("linkedspec.staged_ast_enrichment")\nlocal function read(path)local f=assert(io.open(path,"rb"));local s=f:read("*a");f:close();return s end\nlocal contract=json.decode(read("capability_conformance/staged_ast_enrichment_contract.json"))\nlocal rows=json.array()\nlocal function observe(kind,name,fn)\n local ok,value=pcall(fn);local row=json.harray({kind=kind,case=name,ok=ok})\n if ok then row.value=value==nil and json.null or value\n elseif staged_ast_enrichment.is_error(value) then row.error=staged_ast_enrichment.to_json(value)\n else row.error=tostring(value) end\n rows[#rows+1]=row;return row\nend\nlocal function enrichment_options()\n  return json.harray({\n    declaring_spec_id = "grammar/main.spec",\n    caller_capabilities = json.array({\n      "staged-parse-job-v2",\n      "structured-result-v1",\n      "typed-source-location-v1",\n      "xml-v1",\n      "yaml-v1",\n    }),\n    caller_policy_modes = json.array({\n      "append_child",\n      "diagnostic_node",\n      "fail",\n      "keep_text",\n      "replace_field",\n      "replace_marker",\n      "sibling_field",\n      "trace",\n    }),\n    caller_ceilings = json.harray({\n      source_detail = "text",\n      max_steps = 200,\n      max_result_nodes = 128,\n      max_diagnostic_bytes = 8192,\n    }),\n    required_source_detail = "identity",\n    required_versions = json.harray({\n      spec_language_version = 2,\n      helper_contract_version = "actionir-v3",\n      staged_contract_version = 2,\n    }),\n  })\nend\n\nlocal function enrichment_marker(text, start_offset, result_policy, into, failure_policy, top_rule)\n  local sidecar = json.harray({\n    kind = "staged_parse_job_v2",\n    version = 2,\n    state = "declared",\n    effect = "staged_parse_job_declaration",\n    node_kind = "expression",\n    payload_kind = "embedded_expression",\n    parser_spec_id = "expr",\n    result_policy = result_policy,\n    failure_policy = failure_policy,\n    required_capabilities = json.array({ "typed-source-location-v1" }),\n    text = text,\n    provenance = json.harray({\n      kind = "direct_span",\n      source_id = "ascii",\n      start = start_offset,\n      ["end"] = start_offset + #text,\n      provenance = "capture",\n    }),\n    origin = "contract:parse_job",\n  })\n  if top_rule ~= false then sidecar.top_rule = top_rule or "Expr" end\n  if into ~= nil and into ~= json.null then sidecar.into = into end\n  return json.harray({\n    kind = "STAGED_PARSE_JOB_MARKER",\n    version = 2,\n    sidecar_kind = "staged_parse_job_v2",\n    effect = "staged_parse_job_declaration",\n    staged_parse_job_v2 = sidecar,\n  })\nend\n\nlocal function enrichment_callbacks(callback, snapshot)\n  snapshot = snapshot or contract.resolution_snapshot\n  local result = {}\n  for _, entry in ipairs(snapshot.entries) do result[entry.compiled_authority] = callback end\n  return result\nend\n\nlocal function enrichment_registry(callback, snapshot, callbacks)\n  snapshot = snapshot or contract.resolution_snapshot\n  return staged_ast_enrichment.freeze_registry(\n    snapshot,\n    callbacks or enrichment_callbacks(callback, snapshot)\n  )\nend\n\nlocal function recursive_authority(options)\n  options = options or {}\n  local config = json.harray({\n    cancellation_token = options.token or "cancel:open",\n    deadline = options.deadline or 100,\n    remaining_steps = options.remaining_steps == nil and 20 or options.remaining_steps,\n    required_steps = options.required_steps == nil and 1 or options.required_steps,\n    max_depth = options.max_depth or 4,\n    max_calls = options.max_calls or 10,\n  })\n  if options.total_calls ~= nil then config.total_calls = options.total_calls end\n  return staged_ast_enrichment.recursive_authority(\n    config,\n    options.cancelled or function() return false end,\n    options.clock or function() return 1 end\n  )\nend\n\n-- The instruction guard bounds deliberately cyclic host input in this diagnostic only.\nif jit then jit.off() end\nlocal variants={\n {"plain_cycle",function()local t=json.harray();t.loop=t;return t end},\n {"marker_cycle",function()local t=enrichment_marker("x",0,"replace_marker",nil,"fail");t.loop=t;return t end},\n {"nested_marker_cycle",function()local t=enrichment_marker("x",0,"replace_marker",nil,"fail");local c=json.harray();c.loop=c;t.extension=c;return t end},\n {"marker_null",function()local t=enrichment_marker("x",0,"replace_marker",nil,"fail");t.extension=json.null;return t end},\n {"marker_false",function()local t=enrichment_marker("x",0,"replace_marker",nil,"fail");t.extension=false;return t end},\n {"marker_valid",function()return enrichment_marker("x",0,"replace_marker",nil,"fail")end},\n {"marker_function",function()local t=enrichment_marker("x",0,"replace_marker",nil,"fail");t.extension=function()end;return t end},\n {"marker_atomic",function()local t=enrichment_marker("x",0,"replace_marker",nil,"fail");t.extension=json.array();for i=1,100 do t.extension[i]=i end;return t end,1},\n {"plain_null",function()return json.harray({extension=json.null})end},\n}\nfor _,case in ipairs(variants)do\n local input=case[2]();local ticks=0;local guarded=false\n debug.sethook(function()ticks=ticks+1;if ticks>=100 then guarded=true;debug.sethook();error("probe_instruction_limit",0)end end,"",100)\n local row=observe("detachment",case[1],function()return staged_ast_enrichment.detach_plain(input,case[3] or 256)end)\n debug.sethook();row.instruction_guard=guarded\nend\nfor _,case in ipairs({{"valid"},{"extra"},{"hole"}})do\n for _,operation in ipairs({"freeze","seed"})do\n  local snapshot=json.decode(json.encode(contract.resolution_snapshot))\n  if case[1]=="extra" then snapshot.aliases.extra=false\n  elseif case[1]=="hole" then snapshot.aliases[#snapshot.aliases+2]=false end\n  local count=0;for _ in pairs(snapshot.aliases)do count=count+1 end\n  local row=observe("snapshot_"..operation,case[1],function()\n   if operation=="freeze" then return staged_ast_enrichment.node_type(enrichment_registry(function()end,snapshot)) end\n   return staged_ast_enrichment.node_type(staged_ast_enrichment.execution_seed(snapshot,enrichment_options(),function()error("unused factory")end))\n  end)\n  row.host_length=#snapshot.aliases;row.member_count=count\n end\nend\nio.write(json.encode(rows),"\\n")\n')
(p/'capture-ranges.lua').write_text('local json=require("linkedspec.json")\nlocal ranges=require("linkedspec.staged_capture_provenance")\nlocal rows=json.array()\nlocal function scalar(v)\n if v==nil then return json.null end\n if type(v)=="number" and (v~=v or v==math.huge or v==-math.huge) then return tostring(v)end\n return v\nend\nlocal cases={\n {"valid",0,1},{"negative",-1,1},{"reversed",2,1},{"fraction",0.5,1.5},\n {"positive_infinity",0,math.huge},{"negative_infinity",-math.huge,1},{"nan",0/0,1},\n {"text","0",1},{"false",false,1}\n}\nfor _,case in ipairs(cases)do\n local match={};local input={{start_byte=case[2],end_byte=case[3]}}\n local ok,value=pcall(ranges.record,match,input);local row=json.harray({kind="range",case=case[1],ok=ok})\n if ok then local a,b=ranges.byte_span(match,0);row.start=scalar(a);row.finish=scalar(b);row.same_match=value==match\n else row.error=tostring(value)end\n rows[#rows+1]=row\nend\nfor _,name in ipairs({"extra","hole","valid_copy"})do\n local input={{start_byte=0,end_byte=1}}\n if name=="extra" then input.extra=false elseif name=="hole" then input[3]={start_byte=2,end_byte=3}end\n local match={};ranges.record(match,input);local clone={};ranges.copy(match,clone)\n input[1].start_byte=8\n local row=json.harray({kind="membership",case=name,spans=json.array()})\n for _,target in ipairs({match,clone})do\n  local a,b=ranges.byte_span(target,0);local c,d=ranges.byte_span(target,1);local e,f=ranges.byte_span(target,2)\n  row.spans[#row.spans+1]=json.array({scalar(a),scalar(b),scalar(c),scalar(d),scalar(e),scalar(f)})\n end\n row.caller_first=input[1].start_byte;row.caller_extra=input.extra==false;row.caller_third=input[3]~=nil\n rows[#rows+1]=row\nend\nlocal match={};ranges.record(match,{{start_byte=0,end_byte=1}})\nfor _,case in ipairs({{"zero",0},{"negative",-1},{"fraction",0.5},{"infinity",math.huge},{"text","0"},{"false",false}})do\n local ok,a,b=pcall(ranges.byte_span,match,case[2]);local row=json.harray({kind="index",case=case[1],ok=ok})\n if ok then row.start=scalar(a);row.finish=scalar(b)else row.error=tostring(a)end\n rows[#rows+1]=row\nend\nio.write(json.encode(rows),"\\n")\n')
(p/'verify-boundaries.py').write_text("from pathlib import Path\nimport json\np=Path('.linkedspec-data/scratch/lua124')\ndef rows(name,host):return json.loads((p/f'{name}-{host}.json').read_text())\ndef size(value):return len(json.dumps(value,ensure_ascii=False,sort_keys=True,separators=(',',':')).encode())\nr=rows('resources','puc');assert len(r)==18 and r==rows('resources','luajit')\nexpected=[(0,1,None,None),(1,1,[187],0),(64,1,[188],0),(256,1,[189],67),(4096,1,[1671],2425),(64,2,[188,187],0),(4096,2,[1671,1671],754)]\nfor row,(ceiling,count,sizes,remaining) in zip(r[:7],expected):\n assert row['case']==f'{ceiling}/{count}' and row['kind']=='diagnostic'\n if sizes is None:\n  assert row=={'callbacks':0,'case':'0/1','kind':'diagnostic','ok':False,'error':{'code':'staged_registry_snapshot_invalid','phase':'prepare','snapshot_component':'caller_ceilings'}}\n  continue\n assert row['ok'] and row['callbacks']==count and row['sizes']==sizes and row['retained_bytes']==sum(sizes)\n value=row['value'];assert value['ast']=={'nodes':['x']*count}\n assert value['resources']=={'remaining_diagnostic_bytes':remaining,'remaining_result_nodes':128,'remaining_steps':20-count,'total_calls':count}\n assert [size(d) for d in value['diagnostics']]==sizes\n assert [d['code'] for d in value['diagnostics']]==['staged_child_failed' if ceiling==4096 else 'staged_diagnostic_truncated']*count\n assert value['cache']=={'entries':1,'hits':count-1,'misses':1,'snapshot_id':'registry-snapshot:sha256:751774c703674f4936e08b2bfe2781140750a60f8d17c64d03e37eaa6bb5e9f1'}\n for i,sidecar in enumerate(value['sidecars']):\n  assert sidecar['diagnostic']==value['diagnostics'][i] and sidecar['state']=='failed_keep_text' and sidecar['parent_ast_path']==['nodes',i]\n  assert sidecar['effective']['max_diagnostic_bytes']==min(ceiling,4096)\nassert [d['maximum_bytes'] for d in r[5]['value']['diagnostics']]==[64,0]\nassert sum(row['retained_bytes']>int(row['case'].split('/')[0]) for row in r[:7] if row['ok'])==3\nmaximum=9007199254740991\njob='parse_job:v2:sha256:c26dc1cfd6b4f0e9be4dd806384bab4b4c873dfa0549dd1e1bc8449ff7c68613'\nfor row,(initial,cap) in zip(r[7:11],[(31,32),(32,32),(maximum-1,maximum),(maximum,maximum)]):\n accepted=initial<cap\n assert row['case']==f'{initial}/{cap}' and row['initial']==initial and row['maximum']==cap and row['callbacks']==int(accepted) and row['ok']==accepted\n if accepted:\n  assert row['value']['ast']=={'payload':'ok'} and row['value']['diagnostics']==[]\n  assert row['value']['resources']=={'remaining_diagnostic_bytes':8192,'remaining_result_nodes':127,'remaining_steps':19,'total_calls':cap}\n else: assert row['error']=={'calls':min(maximum,initial+1),'code':'staged_call_limit_exceeded','job_id':job,'maximum':cap,'phase':'execute','stage_chain':[]}\nfor row,name in zip(r[11:],['absent','zero','one','false','true','fraction','text']):\n assert row['case']==name and row['kind']=='initial_calls';accepted=name in ['absent','zero','one','false'];assert row['ok']==accepted\n if accepted:assert row['value']=={'remaining_diagnostic_bytes':8192,'remaining_result_nodes':128,'remaining_steps':20,'total_calls':1 if name=='one' else 0}\n else:assert row['error']=={'code':'staged_registry_snapshot_invalid','phase':'prepare','snapshot_component':'total_calls'}\na=rows('detachment','puc');b=rows('detachment','luajit');assert len(a)==len(b)==15 and a[:13]==b[:13]\nfor host,values in [('puc',a),('luajit',b)]:\n for row in values[:9]:\n  name=row['case'];guarded=name in ['marker_cycle','nested_marker_cycle'];assert row['instruction_guard']==guarded\n  if guarded:assert not row['ok'] and row['error']=='probe_instruction_limit';continue\n  assert row['ok'];v=row['value']\n  if name=='plain_cycle':assert v=={'accepted':False,'nodes':2,'reason':'<result>/loop'}\n  elif name=='marker_null':assert v=={'accepted':False,'nodes':1,'reason':'<result>/extension'}\n  elif name=='marker_function':assert v=={'accepted':False,'nodes':1,'reason':'<result>'}\n  else:\n   assert v['accepted'] and v['nodes']==(2 if name=='plain_null' else 1)\n   if name=='plain_null':assert v['value']=={'extension':None}\n   else:\n    assert v['value']['kind']=='STAGED_PARSE_JOB_MARKER' and v['value']['staged_parse_job_v2']['text']=='x'\n    if name=='marker_false':assert v['value']['extension'] is False\n    if name=='marker_atomic':assert v['value']['extension']==list(range(1,101))\n for row in values[9:]:\n  name=row['case'];op=row['kind'];assert row['member_count']==(2 if name=='valid' else 3)\n  assert row['host_length']==(4 if host=='luajit' and name=='hole' else 2)\n  accepted=name=='valid' or op=='snapshot_seed' and (name=='extra' or host=='puc')\n  assert row['ok']==accepted\n  if accepted:assert row['value']==('FrozenStagedRegistry' if op=='snapshot_freeze' else 'StagedAstEnrichmentSeed')\n  else:assert row['error']=={'code':'staged_registry_snapshot_invalid','phase':'prepare','snapshot_component':'aliases'}\nc=rows('capture','puc');assert len(c)==18 and c==rows('capture','luajit')\nendpoints=[('valid',0,1),('negative',-1,1),('reversed',2,1),('fraction',0.5,1.5),('positive_infinity',0,'inf'),('negative_infinity','-inf',1),('nan','nan',1)]\nfor row,(name,start,end) in zip(c[:7],endpoints):assert row=={'case':name,'kind':'range','ok':True,'same_match':True,'start':start,'finish':end}\nfor row,name in zip(c[7:9],['text','false']):assert row=={'case':name,'kind':'range','ok':False,'error':'staged capture provenance range is malformed'}\nfor row,name in zip(c[9:12],['extra','hole','valid_copy']):assert row=={'case':name,'kind':'membership','spans':[[0,1,None,None,None,None]]*2,'caller_first':8,'caller_extra':name=='extra','caller_third':name=='hole'}\nfor row,name in zip(c[12:],['zero','negative','fraction','infinity','text','false']):\n if name in ['zero','infinity']:assert row=={'case':name,'kind':'index','ok':True,'start':0 if name=='zero' else None,'finish':1 if name=='zero' else None}\n else:assert row=={'case':name,'kind':'index','ok':False,'error':'staged capture index must be a non-negative integer'}\nfor host,label in [('puc','puc-lua'),('luajit','luajit')]:assert (p/f'staged-{host}.log').read_text()==f'Lua staged-AST enrichment contract: 890 assertions passed on {label}\\n'\nprint('PASS 102 complete boundary observations; sparse-seed host difference retained; 1780 existing assertions; bounded marker guard consumed')\n")
LUA_STAGED_COMPLETION_READING_24
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua124/resources.lua > .linkedspec-data/scratch/lua124/resources-puc.json
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua124/resources.lua > .linkedspec-data/scratch/lua124/resources-luajit.json
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua124/detachment.lua > .linkedspec-data/scratch/lua124/detachment-puc.json
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua124/detachment.lua > .linkedspec-data/scratch/lua124/detachment-luajit.json
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua124/capture-ranges.lua > .linkedspec-data/scratch/lua124/capture-puc.json
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua124/capture-ranges.lua > .linkedspec-data/scratch/lua124/capture-luajit.json
bash tools/run_lua_project_data.sh puc lua/test/staged_ast_enrichment_contract_test.lua > .linkedspec-data/scratch/lua124/staged-puc.log 2>&1
bash tools/run_lua_project_data.sh luajit lua/test/staged_ast_enrichment_contract_test.lua > .linkedspec-data/scratch/lua124/staged-luajit.log 2>&1
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua124/verify-boundaries.py
```

[[lua-startup-reading-coverage]] independently reconstructs all 99 sources, ranges
and child digests. The owning leaf records preservation of all earlier evidence,
old task nodes, immutable history, named-argument parking and book limitations,
plus normal memory/history/Knowledge/book/doctrine checks before landing.

Independent preservation passes against activation 8469d5ba1: 1,399 previous files
remain byte-exact; 2,532 of 2,538 prior task nodes are unchanged. Exactly the reading
leaf, Lua roots 2/2.8/2.25, shared Dart 2.17.1 and startup 3.6 change, with 14 new pending
nodes. All 82 prior Known headings remain and three are added. History suffixes,
immutable archives and parked authoring tree remain exact. All four embedded
payloads match their executed bytes. Coverage independently reconstructs all 99
baseline files and 24 completed groups. Memory remains 60 lines; Changes 382 lines /
26,997 bytes and Notes 312 lines /23,810 bytes fit existing root budgets without
rollover. Knowledge generation contains 1,110 facts /8,896 keys. The book renders with a 10,104,776-byte search index;
its existing large-index warning remains startup .41.9-owned. Normal commit
hooks and post-commit activation verification remain mandatory.
