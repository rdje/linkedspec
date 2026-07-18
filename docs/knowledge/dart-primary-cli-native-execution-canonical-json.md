---
id: dart-primary-cli-native-execution-canonical-json
title: Dart primary CLI uses native execution and direct canonical JSON values
answers:
  - does the Dart primary CLI execute through LinkedSpecRuntimeEngine
  - does Dart primary CLI return RuntimeParseResult value or output
  - are Dart primary CLI nested JSON keys canonical
  - does Dart primary CLI support top rule after global parse mode removal
  - how many shared primary CLI cases does Dart pass after 1.5.3.2
date: 2026-07-10
status: current
tags: [dart, cli, runtime, json, unicode, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.5.3.2 composes compiled requests through LinkedSpecRuntimeEngine and historically reaches 41/61; .1.5.3.3 adds canonical trace and reaches 61/61. Rule-local cursor .9.1.5.5 later removes global mode while retaining top-rule selection/direct values and reaches 63/63 twice."
reverify: "cd dart && dart test test/primary_cli_test.dart && cd .. && perl tools/run_cli_conformance.pl --display-command 'dart run bin/linkedspec_dart.dart' --case success_file_source_file_input_nested_json --case success_explicit_top_rule --case success_input_file_unicode_bom_newlines -- dart --packages={{REPO_ROOT}}/dart/.dart_tool/package_config.json {{REPO_ROOT}}/dart/bin/linkedspec_dart.dart"
---

After strict source compilation and deferred input loading, the Dart primary adapter constructs
`LinkedSpecRuntimeEngine` without a global cursor option and calls `execute(...)` with the optional entry rule.
Every entered rule derives policy from its family. It serializes `RuntimeParseResult.value`, the direct selected-rule value. It deliberately does not use
the legacy `RuntimeParseResult.output` projection, which wraps that value as `[value]` for corpus compatibility.

Canonical rendering recursively preserves array order, sorts every map level by stringified key, encodes compact
JSON as UTF-8, and appends exactly one newline. Inline/file/named source, literal/file input, explicit entry, both
parse modes, nested maps, composed/decomposed Unicode, leading input U+FEFF, and CRLF/LF are exercised by the
unchanged shared fixtures. Backend exceptions and JSON encoding failures stay behind the stable parser-invocation
failure heading.

The 11 direct result cases pass in default and POSIX environments. The quiet-trace case also passes because it
requires no records, advancing the full unchanged Dart baseline from 29/61 to 41/61. The remaining 20 cases are
only ADR `0024` canonical trace records, sinks, reset/append, emoji, escaping, byte counts, and traced failures;
`.1.5.3.3` has since closed them at 61/61.

Related facts: [[dart-primary-cli-boundary]], [[canonical-primary-cli-trace-protocol]],
[[native-in-memory-backend-contract]], [[user-observable-backend-cli-parity-contract]],
[[dart-canonical-primary-cli-trace]].
