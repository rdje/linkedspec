---
id: dart-primary-cli-trace-overflow
title: Dart numeric trace overflow throws after trace-file reset
answers:
  - why can a large Dart CLI trace level throw StateError
  - does Dart validate trace integer range before resetting the file
  - which task owns Dart numeric trace overflow
  - how can I reproduce Dart trace reset before a configuration failure
date: 2026-09-09
status: confirmed; repair pending under DART-STARTUP-READING.2.3
tags: [dart, cli, trace, validation, defects, startup]
evidence: "DART-STARTUP-READING.1.6 reads primary_cli.dart completely and runs seven controlled adapter calls. Signed 64-bit endpoints, 0 and 100 succeed. The adjacent positive and negative overflows pass syntax validation but throw StateError after a selected trace file is reset. Invalid text returns usage 2 and preserves the sentinel. Existing selected AST/compiler/CLI/root tests pass 27/27; no whole process matrix or other-backend overflow proof is claimed."
reverify:
  - "Run the repository-managed DART_TRACE_LEVEL_PROBE recipe below."
  - "cd dart && bash ../tools/run_dart_project_data.sh test test/primary_cli_test.dart"
---

# Trace validation and reset ordering

The callable adapter `runLinkedSpecDartPrimaryCli` lives in
`dart/lib/src/cli/primary_cli.dart`; it is not exported by the package facade.
The reproduction imports that adapter directly, as its existing tests do.

`_validTraceLevel` accepts any decimal matching `^-?\d+$`, but
`_traceLevelNumber` subsequently uses `int.tryParse`. If conversion returns
null, it falls through the named-alias switch and throws `StateError`.
`_CanonicalTrace.create` resets the selected file before that conversion;
its `FileSystemException` catch covers the reset, not this host state error.
The adapter calls trace construction before its compilation/invocation handlers.
Source locations: validation at line 436, conversion at 453, construction at
482, reset at 495 and conversion call at 502; the adapter enters it at 140.

| Trace level | Observed adapter result | Trace file after reset request |
| --- | --- | --- |
| `0` | exit 0, result `"trace"` | empty |
| `100` | exit 0, result `"trace"` | low phase records |
| `9223372036854775807` | exit 0, result `"trace"` | records through debug threshold |
| `9223372036854775808` | `StateError`; no command-output object | empty |
| `-9223372036854775808` | exit 0, result `"trace"` | empty |
| `-9223372036854775809` | `StateError`; no command-output object | empty |
| `invalid` | usage exit 2 | original `sentinel\n` preserved |

This is a validation/order defect even before choosing portable overflow
semantics. ADR 0024 and the neutral CLI manifest own the shared numeric
contract; the repair must reconcile reference behavior and resolve bounded
rejection versus threshold normalization there. No new numeric contract is
invented by this finding. No process exit status, emitted carrier or
other-backend overflow behavior is inferred from these adapter calls.

`DART-STARTUP-READING.2.3` owns validation before file mutation, signed boundary
and invalid controls, API/process proof and any necessary shared follow-up.
Implementation remains gated by startup `.3/.4/.5`. Valid silent reset behavior
must remain intact. Historical shared-suite success is narrower than total
argument coverage; see [[dart-canonical-primary-cli-trace]].

The script resets only its own sentinel under the project-managed scratch
directory. Run from the repository root. Each output line is one JSON record;
the large integers remain exact strings in the `level` field.

```bash
bash tools/project_data_run.sh python3 - <<'DART_TRACE_LEVEL_PROBE'
from pathlib import Path
Path('.linkedspec-data/scratch/dart16-trace-level-probe.dart').write_text("import 'dart:convert';\nimport 'dart:io';\nimport '../../dart/lib/src/cli/primary_cli.dart';\n\nvoid main() {\n  const source = 'Top::\\n /x/ -> Done { return(\"trace\") }\\n\\nDone::\\n /x/\\n';\n  final file = File('.linkedspec-data/scratch/dart16-trace-level-reset.log');\n  for (final level in ['0', '100', '9223372036854775807', '9223372036854775808',\n      '-9223372036854775808', '-9223372036854775809', 'invalid']) {\n    file.writeAsStringSync('sentinel\\n');\n    final row = <String, Object?>{'level': level, 'parsed_int': int.tryParse(level)};\n    try {\n      final output = runLinkedSpecDartPrimaryCli([\n        '--inline-spec', source, '--input', 'x', '--trace', level,\n        '--trace-file', file.path, '--trace-reset',\n      ]);\n      row.addAll({'exit': output.exitCode, 'stdout': utf8.decode(output.stdoutBytes),\n        'stderr': utf8.decode(output.stderrBytes)});\n    } on Object catch (error) {\n      row.addAll({'exception_type': error.runtimeType.toString(), 'exception': error.toString()});\n    }\n    row['file_after'] = file.readAsStringSync();\n    print(jsonEncode(row));\n  }\n}\n")
DART_TRACE_LEVEL_PROBE
bash tools/run_dart_project_data.sh run .linkedspec-data/scratch/dart16-trace-level-probe.dart
```
