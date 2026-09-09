---
id: dart-regex-quantifier-literal-corruption
title: Dart lower-unbounded regex normalization rewrites escaped literals and character classes
answers:
  - why does Dart change literal regex braces comma two into braces zero comma two
  - does Dart regex quantifier normalization respect character classes
  - why does a Dart character class unexpectedly accept zero
  - which task owns Dart regex quantifier literal corruption
date: 2026-09-09
status: confirmed-open
tags: [dart, regex, normalization, literal, character-class, startup, defect]
evidence: "DART-STARTUP-READING.1.23; six public alternation/native/SpecFile-JSON and Perl Get/generated-source controls prove three literal corruptions and three agreements; matching.dart 1619 unconditionally replaces {,n}; gated .2.16.1/.2.16.2 own repair."
reverify: "Run DART_REGEX_LITERAL and DART_REGEX_LITERAL_VERIFY below; assertions pin raw host, normalized bridge and both parser carriers plus Perl source evidence."
---

# Regex text is changed outside quantifiers

The public RuntimeRegexAlternation facade exposes the compiled pattern. Its
lower-unbounded quantifier adapter rewrites {,2} to {0,2} even inside an escaped
literal or a character class. The same altered pattern executes through normal
authored-source compilation and SpecFile-JSON reconstruction.

| Pattern | Input | Raw Dart RegExp | Dart bridge/parser match | Perl regex/Get match |
| --- | --- | --- | --- | --- |
| ^\\{,2}$ | {,2} | true | false | true |
| ^\\{,2}$ | {0,2} | false | true | false |
| ^[{,2}]+$ | 0 | false | true | false |
| ^[{,2}]+$ | 2 | true | true | true |
| ^a{,2}$ | aa | false | true | true |
| ^\\{0,2}$ | {0,2} | true | true | true |

The actual quantifier control proves that removing normalization altogether
would lose supported dialect behavior. The three first cases instead prove
corrupted literal meaning: one false negative and two false positives.
The raw Dart host has the same intended literal behavior as Perl.

Every parser source is Top:: -> Done { return("hit") }, with the tested pattern
as Done's regex. A match returns "hit" and advances to input length; a miss returns
null with matched=false/cursor=0. Native and reconstructed results are identical.
Perl Get has no context last_error in any case; its generated source retains the
authored pattern in both the combined selection and the required-slot record.
The verifier checks both exact source occurrences. This is inspected generated
source, not a separate emitted execution.

## Mechanism and ownership

dart/lib/src/runtime/matching.dart 1417 composes regex normalization passes.
_normalizeLowerUnboundedQuantifiers at 1619 applies replaceAllMapped with a
global {,digits} pattern. It carries no escape or character-class state, so it
rewrites the escaped opening brace and the characters inside [{,2}] alike.
The public facade exports RuntimeRegexAlternation; compileRuntimeRegex itself
is internal. The replay uses the public facade to inspect the resulting regex.

DART-STARTUP-READING.2.16.1 owns lexical-context-aware normalization and the exact
six controls; .2.16.2 owns carrier/public closeout after startup .3/.4/.5.
Adjacent rewrite passes require inspection, but no additional literal corruption
is inferred here. Existing scoped-flag lifting and possessive-marker removal
remain the separately documented dialect limits in [[dart-regex-dialect-bridge]].
The regex-brace scanners under .2.2/startup .54 are different mechanisms.

All 99 selected matcher/interpreter/recognition/observation/gap/self-hosted/source
tests pass, including existing emitted/CLI consumers. The new defect evidence
covers the public alternation API, authored native and SpecFile-JSON Dart plus
Perl regex/Get/source. It does not establish fresh Dart emitted defect behavior
or another backend's output, and no executable repair is made.

## Exact replay

```bash
bash tools/project_data_run.sh python3 - <<'DART_REGEX_LITERAL'
from pathlib import Path
Path(".linkedspec-data/scratch/dart123-regex-cases.json").write_text("[[\"escaped_literal\",\"^\\\\{,2}$\",\"{,2}\"],[\"changed_literal\",\"^\\\\{,2}$\",\"{0,2}\"],[\"class_added_zero\",\"^[{,2}]+$\",\"0\"],[\"class_original_digit\",\"^[{,2}]+$\",\"2\"],[\"lower_unbounded\",\"^a{,2}$\",\"aa\"],[\"explicit_literal\",\"^\\\\{0,2}$\",\"{0,2}\"]]\n")
Path(".linkedspec-data/scratch/dart123-regex-probe.dart").write_text("import 'dart:convert';\nimport 'dart:io';\nimport '../../dart/lib/linkedspec_dart.dart';\nvoid main() {\n  final cases=jsonDecode(File('.linkedspec-data/scratch/dart123-regex-cases.json').readAsStringSync()) as List;\n  for(final entry in cases) {\n    final pattern=entry[1] as String;\n    final input=entry[2] as String;\n    final source='Top::\\n -> Done { return(\"hit\") }\\n\\nDone:\\n /$pattern/\\n';\n    final row=<String,Object?>{'case':entry[0],'pattern':pattern,'input':input};\n    try {\n      row['host_match']=RegExp(pattern).hasMatch(input);\n      final regex=RuntimeRegexAlternation.compile([pattern]).alternatives.single.regex;\n      row['bridge_pattern']=regex.pattern;\n      row['bridge_match']=regex.hasMatch(input);\n      final spec=parseSpec(source);\n      for(final carrier in ['native','spec_json']) {\n        try {\n          final r=LinkedSpecRuntimeEngine(compileSpec(carrier=='native' ? spec : SpecFile.fromJson(spec.toJson()))).parse(input);\n          row[carrier]={'value':r.value,'matched':r.matched,'cursor':r.cursorCodeUnit};\n        } catch(error) { row[carrier]={'error':error.toString()}; }\n      }\n    } catch(error) { row['error']=error.toString(); }\n    print(jsonEncode(row));\n  }\n}\n")
Path(".linkedspec-data/scratch/dart123-regex-probe.pl").write_text("use strict;\nuse warnings;\nuse JSON::PP;\nuse LinkedSpec;\nmy $J=JSON::PP->new->canonical(1)->allow_nonref(1);\nopen my $fh,'<','.linkedspec-data/scratch/dart123-regex-cases.json' or die $!;\nmy $raw; { local $/; $raw=<$fh>; } close $fh;\nfor my $item (@{$J->decode($raw)}) {\n  my ($name,$pattern,$input)=@$item;\n  my $source=\"Top::\\n -> Done { return(\\\"hit\\\") }\\n\\nDone:\\n /$pattern/\\n\";\n  my $row={case=>$name,pattern=>$pattern,input=>$input};\n  my %ctx;\n  eval {\n    $row->{host_match}=($input =~ qr/$pattern/) ? JSON::PP::true : JSON::PP::false;\n    my $emitted;\n    my $parser=LinkedSpec::Get(\\$source,runtime_ctx_ref=>\\%ctx,dump_parser_source=>1,parser_source_ref=>\\$emitted);\n    open my $out,'>',\".linkedspec-data/scratch/dart123-regex-$name.pl\" or die $!;\n    print $out $emitted; close $out;\n    my $copy=$input; $row->{value}=$parser->(\\$copy);\n    $row->{context_error}=$ctx{last_error};\n    1;\n  } or $row->{exception}=\"$@\";\n  print $J->encode($row),\"\\n\";\n}\n")
DART_REGEX_LITERAL
bash tools/run_dart_project_data.sh run .linkedspec-data/scratch/dart123-regex-probe.dart > .linkedspec-data/scratch/dart123-regex-dart.log 2>&1
bash tools/project_data_run.sh perl -Iperl .linkedspec-data/scratch/dart123-regex-probe.pl > .linkedspec-data/scratch/dart123-regex-perl.log 2>&1
bash tools/project_data_run.sh python3 - <<'DART_REGEX_LITERAL_VERIFY'
from pathlib import Path
import json
cases=json.loads(Path('.linkedspec-data/scratch/dart123-regex-cases.json').read_text())
dart=[json.loads(x) for x in Path('.linkedspec-data/scratch/dart123-regex-dart.log').read_text().splitlines()]
perl=[json.loads(x) for x in Path('.linkedspec-data/scratch/dart123-regex-perl.log').read_text().splitlines()]
expected=[(True,True,False),(False,False,True),(False,False,True),(True,True,True),(False,True,True),(True,True,True)]
assert len(cases)==len(dart)==len(perl)==len(expected)==6
for (name,pattern,input),d,p,(host,reference,bridge) in zip(cases,dart,perl,expected):
    assert set(d)=={'case','pattern','input','host_match','bridge_pattern','bridge_match','native','spec_json'},d
    assert set(p)=={'case','pattern','input','host_match','value','context_error'},p
    assert d['case']==p['case']==name and d['pattern']==p['pattern']==pattern and d['input']==p['input']==input
    assert d['host_match'] is host and d['bridge_match'] is bridge and p['host_match'] is reference
    assert d['bridge_pattern']==pattern.replace('{,2}','{0,2}')
    assert d['native']==d['spec_json']=={'value':'hit' if bridge else None,'matched':bridge,'cursor':len(input) if bridge else 0},d
    assert p['value']==('hit' if reference else None) and p['context_error'] is None,p
    emitted=Path(f'.linkedspec-data/scratch/dart123-regex-{name}.pl').read_text()
    quoted=pattern.replace('\\','\\\\').replace("'","\\'")
    assert emitted.count("'(?^:"+quoted+")'")==2,name
print('PASS six public Dart alternation/native/reconstructed and Perl facade/source controls: three literal corruptions and three agreements')
DART_REGEX_LITERAL_VERIFY
```
