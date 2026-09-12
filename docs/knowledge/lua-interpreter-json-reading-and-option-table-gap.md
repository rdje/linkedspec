---
id: lua-interpreter-json-reading-and-option-table-gap
title: Lua interpreter completion and JSON reading confirm false option-table defaulting
answers:
  - what did Lua startup reading group ten cover
  - has the Lua interpreter been fully read
  - does Lua runtime_parse reject a false options table
  - do Lua traced runtime entry points validate false options
  - which task owns nil-only Lua runtime option-table defaults
  - which JSON and runtime controls support Lua reading group ten
date: 2026-09-12
status: exact group ten read; runtime table validation owned by .2.8.3 and .2.8.4
tags: [lua, reading, interpreter, json, options, cursor, observation]
evidence: "LUA-STARTUP-READING.1.10 reads 1500 fragments /51687 bytes from 7d3fb5427634cbbc5b80214149e37afbf48038b0, completing interpreter.lua and reading json.lua 1-282. Runtime/JSON68, cursor108 and observation43 assertions pass per installed host,438 total. Separate five-route false-options observations extend existing .2.8 with two bounded repair/proof children."
reverify:
  - "Run the exact managed runtime/JSON replay below on both installed Lua hosts."
  - "bash tools/run_lua_project_data.sh puc lua/test/rule_local_cursor_execution_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/rule_local_cursor_execution_test.lua"
  - "bash tools/run_lua_project_data.sh puc lua/test/recursive_observation_contract_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/recursive_observation_contract_test.lua"
  - "bash tools/run_python_project_data.sh tools/check_rule_local_cursor_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_root_rule_selection_contract.py"
  - "Run LUA_READING_COVERAGE in docs/knowledge/lua-startup-reading-coverage.md."
---

# Exact physical coverage

Activation is `7d3fb5427634cbbc5b80214149e37afbf48038b0`; frozen baseline remains
`baeb984e36a94a15951cd23d4c52def5064cdaca`.

| Range | LF fragments | Bytes | SHA-256 |
| --- | ---: | ---: | --- |
| interpreter.lua 4417–5634 | 1218 | 43522 | cffd9b2545fcdac9c88b3d863e290b4a4dcff6469f41b076b24b23e506903fd0 |
| json.lua 1–282 | 282 | 8165 | 4fce526568a279f54f0dc5c7baf33e24b8e1aae0ee49175326fa344574176f0c |

Both paths are under `lua/src/linkedspec/`. Ten complete untruncated windows are
interpreter 4417–4586,4587–4756,4757–4926,4927–5096,5097–5266,5267–5436,
5437–5606,5607–5634 and JSON 1–150,151–282. The group is 1,500 fragments /51,687
bytes; its ordered-range SHA is
`451384fb9c5e48d276ef26a2682c263a60745e846baf82f36ed688d7f3fc0922`.
Cumulative coverage is 10/51 groups, 14,445 fragments /558,251 bytes. Sixteen
complete files include the interpreter; JSON remains partial. .1.11 owns its
suffix, matching.lua and the generated MCP prefix.

Rechecking already-read engine/default/export lines and inspecting the first 80
lines of the cursor consumer for its managed execution boundary add no source
reading credit beyond these exact ranges.

# Comprehension and canonical reconciliation

Eager block completion preserves local return and copied final values. Registered
user functions normalize contextual arguments, reject keywords, prepare isolated
copied stores and restore caller stores, binding identities and active paths on
both success and failure. Staged bodies are accepted only when reparsed source and
canonical retained AST agree; the cache key contains both representations.

Lifecycle and slot events use typed payloads and rule-local marks. Ordered matching
retains target/index identity; choice matching, semantic observations and gap
candidates share compiled slot projections. Action edges cache child dispatch,
collect applicable explicit iteration values and retain local-match registers.
Blind dispatch follows the entered rule's AND/OR policy and copies child values.

Each rule derives family/cursor/dispatch policy at entry, isolates runtime stores,
tracks recursion and recognition invocation state, and restores caller state on
exit. Repetition owns lifecycle phases, selected gap candidates, bounds and cursor
progress. Recognition completion records terminal outcomes before frame cleanup.
Generated-family trace identity accompanies the same ordinary execution. Existing
repair owners remain: this reading does not establish new lifecycle or recursion
semantics beyond its selected checks.

Public parsing validates engine/input and supplied option fields, resolves the
entry rule before parse scope, constructs invocation-local state and applies the
public wrapper's leading-input handling. Execution preserves diagnostic and
semantic sink failure identity. Staged enrichment precedes detached result/output
projection; trace scopes close across normal and documented failure paths.
Parse/execute aliases share an implementation. Traced wrappers copy options and
install an emitter. Private receiver-mutation test seams remain absent from the
root facade. JSON projection explicitly enumerates runtime diagnostic/result fields.

The JSON prefix provides explicit null/array/harray identities. Constructors copy
the outer supplied table and require string harray keys. UTF-8 validation checks
continuation ranges, overlong encodings, surrogate exclusion and the upper scalar
limit, returning the first invalid byte position. Decoding accepts only JSON
whitespace, validates four-digit Unicode escapes and surrogate pairs, rejects
unescaped controls, and parses finite decimal/exponent numbers without leading
zeroes. Array decoding only begins in this scope; the suffix and encoder remain
.1.11-owned even though public JSON roundtrip probes execute their current code.

Canonical retrieval covered [[lua-root-rule-selection-routes]],
[[lua-rule-local-cursor-execution]], [[lua-recursive-observation-admission]],
[[lua-trace-controls-sinks]], [[lua-frontend-ast-json-contract]] and
[[lua-fixed-v1-user-function-runtime]]. Their earlier counts and rollout statements
remain dated evidence. The fresh cursor consumer reports 108, not the older
110-assertion initial execution count or 119-assertion composed admission count.

# Explicit false option tables bypass validation

| Public entry | Omitted / empty table | true / number 0 / string | false |
| --- | --- | --- | --- |
| runtime_engine | valid | typed table error | accepted as defaults |
| runtime_parse / runtime_execute | valid | typed table error | accepted as defaults |
| runtime_parse_with_trace / runtime_execute_with_trace | valid | typed table error | accepted as defaults |

Both installed hosts agree; every successful route preserves the fixture's false
parse value. Engine 141–142, parse 5305–5306 and traced parse 5500–5501 each apply
`options = options or {}` before their explicit table-type check. Execute names
are aliases. An explicitly supplied false therefore disappears before validation,
while the compared non-table inputs reach the typed error.

Existing `.2.8` owns runtime configuration validation. Its original .2.8.1/.2
remain the distinct numeric iteration-field repair/proof. New .2.8.3 corrects the
three optional-table owners and .2.8.4 independently verifies all public aliases
and applicable adapters. This follows the parent's requirement to decompose
additional option surfaces before expansion. Preserve valid/omitted options,
caller-table identity, removed-option diagnostics, trace behavior and parse results.
All ten local repair roots retain startup reading/book/policy and declared-runtime
prerequisites. No production source changes in this leaf.

# Focused proof and limits

The exact native script passes 68 controls per installed host: 25 options controls,
16 JSON decode/roundtrip controls, 10 invalid JSON cases, 6 valid UTF-8 sequences,
7 invalid UTF-8 first-byte positions and 4 explicit JSON-constructor controls.
The five false-options acceptances per host are separate defect observations.
The unchanged cursor consumer passes 108 and recursive observation passes 43 on
each host, for 438 total passing assertions across all six native runs. All
outputs and cleanup results are consumed. Installed hosts remain PUC 5.5.1 and
LuaJIT 2.1.1788460057; this does not establish declared PUC 5.4 conformance.

Neutral cursor proof passes 36 families/18 edges/8 parent-child cases, 6 runtime
legs, 30 public documents, 28 current-claim denials, 74 migration files and 60 drift
mutations at 8 complete/0 pending. Root proof passes 8 selection/3 failure/3 strict
cases, 5 backends, 24 public documents, 18 current-claim denials and 54 mutations at
7 complete/0 pending. No full component, corpus or canonical gate is claimed.
The earlier public-selector baseline failure remains pending under startup .28.7;
[[lua-interpreter-helper-reading-and-false-delimiter-gap]] retains its exact proof.

# Exact native replay

The payload is 2760 bytes; SHA-256 `8f0d7421748fff13c5243ec894df28e843d1d2cdf59e59a7d3bb00f5913f4326`.

```bash
bash tools/project_data_run.sh python3 - <<'LUA110_REPLAY'
from pathlib import Path
p=Path('.linkedspec-data/scratch/lua110/runtime-json-proof.lua')
p.parent.mkdir(parents=True,exist_ok=True)
p.write_text(r'''local l=require("linkedspec")
local j=l.json
local checks=0
local function check(v,label) assert(v,label);checks=checks+1 end
local c=l.compile_spec(l.parse_spec('Top::\n /x/\n I {return(false)}\n'))
local e=l.runtime_engine(c)
local config=l.trace_config_disabled()
local routes={
 {"engine",function(options) return l.runtime_parse(l.runtime_engine(c,options),"").value end},
 {"parse",function(options) return l.runtime_parse(e,"",options).value end},
 {"execute",function(options) return l.runtime_execute(e,"",options).value end},
 {"parse_trace",function(options) return l.runtime_parse_with_trace(e,"",config,options).value end},
 {"execute_trace",function(options) return l.runtime_execute_with_trace(e,"",config,options).value end},
}
print("RUNTIME ".._VERSION..(jit and " "..jit.version or ""))
for _,route in ipairs(routes) do
 check(route[2](nil)==false,route[1].." omitted options")
 check(route[2]({})==false,route[1].." empty options")
 for _,invalid in ipairs({true,0,"options"}) do
  local ok,err=pcall(route[2],invalid)
  check(not ok and l.is_runtime_interpreter_error(err) and
    tostring(err):find("options must be a table",1,true),route[1].." typed invalid options")
 end
 local ok,value=pcall(route[2],false)
 print("OBSERVED false options "..route[1].." accepted="..tostring(ok).." value="..j.encode(value))
end
for _,row in ipairs({{'""',""},{'"a\\nb"',"a\nb"},{'"\\u0000"',string.char(0)},
 {'"\\u00e9"',"é"},{'"\\ud83d\\ude00"',"😀"},{"0",0},{"-0",0},{"-1.25e2",-125}}) do
 local value=j.decode(row[1]);check(value==row[2],"JSON decoded "..row[1])
 check(j.decode(j.encode(value))==value,"JSON roundtrip "..row[1])
end
for _,text in ipairs({'01','1.','1e','1e999','"\\uD800"','"\\uDC00"','"\\uD800\\u0041"','"\\x"','"unterminated','"a'..string.char(0)..'b"'}) do
 local ok,err=pcall(j.decode,text)
 check(not ok and tostring(err):find("JSON error",1,true),"JSON rejection")
end
for _,text in ipairs({"", "ASCII", "é", "€", "😀", string.char(0xF4,0x8F,0xBF,0xBF)}) do
 check(j.validate_utf8(text)==true,"valid UTF8")
end
for _,bytes in ipairs({{0x80},{0xC0,0x80},{0xC2},{0xE0,0x80,0x80},{0xED,0xA0,0x80},{0xF4,0x90,0x80,0x80},{0xF5,0x80,0x80,0x80}}) do
 local pieces={};for _,b in ipairs(bytes) do pieces[#pieces+1]=string.char(b) end
 local ok,index=j.validate_utf8("A"..table.concat(pieces))
 check(ok==false and index==2,"invalid UTF8 position")
end
check(j.kind(j.array({false}))=="array" and j.array({false})[1]==false,"typed array false")
check(j.kind(j.harray({k=false}))=="harray" and j.harray({k=false}).k==false,"typed harray false")
for _,constructor in ipairs({j.array,j.harray}) do
 local ok=pcall(constructor,false);check(not ok,"constructor rejects false table")
end
print("PASS "..checks.." valid controls")
''')
LUA110_REPLAY
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua110/runtime-json-proof.lua
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua110/runtime-json-proof.lua
```

# Continuity

Exact source/range identity, preservation, current book/frontier synchronization,
Knowledge, memory, histories and rendered book govern this ordinary reading
commit. Earlier cards, decisions, source and archive bytes remain intact.

Independent reconstruction passes all 99 sources/51 groups/149 ranges and the exact native replay payload. Preservation retains 1,382 prior source/card/decision/history files, 2,461 unchanged prior task nodes and all 62 Known headings; exactly two pending option-table repair nodes are added. Knowledge is 1096/8804, memory 60 lines, histories 284/431 (notes warning, no rollover) and rendered book passes. The existing 10,044,276-byte search-index warning retains startup .41.9 ownership; normal doctrine hooks govern landing.
