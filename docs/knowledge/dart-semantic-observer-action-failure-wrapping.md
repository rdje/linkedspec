---
id: dart-semantic-observer-action-failure-wrapping
title: Dart action child calls replace semantic observer errors and stacks
answers:
  - "does Dart preserve semantic observer failures inside action child calls"
  - "why does a Dart semantic callback expose RuntimeSemanticObservationSinkFailure"
  - "which task owns Dart semantic observer error identity loss"
  - "do direct and blind Dart semantic observer failures preserve original stacks"
date: 2026-09-09
status: confirmed-open
tags: [dart, semantic-introspection, observation, callback, errors, DART-STARTUP-READING]
evidence: "DART-STARTUP-READING.1.16; six public native parse controls; interpreter.dart _emitSemanticObservation at 1542, _executeActionBlock at 1751 with generic translation at 1779-1782, outer passthrough at 485; gated repair .2.8."
reverify: "Run DART_OBSERVER_ACTION, the managed Dart invocation and DART_OBSERVER_ACTION_VERIFY below; assertions describe pre-repair output."
---

# Action-block wrapping interrupts observer passthrough

The current callback contract in [[dart-semantic-runtime-observation-authority-map]]
requires the exact original caller error object and stack after trace scopes close.
Six public native engine controls compile ordinary source, install a typed semantic
observer and throw a sentinel object with a separately retained StackTrace.

| Route / failure event | Same error and stack? | Result |
| --- | --- | --- |
| Direct rule / selected regex slot | Yes / Yes | Original StateError |
| Direct rule / final result | Yes / Yes | Original StateError |
| Blind-dispatched child / selected slot | Yes / Yes | Original StateError |
| Explicit call(Child) inside Top lifecycle I / child selected slot | No / No | RuntimeInterpreterException naming the private wrapper |
| Same explicit call / final Top result | Yes / Yes | Original StateError |
| Same explicit call / observer records without throwing | No failure | matched true, value ok, child slot then final Top event |

The failing source uses `I { return(call(Child)) }`. Its callback sees the same
child slot event as the blind control, but the failure unwinds through the enclosing
action block. _emitSemanticObservation wraps the caller error and stack privately.
_executeActionBlock explicitly rethrows the diagnostic-output failure wrapper, returns,
next, exits and runtime exceptions, but has no semantic-observer wrapper arm. Its broad
catch translates that wrapper into a new runtime exception, so outer _parse cannot
recognize and unwrap it. The resulting diagnostic exposes only the wrapper type string,
losing the original error and stack.

This is distinct from a failure at final Top result, emitted after action execution;
that control reaches the correct outer passthrough. Existing semantic route tests and
the selected 100-test interpreter/recognition/gap/slot/observation suite pass, including
emitted consumers, but do not cover this callback-inside-action composition.

`DART-STARTUP-READING.2.8` owns passthrough repair, nested action/function/control-route
inventory, native/reconstructed/generated/emitted positive and failure controls, original
object/stack identity, trace closure and public evidence. Startup .3/.4/.5 remain required
before implementation. These six probes are direct public native execution; no fresh
generated/emitted or other-backend reproduction of this defect is claimed.

## Exact reproduction

```sh
bash tools/project_data_run.sh python3 - <<'DART_OBSERVER_ACTION'
from pathlib import Path
Path('.linkedspec-data/scratch/dart116-observer-probe.dart').write_text(r'''import 'dart:convert';
import '../../dart/lib/linkedspec_dart.dart';

const direct = 'Top::\n /x/\n E { return("ok") }\n';
const child = 'Child:\n /x/\n E { return("ok") }\n';
const blind = 'Top::\n => Child\n E { return("ok") }\n' + child;
const called = 'Top::\n I { return(call(Child)) }\n' + child;

void run(String name, String source, String? failKind) {
  final sentinel = StateError('observer-sentinel');
  final originalStack = StackTrace.fromString('observer-sentinel-stack');
  final events = <Object?>[];
  final out = <String, Object?>{'case': name};
  final compiled = compileSpec(parseSpec(source));
  try {
    final result = LinkedSpecRuntimeEngine(compiled).parse('x',
      semanticObservationSink: (event) {
        final row = event.toJson();
        events.add(row);
        if (row['event_kind'] == failKind) {
          Error.throwWithStackTrace(sentinel, originalStack);
        }
      });
    out['accepted'] = true;
    out['value'] = result.value;
    out['matched'] = result.matched;
  } catch (error, stack) {
    out['accepted'] = false;
    out['same_error'] = identical(error, sentinel);
    out['same_stack'] = identical(stack, originalStack);
    out['error_type'] = error.runtimeType.toString();
    out['message'] = error.toString();
    if (error is RuntimeInterpreterException) out['diagnostic'] = error.diagnostic?.toJson();
  }
  out['events'] = events;
  print(jsonEncode(out));
}

void main() {
  run('direct_slot_failure', direct, 'regex_slot_selected');
  run('direct_final_failure', direct, 'rule_result');
  run('blind_child_slot_failure', blind, 'regex_slot_selected');
  run('called_child_slot_failure', called, 'regex_slot_selected');
  run('called_child_final_failure', called, 'rule_result');
  run('called_child_success', called, null);
}
''')
DART_OBSERVER_ACTION
bash tools/run_dart_project_data.sh run .linkedspec-data/scratch/dart116-observer-probe.dart > .linkedspec-data/scratch/dart116-observer-probe.log 2>&1
bash tools/project_data_run.sh python3 - <<'DART_OBSERVER_ACTION_VERIFY'
from pathlib import Path
import json, hashlib
rows=[json.loads(s) for s in Path('.linkedspec-data/scratch/dart116-observer-probe.log').read_text().splitlines()]
names=['direct_slot_failure','direct_final_failure','blind_child_slot_failure',
'called_child_slot_failure','called_child_final_failure','called_child_success']
assert [r['case'] for r in rows]==names
def slot(label):
    return dict(contract_id='linkedspec-semantic-execution-observation-v1',
    event_kind='regex_slot_selected',rule_label=label,target_rule=label,regex_index=0,
    position=1,input_identity=None,status=None)
final=dict(contract_id='linkedspec-semantic-execution-observation-v1',event_kind='rule_result',
rule_label='Top',target_rule=None,regex_index=None,position=1,
input_identity='input:sha256:'+hashlib.sha256(b'x').hexdigest(),status='succeeded')
expected=[]
for i,name in enumerate(names):
    events=[slot('Top' if i<2 else 'Child')]
    if i in [1,4,5]: events.append(final)
    row=dict(case=name,events=events)
    if i==5:
        row.update(accepted=True,value='ok',matched=True)
    elif i==3:
        detail="action block failed in rule Top: Instance of '_RuntimeSemanticObservationSinkFailure'"
        row.update(accepted=False,same_error=False,same_stack=False,
        error_type='RuntimeInterpreterException',message='RuntimeInterpreterException: '+detail,
        diagnostic=dict(type='runtime_parser',stage='runtime_execution',owner_stage='dart_runtime',
        summary='Dart runtime interpreter failed',detail=detail,top_rule='Top',rule_label='Top',
        handler_source_label='dart_runtime:rule:Top'))
    else:
        row.update(accepted=False,same_error=True,same_stack=True,
        error_type='StateError',message='Bad state: observer-sentinel')
    expected.append(row)
assert rows==expected,(rows,expected)
print('PASS six exact pre-repair native semantic-observer controls; action child-call identity loss remains open')
DART_OBSERVER_ACTION_VERIFY
```
