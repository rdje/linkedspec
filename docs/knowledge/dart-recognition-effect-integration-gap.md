---
id: dart-recognition-effect-integration-gap
title: Dart recognition effects are disconnected and forbidden writes survive rollback
answers:
  - why can a Dart recognized child write a binding before rollback
  - is the Dart recognition effect classifier connected to runtime execution
  - can Dart observation effects hide behind action or blind edges
  - which task owns Dart recognition effect integration
  - how can I reproduce Dart recognition binding write persistence
date: 2026-09-09
status: confirmed; gated repair owned by DART-STARTUP-READING.2.4
tags: [dart, recognition, observation, effects, rollback, defects, startup]
evidence: "DART-STARTUP-READING.1.7 completes compiler reading and runs eight controlled native/authority probes. Direct classifyEffects rejects binding_write. Ordinary recognition nevertheless accepts a child's set(seen, 1), and rollback leaves the value 1; pure rollback retains 0. The special compiler closure rejects call(Observer) but permits action/blind transitions that enter Observer's lifecycle. Existing 74 selected tests pass. No other-backend or reconstructed/generated/emitted result is claimed by these new probes."
reverify:
  - "Run DART_RECOGNITION_EFFECT_PROBE below from the repository root."
  - "rg -n 'classifyEffects' dart/lib dart/test/recognition_transaction_contract_test.dart"
  - "cd dart && bash ../tools/run_dart_project_data.sh test test/recognition_transaction_contract_test.dart test/recursive_observation_contract_test.dart"
---

# Disconnected effect enforcement

The private authority has the closed allowed/rejected effect vocabulary and a
working fixed-point classifier. At `dart/lib/src/runtime/recognition_transaction.dart:731`,
`classifyEffects` rejects an explicit `binding_write` graph. Searching
`dart/lib` finds its declaration only. The admitted consumer calls it directly
on neutral graph fixtures at `dart/test/recognition_transaction_contract_test.dart` at lines 668/672;
that proves the classifier itself, not integration with executable rules.

The compiler's additional observation policy scans `actionPayloads` at
`dart/lib/src/compiler/compiled_spec.dart:877-882` and closes effects through explicit rule/helper
calls at lines 939-981. It adds no structural action/blind targets. Its two
special flags cover observation writes and parser/staged dispatch; they do not
replace the neutral closed effect vocabulary.

At `dart/lib/src/runtime/interpreter.dart:3647-3657`, `ActionRecognizeOnceExpr` executes the child
before recording the attempt. Observation handling at 3663-3685 executes and
binds normally. Neither path calls the generic classifier. The checkpoint
state at 8009-8015 and its application at 8018-8029 contain cursor, anonymous
boundary and invocation marks; rollback at 8391-8410 restores that state.
Bindings are intentionally outside the permitted transaction snapshot.
The repair must enforce the rejected-effect contract before effects happen,
rather than silently broadening rollback into arbitrary binding snapshots.

| Probe | Current result |
| --- | --- |
| Ordinary `call(Observer)` inside Bridge | Compile rejects `binding_write` |
| Bridge action edge to Observer | Compiles, enters Observer I, returns `true` |
| Bridge blind edge to Observer | Compiles, enters Observer I, returns `false` |
| Pure action-edge control | Compiles and returns `true` |
| Child writes `seen=1` during recognition, then rollback | Returns `[true,1]` |
| Pure recognized child, then rollback | Returns `[true,0]` |
| Ordinary child call with the same write | Returns `[false,1]`; false is its payload |
| Authority receives an explicit binding-write graph | Rejects `recognition_effect_forbidden` |

Lifecycle records in the probe confirm the observer/child was entered; true
and false values alone are not used to infer dispatch. The write-after-rollback
case establishes a concrete forbidden effect and persistent state change.
It does not prove every other rejected family is reachable, nor does it establish
behavior on normalized/generated/emitted carriers or other backends.

`DART-STARTUP-READING.2.4.1` owns complete graph/contract reconciliation;
`.2.4.2` owns executable validation; `.2.4.3` owns carrier/public closeout.
All remain behind startup `.3/.4/.5`. The passing 74-test selection and historical
admission claims are qualified, not reclassified as proof of these missing paths.

Related: [[dart-recognition-transaction-dormant-red]],
[[dart-recursive-observation-admission]], [[dart-compiled-spec-state]],
[[recognition-transaction-neutral-contract]].

The script uses the native parser/compiler/result lifecycle evidence plus the
private authority's own classifier. All generated files stay under managed scratch.

```bash
bash tools/project_data_run.sh python3 - <<'DART_RECOGNITION_EFFECT_PROBE'
from pathlib import Path
Path('.linkedspec-data/scratch/dart17-effect-probe.dart').write_text("import 'dart:convert';\nimport '../../dart/lib/linkedspec_dart.dart';\nimport '../../dart/lib/src/runtime/recognition_transaction.dart';\nimport '../../dart/lib/src/runtime/source_location.dart';\n\nvoid main() {\n  for (final entry in <String, String>{\n    'ordinary_call': 'Bridge:\\n I { return(call(Observer)) }\\n',\n    'action_edge': 'Bridge:\\n -> Observer\\n',\n    'blind_edge': 'Bridge:AND\\n Observer\\n',\n    'pure_action_control': 'Bridge:\\n -> Observer\\n',\n  }.entries) {\n    final observer = entry.key == 'pure_action_control'\n        ? 'Observer:\\n /x/\\n I { return(false) }\\n'\n        : 'Observer:\\n /x/\\n I { value = observe_recognition(observation, call(Child)); return(value) }\\n';\n    final source = '''\nTop::\n I {\n  tx = recognition_checkpoint()\n  matched = recognize_once(tx, call(Bridge))\n  recognition_rollback(tx)\n  return(matched)\n }\n${entry.value}\n$observer\nChild:AND\n /x/\n''';\n    final row = <String, Object?>{'case': entry.key};\n    var phase = 'parse';\n    try {\n      final spec = parseSpecWithStagedUserFunctionDefinitions(source);\n      phase = 'compile';\n      final compiled = compileSpec(spec);\n      row['compiled'] = true;\n      final bridge = compiled.rule('Bridge')!;\n      row['bridge_action_edges'] = bridge.actionEdges.length;\n      row['bridge_blind_edges'] = bridge.blindEdges.length;\n      phase = 'engine';\n      final engine = LinkedSpecRuntimeEngine(compiled);\n      row['engine_created'] = true;\n      phase = 'execute';\n      final result = engine.execute('x');\n      row['value'] = result.value;\n      row['lifecycle_events'] = result.lifecycleEvents.map((event) => event.toJson()).toList();\n    } on Object catch (error) {\n      row['error_phase'] = phase;\n      row['error'] = error.toString();\n    }\n    print(jsonEncode(row));\n  }\n\n  for (final mode in ['write_rollback', 'pure_rollback', 'write_ordinary']) {\n    final childBody = mode == 'pure_rollback' ? 'return(false)' : 'set(seen, 1); return(false)';\n    final invoke = mode == 'write_ordinary' ? 'matched = call(Child)' : '''\n  tx = recognition_checkpoint()\n  matched = recognize_once(tx, call(Child))\n  recognition_rollback(tx)\n''';\n    final source = '''\nTop::\n I {\n  seen = 0\n  $invoke\n  return(array(matched, seen))\n }\nChild:AND\n /x/\n E { $childBody }\n''';\n    final row = <String, Object?>{'case': mode};\n    var phase = 'parse';\n    try {\n      final spec = parseSpecWithStagedUserFunctionDefinitions(source);\n      phase = 'compile';\n      final compiled = compileSpec(spec);\n      row['compiled'] = true;\n      phase = 'execute';\n      final result = LinkedSpecRuntimeEngine(compiled).execute('x');\n      row['value'] = result.value;\n      row['lifecycle_events'] = result.lifecycleEvents.map((event) => event.toJson()).toList();\n    } on Object catch (error) {\n      row['error_phase'] = phase;\n      row['error'] = error.toString();\n    }\n    print(jsonEncode(row));\n  }\n  final row = <String, Object?>{'case': 'authority_binding_write'};\n  try {\n    RecognitionTransactionAuthority(\n      sourceAuthority: SourceAuthority(sources: {'input': 'x'}),\n      sourceIdentity: 'input',\n    ).classifyEffects({\n      'entry': 'Child',\n      'rules': {\n        'Child': {'base': ['binding_write'], 'calls': <String>[]},\n      },\n    });\n    row['accepted'] = true;\n  } on Object catch (error) {\n    row['error'] = error.toString();\n  }\n  print(jsonEncode(row));\n}\n")
DART_RECOGNITION_EFFECT_PROBE
bash tools/run_dart_project_data.sh run .linkedspec-data/scratch/dart17-effect-probe.dart
```
