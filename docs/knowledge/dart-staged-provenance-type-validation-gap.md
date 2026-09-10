---
id: dart-staged-provenance-type-validation-gap
title: Dart staged provenance validation promotes diagnostic placeholders into data
answers:
  - "does Dart reject non-string staged provenance labels"
  - "can malformed staged source_id select the runtime placeholder source"
  - "why does Dart accept null provenance as invalid text"
  - "do derived staged segments validate original field types"
  - "which task owns Dart staged provenance type validation"
  - "are literal runtime and invalid placeholder strings forbidden source names"
  - "is validateAndMaterializeStagedProvenance exposed through MCP"
  - "is the staged provenance validator part of deep semantic introspection"
date: 2026-09-10
status: confirmed private validator mismatch; repair pending under DART-STARTUP-READING.2.19 behind startup gates
tags: [dart, staged-parsing, provenance, validation, source-authority, startup, defect]
evidence: "Reading .1.27 compares seventeen private validateAndMaterializeStagedProvenance cases against the existing neutral materialize_provenance evaluator. Six malformed records are accepted by Dart after placeholder coercion; eleven controls agree. All 33 selected tests and Unicode regeneration/12 neutral fixtures pass. No other-backend runtime or fresh authored production-carrier failure is claimed."
reverify:
  - "Run DART_STAGED_PROVENANCE_PROBE, the managed Dart command, and DART_STAGED_PROVENANCE_VERIFY below; they pin exact pre-repair behavior."
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
---

# Malformed typed provenance becomes valid-looking data

Owner `DART-STARTUP-READING.1.27` activates from clean
`2b8b4bd7dc29f0915e804b9aaf99c70603daf305`. The source is unchanged.
The probe calls the admitted private `validateAndMaterializeStagedProvenance`
API with detached records and a caller-owned `SourceAuthority`. It compares
every row with the existing neutral checker function `materialize_provenance`,
rather than inventing a competing schema.

This is an internal staged-runtime validation function, called here by a local
Dart diagnostic program. It is separate from deep semantic introspection. MCP
exposes capabilities/query over host-registered immutable semantic indexes;
it does not expose this validator. See [[mcp-native-server-topology]] and
[[parser-authoring-dbinp-intake]] for the current transport and parked authoring
boundaries. The word private does not mean a private MCP endpoint.

| Input variation | Dart | Neutral validator |
| --- | --- | --- |
| Valid direct or single-segment derived provenance | Accepts exact é🙂 from input:[1,3) | Agrees |
| provenance is null, integer 7, or an object | Accepts; replaces it with string `<invalid>` | Rejects all three |
| Derived segment has null provenance | Accepts with `<invalid>` in that segment | Rejects |
| source_id is null or integer 7, and caller owns source `<runtime>` | Accepts; selects that source and returns 🙂S | Rejects both |
| Null source_id without caller source `<runtime>` | Rejects unknown fallback source | Agrees |
| Empty/missing provenance, extra key, string offset, unknown source, reversed span, or empty derived segments | Rejects | Agrees |
| Explicit string source_id `<runtime>` and string provenance `<invalid>` | Accepts caller-authorized 🙂S | Agrees |

This is **six malformed acceptances and eleven agreeing controls**. The
placeholder-looking strings are valid strings when supplied explicitly; the
defect is substituting them for a malformed original field. The sources in this
probe are `input = Aé🙂BC` and, when requested, `<runtime> = R🙂ST`. No path,
filesystem, external input or ambient source access is involved.

`_typedDirectSpan` in `dart/lib/src/runtime/staged_parse_job.dart` first converts
non-string source/provenance fields into diagnostic labels `<runtime>` and
`<invalid>` (lines 175–180). Its condition checks exact keys, kind, the replacement
provenance's non-emptiness, and integer offsets (181–191), but not the original
field types. It then constructs typed positions/spans with those replacements.
The derived validator delegates each segment to this same helper. By contrast,
the neutral helper rejects non-string source_id at line 646 and non-string
provenance at 660 before materializing text.

The existing Dart staged consumer at 399–431 checks the eight neutral provenance
fixtures and matches their expected records/errors. Those cases do not cover
the six malformed acceptances above. All 33 selected staged/typed-source/matching/
scalar/casing tests pass for their covered cases. Unicode generation separately
byte-compares the neutral contract and all five backend modules and passes its
twelve neutral fixtures.

Repair `DART-STARTUP-READING.2.19.1` owns strict original-type checks while
retaining diagnostic fallback labels and valid literal placeholder strings.
`.2.19.2` owns neutral/runtime case extension, actual-entrypoint and applicable
carrier proof, public documentation, and canonical closeout. Ordinary typed
authored constructors, host-injected records and returned markers must remain
distinct in that audit. This private probe does not establish the malformed
inputs through normal authored/native/reconstructed/generated/emitted execution
or another backend's runtime. Staged resource repairs .2.17/.2.18 and Rust
startup .74 retain their separate mechanisms and evidence.

## Reproduction

The program calls LinkedSpec's validator directly; it has no replacement
materializer. All scratch output remains under the repository root.

```bash
bash tools/project_data_run.sh python3 - <<'DART_STAGED_PROVENANCE_PROBE'
from pathlib import Path
program = r'''
import 'dart:convert';
import 'dart:io';
import '../../dart/lib/src/runtime/staged_parse_job.dart';
import '../../dart/lib/src/runtime/source_location.dart';

void main() {
  Map<String,Object?> direct({Object? sourceId='input',Object? provenance='capture',Object? start=1,Object? end=3}) => <String,Object?>{
    'kind':'direct_span','source_id':sourceId,'start':start,'end':end,'provenance':provenance,
  };
  Map<String,Object?> derived(Object? segment) => <String,Object?>{'kind':'derived_text','policy':'concatenate_in_order','segments':[segment]};
  final rows=<Object?>[];
  final cases=<({String id,Map<String,Object?> record,bool alias})>[
    (id:'valid_direct',record:direct(),alias:false),
    (id:'valid_derived',record:derived(direct()),alias:false),
    (id:'null_provenance',record:direct(provenance:null),alias:false),
    (id:'numeric_provenance',record:direct(provenance:7),alias:false),
    (id:'object_provenance',record:direct(provenance:<String,Object?>{'kind':'not_text'}),alias:false),
    (id:'null_source_without_alias',record:direct(sourceId:null),alias:false),
    (id:'null_source_with_alias',record:direct(sourceId:null),alias:true),
    (id:'numeric_source_with_alias',record:direct(sourceId:7),alias:true),
    (id:'derived_null_provenance',record:derived(direct(provenance:null)),alias:false),
    (id:'empty_provenance',record:direct(provenance:''),alias:false),
    (id:'missing_provenance',record:direct()..remove('provenance'),alias:false),
    (id:'extra_key',record:direct()..['text']='not_authority',alias:false),
    (id:'string_start',record:direct(start:'1'),alias:false),
    (id:'unknown_source',record:direct(sourceId:'absent'),alias:false),
    (id:'reversed_span',record:direct(start:3,end:1),alias:false),
    (id:'empty_derived',record:<String,Object?>{'kind':'derived_text','policy':'concatenate_in_order','segments':<Object?>[]},alias:false),
    (id:'literal_placeholders',record:direct(sourceId:'<runtime>',provenance:'<invalid>'),alias:true),
  ];
  for(final item in cases) {
    final authority=SourceAuthority(sources:<String,String>{'input':'Aé🙂BC',if(item.alias) '<runtime>':'R🙂ST'});
    final row=<String,Object?>{'id':item.id,'record':item.record,'alias':item.alias};
    try {
      final result=validateAndMaterializeStagedProvenance(authority:authority,record:item.record,origin:'dart127:provenance');
      row.addAll(<String,Object?>{'accepted':true,'result':result});
    } on StagedParseJobDeclarationException catch(error) {
      row.addAll(<String,Object?>{'accepted':false,'error':error.toJson()});
    }
    rows.add(row);
  }
  stdout.writeln(jsonEncode(rows));
}
'''
Path('.linkedspec-data/scratch/dart127-provenance.dart').write_text(program.lstrip('\n'))
DART_STAGED_PROVENANCE_PROBE
bash tools/run_dart_project_data.sh run .linkedspec-data/scratch/dart127-provenance.dart > .linkedspec-data/scratch/dart127-provenance.json 2> .linkedspec-data/scratch/dart127-provenance.stderr
```

The independent check calls the neutral evaluator, pins all seventeen output
records and diagnostic identities, checks source identity, and reports exact
probe/output hashes. These are pre-repair evidence assertions, not acceptance
criteria for retaining the defect.

```bash
bash tools/project_data_run.sh python3 - <<'DART_STAGED_PROVENANCE_VERIFY'
from pathlib import Path
import hashlib,json,runpy,subprocess
rows=json.loads(Path('.linkedspec-data/scratch/dart127-provenance.json').read_text())
ids=['valid_direct','valid_derived','null_provenance','numeric_provenance','object_provenance','null_source_without_alias','null_source_with_alias','numeric_source_with_alias','derived_null_provenance','empty_provenance','missing_provenance','extra_key','string_start','unknown_source','reversed_span','empty_derived','literal_placeholders']
assert [row['id'] for row in rows]==ids
neutral=runpy.run_path('tools/check_staged_ast_enrichment_contract.py')['materialize_provenance']
mismatches={'null_provenance','numeric_provenance','object_provenance','null_source_with_alias','numeric_source_with_alias','derived_null_provenance'}
valid={'valid_direct','valid_derived','literal_placeholders'}
error_fields={'null_source_without_alias':('<runtime>','capture'),'empty_provenance':('input',''),'missing_provenance':('input','<invalid>'),'extra_key':('input','capture'),'string_start':('input','capture'),'unknown_source':('absent','capture'),'reversed_span':('input','capture'),'empty_derived':('<derived>','derived_text')}
observed=set()
for row in rows:
    name=row['id']
    sources={'input':'Aé🙂BC',**({'<runtime>':'R🙂ST'} if row['alias'] else {})}
    expected=neutral({'provenance':row['record']},sources)
    assert expected[0]==(name in valid),(name,expected)
    assert row['accepted']==(name in valid|mismatches),name
    if row['accepted']!=expected[0]:observed.add(name)
    if not row['accepted']:
        source,label=error_fields[name]
        assert row['error']=={'code':'staged_source_provenance_invalid','phase':'declare','origin':'dart127:provenance','source_id':source,'provenance':label}
        assert expected==(False,None,'staged_source_provenance_invalid')
        continue
    alias=name in {'null_source_with_alias','numeric_source_with_alias','literal_placeholders'}
    label='<invalid>' if name in {'null_provenance','numeric_provenance','object_provenance','derived_null_provenance','literal_placeholders'} else 'capture'
    span={'kind':'direct_span','source_id':'<runtime>' if alias else 'input','start':1,'end':3,'provenance':label}
    provenance={'kind':'derived_text','policy':'concatenate_in_order','segments':[span]} if name in {'valid_derived','derived_null_provenance'} else span
    text='🙂S' if alias else 'é🙂'
    assert row['result']=={'text':text,'provenance':provenance},name
    if name in valid:assert expected==(True,text,None)
    else:assert expected==(False,None,'staged_source_provenance_invalid')
assert observed==mismatches
assert not Path('.linkedspec-data/scratch/dart127-provenance.stderr').read_bytes()
src=Path('dart/lib/src/runtime/staged_parse_job.dart')
assert src.read_bytes()==subprocess.check_output(['git','show','2b8b4bd7dc29f0915e804b9aaf99c70603daf305:'+str(src)])
s=src.read_text();a=s.index('_typedDirectSpan(SourceAuthority');z=s.index('Map<String, Object?> _directRuntimeRecord(',a)
body=s[a:z]
assert "object['source_id'] is String" in body and "object['provenance'] is String" in body
assert "object['source_id'] is! String" not in body and "object['provenance'] is! String" not in body
for path in ['.linkedspec-data/scratch/dart127-provenance.dart','.linkedspec-data/scratch/dart127-provenance.json']:
    b=Path(path).read_bytes();print(json.dumps({'path':path,'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}))
print('PASS 17 private/neutral provenance controls: 6 malformed acceptances and 11 agreeing controls; unchanged source and no repair claim')
DART_STAGED_PROVENANCE_VERIFY
```

Related: [[dart-staged-ast-enrichment-marker-provenance]],
[[general-staged-ast-enrichment-neutral-contract]],
[[dart-staged-resource-boundary-gaps]],
[[rust-staged-returned-marker-validation-gaps]].
