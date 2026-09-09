---
id: dart-spec-lexical-boundary-defects
title: Dart compact fluent arguments count quoted parentheses and outer blocks count regex braces
answers:
  - why does Dart I.return with a quoted opening parenthesis return null
  - why does Dart reject a quoted closing parenthesis in a compact lifecycle call
  - does Dart outer spec parsing truncate regex closing braces
  - which task owns Dart compact fluent argument corruption
date: 2026-09-09
status: confirmed bounded defects; DART-STARTUP-READING.2.7 and .2.2.2 repair pending
tags: [dart, parser, fluent, regex, lexical, source, DART-STARTUP-READING]
evidence: "DART-STARTUP-READING.1.12 completes spec_parser.dart and reads staged registry 1-677. Ten authored-source AST/compiler/native controls establish one silent empty-call rewrite, three truncated/rejected payloads and six successful value controls; 17 existing parser/registry tests pass."
reverify: "Run DART_SPEC_LEXICAL, the managed Dart invocation and DART_SPEC_LEXICAL_VERIFY below. These assertions reproduce pre-repair behavior, not repair acceptance."
---

## Compact fluent argument corruption

`I.return("(")` becomes lifecycle code `return()` with no Raw suffix, compiles, and returns
null with `matched=false`. The braced twin `I { return("(") }` returns `"("` with
`matched=true`. A closing parenthesis inside the quoted argument instead ends extraction
too early: `I.return(")")` produces partial code `return(")` plus Raw `")` and fails
ordinary validation at line 2. Its braced twin returns `")"` successfully. Plain and
horizontally spaced `I.return("ok")` controls both return `"ok"`.

In `dart/lib/src/parser/spec_parser.dart`, the completeness scanner at line 1313 skips
quoted/regex literals, but `_extractParenContentWithEnd` at line 1459 counts every parenthesis.
`_parseFluentChainWithRemainder` at line 1425 turns failed extraction into empty arguments
and clears the remainder, explaining the silent opening-parenthesis rewrite. The separate
closing-parenthesis case retains a suffix and reaches Raw validation. `.2.7` owns full
lexical extraction and malformed-input preservation, coordinated with Rust startup `.52.2`.
The six compact/braced controls establish Dart behavior without a fresh other-backend run.

## Outer regex-brace truncation

Two additional sources, `I { return(matches("}", /}/)) }` and
`I { return(matches("}", /(})/)) }`, become partial lifecycle code ending respectively
`return(matches("}", /` and `return(matches("}", /(`. Their retained outer source ends
at the regex's `}`; Raw tails `/)) }` and `)/)) }` fail validation at line 2.
Ordinary `/x/` and quoted `"}"` pattern controls compile and execute true.

`_consumeBlockFromRest` (line 1092) uses `_scanLineForBraces` (line 1381), whose quote-aware
brace depth has no regex state. It therefore closes the outer block at the regex brace.
This is fresh authored-source evidence for existing `.2.2.2`, which already owns lifecycle
validation and auditing outer collectors. The earlier five-case programmatic/ActionIR
probe remains intact in [[dart-regex-brace-scanner-defects]]; it established independent
inner-parser/validator failures, whereas these four controls locate source truncation.
Startup `.54.3` still owns broad public/cross-backend recurrence.

All repairs remain behind startup `.3/.4/.5`. No generated/emitted carrier or fresh
other-backend outcome is inferred. Successful normal compilation precedes every reported
native value; rejected cases do not claim a runtime result.

## Exact managed replay

```bash
bash tools/project_data_run.sh python3 - <<'DART_SPEC_LEXICAL'
from pathlib import Path
Path('.linkedspec-data/scratch/dart112-lexical-probe.dart').write_text(r'''import 'dart:convert';
import '../../dart/lib/linkedspec_dart.dart';

void main() {
  final cases = <String, String>{
    'compact_plain': 'I.return("ok")',
    'compact_space': 'I.return ("ok")',
    'compact_quoted_close': 'I.return(")")',
    'braced_quoted_close': 'I { return(")") }',
    'compact_quoted_open': 'I.return("(")',
    'braced_quoted_open': 'I { return("(") }',
    'braced_regex_close': 'I { return(matches("}", /}/)) }',
    'braced_grouped_regex_close': 'I { return(matches("}", /(})/)) }',
    'braced_regex_control': 'I { return(matches("x", /x/)) }',
    'braced_quoted_brace_control': 'I { return(matches("}", "}")) }',
  };
  for (final entry in cases.entries) {
    final source = 'Top::\n ' + entry.value + '\n /x/ -> Done\nDone: /[a-z]+/\n';
    final row = <String, Object?>{'case': entry.key, 'source': source};
    try {
      final spec = parseSpec(source);
      row['body'] = spec.topRule!.body.map((element) => element.toJson()).toList();
      try {
        final compiled = compileSpec(spec);
        row['compiled'] = true;
        final result = LinkedSpecRuntimeEngine(compiled).parse('xhello');
        row['value'] = result.value;
        row['matched'] = result.matched;
      } catch (error) {
        row['error'] = error.toString();
      }
    } catch (error) {
      row['parse_error'] = error.toString();
    }
    print(jsonEncode(row));
  }
}
''', encoding='utf-8')
DART_SPEC_LEXICAL
bash tools/run_dart_project_data.sh run .linkedspec-data/scratch/dart112-lexical-probe.dart > .linkedspec-data/scratch/dart112-lexical-probe.log 2>&1
```

```bash
bash tools/project_data_run.sh python3 - <<'DART_SPEC_LEXICAL_VERIFY'
from pathlib import Path
import json
rows=[json.loads(line) for line in Path('.linkedspec-data/scratch/dart112-lexical-probe.log').read_text().splitlines()]
by={row['case']:row for row in rows}
controls={'compact_plain':'ok','compact_space':'ok','braced_quoted_close':')','braced_quoted_open':'(','braced_regex_control':True,'braced_quoted_brace_control':True}
failures={
    'compact_quoted_close':('return(")', '")'),
    'braced_regex_close':('return(matches("}", /', '/)) }'),
    'braced_grouped_regex_close':('return(matches("}", /(', ')/)) }'),
}
assert len(rows)==len(by)==10 and set(by)==set(controls)|set(failures)|{'compact_quoted_open'}
for name,row in by.items():
    assert 'parse_error' not in row,(name,row)
    first=row['body'][0]
    assert first['kind']['kind']=='code_block' and first['kind']['lifecycle']=='I' and first['line']==2
    if name in controls:
        assert row['compiled'] is True and row['matched'] is True and row['value']==controls[name] and 'error' not in row,(name,row)
        assert all(item['kind']['kind']!='raw' for item in row['body'])
    elif name in failures:
        code,tail=failures[name]
        assert first['kind']['code']==code,(name,row)
        raw=[item for item in row['body'] if item['kind']['kind']=='raw']
        assert len(raw)==1 and raw[0]['kind']['text']==tail and raw[0]['line']==2,(name,row)
        assert row['error']=="SpecValidationException: rule 'Top': unrecognized body syntax at line 2: "+tail
        assert 'compiled' not in row and 'value' not in row,(name,row)
    else:
        assert first['kind']['code']=='return()' and row['compiled'] is True and row['matched'] is False and row['value'] is None and 'error' not in row,(name,row)
        assert all(item['kind']['kind']!='raw' for item in row['body'])
print('PASS 10 pre-repair controls: 6 successful values, 1 silent empty-call rewrite, 3 truncated/rejected payloads')
DART_SPEC_LEXICAL_VERIFY
```

Related: [[dart-core-spec-parser]], [[dart-body-suffix-omission]],
[[rust-body-parser-lexical-boundary-defects]], [[standalone-lifecycle-block-audit]].
