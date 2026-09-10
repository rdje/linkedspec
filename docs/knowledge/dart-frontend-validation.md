---
id: dart-frontend-validation
title: Dart frontend validation checks parsed source ASTs before compiler/runtime work
answers:
  - does Dart validate parsed spec ASTs
  - where is the Dart spec validator
  - what does validateSpec check
  - does Dart strict syntax exist
  - does Dart reject duplicate labels
  - does Dart reject undefined edge targets
  - does Dart validate user function registry records
date: 2026-07-09
status: current
tags: [dart, validation, parser, ast, strict-syntax]
evidence: "DART-BACKEND-PARITY.2.3 adds dart/lib/src/validation/spec_validator.dart and dart/test/spec_validator_test.dart. Tests cover focused validation failures, strictSyntax unused-rule rejection, all checked-in specs/*.spec in non-strict mode, and rule-only corpus input.spec files."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/spec_validator_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings"
---

Dart `validateSpec(...)` lives in `dart/lib/src/validation/spec_validator.dart`
and is exported from `dart/lib/linkedspec_dart.dart`. It validates parsed
source ASTs produced by `parseSpec(...)` or assembled by later frontend stages.

Current checks cover top-rule presence, duplicate rule labels, duplicate user
function names, function registry collisions and parameter shape, malformed raw
body lines, mixed action/blind-call edge families, grouped action targets that
lack a shared block, undefined targets, out-of-range regex-slot references, and
lightweight regex structural errors.

`validateSpec(spec, strictSyntax: true)` adds strict unused-rule rejection. The
validator does not parse top-level `fn` definitions from source and does not
execute helper/action or runtime semantics.

Related facts: [[dart-core-spec-parser]], [[dart-backend-scaffold-package]],
[[rust-strict-syntax-validation]].

## 2026-09-10 — complete validator reading and reconstructed selector gap

`DART-STARTUP-READING.1.35` completes all 1,072 validator lines. The tail
checks edge ownership/targets, shared blocks, directive uniqueness/conflicts,
loop/seek/action eligibility, named and numeric slots, lightweight regex
structure and authored-edge-only strict unused rules. Entry selection and
authored top markers give no strict exemption, as recorded in
[[dart-root-rule-selection-core]]. Regex structure is a preliminary check,
not execution of the complete backend regex dialect.

The named selector path does not require a name before nullable slot lookup.
Ten reconstructed controls establish two named/null acceptances that select
anonymous regexes, plus six valid/rejecting controls and two additional accepted
provenance shapes for compatibility census. Exact source causes, descriptor
identity, runtime values and gated repair .2.23 are in
[[dart-null-named-selector-validation-gap]]. All 35 selected validator/action/
root/gap/duplicate tests pass; those existing tests do not cover the new defect.
