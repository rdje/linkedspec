---
id: dart-null-named-selector-validation-gap
title: Dart reconstructed null named selectors can resolve anonymous regex declarations
answers:
  - "why does Dart accept null as a named regex selector"
  - "can a reconstructed Dart named selector select an anonymous slot"
  - "does Dart selector validation check authored_selector type"
  - "which task owns null named selector validation"
  - "does Dart reject malformed selector provenance in SpecFile JSON"
date: 2026-09-10
status: confirmed defect; repair pending behind startup reading and policy gates
tags: [dart, validation, regex-slots, reconstruction, provenance, defect]
evidence: DART-STARTUP-READING.1.35; spec_validator.dart 771-785/818-830; spec_ast.dart 770-797; compiled_spec.dart 1547-1566/1711-1729; ten public reconstructed controls; DART-STARTUP-READING.2.23
reverify: "Run both complete repository-rooted reproduction blocks below; they regenerate and independently check the ten controls without a filesystem .spec input."
---

Reading `DART-STARTUP-READING.1.35` confirms that a reconstructed
`EdgeTarget` with `selector_kind: named` and `authored_selector: null` passes
validation and selects an anonymous regex declaration. A named selector must
identify a named declaration under [[inter-match-gap-executable-contract-plan]].
Anonymous declarations have a null slot ID; that absence is not a valid name.

The ten controls start with valid parsed source, JSON-round-trip the AST,
replace exactly one target's selector fields, then call public
`SpecFile.fromJson`, `validateSpec`, `compileSpec`, descriptor projection and
`LinkedSpecRuntimeEngine`. No physical .spec input is required.

| Case | Validation / compiled identity | Runtime on a / b |
| --- | --- | --- |
| named head | accepted, index 1 / head | null / b |
| numeric 1 | accepted, index 1 / head | null / b |
| unindexed | accepted, index 0 / anonymous | a / null |
| named null, anonymous first | **incorrectly accepted, index 0 / anonymous** | a / null |
| named null, anonymous second | **incorrectly accepted, index 1 / anonymous** | a / null |
| named null, all declarations named | rejected, regex_slot_unknown_name | not executed |
| named numeric 0 | rejected, regex_slot_unknown_name | not executed |
| named empty string | rejected, regex_slot_unknown_name | not executed |
| numeric null provenance, index 1 | accepted, index 1 / head | null / b |
| unindexed text provenance, index 0 | accepted, index 0 / anonymous | a / null |

This establishes **two malformed named acceptances**, three valid selectors
and three rejecting-name controls. The final two accepted provenance shapes
are separately inventoried for compatibility review: no additional wrong-slot
claim or newly chosen normalization policy follows from them. Descriptor
`meta.resolved_slot_edges` preserves their supplied kind/authored value; the
two null-name failures expose named/null provenance with a null target slot ID.

The causal chain is specific. `EdgeTarget.fromJson` retains the untyped
authored-selector value. The named branch in
`dart/lib/src/validation/spec_validator.dart:771` calls
`_regexSlotIndex` without requiring a name. Its equality at line 825 accepts
`null == null` for an anonymous declaration. Compilation's
`_resolveAuthoredTarget` at `dart/lib/src/compiler/compiled_spec.dart:1711`
repeats the same nullable equality and propagates the resolved index into the
action edge at lines 1547-1566. Moving the anonymous declaration from index 0
to 1 moves the erroneous selection with it; it is not a default-index fallback.
With no anonymous declaration, both public validation and compilation reject
the same null name as `regex_slot_unknown_name / resolve_selector`.

`DART-STARTUP-READING.2.23.1` owns the named identity guard and a census of
selector-kind/authored-selector/index consistency, including deliberate
historical carrier defaults. `.2.23.2` owns supported carrier recurrence and
public closeout. Valid named/numeric/unindexed behavior, exact Unicode names,
authored order and existing slot-identity guards must remain intact.

This probe establishes a public SpecFile reconstruction path, not an authored
.spec syntax failure. No fresh generated/emitted, semantic-index, MCP or
other-backend exposure is claimed. All 35 selected validator/action/root/gap/
duplicate-slot tests pass, including their existing emitted and primary roles;
the neutral gap contract remains 9/0/63 plus public8/15/10/34 and duplicate
identity remains 7/0/59. Passing these existing suites does not cover the new
malformed cases. Repairs remain gated by startup .3/.4/.5.

Run from the repository root using the existing repository-local scratch directory:

```bash
cat > .linkedspec-data/scratch/dart135-selector.dart <<'DART135_SELECTOR'
import 'dart:convert';
import '../../dart/lib/linkedspec_dart.dart';
void main() {
 const first='Top::\n -> Child[head] { return(match_text()) }\n\nChild::\n /a/\n head=/b/\n';
 const second='Top::\n -> Child[head] { return(match_text()) }\n\nChild::\n head=/b/\n /a/\n';
 const allNamed='Top::\n -> Child[head] { return(match_text()) }\n\nChild::\n tail=/a/\n head=/b/\n';
 final cases=<String,Map<String,Object?>>{
  'named_head':{'source':first,'kind':'named','authored':'head','index':0},
  'numeric_one':{'source':first,'kind':'numeric','authored':1,'index':1},
  'unindexed':{'source':first,'kind':'unindexed','authored':null,'index':0},
  'named_null_first':{'source':first,'kind':'named','authored':null,'index':0},
  'named_null_second':{'source':second,'kind':'named','authored':null,'index':0},
  'named_null_all_named':{'source':allNamed,'kind':'named','authored':null,'index':0},
  'named_number':{'source':first,'kind':'named','authored':0,'index':0},
  'named_empty':{'source':first,'kind':'named','authored':'','index':0},
  'numeric_null':{'source':first,'kind':'numeric','authored':null,'index':1},
  'unindexed_text':{'source':first,'kind':'unindexed','authored':'head','index':0},
 };
 Map<String,Object?> error(Object e)=>{'type':e.runtimeType.toString(),'message':e.toString(),
  if(e is SpecValidationException)'diagnostic':e.diagnostic?.toJson()};
 final rows=<Map<String,Object?>>[];
 for(final entry in cases.entries){
  final config=entry.value;
  final json=jsonDecode(jsonEncode(parseSpec(config['source'] as String).toJson())) as Map<String,dynamic>;
  int changed=0;
  void visit(Object? value){
   if(value is Map){
    if(value.containsKey('selector_kind') && value['label']=='Child'){
     value['selector_kind']=config['kind'];value['authored_selector']=config['authored'];
     value['index']=config['index'];changed++;
    }else{for(final v in value.values){visit(v);}}
   }else if(value is List){for(final v in value){visit(v);}}
  }
  visit(json);
  if(changed!=1){throw StateError('Expected one selector, got $changed');}
  final row=<String,Object?>{'case':entry.key,'config':config,'reconstructed_json':json};
  try{
   final spec=SpecFile.fromJson(json);row['reconstructed']=true;
   try{validateSpec(spec);row['validated']=true;}
   catch(e){row['validation_error']=error(e);}
   try{
    final compiled=compileSpec(spec);
    row['compiled_index']=compiled.rulesByLabel['Top']!.actionEdges.single.childRegexIndex;
    row['resolved_slots']=(compiled.rulesByLabel['Top']!.toDescriptorRuleJson()['meta'] as Map)['resolved_slot_edges'];
    row['a']=LinkedSpecRuntimeEngine(compiled).parse('a').value;
    row['b']=LinkedSpecRuntimeEngine(compiled).parse('b').value;
   }catch(e){row['compile_or_runtime_error']=error(e);}
  }catch(e){row['reconstruction_error']=error(e);}
  rows.add(row);
 }
 print(jsonEncode(rows));
}
DART135_SELECTOR
bash tools/run_dart_project_data.sh run .linkedspec-data/scratch/dart135-selector.dart \
  > .linkedspec-data/scratch/dart135-selector.json \
  2> .linkedspec-data/scratch/dart135-selector.stderr
```

Then independently verify every result:

```bash
bash tools/project_data_run.sh python3 - <<'DART135_VERIFY'
from pathlib import Path
import json
rows=json.loads(Path('.linkedspec-data/scratch/dart135-selector.json').read_text())
assert Path('.linkedspec-data/scratch/dart135-selector.stderr').stat().st_size==0
expected={
 'named_head':(1,'head',None,'b'),
 'numeric_one':(1,'head',None,'b'),
 'unindexed':(0,None,'a',None),
 'named_null_first':(0,None,'a',None),
 'named_null_second':(1,None,'a',None),
 'numeric_null':(1,'head',None,'b'),
 'unindexed_text':(0,None,'a',None),
}
rejected={'named_null_all_named':None,'named_number':0,'named_empty':''}
assert len(rows)==10 and {r['case'] for r in rows}==set(expected)|set(rejected)
for row in rows:
 name=row['case'];config=row['config']
 assert row['reconstructed'] is True
 targets=[]
 def visit(value):
  if isinstance(value,dict):
   if 'selector_kind' in value and value.get('label')=='Child':targets.append(value)
   for v in value.values():visit(v)
  elif isinstance(value,list):
   for v in value:visit(v)
 visit(row['reconstructed_json'])
 assert targets==[{'label':'Child','index':config['index'],'selector_kind':config['kind'],'authored_selector':config['authored']}],name
 if name in rejected:
  assert 'validated' not in row and 'compiled_index' not in row
  for key in ['validation_error','compile_or_runtime_error']:
   err=row[key];diag=err['diagnostic']
   assert err['type']=='SpecValidationException'
   assert diag['code']=='regex_slot_unknown_name' and diag['stage']=='resolve_selector'
   assert diag['fields']=={'authored_selector':rejected[name],'line':2,'rule_label':'Top','source_id':'inline','target_rule':'Child'}
 else:
  index,slot,a,b=expected[name]
  assert row['validated'] is True and not any(k.endswith('_error') for k in row),name
  assert (row['compiled_index'],row['a'],row['b'])==(index,a,b),name
  assert row['resolved_slots']==[{'selector_kind':config['kind'],'authored_selector':config['authored'],'target_rule':'Child','regex_index':index,'target_slot_id':slot}],name
by={r['case']:r for r in rows}
assert by['named_null_first']['config']['source']==by['named_head']['config']['source']
assert '\n /a/\n head=/b/\n' in by['named_null_first']['config']['source']
assert '\n head=/b/\n /a/\n' in by['named_null_second']['config']['source']
assert '\n tail=/a/\n head=/b/\n' in by['named_null_all_named']['config']['source']
print('PASS ten reconstructed selector controls: two null-name wrong-slot acceptances, three valid selectors, three rejecting names, two accepted provenance census inputs')
DART135_VERIFY
```

Related: [[dart-frontend-validation]], [[dart-duplicate-regex-slot-identity-admission]],
[[inter-match-gap-executable-contract-plan]], [[dart-semantic-indexed-edge-correlation-gaps]].
