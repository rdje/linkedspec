---
id: dart-mcp-unicode-key-order-gap
title: Dart MCP canonical JSON sorts supplementary-plane keys differently from the neutral owner
answers:
  - does Dart MCP canonical JSON sort Unicode keys in neutral order
  - do astral Unicode keys change Dart canonical JSON bytes
  - does SplayTreeMap preserve the LinkedSpec canonical key order
  - where is the Dart MCP Unicode serialization repair owned
date: 2026-09-09
status: confirmed production-helper and controlled injected-dispatch defect; repair gated under DART-STARTUP-READING.2.5
tags: [dart, mcp, unicode, canonical-json, defect, startup]
evidence: "DART-STARTUP-READING.1.10 reads mcp_contract_runtime.dart. Its _canonicalJsonValue uses default SplayTreeMap ordering. Four direct calls through McpServerTestHarness.canonicalJson match neutral canonical_bytes on ASCII/BMP controls but reverse U+E000 and U+10000 at root and nested object levels. No source repair is made; public native payload reach and other serializers remain separately scoped."
reverify: "Run the repository-managed DART_MCP_UNICODE_ORDER recipe below."
---

# Unicode key-order mismatch

The generated MCP contract requires canonical JSON identity. The actual neutral byte owner,
`tools/check_mcp_semantic_transport_contract.py::canonical_bytes`, recursively sorts object keys.
The Dart production path `_mcpCanonicalJson` calls `_canonicalJsonValue` in
`dart/lib/src/mcp/mcp_contract_runtime.dart`; its map branch uses
`SplayTreeMap<String, Object?>()` without a comparator.

The direct LinkedSpec test seam calls that production serializer. ASCII and BMP-only controls agree.
With keys U+E000 and U+10000, Dart emits U+10000 first; the neutral owner emits U+E000 first.
The same mismatch occurs inside an object nested in an array. Values and decoded JSON remain equal,
but canonical bytes differ. Default Dart string ordering uses UTF-16 code units at this boundary;
the supplementary character begins with U+D800, before U+E000.

This confirms the helper's mismatch. It does not yet establish a public native SemanticIndex payload
that carries these keys, an emitted/wire outcome, or another backend's behavior. Those paths and other
Dart serializers belong to `DART-STARTUP-READING.2.5.1`; `.2.5.2` owns repair and recurring byte proof
after startup reading/policy gates. Existing finite canonical fixtures do not close this gap.

## Exact replay

This calls the production Dart serializer through the existing package-internal LinkedSpec harness,
then compares with the actual neutral checker function. All project outputs stay under managed scratch.

```bash
bash tools/project_data_run.sh python3 - <<'DART_MCP_UNICODE_ORDER'
from pathlib import Path
Path('.linkedspec-data/scratch/dart110-canonical-probe.dart').write_text("import 'dart:convert';\nimport '../../dart/lib/src/mcp/mcp_server.dart';\nvoid main() {\n  final cases = <String, Object?>{\n    'ascii': {'z': 1, 'a': 2},\n    'bmp': {'\\u{E000}': 1, '\\u{D7FF}': 2},\n    'bmp_astral': {'\\u{E000}': 1, '\\u{10000}': 2},\n    'nested_bmp_astral': {'outer': [{'\\u{10000}': 2, '\\u{E000}': 1}]},\n  };\n  for (final entry in cases.entries) {\n    final text = McpServerTestHarness.canonicalJson(entry.value);\n    print(jsonEncode({'case': entry.key, 'json': text, 'runes': text.runes.toList()}));\n  }\n}\n")
DART_MCP_UNICODE_ORDER
bash tools/run_dart_project_data.sh run .linkedspec-data/scratch/dart110-canonical-probe.dart > .linkedspec-data/scratch/dart110-canonical-probe.log
bash tools/project_data_run.sh python3 - <<'DART_MCP_UNICODE_COMPARE'
from pathlib import Path
import json,sys
sys.path.insert(0,str(Path('tools').resolve()))
from check_mcp_semantic_transport_contract import canonical_bytes
cases={
'ascii':{'z':1,'a':2},
'bmp':{chr(0xe000):1,chr(0xd7ff):2},
'bmp_astral':{chr(0xe000):1,chr(0x10000):2},
'nested_bmp_astral':{'outer':[{chr(0x10000):2,chr(0xe000):1}]},
}
rows=[json.loads(line) for line in Path('.linkedspec-data/scratch/dart110-canonical-probe.log').read_text().splitlines()]
assert [r['case'] for r in rows]==list(cases)
for row in rows:
    expected=canonical_bytes(cases[row['case']]).decode()
    row['neutral']=expected
    row['equal']=row['json']==expected
    print(json.dumps(row,ensure_ascii=True))
assert [row['equal'] for row in rows]==[True,True,False,False]

DART_MCP_UNICODE_COMPARE
```


## Controlled decoded-dispatch reach

A fifth probe registers a real source-built index, then uses the existing `queryIndex` test seam to
supply a schema-valid semantic rejection payload whose diagnostic fields contain U+E000 and U+10000.
The public `McpServer.dispatch` returns `isError=false` and unchanged structured JSON values, but
its text payload orders U+10000 first and differs from the neutral canonical bytes. This is an
injected query-result proof, not a claim that normal native index construction produces those keys.
The 11 existing binding/decoded-dispatch tests pass and therefore do not close this mismatch.

```bash
bash tools/project_data_run.sh python3 - <<'DART_MCP_UNICODE_DISPATCH'
from pathlib import Path
Path('.linkedspec-data/scratch/dart110-dispatch-canonical-probe.dart').write_text("import 'dart:convert';\nimport 'dart:io';\nimport '../../dart/lib/linkedspec_dart.dart';\nimport '../../dart/lib/src/mcp/mcp_server.dart' show McpServerTestHarness;\nvoid main() {\n  final index = SemanticIndex.fromUtf8(\n    File('capability_conformance/semantic_introspection/graph.spec').readAsBytesSync(),\n    options: const SemanticIndexOptions(logicalName: 'graph.spec', sourceDetailCeiling: SemanticSourceDetail.text),\n  );\n  final payload = ((McpServerTestHarness.frame('semantic_ok_false_response')!['result']\n    as Map)['structuredContent'] as Map).cast<String, Object?>();\n  ((payload['diagnostics'] as List).first as Map)['fields'] = {\n    'reason': 'operation_combination', '\\u{E000}': 1, '\\u{10000}': 2,\n  };\n  final server = McpServerTestHarness.create(\n    entropy: () => List<int>.filled(32, 7),\n    nowMs: () => 0,\n    queryIndex: (_, _) => payload,\n  );\n  final authorization = utf8.encode('controlled-principal');\n  final handle = server.registerIndex(index, authorization);\n  final request = McpServerTestHarness.frame('query_call_request')!;\n  ((request['params'] as Map)['arguments'] as Map)['handle'] = handle;\n  final response = server.dispatch(request, authorization)!;\n  final result = response['result'] as Map;\n  print(jsonEncode({\n    'case': 'injected_query_dispatch',\n    'payload_schema_valid': McpServerTestHarness.validateNamed('semanticQueryResponse', payload),\n    'is_error': result['isError'],\n    'text': ((result['content'] as List).first as Map)['text'],\n    'structured': result['structuredContent'],\n  }));\n  server.shutdown();\n}\n")
DART_MCP_UNICODE_DISPATCH
bash tools/run_dart_project_data.sh run .linkedspec-data/scratch/dart110-dispatch-canonical-probe.dart > .linkedspec-data/scratch/dart110-dispatch-canonical-probe.log
bash tools/project_data_run.sh python3 - <<'DART_MCP_UNICODE_DISPATCH_COMPARE'
from pathlib import Path
import json,sys
sys.path.insert(0,str(Path('tools').resolve()))
from check_mcp_semantic_transport_contract import canonical_bytes
row=json.loads(Path('.linkedspec-data/scratch/dart110-dispatch-canonical-probe.log').read_text())
assert row['payload_schema_valid'] is True and row['is_error'] is False
assert json.loads(row['text'])==row['structured']
expected=canonical_bytes(row['structured']).decode()
assert row['text']!=expected
print('PASS controlled injected dispatch reproduces canonical byte mismatch with equal JSON values')

DART_MCP_UNICODE_DISPATCH_COMPARE
```
