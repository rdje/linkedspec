---
id: lua-validator-staged-prefix-reading-and-array-gaps
title: Lua validator options default false and staged tagged-array copies can omit malformed members
answers:
  - "what exact Lua source did startup reading child 23 cover"
  - "does Lua validate_spec reject false options"
  - "do Lua staged typed arrays validate every member before copying"
  - "can a malformed host array lose members in staged parent AST detachment"
  - "why do malformed Lua staged job paths share the clean prefix digest"
  - "do Lua staged cache capability arrays reject extra keys"
  - "which tasks own Lua validator and staged array admission repairs"
date: 2026-09-13
status: exact reading complete; validator and staged host-input repairs remain pending
tags: [lua, startup, validation, staged-parsing, arrays, evidence]
evidence: "LUA-STARTUP-READING.1.23; clean activation 4e2cbd9a2f33b276718a5b7b8186f6a7df894852. Two exact ranges /1500 fragments /54480 bytes in eight complete windows. Staged890 and gap392 assertions pass per installed host, 2564 total; 52 exact observations agree across hosts. .2.25 owns complete staged tagged-array copying; .2.8.13/.14 own validator options; .2.1 retains dated/current guidance reconciliation. All source remains unchanged."
reverify:
  - "Run LUA_VALIDATOR_STAGED_READING_23 and its managed commands below; verify-boundaries.py asserts the measured pre-repair behavior."
  - "bash tools/run_lua_project_data.sh puc lua/test/staged_ast_enrichment_contract_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/staged_ast_enrichment_contract_test.lua"
  - "bash tools/run_lua_project_data.sh puc lua/test/inter_match_gap_capture_contract_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/inter_match_gap_capture_contract_test.lua"
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py"
---

# Exact coverage and comprehension

Baseline `baeb984e36a94a15951cd23d4c52def5064cdaca` remains the sole source
inventory. The two ranges have ordered group SHA-256
`56ec303aa8c4a6d47f54d40eef4a977642127eb0da7cfc4d74b4e03b23dccccb`.

| Repo-root source | Inclusive lines | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| `lua/src/linkedspec/spec_validator.lua` | 144–865 | 24993 | `e5563e867b8c28aa55ae521fdcdf49723501810b3af0325db97a9b7687cd0cb2` |
| `lua/src/linkedspec/staged_ast_enrichment.lua` | 1–778 | 29487 | `51f41369f4a86b3be790504620663834db6850ce9e1256a26a049ee4a22c5502` |

The untruncated windows are validator 144–343, 344–543, 544–743, 744–865 and
staged 1–200, 201–400, 401–600, 601–778. Cumulative reading is 23/51,
30,151 fragments /1,178,760 bytes, with 41 complete files and the staged module
partial. Diagnostic reads of staged 1166–1238 and 2120–2187 establish the parent
copy call chain but grant no advance reading credit to child 24.

Validation checks declared regex-slot names and duplicate identities, resolves
named/unindexed targets to numeric slots, classifies gap-eligible modes and edge
ownership, and enforces function/parameter/signature reservations. It rejects raw
body lines, mixed edge ownership, invalid grouped/AND/indexed edges and undefined
or out-of-range target slots. Its lightweight regex structure scanner tracks
escapes, character classes and parenthesis depth. Strict mode additionally checks
unused rules. Trace events wrap this ordered validation, which returns no value
on success. The lifecycle brace scanner is the separate quote-only implementation
already owned by .2.24.4 and shared startup .54.3; this slice does not reclassify it.

The staged prefix implements private opaque tokens and detached errors, finite
scalar copies, registry snapshot validation, immutable callback binding sets and
logical snapshot digests. Aliases/declaring-relative candidates precede ordered
roots and providers; these are completed caller-supplied outcomes, with no live
lookup. Effective versions, tops, capabilities, policy modes, source detail and
ceilings can narrow caller authority. Job identities use complete seven-field
logical input; cache identities validate and normalize eight fields, including a
dense sorted capability set. The typed ordering prefix compares strings before
numeric array coordinates. Reading stops inside order_jobs before its suffix.

Retrieved [[lua-frontend-validation]], [[lua-staged-ast-enrichment-marker-provenance]],
[[lua-staged-ast-enrichment-current-depth-authority]],
[[lua-staged-ast-enrichment-carriers-admission]] and
[[lua-staged-ast-enrichment-recomposition]] before reconciliation. Existing .2.1
retains their dated/current count reconciliation: present-tense 888 totals are
historical; this unchanged consumer freshly reports 890 on each installed host.
The Dart/Julia staged resource cards concern different byte/call boundaries and
provide no fresh Lua resource proof in this slice.

# Confirmed boundaries and repair ownership

`validate_spec` at spec_validator.lua:823 applies `options or {}` before its table
check. Absent/empty/false options succeed; true/zero/text reject the exact typed
`SpecValidationException: validation options must be a table`. The public facade
is called on a fresh parsed `Top:: I { return(7) }` input for each control.
`.2.8.13` owns absent-only defaulting and `.2.8.14` owns independent validation
and dependent-carrier proof. Successful validation does not execute that action.

The staged `plain_table_kind` at line 94 returns a tagged array's declared kind before
checking `dense_array`. Its `copy_plain` loop at line 133 and `detach_plain` loop at line 1214
then walk only the length-selected prefix. The private job_identity route at line 676
and parent-AST entrypoint at line 2135 expose this behavior:

| Host-created input | Job identity | Parent AST | Caller input |
| --- | --- | --- | --- |
| dense `["nodes"]` | baseline digest | `["nodes"]` | retained |
| dense `["nodes",false]` | distinct digest | `["nodes",false]` | retained |
| tagged array plus `extra=false` | baseline digest | `["nodes"]` | extra member retained |
| tagged array plus sparse index3=false | baseline digest | `["nodes"]` | sparse member retained |
| equivalent plain malformed tables | reject non-plain input | typed snapshot rejection | retained |
| tagged dense infinity / cyclic array | reject | typed snapshot rejection | retained |
| dense `["nodes",null]` | distinct digest | `["nodes",null]` | retained |

All parent cases use a frozen registry with zero callbacks, zero cache entries,
zero hits/misses and empty sidecars/diagnostics. Equal job digests follow omission
before hashing; they are not evidence of a SHA-256 algorithm defect. The private
job helper itself does not admit these inputs as valid authored path components.
The valid cache fixture preserves its exact neutral digest; an extra capability
member rejects with staged_cache_identity_invalid because that path checks full
density before copying.

`.2.25` owns full staged membership validation with implementation and independent
proof children. It coordinates with AST copying .2.23, whose non-finite payload
acceptance is distinct: these staged paths already reject non-finite numbers.
These are deliberately altered host tables. No valid serialized JSON, ordinary
spec input, child execution, recursive scheduling or production-carrier defect
is demonstrated. The repair must establish each additional affected route before
making broader claims.

# Focused verification and limits

Both managed staged consumers pass 890 assertions and gap-capture consumers pass 392,
2,564 total. Their admitted native/reconstructed/generated/emitted positive
controls remain covered. A separate 26-row matrix per host records six validator
options, nine job-identity values, two cache cases and nine parent inputs. The
independent Python checker compares all 52 observations across hosts and pins
exact digests, copied ASTs, errors, caller member counts and zero callbacks.
The initial 17-row probe was extended with nine parent cases; both complete
payloads were rerun successfully. Every process result was consumed with exit 0.

Neutral staged governance passes 9 complete rollout legs, 123 semantic and 129
public mutations; gap governance passes 9 complete/0 pending, 63 semantic and 34
public mutations plus existing admission mutations. These are contract/topology
checks, not additional runtime assertions or proof of the malformed cases' repair.
Installed PUC 5.5.1 and LuaJIT remain the measured hosts; supported-PUC .2.2, earlier
nil-error test failures, public-selector .28.7, all source repairs and later full
CI/push prerequisites remain open. No dependency build or broad gate runs here.

# Exact managed replay

The payloads below invoke the existing LinkedSpec modules and fixture data. The
checker preserves the measured pre-repair outcome, rather than approving it as
the intended acceptance behavior. Run from the repository root.

```bash
bash tools/project_data_run.sh python3 - <<'LUA_VALIDATOR_STAGED_READING_23'
from pathlib import Path
p=Path('.linkedspec-data/scratch/lua123'); p.mkdir(parents=True,exist_ok=True)
(p/'boundaries.lua').write_text('local ls=require("linkedspec")\nlocal json=ls.json\nlocal staged=require("linkedspec.staged_ast_enrichment")\nlocal rows=json.array()\nlocal function read(path)local f=assert(io.open(path,"rb"));local s=f:read("*a");f:close();return s end\nlocal contract=json.decode(read("capability_conformance/staged_ast_enrichment_contract.json"))\nlocal function clone(v)return json.decode(json.encode(v))end\nlocal function record(kind,name,operation)\n local ok,value=pcall(operation)\n local row=json.harray({kind=kind,case=name,ok=ok})\n if ok then row.value=value==nil and json.null or value\n else row.error=tostring(value);row.typed_validation=ls.is_spec_validation_error(value);row.typed_staged=staged.is_error(value) end\n rows[#rows+1]=row\n return row\nend\nfor _,case in ipairs({{"absent"},{"empty",{}},{"false",false},{"true",true},{"zero",0},{"text","wrong"}})do\n record("validator_options",case[1],function()return ls.validate_spec(ls.parse_spec("Top::\\n I { return(7) }\\n"),case[2])end)\nend\nlocal function fields(path)\n local v=clone(contract.job_id_cases[1]);v.id=nil;v.expected_job_id=nil;v.parent_ast_path=path;return v\nend\nlocal variants={\n {"dense",function()return json.array({"nodes"})end},\n {"dense_changed",function()return json.array({"nodes",false})end},\n {"typed_extra",function()local v=json.array({"nodes"});v.extra=false;return v end},\n {"typed_hole",function()local v=json.array({"nodes"});v[3]=false;return v end},\n {"plain_extra",function()return {[1]="nodes",extra=false}end},\n {"plain_hole",function()return {[1]="nodes",[3]=false}end},\n {"typed_infinity",function()return json.array({"nodes",math.huge})end},\n {"typed_cycle",function()local v=json.array({"nodes"});v[2]=v;return v end},\n {"dense_null",function()return json.array({"nodes",json.null})end},\n}\nfor _,case in ipairs(variants)do\n local path=case[2]();local before_keys=0;for _ in pairs(path)do before_keys=before_keys+1 end\n local row=record("job_identity",case[1],function()return staged.job_identity(fields(path))end)\n local after_keys=0;for _ in pairs(path)do after_keys=after_keys+1 end\n row.caller_keys_before=before_keys;row.caller_keys_after=after_keys\n row.caller_extra_false=path.extra==false;row.caller_index3_false=path[3]==false\nend\nfor _,case in ipairs({{"dense",false},{"typed_extra",true}})do\n local input=clone(contract.cache_cases[1].fields)\n if case[2] then input.backend_capabilities.extra=false end\n record("cache_identity",case[1],function()return staged.cache_identity(input)end)\nend\nlocal function enrichment_options()\n  return json.harray({\n    declaring_spec_id = "grammar/main.spec",\n    caller_capabilities = json.array({\n      "staged-parse-job-v2",\n      "structured-result-v1",\n      "typed-source-location-v1",\n      "xml-v1",\n      "yaml-v1",\n    }),\n    caller_policy_modes = json.array({\n      "append_child",\n      "diagnostic_node",\n      "fail",\n      "keep_text",\n      "replace_field",\n      "replace_marker",\n      "sibling_field",\n      "trace",\n    }),\n    caller_ceilings = json.harray({\n      source_detail = "text",\n      max_steps = 200,\n      max_result_nodes = 128,\n      max_diagnostic_bytes = 8192,\n    }),\n    required_source_detail = "identity",\n    required_versions = json.harray({\n      spec_language_version = 2,\n      helper_contract_version = "actionir-v3",\n      staged_contract_version = 2,\n    }),\n  })\nend\n\nlocal calls=0\nlocal callbacks={}\nfor _,entry in ipairs(contract.resolution_snapshot.entries)do callbacks[entry.compiled_authority]=function()calls=calls+1;return staged.child_success("ok")end end\nlocal registry=staged.freeze_registry(contract.resolution_snapshot,callbacks)\nfor _,case in ipairs(variants)do\n local parent=case[2]();local before=0;for _ in pairs(parent)do before=before+1 end\n local row=record("parent_ast",case[1],function()return staged.enrich_current_depth(registry,parent,enrichment_options())end)\n local after=0;for _ in pairs(parent)do after=after+1 end\n row.caller_keys_before=before;row.caller_keys_after=after;row.callbacks=calls\nend\nio.write(json.encode(rows),"\\n")\n')
(p/'verify-boundaries.py').write_text("from pathlib import Path\nimport json\np=Path('.linkedspec-data/scratch/lua123')\na=json.loads((p/'boundaries-puc.json').read_text());b=json.loads((p/'boundaries-luajit.json').read_text())\nassert a==b and len(a)==26\nrows={(r['kind'],r['case']):r for r in a};assert len(rows)==26\nfor name in ['absent','empty','false','true','zero','text']:\n r=rows['validator_options',name];accepted=name in ['absent','empty','false'];assert r['ok']==accepted\n if accepted: assert r=={'case':name,'kind':'validator_options','ok':True,'value':None}\n else: assert r=={'case':name,'kind':'validator_options','ok':False,'error':'SpecValidationException: validation options must be a table','typed_staged':False,'typed_validation':True}\nexpected_ids={\n 'dense':'0af6b28c968620ee72c862da88371632927c74f609e41d333ced605d5a23578a',\n 'dense_changed':'5d49bd59f45de1493199b8fdf2a8603c28a8719b057ef89c08ef42e04e45f090',\n 'dense_null':'9c1f5669ac667cabf1198c76e4fa493f86b3ae57a207d308f834147bfd29802c',\n}\naccepted=['dense','dense_changed','typed_extra','typed_hole','dense_null']\nfor name in ['dense','dense_changed','typed_extra','typed_hole','plain_extra','plain_hole','typed_infinity','typed_cycle','dense_null']:\n j=rows['job_identity',name];r=rows['parent_ast',name]\n assert j['ok']==r['ok']==(name in accepted)\n assert j['caller_keys_before']==j['caller_keys_after']==r['caller_keys_before']==r['caller_keys_after']==(1 if name=='dense' else 2)\n assert j['caller_extra_false']==(name in ['typed_extra','plain_extra'])\n assert j['caller_index3_false']==(name in ['typed_hole','plain_hole'])\n assert r['callbacks']==0\n if name in accepted:\n  normalized='dense' if name in ['typed_extra','typed_hole'] else name\n  assert j['value']=='parse_job:v2:sha256:'+expected_ids[normalized]\n  expected=['nodes']+([False] if name=='dense_changed' else [None] if name=='dense_null' else [])\n  assert r['value']=={'ast':expected,'cache':{'entries':0,'hits':0,'misses':0,'snapshot_id':'registry-snapshot:sha256:751774c703674f4936e08b2bfe2781140750a60f8d17c64d03e37eaa6bb5e9f1'},'diagnostics':[],'sidecars':[]}\n else:\n  reason='non-plain data' if name.startswith('plain_') else 'a non-finite number' if name=='typed_infinity' else 'cyclic data'\n  assert j['error']=='staged AST enrichment cannot copy '+reason\n  assert j['typed_staged']==j['typed_validation']==False\n  assert r['error']=='LINKEDSPEC_STAGED_AST_ENRICHMENT_ERROR:staged_registry_snapshot_invalid' and r['typed_staged'] and not r['typed_validation']\nassert rows['cache_identity','dense']=={'case':'dense','kind':'cache_identity','ok':True,'value':'sha256:9388c18c39307e38fb001602295e05d84dbf113fec0d7cddcc45ef4b9bc338cb'}\nassert rows['cache_identity','typed_extra']=={'case':'typed_extra','kind':'cache_identity','ok':False,'error':'LINKEDSPEC_STAGED_AST_ENRICHMENT_ERROR:staged_cache_identity_invalid','typed_staged':True,'typed_validation':False}\nfor host,label in [('puc','puc-lua'),('luajit','luajit')]:\n assert (p/f'staged-{host}.log').read_text()==f'Lua staged-AST enrichment contract: 890 assertions passed on {label}\\n'\n assert (p/f'gap-{host}.log').read_text()==f'Lua inter-match gap contract: OK (392 assertions; admitted; runtime={label})\\n'\nprint('PASS 52 exact two-host observations; 2564 existing assertions pass; no source repair or declared-PUC proof')\n")
LUA_VALIDATOR_STAGED_READING_23
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua123/boundaries.lua > .linkedspec-data/scratch/lua123/boundaries-puc.json
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua123/boundaries.lua > .linkedspec-data/scratch/lua123/boundaries-luajit.json
bash tools/run_lua_project_data.sh puc lua/test/staged_ast_enrichment_contract_test.lua > .linkedspec-data/scratch/lua123/staged-puc.log 2>&1
bash tools/run_lua_project_data.sh luajit lua/test/staged_ast_enrichment_contract_test.lua > .linkedspec-data/scratch/lua123/staged-luajit.log 2>&1
bash tools/run_lua_project_data.sh puc lua/test/inter_match_gap_capture_contract_test.lua > .linkedspec-data/scratch/lua123/gap-puc.log 2>&1
bash tools/run_lua_project_data.sh luajit lua/test/inter_match_gap_capture_contract_test.lua > .linkedspec-data/scratch/lua123/gap-luajit.log 2>&1
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua123/verify-boundaries.py
```

The independent coverage replay in [[lua-startup-reading-coverage]] verifies all
99 baseline sources, every ordered range and the group summary. The owning leaf
also records exact preservation of older repair nodes, evidence, history and
parked named arguments, plus resulting-tree memory/history/book/doctrine checks.

Independent preservation passes against activation 4e2cbd9a2: 1,398 previous files
remain byte-exact; 2,528 of 2,533 prior task nodes are unchanged. Exactly the reading
leaf, repair roots 2/2.1/2.8 and startup 3.6 change, with five new pending repair
nodes. All 81 prior Known headings remain and one is added. History suffixes,
immutable archives and parked authoring tree remain exact. Both embedded payloads
match their executed bytes. Coverage independently reconstructs all 99 baseline
files and 23 completed groups. Memory remains 60 lines; Changes 375 lines /26,375 bytes and
Notes 305 lines /23,103 bytes fit existing root budgets without rollover. Knowledge generation
contains 1,109 facts /8,887 keys. The book renders successfully with a 10,097,626-byte
search index; the existing large-index warning remains startup .41.9-owned.
Normal commit doctrines and post-commit activation verification remain mandatory.
