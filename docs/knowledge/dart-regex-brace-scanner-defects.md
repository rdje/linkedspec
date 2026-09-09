---
id: dart-regex-brace-scanner-defects
title: Dart grouped regex braces break action scanning and lifecycle balance validation
answers:
  - "why does Dart accept a grouped regex alone but reject it in an attached if"
  - "why does Dart count a regex closing brace as an unmatched lifecycle brace"
  - "which tasks own Dart regex brace scanner repairs"
  - "does a programmatic Dart spec bypass regex brace validation failure"
date: 2026-09-09
status: confirmed defects; DART-STARTUP-READING.2.2.1/.2.2.2 pending behind startup gates
tags: [dart, actionir, regex, scanner, validation, startup, defect]
evidence: "DART-STARTUP-READING.1.5 completes the action scanner tail and probes five public AST cases, four through programmatically constructed SpecFile compilation/execution. Standalone /(})/ is a regex; attached-if use becomes raw_perl. Lifecycle balance rejects both /}/ and /(})/ without involving the outer source collector. Ordinary grouped-regex and quoted-pattern controls execute true. All 55 selected existing tests pass despite the gaps."
reverify: "Replay the DART_REGEX_PROBE recipe below from the repository root; its current failures are observations, not repaired acceptance criteria."
---

# Dart regex-brace scanner defects

Two independent boundaries fail. The inner ActionIR parser accepts `/(})/`
as a regex with pattern `(})` in isolation. Inside
`if(true) { return(matches("}", /(})/)) }`, it returns `raw_perl` instead of
`control_if`. The `/}/`, `/(x)/` and quoted-pattern controls retain typed control
nodes. This is an action-parser failure before runtime matching.

`dart/lib/src/action/action_parser.dart:2523` classifies a slash followed by
`(` as not starting a regex. The delimiter walker at line 2019 consequently
counts the grouped regex's `}` as the attached block's closing delimiter;
complete-block recognition fails. The repair must preserve symbolic division
calls while distinguishing complete regex literals, not simply treat every
slash as regex syntax. `.2.2.1` owns that work and surrounding lexical controls.

A second probe builds a normal public `SpecFile` with a lifecycle `E` payload,
bypassing the outer `.spec` source collector. Normal compilation still rejects
both regex-brace patterns as one unmatched close. At
`dart/lib/src/validation/spec_validator.dart:356`, `_braceDepthDelta` tracks
quotes/escapes and braces but no regex state. `_checkBalancedLifecycleBlocks`
uses it on the lifecycle payload. `.2.2.2` owns this validator repair plus a
bounded audit of relevant outer collectors before claiming source-file coverage.
The validator excerpt at lines 322–398 is diagnostic reading only, not full-file
startup credit. No normal regex-brace runtime success is claimed while this gate fails.

| Input/control | Public ActionIR result | Programmatic spec result |
| --- | --- | --- |
| standalone `/(})/` | `regex`, no diagnostics | not executed as a spec |
| attached `matches("}", /}/)` | `control_if`, no diagnostics | unmatched close validation error |
| attached `matches("}", /(})/)` | `raw_perl` diagnostic | unmatched close validation error |
| attached `matches("x", /(x)/)` | `control_if`, no diagnostics | true |
| attached `matches("}", "(})")` | `control_if`, no diagnostics | true |

Each attached form is inside `if(true) { return(...) }`. The controls show
that the grouped pattern itself is supported when represented as a string and
that ordinary regex groups are supported. They do not prove all regex syntax,
outer-source collection, emitted carriers or other backends.

Existing startup `.54.1/.54.2` own the independently observed Perl/Rust outer
collector defects. `.54.3` remains the single broad public/recurrence closeout
and now coordinates the concrete Dart owners. These are pending repairs after
startup `.3/.4/.5`; the passing 55-test selection does not close them.

## Reproduce the observed state

```sh
bash tools/project_data_run.sh python3 - <<'DART_REGEX_PROBE'
from pathlib import Path
scratch = Path('.linkedspec-data/scratch')
scratch.mkdir(parents=True, exist_ok=True)
(scratch / 'dart15-regex-probe.dart').write_text('import \'dart:convert\';\nimport \'../../dart/lib/linkedspec_dart.dart\';\nvoid main() {\n  for (final source in [\n    r\'/(})/\',\n    r\'if(true) { return(matches("}", /}/)) }\',\n    r\'if(true) { return(matches("}", /(})/)) }\',\n    r\'if(true) { return(matches("x", /(x)/)) }\',\n    r\'if(true) { return(matches("}", "(})")) }\',\n  ]) {\n    final expr = parseActionExpression(source);\n    final row = <String,Object?>{\'source\': source, \'ast\': expr.toJson(),\n      \'resolution\': resolveActionExpressionContracts(expr).toJson()};\n    if (source.startsWith(\'if\')) {\n      final spec = SpecFile(rules: [Rule(\n        header: const RuleHeader(label: \'Top\', isTop: true,\n          mode: RuleMode.defaultMode, rest: \'\', line: 1),\n        body: [BodyElement(kind: CodeBlockBodyElementKind(lifecycle: \'E\', code: source),\n          source: source, line: 2)],\n      )]);\n      try { row[\'value\'] = LinkedSpecRuntimeEngine(compileSpec(spec)).parse(\'\').value; }\n      catch(e) { row[\'error\'] = e.toString(); }\n    }\n    print(jsonEncode(row));\n  }\n}\n')
DART_REGEX_PROBE
(cd dart && bash ../tools/run_dart_project_data.sh run ../.linkedspec-data/scratch/dart15-regex-probe.dart)
```

Related: [[dart-actionir-ast-parser]], [[dart-frontend-validation]],
[[rust-body-parser-lexical-boundary-defects]], [[bootstrap-conditional-regex-delimiters]].

## 2026-09-09 — authored-source outer collector now measured

Reading `DART-STARTUP-READING.1.12` completes the outer spec parser. Four additional
authored-source controls now establish that /}/ and /(})/ truncate lifecycle-I payloads
at the regex brace and retain Raw tails, causing ordinary validation failure. Ordinary
regex and quoted-brace twins execute true. `_consumeBlockFromRest` at spec_parser.dart:1092
calls the quote-aware but regex-unaware `_scanLineForBraces` at line 1381.
Existing .2.2.2 now owns this confirmed collector mechanism as well as lifecycle validation;
the earlier five-case evidence above remains unchanged and independently scoped.
[[dart-spec-lexical-boundary-defects]] preserves the exact new replay. This resolves the
earlier outer-source uncertainty for these two patterns, without emitted/other-backend proof.
