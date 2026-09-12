---
id: lua-emitter-source-location-reading-and-boundary-gaps
title: Lua emitter and typed source reading locates false defaults and numeric boundary gaps
answers:
  - "does Lua generated execution reject false options"
  - "does Lua generated plan validation reject a false contract"
  - "can rejected Lua source positions produce non serializable diagnostics"
  - "does Lua accept infinity as a typed Position"
  - "why does Lua input_slice return null for a maximum integer width"
  - "how does Lua input_slice compare with Perl for a large floating width"
  - "what did Lua startup reading group 20 cover"
date: 2026-09-13
status: confirmed-open repairs; exact reading complete
tags: [lua, source-emitter, source-location, options, numeric, startup]
evidence: "LUA-STARTUP-READING.1.20; clean activation 028d4158ee753c7a678df2470ba0e07feb0dc730. Four exact ranges /1,500 fragments /54,002 bytes; eight complete reading windows. Typed240 and generated106 assertions pass per installed host, 692 total; 112 complete diagnostic observations and six independent Perl facade/lowering/source controls. All source remains unchanged."
reverify:
  - "Run the exact managed replay below; its expected defects describe observations, not desired behavior."
  - "bash tools/run_lua_project_data.sh puc lua/test/typed_source_location_contract_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/typed_source_location_contract_test.lua"
  - "bash tools/run_lua_project_data.sh puc lua/test/rule_local_cursor_generated_source_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/rule_local_cursor_generated_source_test.lua"
  - "bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py"
  - "bash tools/project_data_run.sh perl tools/check_generated_source_contract.pl"
---

## Exact reading and comprehension

The ordered group digest remains
`3dba5254dfc4c319bfccce1ea072eb313f8e4099934ee5717343d0b79ba60114`.

| Repository path | Inclusive LF range | Bytes | Range SHA-256 |
| --- | --- | ---: | --- |
| `lua/src/linkedspec/source_emitter.lua` | 166–789 | 24341 | `a45e3da557a90735525315ce3affd1b594213042fc82a4c3a73f31a0915b6f9c` |
| `lua/src/linkedspec/source_location.lua` | 1–436 | 14426 | `80d360ed9c04ee1de45fdc757c630376de3d0b88d641a97577e512aa8fc25fe9` |
| `lua/src/linkedspec/source_location_runtime.lua` | 1–325 | 12432 | `089bc1d873a4b8ec1c70f3b76a3e66b0f4d249a38cb969547d7e96a365e247f8` |
| `lua/src/linkedspec/spec_ast.lua` | 1–115 | 2803 | `146c488d655a09fed8c6ffbe7973ba5a1bc213fae483b73ee37b016100bd3381` |

All eight windows were read without truncation: emitter166–365,366–565,566–789;
source-location1–220,221–436; runtime1–170,171–325; AST1–115.
The emitter and both typed-source modules finish; AST reading stops inside dense
list validation. Cumulative coverage is 20/51 groups, 25,651 fragments /1,025,260
bytes and 37 complete files plus the partial AST. Remaining source is not credited.

The emitter validates the generated contract before decoding its effective
compiled spec, retains deterministic canonical JSON/hex module source and validates
family rows against current compiled rules. Nested contracts and copied metadata
remain explicit. Private callback carriers preserve host failures; this does not
close the earlier PUC5.5 nil-error compatibility failure under .2.2.

The value core uses private weak-key tokens and bounded monotonic authority ids.
Each authority snapshots strictly decoded UTF-8 and derives scalar, byte, line and
column coordinates. Positions are bounded by that source; spans retain same-source
and same-authority checks. Materialization and derived provenance use detached
projections. Runtime adapters retain one copied input source and the existing
47/30/11/4 helper groups plus seven aliases without replacing byte registers.
Typed value failures become compatibility nil; unrelated errors are rethrown.
The AST prefix validates node kinds, rule modes, primitive fields and dense lists;
its modulo-based integer predicate differs from the source core's floor check.

Retrieved canonical facts before reconciliation: [[lua-generated-source-v2-rule-local-cursor]],
[[lua-generated-source-emitter-core]], [[lua-typed-source-location-dormant-red]],
[[typed-source-location-neutral-contract-plan]], [[dart-input-slice-boundary-gaps]],
[[julia-input-slice-arity-and-count-boundaries]]. The dated implementation/admission
history stays intact; new evidence qualifies the exact boundaries below.

## Generated option and contract values

Five operations share false-erasing options: generated direct/traced execution,
freshly loaded emitted direct/traced execution, and execution-failure construction.
For each, omitted options, `{}` and `false` succeed; `true`, zero and text reject
with their existing table error. Execution returns 7; the failure constructor
returns a typed generated error. This is thirty complete observations per host.
`source_emitter.lua`250 and494 default before validating. The third default at377
belongs to a private failure helper, not an additional demonstrated public route.
Existing .2.8 gains .2.8.9 implementation and .2.8.10 independent verification.

Separately, `validate_generated_rule_plan_v2`409 substitutes the current contract
when passed false. Omission/current/false validate, true/zero fail string validation,
and an invalid string reports contract mismatch. `init.lua`187 exports the current
constant used by the valid control. New .2.20/.2.20.1/.2.20.2 own absent-only contract
handling and supported-route proof. Direct generated-literal validation remains
strict; this observation does not show acceptance of a stale emitted contract.

## Rejected source coordinates and diagnostics

Both scalar and UTF-8-byte position constructors reject positive and negative
infinity; neither produces a Position. However `source_location.lua`27 treats
infinity as an integer because it equals its floor. Constructors249–258/273–285
therefore create `source_location_position_out_of_range` errors whose
`position_offset` still contains infinity. `to_json`418–431 copies that field;
JSON encoding then reports `cannot encode a non-finite number`.

For input `abc`, offset3 succeeds and serializes; finite outside offset4 rejects
with the exact typed error and serializes. All invalid controls return nil through
the runtime compatibility adapter. Eight complete observations per host separate
rejection, typed error identity, JSON conversion and compatibility projection.
This is distinct from .2.12's accepted private recognition coordinates: no infinite
Position, ordinary-spec reachability or MCP propagation is demonstrated here.
New .2.21/.2.21.1/.2.21.2 own finite integer validation, a bounded adjacent census
and independent diagnostic/compatibility proof without admitting a public value API.

## Typed input slicing and host arithmetic

All six sources have a zero-regex Top:: -> Done return handler and Done:: /x/;
input is `xabc`. Both native and SpecFile-JSON reconstructed Lua carriers execute.

| input_slice arguments | Installed PUC5.5.1 | Installed LuaJIT | Fresh Perl Get |
| --- | --- | --- | --- |
| 0, 9223372036854775807 | xabc | xabc | xabc |
| 1, 9223372036854775807 | null | abc | abc |
| 3, 9223372036854775807 | null | c | c |
| 4, 9223372036854775807 | null | empty | empty |
| 1, 100000000000000000000.0 | abc | abc | ab |
| 1, 2 | ab | ab | ab |

`source_location_runtime.lua`316 adds start+width before clipping to source length.
PUC integer addition wraps the endpoint negative; the typed span rejects it and
the adapter returns nil. LuaJIT's floating representation does not wrap here.
This is not JSON encoding loss (.2.11), and it does not establish arbitrary precision.
Lua .2.13 gains bounded typed-clipping repair .2.13.3 and carrier proof .2.13.4,
coordinated with Dart .2.14 and the shared count-policy owner startup .60.2.

Each fresh Perl case executes Get with the same source/input, captures generated
source, checks exact helper lowering inside it and retains no context error. Its
four max-integer cases and small control establish expected clipping independently.
The floating case repeats the already recorded reference limitation: scientific
spelling bypasses Perl's typed integer guard and enters host substr, returning ab.
[[julia-input-slice-arity-and-count-boundaries]] and startup .60.2 retain that causal
fact and repair ownership. Neither this reference fallback nor Lua's floating result
is a newly selected cross-backend count policy. Capturing generated reference source
is not an independent execution of an emitted reference artifact.

## Proof scope and capture hygiene

Fresh unchanged suites pass typed240 and rule-local generated106 assertions per
installed host, 692 total. The 112 new complete observations comprise 60 options,
12 contract, 16 source-position and 24 slice rows; they are not additional declared
suite assertion counts. Six independent Perl comparisons retain exact lowerings,
source byte counts/digests and null context errors. Both measured hosts are the
previously recorded PUC5.5.1 and LuaJIT; declared PUC5.4 remains unavailable and .2.2-owned.

Neutral typed-source passes 14 complete /0 pending /231 mutations. The generated
contract checker passes v1/10 families/1 behavior case and the existing 8/105
Dart/Julia/Lua, strict Rust105/105 and capability100/0/0 ledger. These are current
governance checks, not fresh six-runtime admission or complete backend CI.
The earlier PUC observation failures and public-selector baseline failure remain
open. New emitted execution evidence is limited to the option fixture's loaded
module; new slice cases prove native/reconstructed routes only. No CLI/MCP/full-gate
or dependency build is newly claimed.

The first fixture used an and/or expression that invoked the byte fallback when
the scalar compatibility result was nil. Explicit branches now isolate the routes;
both complete payloads were rerun and verified. Initial selected-test output was
not available after a truncated tool response, so all four suites were rerun with
repository-local captured logs and exit0 consumed. A mistaken Python checker path
was rejected before execution; the existing Perl generated-contract owner then
ran successfully. These capture corrections do not modify production files.

## Exact managed replay

```bash
bash tools/project_data_run.sh python3 - <<'LUA_EMITTER_SOURCE_READING_20'
from pathlib import Path
root=Path('.linkedspec-data/scratch/lua120')
root.mkdir(parents=True,exist_ok=True)
(root/'boundaries.lua').write_text('local ls=require("linkedspec");local json=ls.json;local source_location=require("linkedspec.source_location");local adapter=require("linkedspec.source_location_runtime")\nlocal source="Top::\\n -> Done { return(7) }\\nDone::\\n /x/\\n"\nlocal compiled=ls.compile_spec(ls.parse_spec(source));local plan=ls.build_generated_rule_plan(compiled);local text=ls.emit_lua_source_v2(compiled,"lua120.spec");local loader=loadstring or load;local emitted=assert(loader(text,"@lua120-emitted"))();local trace=ls.trace_config_disabled()\nlocal rows=json.array()\nlocal options={{"absent"},{"empty",{}},{"false",false},{"true",true},{"zero",0},{"text","bad"}}\nlocal operations={\n {"generated",function(o)return ls.execute_generated_parser_v2(compiled,plan,"x","lua120.spec",o) end},\n {"generated_trace",function(o)return ls.execute_generated_parser_with_trace_v2(compiled,plan,"x",trace,"lua120.spec",o) end},\n {"emitted",function(o)return emitted.execute("x",o) end},\n {"emitted_trace",function(o)return emitted.execute_with_trace("x",trace,o) end},\n {"failure_constructor",function(o)return ls.is_generated_source_error(ls.generated_source_execution_failed("lua120.spec","detail",o)) end},\n}\nfor _,op in ipairs(operations) do for _,option in ipairs(options) do\n local ok,value=pcall(op[2],option[2]);rows[#rows+1]=json.harray({group="options",operation=op[1],case=option[1],ok=ok,value=ok and value or tostring(value)})\nend end\nfor _,item in ipairs({{"absent"},{"current",ls.GENERATED_SOURCE_CONTRACT},{"false",false},{"true",true},{"zero",0},{"text","invalid-contract"}}) do\n local ok,value=pcall(ls.validate_generated_rule_plan_v2,compiled,plan,"lua120.spec",item[2]);rows[#rows+1]=json.harray({group="contract",case=item[1],ok=ok,validated=ok and value.Top==plan[1].family or false,error=not ok and tostring(value) or json.null})\nend\nlocal context=source_location.source_location_context({rule_role="Top",invocation_role="reading"});local authority=source_location.source_authority({sources={input="abc"}});local runtime=adapter.runtime("abc")\nfor _,mode in ipairs({"scalar","byte"}) do for _,item in ipairs({{"end",3},{"outside",4},{"positive_infinity",math.huge},{"negative_infinity",-math.huge}}) do\n local fn=mode=="scalar" and source_location.position or source_location.position_from_utf8_byte\n local opts={source_id="input",context=context};opts[mode=="scalar" and "offset" or "utf8_byte_offset"]=item[2]\n local ok,value=pcall(fn,authority,opts);local encoded,wire=pcall(function()return json.encode(source_location.to_json(value))end)\n local compat\n if mode=="scalar" then compat=runtime:position_from_scalar(item[2],"Top","probe") else compat=runtime:position_from_byte(item[2],"Top","probe") end\n rows[#rows+1]=json.harray({group="position",mode=mode,case=item[1],accepted=ok,typed_error=source_location.is_error(value),serializable=encoded,wire=wire,compatibility_position=compat~=nil})\nend end\nlocal cases={{"start0",0,"9223372036854775807"},{"start1",1,"9223372036854775807"},{"start3",3,"9223372036854775807"},{"end4",4,"9223372036854775807"},{"floating",1,"100000000000000000000.0"},{"small",1,"2"}}\nfor _,item in ipairs(cases) do\n local input="xabc";local expression="input_slice("..item[2]..", "..item[3]..")";local spec_source="Top::\\n -> Done { return("..expression..") }\\nDone::\\n /x/\\n"\n for _,reconstruct in ipairs({false,true}) do\n  local spec=ls.parse_spec(spec_source);if reconstruct then spec=ls.spec_ast.from_json("SpecFile",json.decode(json.encode(ls.spec_ast.to_json(spec)))) end\n  local value=ls.runtime_parse(ls.runtime_engine(ls.compile_spec(spec)),input).value\n  rows[#rows+1]=json.harray({group="slice",case=item[1],route=reconstruct and "reconstructed" or "native",source=spec_source,input=input,value=value})\n end\nend\nio.write(json.encode(rows),"\\n")\n')
(root/'reference.pl').write_text('use strict;use warnings;use LinkedSpec;use JSON::PP;use Digest::SHA qw(sha256_hex);\nmy $json=JSON::PP->new->canonical->allow_nonref;\nopen my $f,\'<:raw\',\'.linkedspec-data/scratch/lua120/boundaries-puc.json\' or die $!;\nmy $rows=$json->decode(do{local $/;<$f>});close $f;\nmy @results;\nfor my $row (@$rows){\n next unless $row->{group} eq \'slice\' && $row->{route} eq \'native\';\n my $source=$row->{source};my $input=$row->{input};my %ctx;my $emitted;\n my ($expression)=$source=~/return\\((input_slice\\([^\\n]+?\\))\\)/;die \'expression absent\' unless defined $expression;\n my $lowered=LinkedSpec::call_spec_handler_subst(\'Top\',"return($expression)");\n my $parser=LinkedSpec::Get(\\$source,runtime_ctx_ref=>\\%ctx,dump_parser_source=>1,parser_source_ref=>\\$emitted);\n my $value=$parser->(\\$input);die \'lowering absent\' unless index($emitted,$lowered)>=0;\n push @results,{case=>$row->{case},input=>$input,value=>$value,context_error=>$ctx{last_error},lowered=>$lowered,source_bytes=>length($emitted),source_sha256=>sha256_hex($emitted)};\n}\nprint $json->encode(\\@results),"\\n";\n')
(root/'verify-boundaries.py').write_text("from pathlib import Path\nimport json\nroot=Path('.linkedspec-data/scratch/lua120')\nby_host={host:json.loads((root/('boundaries-'+host+'.json')).read_text()) for host in ['puc','luajit']}\nfor host,rows in by_host.items():\n assert len(rows)==56\n groups={g:[r for r in rows if r['group']==g] for g in ['options','contract','position','slice']}\n assert [len(groups[g]) for g in groups]==[30,6,8,12]\n for r in groups['options']:\n  valid=r['case'] in ['absent','empty','false']; assert r['ok']==valid\n  if valid: assert r['value']==(True if r['operation']=='failure_constructor' else 7)\n  else: assert r['value']=='GeneratedSourceError: generated '+('execution failure' if r['operation']=='failure_constructor' else 'execution')+' options must be a table'\n for r in groups['contract']:\n  valid=r['case'] in ['absent','current','false']; assert r['ok']==r['validated']==valid\n  if valid: assert r['error'] is None\n  elif r['case']=='text': assert r['error']=='Generated source contract does not match the active validator: regenerate the generated artifact from its .spec source'\n  else: assert r['error']=='GeneratedSourceError: actual generated source contract must be a string'\n for r in groups['position']:\n  valid=r['case']=='end'; finite=r['case'] in ['end','outside']\n  assert r['accepted']==r['compatibility_position']==valid and r['typed_error']==(not valid) and r['serializable']==finite\n  if valid: assert json.loads(r['wire'])=={'offset':3,'source_id':'input'}\n  elif finite: assert json.loads(r['wire'])=={'code':'source_location_position_out_of_range','invocation_role':'reading','phase':'validate_value','position_offset':4,'rule_role':'Top','source_id':'input','source_length':3}\n  else: assert r['wire']=='JSON error: cannot encode a non-finite number'\n expected={'start0':'xabc','start1':'abc','start3':'c','end4':'','floating':'abc','small':'ab'}\n for r in groups['slice']:\n  value=None if host=='puc' and r['case'] in ['start1','start3','end4'] else expected[r['case']]\n  assert r['value']==value and r['input']=='xabc'\n assert [r for r in rows if r['group']!='slice']==[r for r in by_host['puc'] if r['group']!='slice']\nreference=json.loads((root/'reference.json').read_text());assert len(reference)==6\nexpected={'start0':'xabc','start1':'abc','start3':'c','end4':'','floating':'ab','small':'ab'}\nfor r in reference:\n assert r['value']==expected[r['case']] and r['context_error'] is None and r['input']=='xabc'\n assert 'LinkedSpec::SourceLocation::Runtime::source_slice_text' in r['lowered'] and r['source_bytes']>12000 and len(r['source_sha256'])==64\nprint('PASS 112 complete Lua observations: 60 options, 12 contract, 16 typed-position, 24 native/reconstructed slice; six fresh Perl facade/lowering/source controls. Current defects retained as evidence, not accepted behavior.')\n")
LUA_EMITTER_SOURCE_READING_20
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua120/boundaries.lua > .linkedspec-data/scratch/lua120/boundaries-puc.json
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua120/boundaries.lua > .linkedspec-data/scratch/lua120/boundaries-luajit.json
bash tools/project_data_run.sh perl -Iperl .linkedspec-data/scratch/lua120/reference.pl > .linkedspec-data/scratch/lua120/reference.json
bash tools/project_data_run.sh python3 .linkedspec-data/scratch/lua120/verify-boundaries.py
```

The final preservation audit retains 1,395 prior source/card/decision/history files,
2,501 of 2,507 prior task nodes byte-for-byte, the six explicitly extended owners,
all 73 prior known-limitation headings and all 99 baseline Lua files. Exactly ten
new pending repair nodes and three book limitation headings are added. The three
embedded replay payloads equal the executed scratch files; all four range hashes
and cumulative 20-group totals match the independent canonical coverage replay.
The parked authoring tree and prior chronology suffixes remain exact.

Knowledge regeneration reports 1,106 facts /8,866 question keys. Memory remains 60
lines; change/engineering hot logs are 354/284 lines (24,530/20,950 bytes), with no
rollover required. Memory invariants, both history checks, whitespace validation
and mdBook rendering pass. The existing book search-index warning is 10,083,084
bytes and remains startup .41.9-owned. Normal doctrine hooks govern this focused
landing; no canonical gate or push is claimed.
