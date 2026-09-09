---
id: dart-slice-end-overflow
title: Dart array slice and substr overflow before clipping a large end
answers:
  - can a large Dart slice length throw a RangeError
  - why does Dart substr compute a negative end for a positive length
  - does Dart clip slice length before adding the start
  - which task owns Dart array and string slice overflow repair
date: 2026-09-09
status: confirmed-open
tags: [dart, array, string, slice, bounds, overflow, startup, defect]
evidence: "DART-STARTUP-READING.1.20; six Dart native/SpecFile-JSON and Perl facade/source controls; interpreter.dart _callSlice adds start+length at 7067 and _charSubstring repeats it at 7897; gated .2.14.1/.2.14.2 alongside Rust startup .60 and Dart numeric .2.12."
reverify: "Run DART_SLICE_END and DART_SLICE_END_VERIFY below; assertions pin pre-repair values and exact wrapped errors."
---

# End addition before clipping

Both array slice and string substr accept a large positive length at offset zero.
Moving the start to one makes start+length overflow the host integer before the end
is clipped to the actual three-element length.

| Expression | Dart native and reconstructed | Perl Get |
| --- | --- | --- |
| slice([1,2,3],1,2) | [2,3] | [2,3] |
| slice([1,2,3],0,9223372036854775807) | [1,2,3] | [1,2,3] |
| slice([1,2,3],1,9223372036854775807) | wrapped RangeError | [2,3] |
| substr("abc",1,2) | "bc" | "bc" |
| substr("abc",0,9223372036854775807) | "abc" | "abc" |
| substr("abc",1,9223372036854775807) | wrapped RangeError | "bc" |

All six sources use a zero-regex Top action edge to Done: /x/ on input x and compile
with empty helper diagnostics. The four successful controls have matched=true/cursor=1.
The two failing controls throw RuntimeInterpreterException with this exact text:

```text
RuntimeInterpreterException: action block failed in rule Top: RangeError (end): Invalid value: Not in inclusive range 1..3: -9223372036854775808
```

Perl returns normally with no context last_error. Its exact lowering is also checked
inside Get's generated source. That inspected source is not a separate emitted execution.

## Mechanism and repair ownership

In dart/lib/src/runtime/interpreter.dart, _callSlice at 7054 guards start against the
array length, then computes math.min(items.length, start + length) at 7067.
_charSubstring at 7890 similarly converts to runes, guards start, then adds before
math.min at 7897. A nonnegative width therefore produces a negative end passed to sublist.
The action wrapper translates the host RangeError into the runtime exception above.

DART-STARTUP-READING.2.14.1 owns safe clipping and direct/receiver/actual mutation-consumer
proof; .2.14.2 owns carrier/public closeout after startup .3/.4/.5. Preserve the remaining
suffix without overflowing intermediate arithmetic. Empty/exact/beyond-end, omitted/zero
widths, scalar Unicode and adjacent integer bounds belong in permanent tests.

[[rust-array-slice-boundary-panics]] retains Rust startup .60, whose public small-range
panics are separate. [[dart-large-number-helper-corruption]] owns numeric conversion and
arithmetic under .2.12; this leaf owns slice-end calculation. Invalid/negative helper-count
policy remains under FUTURE-PARITY-BACKLOG.5 rather than being silently changed here.

The 111 selected Dart tests pass, including existing emitted/CLI consumers. These six
new controls prove native and SpecFile-JSON Dart plus Perl Get/source behavior only.
They do not establish fresh Dart emitted execution, process exit behavior, typed-source
slice failure or other backend output.

## Exact replay

```bash
bash tools/project_data_run.sh python3 - <<'DART_SLICE_END'
from pathlib import Path
Path(".linkedspec-data/scratch/dart120-slice-cases.json").write_text("[[\"array_small\",\"slice([1, 2, 3], 1, 2)\"],[\"array_large_safe\",\"slice([1, 2, 3], 0, 9223372036854775807)\"],[\"array_large_overflow\",\"slice([1, 2, 3], 1, 9223372036854775807)\"],[\"string_small\",\"substr(\\\"abc\\\", 1, 2)\"],[\"string_large_safe\",\"substr(\\\"abc\\\", 0, 9223372036854775807)\"],[\"string_large_overflow\",\"substr(\\\"abc\\\", 1, 9223372036854775807)\"]]\n")
Path(".linkedspec-data/scratch/dart120-slice-probe.dart").write_text("import 'dart:convert';\nimport 'dart:io';\nimport '../../dart/lib/linkedspec_dart.dart';\nvoid main() {\n  final cases = jsonDecode(File('.linkedspec-data/scratch/dart120-slice-cases.json').readAsStringSync()) as List;\n  for (final entry in cases) {\n    final expr = entry[1] as String;\n    final source = 'Top::\\n -> Done { return($expr) }\\n\\nDone:\\n /x/\\n';\n    final row = <String,Object?>{'case':entry[0],'expression':expr};\n    try {\n      final spec = parseSpec(source);\n      final ast = parseActionExpression(expr);\n      row['diagnostics'] = resolveActionExpressionContracts(ast).diagnostics.map((d) => d.code).toList();\n      for(final carrier in ['native','spec_json']) {\n        try {\n          final result=LinkedSpecRuntimeEngine(compileSpec(carrier=='native' ? spec : SpecFile.fromJson(spec.toJson()))).parse('x');\n          row[carrier]={'value':result.value,'matched':result.matched,'cursor':result.cursorCodeUnit};\n        } catch(error) {\n          row[carrier]={'error':error.toString(),'type':error.runtimeType.toString()};\n        }\n      }\n    } catch (error) { row['error']=error.toString(); }\n    print(jsonEncode(row));\n  }\n}\n")
Path(".linkedspec-data/scratch/dart120-slice-probe.pl").write_text("use strict;\nuse warnings;\nuse JSON::PP;\nuse LinkedSpec;\nmy $J=JSON::PP->new->canonical(1)->allow_nonref(1);\nopen my $fh, '<', '.linkedspec-data/scratch/dart120-slice-cases.json' or die $!;\nmy $raw; { local $/; $raw=<$fh>; } close $fh;\nmy $cases=$J->decode($raw);\nfor my $item (@$cases) {\n  my ($name,$expr)=@$item;\n  my $source=\"Top::\\n -> Done { return($expr) }\\n\\nDone:\\n /x/\\n\";\n  my $row={case=>$name,expression=>$expr};\n  my %ctx;\n  eval {\n    $row->{lowering}=LinkedSpec::call_spec_handler_subst('Top',\"return($expr)\");\n    my $emitted;\n    my $parser=LinkedSpec::Get(\\$source,runtime_ctx_ref=>\\%ctx,dump_parser_source=>1,parser_source_ref=>\\$emitted);\n    open my $out, '>', \".linkedspec-data/scratch/dart120-slice-$name.pl\" or die $!;\n    print $out $emitted; close $out;\n    my $input='x';$row->{value}=$parser->(\\$input);\n    $row->{context_error}=$ctx{last_error};\n    1;\n  } or $row->{exception}=\"$@\";\n  print $J->encode($row),\"\\n\";\n}\n")
DART_SLICE_END
bash tools/run_dart_project_data.sh run .linkedspec-data/scratch/dart120-slice-probe.dart > .linkedspec-data/scratch/dart120-slice-dart.log 2>&1
bash tools/project_data_run.sh perl -Iperl .linkedspec-data/scratch/dart120-slice-probe.pl > .linkedspec-data/scratch/dart120-slice-perl.log 2>&1
bash tools/project_data_run.sh python3 - <<'DART_SLICE_END_VERIFY'
from pathlib import Path
import json
cases=json.loads(Path('.linkedspec-data/scratch/dart120-slice-cases.json').read_text())
dart=[json.loads(x) for x in Path('.linkedspec-data/scratch/dart120-slice-dart.log').read_text().splitlines()]
perl=[json.loads(x) for x in Path('.linkedspec-data/scratch/dart120-slice-perl.log').read_text().splitlines()]
values=[[2,3],[1,2,3],[2,3],'bc','abc','bc']
message='RuntimeInterpreterException: action block failed in rule Top: RangeError (end): Invalid value: Not in inclusive range 1..3: -9223372036854775808'
assert len(cases)==len(dart)==len(perl)==len(values)==6
for (name,expr),d,p,value in zip(cases,dart,perl,values):
    assert set(d)=={'case','expression','diagnostics','native','spec_json'},d
    assert d['case']==p['case']==name and d['expression']==p['expression']==expr
    assert d['diagnostics']==[]
    expected={'error':message,'type':'RuntimeInterpreterException'} if name.endswith('_overflow') else {'value':value,'matched':True,'cursor':1}
    assert d['native']==d['spec_json']==expected,d
    assert set(p)=={'case','expression','lowering','value','context_error'},p
    assert p['value']==value and p['context_error'] is None,p
    emitted=Path(f'.linkedspec-data/scratch/dart120-slice-{name}.pl').read_text()
    assert p['lowering'] in emitted,name
print('PASS six exact Dart native/reconstructed and Perl facade/source slice controls: two failures, four agreements')
DART_SLICE_END_VERIFY
```
