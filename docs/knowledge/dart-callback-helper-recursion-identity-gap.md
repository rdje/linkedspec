---
id: dart-callback-helper-recursion-identity-gap
title: Dart uses helper names as callback recursion identities
answers:
  - why does nested Dart with report codeblock recursion
  - can Dart nest distinct map_leaves callbacks
  - does Dart preserve bound callback identity through with
  - which task owns Dart helper callback recursion identity
date: 2026-09-09
status: confirmed-open
tags: [dart, runtime, callable, codeblock, recursion, callback, startup, defect]
evidence: "DART-STARTUP-READING.1.18; nine native/SpecFile-JSON controls; interpreter.dart helper/receiver with calls at 2932/2977, tree callback name at 3027-3028, leaf calls at 3240/3376, active-name lookup at 4881 and insertion at 4907; gated repair .2.10."
reverify: "Run DART_CALLBACK_IDENTITY, the managed Dart invocation and DART_CALLBACK_IDENTITY_VERIFY below; assertions describe pre-repair output."
---

# Callback identity through helpers

Distinct nested callbacks are separate invocations. The helper name with or
map_leaves is not the identity of each callback passed to that helper. Dart
nevertheless uses that name as the active-codeblock recursion key. Valid nested
callbacks reject as if they were recursive calls to the same bound codeblock.

A real bound callback passed through with also loses its binding identity:
cb calling with(v, cb) eventually reports with -> with instead of cb -> cb.
The probe establishes wrong diagnostic identity, not an unbounded recursion
escape or a fresh execution-count claim.

Nine exact source controls use Top:: with /x/ and an E block, parsed and compiled
normally, then executed on input x. Both native and SpecFile-JSON routes agree:

| Case | Current outcome |
| --- | --- |
| Single with callback | "a", matched=true, cursor=1 |
| Nested helper with callbacks | rejects cycle [with,with] |
| Nested receiver with callbacks | rejects cycle [with,with] |
| Helper with containing receiver with | rejects cycle [with,with] |
| Sequential with callbacks | ["a","b"], matched=true, cursor=1 |
| map_leaves callback containing another map_leaves callback | rejects cycle [map_leaves,map_leaves] |
| map_leaves callback containing reduce_leaves | [1], matched=true, cursor=1 |
| Direct bound cb recursion | rejects cycle [cb,cb], as intended |
| Bound cb recursion through with(v, cb) | rejects cycle [with,with], losing cb identity |

All rejections carry codeblock_recursion_unsupported at callable_codeblock_invocation.
The full message, callable_name, cycle and handler_source_label are checked below;
no compilation rejection is substituted for a runtime result. The single/sequential/
different-helper controls distinguish nested helper-name collision from general
callback invocation failure.

## Mechanism and repair boundary

In dart/lib/src/runtime/interpreter.dart, _executeCodeblockValue takes a name,
checks activeCodeblocks.indexOf(name) at 4881 and pushes that name at 4907.
Direct bound dispatch supplies call.name at 4778. Helper/receiver with at
2932/2977 supply with. Tree callbacks store the method at 3027-3028 and pass it
through the leaf executors at 3240/3376. Callback expressions resolve before
scoped values are installed, but their identity is not retained across that seam.

DART-STARTUP-READING.2.10 owns distinct anonymous callback nesting, retained
bound callback identity, exact real-cycle rejection, scope restoration and
native/reconstructed/generated/emitted proof after startup .3/.4/.5. The
separate map_leaves! binding-identity mutation guard must remain intact.

The existing [[lua-callable-codeblock-emitted-route-identity]] record describes
the appropriate distinction for Lua. It is dated comparison evidence; this
reading slice does not freshly execute Lua or claim any other backend result.
All 140 selected Dart interpreter/callable/variadic/mutation/observation/source/
logical/diagnostic tests pass, including their existing emitted/CLI consumers.
Those passes do not establish the new nested-callback boundary.

## Reproduce

All generated inputs and logs use managed repository-local storage.

```sh
bash tools/project_data_run.sh python3 - <<'DART_CALLBACK_IDENTITY'
from pathlib import Path
Path('.linkedspec-data/scratch/dart118-callback-probe.dart').write_text("import 'dart:convert';\nimport '../../dart/lib/linkedspec_dart.dart';\n\nvoid main() {\n  final bodies = <String, String>{\n    'single_with': 'return(with(\"a\") { return(value) })',\n    'nested_helper_with': 'return(with(\"outer\") { return(with(\"inner\") { return(value) }) })',\n    'nested_receiver_with': 'return(\"outer\".with() { return(\"inner\".with() { return(value) }) })',\n    'nested_mixed_with': 'return(with(\"outer\") { return(\"inner\".with() { return(value) }) })',\n    'sequential_with': 'return([with(\"a\") { return(value) }, with(\"b\") { return(value) }])',\n    'nested_tree_map': 'return([1].map_leaves() { return([value].map_leaves() { return(value) }) })',\n    'mixed_tree_map_reduce': 'return([1].map_leaves() { return([value].reduce_leaves(0) { return(num_add(acc, value)) }) })',\n    'direct_bound_recursion': 'cb = {|v| return(cb(v)) }; return(cb(\"x\"))',\n    'helper_bound_recursion': 'cb = {|v| return(with(v, cb)) }; return(cb(\"x\"))',\n  };\n  for (final entry in bodies.entries) {\n    final source = 'Top::\\n /x/\\n E { ${entry.value} }\\n';\n    final row = <String, Object?>{'case': entry.key, 'body': entry.value};\n    try {\n      final spec = parseSpec(source);\n      for (final carrier in ['native', 'spec_json']) {\n        final compiled = compileSpec(carrier == 'native' ? spec : SpecFile.fromJson(spec.toJson()));\n        try {\n          final result = LinkedSpecRuntimeEngine(compiled).parse('x');\n          row[carrier] = {'value': result.value, 'matched': result.matched, 'cursor': result.cursorCodeUnit};\n        } on RuntimeInterpreterException catch (error) {\n          row[carrier] = {'message': error.message, 'diagnostic': error.diagnostic?.toJson()};\n        }\n      }\n    } catch (error) { row['unexpected_error'] = error.toString(); }\n    print(jsonEncode(row));\n  }\n}\n")
DART_CALLBACK_IDENTITY
bash tools/run_dart_project_data.sh run .linkedspec-data/scratch/dart118-callback-probe.dart > .linkedspec-data/scratch/dart118-callback-probe.log 2>&1
bash tools/project_data_run.sh python3 - <<'DART_CALLBACK_IDENTITY_VERIFY'
from pathlib import Path
import json
rows=[json.loads(line) for line in Path('.linkedspec-data/scratch/dart118-callback-probe.log').read_text().splitlines()]
bodies={
'single_with':'return(with("a") { return(value) })',
'nested_helper_with':'return(with("outer") { return(with("inner") { return(value) }) })',
'nested_receiver_with':'return("outer".with() { return("inner".with() { return(value) }) })',
'nested_mixed_with':'return(with("outer") { return("inner".with() { return(value) }) })',
'sequential_with':'return([with("a") { return(value) }, with("b") { return(value) }])',
'nested_tree_map':'return([1].map_leaves() { return([value].map_leaves() { return(value) }) })',
'mixed_tree_map_reduce':'return([1].map_leaves() { return([value].reduce_leaves(0) { return(num_add(acc, value)) }) })',
'direct_bound_recursion':'cb = {|v| return(cb(v)) }; return(cb("x"))',
'helper_bound_recursion':'cb = {|v| return(with(v, cb)) }; return(cb("x"))',
}
success={'single_with':'a','sequential_with':['a','b'],'mixed_tree_map_reduce':[1]}
names={'nested_helper_with':'with','nested_receiver_with':'with','nested_mixed_with':'with','nested_tree_map':'map_leaves','direct_bound_recursion':'cb','helper_bound_recursion':'with'}
assert len(rows)==9
for row,(case,body) in zip(rows,bodies.items()):
    if case in success:
        result={'value':success[case],'matched':True,'cursor':1}
    else:
        name=names[case]
        message=f'codeblock_recursion_unsupported callable_name="{name}" cycle=[{name}, {name}] rule_label="Top"'
        result={'message':message,'diagnostic':{
            'type':'runtime_parser','stage':'callable_codeblock_invocation','owner_stage':'dart_runtime',
            'summary':'Dart callable codeblock invocation failed','detail':message,
            'code':'codeblock_recursion_unsupported','callable_name':name,'cycle':[name,name],
            'top_rule':'Top','rule_label':'Top','handler_source_label':'dart_runtime:codeblock:'+name}}
    assert row=={'case':case,'body':body,'native':result,'spec_json':result},row
print('PASS nine exact native/SpecFile-JSON callback controls; four false cycles and helper-mediated identity loss remain open')
DART_CALLBACK_IDENTITY_VERIFY
```

Related: [[dart-callable-codeblock-dynamic-invocation]],
[[dart-runtime-value-control-tree-helpers]], [[callable-codeblock-literal-contract]],
[[map-leaves-mutation-dart-runtime]].
