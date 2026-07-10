---
id: dart-primary-cli-mechanism-audit
title: Dart primary CLI work is an adapter replacement over reusable native seams
answers:
  - what Dart APIs can the shared primary LinkedSpec CLI reuse
  - why does the Dart primary CLI fail the shared 61 case suite
  - does Dart already have direct top rule result execution
  - how is FUTURE-PARITY-BACKLOG 1.5.3 split
  - does the Dart corpus runner remain available
date: 2026-07-10
status: current
tags: [dart, cli, parser, runtime, utf8, json, trace, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.5.3.0 audits the corpus-oriented primary command, records its 0/61 shared baseline, and splits boundary, execution, trace, and closeout leaves without changing Dart behavior."
reverify: "sed -n '1,240p' dart/lib/src/cli/linkedspec_dart_cli.dart; rg -n 'parseSpecWithStagedUserFunctionDefinitions|compileSpec|class LinkedSpecRuntimeEngine|RuntimeParseResult execute|_canonicalJson' dart/lib; perl tools/run_cli_conformance.pl --display-command 'dart run bin/linkedspec_dart.dart' -- dart --packages={{REPO_ROOT}}/dart/.dart_tool/package_config.json {{REPO_ROOT}}/dart/bin/linkedspec_dart.dart"
---

At the `.1.5.3.0` audit, `dart/bin/linkedspec_dart.dart` was a corpus-oriented command rather than ADR `0023`'s
primary parser command. It accepted `corpus`, `--corpus`, `--execute`, and fixture selectors; no arguments printed
scaffold status and exited `0`; usage failures exited `64`. The unchanged shared process suite therefore passed
0/61 cases. `dart/bin/corpus_runner.dart` remains the correct separate owner for those developer workflows.

The language pipeline does not need to be reimplemented in the adapter. Dart already exports
`parseSpecWithStagedUserFunctionDefinitions`, `compileSpec` with validation, and `LinkedSpecRuntimeEngine` with a
constructor-level global parse mode and per-call optional top rule. `RuntimeParseResult.value` is the direct
selected-rule value; its legacy `output` projection is `[value]` and must not be used by the primary command.
The corpus runner also contains recursive key-sorted JSON logic that can be promoted to an appropriate reusable
adapter seam without giving the CLI ownership of language semantics.

The remaining work is split into exact process arguments/help/loading (`.1`), native execution composition plus
canonical results and stable failures (`.2`), ADR `0024` canonical adapter trace independent of Dart's rich native
trace (`.3`), and unchanged 61-case default/POSIX plus recurring-gate closeout (`.4`). Strict UTF-8 loading needs
an explicit raw-byte boundary so valid text, including a leading U+FEFF, is preserved and malformed bytes remain
in their owning compilation or input-load phase.

Related facts: [[dart-specific-cli]], [[native-in-memory-backend-contract]],
[[primary-cli-strict-utf8-text-contract]], [[canonical-primary-cli-trace-protocol]],
[[neutral-cli-fixture-runner]], [[user-observable-backend-cli-parity-contract]].
