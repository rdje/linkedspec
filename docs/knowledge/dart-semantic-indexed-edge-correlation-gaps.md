---
id: dart-semantic-indexed-edge-correlation-gaps
title: Dart static correlation can reject valid grouped and regex-arrow indexed edges
answers:
  - "why does Dart semantic index reject a grouped shared selector"
  - "can arrow text inside a regex break Dart semantic index construction"
  - "why does Dart semantic static correlation reject valid indexed edges"
  - "which task owns Dart regex-arrow selector correlation"
  - "does Dart reproduce the grouped semantic source correlation gap"
date: 2026-09-10
status: confirmed native index-construction failures; repairs pending behind startup prerequisites
tags: [dart, semantic-introspection, source-correlation, grouped-edges, regex, selectors, startup-reading]
evidence: "DART-STARTUP-READING.1.33 reads semantic_static_projection.dart 382-1664, sha256.dart 1-162 and source_emitter.dart 1-55 from clean 802582d27453e1e27c729c50c18bd5d19b3127cf. Eight public native index/compiled/runtime controls establish four construction failures and four successful controls. Existing startup .70 owns grouped selectors; Dart .2.22 and two children own regex-arrow correlation."
reverify: "Run both complete managed reproduction blocks below; bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py; cd dart && bash ../tools/run_dart_project_data.sh test test/semantic_index_static_graph_test.dart test/semantic_index_source_foundation_test.dart test/semantic_index_compilation_foundation_test.dart test/semantic_index_call_projection_test.dart test/semantic_index_query_kernel_test.dart"
---

Eight public native controls separate compiled/runtime behavior from semantic
index construction. Every source compiles; every runtime value equals the
chosen input. Four semantic constructors nevertheless throw
`semantic_static_correlation_failed` at `project_static_semantics` with message
`Authored and compiled action-edge identities differ`. They produce no query
response. Four comparison constructors and their public typed queries succeed.

All sources declare Top plus ChildLong slots c/d, Other slots e/f and Child
slots a/b. Each action block is `{ return(match_text()) }`.

| Top action member(s) | Input and runtime value | Semantic index |
| --- | --- | --- |
| `-> ChildLong \| Child[1]` | `b` | Construction fails |
| `-> Other \| Child[1]` | `b` | Construction fails |
| Separate `-> ChildLong[1]` and `-> Child[1]` members | `b` | Two exact indexed edges |
| `/x/ -> Child[1]` | `x` | One exact indexed edge |
| `/-> Child/ -> Child[1]` | `-> Child` | Construction fails |
| `/-> Child[0]/ -> Child[1]` | `-> Child0` | Construction fails |
| `/-> Child[1]/ -> Child[1]` | `-> Child1` | One exact indexed edge |
| `/-> Child/ -> Child` | `-> Child` | One exact direct edge |

The two grouped forms compile to two block-bearing edges, both with selector 1.
The separate control preserves both indexed source members. The regex controls
compile one block-bearing Child edge with selector 1, except the direct control
with selector 0. Expected runtime inputs differ deliberately to exercise each
authored matcher. No inferred equivalence between those regexes is claimed.

`_scanSemanticMember` in `dart/lib/src/semantic/semantic_static_projection.dart`
1034 onward passes a whole member's text, target label and parsed index to
`_semanticExplicitTargetIndex` at 1219–1238. That helper takes the first arrow
substring, then the first target-name substring, and requires a bracket directly
after that occurrence. For shared-selector groups, the first target has no
adjacent bracket even though the parsed/compiled selector applies to both
targets. Both prefix and non-prefix controls therefore fail; prefix overlap
is not required to trigger this Dart failure.

For regex decoys, the same helper can select arrow/name text inside the
matcher instead of the actual target. An absent or mismatched decoy bracket
returns null. `_requireSemanticActionEdgeIdentity` at 888 onward then compares
compiled selector 1 with null's fallback 0 and rejects construction. This guard
detects disagreement; weakening it would hide the earlier correlation failure.
The same-index decoy happens to agree and is only a counter-control, not proof
of lexical correctness.

Existing `SESSION-STARTUP-READING.70.1/.70.3` now includes the Dart grouped
recurrence, alongside the different Perl/Rust evidence in
[[semantic-grouped-edge-source-correlation-gaps]]. Dart `.2.22.1/.2.22.2` owns
lexical target selection, recurrence and public closeout for regex-arrow cases,
coordinated with `.70` and [[dart-semantic-call-projection-counterexamples]]
without merging their distinct failures.

All 28 selected static/source/compilation/call/query tests and neutral
6-group/20-query/128-mutation checks pass, with rollout 9/0 and admission 6/0
unchanged. These eight controls exercise public native source construction,
typed query, separate compilation and runtime. They establish no fresh
raw-query, UTF-8-constructor, observation, emitted/reconstructed, other-backend
or MCP result. The complete source, input, compiled facts and response/error
are preserved by the recipe; independent assertions check source forms,
exact member text and actual UTF-8 span slices for successful queries.

No source repair or syntax change lands in the reading slice. Startup
prerequisites still gate implementation.

```bash
bash tools/project_data_run.sh python3 - <<'DART133_PROGRAM'
from pathlib import Path
Path('.linkedspec-data/scratch/dart133-correlation.dart').write_text("import 'dart:convert';\nimport '../../dart/lib/linkedspec_dart.dart';\nvoid main() {\n final cases=<String,String>{\n  'group_prefix':'-> ChildLong | Child[1] { return(match_text()) }',\n  'group_other':'-> Other | Child[1] { return(match_text()) }',\n  'separate':'-> ChildLong[1] { return(match_text()) }\\n -> Child[1] { return(match_text()) }',\n  'regex_clean':'/x/ -> Child[1] { return(match_text()) }',\n  'regex_arrow':'/-> Child/ -> Child[1] { return(match_text()) }',\n  'regex_wrong_index':'/-> Child[0]/ -> Child[1] { return(match_text()) }',\n  'regex_same_index':'/-> Child[1]/ -> Child[1] { return(match_text()) }',\n  'regex_direct':'/-> Child/ -> Child { return(match_text()) }',\n };\n final results=<Map<String,Object?>>[];\n for(final entry in cases.entries){\n  final source='Top::\\n ${entry.value}\\n\\nChildLong::\\n /c/\\n /d/\\n\\nOther::\\n /e/\\n /f/\\n\\nChild::\\n /a/\\n /b/\\n';\n  final input=switch(entry.key){'regex_clean'=>'x','regex_arrow'||'regex_direct'=>'-> Child','regex_wrong_index'=>'-> Child0','regex_same_index'=>'-> Child1',_=>'b'};\n  final row=<String,Object?>{'case':entry.key,'source':source,'input':input};\n  try{\n   final compiled=compileSpec(parseSpec(source));\n   row['compiled_edges']=compiled.rulesByLabel['Top']!.actionEdges.map((e)=>{'targets':e.targets.map((t)=>t.label).toList(),'child_regex_index':e.childRegexIndex,'has_block':e.code!=null}).toList();\n   try{row['runtime']=LinkedSpecRuntimeEngine(compiled).parse(input).value;}\n   catch(e){row['runtime_error']='${e.runtimeType}: $e';}\n  }catch(e){row['compile_error']='${e.runtimeType}: $e';}\n  try{\n   final index=SemanticIndex.fromSource(source,options:const SemanticIndexOptions(logicalName:'dart133.spec',sourceDetailCeiling:SemanticSourceDetail.text));\n   final response=index.query(SemanticQuery(operation:SemanticQueryOperation.list,recordKinds:const ['edge'],source:const SemanticQuerySource(detail:SemanticSourceDetail.text)));\n   row['query']=response.toJson();\n  }catch(e){row['index_error']='${e.runtimeType}: $e';}\n  results.add(row);\n }\n print(jsonEncode(results));\n}\n")
DART133_PROGRAM
bash tools/run_dart_project_data.sh run .linkedspec-data/scratch/dart133-correlation.dart > .linkedspec-data/scratch/dart133-correlation.json 2> .linkedspec-data/scratch/dart133-correlation.stderr
```

```bash
bash tools/project_data_run.sh python3 - <<'DART133_VERIFY'
from pathlib import Path
import json
rows=json.loads(Path('.linkedspec-data/scratch/dart133-correlation.json').read_text())
assert len(rows)==8 and len({r['case'] for r in rows})==8
assert Path('.linkedspec-data/scratch/dart133-correlation.stderr').read_bytes()==b''
failed={'group_prefix','group_other','regex_arrow','regex_wrong_index'}
expected_inputs={'group_prefix':'b','group_other':'b','separate':'b','regex_clean':'x','regex_arrow':'-> Child','regex_wrong_index':'-> Child0','regex_same_index':'-> Child1','regex_direct':'-> Child'}
error='SemanticIndexError: semantic_static_correlation_failed at project_static_semantics: Authored and compiled action-edge identities differ'
for row in rows:
 name=row['case'];assert 'compile_error' not in row and 'runtime_error' not in row,name
 assert row['input']==row['runtime']==expected_inputs[name],name
 expected_targets={'group_prefix':['ChildLong','Child'],'group_other':['Other','Child'],'separate':['ChildLong','Child']}.get(name,['Child'])
 assert [e['targets'] for e in row['compiled_edges']]==[[t] for t in expected_targets],name
 assert all(e['has_block'] is True and e['child_regex_index']==(0 if name=='regex_direct' else 1) for e in row['compiled_edges']),name
 if name in failed:
  assert row['index_error']==error and 'query' not in row,name
  continue
 assert 'index_error' not in row,name
 q=row['query'];assert q['ok'] and q['diagnostics']==[] and q['relations']==[],name
 assert q['snapshot']['state']=='compiled' and q['snapshot']['has_execution'] is False,name
 assert q['page']=={'after_id':None,'next_after_id':None,'complete':True},name
 assert len(q['records'])==len(expected_targets),name
 assert [r['id'] for r in q['records']]==['edge:rule:Top:'+str(i) for i in range(len(expected_targets))],name
 members=row['source'].split('\n\n',1)[0].splitlines()[1:]
 assert [r['source']['excerpt'] for r in q['records']]==[m.strip() for m in members],name
 raw=row['source'].encode()
 for record in q['records']:
  assert record['facts']['source_form']==('direct' if name=='regex_direct' else 'indexed'),name
  assert record['facts']['has_block'] is True,name
  source=record['source'];span=source['span']
  assert raw[span['start_byte']:span['end_byte']].decode()==source['excerpt'],name
  assert source['logical_name']=='dart133.spec',name
print('PASS eight public native compiled/index/runtime controls: four construction failures, four successful controls')
print('Two grouped failures extend startup .70; two regex-arrow failures belong to Dart .2.22')
print('All eight runtime values equal their exact input; successful source forms, members and byte spans verified')
DART133_VERIFY
```
