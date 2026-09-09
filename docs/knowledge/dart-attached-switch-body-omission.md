---
id: dart-attached-switch-body-omission
title: Dart attached switches can omit body statements and overwrite an earlier default
answers:
  - "can Dart attached switch silently discard a trailing statement"
  - "why does Dart switch lose unknown helper diagnostics after a case"
  - "does Dart reject duplicate default blocks"
  - "which task owns Dart attached switch body validation"
date: 2026-09-09
status: confirmed defect; repair pending under DART-STARTUP-READING.2.1
tags: [dart, actionir, switch, validation, diagnostics, startup, defect]
evidence: "DART-STARTUP-READING.1.3 reads the parser and resolver, then probes their public APIs and native/SpecFile-reconstructed execution. The full body retains two statements, but extracted cases/default omit trailing non-branches or replace the earlier default. Resolution and execution prefer the extracted branches. Five controlled cases reproduce the behavior; no other backend or emitted-carrier result is claimed."
reverify: "Replay the DART_SWITCH_PROBE recipe in this card from the repository root; compare its five JSON rows with the expected current results below."
---

# Attached-switch body omission

The parser keeps two representations: the complete typed body and an extracted
case list plus one default. In `dart/lib/src/action/action_parser.dart:564`,
`_parseSwitchBranches` stops when no following top-level brace is found, skips
unrecognized branch expressions, and assigns `defaultCase = expr` each time.
It does not require the extracted branches to cover the complete body.

At `dart/lib/src/action/action_contracts.dart:969`, the resolver visits the
extracted cases/default whenever either exists; the complete body is visited
only when neither exists. Consequently a trailing call can remain visible in
`body.statements` but disappear from contract diagnostics. This is separate
from intentional deferred callable-body handling.

Runtime statement selection at `dart/lib/src/runtime/interpreter.dart:1831`
and `_selectSwitchBody` at line 2667 use those extracted branches. Native and
SpecFile-JSON reconstruction therefore reproduce the omission. These are
bounded diagnostic source reads outside the .1.3 reading group, not whole-file
runtime reading credit. The selected 45 existing tests pass despite this gap.

The probe initializes `result = 0`, executes `switch(1)`, then returns result:

| Switch body | Resolver diagnostics | Native / reconstructed outcome |
| --- | --- | --- |
| `case(1) { result = 7 }` | none | 7 / 7 |
| `mystery_probe(1)` | `unknown_helper` | 0 / 0 |
| `case(1) { result = 7 }; mystery_probe(1)` | none | 7 / 7 |
| `default() { mystery_probe(1) }; default() { result = 9 }` | none | 9 / 9 |
| `default() { result = 9 }; default() { mystery_probe(1) }` | `unknown_helper` | both throw `unknown_helper` |

All five compile. Compilation acceptance alone is not proof of an empty
contract-diagnostic list: the second and fifth rows explicitly retain the
unknown-helper diagnostic. The issue is the lost authored content and its
inconsistent visibility, not a claim that every unknown helper must fail at
compile time. The semicolon is an existing statement separator in these API
probes. No valid-switch behavior change is proposed by this finding.

`DART-STARTUP-READING.2.1.1` will resolve complete body validation and duplicate
default diagnostics against the normative control contract and Perl reference.
`.2.1.2` owns implementation and supported-carrier proof after that resolution.
Both remain behind startup `.3/.4/.5`. No fix, emitted execution or cross-backend
conclusion is claimed here; the book's current limitation points to this owner.

## Reproduce the observed state

All generated inputs and logs stay under the repository's managed scratch tree.
This reproduces observations, not acceptance tests for the eventual repair.

```sh
bash tools/project_data_run.sh python3 - <<'DART_SWITCH_PROBE'
from pathlib import Path
scratch = Path('.linkedspec-data/scratch')
scratch.mkdir(parents=True, exist_ok=True)
(scratch / 'dart13-switch-runtime.dart').write_text("import 'dart:convert';\nimport '../../dart/lib/linkedspec_dart.dart';\nvoid main() {\n  for (final body in [\n    'case(1) { result = 7 }',\n    'mystery_probe(1)',\n    'case(1) { result = 7 }; mystery_probe(1)',\n    'default() { mystery_probe(1) }; default() { result = 9 }',\n    'default() { result = 9 }; default() { mystery_probe(1) }',\n  ]) {\n    final action = 'switch(1) { $body }';\n    final ast = parseActionExpression(action) as ActionControlSwitchExpr;\n    final resolution = resolveActionExpressionContracts(ast);\n    final source = 'Top::\\n E { result = 0\\n$action\\nreturn(result) }\\n';\n    final row = <String,Object?>{\n      'action': action,\n      'body_statements': ast.body!.statements.length,\n      'case_count': ast.cases.length,\n      'default_source': ast.defaultCase?.source,\n      'diagnostics': resolution.diagnostics.map((d) => d.code).toList(),\n    };\n    try {\n      final spec = parseSpec(source);\n      final compiled = compileSpec(spec);\n      row['compile'] = 'accepted';\n      try { row['native_value'] = LinkedSpecRuntimeEngine(compiled).parse('').value; }\n      catch(e) { row['native_error'] = e.toString(); }\n      try { row['reconstructed_value'] = LinkedSpecRuntimeEngine(compileSpec(SpecFile.fromJson(spec.toJson()))).parse('').value; }\n      catch(e) { row['reconstructed_error'] = e.toString(); }\n    } catch(e) { row['compile_error'] = e.toString(); }\n    print(jsonEncode(row));\n  }\n}\n")
DART_SWITCH_PROBE
(cd dart && bash ../tools/run_dart_project_data.sh run ../.linkedspec-data/scratch/dart13-switch-runtime.dart)
```

Related: [[dart-actionir-contract-resolver]], [[dart-actionir-ast-parser]],
[[dart-marker-switch-chain-selection]], [[dart-runtime-value-control-tree-helpers]].
