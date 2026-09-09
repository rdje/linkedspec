---
id: dart-helper-unicode-order-gap
title: Dart lexical helpers use UTF-16 order instead of Perl character order
answers:
  - why does Dart sorted put U+10000 before U+E000
  - do Dart sorted_keys and sorted_values agree with Perl for supplementary characters
  - do Dart str_lt and str_gt use Unicode scalar ordering
  - which task owns Dart lexical helper Unicode ordering repair
date: 2026-09-09
status: confirmed-open
tags: [dart, unicode, ordering, helpers, hash, string, startup, defect]
evidence: "DART-STARTUP-READING.1.20; eight Dart native/SpecFile-JSON and Perl facade/source controls; interpreter.dart sorted compareTo at 6973, sorted_keys sort at 7286, sorted_values compareTo at 7296 and str_* compareTo at 7473; gated .2.13.1-.2.13.3, separate from MCP .2.5."
reverify: "Run DART_UNICODE_ORDER and DART_UNICODE_ORDER_VERIFY below; assertions pin pre-repair results with decoded Unicode scalars."
---

# Supplementary-character lexical ordering

Let low be U+E000 and high be U+10000. Unicode scalar order puts low first.
UTF-16 instead begins high with a surrogate below U+E000, so Dart's default
string comparison puts high first. That host comparison reaches public helpers:

| Case | Dart native and reconstructed | Perl Get |
| --- | --- | --- |
| sorted(["b", "a"]) | ["a", "b"] | ["a", "b"] |
| sorted([U+E000, U+D7FF]) | [U+D7FF, U+E000] | [U+D7FF, U+E000] |
| sorted([low, high]) | [high, low] | [low, high] |
| sorted_keys({low:1, high:2}) | [high, low] | [low, high] |
| sorted_values({low:1, high:2}) | [2, 1] | [1, 2] |
| if(str_lt(low, high), 1, 0) | 0 | 1 |
| if(str_gt(low, high), 1, 0) | 1 | 0 |
| if(str_eq(high, high), 1, 0) | 1 | 1 |

The actual source contains quoted characters, not the symbolic table names.
Each expression runs in a zero-regex Top action edge to Done: /x/, on input x.
All Dart helper diagnostics are empty, all outputs have matched=true/cursor=1,
and all Perl context errors are null. Conditional numeric results compare
ordering decisions without conflating host predicate value representations.
ASCII, BMP-only and equality controls distinguish the five ordering differences.

## Mechanism and ownership

dart/lib/src/runtime/interpreter.dart uses compareTo for sorted array items at 6973,
the default key sort at 7286, key compareTo for sorted_values at 7296 and compareTo
for str_* at 7473. The paired Perl generated handlers use cmp, sort keys, and lt/gt.
The replay checks exact lowering inside the generated source and compares decoded
characters; JSON escape spelling is not the claimed difference.

DART-STARTUP-READING.2.13.1 reconciles the preserved lexical reference contract with
portable character ordering and inventories affected consumers. .2.13.2 owns repair;
.2.13.3 owns carrier/public closeout after startup .3/.4/.5. Preserve equality,
normalization-distinct strings, copied values, key/value correspondence and authored
array order outside an explicit sort.

Sorted callback-key loops at interpreter 3126, 3161, 3195 and 3893 belong in the
consumer inventory; no fresh callback-order failure is claimed by these eight cases.
[[dart-mcp-unicode-key-order-gap]] owns the separate canonical serializer repair .2.5.
A serializer's byte contract alone does not define every language helper's semantics.

The 111 selected Dart tests pass, including existing emitted/CLI consumers, but do
not cover these supplementary/BMP ordering pairs. New defect proof is limited to
native/SpecFile-JSON Dart and Perl Get with inspected generated source; no fresh Dart
generated/emitted, callback traversal, Rust, Julia or Lua result is inferred.

Related facts: [[terse-string-comparison-bridge-contract]], [[dart-runtime-hash-helpers]],
[[dart-runtime-array-helpers]], [[dart-runtime-string-numeric-helpers]].

## Exact replay

```bash
bash tools/project_data_run.sh python3 - <<'DART_UNICODE_ORDER'
from pathlib import Path
Path(".linkedspec-data/scratch/dart120-order-cases.json").write_text("[[\"ascii_sorted\",\"sorted([\\\"b\\\", \\\"a\\\"])\"],[\"bmp_sorted\",\"sorted([\\\"\\\", \\\"퟿\\\"])\"],[\"cross_sorted\",\"sorted([\\\"\\\", \\\"𐀀\\\"])\"],[\"cross_sorted_keys\",\"sorted_keys({\\\"\\\": 1, \\\"𐀀\\\": 2})\"],[\"cross_sorted_values\",\"sorted_values({\\\"\\\": 1, \\\"𐀀\\\": 2})\"],[\"cross_less\",\"if(str_lt(\\\"\\\", \\\"𐀀\\\"), 1, 0)\"],[\"cross_greater\",\"if(str_gt(\\\"\\\", \\\"𐀀\\\"), 1, 0)\"],[\"same_scalar_equal\",\"if(str_eq(\\\"𐀀\\\", \\\"𐀀\\\"), 1, 0)\"]]\n")
Path(".linkedspec-data/scratch/dart120-order-probe.dart").write_text("import 'dart:convert';\nimport 'dart:io';\nimport '../../dart/lib/linkedspec_dart.dart';\nvoid main() {\n  final cases = jsonDecode(File('.linkedspec-data/scratch/dart120-order-cases.json').readAsStringSync()) as List;\n  for (final entry in cases) {\n    final expr = entry[1] as String;\n    final source = 'Top::\\n -> Done { return($expr) }\\n\\nDone:\\n /x/\\n';\n    final row = <String,Object?>{'case':entry[0],'expression':expr};\n    try {\n      final spec = parseSpec(source);\n      final ast = parseActionExpression(expr);\n      row['diagnostics'] = resolveActionExpressionContracts(ast).diagnostics.map((d) => d.code).toList();\n      for(final carrier in ['native','spec_json']) {\n        final result=LinkedSpecRuntimeEngine(compileSpec(carrier=='native' ? spec : SpecFile.fromJson(spec.toJson()))).parse('x');\n        row[carrier]={'value':result.value,'matched':result.matched,'cursor':result.cursorCodeUnit};\n      }\n    } catch (error) { row['error']=error.toString(); }\n    print(jsonEncode(row));\n  }\n}\n")
Path(".linkedspec-data/scratch/dart120-order-probe.pl").write_text("use strict;\nuse warnings;\nuse JSON::PP;\nuse LinkedSpec;\nmy $J=JSON::PP->new->canonical(1)->allow_nonref(1)->utf8(1);\nopen my $fh, '<', '.linkedspec-data/scratch/dart120-order-cases.json' or die $!;\nmy $raw; { local $/; $raw=<$fh>; } close $fh;\nmy $cases=$J->decode($raw);\nfor my $item (@$cases) {\n  my ($name,$expr)=@$item;\n  my $source=\"Top::\\n -> Done { return($expr) }\\n\\nDone:\\n /x/\\n\";\n  my $row={case=>$name,expression=>$expr};\n  my %ctx;\n  eval {\n    $row->{lowering}=LinkedSpec::call_spec_handler_subst('Top',\"return($expr)\");\n    my $emitted;\n    my $parser=LinkedSpec::Get(\\$source,runtime_ctx_ref=>\\%ctx,dump_parser_source=>1,parser_source_ref=>\\$emitted);\n    open my $out, '>:encoding(UTF-8)', \".linkedspec-data/scratch/dart120-order-$name.pl\" or die $!;\n    print $out $emitted; close $out;\n    my $input='x';$row->{value}=$parser->(\\$input);\n    $row->{context_error}=$ctx{last_error};\n    1;\n  } or $row->{exception}=\"$@\";\n  print $J->encode($row),\"\\n\";\n}\n")
DART_UNICODE_ORDER
bash tools/run_dart_project_data.sh run .linkedspec-data/scratch/dart120-order-probe.dart > .linkedspec-data/scratch/dart120-order-dart.log 2>&1
bash tools/project_data_run.sh perl -Iperl .linkedspec-data/scratch/dart120-order-probe.pl > .linkedspec-data/scratch/dart120-order-perl.log 2>&1
bash tools/project_data_run.sh python3 - <<'DART_UNICODE_ORDER_VERIFY'
from pathlib import Path
import json
cases=json.loads(Path('.linkedspec-data/scratch/dart120-order-cases.json').read_text())
dart=[json.loads(x) for x in Path('.linkedspec-data/scratch/dart120-order-dart.log').read_text().splitlines()]
perl=[json.loads(x) for x in Path('.linkedspec-data/scratch/dart120-order-perl.log').read_text().splitlines()]
low='\ue000';high='\U00010000'
dvalues=[['a','b'],['\ud7ff',low],[high,low],[high,low],[2,1],0,1,1]
pvalues=[['a','b'],['\ud7ff',low],[low,high],[low,high],[1,2],1,0,1]
assert len(cases)==len(dart)==len(perl)==len(dvalues)==len(pvalues)==8
for (name,expr),d,p,dv,pv in zip(cases,dart,perl,dvalues,pvalues):
    assert set(d)=={'case','expression','diagnostics','native','spec_json'},d
    assert d['case']==p['case']==name and d['expression']==p['expression']==expr
    assert d['diagnostics']==[]
    assert d['native']==d['spec_json']=={'value':dv,'matched':True,'cursor':1},d
    assert set(p)=={'case','expression','lowering','value','context_error'},p
    assert p['value']==pv and p['context_error'] is None,p
    emitted=Path(f'.linkedspec-data/scratch/dart120-order-{name}.pl').read_text()
    assert p['lowering'] in emitted,name
assert ord(low)<ord(high)
assert low.encode('utf-16-be')>high.encode('utf-16-be')
print('PASS eight exact Dart native/reconstructed and Perl facade/source Unicode controls: five differences, three agreements')
DART_UNICODE_ORDER_VERIFY
```
