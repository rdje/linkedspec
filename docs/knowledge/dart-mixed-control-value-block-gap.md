---
id: dart-mixed-control-value-block-gap
title: Dart marker-selected value ranges lose attached-control return locality and else selection
answers:
  - does Dart keep mixed marker and attached control returns block local
  - why does a Dart attached else inside a marker value branch get skipped
  - which task owns Dart mixed control value block execution
  - do reconstructed Dart specs preserve the mixed control return defect
date: 2026-09-09
status: confirmed-open
tags: [dart, runtime, controls, value-block, return, startup, defect]
evidence: "DART-STARTUP-READING.1.17; ten typed-AST/contract/native/SpecFile-JSON controls; interpreter.dart _executeValueStatementRange at 2337, generic expression fallback at 2397, action-control adapter at 2732 and structured-control dispatch at 3572; gated repair .2.9."
reverify: "Run DART_MIXED_CONTROLS, the managed Dart invocation and DART_MIXED_CONTROLS_VERIFY below; assertions describe pre-repair output."
---

# Mixed control value-block execution

An expression-valued block must keep its return local and allow the surrounding
rule to continue. In Dart, a marker-selected value range handles nested marker
if/switch and immediate return calls explicitly, but sends an attached control
through the general expression evaluator. That evaluator enters the action
statement path, which raises the surrounding action's return signal.

The typed AST retains the attached control and its return body. For an attached
if/else, the adapter constructs a one-statement list, so the sibling else is
unavailable to branch selection; the later else expression simply yields null.
This is execution drift, separate from the attached-switch body extraction defect
owned by .2.1. The same defect reproduces after SpecFile JSON reconstruction.

All controls compile and have empty action-contract diagnostic lists. They use:

~~~text
Top::
 /x/
 E {
   result = { BODY };
   return(array("continued", result))
 }
~~~

Input is x. Native and reconstructed outcomes agree in all ten cases, with
matched=true and cursorCodeUnit=1:

| BODY structure | Current value |
| --- | --- |
| Direct return("local") | ["continued","local"] |
| Marker if with direct return | ["continued","local"] |
| Marker if with attached true if returning local | "local" — surrounding rule exits |
| Marker if with attached false if / else returning local | ["continued","tail"] — else skipped |
| Marker if with attached while returning local | "local" — surrounding rule exits |
| Marker if with attached switch case returning local | "local" — surrounding rule exits |
| Marker switch case with direct return | ["continued","local"] |
| Marker switch case with attached true if returning local | "local" — surrounding rule exits |
| Attached if with attached false if / else returning local | ["continued","local"] |
| Marker if with nested marker false if / else returning local | ["continued","local"] |

Every BODY ends with "tail" after its control, so premature exits and lost
selection are distinguishable from correct local return. Typed serialized AST
kind counts in the replay preserve evidence that the bodies and else exist;
counts traverse all serialized representations, not unique source nodes.

## Root cause and ownership

- In dart/lib/src/runtime/interpreter.dart, _executeValueStatementRange at 2337
  has marker handling and immediate local-return interception, then calls
  _evaluateExpression at 2397 with statementContext=true for other expressions.
- Structured controls reach _evaluateStructuredControlExpression at 2732
  through the expression cases at 3572. The if adapter passes only its current
  statement to _executeAttachedIfChainStatement; while/switch use the attached
  action executors directly.
- The action if executor at 1852 calls _executeActionBlock and turns a returned
  result into _ActionReturn at 1906. Attached while/switch likewise use the
  action return path. This is appropriate in an action, but not in the selected
  range of an expression-valued block.
- The value-aware alternatives _executeValueIfChainStatement (2210),
  _executeValueWhileStatement (2613) and _executeValueSwitchStatement (2648)
  preserve _ValueBlockFlow when reached from the full value-block dispatcher.

Pending DART-STARTUP-READING.2.9 owns one value-aware dispatch authority, mixed
nesting/branch coverage, local-versus-rule return separation and supported
carrier proof after startup .3/.4/.5. The 124 selected interpreter/ActionIR/
callable/binding/write/mutation tests pass, including their existing emitted
and CLI consumers, but do not establish the new mixed-control boundary.
No fresh generated, emitted or other-backend outcome is claimed for this probe.

## Reproduce

All inputs, logs and managed runtime data stay on the repository volume.

```sh
bash tools/project_data_run.sh python3 - <<'DART_MIXED_CONTROLS'
from pathlib import Path
Path('.linkedspec-data/scratch/dart117-control-probe.dart').write_text("import 'dart:convert';\nimport '../../dart/lib/linkedspec_dart.dart';\n\nvoid main() {\n  final bodies = <String, String>{\n    'direct_return': 'return(\"local\"); \"tail\"',\n    'marker_if_return': 'if(true); return(\"local\"); endif(); \"tail\"',\n    'marker_if_attached_if': 'if(true); if(true) { return(\"local\") }; endif(); \"tail\"',\n    'marker_if_attached_else': 'if(true); if(false) { return(\"bad\") } else { return(\"local\") }; endif(); \"tail\"',\n    'marker_if_attached_while': 'if(true); while(true) { return(\"local\") }; endif(); \"tail\"',\n    'marker_if_attached_switch': 'if(true); switch(1) { case(1) { return(\"local\") } }; endif(); \"tail\"',\n    'marker_switch_return': 'switch(1); case(1); return(\"local\"); endcase(); endswitch(); \"tail\"',\n    'marker_switch_attached_if': 'switch(1); case(1); if(true) { return(\"local\") }; endcase(); endswitch(); \"tail\"',\n    'attached_if_attached_else': 'if(true) { if(false) { return(\"bad\") } else { return(\"local\") } }; \"tail\"',\n    'marker_if_nested_marker': 'if(true); if(false); return(\"bad\"); else(); return(\"local\"); endif(); endif(); \"tail\"',\n  };\n  for (final entry in bodies.entries) {\n    final action = 'result = { ${entry.value} }';\n    final ast = parseActionExpression(action);\n    final kinds = <String, int>{};\n    void visit(Object? value) {\n      if (value is Map) {\n        final kind = value['kind'];\n        if (kind is String) kinds.update(kind, (n) => n + 1, ifAbsent: () => 1);\n        for (final child in value.values) { visit(child); }\n      } else if (value is List) {\n        for (final child in value) { visit(child); }\n      }\n    }\n    visit(ast.toJson());\n    final row = <String, Object?>{\n      'case': entry.key,\n      'action': action,\n      'ast_kinds': kinds,\n      'diagnostics': resolveActionExpressionContracts(ast).diagnostics.map((d) => d.code).toList(),\n    };\n    final source = 'Top::\\n /x/\\n E { $action; return(array(\"continued\", result)) }\\n';\n    try {\n      final spec = parseSpec(source);\n      for (final carrier in ['native', 'spec_json']) {\n        final compiled = compileSpec(carrier == 'native' ? spec : SpecFile.fromJson(spec.toJson()));\n        final result = LinkedSpecRuntimeEngine(compiled).parse('x');\n        row[carrier] = {'value': result.value, 'matched': result.matched, 'cursor': result.cursorCodeUnit};\n      }\n    } catch (e) { row['error'] = e.toString(); }\n    print(jsonEncode(row));\n  }\n}\n")
DART_MIXED_CONTROLS
bash tools/run_dart_project_data.sh run .linkedspec-data/scratch/dart117-control-probe.dart > .linkedspec-data/scratch/dart117-control-probe.log 2>&1
bash tools/project_data_run.sh python3 - <<'DART_MIXED_CONTROLS_VERIFY'
from pathlib import Path
import json
rows=[json.loads(line) for line in Path('.linkedspec-data/scratch/dart117-control-probe.log').read_text().splitlines()]
cases=['direct_return','marker_if_return','marker_if_attached_if','marker_if_attached_else','marker_if_attached_while','marker_if_attached_switch','marker_switch_return','marker_switch_attached_if','attached_if_attached_else','marker_if_nested_marker']
bodies=[
'return("local"); "tail"',
'if(true); return("local"); endif(); "tail"',
'if(true); if(true) { return("local") }; endif(); "tail"',
'if(true); if(false) { return("bad") } else { return("local") }; endif(); "tail"',
'if(true); while(true) { return("local") }; endif(); "tail"',
'if(true); switch(1) { case(1) { return("local") } }; endif(); "tail"',
'switch(1); case(1); return("local"); endcase(); endswitch(); "tail"',
'switch(1); case(1); if(true) { return("local") }; endcase(); endswitch(); "tail"',
'if(true) { if(false) { return("bad") } else { return("local") } }; "tail"',
'if(true); if(false); return("bad"); else(); return("local"); endif(); endif(); "tail"',
]
normal=['continued','local']
values=[normal,normal,'local',['continued','tail'],'local','local',normal,'local',normal,normal]
kinds=[
{'assign_scalar':1,'block_value':1,'action_block':1,'action_stmt':2,'call':1,'string':2},
{'assign_scalar':1,'block_value':1,'action_block':1,'action_stmt':4,'control_if':1,'boolean':2,'call':1,'string':2,'control_endif':1},
{'assign_scalar':1,'block_value':1,'action_block':2,'action_stmt':5,'control_if':2,'boolean':4,'call':1,'string':2,'control_endif':1},
{'assign_scalar':1,'block_value':1,'action_block':3,'action_stmt':7,'control_if':2,'boolean':4,'call':2,'string':3,'control_else':1,'control_endif':1},
{'assign_scalar':1,'block_value':1,'action_block':2,'action_stmt':5,'control_if':1,'boolean':4,'control_while':1,'call':1,'string':2,'control_endif':1},
{'assign_scalar':1,'block_value':1,'action_block':4,'action_stmt':7,'control_if':1,'boolean':2,'control_switch':1,'number':6,'control_case':2,'call':2,'string':3,'control_endif':1},
{'assign_scalar':1,'block_value':1,'action_block':1,'action_stmt':6,'control_switch':1,'number':4,'control_case':1,'call':1,'string':2,'control_endcase':1,'control_endswitch':1},
{'assign_scalar':1,'block_value':1,'action_block':2,'action_stmt':7,'control_switch':1,'number':4,'control_case':1,'control_if':1,'boolean':2,'call':1,'string':2,'control_endcase':1,'control_endswitch':1},
{'assign_scalar':1,'block_value':1,'action_block':4,'action_stmt':6,'control_if':2,'boolean':4,'call':2,'string':3,'control_else':1},
{'assign_scalar':1,'block_value':1,'action_block':1,'action_stmt':8,'control_if':2,'boolean':4,'call':2,'string':3,'control_else':1,'control_endif':2},
]
assert len(rows)==len(cases)==len(bodies)==len(values)==len(kinds)==10
for row,name,body,value,counts in zip(rows,cases,bodies,values,kinds):
    result={'value':value,'matched':True,'cursor':1}
    expected={'case':name,'action':'result = { '+body+' }','ast_kinds':counts,'diagnostics':[],'native':result,'spec_json':result}
    assert row==expected,(name,row,expected)
print('PASS ten exact typed-AST/contract/native/SpecFile-JSON controls; four escaping returns and one skipped else remain open')
DART_MIXED_CONTROLS_VERIFY
```

Related: [[dart-runtime-value-control-tree-helpers]],
[[dart-marker-switch-chain-selection]], [[terse-expression-valued-block-early-return]],
[[dart-attached-switch-body-omission]].
