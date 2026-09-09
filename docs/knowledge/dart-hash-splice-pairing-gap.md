---
id: dart-hash-splice-pairing-gap
title: Dart pairs hash arguments before splicing and loses authored fields
answers:
  - why does Dart hash flat produce a container text key
  - does Dart hash preserve pairs following a splice
  - does Dart hash support flat_array key value tokens
  - which task owns Dart hash splice order and duplicate repair
date: 2026-09-09
status: confirmed-open
tags: [dart, runtime, hash, harray, constructor, flat, splice, startup, defect]
evidence: "DART-STARTUP-READING.1.19; nine Dart native/SpecFile-JSON controls and nine Perl facade comparisons with generated handler inspection; interpreter.dart _callHash at 5383, raw pairing at 5394 and late map merge at 5399; _isHashSpliceArgument at 6723 omits flat_array; gated .2.11.1-.2.11.3, coordinated with FUTURE-PARITY-BACKLOG.5."
reverify: "Run DART_HASH_SPLICE, both managed invocations and DART_HASH_SPLICE_VERIFY below; assertions pin pre-repair behavior."
---

# Hash splice pairing and ordering

Dart evaluates all hash-constructor arguments, pairs their raw values, then separately
merges explicit map-splice arguments. A leading or middle map can therefore become a
host container-text key, consume the following key as its value and lose the following
ordinary field. Applying every map merge last also overrides a later authored duplicate.

A leading flat_array result is likewise paired as one container value. Hash splice
classification accepts flat and flat_hash, but omits flat_array; the merge path also
accepts only maps. The array constructor uses a separate token-expansion path.

The nine cases below use meta = {"a": 1} before the expression in a zero-regex Top action
edge targeting Done: /x/, on input x. This lets the edge select Done's regex; it does not
rely on entry matching Top's own regex. See [[top-rule-is-ordinary-rule-entered-first]].

| Expression | Dart native and reconstructed value | Perl facade value |
| --- | --- | --- |
| hash("a", 1, "b", 2) | {"a":1,"b":2} | {"a":1,"b":2} |
| hash("b", 2, flat(meta)) | {"b":2,"a":1} | null |
| hash(flat(meta), "b", 2) | {"{a: 1}":"b","a":1} | null |
| hash("p", 0, flat(meta), "b", 2) | {"p":0,"{a: 1}":"b","a":1} | null |
| hash(flat(meta), "a", 2) | {"{a: 1}":"a","a":1} | null |
| hash("a", 2, flat(meta)) | {"a":1} | null |
| hash(flat(meta)) | {"a":1} | null |
| hash(flat_array(["a", 1]), "b", 2) | {"[a, 1]":"b"} | {"a":1,"b":2} |
| hash("payload", meta, "b", 2) | {"payload":{"a":1},"b":2} | {"payload":{"a":1},"b":2} |

All Dart cases compile with empty helper-contract diagnostics and return matched=true,
cursor=1 on both carriers. Perl's six map-splice cases lower the complete body to
LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash and return null. Both the complete-body
call_spec_handler_subst output and Get's generated handler contain that sentinel;
runtime context has no last_error. Isolated return-only lowering lacks the preceding
binding-kind context and is not a reliable substitute for that complete-body proof.

The Perl flat_array control succeeds, as do plain pairs and the ordinary nested map.
Its map results are an already-owned helper-context limitation, not an expected
replacement for Dart's map-splice output. [[hash-helper-odd-arity-current-behavior]]
and FUTURE-PARITY-BACKLOG.5 retain those portable decision boundaries.
[[lua-flat-array-hash-splicing]] and [[lua-runtime-harray-construction]] record Lua's
ordered explicit-splice behavior; this slice does not freshly execute Lua.

## Repair ownership and proof limits

DART-STARTUP-READING.2.11.1 resolves exact expectations with the existing helper caveat
owner. .2.11.2 repairs the Dart splice stream and .2.11.3 owns carrier/public closeout
after startup .3/.4/.5. Preserve explicit syntax, ordinary nested values, last-authored
duplicate order, once-only evaluation and deep copying. Direct/receiver aliases, empty
and multiple splices, odd-shape policy and effect/copy controls require repair proof.

The 122 selected Dart tests pass, including existing emitted/CLI consumers; they do not
cover this newly measured boundary. New defect proof here covers native and SpecFile-JSON
Dart plus Perl's Get facade and inspected generated source. It does not establish fresh
Dart generated/emitted execution or other backend output.

## Exact replay

```bash
bash tools/project_data_run.sh python3 - <<'DART_HASH_SPLICE'
from pathlib import Path
import json
Path(".linkedspec-data/scratch/dart119-hash-cases.json").write_text("[[\"plain_pairs\",\"hash(\\\"a\\\", 1, \\\"b\\\", 2)\"],[\"trailing_map\",\"hash(\\\"b\\\", 2, flat(meta))\"],[\"leading_map\",\"hash(flat(meta), \\\"b\\\", 2)\"],[\"middle_map\",\"hash(\\\"p\\\", 0, flat(meta), \\\"b\\\", 2)\"],[\"leading_duplicate\",\"hash(flat(meta), \\\"a\\\", 2)\"],[\"trailing_duplicate\",\"hash(\\\"a\\\", 2, flat(meta))\"],[\"sole_map\",\"hash(flat(meta))\"],[\"leading_flat_array\",\"hash(flat_array([\\\"a\\\", 1]), \\\"b\\\", 2)\"],[\"nested_map_value\",\"hash(\\\"payload\\\", meta, \\\"b\\\", 2)\"]]\n")
Path(".linkedspec-data/scratch/dart119-hash-probe.dart").write_text("import 'dart:convert';\nimport 'dart:io';\nimport '../../dart/lib/linkedspec_dart.dart';\nvoid main() {\n  final cases = jsonDecode(File('.linkedspec-data/scratch/dart119-hash-cases.json').readAsStringSync()) as List;\n  for (final entry in cases) {\n    final expr = entry[1] as String;\n    final source = 'Top::\\n -> Done { meta = {\"a\": 1}; return($expr) }\\n\\nDone:\\n /x/\\n';\n    final row = <String,Object?>{'case':entry[0],'expression':expr};\n    try {\n      final spec = parseSpec(source);\n      final ast = parseActionExpression(expr);\n      row['diagnostics'] = resolveActionExpressionContracts(ast).diagnostics.map((d) => d.code).toList();\n      for(final carrier in ['native','spec_json']) {\n        final result=LinkedSpecRuntimeEngine(compileSpec(carrier=='native' ? spec : SpecFile.fromJson(spec.toJson()))).parse('x');\n        row[carrier]={'value':result.value,'matched':result.matched,'cursor':result.cursorCodeUnit};\n      }\n    } catch (error) { row['error']=error.toString(); }\n    print(jsonEncode(row));\n  }\n}\n")
Path(".linkedspec-data/scratch/dart119-hash-probe.pl").write_text("use strict;\nuse warnings;\nuse JSON::PP;\nuse LinkedSpec;\nmy $J=JSON::PP->new->canonical(1)->allow_nonref(1);\nopen my $fh, '<', '.linkedspec-data/scratch/dart119-hash-cases.json' or die $!;\nmy $raw; { local $/; $raw=<$fh>; } close $fh;\nmy $cases=$J->decode($raw);\nfor my $item (@$cases) {\n  my ($name,$expr)=@$item;\n  my $source=\"Top::\\n -> Done { meta = {\\\"a\\\": 1}; return($expr) }\\n\\nDone:\\n /x/\\n\";\n  my $row={case=>$name,expression=>$expr};\n  my %ctx;\n  eval {\n    $row->{lowering}=LinkedSpec::call_spec_handler_subst('Top',\"meta = {\\\"a\\\": 1}; return($expr)\");\n    my $emitted;\n    my $parser=LinkedSpec::Get(\\$source,runtime_ctx_ref=>\\%ctx,dump_parser_source=>1,parser_source_ref=>\\$emitted);\n    open my $out, '>', \".linkedspec-data/scratch/dart119-hash-$name.pl\" or die $!;\n    print $out $emitted; close $out;\n    my $input='x';$row->{value}=$parser->(\\$input);\n    $row->{context_error}=$ctx{last_error};\n    1;\n  } or $row->{exception}=\"$@\";\n  print $J->encode($row),\"\\n\";\n}\n")
DART_HASH_SPLICE
bash tools/run_dart_project_data.sh run .linkedspec-data/scratch/dart119-hash-probe.dart > .linkedspec-data/scratch/dart119-hash-dart.log 2>&1
bash tools/project_data_run.sh perl -Iperl .linkedspec-data/scratch/dart119-hash-probe.pl > .linkedspec-data/scratch/dart119-hash-perl.log 2>&1
bash tools/project_data_run.sh python3 - <<'DART_HASH_SPLICE_VERIFY'
from pathlib import Path
import json
cases=json.loads(Path('.linkedspec-data/scratch/dart119-hash-cases.json').read_text())
dart=[json.loads(line) for line in Path('.linkedspec-data/scratch/dart119-hash-dart.log').read_text().splitlines()]
perl=[json.loads(line) for line in Path('.linkedspec-data/scratch/dart119-hash-perl.log').read_text().splitlines()]
expected=[
 {'a':1,'b':2}, {'b':2,'a':1}, {'{a: 1}':'b','a':1},
 {'p':0,'{a: 1}':'b','a':1}, {'{a: 1}':'a','a':1},
 {'a':1}, {'a':1}, {'[a, 1]':'b'}, {'payload':{'a':1},'b':2},
]
assert len(cases)==len(dart)==len(perl)==len(expected)==9
for index,((name,expr),d,p,value) in enumerate(zip(cases,dart,perl,expected)):
    assert set(d)=={'case','expression','diagnostics','native','spec_json'},d
    assert d['case']==p['case']==name and d['expression']==p['expression']==expr
    assert d['diagnostics']==[]
    assert d['native']==d['spec_json']=={'value':value,'matched':True,'cursor':1},d
    assert set(p)=={'case','expression','lowering','value','context_error'},p
    assert p['context_error'] is None
    emitted=Path(f'.linkedspec-data/scratch/dart119-hash-{name}.pl').read_text()
    assert p['lowering'] in emitted,(name,p['lowering'])
    if 1<=index<=6:
        assert p['value'] is None and 'LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash' in p['lowering'],p
    else:
        assert 'LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash' not in p['lowering']
        wanted={'a':1,'b':2} if index in (0,7) else {'payload':{'a':1},'b':2}
        assert p['value']==wanted,p
print('PASS nine exact Dart native/reconstructed results and nine source-backed Perl facade comparisons')
DART_HASH_SPLICE_VERIFY
```
