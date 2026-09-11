---
id: dart-component-gate-sdk-compatibility
title: Dart component verification exposes formatting drift and deprecated regex adapters
answers:
  - why does the complete Dart gate currently fail
  - which Dart files fail formatting with SDK 3.13.3
  - why does strict Dart analysis report deprecated_implement
  - are the Dart component gate failures fixed or task owned
  - did the complete Dart gate pass at reading closeout
date: 2026-09-11
status: confirmed failures; repairs pending under DART-STARTUP-READING.2.24 and .2.25
tags: [dart, ci, sdk, formatter, regex, startup, defect]
evidence: "At physical reading checkpoint 1f8f226f, Dart 3.13.3/dart_style 3.1.13 reports six changed test files and exits 1. Strict analysis separately exits 2 at matching.dart:725:42 and 1173:47 because SDK RegExp/RegExpMatch implementation is deprecated. Remaining stages independently pass 461 tests,25-owner / 47-package storage,CLI 66 twice and corpus 105. Source bytes are restored exactly; full gate remains failed."
reverify:
  - "bash tools/run_dart_project_data.sh --version && bash tools/run_dart_project_data.sh format --version"
  - "bash tools/run_dart_project_data.sh format --output=none --set-exit-if-changed --language-version=3.9 dart"
  - "cd dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings"
---

# Exact failure and repair ownership

`DART-STARTUP-READING.3.1` ran the unchanged `tools/run_dart_local.sh`.
Its first format stage returned 1 after writing six committed tests. The gate uses
`format --set-exit-if-changed .` with the formatter's default write output. The
diff contains 249 insertions / 277 deletions; it does not represent an authored change.
Original and formatted bytes were retained in repository-local diagnostics before
restoring exactly those six files from HEAD. An attempted remaining-stage diagnostic
initially re-entered the canonical script through the managed-run launcher and
repeated the same six edits; all six output hashes matched and all original hashes
were restored again. The corrected diagnostic names itself as the managed entrypoint.
There is no current tracked Dart source delta.

A non-writing replay with explicit language 3.9 returns 1 for the same six files.
The installed SDK is 3.13.3, formatter 3.1.13, and project package metadata already
records generator 3.13.3 / language 3.9. This is not the stale-metadata wait described in
[[dart-sdk-local-metadata-refresh]]. We have not established which historical SDK
first introduced the layout difference. The current formatter defaults to automated
trailing commas and changes wrapping/indentation around calls and callback bodies.
An analyzer 12.1.0 token/comment comparison retains every record after excluding
trailing commas immediately before closing delimiters:5287,5859,1702,2865,3238,2194
records respectively. String token contents remain exact. This characterizes the
saved formatter diff; the committed source remains unchanged.

`.2.24.1` owns the six formatting corrections after startup gates. `.2.24.2`
separately owns a non-writing format gate, with failing/passing fixture byte-preservation
proof and canonical infrastructure admission. Neither change is implemented here.

| Test basename under dart/test | Original bytes / SHA-256 | Formatted bytes / SHA-256 |
| --- | --- | --- |
| `callable_codeblock_literal_contract_test.dart` | 35158 / `c843e5456580b75c5bbe6283a22b45835c8fd578de4b7a817a9936751658fa6c` | 34891 / `beb31162a4d204b0a74c6d1f7c3c694ad37b8bd75bad6c9f7f64f9d2e65e8c44` |
| `inter_match_gap_capture_contract_test.dart` | 45826 / `b2b49d1abad130045ec8449bc8cd1c2a8d6012fddc1b7d45c4f29d7757636a94` | 45832 / `6b0254543ed7dbae6583ec961d5cdaee24b2036c9664fa198035f01d50f42d73` |
| `recursive_observation_contract_test.dart` | 13325 / `cc4cac71e3924e77afd5f4c538a3efefc0323089aad13816dd762e87dca26249` | 13280 / `1248159031e099a742918cb06cff73f7f910195d44488fc8fc814c475824da06` |
| `repeated_action_result_contract_test.dart` | 15600 / `4d98fb7a5c2a30f1a4e1473e880e6e9fbcb1a615220a70daea22f4c9964cd11e` | 15592 / `5c3fa2a0acbf34073dc5080f4c8a87e3a755ce81144788e8ca8403ee85e361bd` |
| `source_emitter_test.dart` | 27123 / `ebfa150e20c7767b056a5bfa12a8e76bbef7ba97958f709e8b2657ddbd22bdad` | 26923 / `e61c919c9056d929147fae2b846f5945f6677d829658ad395671deefd5850227` |
| `unicode_rule_label_identity_routes_test.dart` | 13017 / `7cb4c7bf8d359ff5bcc6b5c4bc47ac857a90e3699f73d4e572c023652342b074` | 12837 / `831ba09bef1a7e5054f9bcd1f9f382bf1de478b8cc13ee0cf14243c83ba87fe6` |


# Strict analyzer failure

Running the unchanged analyzer command separately returns 2 with exactly:

- `lib/src/runtime/matching.dart:725:42`: `_StructuralRegExp implements RegExp`,
  diagnostic `deprecated_implement`.
- `lib/src/runtime/matching.dart:1173:47`: `_StructuralRegExpMatch implements RegExpMatch`,
  the same diagnostic.

The required installed Dart SDK was inspected read-only: derive the executable from
`shutil.which('dart')`, resolve its symlink, then locate `lib/core/regexp.dart`
relative to the SDK root. It marks both interfaces with `@Deprecated.implement` at
lines 216/475; the messages describe future final classes and suggest `Pattern`/`Match`.
No SDK data was copied, changed or cached outside the repository. The precise
warning mechanism is these implementation clauses against the installed SDK
annotations; no current parser execution failure or future migration date is inferred.

`.2.25.1-.3` own public/internal caller and signature inventory, a compatible adapter
migration, and full carrier/gate admission. Preserve options, pattern identity,
capture names/spans, ordered alternatives, zero progress, generated callers and staged
provenance. Do not suppress diagnostics or downgrade the SDK. A necessary public
signature change requires a separately explicit contract decision.

# Passing diagnostics are distinct from complete-gate success

After consuming each early failure, a repository-local diagnostic replay ran the
remaining stages with their original commands and order, retaining the gate's managed
storage environment. It explicitly reported the failed format/analyzer stages and
never printed the complete-gate success message. The final result is:

| Check | Result |
| --- | --- |
| Unchanged complete Dart gate | FAIL at formatter, exit 1 |
| Strict analyzer run independently | FAIL, two warnings, exit 2 |
| Ordinary package discovery | PASS 461 tests |
| Storage oracle after the complete package tests | PASS 25 temporary owners / 47 locked offline packages |
| Primary/corpus help and one-fixture smoke | PASS |
| Default primary CLI | PASS 66/66 |
| POSIX primary CLI | PASS 66/66 |
| Full corpus | PASS 105/105 |
| Dormant private authority consumer | Four groups passed separately in committed .1.55; not ordinary discovery |

Do not report the complete component gate green. No PGEN/RGX build or canonical CI
ran. All jobs finished and source hashes match the physical reading checkpoint.
[[dart-reading-commit-closeout-audit]] records the passing source/commit audit and
the unresolved, separately owned reading-closeout decision. Existing runtime defects
remain pending even where these regression suites pass.
