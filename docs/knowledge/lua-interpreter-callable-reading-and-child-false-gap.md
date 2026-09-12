---
id: lua-interpreter-callable-reading-and-child-false-gap
title: Lua callable and statement reading isolates false whole-child push loss
answers:
  - what did Lua startup reading group nine cover
  - does Lua whole child push preserve a false result
  - why does Lua push Child append null instead of false
  - which task fixes Lua implicit and explicit false child push
  - which Lua callable proofs were rerun during interpreter reading
  - why do older Lua callback cards still call explicit literals future
date: 2026-09-12
status: exact group nine read; false whole-child push repair pending under .2.10
tags: [lua, reading, callable, child, push, false, interpreter]
evidence: "LUA-STARTUP-READING.1.9 reads 1500 fragments /58443 bytes from 4a3d170d335b0fa2aad17e3f9acbbc7e53805d0a. Both installed hosts pass26 valid controls and the unchanged449-assertion callable consumer. Separate whole-child false observations reproduce null substitution; .2.10 owns repair and independent carrier proof. Existing .2.1 gains stale explicit-callable guidance correction."
reverify:
  - "Run the exact managed native replay below on both installed Lua hosts."
  - "bash tools/run_lua_project_data.sh puc lua/test/callable_codeblock_literal_contract_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/callable_codeblock_literal_contract_test.lua"
  - "bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_uniform_binding_contract.py"
  - "Run LUA_READING_COVERAGE in docs/knowledge/lua-startup-reading-coverage.md."
---

# Exact reading

Activation is `4a3d170d335b0fa2aad17e3f9acbbc7e53805d0a`; frozen baseline
remains `baeb984e36a94a15951cd23d4c52def5064cdaca`.
Every byte of `lua/src/linkedspec/interpreter.lua` lines2917–4416 was read in
nine complete untruncated windows:2917–3086,3087–3256,3257–3426,3427–3596,
3597–3766,3767–3936,3937–4106,4107–4276,4277–4416.

The 58,443-byte range SHA-256 is
`e4b4cea4372230681ab9e1cadbfc074a143c75a66048262237d98aefd4986a57`;
ordered-range SHA is
`6a6df80d62f8e687d41b08451bdeb320506faff6325cf7a746f51e043074a016`.
Cumulative reading reaches 9/51 groups, 12,945 fragments /506,564 bytes, with
15 complete files and a partial interpreter. .1.10 continues that suffix before
reading the JSON prefix. Rechecking already-read read_index 620–630 adds no credit.

# Comprehension and canonical reconciliation

Callable execution validates fixed/rest arity, preserves keyword diagnostics,
constructs copied parameter bindings and tracks ordered bound-name recursion.
The scoped frame restores parameters and active-call state on normal or failed
execution; nonparameter caller bindings remain live. Body return is local and
results copy outward. Built-in callback identity differs from an anonymous helper
name, preserving nested anonymous callbacks and bound callback recursion checks.

Ordinary calls resolve registered functions and governed controls/helpers before
bound values. Gap/capture, scoped with, split, coalescing, array/harray, numeric,
mark, diagnostic and logical operations retain their dedicated owners. Return,
next, typed exit, direct/cached child calls and rule-target push preserve separate
control paths. Whole child push has the false-selection defect below; ordinary
and indexed push controls distinguish its narrow cause.

Fluent evaluation dispatches scoped callbacks, named array-end mutations, pure
helpers and terminal continuation rules. Receiver map_leaves mutation validates
binding identity and root kind, copies the original tree, releases its active
guard on failure and publishes before continuation. Expression dispatch preserves
typed scalar/aggregate/callable values, read copying, progressive/staged adapters,
assignment guards, evaluated dense nested paths and recognition operations.

Dropped statements select mutating regex substitution, split, array transforms
and harray set-key before ordinary expression evaluation. Regex mutation evaluates
pattern/flags/replacement through the existing native adapter and then binds the
result. Attached and marker if/switch forms validate their structural ranges;
switch evaluates its subject once and selects the first matching range. While
owns its iteration counter and local next handling. The indexed statement driver
rejects orphan controls. Eager block evaluation begins here, treating its final
expression as a value and catching only local return; its final loop suffix is
part of .1.10 rather than claimed read in this leaf.

Canonical homes were retrieved before diagnosis:
[[lua-callable-codeblock-dynamic-invocation]],
[[lua-contextual-user-function-codeblock-runtime]],
[[lua-callable-codeblock-emitted-route-identity]],
[[lua-runtime-builtin-final-codeblocks-with]], [[lua-runtime-eager-block-values]],
[[lua-runtime-array-mutation-child-flow]], [[lua-action-edge-child-call-reuse]],
[[lua-statement-regex-mutation]], [[lua-runtime-switch-statement-controls]],
[[write-vivification-lua-runtime]] and [[map-leaves-mutation-lua-runtime]].
The older with/eager-block cards still describe explicit callable values as
future. Existing .2.1 and its repair/proof children now own these exact wording
corrections; the emitted-identity card and current449-assertion consumer establish
the superseding implementation. Old cards and their original counts remain intact.
Existing switch comparison/placement and runtime repair owners remain unchanged.

# Confirmed false whole-child push loss

| Form with Child returning false | Observed value |
| --- | --- |
| `push(Child); return(Top)` | `[null]` |
| `items=[]; push(Child,items); return(items)` | `[null]` |
| `return(call(Child))` | `false` |
| `items=[]; push(items,call(Child)); return(items)` | `[false]` |

Both installed hosts agree. Whole-result true, numeric zero, empty string, array,
harray and null controls preserve their values through both implicit and explicit
forms. Indexed implicit/explicit child pushes also preserve an element false.

Interpreter 3245 chooses `child_index == nil and child.value or
read_index(child.value, child_index)`. When the index is absent and the whole value
is false, the trailing `or` incorrectly selects indexing. The already-read
read_index 620–630 returns null for a scalar receiver, so the accumulator gets null.
The documented child-push contract calls for the whole result in those forms.

`.2.10.1` owns explicit optional-index selection, with matched value and copy
controls. `.2.10.2` independently verifies supported native/reconstructed/generated/
emitted routes and cached action-edge once-only behavior. This probe establishes
the two native direct-child forms, not a new whole carrier matrix or fresh edge
cache proof. Keep false delimiter .2.9 and invalid iteration-option .2.8 separate.
All ten local repair roots retain startup reading/book/policy prerequisites and
the declared PUC identity requirement under .2.2.

# Focused verification

The unchanged callable consumer passes 449 assertions on each installed host,
including its existing native/reconstructed/generated/fresh-emitted boundaries.
The additional exact script passes 26 valid controls per host: twelve matched
whole-child values, direct/ordinary/indexed false handling, callable arguments,
parameter restoration, dynamic caller mutation, contextual/bound callbacks,
map-leaves false, nested-write false, dropped regex substitution, bounded while
and eager block return. Together these are 950 passing assertions; the two
whole-false defect observations per host are separate. All four native runs and
cleanup outcomes are consumed. Installed hosts remain PUC 5.5.1 and
LuaJIT 2.1.1788460057; no declared PUC 5.4 certification is inferred.

Neutral callable proof passes 7 literals/11 calls/9 invalid literals/7 invalid
calls/4 invalid declarations/8 contextual forms and 23 governance mutations.
Uniform binding passes 11 migrations/7 executions/6 invalid selectors/8 constructors.
No full component or canonical gate is claimed. The prior public-selector
baseline failure remains owned by startup .28.7; see
[[lua-interpreter-helper-reading-and-false-delimiter-gap]]. It is not silently
reclassified as passing by these independent focused checks.

# Exact native replay

The payload is 2292 bytes; SHA-256 `02e61253be75e86dd5b83d501bcf308da17305426c552dfe2f7624c5a91dc1af`.
Run from repository root through the managed native wrapper:

```bash
bash tools/project_data_run.sh python3 - <<'LUA19_REPLAY'
from pathlib import Path
p=Path('.linkedspec-data/scratch/lua19/runtime-proof.lua')
p.parent.mkdir(parents=True,exist_ok=True)
p.write_text(r'''local l=require("linkedspec")
local j=l.json
local checks=0
local function eq(actual,expected,label)
 assert(j.encode(actual)==expected,label..": "..j.encode(actual).." ~= "..expected)
 checks=checks+1
end
local function run(code,child)
 local text='Top::\n /x/\n E { '..code..' }\n'
 if child then text=text..'\nChild::\n /x/\n E { return('..child..') }\n' end
 return l.runtime_parse(l.runtime_engine(l.compile_spec(l.parse_spec(text))),"").value
end
print("RUNTIME ".._VERSION..(jit and " "..jit.version or ""))
for _,row in ipairs({{"true","true"},{"0","0"},{'""','""'},
 {'[false]','[false]'},{'{"k":false}','{"k":false}'},{"undef","null"}}) do
 eq(run('push(Child);return(Top)',row[1]),'['..row[2]..']',"implicit "..row[1])
 eq(run('items=[];push(Child,items);return(items)',row[1]),'['..row[2]..']',"explicit "..row[1])
end
eq(run('return(call(Child))','false'),'false','direct false child')
eq(run('items=[];push(items,call(Child));return(items)','false'),'[false]','ordinary false push')
eq(run('push(Child,0);return(Top)','[false]'),'[false]','indexed implicit false')
eq(run('items=[];push(Child,items,0);return(items)','[false]'),'[false]','indexed explicit false')
eq(run('cb={|x| return(x)};return(cb(false))'),'false','callable false argument')
eq(run('x="outer";cb={|x| return(x)};cb(false);return(x)'),'"outer"','parameter restoration')
eq(run('flag=true;cb={|| flag=false;return(flag)};cb();return(flag)'),'false','dynamic caller mutation')
eq(run('return(with(false){return(value)})'),'false','contextual false')
eq(run('cb={|x| return(x)};return(with(false,cb))'),'false','bound callback false')
eq(run('tree=[true];tree.map_leaves!(){return(false)};return(tree)'),'[false]','mutation false leaf')
eq(run('doc["k"][0]=false;return(doc)'),'{"k":[false]}','nested write false')
eq(run('text="aba";regex_subst(text,"a","x","g");return(text)'),'"xbx"','dropped regex mutation')
eq(run('flag=true;while(flag){flag=false};return(flag)'),'false','bounded while')
eq(run('result={return(false)};return(result)'),'false','eager block false')
print("OBSERVED implicit false child "..j.encode(run('push(Child);return(Top)','false')))
print("OBSERVED explicit false child "..j.encode(run('items=[];push(Child,items);return(items)','false')))
print("PASS "..checks.." valid controls")
''')
LUA19_REPLAY
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua19/runtime-proof.lua
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua19/runtime-proof.lua
```

# Continuity

The reading leaf preserves all source, prior cards/decisions and immutable history,
synchronizes the current book/frontier and records concrete repair children before
any implementation. Exact coverage, preservation, memory, Knowledge, histories and
rendering proof govern its ordinary per-leaf commit; later prerequisites remain.

Independent reconstruction passes 99 sources/51 groups/149 ranges and the exact native replay payload. Preserve 1,381 prior source/card/decision/history files, 2,456 unchanged prior task nodes and all 61 prior Known headings; exactly three pending .2.10 nodes are added. Knowledge 1095/8798, memory 60, histories 277/424 (notes warning, no rollover) and rendered book pass. The existing 10,043,366-byte search-index warning retains startup .41.9 ownership; normal doctrine hooks govern landing.
