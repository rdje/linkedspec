---
id: dart-primary-cli-boundary
title: Dart has the exact shared primary CLI boundary and strict UTF-8 phase loading
answers:
  - does Dart reject primary CLI corpus subcommands
  - does Dart primary CLI use exact case sensitive options
  - how does Dart primary CLI load strict UTF-8 source and input
  - does Dart preserve a UTF-8 BOM in source and input files
  - how many shared primary CLI cases does Dart pass after 1.5.3.1
  - why did the Dart staged function parser reject ordinary specs
date: 2026-07-10
status: current
tags: [dart, cli, utf8, parser, loading, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.5.3.1 replaces the corpus primary boundary and reaches 29/61; .2 direct results reach 41/61 and .3 canonical trace reaches 61/61."
reverify: "cd dart && dart analyze --fatal-infos --fatal-warnings && dart test test/primary_cli_test.dart test/user_function_definition_parser_test.dart && cd .. && bash tools/run_dart_local.sh && rg -n '29/29|FUTURE-PARITY-BACKLOG.1.5.3.1' docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

`dart/bin/linkedspec_dart.dart` now owns only ADR `0023`'s primary parser interface. Its manual parser accepts the
same source/input/top-rule/trace options as the shared commands, rejects the retired `--parse-mode` flag with
targeted migration guidance, rejects positionals, subcommands,
abbreviations, case drift, undocumented negations, invalid values, and selector conflicts, and renders exact help
and usage bytes for `dart run bin/linkedspec_dart.dart`. Corpus validation/execution remains under
`dart/bin/corpus_runner.dart`.

Named source resolution checks the current working directory's exact name, then its `.spec` suffix, then the
repository `specs/` fallback. Source files decode before compilation; input files remain deferred until compilation
succeeds. Both use raw bytes plus strict UTF-8 decoding, preserve code points, normalization, BOM, CRLF/LF, and
reject malformed bytes in the owning phase. Dart's frontend calls `String.trim()`, which would treat leading
U+FEFF as whitespace, so the CLI rejects a preserved leading source BOM before the frontend can erase it; input
BOM remains data.

The audit also exposed that `parseSpecWithStagedUserFunctionDefinitions(...)` treated the ordinary zero-function
case as a parser error. The reusable function-definition extractor now returns an empty definition list when its
spec-driven parser matches no `fn`; the ordinary `.spec` parser then handles the unchanged source. Function-bearing
sources retain the existing staged path. A native regression locks both cases.

The exact boundary/loading/failure subset is 29/29 under default and `POSIXLY_CORRECT=1`. The remaining 32 shared
cases were 11 successful direct result cases plus 21 trace-tagged cases. `.1.5.3.2` now closes all direct results
and the silent quiet-trace case at 41/61; `.1.5.3.3` closes the remaining 20 trace cases at 61/61. Cursor option
removal `.9.1.5.5` advances the expanded manifest to exact 63/63 in both environments.

Related facts: [[dart-primary-cli-mechanism-audit]], [[primary-cli-strict-utf8-text-contract]],
[[user-observable-backend-cli-parity-contract]], [[dart-local-verification-gate]], [[dart-specific-cli]],
[[dart-primary-cli-native-execution-canonical-json]], [[dart-canonical-primary-cli-trace]].
