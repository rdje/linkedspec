---
id: dart-large-number-helper-corruption
title: Dart numeric helpers and scalar text corrupt large finite values
answers:
  - why does Dart adding zero change a large finite number
  - why does Dart cat clamp 1e20 to a signed integer endpoint
  - can Dart num_add wrap and num_abs return a negative result
  - which task owns Dart finite number conversion and arithmetic repair
date: 2026-09-09
status: confirmed-open
tags: [dart, numeric, scalar-text, overflow, conversion, startup, defect]
evidence: "DART-STARTUP-READING.1.20; eleven Dart native/SpecFile-JSON and Perl facade/source controls; interpreter.dart numeric add at 7493, abs at 7532, fold at 7614, _jsonNumber conversion at 7740 and scalar text conversion at 7879; gated .2.12.1-.2.12.3 alongside startup .55 and .20."
reverify: "Run DART_NUMBER_BOUNDARY and DART_NUMBER_BOUNDARY_VERIFY below; assertions pin pre-repair output and JSON kinds."
---

# Large finite value corruption

Dart preserves direct positive and negative 1e20 literal returns. Applying num_add(value, 0)
or scalar-text cat changes their magnitude to a signed-64 endpoint. Integer addition can
also wrap across that boundary, and num_abs of the minimum signed integer remains negative.

Eleven exact cases use a zero-regex Top action edge to Done: /x/ on input x.
Native and SpecFile-JSON Dart agree, with empty helper diagnostics:

| Expression | Dart value | Perl Get value |
| --- | --- | --- |
| 42 | 42 | 42 |
| 100000000000000000000 | 1e20 | 1e20 |
| -100000000000000000000 | -1e20 | -1e20 |
| num_add(40, 2) | 42 | 42 |
| num_add(100000000000000000000, 0) | 9223372036854775807 | 1e20 |
| num_add(-100000000000000000000, 0) | -9223372036854775808 | -1e20 |
| cat(100000000000000000000, "") | "9223372036854775807" | "1e+20" |
| cat(-100000000000000000000, "") | "-9223372036854775808" | "-1e+20" |
| num_add(9223372036854775807, 1) | -9223372036854775808 | 9223372036854775808 |
| num_abs(-9223372036854775808) | -9223372036854775808 | 9223372036854775808 |
| num_div(1, 0) | null | null |

The six differences include numeric sign/magnitude corruption, not merely alternate JSON
or scientific spelling. The two direct large literals are floating JSON numbers; saturated
helper outputs are integers, and cat results are strings. Every Dart case reaches cursor 1;
all non-null results have matched=true, while invalid division has matched=false.
Perl has no context last_error and its inspected generated handler contains the exact
call_spec_handler_subst lowering retained by the probe.

## Mechanism and ownership

In dart/lib/src/runtime/interpreter.dart, _jsonNumber at 7735 converts any finite integral
number with toInt at 7740, without an integer-range guard. _scalarString repeats that
conversion at 7879 before printing. The helper dispatcher performs addition with native
num arithmetic at 7493 and absolute value at 7532; integer overflow can already have
changed the result before _numericFold or _unaryNumber normalizes it.

DART-STARTUP-READING.2.12.1 owns the complete conversion/arithmetic consumer inventory
and independent boundary expectations; .2.12.2 owns implementation and .2.12.3 owns
carrier/public closeout after startup .3/.4/.5. Audit reducers, modulo/rounding and
index/diagnostic consumers as source inventory; they are not additional measured failures.

[[rust-large-number-conversion-defect]] retains Rust repair SESSION-STARTUP-READING.55.1
and the separate portable text-spelling decision .55.2. Dart's text magnitude corruption
must be fixed regardless of that spelling choice. Numeric input grammar remains under
startup .20. This does not promise arbitrary-precision integer arithmetic.

ADR0029 admits finite numeric inputs and rejects invalid/nonfinite results; it does not
authorize silent host overflow. The neutral 55-case/18-helper checker and 111 selected
Dart tests pass, including the existing exact numeric fixture, scalar-text fixture and
emitted/CLI consumers. [[cross-backend-scalar-numeric-drift]] qualifies earlier admission:
finite fixture success does not cover these larger magnitudes.

New defect proof covers native/reconstructed Dart and Perl Get plus inspected generated
source. No fresh Dart generated/emitted defect result or complete numeric range census
is claimed.

## Exact replay

```bash
bash tools/project_data_run.sh python3 - <<'DART_NUMBER_BOUNDARY'
from pathlib import Path
Path(".linkedspec-data/scratch/dart120-number-cases.json").write_text("[[\"small_literal\",\"42\"],[\"large_positive_literal\",\"100000000000000000000\"],[\"large_negative_literal\",\"-100000000000000000000\"],[\"small_add\",\"num_add(40, 2)\"],[\"large_positive_add\",\"num_add(100000000000000000000, 0)\"],[\"large_negative_add\",\"num_add(-100000000000000000000, 0)\"],[\"large_positive_text\",\"cat(100000000000000000000, \\\"\\\")\"],[\"large_negative_text\",\"cat(-100000000000000000000, \\\"\\\")\"],[\"int_add_boundary\",\"num_add(9223372036854775807, 1)\"],[\"int_abs_boundary\",\"num_abs(-9223372036854775808)\"],[\"invalid_division\",\"num_div(1, 0)\"]]\n")
Path(".linkedspec-data/scratch/dart120-number-probe.dart").write_text("import 'dart:convert';\nimport 'dart:io';\nimport '../../dart/lib/linkedspec_dart.dart';\nvoid main() {\n  final cases = jsonDecode(File('.linkedspec-data/scratch/dart120-number-cases.json').readAsStringSync()) as List;\n  for (final entry in cases) {\n    final expr = entry[1] as String;\n    final source = 'Top::\\n -> Done { return($expr) }\\n\\nDone:\\n /x/\\n';\n    final row = <String,Object?>{'case':entry[0],'expression':expr};\n    try {\n      final spec = parseSpec(source);\n      final ast = parseActionExpression(expr);\n      row['diagnostics'] = resolveActionExpressionContracts(ast).diagnostics.map((d) => d.code).toList();\n      for(final carrier in ['native','spec_json']) {\n        final result=LinkedSpecRuntimeEngine(compileSpec(carrier=='native' ? spec : SpecFile.fromJson(spec.toJson()))).parse('x');\n        row[carrier]={'value':result.value,'matched':result.matched,'cursor':result.cursorCodeUnit};\n      }\n    } catch (error) { row['error']=error.toString(); }\n    print(jsonEncode(row));\n  }\n}\n")
Path(".linkedspec-data/scratch/dart120-number-probe.pl").write_text("use strict;\nuse warnings;\nuse JSON::PP;\nuse LinkedSpec;\nmy $J=JSON::PP->new->canonical(1)->allow_nonref(1);\nopen my $fh, '<', '.linkedspec-data/scratch/dart120-number-cases.json' or die $!;\nmy $raw; { local $/; $raw=<$fh>; } close $fh;\nmy $cases=$J->decode($raw);\nfor my $item (@$cases) {\n  my ($name,$expr)=@$item;\n  my $source=\"Top::\\n -> Done { return($expr) }\\n\\nDone:\\n /x/\\n\";\n  my $row={case=>$name,expression=>$expr};\n  my %ctx;\n  eval {\n    $row->{lowering}=LinkedSpec::call_spec_handler_subst('Top',\"return($expr)\");\n    my $emitted;\n    my $parser=LinkedSpec::Get(\\$source,runtime_ctx_ref=>\\%ctx,dump_parser_source=>1,parser_source_ref=>\\$emitted);\n    open my $out, '>', \".linkedspec-data/scratch/dart120-number-$name.pl\" or die $!;\n    print $out $emitted; close $out;\n    my $input='x';$row->{value}=$parser->(\\$input);\n    $row->{context_error}=$ctx{last_error};\n    1;\n  } or $row->{exception}=\"$@\";\n  print $J->encode($row),\"\\n\";\n}\n")
DART_NUMBER_BOUNDARY
bash tools/run_dart_project_data.sh run .linkedspec-data/scratch/dart120-number-probe.dart > .linkedspec-data/scratch/dart120-number-dart.log 2>&1
bash tools/project_data_run.sh perl -Iperl .linkedspec-data/scratch/dart120-number-probe.pl > .linkedspec-data/scratch/dart120-number-perl.log 2>&1
bash tools/project_data_run.sh python3 - <<'DART_NUMBER_BOUNDARY_VERIFY'
from pathlib import Path
import json
cases=json.loads(Path('.linkedspec-data/scratch/dart120-number-cases.json').read_text())
dart=[json.loads(x) for x in Path('.linkedspec-data/scratch/dart120-number-dart.log').read_text().splitlines()]
perl=[json.loads(x) for x in Path('.linkedspec-data/scratch/dart120-number-perl.log').read_text().splitlines()]
minimum=-(2**63);maximum=2**63-1
dvalues=[42,1e20,-1e20,42,maximum,minimum,str(maximum),str(minimum),minimum,minimum,None]
pvalues=[42,1e20,-1e20,42,1e20,-1e20,'1e+20','-1e+20',2**63,2**63,None]
assert len(cases)==len(dart)==len(perl)==len(dvalues)==len(pvalues)==11
for (name,expr),d,p,dv,pv in zip(cases,dart,perl,dvalues,pvalues):
    assert set(d)=={'case','expression','diagnostics','native','spec_json'},d
    assert d['case']==p['case']==name and d['expression']==p['expression']==expr
    assert d['diagnostics']==[]
    assert d['native']==d['spec_json']=={'value':dv,'matched':dv is not None,'cursor':1},d
    assert type(d['native']['value']) is type(dv),d
    assert set(p)=={'case','expression','lowering','value','context_error'},p
    assert p['value']==pv and type(p['value']) is type(pv) and p['context_error'] is None,p
    emitted=Path(f'.linkedspec-data/scratch/dart120-number-{name}.pl').read_text()
    assert p['lowering'] in emitted,name
print('PASS eleven exact Dart native/reconstructed and Perl facade/source number controls: six differences, five agreements')
DART_NUMBER_BOUNDARY_VERIFY
```
