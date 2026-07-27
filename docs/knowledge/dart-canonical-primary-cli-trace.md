---
id: dart-canonical-primary-cli-trace
title: Dart primary CLI implements the independent canonical trace protocol
answers:
  - does Dart primary CLI implement canonical trace
  - are Dart primary CLI trace records separate from native trace
  - does Dart primary trace count UTF-8 bytes
  - does Dart primary trace support route mirror reset append and emoji
  - how many shared CLI cases does Dart pass after 1.5.3.3
date: 2026-07-10
status: current
tags: [dart, cli, trace, utf8, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.5.3.3 adds an adapter-local ADR 0024 trace and passes all 61 unchanged cases in default and POSIX environments; rich LinkedSpecTraceEmitter behavior remains independent."
evidence_update_2026_07_18_cursor: "FUTURE-PARITY-BACKLOG.9.1.5.5 removes the global parse_mode request field while preserving every unrelated trace byte; the expanded shared matrix passes 63/63 in both environments."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/primary_cli_test.dart && cd .. && perl tools/run_cli_conformance.pl --display-command 'bash ../tools/run_dart_project_data.sh run bin/linkedspec_dart.dart' -- bash {{REPO_ROOT}}/tools/run_dart_project_data.sh --packages={{REPO_ROOT}}/dart/.dart_tool/package_config.json {{REPO_ROOT}}/dart/bin/linkedspec_dart.dart"
---

The Dart primary adapter owns a small deterministic trace projection separate from `LinkedSpecTraceEmitter` and
its rich native events. It emits only ADR `0024` compile/input/invoke phase records at the shared 100/200/300/400/
500 thresholds, accepts the exact named/numeric aliases, percent-escapes fields over UTF-8 bytes, counts source/
input/result UTF-8 bytes, and adds the canonical optional emoji prefixes.

`stdout`, `route`, and `mirror` have the same defaults and byte behavior as Perl/Rust. A trace file implies route;
reset truncates even at `none`/`quiet`; absence of reset appends; mirror bytes equal routed bytes; and stdout trace
precedes the canonical JSON record. Compile/input/invoke failures emit their phase error event. Trace setup/write
failure maps to the stable compilation failure without exposing Dart exceptions; any records already written to
stdout remain available exactly as in the shared contract.

Ambient/native Dart trace configuration cannot enable this protocol, and primary CLI options do not configure the
native trace emitter. The unchanged suite passes 61/61 under default and `POSIXLY_CORRECT=1` environments;
`.1.5.3.4` makes both legs recurring in the focused Dart gate. Rule-local cursor removal later deletes the global
request field and advances the recurring expanded suite to 63/63 twice.

Related facts: [[canonical-primary-cli-trace-protocol]], [[dart-trace-controls-sinks]],
[[dart-primary-cli-native-execution-canonical-json]], [[user-observable-backend-cli-parity-contract]],
[[dart-primary-cli-closeout]].
