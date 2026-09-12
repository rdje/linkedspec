---
id: lua-semantic-projector-reading-and-source-ownership-gaps
title: Lua projector reading separates source correlation failures from explicit child matcher divergence
answers:
  - what did Lua startup reading group eighteen cover
  - why does Lua semantic index reject mixed parent and structural regex slots
  - do Lua grouped action edges preserve shared semantic selectors
  - can Lua semantic call and binding source point into a regex matcher
  - which tasks fix Lua semantic projector source correlation
  - does Lua use a same-line parent regex instead of the explicit child slot
  - why do Lua and Perl disagree on same-line action match ownership
  - which evidence distinguishes Lua semantic projection from runtime match parity
date: 2026-09-13
status: group eighteen read; three Lua repair roots and shared grouped recurrence pending
tags: [lua, reading, semantic, source-correlation, regex, action-edges, runtime, verification]
evidence: "LUA-STARTUP-READING.1.18 from cdf15066d507d5bced806dbee5139aeab203e270 reads 1,500 fragments /50,709 bytes. Four selected suites pass 591 assertions per installed host. Ten full semantic observations agree across hosts: three construction failures, three wrong-source cases, four successful controls. An additional 16 native/reconstructed matcher rows per host and eight reference Get executions locate same-line match ownership divergence. .2.16/.2.17/.2.18 and shared startup .70 own repairs."
reverify:
  - "Run LUA_PROJECTOR_READING_18 below and consume every exit status."
  - "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py"
  - "Run LUA_READING_COVERAGE in docs/knowledge/lua-startup-reading-coverage.md."
---

## Exact reading

Activation is `cdf15066d507d5bced806dbee5139aeab203e270`; frozen baseline remains
`baeb984e36a94a15951cd23d4c52def5064cdaca`. Group eighteen covers 1,500 fragments /
50,709 bytes, ordered-range SHA-256
`996883ed5d7c8cbbf051fb6672c848c2bd7836f49d44713495cea70f80a89844`.

| File under lua/src/linkedspec | Lines | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| semantic_runtime_projection.lua | 80–289 | 7933 | 46a22814b885fee9e0c225ff10d5784030cdd19dac4c7f6d9efdcbbd88c9669e |
| semantic_static_projection.lua | 1–1290 | 42776 | 356041ddb55e6c66ad27a09f2c8502be2277828e34d0e91ea6808cf4ce818a76 |

All six untruncated windows were consumed: runtime projection 80–289; static
projection 1–150,151–450,451–750,751–1050,1051–1290. Cumulative coverage is
18/51 groups, 22,651 fragments /918,924 bytes, 32 complete files and one partial
static projector. Diagnostic revisits to previously read compiler/interpreter/
matching code add no coverage. All 99 Lua baseline files remain unchanged.

## Comprehension and canonical reconciliation

Runtime derivation validates the dense protected event sequence, event kinds,
portable labels, finite nonnegative positions, slot identity and final input hash.
Exactly one succeeded result must be last and belong to the selected entry rule.
The detached static graph supplies rule/slot/edge identity and value shapes;
derivation appends execution/events and observed_as relations before freezing a
new projection. Caller observations do not authorize execution or source access
beyond the retained index ceiling. Failed derivation cannot mutate the original
retained index because the public boundary supplies a detached projection.

The static prefix stores recursively frozen values in private weak-key state,
retains JSON null explicitly and emits fresh typed JSON clones. It builds
conservative literal/function shapes, byte/scalar source references and canonical
record/relation envelopes. Parsed members are grouped by authored line; complete
member scanning retains multiline delimiters. Compiled edges, regex slots and
lifecycle payloads are correlated separately. Lifecycle identity is occurrence-
based, and native Default repetition is normalized to the neutral model.

Entry evidence construction is defined here; its caller is beyond this reading
range and gets no closure credit. Function source ranges combine staged body
spans with the unique enclosing shell; retained staged JSON is checked against
reparsed typed ActionIR before contract resolution. Function shapes use a bounded
fixed-point pass. Edge calls use a lexical occurrence scanner over their complete
member; the exact scanner boundary failures are below. The range ends at the
start of function-resolution evidence construction.

Retrieved before diagnosis: [[lua-semantic-static-projection-plan]],
[[lua-semantic-introspection-authority-map]],
[[lua-semantic-call-staged-projection-plan]],
[[julia-semantic-static-correlation-gaps]],
[[julia-semantic-regex-call-source-gap]], and
[[dart-semantic-indexed-edge-correlation-gaps]]. After the reference discrepancy,
[[spec-edge-syntax-contract]], [[inter-match-gap-capture-origin-and-contract]],
[[lua-compiled-spec-state]] and historical [[rust-edge-semantics-bug]] established
the existing contract and distinct compiler owner. No current Rust recurrence is
inferred from that historical card. TOOLBOX's Get, return_descriptor,
dump_parser_source, managed Lua consumers and neutral validator were used.

## Three construction failures and three wrong-source cases

All ten semantic cases compile and execute on both installed hosts; their full
observations are identical. Three constructors fail and return no query. The
other seven queries pass schema validation and retain correct byte slices for
the excerpts they report; that does not prove the excerpts identify the typed call.

| Case | Observation | Repair |
| --- | --- | --- |
| Parent matcher /a/ then structural /b/ in Top | Compiled [a,b], runtime a; index fails at identity Top, slot0 | Lua .2.16 |
| Structural /b/ then parent matcher /a/ | Compiled [b,a], runtime a; exact /b/ semantic slot | Control |
| ChildLong \| Child[1] shared block | Both compiled selectors 1, runtime b; index edge-identity failure | Shared startup .70 |
| Other \| Child[1] shared block | Same failure without prefix overlap | Shared startup .70 |
| Separate ChildLong[1] and Child[1] members | Exact indexed edges and source members, runtime b | Control |
| /-> Child/ -> Child[1] | Lua query succeeds, runtime -> Child; reference mismatch separately below | Semantic correlation control only |
| Plain /trim(x)/ matcher | Call/binding source is typed trim(" x ") | Control |
| Grouped /(trim(x))/ matcher | Call/binding source is matcher trim(x) | Lua .2.17 |
| Noncapturing /(?:trim(x))/ matcher | Call/binding source is matcher trim(x) | Lua .2.17 |
| Whitespace-prefixed / trim(x)/ matcher | Call/binding source is matcher trim(x) | Lua .2.17 |

`semantic_static_projection.lua`526–544 filters authored parent matchers from
structural slots, then at538 compares against the unfiltered compiled prefix.
The mixed parent-first case therefore compares retained b against compiled a.
Lua `.2.16.1/.2` own typed ownership reconciliation and independent carrier proof;
repair must not erase compiler facts or weaken correlation diagnostics.

For grouped edges, `explicit_target_index`374–384 searches target-label occurrences
for an adjacent matching bracket. It cannot recover the first target's inherited
shared selector. `project_edges` then compares null's fallback zero with compiled
one and rejects. Existing startup `.70.1/.70.3` now includes Lua evidence and
supported-carrier follow-up; the tested regex-arrow control succeeds because Lua
continues searching until the real indexed target. That control is not a full
lexical-correlation guarantee.

The four call cases include an unused function to isolate the scanner from other
call-projection admission conditions. All execute to x. Their typed RHS is
`trim(" x ")`; the following coordinates are zero-based half-open UTF-8 bytes:

| Matcher | Returned call/binding bytes | Actual typed RHS bytes |
| --- | --- | --- |
| /trim(x)/ | 70–81 | 70–81 |
| /(trim(x))/ | 45–52 | 72–83 |
| /(?:trim(x))/ | 47–54 | 74–85 |
| / trim(x)/ | 45–52 | 71–82 |

`call_action_owners`1231 supplies the entire authored member. `regex_start`1067
rejects a slash followed by an opening parenthesis or whitespace, so
`scan_call_sites`1124 indexes matcher text as calls. `take_call_site`1178 consumes
the first matching name; its source is also copied into the RHS binding. Lua
`.2.17.1/.2` own lexical/typed occurrence repair and exact public/carrier proof.

## Reference discrepancy: explicit child match ownership

The initial reference loop stopped at regex_arrow after five agreeing Get cases;
that was a real discrepancy, not a malformed fixture. A complete diagnostic rerun
retains nine agreements and one mismatch: reference null versus Lua -> Child.
No all-ten reference-pass claim is made. A diagnostic stdout-only attempt lacked
retained output; the complete file-captured rerun is the evidence used here.

Get with return_descriptor shows authored Top regex -> Child, but dependency
reference Child[1] and dependency matcher b. The 13,952-byte generated source
uses dependency_regex_map at line49, with b materialized at164/168. The reference
therefore returns null when the input lacks b. This matches the locked explicit
edge contract: a preceding regex does not supply an action edge's selected match.

Eight paired source/input controls separate parent matching from arrow syntax.
Each is executed natively and after SpecFile JSON reconstruction on both Lua
hosts; all 16 rows per host agree. Eight fresh reference Get cases give:

| Top member | Input | Lua native/reconstructed | Reference |
| --- | --- | --- | --- |
| /x/ -> Child[1] | x | x | null |
| /x/ -> Child[1] | b | null | b |
| /-> Child/ -> Child[1] | -> Child | -> Child | null |
| /-> Child/ -> Child[1] | b | null | b |
| -> Child[1] | x | null | null |
| -> Child[1] | b | b | b |
| /x/ -> Top[0] | x | x | x |
| /x/ -> Top[0] | b | null | null |

Child's slots are a,b; every attached block returns match_text(). Lua's compiled
dependency patterns correctly retain b for Child[1], but its effective Top
patterns retain the parent x or -> Child. `compiled_spec.lua`239–254 records
has_parent_regex; dependency resolution416–417 bypasses child-pattern copying
for that branch. `matching.lua`158/173 compiles CompiledRule.regex_patterns, and
interpreter matching/dispatch uses that effective alternation (4682 and4748).
The descriptor can therefore look consistent while runtime uses the wrong owner.

New Lua `.2.18.1/.2` own compiler/runtime ownership repair and independent
supported-carrier proof. `.2.16` must coordinate any slot-layout consequences;
source correlation, runtime match selection and shared grouped selector evidence
remain separate. No backend contract change, reference repair, current Rust/Dart/
Julia recurrence, emitted execution or MCP result is inferred here.

## Proof scope and exact replay

Four unchanged selected consumers pass on each installed host: static graph64,
remaining targets122, typed call core136 and runtime projection269, or591 per host
and1,182 assertions total. The 20 semantic observations, 32 matcher observations,
10 complete initial reference executions and eight additional reference executions
are separate diagnostic evidence, not additions to those assertion counts.
Neutral validation passes six groups, twenty queries and128 rejected mutations,
with existing rollout9/9 and admission6/6 governance. No fresh six-runtime
admission, full gate or declared PUC5.4 pass is claimed. The two installed5.5
observation failures from .1.17 remain .2.2-owned and were not rerun or closed.

| Replay payload | Bytes | SHA-256 |
| --- | ---: | --- |
| projector-probe.lua | 2662 | 53a63d7a1616b827099e5a293e421a9ed6ec54213cb7bfb92fc64e890438329c |
| verify-projector.py | 3678 | c46fc604141ed8ae796ea9f243275f8582a80b5035ab58eff2207267e1280a03 |
| reference.pl | 753 | 066c6cabcf214ce07eb6d4144bb2592f8d60f7495b25f1a85a43eb76edd435ba |
| reference-descriptor.pl | 731 | cab9abea478cd9910fb6c1774b466668f0421e006f77049fad9b6300320fddd2 |
| matcher-probe.lua | 1339 | 30ac85f7813317650a89b0375c1582b5934f8f293262d43ad37b2fb627092093 |
| matcher-reference.pl | 498 | 8e50371dba6e86e4a091d2dc15e1f0b6a7467b5e24d2dfbe121e8e7184737924 |
| verify-matchers.py | 1682 | 0016eebe1aaf27dfcc48ca457cfad06d4bbb21f6985cfcc7696226699671b184 |

```bash
bash tools/project_data_run.sh python3 - <<'LUA_PROJECTOR_READING_18'
from pathlib import Path
root = Path('.linkedspec-data/scratch/lua118')
root.mkdir(parents=True, exist_ok=True)
(root / 'projector-probe.lua').write_text('local ls = require("linkedspec")\nlocal json = ls.json\nlocal staged = require("linkedspec.user_function_definition_parser")\nlocal request = json.decode([[{"contract":"linkedspec-semantic-query-v1","operation":"list","subjects":[],"record_kinds":[],"relation_kinds":[],"direction":"outgoing","page":{"after_id":null,"limit":100},"budget":{"max_records":1000,"max_relations":2000,"max_depth":4},"source":{"detail":"text","include_content_digest":false}}]])\nlocal cases = {\n {"mixed_parent_first", "Top::\\n /a/ -> Child { return(match_text()) }\\n /b/\\nChild::\\n /a/\\n", "a"},\n {"mixed_slot_first", "Top::\\n /b/\\n /a/ -> Child { return(match_text()) }\\nChild::\\n /a/\\n", "a"},\n}\nlocal tail = "\\nChildLong::\\n /c/\\n /d/\\nOther::\\n /e/\\n /f/\\nChild::\\n /a/\\n /b/\\n"\nfor _,item in ipairs({\n {"group_prefix", "-> ChildLong | Child[1] { return(match_text()) }", "b"},\n {"group_other", "-> Other | Child[1] { return(match_text()) }", "b"},\n {"separate", "-> ChildLong[1] { return(match_text()) }\\n -> Child[1] { return(match_text()) }", "b"},\n {"regex_arrow", "/-> Child/ -> Child[1] { return(match_text()) }", "-> Child"},\n}) do cases[#cases+1]={item[1],"Top::\\n "..item[2]..tail,item[3]} end\nfor _,item in ipairs({{"plain_regex","trim(x)","trimx"},{"group_regex","(trim(x))","trimx"},{"noncapture_regex","(?:trim(x))","trimx"},{"space_regex"," trim(x)"," trimx"}}) do\n cases[#cases+1]={item[1],"fn unused(value) { return(value) }\\n\\nTop::\\n /"..item[2].."/ -> Top { value = trim(\\" x \\"); return(value) }\\n",item[3]}\nend\nlocal rows=json.array()\nfor _,item in ipairs(cases) do\n local row=json.harray({case=item[1],source=item[2],input=item[3]})\n local spec=staged.parse_spec_with_staged_user_function_definitions(item[2])\n local compiled=ls.compile_spec(spec)\n local top=compiled.rules_by_label.Top\n row.compiled_patterns=json.array(); for i,p in ipairs(top.regex_patterns) do row.compiled_patterns[i]=p end\n row.compiled_edges=json.array()\n for i,e in ipairs(top.action_edges) do\n  local targets=json.array();for j,t in ipairs(e.targets) do targets[j]=t.label end\n  row.compiled_edges[i]=json.harray({targets=targets,child_regex_index=e.child_regex_index,has_block=e.code~=nil})\n end\n row.runtime=ls.runtime_parse(ls.runtime_engine(compiled),item[3]).value\n if item[1]:match("regex$") then\n  row.typed_rhs=ls.action_ast.to_json(top.action_edges[1].action_payload.action_ast.statements[1].expr).value\n end\n local ok,index=pcall(ls.semantic_index,item[2],{logical_name="lua118.spec",source_detail_ceiling="text"})\n if ok then row.query=index:query_neutral(request):to_json()\n else row.index_error=index:to_json() end\n rows[#rows+1]=row\nend\nio.write(json.encode(rows),"\\n")\n')
(root / 'verify-projector.py').write_text('from pathlib import Path\nimport importlib.util,json,sys\nroot=Path(\'.linkedspec-data/scratch/lua118\')\na=json.loads((root/\'projector-puc.json\').read_text()); b=json.loads((root/\'projector-luajit.json\').read_text())\nassert a==b and len(a)==10 and len({r[\'case\'] for r in a})==10\nspec=importlib.util.spec_from_file_location(\'lua118_neutral\',\'tools/check_semantic_introspection_contract.py\')\nm=importlib.util.module_from_spec(spec);sys.modules[spec.name]=m;spec.loader.exec_module(m)\ncontract=m.load_json(m.ROOT/\'capability_conformance/semantic_introspection_contract.json\')\nfailed={\'mixed_parent_first\',\'group_prefix\',\'group_other\'}\nwrong={\'group_regex\':(45,52,72,83),\'noncapture_regex\':(47,54,74,85),\'space_regex\':(45,52,71,82)}\nfor r in a:\n name=r[\'case\']; expected=\'a\' if name.startswith(\'mixed\') else \'b\' if name in {\'group_prefix\',\'group_other\',\'separate\'} else \'-> Child\' if name==\'regex_arrow\' else \'x\'\n assert r[\'runtime\']==expected,name\n if name.startswith(\'mixed\'):\n  assert r[\'compiled_patterns\']==([\'a\',\'b\'] if name==\'mixed_parent_first\' else [\'b\',\'a\'])\n else:\n  assert all(e[\'has_block\'] and e[\'child_regex_index\']==(1 if name in {\'group_prefix\',\'group_other\',\'separate\',\'regex_arrow\'} else 0) for e in r[\'compiled_edges\'])\n if name in failed:\n  err=r[\'index_error\'];assert \'query\' not in r\n  assert err[\'code\']==\'semantic_static_correlation_failed\' and err[\'stage\']==\'project_static_semantics\'\n  assert err[\'fields\']==({\'identity\':\'Top\',\'slot\':0} if name==\'mixed_parent_first\' else {\'identity\':\'Top\'})\n  assert err[\'message\']==(\'Authored and compiled regex-slot identities differ\' if name==\'mixed_parent_first\' else \'Authored and compiled action-edge identities differ\')\n  continue\n q=r[\'query\'];assert \'index_error\' not in r and q[\'ok\'] and q[\'snapshot\'][\'state\']==\'compiled\' and q[\'snapshot\'][\'has_execution\'] is False and q[\'diagnostics\']==[]\n m.validate_response(contract,q,name)\n assert q[\'page\']=={\'after_id\':None,\'next_after_id\':None,\'complete\':True}\n raw=r[\'source\'].encode()\n for record in q[\'records\']+q[\'relations\']:\n  if record[\'source\'] is not None:\n   s=record[\'source\'];span=s[\'span\'];assert raw[span[\'start_byte\']:span[\'end_byte\']].decode()==s[\'excerpt\']\n if name==\'mixed_slot_first\':\n  slot=next(x for x in q[\'records\'] if x[\'id\']==\'regex:rule:Top:0\');assert slot[\'facts\'][\'pattern\']==\'b\' and slot[\'source\'][\'excerpt\']==\'/b/\'\n if name in {\'separate\',\'regex_arrow\'}:\n  edges=[v for v in q[\'records\'] if v[\'kind\']==\'edge\' and v[\'owner_id\']==\'rule:Top\'];assert len(edges)==(2 if name==\'separate\' else 1)\n  assert [e[\'source\'][\'excerpt\'] for e in edges]==[line.strip() for line in r[\'source\'].splitlines()[1:1+len(edges)]]\n if name.endswith(\'regex\'):\n  calls=[v for v in q[\'records\'] if v[\'kind\']==\'call\' and v[\'owner_id\']==\'edge:rule:Top:0\'];bindings=[v for v in q[\'records\'] if v[\'kind\']==\'binding\' and v[\'owner_id\']==\'edge:rule:Top:0\']\n  assert [v[\'name\'] for v in calls]==[\'trim\',\'return\'] and len(bindings)==1\n  rhs=r[\'typed_rhs\'];assert rhs[\'kind\']==\'call\' and rhs[\'name\']==\'trim\' and rhs[\'source\']==\'trim(" x ")\'\n  source=calls[0][\'source\'];assert source==bindings[0][\'source\']\n  span=source[\'span\'];actual=(span[\'start_byte\'],span[\'end_byte\']);start=raw.index(rhs[\'source\'].encode());expected_span=(start,start+len(rhs[\'source\'].encode()))\n  if name in wrong:\n   coords=wrong[name];assert actual==coords[:2] and expected_span==coords[2:] and source[\'excerpt\']==\'trim(x)\'\n  else:assert actual==expected_span==(70,81) and source[\'excerpt\']==rhs[\'source\']\nprint(\'PASS 10 identical complete two-host observations:3 exact construction failures,3 wrong call/binding spans,4 successful controls;all 7 query schemas and returned source byte slices pass\')\n')
(root / 'reference.pl').write_text('use strict;\nuse warnings;\nuse JSON::PP;\nuse LinkedSpec;\nmy $json=JSON::PP->new->canonical->allow_nonref;\nopen my $f, \'<:raw\', \'.linkedspec-data/scratch/lua118/projector-puc.json\' or die $!;\nmy $rows=$json->decode(do { local $/; <$f> });close $f or die $!;\nfor my $row (@$rows) {\n my $source=$row->{source};my $input=$row->{input};\n my $parser=LinkedSpec::Get(\\$source);\n die "reference parser absent: $row->{case}" unless ref($parser) eq \'CODE\';\n my $value=$parser->(\\$input);\n my $same=$json->encode($value) eq $json->encode($row->{runtime});\n print $json->encode({case=>$row->{case},value=>$value,lua_value=>$row->{runtime},equal=>$same?JSON::PP::true:JSON::PP::false}),"\\n";\n}\nprint "Completed 10 reference Get executions; retain all differences\\n";\n')
(root / 'reference-descriptor.pl').write_text('use strict;use warnings;use LinkedSpec;use JSON::PP;use Data::Dumper;\nopen my $f,\'<:raw\',\'.linkedspec-data/scratch/lua118/projector-puc.json\' or die $!;\nmy $rows=JSON::PP->new->decode(do{local $/;<$f>});close $f;\nmy ($row)=grep {$_->{case} eq \'regex_arrow\'} @$rows;my $source=$row->{source};\nmy %ctx;my $generated;\nmy $descriptor=LinkedSpec::Get(\\$source,return_descriptor=>1,dump_parser_source=>1,parser_source_ref=>\\$generated,runtime_ctx_ref=>\\%ctx);\nlocal $Data::Dumper::Sortkeys=1;local $Data::Dumper::Maxdepth=5;\nprint Dumper($descriptor->{spec}{Top});\nopen my $out,\'>:raw\',\'.linkedspec-data/scratch/lua118/reference-generated.pl\' or die $!;print $out $generated;close $out;\nprint "Generated bytes ",length($generated),"\\n";\n')
(root / 'matcher-probe.lua').write_text('local ls=require("linkedspec");local json=ls.json\nlocal tail="\\nChild::\\n /a/\\n /b/\\n"\nlocal cases={\n {"parent_plain","Top::\\n /x/ -> Child[1] { return(match_text()) }"..tail,"x"},\n {"parent_arrow","Top::\\n /-> Child/ -> Child[1] { return(match_text()) }"..tail,"-> Child"},\n {"target_only","Top::\\n -> Child[1] { return(match_text()) }"..tail,"x"},\n {"self_target","Top::\\n /x/ -> Top[0] { return(match_text()) }\\n","x"},\n}\nlocal rows=json.array()\nfor _,item in ipairs(cases) do\n for _,reconstructed in ipairs({false,true}) do\n  local spec=ls.parse_spec(item[2])\n  if reconstructed then spec=ls.spec_ast.from_json("SpecFile",json.decode(json.encode(ls.spec_ast.to_json(spec)))) end\n  local compiled=ls.compile_spec(spec);local top=compiled.rules_by_label.Top;local edge=top.action_edges[1]\n  for _,input in ipairs({item[3],"b"}) do\n   local result=ls.runtime_parse(ls.runtime_engine(compiled),input)\n   rows[#rows+1]=json.harray({case=item[1],source=item[2],input=input,route=reconstructed and "reconstructed" or "native",value=result.value,patterns=json.array(top.regex_patterns),dependency_patterns=json.array(compiled.dependency_regex_state.dependency_regex_map.Top.patterns),has_parent_regex=edge.has_parent_regex,regex_index=edge.regex_index,child_regex_index=edge.child_regex_index})\n  end\n end\nend\nio.write(json.encode(rows),"\\n")\n')
(root / 'matcher-reference.pl').write_text('use strict;use warnings;use LinkedSpec;use JSON::PP;\nmy $json=JSON::PP->new->canonical->allow_nonref;\nopen my $f,\'<:raw\',\'.linkedspec-data/scratch/lua118/matcher-puc.json\' or die $!;\nmy $rows=$json->decode(do{local $/;<$f>});close $f;\nmy @results;\nfor my $row (@$rows){next unless $row->{route} eq \'native\';my $source=$row->{source};my $input=$row->{input};my $p=LinkedSpec::Get(\\$source);push @results,{case=>$row->{case},input=>$input,value=>$p->(\\$input)};}\nprint $json->encode(\\@results),"\\n";\n')
(root / 'verify-matchers.py').write_text("from pathlib import Path\nimport json\nroot=Path('.linkedspec-data/scratch/lua118');a=json.loads((root/'matcher-puc.json').read_text());b=json.loads((root/'matcher-luajit.json').read_text());ref=json.loads((root/'matcher-reference.json').read_text())\nassert a==b and len(a)==16 and len(ref)==8\nreference={(r['case'],r['input']):r['value'] for r in ref};assert len(reference)==8\nmismatches=0\nfor r in a:\n name=r['case'];input=r['input'];dep='x' if name=='self_target' else 'b'\n parent='-> Child' if name=='parent_arrow' else 'x'\n effective=parent if name.startswith('parent_') or name=='self_target' else 'b'\n assert r['patterns']==[effective] and r['dependency_patterns']==[dep]\n assert r['has_parent_regex']==(name!='target_only') and r['regex_index']==0 and r['child_regex_index']==(0 if name=='self_target' else 1)\n assert r['value']==(input if input==effective else None)\n assert reference[(name,input)]==(input if input==dep else None)\n if r['value']!=reference[(name,input)]:mismatches+=1;assert name.startswith('parent_')\n peer=next(x for x in a if x['case']==name and x['input']==input and x['route']!=r['route']);assert {k:v for k,v in peer.items() if k!='route'}=={k:v for k,v in r.items() if k!='route'}\nassert mismatches==8\ninitial=[json.loads(line) for line in (root/'reference.jsonl').read_text().splitlines() if line.startswith('{')]\nassert len(initial)==10 and [x['case'] for x in initial if not x['equal']]==['regex_arrow']\nprint('PASS 16 identical native/reconstructed matcher rows per host and8 reference executions:4 unique source/input mismatches repeated in both Lua routes;4 unique agreeing controls;initial10 reference cases retain9 agreements and1 mismatch')\n")
LUA_PROJECTOR_READING_18
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua118/projector-probe.lua > .linkedspec-data/scratch/lua118/projector-puc.json
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua118/projector-probe.lua > .linkedspec-data/scratch/lua118/projector-luajit.json
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua118/verify-projector.py
bash tools/project_data_run.sh perl -Iperl .linkedspec-data/scratch/lua118/reference.pl > .linkedspec-data/scratch/lua118/reference.jsonl
bash tools/project_data_run.sh perl -Iperl .linkedspec-data/scratch/lua118/reference-descriptor.pl > .linkedspec-data/scratch/lua118/reference-descriptor.txt
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua118/matcher-probe.lua > .linkedspec-data/scratch/lua118/matcher-puc.json
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua118/matcher-probe.lua > .linkedspec-data/scratch/lua118/matcher-luajit.json
bash tools/project_data_run.sh perl -Iperl .linkedspec-data/scratch/lua118/matcher-reference.pl > .linkedspec-data/scratch/lua118/matcher-reference.json
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua118/verify-matchers.py
```

Run the four unchanged consumers through each managed host wrapper:

```bash
for runtime in puc luajit; do
  bash tools/run_lua_project_data.sh "$runtime" lua/test/semantic_index_static_graph_test.lua
  bash tools/run_lua_project_data.sh "$runtime" lua/test/semantic_index_static_remaining_test.lua
  bash tools/run_lua_project_data.sh "$runtime" lua/test/semantic_index_call_core_test.lua
  bash tools/run_lua_project_data.sh "$runtime" lua/test/semantic_index_runtime_projection_test.lua
done
```

Exact preservation, cumulative coverage, both histories, Knowledge, memory,
rendered book and normal doctrine hooks govern landing. Approved named arguments
remain parked, and all startup, storage and ADR0118 prerequisites remain intact.
No PGEN/RGX build or push belongs to this reading slice.

Independent preservation passes for 1,393 prior source, fact, decision, history and
policy files. Of 2,494 prior task nodes, 2,489 are byte-identical; only the reading
leaf, Lua repair container, startup reading owner and two shared grouped owners
change. Nine new pending nodes match the three implementation/proof repairs.
The parked parser tree, prior chronology suffixes and live-history query section
remain exact. All 67 prior limitation headings remain, with four added. Seven
embedded replay payloads match their executed bytes. Independent coverage retains
all 99 baseline digests and confirms 18 completed groups /22,651 fragments /
918,924 bytes.

Landing checks pass: Knowledge generation has 1,104 facts /8,852 question keys;
MEMORY remains 60 lines; change history is 340 lines /23,268 bytes and engineering
notes are 270 lines /19,540 bytes, with no rollover required. The book build passes;
its 10,072,888-byte search-index warning remains startup .41.9-owned. Diff whitespace
checks pass. Normal doctrine hooks remain required for the commit, and none of
these document checks closes a source/runtime repair or the earlier failed tests.
