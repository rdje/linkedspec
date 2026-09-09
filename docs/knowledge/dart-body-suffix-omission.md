---
id: dart-body-suffix-omission
title: Dart body parsing silently discards unsupported suffixes after regex and lifecycle E elements
answers:
  - why does Dart accept unexpected text after a regex in a spec
  - why does Dart accept an invalid suffix after a lifecycle E block
  - does Dart preserve every unconsumed body suffix for validation
  - which task owns Dart body suffix omission
date: 2026-09-09
status: confirmed bounded defect; repair pending DART-STARTUP-READING.2.6
tags: [dart, parser, validation, source, diagnostics, DART-STARTUP-READING]
evidence: "DART-STARTUP-READING.1.11 reads spec_parser.dart 1-744 and runs fourteen parseSpec/validateSpec/normal compileSpec controls. Four invalid regex/E tails disappear and compile; four valid controls compile; six invalid own-line/I/edge controls retain Raw and reject. No source repair or runtime/carrier/other-backend proof."
reverify: "Run DART_BODY_SUFFIX, the managed Dart invocation and DART_BODY_SUFFIX_VERIFY below. Assertions describe the pre-repair defect, not repair acceptance."
---

## Measured boundary

Four malformed sources lose `@unexpected`: regex and lifecycle-E blocks, each on the rule
header or on a body line. Their ASTs retain the valid element but contain no Raw node for
the invalid text; `validateSpec` and ordinary `compileSpec` both accept. For example,
`Top:: /x/ @unexpected` produces the same body AST as `Top:: /x/`.

Moving the invalid suffix to its own line preserves a Raw node and rejects at line 3.
Explicit lifecycle-I header/body twins, shorthand lifecycle-I body and malformed action-edge
header/body twins also retain Raw and reject, with exact lines in the replay. Valid regex
header/body, comment and lifecycle-E controls pass. Four accepted malformed cases, four valid
controls and six rejected malformed controls total fourteen.

`_parseInlineBody` (`dart/lib/src/parser/spec_parser.dart:343`) and `_parseBodyElements`
(line 460) break when `_parseSingleElement` cannot consume the next suffix. They preserve that
suffix only if no element has been parsed, it begins with an edge token, or
`_isUnsupportedLifecycleRemainder` (line 512) identifies an I block followed by a non-header
remainder. Regex and E successors do not satisfy these conditions. The missing text never
reaches `_checkMalformedRawBodyLines` (`dart/lib/src/validation/spec_validator.dart:320`),
which rejects every retained Raw node. `compileSpec` defaults to source validation
(`dart/lib/src/compiler/compiled_spec.dart:151`); default validation cannot recover lost text.

This is distinct from the existing Rust header-only lifecycle-I defect at startup `.53`:
Dart's tested I twins reject, while its regex/E twins fail on both layouts. The existing
standalone lifecycle rule-header exception protects typed-diagnostic precedence and must
be reconciled when repairing general suffix retention. `DART-STARTUP-READING.2.6` owns
the repair after startup `.3/.4/.5`, coordinated with that Rust owner and lifecycle contract.
No fresh Rust, Perl, Julia, Lua, runtime invocation or generated/emitted result is inferred.

## Exact managed replay

The temporary diagnostic is task-owned, ignored and stored on the repository volume.
Its complete source is reproduced here so the result survives scratch cleanup.

```bash
bash tools/project_data_run.sh python3 - <<'DART_BODY_SUFFIX'
from pathlib import Path
Path('.linkedspec-data/scratch/dart111-body-suffix-probe.dart').write_text(r'''import 'dart:convert';
import '../../dart/lib/linkedspec_dart.dart';

void main() {
  final cases = <String, String>{
    'regex_header_control': 'Top:: /x/',
    'regex_body_control': 'Top::\n /x/',
    'regex_header_suffix': 'Top:: /x/ @unexpected',
    'regex_body_suffix': 'Top::\n /x/ @unexpected',
    'regex_body_comment': 'Top::\n /x/ # comment',
    'regex_suffix_own_line': 'Top::\n /x/\n @unexpected',
    'explicit_i_header_suffix': 'Top:: I { return("ok") } @unexpected\n /x/',
    'explicit_i_body_suffix': 'Top::\n I { return("ok") } @unexpected\n /x/',
    'bare_i_body_suffix': 'Top::\n { return("ok") } @unexpected\n /x/',
    'e_header_control': 'Top:: E { return("ok") }\n /x/',
    'e_header_suffix': 'Top:: E { return("ok") } @unexpected\n /x/',
    'e_body_suffix': 'Top::\n E { return("ok") } @unexpected\n /x/',
    'action_header_suffix': 'Top:: -> Child @unexpected\nChild: /x/',
    'action_body_suffix': 'Top::\n -> Child @unexpected\nChild: /x/',
  };
  for (final entry in cases.entries) {
    final row = <String, Object?>{'case': entry.key, 'source': entry.value};
    try {
      final spec = parseSpec(entry.value);
      row['body'] = spec.topRule!.body.map((element) => element.toJson()).toList();
      try {
        validateSpec(spec);
        row['validation'] = 'accepted';
      } catch (error) {
        row['validation'] = error.toString();
      }
      try {
        compileSpec(spec);
        row['compilation'] = 'accepted';
      } catch (error) {
        row['compilation'] = error.toString();
      }
    } catch (error) {
      row['parse_error'] = error.toString();
    }
    print(jsonEncode(row));
  }
}
''', encoding='utf-8')
DART_BODY_SUFFIX
bash tools/run_dart_project_data.sh run .linkedspec-data/scratch/dart111-body-suffix-probe.dart > .linkedspec-data/scratch/dart111-body-suffix-probe.log 2>&1
```

```bash
bash tools/project_data_run.sh python3 - <<'DART_BODY_SUFFIX_VERIFY'
from pathlib import Path
import json
rows=[json.loads(line) for line in Path('.linkedspec-data/scratch/dart111-body-suffix-probe.log').read_text().splitlines()]
by={row['case']:row for row in rows}
controls={'regex_header_control','regex_body_control','regex_body_comment','e_header_control'}
dropped={'regex_header_suffix','regex_body_suffix','e_header_suffix','e_body_suffix'}
rejected={'regex_suffix_own_line':3,'explicit_i_header_suffix':1,'explicit_i_body_suffix':2,'bare_i_body_suffix':2,'action_header_suffix':1,'action_body_suffix':2}
assert len(rows)==len(by)==14 and set(by)==controls|dropped|set(rejected)
for name,row in by.items():
    assert 'parse_error' not in row,(name,row)
    if name in controls|dropped:
        assert row['validation']==row['compilation']=='accepted',(name,row)
        assert all(item['kind']['kind']!='raw' for item in row['body']),(name,row)
    else:
        assert row['validation']==row['compilation'],(name,row)
        assert 'unrecognized body syntax at line '+str(rejected[name])+':' in row['validation'],(name,row)
        raw=[item for item in row['body'] if item['kind']['kind']=='raw']
        assert len(raw)==1 and raw[0]['line']==rejected[name] and '@unexpected' in raw[0]['kind']['text'],(name,row)
for malformed,control in [
    ('regex_header_suffix','regex_header_control'),
    ('regex_body_suffix','regex_body_control'),
    ('e_header_suffix','e_header_control'),
]:
    assert by[malformed]['body']==by[control]['body']
assert [item['kind'] for item in by['e_body_suffix']['body']]==[item['kind'] for item in by['e_header_control']['body']]
print('PASS 14 pre-repair controls: 4 valid, 4 suffixes dropped/accepted, 6 retained/rejected with exact lines')
DART_BODY_SUFFIX_VERIFY
```

Related: [[dart-core-spec-parser]], [[dart-frontend-validation]],
[[standalone-lifecycle-block-audit]], [[rust-body-parser-lexical-boundary-defects]].

## 2026-09-09 — standalone fluent adapter joins the same repair owner

Seven additional controls under reading .1.13 identify an earlier discarded remainder in
the standalone fluent adapter. [[dart-body-fluent-suffix-loss]] retains exact source,
AST/validation/compiler outcomes and reproduction. Existing .2.6 now covers that adapter
as well as both body loops; the fourteen original regex/E controls above remain unchanged.
