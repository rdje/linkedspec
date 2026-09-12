---
id: lua-semantic-query-observation-reading-and-evidence-gaps
title: Lua semantic reading owns rejected false evidence and qualifies query budgets and host error behavior
answers:
  - what did Lua startup reading group seventeen cover
  - do Lua semantic queries reproduce the shared budget gaps
  - why does a rejected Lua semantic query turn false into null
  - which task owns Lua rejected query evidence preservation
  - why do Lua native and generated observation tests fail nil callback identity on 5.5
  - does Lua 5.5 error nil preserve the same value as LuaJIT
  - which semantic observation results actually passed during Lua startup reading
date: 2026-09-13
status: group seventeen read; query evidence repair pending; two installed-PUC host incompatibilities retained
tags: [lua, reading, semantic, query, observation, budgets, diagnostics, runtime, verification]
evidence: "LUA-STARTUP-READING.1.17 reads1500 fragments/53106 bytes from dce95cec24f66a2badf0746edf1b701f78ae15f8. Query571 and projection269 pass per host; LuaJIT observation121/generated80 pass. Installed PUC observation120/121 and generated79/80 retain one nil-error failure each. Fourteen two-host query responses match;12 agree fully with neutral,2 differ only by false-to-null evidence. .2.15 owns query evidence; shared .82.3.1 owns Lua budgets; existing .2.2 owns documented 5.5 nil-error incompatibility."
reverify:
  - "Run LUA_SEMANTIC_READING_17 below for exact public query/neutral comparison."
  - "bash tools/run_lua_project_data.sh puc lua/test/semantic_index_query_kernel_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/semantic_index_query_kernel_test.lua"
  - "bash tools/run_lua_project_data.sh puc lua/test/semantic_index_runtime_projection_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/semantic_index_runtime_projection_test.lua"
  - "Run the four unchanged observation consumers and the bare error probe below; retain installed5.5 failures."
  - "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py"
  - "Run LUA_READING_COVERAGE in docs/knowledge/lua-startup-reading-coverage.md."
---

# Exact reading and scope

Activation is `dce95cec24f66a2badf0746edf1b701f78ae15f8`; frozen source baseline
remains `baeb984e36a94a15951cd23d4c52def5064cdaca`. Group seventeen covers1,500
fragments /53,106 bytes, ordered-range SHA-256
`5148785e3cf31a218ea26f11df0d3e783be1e4524eb8c8138fa0c4e01fd31ef5`.
All source coordinates below are inclusive LF lines under `lua/src/linkedspec`.

| File | Lines | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| semantic_index.lua | 594–753 | 5670 | 6038f6c8a7bb0cb89cdd5b99d950e2dc285c12f149e99b9b4b0e7da4469ad858 |
| semantic_observation.lua | 1–119 | 3702 | d91e9a216fa3385f1b937052083c11c53e7096008f1a556d4f55bc112b0771d0 |
| semantic_query.lua | 1–1142 | 41182 | 2385f5130a9cdbc8cf9386337181d587d85bb1207297667d5dfabb06dc4be610 |
| semantic_runtime_projection.lua | 1–79 | 2552 | cdcde8705ca36db849e6933b09e0d12d5cbf803c7956c9b2ec16f4f12f92463a |

All twelve complete windows were consumed without truncation: index594–743,
744–753; observation1–119; query1–150,151–300,301–450,451–600,601–750,751–900,
901–1050,1051–1142; runtime projection1–79. Index, observation and query reading
are complete; runtime projection stops inside dense event-key validation.
Cumulative coverage is17/51,21,151 fragments /868,215 bytes,31 complete files and
one partial runtime projector. All99 baseline sources remain unchanged.

# Comprehension and canonical reconciliation

The index suffix exposes detached diagnostic/entry/plan/source values, validates
byte/scalar ranges and source ceilings, and performs exact UTF-8 needle lookup.
Observed-index derivation takes one detached projection and protected events,
retaining a separate immutable index while sharing private immutable source state.
Typed and raw queries each materialize one projection; private identity/testing
seams do not expose that retained state as public fields.

Observation owns protected event handles, eight-field detached JSON and a separate
sink-failure carrier. Slot events carry selected identity and scalar position;
result events hash input through the shared SHA owner. Optional fields use explicit
nil checks, preserving false when relevant to a malformed-event test. Delivery
captures the error value supplied by the host and transports it through the private
carrier; the installed-host nil behavior is distinguished below.

The query module imports only JSON and receives a detached projection. Requests
have explicit operations, ranked kinds, plain typed options, finite bounded page/
budget integers and copied subject sequences. Raw requests require exact JSON
object/array/null kinds and field sets, reject scalar-ambiguous cursors, and share
the typed evaluator after validation. Recursive frozen nodes distinguish null,
arrays and objects; accessors and JSON projection return detached values. This
correct null handling is separate from .2.14's diagnostic table-copy defect.

Projection enforces requested source detail, structural redaction and digest
availability. Capabilities, filtered list/get, relation breadth-first traversal and
explain preserve canonical projection order. Paging applies after_id to the primary
filtered stream. Costs reflect returned logical records/relations/depth; existing
shared budget gaps and the new rejected-evidence false loss are below.

The runtime projector prefix constructs portable record/relation envelopes,
validates finite integer positions, UTF-8 labels and exact input digest spelling,
and begins dense typed-event sequence validation. Its remaining body receives no
physical reading credit from running the complete projection consumer.

Canonical retrieval preceded diagnosis: [[lua-semantic-query-kernel]],
[[lua-semantic-query-traversal]], [[lua-semantic-query-public-api]],
[[lua-semantic-runtime-observation-direct-capture]],
[[lua-semantic-runtime-observation-derivation]] and
[[semantic-query-budget-contract-gaps]]. Existing .2.1 gains the semantic_index.lua
line3 future-generated-observation comment and present-tense pending wording in
the public query card; original dated stage counts remain historical evidence.

# Rejected scalar false becomes null

Public query_neutral with contract=false correctly rejects the request but reports
requested=null instead of false. An otherwise valid request with page.after_id=false
also rejects correctly while echoing page.after_id=null. Both installed hosts
produce identical complete responses. True, zero, typed null and a nested
[false,null] contract value retain their evidence; the loss is scalar false.

semantic_query.lua neutral_evidence at845–847 returns `ok and copied or json.null`.
A successful false copy takes the final fallback. Each of the two complete native
responses equals the independently generated neutral response after changing only
that expected false field to null. Every response still passes the neutral schema;
schema validity alone cannot establish evidence fidelity.

Pending `.2.15.1` owns explicit success/value handling and `.2.15.2` independent
full-response, detachment, invalid-input and applicable transport proof. Query
operations remain rejected with zero costs; this is an evidence-preservation bug,
not acceptance of an invalid contract or cursor. Compilation diagnostic null-to-
object copying stays separately owned by .2.14.

# Shared query budget evidence now includes Lua

All six graph requests from the existing Julia/neutral fact produce the same
complete JSON values on both Lua hosts and equal the neutral responses:

| Request | Records/relations/depth cost | Complete | Diagnostic |
| --- | --- | --- | --- |
| default explain | 3/2/1 | true | none |
| explain max_relations=1 | 3/2/1 | true | none |
| explain max_depth=0 | 3/2/1 | true | none |
| explain max_records=1 | 1/0/0 | false | max_records |
| list page.limit=1 | 1/0/0 | false | none |
| same page, max_records=2 | 1/0/0 | false | max_records |

At semantic_query.lua652, page_stream derives limited_by_budget from the entire
remaining stream before choosing the smaller requested page. Explain at1092
restricts steps only by max_records-1, then adds explained_by relations and reports
depth at1107 without applying the other requested ceilings. These are the existing
shared .82 causes, not a separate Lua contract decision. New `.82.3.1.1/.2` own
bounded Lua implementation and independent proof after shared .82.1/.82.2 and
startup prerequisites. Other native backends and MCP still need their own census.

# Installed PUC nil-error incompatibility: two tests fail

| Unchanged consumer | Installed PUC5.5 | LuaJIT |
| --- | ---: | ---: |
| semantic_index_query_kernel_test.lua | 571/571 | 571/571 |
| semantic_index_runtime_projection_test.lua | 269/269 | 269/269 |
| semantic_index_runtime_observation_native_test.lua | 120/121, FAIL | 121/121 |
| semantic_index_runtime_observation_generated_routes_test.lua | 79/80, FAIL | 80/80 |

Each failing PUC suite expects a nil callback error and receives the string
`<no error object>`. The native assertion is at test line423; both suites invoke
error(nil,0) in the callback. A bare pcall/error probe with no LinkedSpec import
reproduces the host difference: PUC5.5 yields false/string/<no error object>;
LuaJIT yields false/nil/nil. False, string and table-identity controls agree.

This is a documented host change: [Lua5.5 error handling](https://www.lua.org/manual/5.5/manual.html#2.3)
converts nil error objects to a string. [Lua5.5.1 luaG_errormsg](https://www.lua.org/source/5.5/ldebug.c.html#luaG_errormsg)
performs that conversion before throwing. [Lua5.4 error handling](https://www.lua.org/manual/5.4/manual.html#2.3)
permits any error value. The local primitive probe identifies the actual behavior;
the manuals do not substitute for a fresh declared5.4 run.

Existing `.2.2` owns restoring the declared5.4 runtime/header selection. Its `.2.2.2`
acceptance now names both failing consumers and exact nil/false/string/table
controls. Do not change declared5.4 expectations to accommodate the unapproved5.5
host, or translate a legitimate string back to nil. The private carrier receives
the already-converted string. These failures remain open; no complete PUC or
supported dual-host semantic pass is claimed. The source-reading/evidence scope
can close with their located cause and repair ownership; source repairs remain gated.

# Exact proof accounting and replay

The selected consumers run2,082 assertions:2,080 pass and the two above fail.
LuaJIT passes1,041/1,041; installed PUC passes1,039/1,041. Ten selected Lua
executions (eight consumers and two query probes) complete, and every result is
consumed. The two additional bare-host probes complete separately. Fourteen public
query responses per host are checked as observations:12 full neutral agreements,
including all six budget requests, and two exact scalar-false differences.
Neutral validation passes6 fixture groups/20 queries/128 mutations and existing
9/9 rollout,6/6 admission governance. No fresh six-runtime execution, full gate,
MCP reproduction, declared5.4 or repaired behavior is claimed. Earlier .28.7 and
all fifteen Lua repair roots remain open.

| Replay payload | Bytes | SHA-256 |
| --- | ---: | --- |
| query-boundaries.lua | 2388 | 7a727b3f4530075ce818f8a9f038085771771f7623399d779befaeff8cd96d20 |
| neutral-query-proof.py | 2152 | 40d7ed7a2c3b3336c6cf31b3a16f9d7ba989b554df1432e092dfced09e13f7af |

```bash
bash tools/project_data_run.sh python3 - <<'LUA_SEMANTIC_READING_17'
from pathlib import Path
root = Path('.linkedspec-data/scratch/lua117')
root.mkdir(parents=True, exist_ok=True)
(root / 'query-boundaries.lua').write_text('local ls = require("linkedspec")\nlocal json = ls.json\nlocal function read_file(path)\n  local f = assert(io.open(path, "rb")); local data = assert(f:read("*a")); assert(f:close()); return data\nend\nlocal function clone(value) return json.decode(json.encode(value)) end\nlocal contract = json.decode(read_file("capability_conformance/semantic_introspection_contract.json"))\nlocal source = read_file("capability_conformance/semantic_introspection/graph.spec")\nlocal index = ls.semantic_index(source, { logical_name = "graph.spec", source_detail_ceiling = "text" })\nlocal base\nfor _, item in ipairs(contract.query_cases) do\n  if item.id == "graph_explain_entry" then assert(base == nil); base = item.request end\nend\nassert(base ~= nil)\nlocal budget_cases = { "explain_default", "explain_relations1", "explain_depth0", "explain_records1", "list_page1", "list_page1_records2" }\nlocal rows = json.array()\nfor _, name in ipairs(budget_cases) do\n  local request = clone(base)\n  if name == "explain_relations1" then request.budget.max_relations = 1\n  elseif name == "explain_depth0" then request.budget.max_depth = 0\n  elseif name == "explain_records1" then request.budget.max_records = 1\n  elseif name:sub(1, 5) == "list_" then\n    request.operation = "list"; request.subjects = json.array(); request.page.limit = 1\n    if name == "list_page1_records2" then request.budget.max_records = 2 end\n  end\n  local response = index:query_neutral(request):to_json()\n  assert(response.ok and response.snapshot.state == "compiled")\n  rows[#rows + 1] = json.harray({ case = name, request = request, response = response })\nend\nlocal evidence_cases = {\n  { "contract_false", "contract", false },\n  { "contract_true", "contract", true },\n  { "contract_zero", "contract", 0 },\n  { "contract_null", "contract", json.null },\n  { "contract_array", "contract", json.array({ false, json.null }) },\n  { "after_false", "after", false },\n  { "after_true", "after", true },\n  { "after_zero", "after", 0 },\n}\nfor _, item in ipairs(evidence_cases) do\n  local request = clone(base)\n  if item[2] == "contract" then request.contract = item[3] else request.page.after_id = item[3] end\n  local response = index:query_neutral(request):to_json()\n  assert(not response.ok and #response.diagnostics == 1)\n  rows[#rows + 1] = json.harray({ case = item[1], request = request, response = response })\nend\nio.write(json.encode(rows), "\\n")\n')
(root / 'neutral-query-proof.py').write_text("from pathlib import Path\nimport copy,importlib.util,json,sys\nspec=importlib.util.spec_from_file_location('lua117_neutral','tools/check_semantic_introspection_contract.py')\nm=importlib.util.module_from_spec(spec);sys.modules[spec.name]=m;spec.loader.exec_module(m)\ncontract=m.load_json(m.ROOT/'capability_conformance/semantic_introspection_contract.json')\nmodel=m.load_json(m.ROOT/'capability_conformance/semantic_introspection_model.json')\nsnapshot=next(row for row in model['snapshots'] if row['id']=='graph')\nroot=Path('.linkedspec-data/scratch/lua117')\npuc=json.loads((root/'query-puc.json').read_text());lj=json.loads((root/'query-luajit.json').read_text())\nassert puc==lj and len(puc)==14 and len({r['case'] for r in puc})==14\nfull=0; differences=0\nfor row in puc:\n expected=m.evaluate_query(contract,snapshot,row['request'])\n m.validate_response(contract,expected,row['case'])\n m.validate_response(contract,row['response'],row['case']+' Lua')\n if row['case']=='contract_false':\n  assert expected['diagnostics'][0]['fields']['requested'] is False\n  altered=copy.deepcopy(expected);altered['diagnostics'][0]['fields']['requested']=None\n  assert altered==row['response'];differences+=1\n elif row['case']=='after_false':\n  assert expected['page']['after_id'] is False\n  altered=copy.deepcopy(expected);altered['page']['after_id']=None\n  assert altered==row['response'];differences+=1\n else:\n  assert expected==row['response'],row['case'];full+=1\nlookup={r['case']:r for r in puc}\nassert lookup['explain_relations1']['response']['cost']['relations_examined']>lookup['explain_relations1']['request']['budget']['max_relations']\nassert lookup['explain_depth0']['response']['cost']['depth_reached']>lookup['explain_depth0']['request']['budget']['max_depth']\nr=lookup['list_page1_records2'];assert r['response']['cost']['records_examined']<r['request']['budget']['max_records'] and r['response']['diagnostics'][0]['fields']['limit']=='max_records'\nassert full==12 and differences==2\nprint('PASS 14 identical two-host responses;12 full neutral agreements including all six budget cases;2 exact false-to-null evidence differences;all response schemas pass')\n")
LUA_SEMANTIC_READING_17
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua117/query-boundaries.lua > .linkedspec-data/scratch/lua117/query-puc.json
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua117/query-boundaries.lua > .linkedspec-data/scratch/lua117/query-luajit.json
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua117/neutral-query-proof.py
```

Run each unchanged observation consumer separately and retain its exit status:

```bash
bash tools/run_lua_project_data.sh puc lua/test/semantic_index_runtime_observation_native_test.lua
bash tools/run_lua_project_data.sh luajit lua/test/semantic_index_runtime_observation_native_test.lua
bash tools/run_lua_project_data.sh puc lua/test/semantic_index_runtime_observation_generated_routes_test.lua
bash tools/run_lua_project_data.sh luajit lua/test/semantic_index_runtime_observation_generated_routes_test.lua
```

Exact bare-host diagnostic, executed on each host through its managed wrapper:

```bash
bash tools/run_lua_project_data.sh puc -e 'local function report(label,ok,value) print(_VERSION,label,ok,type(value),tostring(value)) end; report("nil",pcall(error,nil,0)); report("false",pcall(error,false,0)); report("string",pcall(error,"marker",0)); local marker={}; local ok,value=pcall(error,marker,0); print(_VERSION,"table",ok,value==marker)'
bash tools/run_lua_project_data.sh luajit -e 'local function report(label,ok,value) print(_VERSION,label,ok,type(value),tostring(value)) end; report("nil",pcall(error,nil,0)); report("false",pcall(error,false,0)); report("string",pcall(error,"marker",0)); local marker={}; local ok,value=pcall(error,marker,0); print(_VERSION,"table",ok,value==marker)'
```

Independent preservation passes for 1,392 prior source, fact, decision, history and
policy files; 2,479 of 2,488 prior task nodes remain exact. The nine changed owners
and six new pending repair/proof nodes match this slice. The parked parser tree,
both prior chronology suffixes and live-history query section remain exact. All
66 prior limitation headings remain, with one new heading; the audit was corrected
to compare headings alone after an authorized paragraph extension changed the
rest of its first line. Both embedded replay payloads match their executed bytes.
Independent coverage confirms all 99 baseline digests and 17 completed groups,
21,151 fragments /868,215 bytes. Both histories, Knowledge, memory, rendered book
and normal doctrine hooks govern landing. The
approved named-argument direction remains parked; all startup and ADR0118 controls
remain unchanged. No PGEN/RGX build or push belongs to this reading slice.

Landing checks pass: Knowledge generation has 1,103 facts /8,844 question keys;
MEMORY is 60 lines; change history is 333 lines /22,681 bytes and engineering
notes are 263 lines /18,844 bytes, with no rollover required. The rendered book
build passes; its 10,068,856-byte search-index warning remains startup .41.9-owned.
The direct-dependent semantic contract recheck passes 6/20/128 with the same
qualified governance counts. Diff whitespace checks pass; normal hooks remain
required for the commit. These document checks do not erase the two failed tests.
