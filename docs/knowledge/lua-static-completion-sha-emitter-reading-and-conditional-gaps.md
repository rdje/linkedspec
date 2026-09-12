---
id: lua-static-completion-sha-emitter-reading-and-conditional-gaps
title: Lua static completion reading preserves conditional call and entry omissions and independent binding source ownership
answers:
  - what did Lua startup reading group nineteen cover
  - does Lua omit semantic rule calls when no function is defined
  - why does Lua semantic array or literal binding source become null
  - why does an unused function remove Lua entry explanation records
  - can Lua explain the entry of a single-rule spec
  - what did Lua SHA and emitter prefix reading verify
  - does Lua distinguish missing-rule and out-of-range-slot semantic diagnostics
date: 2026-09-13
status: group nineteen read; conditional entry repair and shared call/source repairs pending
tags: [lua, reading, semantic, bindings, entry-selection, source, sha256, generated-source]
evidence: "LUA-STARTUP-READING.1.19 from 1d569ea18c7256d6d0b4493e57373a84df86879d reads 1,500 fragments /52,334 bytes. Source382, staged97 and remaining122 assertions pass on both installed hosts, 1,202 total. Nine complete observations per host and 18 query schemas retain call/binding/entry omissions plus distinct failure controls. Lua .2.19 and shared startup .22/.67.2 own repairs."
reverify:
  - "Run LUA_STATIC_COMPLETION_READING_19 below and consume every exit status."
  - "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py"
  - "perl tools/check_generated_source_contract.pl"
  - "Run LUA_READING_COVERAGE in docs/knowledge/lua-startup-reading-coverage.md."
---

## Exact reading

Activation is `1d569ea18c7256d6d0b4493e57373a84df86879d`; frozen baseline remains
`baeb984e36a94a15951cd23d4c52def5064cdaca`. Group nineteen covers 1,500 fragments /
52,334 bytes, ordered-range SHA-256
`69bb5c76b2bc703c39db1e27a4083c1f5658e33583d6abc9177d81ce668cda0c`.

| File under lua/src/linkedspec | Lines | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| semantic_static_projection.lua | 1291–2438 | 40315 | ef713662658bda6655c86bf042870ee870823eb1f5c78d82b641890275bfdaaf |
| sha256.lua | 1–187 | 6017 | 9e102cb81ce541d6765ef9f41a102e22797f2bc23a246f19efa0124ee1e7db8e |
| source_emitter.lua | 1–165 | 6002 | 592bfab47bd255b27b3219468eba4e37b3ba6a9c57904c92cf840932214fbe5f |

Six complete windows were consumed: static1291–1590,1591–1890,1891–2190,2191–2438;
SHA1–187; emitter1–165. Static projection and SHA reading are complete; the emitter
stops inside generated-error construction. Cumulative coverage is 19/51 groups,
24,151 fragments /971,258 bytes, 34 complete files and the partial emitter.
All 99 Lua baseline sources remain unchanged.

## Comprehension and canonical reconciliation

The static suffix visits typed composite children, emits helper/function calls in
preorder, retains per-owner call and binding identities and adds resolution/read/
write relations. Assignments use typed value shapes; registered functions precede
the narrow helper table. Function-surface return is syntax and visits its children,
while edge return is a projected helper. Staged payload/job/result fields must agree
with accepted typed authority before neutral artifacts are added. Generated plan
contract, format, identity, row order and unique selected entry are checked without
calling the emitter or executing generated code.

The compiled projection builds rule, edge, lifecycle and slot records with source
references, then extends calls and adds conditional entry evidence. Failed outcomes
retain parsed rule/source facts and native diagnostics; only selected diagnostic
classes receive neutral missing-rule normalization. Canonical ordering and recursive
freeze are shared with derived runtime projections. The existing private test seams
validate staged and generated owners; they are not public source constructors.

SHA is one package-local arithmetic implementation shared by semantic source and
observation identities. Nibble operations, 32-bit modular sums, rotations, message
padding and 64 compression rounds avoid optional host bit libraries. The source
foundation consumer includes standard, padding, multiblock and Unicode digest
vectors; its current passing count is reported below. No new cryptographic assurance
claim follows from reading or those finite vectors.

The emitter prefix defines the generated-v2 contract, stage/code vocabulary, ten
handler families, error/metadata/plan identities and primitive field validators.
Generated-error construction is incomplete at this range boundary; no source-load,
execution, callback-carrier or remaining emitter reading credit is inferred.

Retrieved before diagnosis: [[lua-semantic-static-projection-plan]],
[[lua-semantic-call-staged-projection-plan]],
[[lua-semantic-staged-generated-projection]],
[[lua-semantic-source-foundation]], [[lua-generated-source-emitter-core]],
[[semantic-rule-calls-empty-function-gate]],
[[julia-semantic-static-correlation-gaps]] and
[[julia-semantic-regex-call-source-gap]]. Existing dated facts and all earlier
repair owners remain intact. TOOLBOX's managed Lua source/staged/static consumers,
public index/query and separate runtime APIs, neutral validator and generated-source
contract checker supply the diagnostic proof.

## Public conditional omissions

Nine cases have identical complete observations on both installed hosts. Seven
compile and separately execute; two produce legitimate failed-compilation indices.
All list and explain response schemas pass. Successful query schemas do not close
missing semantic records or incorrect coverage.

| Case | Runtime / native state | Semantic observation | Owner |
| --- | --- | --- | --- |
| Rule assigns trim(" x "), no function | x | Zero helper/binding/call records | Shared .22 |
| Same rule plus unused function | x | Five records, exact trim RHS source | Control |
| Unused function; array RHS [trim(" x ")] | ["x"] | Trim call retained; binding source null | Shared .67.2 |
| Unused function; literal RHS 1 | 1 | Binding source null | Shared .67.2 |
| Single entry rule | Successful, null value | explain(spec:0) is not_explainable | Lua .2.19 |
| Two rules, no functions | Successful, null value | Entry decision +2 steps /2 relations | Control |
| Same two rules plus unused function | Successful, null value | Entry explanation absent | Lua .2.19 |
| Missing target | Native bare_edge_target_undefined | Portable unknown_rule_reference with exact Missing source | Positive failure control |
| Existing Child at slot9 | Native regex_slot_index_out_of_range | Same code/stage, exact /x/ -> Child[9] source | Positive failure control |

`semantic_static_projection.lua`1828 returns from extend_call_core when the
function list is empty, before action-owner traversal. The fresh Lua zero-versus-
five pair extends startup `.22.1`; it does not refresh the earlier six-runtime
census or authorize silent changes to frozen models/hashes.

For binding sources, `call_emit_statement`1560/1577 registers a source only when
the RHS visitor returns an emitted outer call. Composite traversal visits nested
calls but returns no outer call; a literal also returns none. Consequently the
array retains trim and correct runtime ["x"], while the array and literal bindings
lose their RHS source. The direct trim binding retains the exact source.
Startup `.67.2` now explicitly owns this Lua recurrence, keeping nested-call
traversal distinct from RHS source preservation. Regex matcher/source confusion
remains separately Lua `.2.17`-owned.

At2175, entry explanations require no parsed functions, more than one compiled
rule, and a selected entry. All three entry controls retain Top as selected;
only the function-free two-rule case yields an entry decision and two steps.
Single-rule and unused-function controls return semantic_query_invalid with
reason not_explainable and empty explanation records/relations. New Lua `.2.19`
owns bounded contract/model impact, implementation and independent proof under
`.2.19.1-.3`, coordinated with Julia `.2.17.1` and shared `.22`. This reading slice
does not silently expand the neutral model or declare a contract migration.

The missing-rule control intentionally normalizes bare_edge_target_undefined /
normalize_edges to unknown_rule_reference /compile and adds dependency_target_missing
explanation evidence. The out-of-range slot instead retains
regex_slot_index_out_of_range /resolve_selector without inventing a missing rule
or decision. These controls do not close the separate shared failure census or
prove every internal diagnostic normalization case.

## Proof scope and exact replay

Three unchanged consumers pass per installed host: source382, staged/generated97,
remaining static122, or601 per host /1,202 assertions total. Nine two-host native
observations and 18 distinct response-schema validations are separate diagnostic
evidence. Native PUC is the installed5.5 host; no declared5.4, full gate, six-runtime
execution, reconstructed/emitted run or MCP proof is claimed. The earlier two
PUC observation failures remain .2.2-owned and were not rerun or closed.

Neutral validation passes six fixture groups, twenty queries and128 rejected
mutations, with existing rollout9/9 and admission6/6 governance. The generated-source
contract checker passes ten families, one behavior case, declared Dart/Julia/Lua
8/105 and strict Rust105/105 inventories, census100/0/0. These are contract/ledger
checks, not freshly executed runtime counts or a new generated-format admission.

| Replay payload | Bytes | SHA-256 |
| --- | ---: | --- |
| projection-conditions.lua | 2006 | 121460245a7291bb992e37d84c4c640751806b6a1b4e009912246ba5589bfedd |
| verify-conditions.py | 3674 | 9ca5ba70f64550ab96f4da7b869bbbea38a08caf261cc136d0750b48c7302800 |

```bash
bash tools/project_data_run.sh python3 - <<'LUA_STATIC_COMPLETION_READING_19'
from pathlib import Path
root = Path('.linkedspec-data/scratch/lua119')
root.mkdir(parents=True, exist_ok=True)
(root / 'projection-conditions.lua').write_text('local ls=require("linkedspec");local json=ls.json;local staged=require("linkedspec.user_function_definition_parser")\nlocal unused="fn unused(value) { return(value) }\\n\\n"\nlocal function edge(rhs) return "Top::\\n /x/ -> Top { value = "..rhs.."; return(value) }\\n" end\nlocal cases={\n {"no_function",edge(\'trim(" x ")\')},\n {"unused_function",unused..edge(\'trim(" x ")\')},\n {"array_binding",unused..edge(\'[trim(" x ")]\')},\n {"literal_binding",unused..edge(\'1\')},\n {"single_entry","Top::\\n /x/\\n"},\n {"multi_entry","Top::\\n /x/\\nOther::\\n /y/\\n"},\n {"function_entry",unused.."Top::\\n /x/\\nOther::\\n /y/\\n"},\n {"missing_target","Top:\\n Missing\\n"},\n {"slot_range","Top::\\n /x/ -> Child[9]\\nChild::\\n /y/\\n"},\n}\nlocal request=json.decode([[{"contract":"linkedspec-semantic-query-v1","operation":"list","subjects":[],"record_kinds":[],"relation_kinds":[],"direction":"outgoing","page":{"after_id":null,"limit":100},"budget":{"max_records":1000,"max_relations":2000,"max_depth":4},"source":{"detail":"text","include_content_digest":false}}]])\nlocal rows=json.array()\nfor _,item in ipairs(cases) do\n local row=json.harray({case=item[1],source=item[2]})\n local index=ls.semantic_index(item[2],{logical_name="lua119.spec",source_detail_ceiling="text"})\n row.query=index:query_neutral(request):to_json()\n local explain=json.decode(json.encode(request));explain.operation="explain";explain.subjects=json.array({"spec:0"})\n row.explain=index:query_neutral(explain):to_json()\n local diagnostic=index:compilation_diagnostic()\n if diagnostic~=nil then row.diagnostic=diagnostic:to_json()\n else\n  local compiled=ls.compile_spec(staged.parse_spec_with_staged_user_function_definitions(item[2]));row.runtime=ls.runtime_parse(ls.runtime_engine(compiled),"x").value\n  if item[1]:match("binding$") or item[1]:match("function$") then row.typed_rhs=ls.action_ast.to_json(compiled.rules_by_label.Top.action_edges[1].action_payload.action_ast.statements[1].expr).value end\n end\n rows[#rows+1]=row\nend\nio.write(json.encode(rows),"\\n")\n')
(root / 'verify-conditions.py').write_text('from pathlib import Path\nimport importlib.util,json,sys\nroot=Path(\'.linkedspec-data/scratch/lua119\');a=json.loads((root/\'conditions-puc.json\').read_text());b=json.loads((root/\'conditions-luajit.json\').read_text());assert a==b and len(a)==9 and len({r[\'case\'] for r in a})==9\nspec=importlib.util.spec_from_file_location(\'lua119_neutral\',\'tools/check_semantic_introspection_contract.py\');m=importlib.util.module_from_spec(spec);sys.modules[spec.name]=m;spec.loader.exec_module(m);contract=m.load_json(m.ROOT/\'capability_conformance/semantic_introspection_contract.json\')\nfor row in a:\n name=row[\'case\'];q=row[\'query\'];e=row[\'explain\'];m.validate_response(contract,q,name);m.validate_response(contract,e,name+\' explain\')\n assert q[\'ok\'] and q[\'diagnostics\']==[] and q[\'snapshot\'][\'has_execution\'] is False\n records=q[\'records\'];assert len({r[\'id\'] for r in records})==len(records)\n raw=row[\'source\'].encode()\n for r in records+q[\'relations\']:\n  s=r[\'source\']\n  if s is not None:\n   span=s[\'span\'];assert raw[span[\'start_byte\']:span[\'end_byte\']].decode()==s[\'excerpt\']\n if name in {\'missing_target\',\'slot_range\'}:\n  assert \'runtime\' not in row and q[\'snapshot\'][\'state\']==\'failed_compilation\'\n  native=row[\'diagnostic\'];diagnostic=next(r for r in records if r[\'kind\']==\'diagnostic\')\n  if name==\'missing_target\':\n   assert native[\'code\']==\'bare_edge_target_undefined\' and native[\'stage\']==\'normalize_edges\'\n   assert diagnostic[\'facts\'][\'code\']==\'unknown_rule_reference\' and diagnostic[\'facts\'][\'stage\']==\'compile\' and diagnostic[\'source\'][\'excerpt\']==\'Missing\'\n   assert next(r for r in records if r[\'kind\']==\'explanation_step\')[\'facts\'][\'rule_code\']==\'dependency_target_missing\'\n  else:\n   assert native[\'code\']==diagnostic[\'facts\'][\'code\']==\'regex_slot_index_out_of_range\'\n   assert native[\'stage\']==diagnostic[\'facts\'][\'stage\']==\'resolve_selector\' and diagnostic[\'source\'][\'excerpt\']==\'/x/ -> Child[9]\'\n   assert not any(r[\'kind\'] in {\'decision\',\'explanation_step\'} for r in records)\n else:\n  assert q[\'snapshot\'][\'state\']==\'compiled\' and \'diagnostic\' not in row\n  assert next(r for r in records if r[\'id\']==\'spec:0\')[\'facts\'][\'entry_rule_id\']==\'rule:Top\'\n  assert row[\'runtime\']==({\'no_function\':\'x\',\'unused_function\':\'x\',\'array_binding\':[\'x\'],\'literal_binding\':1}.get(name))\n relevant=[r for r in records if r[\'kind\'] in {\'helper\',\'call\',\'binding\'}]\n if name==\'no_function\':assert relevant==[] and row[\'typed_rhs\'][\'name\']==\'trim\'\n elif name in {\'unused_function\',\'array_binding\',\'literal_binding\'}:\n  calls=[r for r in relevant if r[\'kind\']==\'call\'];bindings=[r for r in relevant if r[\'kind\']==\'binding\'];assert len(bindings)==1\n  assert [r[\'name\'] for r in calls]==([\'return\'] if name==\'literal_binding\' else [\'trim\',\'return\'])\n  if name==\'unused_function\':assert len(relevant)==5 and bindings[0][\'source\'][\'excerpt\']==row[\'typed_rhs\'][\'source\']==\'trim(" x ")\'\n  else:\n   assert bindings[0][\'source\'] is None\n   if name==\'array_binding\':assert row[\'typed_rhs\'][\'kind\']==\'array_literal\' and row[\'typed_rhs\'][\'items\'][0][\'name\']==\'trim\' and calls[0][\'source\'][\'excerpt\']==\'trim(" x ")\'\n   else:assert row[\'typed_rhs\'][\'kind\']==\'number\' and row[\'typed_rhs\'][\'source\']==\'1\'\n expected=name==\'multi_entry\';assert e[\'ok\']==expected\n if expected:assert len(e[\'records\'])==3 and len(e[\'relations\'])==2 and e[\'diagnostics\']==[]\n else:assert e[\'records\']==[] and e[\'relations\']==[] and e[\'diagnostics\'][0][\'fields\'][\'reason\']==\'not_explainable\'\nprint(\'PASS 9 identical complete two-host observations /18 query schemas:zero-versus-five call gate;array and literal binding source omissions;conditional3/2 entry explanation;distinct missing-target and slot-range diagnostic controls\')\n')
LUA_STATIC_COMPLETION_READING_19
bash tools/run_lua_project_data.sh puc .linkedspec-data/scratch/lua119/projection-conditions.lua > .linkedspec-data/scratch/lua119/conditions-puc.json
bash tools/run_lua_project_data.sh luajit .linkedspec-data/scratch/lua119/projection-conditions.lua > .linkedspec-data/scratch/lua119/conditions-luajit.json
bash tools/run_python_project_data.sh .linkedspec-data/scratch/lua119/verify-conditions.py
for runtime in puc luajit; do
  bash tools/run_lua_project_data.sh "$runtime" lua/test/semantic_index_source_foundation_test.lua
  bash tools/run_lua_project_data.sh "$runtime" lua/test/semantic_index_call_staged_generated_test.lua
  bash tools/run_lua_project_data.sh "$runtime" lua/test/semantic_index_static_remaining_test.lua
done
```

Exact source/evidence preservation, cumulative coverage, both histories, Knowledge,
memory, rendered book and normal hooks govern landing. Named arguments remain
approved and parked; all startup and ADR0118 prerequisites remain. No PGEN/RGX
build or push belongs to this reading slice.

Independent preservation passes for 1,394 prior source, fact, decision, history and
policy files. Of 2,503 prior task nodes, 2,498 remain byte-identical; only the
reading leaf, Lua repair container, startup reading owner and two shared omission
owners change. Four new pending entry-coverage nodes match the bounded task plan.
The parked parser tree, prior chronology suffixes and live-history query section
remain exact. All 71 prior limitation headings remain, with two added. Both
embedded replay payloads match their executed bytes. Independent coverage retains
all 99 baseline digests and confirms 19 groups /24,151 fragments /971,258 bytes.

Landing checks pass: Knowledge generation has 1,105 facts /8,859 question keys;
MEMORY remains 60 lines; change history is 347 lines /23,875 bytes and engineering
notes are 277 lines /20,251 bytes, with no rollover required. The book build passes;
its 10,076,773-byte search-index warning remains startup .41.9-owned. Diff whitespace
checks pass. Normal doctrine hooks remain required for landing; these checks do
not close source/runtime repairs or the earlier failed observation tests.
