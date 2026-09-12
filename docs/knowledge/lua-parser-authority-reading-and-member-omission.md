---
id: lua-parser-authority-reading-and-member-omission
title: Lua parser completion distinguishes lost harray members from incomplete switch diagnostics
answers:
  - what did Lua startup reading group four cover
  - why can Lua harray literals discard pairless members
  - which task fixes Lua hash literal member completeness
  - why can Lua switch contract resolution omit an unknown helper
  - does Lua attached switch runtime validate its complete body
  - how was the private Lua authority tested without a native build
  - which part of Lua progressive authority was read in group four
date: 2026-09-12
status: exact group four read; two concrete parser and resolver repairs pending
tags: [lua, parser, harray, switch, progressive, authority, reading, diagnostics]
evidence: "LUA-STARTUP-READING.1.4 reads 1500 fragments /58,518 bytes from clean 344f4503b3601bf3349af6124fe1225af0322aa4. 272 selected existing private-authority assertions plus 13 parser boundary controls pass per measured runtime (PUC 5.5.1 and LuaJIT 2.1.1788460057). Four harray omission and two switch diagnostic omission controls per runtime are confirmed; .2.6/.2.7 own repairs and independent verification. All source bytes remain baseline-identical."
reverify:
  - "Run both self-contained recipes below through the managed process wrapper; the selected authority excludes exactly the facade import and assertion."
  - "Run LUA_READING_COVERAGE from docs/knowledge/lua-startup-reading-coverage.md for exact all-source/range reconstruction."
  - "bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py"
  - "bash tools/run_python_project_data.sh tools/check_write_vivification_contract.py"
---

# Physical reading

Activation is `344f4503b3601bf3349af6124fe1225af0322aa4`; the frozen Lua source
baseline remains `baeb984e36a94a15951cd23d4c52def5064cdaca`. Nine complete windows
read parser 723–903, 904–1084, 1085–1265, 1266–1446, 1447–1627 and authority
1–150, 151–300, 301–450, 451–595. No output truncation or omitted source bytes.

| Path | Inclusive LF lines | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| `lua/src/linkedspec/action_parser.lua` | 723–1627 | 37654 | `82ae683c15b75d4fdb1ea157b7389a7fee9a6629acaa8d04e71bdc0bc988931c` |
| `lua/src/linkedspec/bounded_child_parse_authority.lua` | 1–595 | 20864 | `7de178a52bfa2dd6eb7487bd1c5cf8fb118cab0eaac6438ed18e882a43433fa2` |

Total: 1,500 fragments /58,518 bytes; ordered-range SHA-256
`b48fca781d6ab629076a66a214be4b0e1fb9b56f8142477a0e224bf0b5e3fbc4`.
Cumulative reading is 4/51 groups, 5,445 fragments /228,546 bytes, ten complete
files and one partial authority module. Its suffix belongs to .1.5. The independent
99-file coverage recipe verifies scope without substituting hashes for reading.

# Comprehension and canonical reconciliation

The parser suffix completes evaluated nested-write targets and typed path errors,
then constructs staged v2 marker assignments from literal options and direct/derived
source-text plans. Capability lists are unique and sorted; result/failure policies
and target compatibility are checked before constructing typed marker state.
Exact progressive assignments carry only static parser/top identities and a bare
span binding. Residual parse_job calls are rejected recursively after parsing.
Canonical staged/progressive authority remains in its separate private module.

Receiver mutation admits only an addressable bare binding, exactly one adjacent
map_leaves bang, empty arguments, an immediate callback and non-bang continuation.
It retains expression and callback/argument/method source spans. Recognition and
recursive-observation calls become dedicated typed nodes with constrained operands.
Generic trailing blocks, attached/marker control forms, call-result access, primitive/
container classification and offset-preserving callable reparsing finish the public
parser. [[write-vivification-lua-runtime]], [[lua-progressive-span-dispatch-carriers]]
and [[lua-actionir-ast-parser]] retain the complete admitted behavior owners.

The authority prefix uses opaque tokens with weak-key private state, typed errors,
exact option fields, finite exact integer limits, normalized identities and copied
dense string lists. Frozen registry entries hold only already-compiled callbacks;
registry mutation and implicit loads explicitly fail. Invocation creation copies
sources, binds cancellation/clock/limits and validates every active-chain span
against the decoded source before accepting it. Execution seeds own a copied recipe
and create fresh invocation accounting while sharing authorized cancellation identity.
Diagnostic projection copying is separate from the result-detachment boundary in
the unread suffix. Canonical ownership: [[lua-progressive-span-dispatch-private-authority]].

# Confirmed harray member omission — Lua .2.6

The brace classifier in action_parser.lua lines 1516–1538 splits top-level comma
parts and appends only those containing a separator. Once any pair exists, it
returns hash_literal even if other parts were silently skipped. The source string
still contains those bytes, but the semantic AST contains no node for them:

| Source | Retained entries | Contract diagnostics |
| --- | ---: | --- |
| `{ key: 1, mystery_probe() }` | 1 | none |
| `{ mystery_probe(), key: 1 }` | 1 | none |
| `{ first: 1, mystery_probe(), last: 2 }` | 2 | none |
| `{ key: 1, 99 }` | 1 | none |

The standalone `{ mystery_probe() }` control is a block_value and retains its
unknown_helper diagnostic; empty and valid nested harrays remain accepted.
This is lost authored member accounting, not a proposal for mixed block/harray
syntax. .2.6.1 owns complete pair recognition with source-attributed errors;
.2.6.2 owns independent supported-route proof. No native execution result is inferred.

# Confirmed switch diagnostic omission — Lua .2.7

The parser retains the full attached body but also extracts cases and one final
default. The contract resolver prefers that projection whenever it is nonempty.
For a valid case followed by mystery_probe(), or an earlier default containing that
call followed by a second default, projected resolution reports ok=true. Calling
resolve_action_block_contracts on the unchanged retained body reports unknown_helper.
This direct controlled comparison locates the omission without modifying any module.
A valid one-case control stays clear in both views.

Runtime is a distinct boundary: after canonical retrieval of
[[lua-runtime-switch-statement-controls]], diagnostic source reading of
`lua/src/linkedspec/interpreter.lua` lines 4159–4201 confirms that
execute_attached_switch validates every retained body statement, rejects non-branches,
duplicate defaults and cases after a default, then evaluates the subject. This
source inspection grants neither whole-interpreter reading credit nor fresh carrier
execution proof. Do not import the Dart/Julia runtime omission conclusion into Lua.

Lua .2.7.1 owns complete source-attributed contract accounting or explicit structural
rejection without duplicate valid contracts; .2.7.2 independently checks static and
runtime boundaries. Existing marker/value/attached behavior remains the reference.
[[dart-attached-switch-body-omission]] and [[julia-attached-switch-body-omission]]
retain their separately measured execution defects.

# Focused proof and declared-primary qualification

The existing dormant private-authority consumer has one package-facade assertion.
For this ordinary reading slice, its exact package import and that one assertion
are omitted from a project-local copy; all other bytes are unchanged. This runs
272 existing assertions on each measured host without building a native adapter.
The original 273-assertion consumer is not claimed as freshly executed in full.
All neutral authority rows, diagnostic contexts, nested budgets, cancellation,
expiry, rebasing, detachment and isolation assertions remain in the selected source.

Original test: 22,130 bytes, SHA-256
`1c623f19e1b4503eaebe8c6e41ce80e13ec575cfb37b1a0943c5d3f55e703686`.
Selected source: 21,986 bytes, SHA-256
`375ab04e4409d13c1b2b899c9beeff2ae2dc912269621eea8e45047b4f8ce0ee`.
The parser recipe below passes 13 valid boundary controls per host, separately
asserting four harray and two switch diagnostic failures. Positive checks include
typed nested writes, bang mutation, progressive/recognition nodes and rebased spans.
Total correct selected controls: 570 across both measured runtimes.

Exact runtime census: PUC 5.5.1 and LuaJIT 2.1.1788460057. The declared 5.4.8 primary
remains unavailable under .2.2; none of these observations establishes its conformance.
Neutral progressive proof passes rollout 9/9, 116 contract mutations and public
6/12/10/60; write-vivification passes 105 rejected mutations and its unchanged case
matrix. No full Lua gate, canonical CI, PGEN/RGX build or repair completion is claimed.

# Exact selected-authority replay

```bash
bash tools/project_data_run.sh python3 - <<'LUA_SELECTED_AUTHORITY'
from pathlib import Path
import hashlib
source=Path('lua/test_dormant/progressive_span_dispatch_authority_test.lua').read_text()
assert hashlib.sha256(source.encode()).hexdigest()=='1c623f19e1b4503eaebe8c6e41ce80e13ec575cfb37b1a0943c5d3f55e703686'
for needle in ['local linkedspec = require("linkedspec")\n',
               'check(linkedspec.bounded_child_parse_authority == nil, "private authority absent from package facade")\n']:
    assert source.count(needle)==1
    source=source.replace(needle,'')
assert hashlib.sha256(source.encode()).hexdigest()=='375ab04e4409d13c1b2b899c9beeff2ae2dc912269621eea8e45047b4f8ce0ee'
path=Path('.linkedspec-data/scratch/lua14/selected-authority.lua')
path.parent.mkdir(parents=True,exist_ok=True)
path.write_text(source)
LUA_SELECTED_AUTHORITY
bash tools/project_data_run.sh lua -v
bash tools/project_data_run.sh luajit -v
bash tools/project_data_run.sh env 'LUA_PATH=lua/src/?.lua;lua/src/?/init.lua;;' lua .linkedspec-data/scratch/lua14/selected-authority.lua
bash tools/project_data_run.sh env 'LUA_PATH=lua/src/?.lua;lua/src/?/init.lua;;' luajit .linkedspec-data/scratch/lua14/selected-authority.lua
```

# Parser accounting replay

This dated diagnostic expects the current omissions; after repair, use its owning
regression checks. No native module is needed.

```lua
package.path = "lua/src/?.lua;lua/src/?/init.lua;" .. package.path
local p=require("linkedspec.action_parser")
local a=require("linkedspec.action_ast")
local c=require("linkedspec.action_contracts")
local j=require("linkedspec.json")
local checks=0
local function check(v,label) assert(v,label); checks=checks+1 end
local function parse(s) return p.parse_action_expression(s) end
local function codes(r)
 local result=j.array()
 for _,d in ipairs(r.diagnostics) do result[#result+1]=d.code end
 return result
end
print("RUNTIME",_VERSION,jit and jit.version or "PUC")
for _,source in ipairs({'{}','{ key: 1 }','{ first: 1, second: { nested: 2 } }'}) do
 local e=parse(source)
 check(e.kind=='hash_literal' and c.resolve_action_expression_contracts(e).ok,'valid harray')
end
local block=parse('{ mystery_probe() }')
check(block.kind=='block_value' and not c.resolve_action_expression_contracts(block).ok,'non-harray block retains diagnostic')
for _,source in ipairs({'{ key: 1, mystery_probe() }','{ mystery_probe(), key: 1 }','{ first: 1, mystery_probe(), last: 2 }','{ key: 1, 99 }'}) do
 local e=parse(source)
 local r=c.resolve_action_expression_contracts(e)
 assert(e.kind=='hash_literal' and r.ok)
 local serialized=j.encode(a.to_json(e))
 print('HARRAY_OMISSION',source,'entries='..#e.entries,'diagnostics='..j.encode(codes(r)))
 for _,entry in ipairs(e.entries) do
  assert(entry.value.kind=='number' and entry.value.value~=99)
 end
end
for _,body in ipairs({'case(1) { return(7) }','case(1) { return(7) }; mystery_probe()','default() { mystery_probe() }; default() { return(9) }'}) do
 local e=parse('switch(1) { '..body..' }')
 local projected=c.resolve_action_expression_contracts(e)
 local full=c.resolve_action_block_contracts(e.body)
 assert(projected.ok)
 if body=='case(1) { return(7) }' then check(full.ok,'valid switch full-body control')
 else assert(not full.ok and full.diagnostics[1].code=='unknown_helper') end
 print('SWITCH_DIAGNOSTICS','body='..#e.body.statements,'projected='..j.encode(codes(projected)),'full='..j.encode(codes(full)))
end
local nested=parse('document[cat("a", "b")][0] = 7')
check(nested.kind=='assign_nested_access' and #nested.segments==2 and nested.segments[1].expression.kind=='call','typed evaluated write path')
local ok,err=pcall(parse,'document[] = 7')
check(not ok and p.is_action_parse_error(err) and err.code=='nested_write_segment_empty','typed empty path diagnostic')
local mutation=parse('document.map_leaves!() { return(value) }.count_keys()')
check(mutation.kind=='receiver_mutation_chain' and mutation.mutation.method=='map_leaves' and #mutation.continuation==1,'one bang mutation and continuation')
local bad,bang=pcall(parse,'document.map_leaves!!() { return(value) }')
check(not bad and p.is_action_parse_error(bang) and bang.code=='bang_method_suffix_invalid','exact bang denial')
local progressive=parse('value = dispatch_span("expr-v1", "Expr", span)')
check(progressive.kind=='progressive_dispatch_span' and progressive.parser_id=='expr-v1' and progressive.span=='span','dedicated progressive node')
local invalid,message=pcall(parse,'value = dispatch_span(dynamic, "Expr", span)')
check(not invalid and tostring(message):find('progressive_parser_identity_literal_required',1,true),'literal progressive identity')
local recognition=parse('recognize_once(token, call(Child))')
check(recognition.kind=='recognize_once' and recognition.token=='token' and recognition.rule=='Child','dedicated recognition operands')
local offset=p.parse_action_expression_at('"é"',4)
check(offset.source_span.start==4 and offset.source_span['end']==7,'rebased copied expression')
print('VALID_BOUNDARY_CONTROLS',checks)
```

```bash
bash tools/project_data_run.sh python3 - <<'LUA_ACCOUNTING_PROBE'
from pathlib import Path
import re
card=Path('docs/knowledge/lua-parser-authority-reading-and-member-omission.md').read_text()
source=re.search(r'^```lua\n(.*?)^```$',card,re.M|re.S)[1]
path=Path('.linkedspec-data/scratch/lua14/parser-accounting-proof.lua')
path.parent.mkdir(parents=True,exist_ok=True)
path.write_text(source)
LUA_ACCOUNTING_PROBE
bash tools/project_data_run.sh lua .linkedspec-data/scratch/lua14/parser-accounting-proof.lua
bash tools/project_data_run.sh luajit .linkedspec-data/scratch/lua14/parser-accounting-proof.lua
```
