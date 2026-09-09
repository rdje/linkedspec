---
id: dart-input-slice-boundary-gaps
title: Dart typed input slicing overflows its end and accepts unsupported zero arity
answers:
  - why does Dart input_slice return null for a large positive width
  - does Dart typedSourceSlice clip width before adding its start
  - is zero argument input_slice portable
  - which task owns input_slice arity and typed slice overflow
date: 2026-09-09
status: confirmed-open
tags: [dart, perl, source, slice, overflow, arity, startup, defect]
evidence: "DART-STARTUP-READING.1.21; nine native/SpecFile-JSON and Perl Get/generated-source comparisons: two overflow failures, six agreements, one zero-argument discrepancy; .2.14 owns safe clipping and .2.15 owns documented arity."
reverify: "Run DART_TYPED_SLICE and DART_TYPED_SLICE_VERIFY below; assertions pin the exact pre-repair carrier results and Perl handler context."
---

# Public input slicing boundary evidence

Every source uses zero-regex Top:: -> Done with return(expression), Done: /x/,
and input xabc. All nine Dart helper resolutions have empty diagnostics.
Native and SpecFile-JSON results agree exactly; cursor remains 1.

| Expression | Dart value / matched | Perl Get value |
| --- | --- | --- |
| input_slice(1,2) | "ab" / true | "ab" |
| input_slice(0,9223372036854775807) | "xabc" / true | "xabc" |
| input_slice(1,9223372036854775807) | null / false | "abc" |
| input_slice(4,9223372036854775807) | null / false | "" |
| input_slice(4,0) | "" / true | "" |
| input_slice(1,3) | "abc" / true | "abc" |
| input_slice(1,0) | "" / true | "" |
| input_slice(0,4) | "xabc" / true | "xabc" |
| input_slice() | "xabc" / true | null with handler error |

The first eight Perl cases have no context last_error. The last retains the exact
runtime_handler/rule_handler_eval context: undefined subroutine
LinkedSpec::SpecEntry::input_slice at generated_handler:Top:_default line 57.
The verifier pins every context field and the three emitted trace lines by their
stable content. Get's exact lowering is checked inside generated source for every
case; inspected source is not a separate emitted execution.

## Two mechanisms, separate owners

In dart/lib/src/runtime/interpreter.dart, _callInputSlice at 5409 delegates valid
start/width values to typedSourceSlice at 8618. At 8629, clampedStart+width
overflows before math.min clips to source length. The negative scalar endpoint
fails typed position projection; typedPositionFromScalar catches the source
exception and returns null. The span consequently cannot materialize. Unlike the
array/string host RangeErrors in [[dart-slice-end-overflow]], these public calls
return null and make the explicit-return parser result unmatched. Existing
DART-STARTUP-READING.2.14.1/.2.14.2 now also own this measured typed-source route.

Separately, _callInputSlice's args.isEmpty branch returns typedSourceText.
The helper resolver records known calls and counts at action_contracts.dart
1113-1126 without enforcing this signature. The public helper catalog at
docs/linkedspec-book/src/appendix/helper-contract-catalog.md specifies two arguments.
Perl MethodLowering.pm 5158-5170 requires two normalized operands; zero arguments
leave return input_slice() raw and Get's handler subsequently reports the error.
New .2.15 owns consistent early arity handling, coordinated with the existing
FUTURE-PARITY-BACKLOG.5 helper-arity work. This is not admission of a whole-input
overload: portable authoring uses input_text().

The 124 context/binding/source/recognition/observation/gap/write/mutation tests
and six ActionIR contract tests pass, including existing emitted/CLI consumers.
These nine new controls prove only Dart native/reconstructed and Perl facade/source
behavior. One/three-argument forms, fresh Dart emitted defect behavior and other
backends have not been newly measured. No executable repair is made.

## Exact replay

```bash
bash tools/project_data_run.sh python3 - <<'DART_TYPED_SLICE'
from pathlib import Path
Path(".linkedspec-data/scratch/dart121-typed-slice-cases.json").write_text("[[\"small\",\"input_slice(1, 2)\"],[\"large_at_zero\",\"input_slice(0, 9223372036854775807)\"],[\"large_at_one\",\"input_slice(1, 9223372036854775807)\"],[\"large_at_end\",\"input_slice(4, 9223372036854775807)\"],[\"zero_at_end\",\"input_slice(4, 0)\"],[\"exact_suffix\",\"input_slice(1, 3)\"],[\"zero_width\",\"input_slice(1, 0)\"],[\"whole_input\",\"input_slice(0, 4)\"],[\"zero_arguments\",\"input_slice()\"]]\n")
Path(".linkedspec-data/scratch/dart121-typed-slice-probe.dart").write_text("import 'dart:convert';\nimport 'dart:io';\nimport '../../dart/lib/linkedspec_dart.dart';\nvoid main() {\n  final cases = jsonDecode(File('.linkedspec-data/scratch/dart121-typed-slice-cases.json').readAsStringSync()) as List;\n  for (final entry in cases) {\n    final expr = entry[1] as String;\n    final source = 'Top::\\n -> Done { return($expr) }\\n\\nDone:\\n /x/\\n';\n    final row = <String,Object?>{'case':entry[0],'expression':expr};\n    try {\n      final spec = parseSpec(source);\n      final ast = parseActionExpression(expr);\n      row['diagnostics'] = resolveActionExpressionContracts(ast).diagnostics.map((d) => d.code).toList();\n      for(final carrier in ['native','spec_json']) {\n        try {\n          final result=LinkedSpecRuntimeEngine(compileSpec(carrier=='native' ? spec : SpecFile.fromJson(spec.toJson()))).parse('xabc');\n          row[carrier]={'value':result.value,'matched':result.matched,'cursor':result.cursorCodeUnit};\n        } catch(error) {\n          row[carrier]={'error':error.toString(),'type':error.runtimeType.toString()};\n        }\n      }\n    } catch (error) { row['error']=error.toString(); }\n    print(jsonEncode(row));\n  }\n}\n")
Path(".linkedspec-data/scratch/dart121-typed-slice-probe.pl").write_text("use strict;\nuse warnings;\nuse JSON::PP;\nuse LinkedSpec;\nmy $J=JSON::PP->new->canonical(1)->allow_nonref(1);\nopen my $fh, '<', '.linkedspec-data/scratch/dart121-typed-slice-cases.json' or die $!;\nmy $raw; { local $/; $raw=<$fh>; } close $fh;\nmy $cases=$J->decode($raw);\nfor my $item (@$cases) {\n  my ($name,$expr)=@$item;\n  my $source=\"Top::\\n -> Done { return($expr) }\\n\\nDone:\\n /x/\\n\";\n  my $row={case=>$name,expression=>$expr};\n  my %ctx;\n  eval {\n    $row->{lowering}=LinkedSpec::call_spec_handler_subst('Top',\"return($expr)\");\n    my $emitted;\n    my $parser=LinkedSpec::Get(\\$source,runtime_ctx_ref=>\\%ctx,dump_parser_source=>1,parser_source_ref=>\\$emitted);\n    open my $out, '>', \".linkedspec-data/scratch/dart121-typed-slice-$name.pl\" or die $!;\n    print $out $emitted; close $out;\n    my $input='xabc';$row->{value}=$parser->(\\$input);\n    $row->{context_error}=$ctx{last_error};\n    1;\n  } or $row->{exception}=\"$@\";\n  print $J->encode($row),\"\\n\";\n}\n")
DART_TYPED_SLICE
bash tools/run_dart_project_data.sh run .linkedspec-data/scratch/dart121-typed-slice-probe.dart > .linkedspec-data/scratch/dart121-typed-slice-dart.log 2>&1
bash tools/project_data_run.sh perl -Iperl .linkedspec-data/scratch/dart121-typed-slice-probe.pl > .linkedspec-data/scratch/dart121-typed-slice-perl.log 2>&1
bash tools/project_data_run.sh python3 - <<'DART_TYPED_SLICE_VERIFY'
from pathlib import Path
import json,re
cases=json.loads(Path('.linkedspec-data/scratch/dart121-typed-slice-cases.json').read_text())
dart=[json.loads(x) for x in Path('.linkedspec-data/scratch/dart121-typed-slice-dart.log').read_text().splitlines()]
lines=Path('.linkedspec-data/scratch/dart121-typed-slice-perl.log').read_text().splitlines()
perl=[json.loads(x) for x in lines if x.startswith('{')]
trace=[x for x in lines if not x.startswith('{')]
assert len(trace)==3 and all('[NONE][SpecEntry.pm][trace_decision:63]' in x for x in trace)
assert 'DECISION rule_handler_eval:Top => SKIPPED' in trace[0]
assert 'Undefined subroutine &LinkedSpec::SpecEntry::input_slice' in trace[1]
values=['ab','xabc','abc','','','abc','','xabc','xabc']
assert len(cases)==len(dart)==len(perl)==len(values)==9
for (name,expr),d,p,value in zip(cases,dart,perl,values):
    assert set(d)=={'case','expression','diagnostics','native','spec_json'},d
    assert d['case']==p['case']==name and d['expression']==p['expression']==expr
    assert d['diagnostics']==[]
    dv=None if name in {'large_at_one','large_at_end'} else value
    assert d['native']==d['spec_json']=={'value':dv,'matched':dv is not None,'cursor':1},d
    assert set(p)=={'case','expression','lowering','value','context_error'},p
    emitted=Path(f'.linkedspec-data/scratch/dart121-typed-slice-{name}.pl').read_text()
    assert p['lowering'] in emitted,name
    if name=='zero_arguments':
        assert p['value'] is None and p['lowering']=='return input_slice()'
        expected={'type':'runtime_handler','stage':'rule_handler_eval','owner_stage':'runtime_handler:rule_handler_eval',
            'rule_label':'Top','top_rule':'Top','spec_name':'','spec_path':'',
            'summary':'Rule handler execution failed','handler_variant':'_default',
            'handler_source_label':'LinkedSpec::generated_handler:Top:_default',
            'detail':'Undefined subroutine &LinkedSpec::SpecEntry::input_slice called at LinkedSpec::generated_handler:Top:_default line 57.\n'}
        assert p['context_error']==expected,p
    else:
        assert p['value']==value and p['context_error'] is None,p
print('PASS nine exact Dart native/reconstructed and Perl facade/source controls: two typed-slice overflows, six agreements, one unsupported zero-argument difference')
DART_TYPED_SLICE_VERIFY
```
