---
id: lua-spec-ast-loader-reading-and-validation-gaps
title: Lua AST and loader reading separates constructor defaults from typed JSON validation
answers:
  - "do Lua native AST constructors reject false optional fields"
  - "does Lua AST reconstruction reject false selector and list fields"
  - "can Lua AST JSON reconstruction discard malformed array members"
  - "does Lua function payload copying reject non finite numbers"
  - "how does Lua AST payload copying preserve false and null"
  - "what did Lua startup reading group 21 cover"
  - "did the Lua descriptor reading check emit a process group warning"
date: 2026-09-13
status: confirmed-open repairs; exact reading complete
tags: [lua, ast, json, loader, validation, startup]
evidence: "LUA-STARTUP-READING.1.21; clean activation 31ebbc2e414e035414845551b045c7002bf5df29. Two exact ranges /1,500 fragments /54,561 bytes; eight complete windows. Descriptor912 and root-route106 assertions pass per installed host, 2,036 total; 208 complete observations agree across hosts. Lua .2.22/.2.23 own validation repairs, .2.1 stale guidance, and startup .7 the already known process-group warning. Source remains unchanged."
reverify:
  - "Run the exact managed AST replay below; invalid-input observations are not accepted behavior."
  - "bash tools/run_lua_project_data.sh puc lua/test/rule_local_cursor_descriptor_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/rule_local_cursor_descriptor_test.lua"
  - "bash tools/run_lua_project_data.sh puc lua/test/root_rule_selection_routes_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/root_rule_selection_routes_test.lua"
  - "bash tools/project_data_run.sh perl tools/check_native_spec_resolution_contract.pl"
  - "bash tools/run_python_project_data.sh tools/check_rule_local_cursor_contract.py"
---

## Exact reading and comprehension

The ordered group digest remains
`e4df52ef54026c29fb3b399c526d674d5b4c3201edbd796791d8cd7cda4be111`.

| Repository path | Inclusive LF range | Bytes | Range SHA-256 |
| --- | --- | ---: | --- |
| `lua/src/linkedspec/spec_ast.lua` | 116–1183 | 40052 | `16590a997391a118937b07c122ae30a88398bf3c1852f15e098e7c1efdddbbde` |
| `lua/src/linkedspec/spec_loader.lua` | 1–432 | 14509 | `75206dd5db9ecdc660f887bde0b7c3fa5705cc70dc532f391af9cd602bc73f28` |

Eight untruncated windows cover AST116–315,316–515,516–715,716–915,916–1115,
1116–1183 and loader1–216,217–432. AST reading finishes; loader reading stops
after the loaded-source trace decision inside load_and_compile_spec.
Cumulative coverage is 21/51 groups, 27,151 fragments /1,079,821 bytes,
38 complete files and the partial loader. Remaining source is not credited.

The AST validates primitive/node fields and dense native lists, copies optional
function JSON data and projects every body variant. Fixed and variadic callable
signatures retain separate params/arity versus signature projections; only a final
fixed parameter can carry codeblock kind metadata. Mode helpers derive AND and
repetition properties; normalized nodes preserve source/body spans, staged job
fields, selector metadata, rule order and authored top markers. Reconstruction
uses typed JSON object/array gates and dispatches through the same constructors,
but some pre-copy traversal and absence rules differ as measured below.

Loader requests/options have separate typed identities. Name validation first
checks UTF-8, then controls, boundary whitespace and portable components. Exact
paths have their own validation. Search order remains cwd exact, cwd suffix and
declared direct roots, with lexical deduplication and no implicit recursion.
The native inspector determines file kind; the first regular candidate wins and
non-regular candidates are retained for a miss diagnostic. Loading closes the
handle, preserves all source bytes and rejects invalid UTF-8 without normalization.
Trace and pipeline errors retain request/source identity; zero-rule validation
keeps its own code instead of collapsing into a generic validation failure.

Canonical facts retrieved before reconciliation: [[lua-frontend-ast-json-contract]],
[[lua-frontend-validation]], [[lua-native-spec-resolution]], [[lua-native-spec-pipeline]],
[[lua-rule-local-cursor-descriptor]] and [[lua-root-rule-selection-routes]].
Existing .2.1 gains exact stale-guidance locations: two cards call historical
60/60 gates current, native resolution still calls later completed descriptor/trace
work active, and the descriptor body still describes generated v1 and staged outer
options. Dated evidence remains intact; current v2 and option-removal facts take
precedence. No fresh whole-backend gate is claimed by this reconciliation.

## Native defaults differ from reconstruction

Six field surfaces default explicit false in native constructors:

| Constructor field | False becomes | Equivalent from_json field |
| --- | --- | --- |
| EdgeTarget.selector_kind | numeric | rejects string type |
| BareEdgeTarget.selector_kind | unindexed for absent index | rejects string type |
| ActionEdgeBodyElementKind.fluent_chain | empty list | rejects JSON array type |
| BlindEdgeBodyElementKind.fluent_chain | empty list | rejects JSON array type |
| BareEdgeBodyElementKind.fluent_chain | empty list | rejects JSON array type |
| SpecFile.functions | empty list | rejects JSON array type |

`spec_ast.lua`452/471/516/526/535/615 use `or` before the established string/list
checks. Omission and valid defaults succeed; true/zero reject. Text remains a valid
string at the selector constructor's type boundary, while text fails list fields.
This does not admit an arbitrary selector kind into compiled execution.
Seventy-two observations per host cover all six fields, six values and both routes.
New .2.22/.2.22.1/.2.22.2 own absent-only construction and independent parity proof.

## Typed array and payload validation

Both FunctionDefinition.body_payload and body_ast accept host-typed arrays whose
first member is true but that also contain either an extra string key or a member
at index3 after a hole. The cloned/projected value is only `[true]` on both hosts.
`clone_json`198–231 traverses the length-selected prefix without checking all keys.
The lost member is deliberately supplied through a mutable host table; a valid
serialized JSON array cannot encode this malformed shape.

The same helper returns number values without a finite check. A host infinity is
accepted and retained by both native construction and from_json, then JSON encoding
fails. This differs from .2.21's rejected-coordinate diagnostic and .2.11's exact
integer serialization. New .2.23.1 owns complete array validation and .2.23.2 finite
payload checks, with .2.23.3 independent boundary/carrier proof.

Reconstructed object lists have another pre-validation loss point: the helpers
at898/914 use ipairs before their resulting dense list reaches a constructor.
A malformed typed rules array with an extra key or index3 is rejected by native
SpecFile construction but reconstructed as one rule. This measured object-list
route and the adjacent string-list helper share .2.23.1's complete-input census.
No parsed spec data loss or runtime consequence of these invalid host inputs is
inferred. Ordinary serialized/reconstructed descriptor and root routes still pass.

Controls preserve scalar false and nested `[false,null]` through both payload
fields. Cyclic payloads reject with the exact existing error. A top-level optional
payload null is retained by the native node but interpreted as absent by from_json;
this is the existing optional-field normalization, not a new runtime result policy.
The focused comparison records all 28 payload and four density rows per host,
separately from the six-field matrix. No caller-created invalid shape is silently
blessed as a valid JSON array by the repair plan.

## Selected proof and process-group warning

Fresh unchanged consumers pass descriptor912 and root-route106 assertions on each
installed host, 2,036 total. They cover existing native/reconstructed/loaded and
root generated/emitted adapters. The new invalid-input fixtures remain direct
native/from_json API observations; no new invalid-input runtime, CLI or MCP
reachability is demonstrated. Neutral resolution passes14/9/4 and cursor governance
passes8 complete /0 pending /60 mutations; these ledgers are not fresh six-runtime
admission. Declared PUC5.4 and the earlier installed5.5 observation failures remain
under .2.2; no full CI, dependency build or push is claimed.

The PUC descriptor log contains one managed-wrapper child setpgid EPERM warning
for child47639, followed by all912 assertions and exit0. The original final PGID
was not captured. Retrieval of [[project-data-liveness-permission-denial]] locates
the existing mechanism: project_data_run.sh308–314 enables monitor mode and records
the child PID as its process group without checking establishment. Startup .7
already owns that verification, unknown/denied state handling and recovery/purge
restrictions; its node now records this recurrence. No deletion probe ran.
A separate current-process control reports matching PID/PGID50782; read-only
listing reports found0/removed0/skipped0. That control does not retroactively prove
the warned child's group or resolve the unknown kernel/parent-child timing cause.

The fixture's generic text case was renamed from invalid_text to text because
strings are valid at the selector constructor's type boundary; both complete
payloads were rerun and verified. All208 decoded observations agree across hosts.
Selected consumer assertions and these observations are reported separately.

## Exact managed replay

```bash
bash tools/project_data_run.sh python3 - <<'LUA_AST_LOADER_READING_21'
from pathlib import Path
root=Path('.linkedspec-data/scratch/lua121')
root.mkdir(parents=True,exist_ok=True)
(root/'ast-boundaries.lua').write_text('local ls=require("linkedspec");local ast=ls.spec_ast;local json=ls.json\nlocal rows=json.array()\nlocal operations={\n {"edge_selector","EdgeTarget","selector_kind",function()return {label="Done",index=0} end,ast.edge_target,"numeric"},\n {"bare_selector","BareEdgeTarget","selector_kind",function()return {label="Done"} end,ast.bare_edge_target,"unindexed"},\n {"action_fluents","BodyElementKind","fluent_chain",function()return {targets={ast.edge_target({label="Done"})}} end,ast.action_edge_body_kind,json.array()},\n {"blind_fluents","BodyElementKind","fluent_chain",function()return {target="Done"} end,ast.blind_edge_body_kind,json.array()},\n {"bare_fluents","BodyElementKind","fluent_chain",function()return {targets={ast.bare_edge_target({label="Done"})}} end,ast.bare_edge_body_kind,json.array()},\n {"spec_functions","SpecFile","functions",function()return {rules={}} end,ast.spec_file,json.array()},\n}\nfor _,op in ipairs(operations) do\n for _,case in ipairs({{"absent"},{"false",false},{"true",true},{"zero",0},{"text","wrong"},{"valid",op[6]}}) do\n  for _,route in ipairs({"native","reconstructed"}) do\n   local opts=op[4]();local ok,value\n   if route=="native" then opts[op[3]]=case[2];ok,value=pcall(op[5],opts)\n   else local object=ast.to_json(op[5](opts));object[op[3]]=case[2];ok,value=pcall(ast.from_json,op[2],object) end\n   local projected=ok and ast.to_json(value) or nil\n   rows[#rows+1]=json.harray({group="default",operation=op[1],case=case[1],route=route,ok=ok,field=projected and projected[op[3]] or json.null,error=ok and json.null or tostring(value)})\n  end\n end\nend\nlocal function function_options()\n return {name="f",params={},arity=0,body_source="return(1)",source="f() { return(1) }",source_span=ast.source_span({line_start=1,line_end=1}),body_span=ast.source_span({line_start=1,line_end=1})}\nend\nlocal payloads={\n {"false",function()return false end},\n {"null",function()return json.null end},\n {"nested",function()return json.harray({a=json.array({false,json.null})})end},\n {"array_extra",function()local a=json.array({true});a.extra=false;return a end},\n {"array_hole",function()local a=json.array({true});a[3]=false;return a end},\n {"cycle",function()local a=json.array();a[1]=a;return a end},\n {"infinity",function()return math.huge end},\n}\nfor _,field in ipairs({"body_payload","body_ast"}) do for _,case in ipairs(payloads) do for _,route in ipairs({"native","reconstructed"}) do\n local opts=function_options();local input=case[2]();local ok,value\n if route=="native" then opts[field]=input;ok,value=pcall(ast.function_definition,opts)\n else local object=ast.to_json(ast.function_definition(opts));object[field]=input;ok,value=pcall(ast.from_json,"FunctionDefinition",object) end\n local encoded,wire=false,"not constructed";local present=false\n if ok then local projected=ast.to_json(value);present=projected[field]~=nil;encoded,wire=pcall(json.encode,projected) else wire=tostring(value) end\n rows[#rows+1]=json.harray({group="payload",field=field,case=case[1],route=route,ok=ok,present=present,serializable=encoded,wire=wire})\nend end end\nlocal mode=ast.default_rule_mode();local header=ast.rule_header({label="Top",is_top=true,mode=mode,rest="",line=1});local rule=ast.rule({header=header,body={}})\nfor _,case in ipairs({"extra","hole"}) do for _,route in ipairs({"native","reconstructed"}) do\n local values=json.array({route=="native" and rule or ast.to_json(rule)})\n if case=="extra" then values.extra=false else values[3]=values[1] end\n local ok,value\n if route=="native" then ok,value=pcall(ast.spec_file,{rules=values}) else ok,value=pcall(ast.from_json,"SpecFile",json.harray({rules=values})) end\n rows[#rows+1]=json.harray({group="density",case=case,route=route,ok=ok,count=ok and #value.rules or json.null,error=ok and json.null or tostring(value)})\nend end\nio.write(json.encode(rows),"\\n")\n')
(root/'verify-ast.py').write_text("from pathlib import Path\nimport json\nroot=Path('.linkedspec-data/scratch/lua121')\nhosts={h:json.loads((root/('ast-'+h+'.json')).read_text()) for h in ['puc','luajit']}\nassert hosts['puc']==hosts['luajit']\nfor host,rows in hosts.items():\n assert len(rows)==104\n assert [sum(r['group']==g for r in rows) for g in ['default','payload','density']]==[72,28,4]\n for r in rows:\n  if r['group']=='default':\n   selector=r['operation'] in ['edge_selector','bare_selector']\n   valid=r['case'] in ['absent','valid'] or (r['case']=='false' and r['route']=='native') or (r['case']=='text' and selector)\n   assert r['ok']==valid,r\n   if valid:\n    expected='wrong' if r['case']=='text' else ('numeric' if r['operation']=='edge_selector' else 'unindexed') if selector else []\n    assert r['field']==expected and r['error'] is None,r\n   else:\n    assert r['field'] is None\n    name={'edge_selector':'EdgeTarget.selector_kind','bare_selector':'BareEdgeTarget.selector_kind','action_fluents':'ActionEdgeBodyElementKind.fluent_chain','blind_fluents':'BlindEdgeBodyElementKind.fluent_chain','bare_fluents':'BareEdgeBodyElementKind.fluent_chain','spec_functions':'SpecFile.functions'}[r['operation']]\n    if selector: suffix=' must be a string'+(' when present' if r['route']=='reconstructed' else '')\n    elif r['route']=='native': suffix=' must be an array'\n    else: name='SpecFile.functions' if r['operation']=='spec_functions' else 'BodyElementKind.fluent_chain';suffix=' must be a JSON array'\n    assert r['error']=='spec AST error: '+name+suffix,r\n  elif r['group']=='payload':\n   case=r['case'];field=r['field'];valid=case!='cycle';serializable=case not in ['cycle','infinity']\n   assert r['ok']==valid and r['serializable']==serializable\n   present=valid and not(case=='null' and r['route']=='reconstructed');assert r['present']==present\n   if serializable:\n    expected={'arity':0,'body_source':'return(1)','body_span':{'line_end':1,'line_start':1},'name':'f','params':[],'source':'f() { return(1) }','source_span':{'line_end':1,'line_start':1}}\n    if present:expected[field]={'false':False,'null':None,'nested':{'a':[False,None]},'array_extra':[True],'array_hole':[True]}[case]\n    assert json.loads(r['wire'])==expected,r\n   elif case=='cycle':assert r['wire']=='spec AST error: FunctionDefinition.'+field+' must not be cyclic'\n   else:assert r['wire']=='JSON error: cannot encode a non-finite number'\n  else:\n   valid=r['route']=='reconstructed';assert r['ok']==valid and r['count']==(1 if valid else None)\n   assert r['error']==(None if valid else 'spec AST error: SpecFile.rules must use contiguous one-based integer indexes')\nprint('PASS 208 exact two-host observations: 144 constructor/reconstruction defaults, 56 payload copies, 8 list-density controls; invalid inputs remain documented defects.')\n")
LUA_AST_LOADER_READING_21
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua121/ast-boundaries.lua > .linkedspec-data/scratch/lua121/ast-puc.json
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua121/ast-boundaries.lua > .linkedspec-data/scratch/lua121/ast-luajit.json
bash tools/project_data_run.sh python3 .linkedspec-data/scratch/lua121/verify-ast.py
```

The independently dated process-group control can be repeated without recovery:

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -MJSON::PP -e 'print JSON::PP->new->canonical->encode({pid=>$$,pgid=>getpgrp(0),group_matches_pid=>getpgrp(0)==$$?1:0}),qq{\n}'
bash tools/project_data_run.sh --list
```

The preservation audit retains 1,396 prior source/card/decision/history files and
2,512 of 2,517 prior task nodes exactly. Only the reading leaf, repair root,
stale-guidance owner and startup reading/process owners change; exactly seven
pending repair nodes are added. All 76 prior known-limitation headings remain,
with two new headings. The parked authoring tree and prior chronology suffixes
stay byte-identical. Both embedded payloads match the executed files; exact range
hashes and the canonical 99-file/51-group coverage replay pass at 21 read groups.

Knowledge regeneration reports 1,107 facts /8,873 keys. Memory remains 60 lines;
change/engineering hot logs are 361/291 lines (25,165/21,654 bytes), with no rollover
required. Memory, both histories, whitespace and rendered book checks pass.
The existing search-index warning is 10,088,724 bytes and remains startup
.41.9-owned. Normal doctrine hooks govern landing;
no full CI or push is claimed.
