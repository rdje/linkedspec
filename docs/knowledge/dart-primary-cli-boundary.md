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
evidence: "FUTURE-PARITY-BACKLOG.1.5.3.1 replaces the corpus primary boundary, corrects no-function staged parsing, and passes the exact 29-case boundary/loading/failure subset in default and POSIX environments while the full Dart gate remains 147 tests plus 99/99 corpus."
reverify: "cd dart && dart analyze --fatal-infos --fatal-warnings && dart test test/primary_cli_test.dart test/user_function_definition_parser_test.dart && cd .. && bash tools/run_dart_local.sh && rg -n '29/29|FUTURE-PARITY-BACKLOG.1.5.3.1' docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

`dart/bin/linkedspec_dart.dart` now owns only ADR `0023`'s primary parser interface. Its manual parser accepts the
same source/input/top-rule/parse-mode/trace options as the shared commands, rejects positionals, subcommands,
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
cases are 11 successful direct result cases plus 21 canonical-trace cases owned by `.1.5.3.2` and `.1.5.3.3`.

Related facts: [[dart-primary-cli-mechanism-audit]], [[primary-cli-strict-utf8-text-contract]],
[[user-observable-backend-cli-parity-contract]], [[dart-local-verification-gate]], [[dart-specific-cli]].
