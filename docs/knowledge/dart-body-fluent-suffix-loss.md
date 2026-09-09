---
id: dart-body-fluent-suffix-loss
title: Dart standalone body fluents discard unsupported suffixes before validation
answers:
  - why does Dart accept .Töp as fluent method T
  - does Dart body fluent parsing discard invalid suffixes
  - where is the Dart standalone fluent remainder lost
  - which repair owns Dart body fluent whole-token parsing
date: 2026-09-09
status: confirmed bounded defect; repair owned by DART-STARTUP-READING.2.6
tags: [dart, parser, fluent, unicode, diagnostics, DART-STARTUP-READING]
evidence: "DART-STARTUP-READING.1.13 reconciles Unicode identifier isolation with seven body-fluent parseSpec/validateSpec/default compileSpec controls. Three malformed suffixes disappear and compile, two accepted controls compile, and two Raw controls reject. No runtime/emitted or fresh other-backend result."
reverify: "Run DART_BODY_FLUENT, the managed Dart invocation and DART_BODY_FLUENT_VERIFY below; assertions describe the pre-repair state."
---

## Source and measured boundary

The generated Unicode rule-label table is not the cause. Standalone body fluents use their
separate ASCII method grammar. In `dart/lib/src/parser/spec_parser.dart:766`, the adapter
takes only `_parseFluentChainWithRemainder(trimmed).calls` and hardcodes `remainder: ''`.
The helper at line 1425 returns a suffix after the ASCII method prefix, but that suffix
never reaches body parsing or validation.

Seven direct source/AST/validation/ordinary compilation controls show:

- `.Töp()` becomes method `T` with empty arguments and source `.T`; compilation accepts.
- `.Top-Rule()` and `.Top() @unexpected` produce the same body AST as `.Top()` and compile.
- The ASCII `.Top()` and comment twin are accepted controls.
- Moving `@unexpected` to its own line retains Raw and rejects at line 3.
- `.öp()` has no ASCII method prefix, remains Raw and rejects at line 2.

These are parser/validation/compiler outcomes; accepting the AST does not establish that
the body fluent executes as a runtime helper. The fresh 25-test registry/Unicode/function
selection and neutral 806-range check pass, but do not close this additional boundary.
Existing rule-label identity evidence and unrelated identifier policies remain intact.

`DART-STARTUP-READING.2.6` already owns complete invalid-suffix retention through the two
body loops. It now also owns this earlier adapter loss. Merely forwarding its remainder
would still meet those loops' limited retention conditions, so the complete repair must
cover both boundaries without widening ASCII method syntax. The existing fourteen-case
regex/E suffix proof remains in [[dart-body-suffix-omission]]. The analogous repaired
Lua mechanism in [[lua-body-fluent-suffix-loss]] motivated these fresh Dart controls;
no new Lua result is claimed. Startup `.3/.4/.5` remain prerequisites.

## Exact managed replay

```bash
bash tools/project_data_run.sh python3 - <<'DART_BODY_FLUENT'
from pathlib import Path
Path('.linkedspec-data/scratch/dart113-body-fluent-probe.dart').write_text(r'''import 'dart:convert';
import '../../dart/lib/linkedspec_dart.dart';
void main() {
  final cases = <String, String>{
    'ascii_control': '.Top()',
    'unicode_suffix': '.Töp()',
    'hyphen_suffix': '.Top-Rule()',
    'unexpected_suffix': '.Top() @unexpected',
    'comment_control': '.Top() # comment',
    'suffix_own_line': '.Top()\n @unexpected',
    'no_ascii_prefix': '.öp()',
  };
  for (final entry in cases.entries) {
    final source = 'Top::\n ' + entry.value + '\n /x/';
    final row = <String, Object?>{'case':entry.key,'source':source};
    try {
      final spec = parseSpec(source);
      row['body'] = spec.topRule!.body.map((element) => element.toJson()).toList();
      try { validateSpec(spec); row['validation']='accepted'; }
      catch (error) { row['validation']=error.toString(); }
      try { compileSpec(spec); row['compilation']='accepted'; }
      catch (error) { row['compilation']=error.toString(); }
    } catch(error) { row['parse_error']=error.toString(); }
    print(jsonEncode(row));
  }
}
''', encoding='utf-8')
DART_BODY_FLUENT
bash tools/run_dart_project_data.sh run .linkedspec-data/scratch/dart113-body-fluent-probe.dart > .linkedspec-data/scratch/dart113-body-fluent-probe.log 2>&1
```

```bash
bash tools/project_data_run.sh python3 - <<'DART_BODY_FLUENT_VERIFY'
from pathlib import Path
import json
rows=[json.loads(line) for line in Path('.linkedspec-data/scratch/dart113-body-fluent-probe.log').read_text().splitlines()]
by={row['case']:row for row in rows}
methods={'ascii_control':'Top','unicode_suffix':'T','hyphen_suffix':'Top','unexpected_suffix':'Top','comment_control':'Top'}
rejected={'suffix_own_line':(3,'@unexpected'),'no_ascii_prefix':(2,'.öp()')}
assert len(rows)==len(by)==7 and set(by)==set(methods)|set(rejected)
for name,row in by.items():
    assert 'parse_error' not in row,(name,row)
    if name in methods:
        assert row['validation']==row['compilation']=='accepted',(name,row)
        assert row['body'][0]=={'kind':{'kind':'fluent_chain','calls':[{'method':methods[name],'args':''}]},'source':'.'+methods[name],'line':2}
        assert all(item['kind']['kind']!='raw' for item in row['body'])
    else:
        line,tail=rejected[name]
        assert row['validation']==row['compilation']=="SpecValidationException: rule 'Top': unrecognized body syntax at line "+str(line)+': '+tail
        raw=[item for item in row['body'] if item['kind']['kind']=='raw']
        assert len(raw)==1 and raw[0]['line']==line and raw[0]['kind']['text']==tail
for name in ['hyphen_suffix','unexpected_suffix','comment_control']:
    assert by[name]['body']==by['ascii_control']['body']
print('PASS 7 pre-repair controls: 3 malformed suffixes discarded/accepted, 2 accepted controls, 2 exact Raw rejections')
DART_BODY_FLUENT_VERIFY
```

Related: [[unicode-rule-label-contract]], [[dart-core-spec-parser]],
[[dart-semantic-introspection-authority-map]], [[dart-spec-lexical-boundary-defects]].
