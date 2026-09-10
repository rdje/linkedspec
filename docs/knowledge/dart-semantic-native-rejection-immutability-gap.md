---
id: dart-semantic-native-rejection-immutability-gap
title: Native non-JSON cursors can make Dart semantic rejection responses mutable or unencodable
answers:
  - "can Dart queryNeutral retain an invalid caller object in its response"
  - "why does a rejected Dart semantic query change after caller mutation"
  - "can Dart semantic rejected cursor responses fail JSON encoding"
  - "does the Dart native semantic rejection gap reproduce through MCP"
  - "which task owns Dart semantic non-JSON rejection evidence"
date: 2026-09-10
status: confirmed native non-JSON rejection boundary; repair pending behind startup prerequisites
tags: [dart, semantic-query, native-api, immutability, diagnostics, json, startup-reading]
evidence: "DART-STARTUP-READING.1.31 reads semantic_index.dart 400-1231 and semantic_query.dart 1-668 from clean 3f21f3b084fbbd8c51ce2387ed8cc1c5bb6ffa3b. Eight native raw-query controls confirm four defective non-JSON cases and four detached JSON controls. DART-STARTUP-READING.2.21 and two children own admission/rejection, recurrence and public closeout."
reverify: "Run both managed reproduction blocks below; bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py; cd dart && bash ../tools/run_dart_project_data.sh test test/semantic_index_source_foundation_test.dart test/semantic_index_compilation_foundation_test.dart test/semantic_index_query_kernel_test.dart"
---

A native caller can put values outside the standard JSON domain into the
`Object?` request accepted by `SemanticIndex.queryNeutral`. The validator rejects
these cursors, but its returned error envelope can still retain the caller's
object or a nonfinite number. That breaks response detachment/serializability
at this native rejection boundary.

This is distinct from the supported malformed JSON controls: nested ordinary
maps/lists and integer cursors are rejected with detached, serializable evidence;
a null cursor succeeds. The typed request's `String?` cursor cannot represent
the tested host objects. These native probes do not establish MCP reproduction
or a parser execution failure, and do not imply that arbitrary host objects
are valid semantic query inputs.

| Native `page.after_id` | Rejection result | Result after caller mutation |
| --- | --- | --- |
| Mutable caller object with `toJson` | `semantic_query_invalid`; same host object retained | Existing response encodes value 1, then value 2 |
| Map containing that object | Same rejection; nested host identity retained | Existing response encodes nested value 1, then 2 |
| Plain `Object()` | Same rejection; host identity retained | Response JSON encoding raises `JsonUnsupportedObjectError` |
| `double.nan` | Same rejection | Response JSON encoding raises `JsonUnsupportedObjectError` |
| JSON map with mutable list | Same rejection; detached evidence | Original list mutation leaves response at `{"items":[1]}` |
| JSON list | Same rejection; detached evidence | Original list mutation leaves response at `[1]` |
| Integer 7 | Same rejection; plain evidence | Stable serializable value 7 |
| Null | Successful list query | Stable serializable null cursor |

The two mutable-object cases serialize through the caller object's `toJson`
method after the response has already been returned. No new query runs between
the before/after captures. Three cases retain caller host identity; two cases
fail JSON encoding. Those counts overlap and describe four defective cases,
not seven separate cases. Four JSON controls pass.

The rejection helper in `dart/lib/src/semantic/semantic_query.dart` 1435–1474
copies raw `page.after_id` into the rejected response even when cursor
validation fails. `SemanticQueryPageState` at 355–374 calls
`_immutablePlainValue`, and its `toJson` calls `_detachedPlainValue`.
Both helpers in `dart/lib/src/semantic/semantic_index.dart` 1020–1046 recurse
through maps/lists but return all other values unchanged. They neither reject
host objects nor ensure finite JSON numbers. Query validation correctly reports
`reason: after_id`; the defect is in the retained rejection evidence.

`DART-STARTUP-READING.2.21.1` owns explicit native-domain admission or safe rejection
without caller hooks, while preserving existing malformed JSON evidence and
neutral responses. `.2.21.2` owns immutability/serialization recurrence and a
bounded census of public value constructors sharing these helpers. Cycles,
custom collections, other fields, other backends and transport routes were not
measured by these eight controls; they must not be inferred from this finding.

All eighteen selected source/compilation/query tests and neutral semantic
6-group/20-query/128-mutation checks pass. Governance remains rollout 9/0 and
admission 6/0. No source repair or new API capability lands in this reading
slice. Earlier [[dart-semantic-call-projection-counterexamples]] and staged
provenance findings retain their separate owners.

The complete reproduction uses native public constructors and queryNeutral,
with a caller-owned in-memory source and repository-local diagnostic outputs.

```bash
bash tools/project_data_run.sh python3 - <<'DART131_PROGRAM'
from pathlib import Path
Path('.linkedspec-data/scratch/dart131-immutability.dart').write_text("import 'dart:convert';\nimport '../../dart/lib/linkedspec_dart.dart';\n\nfinal class MutableBox {\n  int value = 1;\n  Map<String,Object?> toJson() => {'value':value};\n}\nString encodeResult(SemanticQueryResponse response) {\n  try { return jsonEncode(response.toJson()); }\n  catch(error) { return 'ENCODING_ERROR:${error.runtimeType}'; }\n}\nbool containsIdentity(Object? root, Object target) {\n  if (identical(root,target)) return true;\n  if (root is Map) return root.values.any((item)=>containsIdentity(item,target));\n  if (root is List) return root.any((item)=>containsIdentity(item,target));\n  return false;\n}\nvoid main() {\n  final index = SemanticIndex.fromSource('Top::\\n /x/\\n',options: const SemanticIndexOptions(logicalName:'dart131.spec',sourceDetailCeiling:SemanticSourceDetail.text));\n  final results=<Map<String,Object?>>[];\n  for(final name in ['direct_host','nested_host','plain_host','nonfinite_cursor','json_map','json_list','integer_cursor','null_cursor']) {\n    final box=MutableBox();\n    final plain=Object();\n    final Object? cursor=switch(name) {\n      'direct_host'=>box,\n      'nested_host'=>{'box':box},\n      'plain_host'=>plain,\n      'nonfinite_cursor'=>double.nan,\n      'json_map'=>{'items':<Object?>[1]},\n      'json_list'=><Object?>[1],\n      'integer_cursor'=>7,\n      _=>null,\n    };\n    final request=SemanticQuery(operation:SemanticQueryOperation.list).toJson();\n    (request['page']! as Map<String,Object?>)['after_id']=cursor;\n    try {\n      final response=index.queryNeutral(request);\n      final before=encodeResult(response);\n      final retained=containsIdentity(response.page.afterId,box)||containsIdentity(response.page.afterId,plain);\n      box.value=2;\n      if(name=='json_map') ((cursor! as Map)['items'] as List).add(2);\n      if(name=='json_list') (cursor! as List).add(2);\n      final after=encodeResult(response);\n      results.add({\n        'case':name,'ok':response.ok,\n        'diagnostic_codes':response.diagnostics.map((d)=>d.code).toList(),\n        'retains_host_identity':retained,\n        'serialized_before':before,'serialized_after':after,\n        'serialization_changed':before!=after,\n      });\n    } catch(error) {\n      results.add({'case':name,'error_type':error.runtimeType.toString(),'error':error.toString()});\n    }\n  }\n  print(jsonEncode(results));\n}\n")
DART131_PROGRAM
bash tools/run_dart_project_data.sh run .linkedspec-data/scratch/dart131-immutability.dart > .linkedspec-data/scratch/dart131-immutability.json 2> .linkedspec-data/scratch/dart131-immutability.stderr
```

```bash
bash tools/project_data_run.sh python3 - <<'DART131_VERIFY'
from pathlib import Path
import json
rows=json.loads(Path('.linkedspec-data/scratch/dart131-immutability.json').read_text())
assert len(rows)==8 and len({r['case'] for r in rows})==8
assert Path('.linkedspec-data/scratch/dart131-immutability.stderr').read_bytes()==b''
cases={r['case']:r for r in rows}
for name,row in cases.items():
 assert 'error' not in row,name
 assert row['ok'] == (name=='null_cursor'),name
 assert row['diagnostic_codes']==([] if name=='null_cursor' else ['semantic_query_invalid']),name
 assert row['retains_host_identity']==(name in ['direct_host','nested_host','plain_host']),name
 assert row['serialization_changed']==(name in ['direct_host','nested_host']),name
 if name in ['plain_host','nonfinite_cursor']:
  assert row['serialized_before']==row['serialized_after']=='ENCODING_ERROR:JsonUnsupportedObjectError',name
 else:
  before=json.loads(row['serialized_before']);after=json.loads(row['serialized_after'])
  if name!='null_cursor':
   assert before['records']==before['relations']==[] and after['records']==after['relations']==[]
   assert before['diagnostics'][0]['fields']=={'reason':'after_id'}
  b=before['page']['after_id'];a=after['page']['after_id']
  if name=='direct_host':assert b=={'value':1} and a=={'value':2}
  elif name=='nested_host':assert b=={'box':{'value':1}} and a=={'box':{'value':2}}
  elif name=='json_map':assert b==a=={'items':[1]}
  elif name=='json_list':assert b==a==[1]
  elif name=='integer_cursor':assert b==a==7
  else:assert b is None and a is None
  if name not in ['direct_host','nested_host']:assert row['serialized_before']==row['serialized_after']
print('PASS eight native raw-query controls: four defective non-JSON cases, four detached JSON controls')
print('Two caller-object mutations change rejected-response serialization; three cases retain host identity')
print('Plain object and NaN rejected cursors fail JSON encoding; no typed-query or MCP reproduction claimed')
DART131_VERIFY
```
