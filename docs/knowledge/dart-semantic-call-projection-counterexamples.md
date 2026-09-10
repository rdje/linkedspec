---
id: dart-semantic-call-projection-counterexamples
title: Dart semantic queries omit array calls and can attribute action calls to regex text
answers:
  - "does Dart semantic query omit calls inside array expressions"
  - "why does Dart semantic query give an array binding no source"
  - "can Dart semantic call source point into a regex matcher"
  - "does Dart reproduce the Perl Rust semantic false arity acceptance"
  - "does Dart reuse semantic binding ids after repeated assignments"
  - "which task fixes Dart semantic regex call source correlation"
date: 2026-09-10
status: confirmed public Dart query counterexamples; repair pending behind startup prerequisites
tags: [dart, semantic-introspection, calls, source-correlation, arrays, regex, startup-reading]
evidence: "DART-STARTUP-READING.1.30 reads semantic_call_projection.dart 348-1448 through EOF and semantic_index.dart 1-399 at clean b80acc01545fa62662e3494f040b7b29f8ca4c00; nine public-query/typed-action/runtime controls confirm two defective cases and seven valid/arity-rejection controls. Array repair belongs to SESSION-STARTUP-READING.67.2-.67.4; regex correlation belongs to DART-STARTUP-READING.2.20 and two children."
reverify: "Run both managed reproduction blocks below; bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py; cd dart && bash ../tools/run_dart_project_data.sh test test/semantic_index_call_projection_test.dart test/semantic_index_static_graph_test.dart test/semantic_index_source_foundation_test.dart test/semantic_index_compilation_foundation_test.dart test/semantic_index_query_kernel_test.dart"
---

The public `SemanticIndex.fromSource` / `queryNeutral` route returns compiled, successful,
diagnostic-free responses for seven cases. Separate typed compilation and runtime execution
establish which calls actually exist and execute; semantic queries themselves do not execute
targets. Two wrong-arity cases reject during semantic construction and separately at runtime.
The caller chooses logical name `dart130.spec` and text detail; no physical input spec is required.

| Case | Public semantic result | Independent typed/runtime result |
| --- | --- | --- |
| `normalize()` | Constructor correlation error for unresolved typed contracts | Invalid contracts; runtime rejects zero arguments |
| `normalize(" x ")` | Exact one-argument acceptance | Valid; returns `"x"` |
| `normalize(" x ", " y ")` | Constructor correlation error for unresolved typed contracts | Invalid contracts; runtime rejects two arguments |
| `trim(" x ")` | trim and return, exact call/RHS source | Valid; returns `"x"` |
| `[trim(" x ")]` | Only return; binding source null | Array ActionIR contains trim; returns `["x"]` |
| `trim(trim(" x "))` | Both trim calls plus return, exact distinct ranges | Valid; returns `"x"` |
| Four same-name assignments | Binding suffixes 0,1,2,3 and distinct source excerpts | Valid; returns `"3"` |
| Matcher `/trim(x)/` before action `trim(" x ")` | Call and binding cite `trim(x)` at bytes 44–51 | Typed RHS is `trim(" x ")` at bytes 70–81; returns `"x"` |
| `trim("trim(x)")` | String content creates no extra call; exact outer source | Valid; returns `"trim(x)"` |

The exact sources and request are embedded below. An unused function deliberately bypasses
the separate [[semantic-rule-calls-empty-function-gate]]. None of the successful cases has
semantic execution records. The direct runtime is a separate verification operation.

The array cause is `emitExpressionCalls` in
`dart/lib/src/semantic/semantic_call_projection.dart` 405–425: it unwraps scalar assignment,
then returns for every non-call node, including the typed array. Binding source at 349–359
depends on an emitted RHS call, so the omitted child also leaves the binding source null.
This extends [[semantic-call-signature-and-container-projection-gaps]] under startup .67.2.

The regex cause is distinct. Rule cursors receive the entire authored edge at 249–253.
The scanner at 1282–1339 skips quoted strings but has no regex boundary handling, and the
name cursor at 52–59 selects the first matching name. A call-shaped substring inside the
matcher therefore supplies the range for the real ActionIR call. That wrong range is then
registered for both call and binding. Repair .2.20.1 owns typed/lexical source correlation;
.2.20.2 owns independent recurrence, supported-carrier/MCP census and public closeout.

The neighboring counterexamples are controls, not assumed parity failures. The Dart registry
`resolveCall` in `dart/lib/src/action/function_registry.dart` 130–161 tests accepted arity;
the action-owner projection at 973–978 rejects invalid contracts before building call
acceptance records. The zero/two controls therefore do not reproduce the earlier Perl/Rust
false acceptance. Dart's separate `_bindingCounts` map at call projector 334–340 advances
each occurrence, and the four-assignment control does not reproduce
[[rust-semantic-repeated-binding-identity-gap]]. The shape/traversal and generated/staged
surface remains bounded; these controls do not prove all composite nodes or callable kinds.

All 28 selected Dart tests pass. Fresh neutral semantic checks still pass six fixture groups,
twenty queries and 128 rejected mutations, at rollout 9/0 and admission 6/0. Those finite
fixtures do not cover the two counterexamples. No source repair, fresh other-backend result,
emitted/reconstructed carrier result or MCP reproduction is claimed.

The reproduction uses project-local storage and the actual public staged parser for the
separate typed/runtime control. It creates no input `.spec` on disk.

```bash
bash tools/project_data_run.sh python3 - <<'DART130_PROGRAM'
from pathlib import Path
Path('.linkedspec-data/scratch/dart130-calls.dart').write_text("import 'dart:convert';\nimport '../../dart/lib/linkedspec_dart.dart';\n\nvoid main() {\n  const unused = 'fn unused(value) { return(value) }\\n\\n';\n  const normal = 'fn normalize(value) { return(trim(value)) }\\n\\n';\n  String edge(String rhs, {String matcher = 'x'}) =>\n      'Top::\\n /$matcher/ -> Top { value = $rhs; return(value) }\\n';\n  final cases = <String, String>{\n    'arity_zero': normal + edge('normalize()'),\n    'arity_one': normal + edge('normalize(\" x \")'),\n    'arity_two': normal + edge('normalize(\" x \", \" y \")'),\n    'direct': unused + edge('trim(\" x \")'),\n    'array': unused + edge('[trim(\" x \")]'),\n    'nested': unused + edge('trim(trim(\" x \"))'),\n    'repeated_four': unused + 'Top::\\n /x/ -> Top { value = trim(\" 0 \"); value = trim(\" 1 \"); value = trim(\" 2 \"); value = trim(\" 3 \"); return(value) }\\n',\n    'regex_decoy': unused + edge('trim(\" x \")', matcher: 'trim(x)'),\n    'string_decoy': unused + edge('trim(\"trim(x)\")'),\n  };\n  final request = <String,Object?>{\n    'contract': 'linkedspec-semantic-query-v1',\n    'operation': 'list',\n    'subjects': <Object?>[],\n    'record_kinds': <Object?>[],\n    'relation_kinds': <Object?>[],\n    'direction': 'outgoing',\n    'page': {'after_id': null, 'limit': 100},\n    'budget': {'max_records': 1000, 'max_relations': 2000, 'max_depth': 4},\n    'source': {'detail':'text','include_content_digest':false},\n  };\n  final rows = <Map<String,Object?>>[];\n  for(final entry in cases.entries) {\n    try {\n      final index = SemanticIndex.fromSource(entry.value, options: const SemanticIndexOptions(logicalName:'dart130.spec',sourceDetailCeiling:SemanticSourceDetail.text));\n      rows.add({'case':entry.key,'source':entry.value,'response':index.queryNeutral(request).toJson()});\n    } catch(error) {\n      rows.add({'case':entry.key,'source':entry.value,'error_type':error.runtimeType.toString(),'error':error.toString()});\n    }\n  }\n  for (final row in rows) {\n    try {\n      final compiled = compileSpec(parseSpecWithStagedUserFunctionDefinitions(row['source']! as String));\n      final payload = compiled.rulesByLabel['Top']!.actionEdges.single.actionPayload!;\n      row['typed_action'] = payload.actionAst.toJson();\n      row['contracts_ok'] = payload.contracts.ok;\n      final input = row['case'] == 'regex_decoy' ? 'trimx' : 'x';\n      row['runtime_value'] = LinkedSpecRuntimeEngine(compiled).parse(input).value;\n    } catch(error) {\n      row['runtime_error_type'] = error.runtimeType.toString();\n      row['runtime_error'] = error.toString();\n    }\n  }\n  print(jsonEncode(rows));\n}\n")
DART130_PROGRAM
bash tools/run_dart_project_data.sh run .linkedspec-data/scratch/dart130-calls.dart > .linkedspec-data/scratch/dart130-calls.json 2> .linkedspec-data/scratch/dart130-calls.stderr
```

```bash
bash tools/project_data_run.sh python3 - <<'DART130_VERIFY'
from pathlib import Path
import json
rows=json.loads(Path('.linkedspec-data/scratch/dart130-calls.json').read_text())
assert len(rows)==9 and len({r['case'] for r in rows})==9
assert Path('.linkedspec-data/scratch/dart130-calls.stderr').read_bytes()==b''
cases={r['case']:r for r in rows}
expected={
 'arity_one':(['normalize','return'],'x'),
 'direct':(['trim','return'],'x'),
 'array':(['return'],['x']),
 'nested':(['trim','trim','return'],'x'),
 'repeated_four':(['trim','trim','trim','trim','return'],'3'),
 'regex_decoy':(['trim','return'],'x'),
 'string_decoy':(['trim','return'],'trim(x)'),
}
def records(case,kind):
 return [r for r in cases[case]['response']['records'] if r['kind']==kind]
def edge_calls(case):
 return [r for r in records(case,'call') if r['owner_id']=='edge:rule:Top:0']
for name,(calls,value) in expected.items():
 row=cases[name];res=row['response']
 assert res['ok'] and res['snapshot']['state']=='compiled' and not res['snapshot']['has_execution']
 assert res['diagnostics']==[] and row['contracts_ok'] is True and row['runtime_value']==value,name
 assert 'error' not in row and 'runtime_error' not in row,name
 assert [r['name'] for r in edge_calls(name)]==calls,name
 ids=[r['id'] for r in res['records']];assert len(ids)==len(set(ids)),name
 source=row['source'].encode()
 for r in res['records']:
  ref=r['source']
  if ref is not None:
   span=ref['span'];assert source[span['start_byte']:span['end_byte']].decode()==ref['excerpt'],(name,r['id'])
for name,count in [('arity_zero',0),('arity_two',2)]:
 row=cases[name];assert 'response' not in row
 assert row['error_type']=='SemanticIndexError'
 assert row['error']=='semantic_call_correlation_failed at project_call_semantics: Compiled action owner has unresolved typed contracts'
 assert row['contracts_ok'] is False and row['runtime_error_type']=='RuntimeInterpreterException'
 assert row['runtime_error']==f"RuntimeInterpreterException: user function 'normalize' expects 1 argument(s), got {count} in rule Top"
signature=records('arity_one','function')[0]['facts']['signature']
assert signature['arity_min']==signature['arity_max']==1
accepted=[r for r in records('arity_one','explanation_step') if r['facts']['rule_code']=='call_signature_accepts']
assert len(accepted)==1 and 'one supplied string argument' in accepted[0]['facts']['summary']
rhs=cases['array']['typed_action']['statements'][0]['expr']['value']
assert rhs['kind']=='array_literal' and rhs['items'][0]['kind']=='call' and rhs['items'][0]['name']=='trim'
assert rhs['source']=='[trim(" x ")]'
assert records('array','binding')[0]['source'] is None
assert edge_calls('direct')[0]['source']['excerpt']=='trim(" x ")'
assert [r['source']['excerpt'] for r in edge_calls('nested')]==['trim(trim(" x "))','trim(" x ")','return(value)']
assert edge_calls('string_decoy')[0]['source']['excerpt']=='trim("trim(x)")'
bindings=records('repeated_four','binding')
assert [r['id'].rsplit(':',1)[1] for r in bindings]==['0','1','2','3']
assert [r['source']['excerpt'] for r in bindings]==[f'trim(" {n} ")' for n in range(4)]
decoy=cases['regex_decoy'];typed=decoy['typed_action']['statements'][0]['expr']['value']
assert typed['kind']=='call' and typed['name']=='trim' and typed['source']=='trim(" x ")'
actual=edge_calls('regex_decoy')[0]['source'];binding=records('regex_decoy','binding')[0]['source']
assert actual['excerpt']==binding['excerpt']=='trim(x)'
assert (actual['span']['start_byte'],actual['span']['end_byte'])==(44,51)
expected_start=decoy['source'].encode().index(typed['source'].encode())
assert expected_start==70 and expected_start!=actual['span']['start_byte']
assert decoy['source'].encode()[expected_start:expected_start+len(typed['source'].encode())].decode()==typed['source']
print('PASS nine public-query/typed-runtime controls: two defective cases, seven valid/arity-rejection controls')
print('Array: active typed trim -> runtime ["x"], query omits trim and binding source')
print('Regex: typed RHS bytes 70-81, query call/binding incorrectly cite matcher bytes 44-51')
print('No false arity acceptance or repeated-binding identity failure reproduced on these Dart routes')
DART130_VERIFY
```
