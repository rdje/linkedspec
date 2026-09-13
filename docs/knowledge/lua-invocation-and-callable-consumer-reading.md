---
id: lua-invocation-and-callable-consumer-reading
title: Lua invocation completion and callable consumer reading exposes nested argument-array loss
answers:
  - "what exact Lua source did startup reading child 30 cover"
  - "does Lua function invocation preserve every nested tagged array member"
  - "can Lua invocation discard a cycle stored in an extra array member"
  - "does Lua validate nested argument arrays as strictly as the outer argument list"
  - "does Lua invocation accept false active names or false options"
  - "what callable and body fluent proof ran during Lua reading child 30"
  - "which diagnostic output test prefix was executed during Lua reading child 30"
date: 2026-09-13
status: exact scoped reading complete; nested argument-copy and active-path repairs pending
tags: [lua, invocation, arrays, callable, diagnostics, startup, evidence]
evidence: "LUA-STARTUP-READING.1.30 activates from 4a5feb8ff5a65a82b10a2db8d4dc67f3fdb1a474. All 1500 fragments /60799 bytes are read in eight complete windows. Both installed hosts pass 1564 focused assertions and agree on 46 complete graph/default observations. New .2.33 owns lost nested tagged-array members; .2.8.27/.28 own active-name defaults and existing options gain invocation. No source repair or full gate."
reverify: "Run LUA_INVOCATION_READING_30 and the managed commands below; malformed acceptances are intake evidence, not passing repair criteria."
---

# Exact reading and comprehension

Every byte is read in eight complete, untruncated windows:

| Repository source | Inclusive lines | Fragments / bytes | Raw SHA-256 |
| --- | --- | --- | --- |
| lua/src/linkedspec/user_function_registry.lua | 368–539 | 172 /6,256 | 01eaacb0d8f42e29331f256549f3b9d0f37ddc9ce28c045a5c6252e02b990101 |
| lua/test/body_fluent_whole_token_test.lua | 1–137 | 137 /7,063 | 2c43748fa94ae3c464b513d77dbe7f1982bfc7579e532c06db1b2ed167977aef |
| lua/test/callable_codeblock_literal_contract_test.lua | 1–950 | 950 /38,939 | 5172c8d4d7ac5db9b22c67d39ec97c2556a298e336d2d083a550d27ff82cdd9f |
| lua/test/diagnostic_output_contract_test.lua | 1–241 | 241 /8,541 | 77858a28d277bb0ab216a4de2d035779c819428016a84bf78ee4078fed009baa |

The callable test windows are 1–220, 221–440, 441–660, 661–850 and 851–950;
each other range has one window. Ordered range SHA-256 is
`f3f1e9a54ed0dbb2b52b171dcc5bf01141ae86b6deb0121f91d40d7eac08f093`.
All 99 Lua sources remain baseline-identical to
`baeb984e36a94a15951cd23d4c52def5064cdaca`. Coverage reaches 30/51 groups,
40,651 fragments /1,503,281 bytes and 54 complete files; diagnostics remains partial.

The registry suffix stitches a selected body job into a new typed SpecFile while
retaining rule/source identity. Invocation validates the outer argument list,
resolves fixed/variadic arity and final-codeblock presence/kind, detects an ordered
active-function cycle and builds copied argument/scalar/array/harray stores.
Rest values form a fresh typed array; the active path is copied before appending
the current function. Argument evaluation remains the caller runtime's responsibility;
this API consumes evaluated values and does not execute the user-function body.
The nested-copy and default-admission limitations below qualify its validation.

The complete body-fluent consumer owns seven invalid suffix classes, exact raw
remainder/line/type/error preservation, empty/dollar/newline comparisons and valid
ASCII/chained/comment/lifecycle/regex/edge continuations. This is the repaired
whole-token adapter, not the unfinished argument delimiter defect under `.2.24`.
The retrieved [[lua-body-fluent-suffix-loss]] still ends with a stale future
source/outcome-planning pointer; existing `.2.1` now owns that exact qualification
without rewriting its earlier milestones or the actual repaired behavior.

The complete callable consumer covers brace classification, exact eight-field
literal records, fixed/rest signatures and containing Unicode spans; all neutral
literal errors; inert construction/copy/function transport; deferred body contracts;
typed colon keyword rejection and positional `name = value` assignment; dynamic
call order, parameter copies, live nonparameter state, static callable precedence,
local return, call-result access and contextual/helper forms. Direct, mutual and
helper-mediated recursion preserve ordered typed failures. These are current
contracts; the accepted named-argument direction remains parked separately.

Its emitted-route section writes exact modules and a manifest below managed
repository-local TMPDIR, executes a fresh host with inherited module paths, compares
values and inner failure details, checks corrupt-payload rejection, and proves
workspace removal on success and injected failure. The final semantic binding
check preserves the callable signature. There is one existing executor and codec;
this reading introduces neither a new callable route nor a syntax change.

The diagnostic prefix reads the neutral contract, typed event collection, quiet
and traced aliases, scalar rendering, early arity rejection, wrong-kind behavior,
immediate typed exit and exact caller sink-failure identity. Line 239 closes those
complete tests; line 241 opens the next block, whose body remains `.1.31`. The
focused executable prefix therefore stops at 240 and checks the accumulated failure
list, without manufacturing a result for the unread remainder.

Knowledge was retrieved before code derivation: [[lua-user-function-registry]],
[[lua-fixed-v1-user-function-runtime]], [[lua-body-fluent-suffix-loss]],
[[lua-diagnostic-output-events]], [[lua-callable-codeblock-literal-state]],
[[lua-explicit-callable-codeblock-gap]], [[lua-callable-codeblock-dynamic-invocation]]
and [[lua-callable-codeblock-emitted-route-identity]]. The explicit callable gap is
marked historical and closed; lexical capture remains an intentional exclusion.
Existing AST/staged array facts retain separate ownership from runtime arguments.

# Confirmed nested argument-array loss — .2.33

Use the public invocation API with the actual compiled function registry and one
already-evaluated argument. Four malformed tagged shapes are accepted:

- `[7]` with an additional `extra=false` member loses that member.
- An array with index 1 equal to 7 and index 3 equal to false loses its sparse tail.
- `[7]` with an extra member referencing the same array loses that cycle edge.
- A harray containing the sparse array retains only the nested array's first item.

Every caller graph remains unchanged, but the frame's arguments and parameter
stores contain the shortened copies. `clone_runtime_value` copies a tagged array
with `ipairs` at registry line 105 without checking all keys/density. The outer
`evaluated_values` list has a separate dense-list check; it does not validate the
nested value. Existing active-cycle detection sees only members it traverses.

Nine cases per host include those four malformed acceptances, a dense false/null/
aggregate control, and four proper rejections: direct array-element cycle, untyped
mixed table, extra top-level argument-list member, and sparse top-level argument
list. Complete graph snapshots retain every numeric/string key, tagged kind,
scalar and repeated-reference edge. The independent verifier checks the exact
whole copied graph and all parameter stores against the expected retained prefix,
as well as complete caller preservation. This avoids losing the disputed member
through the diagnostic JSON serialization itself.

`.2.33.1` owns complete nested-array admission and `.2.33.2` graph/consumer proof.
AST `.2.23` and staged identity `.2.25` remain independent repair owners. This is
malformed host-supplied runtime data at the public pre-execution boundary; no valid
source-authored sparse array, invocation-body execution or emitted malformed-input
carrier is claimed. No nonfinite-number probe or new numeric policy is involved.

# Confirmed optional active path and invocation options — .2.8

Registry lines 429–430 apply `active_names or {}` and `options or {}` before their
checks. Both false values become empty defaults. Nil and empty tables are valid;
true, zero and text reject through the established registry errors. A supplied
`other` active name survives as `other, one`; a supplied `one` correctly rejects
with code `user_function_recursion`, cycle `one -> one` and rule `Top`.

Fourteen cases per host preserve exact values, active paths and errors. Existing
`.2.8.21/.22` now include invocation as the ninth function-option route; their
original eight-route evidence stays dated. New `.2.8.27/.28` own the active-name
list boundary and independent recursion controls. Rejecting false here does not
change the language's recursion policy or introduce named arguments.

# Focused verification and limits

Both installed hosts pass these freshly executed checks:

| Consumer | Assertions per host |
| --- | --- |
| Complete body-fluent whole-token test | 166 |
| Complete callable construction/invocation/emitted test | 449 |
| Four selected registry/invocation tests | 62 |
| Complete diagnostic blocks in lines 1–240 | 105 |
| Total | 782 |

That is 1,564 assertions, including independently loaded emitted modules and both
cleanup paths. The original unselected runner and diagnostic suffix are not
counted. Selected registry tests cover rest-array isolation, non-mutating body
stitching, four-kind invocation values and typed arity/name/recursion errors.

The 46 complete diagnostic observations compare exactly across hosts. Their
complete canonical per-host JSON SHA-256 is
`799cfeb4faffc428444f88c135e790562f592a0868da4e31146576882e0e6f84`.
The prior `.1.29` neutral signature/codeblock checker results remain dated and
are not rerun: both contracts and both checker sources are byte-identical to that
commit. There is no full gate, dependency build, push, production source/tool
repair or repair closure. Installed PUC 5.5.1 and LuaJIT do not certify the pending
PUC 5.4 target. All thirty-three repair roots and earlier failures remain open.

Next `.1.31` reads diagnostic 242–327, duplicate-slot 1–467 and gap-capture 1–947.
Startup/ADR0118 and the approved parked authoring direction remain unchanged.

## Exact reproduction

```bash
bash tools/project_data_run.sh python3 - <<'LUA_INVOCATION_READING_30'
from pathlib import Path
p = Path(".linkedspec-data/scratch/lua130")
p.mkdir(parents=True, exist_ok=True)
(p / 'invocation.lua').write_text('local linked=require(\'linkedspec\')\nlocal json=require(\'linkedspec.json\')\nlocal source=\'fn one(value) { return(value) }\\nTop:: I.return("ok")\\n\'\nlocal spec=linked.parse_spec_with_staged_user_function_definitions(source)\nlocal registry=linked.user_function_registry_from_spec(spec)\nlocal function snapshot(value)\n  local ids={};local next_id=0\n  local function visit(item)\n    if item==json.null then return json.harray({kind=\'null\'}) end\n    if type(item)~=\'table\' then return json.harray({kind=type(item),value=item}) end\n    if ids[item] then return json.harray({reference=ids[item]}) end\n    next_id=next_id+1;ids[item]=next_id\n    local out=json.harray({id=next_id,kind=json.kind(item),entries=json.array()})\n    local keys={};for key in pairs(item)do keys[#keys+1]=key end\n    table.sort(keys,function(a,b)\n      if type(a)==type(b) then return a<b end\n      return type(a)<type(b)\n    end)\n    for _,key in ipairs(keys)do\n      out.entries[#out.entries+1]=json.harray({key_type=type(key),key=key,value=visit(item[key])})\n    end\n    return out\n  end\n  return visit(value)\nend\nlocal output=json.harray({copies=json.array(),defaults=json.array()})\nfor _,name in ipairs({\'dense\',\'array_extra_false\',\'array_sparse_tail_false\',\'array_extra_cycle\',\n    \'array_direct_cycle\',\'harray_nested_sparse\',\'plain_mixed\',\'top_extra\',\'top_sparse\'})do\n  local value=json.array({7})\n  if name==\'dense\' then value=json.array({false,json.null,json.harray({items=json.array({7})})})\n  elseif name==\'array_extra_false\' then value.extra=false\n  elseif name==\'array_sparse_tail_false\' then value[3]=false\n  elseif name==\'array_extra_cycle\' then value.extra=value\n  elseif name==\'array_direct_cycle\' then value[1]=value\n  elseif name==\'harray_nested_sparse\' then value[3]=false;value=json.harray({items=value})\n  elseif name==\'plain_mixed\' then value={7,extra=false} end\n  local arguments={value}\n  if name==\'top_extra\' then arguments.extra=false\n  elseif name==\'top_sparse\' then arguments[3]=false end\n  local before=snapshot(arguments)\n  local ok,result=pcall(linked.prepare_user_function_invocation,registry,\'one\',arguments,{}, {})\n  local row=json.harray({case=name,accepted=ok,before=before,after=snapshot(arguments)})\n  if ok then\n    row.arguments=snapshot(result.arguments)\n    row.variables=snapshot(result.variables)\n    row.arrays=snapshot(result.arrays)\n    row.harrays=snapshot(result.harrays)\n    row.active_path=json.array(result.active_path)\n  else row.error=tostring(result);row.registry_error=linked.user_function_registry.is_registry_error(result) end\n  output.copies[#output.copies+1]=row\nend\nlocal cases={{name=\'absent\'},{name=\'empty\',value={}},{name=\'false\',value=false},\n  {name=\'true\',value=true},{name=\'zero\',value=0},{name=\'text\',value=\'options\'}}\nfor _,field in ipairs({\'options\',\'active_names\'})do\n  for _,case in ipairs(cases)do\n    local names,options={},{}\n    if field==\'options\' then options=case.value else names=case.value end\n    local ok,result=pcall(linked.prepare_user_function_invocation,registry,\'one\',{\'ok\'},names,options)\n    local row=json.harray({field=field,case=case.name,accepted=ok})\n    if ok then row.value=result.variables.value;row.active_path=json.array(result.active_path)\n    else row.error=tostring(result);row.registry_error=linked.user_function_registry.is_registry_error(result)end\n    output.defaults[#output.defaults+1]=row\n  end\nend\nfor _,names in ipairs({{\'other\'},{\'one\'}})do\n  local ok,result=pcall(linked.prepare_user_function_invocation,registry,\'one\',{\'ok\'},names,{rule_label=\'Top\'})\n  local row=json.harray({field=\'active_names\',case=names[1],accepted=ok})\n  if ok then row.value=result.variables.value;row.active_path=json.array(result.active_path)\n  else row.error=tostring(result);row.code=result.code;row.cycle=result.cycle end\n  output.defaults[#output.defaults+1]=row\nend\nio.write(json.encode(output),\'\\n\')\n')
(p / 'select-tests.py').write_text('from pathlib import Path\nimport json\nnames = [\'user function registry resolves variadic arity and binds fresh typed rest arrays\', \'user function registry stitches body AST without mutating the source spec\', \'user function invocation frames copy supplied four-kind values into fresh stores\', \'user function invocation frames diagnose arity unknown calls and recursion\']\ns = Path(\'lua/test/run.lua\').read_text()\nselection = \'local selected = {\\n\' + \'\'.join((\'  [\' + json.dumps(n) + \'] = true,\\n\' for n in names)) + \'}\\nlocal assertions = 0\\n\'\ns = selection + s\nfor old, new in [(\'local function test(name, operation)\\n\', \'local function test(name, operation)\\n  if not selected[name] then return end\\n\'), (\'local function assert_equal(actual, expected, label)\\n\', \'local function assert_equal(actual, expected, label)\\n  assertions = assertions + 1\\n\'), (\'local function assert_contains(actual, expected, label)\\n\', \'local function assert_contains(actual, expected, label)\\n  assertions = assertions + 1\\n\')]:\n    assert s.count(old) == 1\n    s = s.replace(old, new, 1)\ns += \'\\nassert(total == 4, "selected test count drift")\\nio.write("selected assertions: ", assertions, "\\\\n")\\n\'\nPath(\'.linkedspec-data/scratch/lua130/selected.lua\').write_text(s)\n\nsource=Path("lua/test/diagnostic_output_contract_test.lua").read_text().splitlines(keepends=True)\nassert source[238]=="end\\n" and source[240]=="do\\n"\nPath(".linkedspec-data/scratch/lua130/diagnostic-prefix.lua").write_text("".join(source[:240])+\'\\nif #failures > 0 then error(table.concat(failures, "\\\\n"), 0) end\\nio.write("diagnostic prefix: ", assertions, " assertions passed\\\\n")\\n\')\n')
(p / 'verify.py').write_text("from pathlib import Path\nimport copy\nimport hashlib\nimport json\nimport subprocess\n\nroot=Path('.linkedspec-data/scratch/lua130')\nhosts=[json.loads((root/('invocation-'+h+'.json')).read_text()) for h in ['puc','luajit']]\nassert hosts[0]==hosts[1]\npin='799cfeb4faffc428444f88c135e790562f592a0868da4e31146576882e0e6f84'\nfor data in hosts:\n    assert hashlib.sha256(json.dumps(data,ensure_ascii=False,sort_keys=True,separators=(',',':')).encode()).hexdigest()==pin\ndata=hosts[0];assert len(data['copies'])==9 and len(data['defaults'])==14\naccepted={'dense','array_extra_false','array_sparse_tail_false','array_extra_cycle','harray_nested_sparse'}\nfor row in data['copies']:\n    assert row['before']==row['after']\n    assert row['accepted']==(row['case'] in accepted)\n    if row['accepted']:\n        expected=copy.deepcopy(row['before'])\n        value=expected['entries'][0]['value']\n        if row['case']=='harray_nested_sparse':\n            nested=value['entries'][0]['value'];assert len(nested['entries'])==2\n            nested['entries']=nested['entries'][:1]\n        elif row['case']!='dense':\n            assert len(value['entries'])==2\n            if row['case']=='array_extra_cycle':assert value['entries'][1]['value']=={'reference':2}\n            value['entries']=value['entries'][:1]\n        assert row['arguments']==expected\n        stores=copy.deepcopy(expected)\n        stores['entries'][0]['key']='value';stores['entries'][0]['key_type']='string'\n        assert row['variables']==stores\n        empty={'id':1,'kind':'table','entries':[]}\n        assert row['arrays']==(stores if value['kind']=='array' else empty)\n        assert row['harrays']==(stores if value['kind']=='harray' else empty)\n        assert row['active_path']==['one']\n    else:assert row['registry_error'] is True and row['error'].startswith('UserFunctionRegistryException: ')\nfor row in data['defaults']:\n    accepted=row['case'] in ['absent','empty','false','other']\n    assert row['accepted']==accepted\n    if accepted:\n        assert row['value']=='ok'\n        assert row['active_path']==(['other','one'] if row['case']=='other' else ['one'])\n    elif row['case']=='one':\n        assert row['code']=='user_function_recursion' and row['cycle']=='one -> one'\n        assert row['error']=='UserFunctionRegistryException: user function recursion is not supported: one -> one in rule Top'\n    else:\n        assert row['registry_error'] is True\n        assert row['error']=='UserFunctionRegistryException: '+('invocation options must be a table' if row['field']=='options' else 'active_names must be a dense list')\nfor row in json.loads((root/'scope.json').read_text()):\n    raw=b''.join(Path(row['path']).read_bytes().splitlines(keepends=True)[row['start']-1:row['end']])\n    assert len(raw)==row['bytes'] and hashlib.sha256(raw).hexdigest()==row['sha256']\nbase='4a5feb8ff5a65a82b10a2db8d4dc67f3fdb1a474'\nfor name in ['capability_conformance/callable_signature_contract.json','tools/check_callable_signature_contract.py',\n             'capability_conformance/callable_codeblock_contract.json','tools/check_callable_codeblock_contract.py']:\n    assert Path(name).read_bytes()==subprocess.check_output(['git','show',base+':'+name]),name\nreport={'complete_observations':46,'per_host_copy_cases':9,'per_host_default_cases':14,\n        'canonical_sha256':pin,'prior_neutral_proof_inputs_unchanged':4}\n(root/'verification.json').write_text(json.dumps(report,indent=2)+'\\n');print(json.dumps(report,indent=2))\n")
(p / 'scope.json').write_text('[\n  {\n    "path": "lua/src/linkedspec/user_function_registry.lua",\n    "start": 368,\n    "end": 539,\n    "bytes": 6256,\n    "sha256": "01eaacb0d8f42e29331f256549f3b9d0f37ddc9ce28c045a5c6252e02b990101"\n  },\n  {\n    "path": "lua/test/body_fluent_whole_token_test.lua",\n    "start": 1,\n    "end": 137,\n    "bytes": 7063,\n    "sha256": "2c43748fa94ae3c464b513d77dbe7f1982bfc7579e532c06db1b2ed167977aef"\n  },\n  {\n    "path": "lua/test/callable_codeblock_literal_contract_test.lua",\n    "start": 1,\n    "end": 950,\n    "bytes": 38939,\n    "sha256": "5172c8d4d7ac5db9b22c67d39ec97c2556a298e336d2d083a550d27ff82cdd9f"\n  },\n  {\n    "path": "lua/test/diagnostic_output_contract_test.lua",\n    "start": 1,\n    "end": 241,\n    "bytes": 8541,\n    "sha256": "77858a28d277bb0ab216a4de2d035779c819428016a84bf78ee4078fed009baa"\n  }\n]\n')
LUA_INVOCATION_READING_30
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua130/select-tests.py
bash tools/run_lua_project_data.sh puc lua/test/body_fluent_whole_token_test.lua
bash tools/run_lua_project_data.sh luajit lua/test/body_fluent_whole_token_test.lua
bash tools/run_lua_project_data.sh puc lua/test/callable_codeblock_literal_contract_test.lua
bash tools/run_lua_project_data.sh luajit lua/test/callable_codeblock_literal_contract_test.lua
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua130/selected.lua
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua130/selected.lua
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua130/diagnostic-prefix.lua
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua130/diagnostic-prefix.lua
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua130/invocation.lua > .linkedspec-data/scratch/lua130/invocation-puc.json
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua130/invocation.lua > .linkedspec-data/scratch/lua130/invocation-luajit.json
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua130/verify.py
```

Related facts: [[lua-startup-reading-coverage]], [[lua-reading-evidence-capacity-admission]],
[[lua-function-projection-reading-and-boundary-gaps]].

## Preservation and documentation verification

The independent audit preserves all 1,405 prior source, Knowledge, decision,
immutable-history and policy files. Seven old task nodes change among 2,577:
this reading leaf, Lua .2/.2.1/.2.8/.2.8.21/.2.8.22 and startup .3.6; all other
2,570 nodes remain exact. Five new nodes are explicitly pending. Both prior
history suffixes, live History query instructions, all 89 earlier Known book
headings and the parked authoring tree remain exact. The book adds one Known
heading, reaching 90. Four embedded payloads equal the executed files. Full
range replay reproduces every baseline digest and all 30 completed groups.

Knowledge regeneration reports 1,116 facts /8,934 question keys. Memory passes
at 60 lines. The shared history checker passes 34 mutation controls and all
three surfaces /66 segments. Changes is 424 lines /30,951 bytes and Notes is
354 /28,482; neither needs rollover. The book renders; its 10,123,630-byte
search-index warning remains startup .41.9-owned. `git diff --check` passes.
Normal registered hooks remain required for the focused commit; no source
repair, full gate or supported-runtime certification is represented as complete.
