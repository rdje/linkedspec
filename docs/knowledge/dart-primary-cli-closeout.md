---
id: dart-primary-cli-closeout
title: Dart primary CLI is closed at 61 cases with recurring local verification
answers:
  - is the Dart primary CLI complete
  - does the Dart local gate run both 61 case environments
  - what does FUTURE-PARITY-BACKLOG 1.5.3.4 prove
  - what remains after Dart primary CLI closeout
date: 2026-07-10
status: current
tags: [dart, cli, verification, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.5.3.4 closes Dart after tools/run_dart_local.sh passes format/analyzer, 151 tests, 61/61 default, 61/61 POSIX, and 99/99 corpus; the broader core gate passes Phase 0 1..1028."
reverify: "bash tools/run_dart_local.sh && rg -n 'FUTURE-PARITY-BACKLOG.1.5.3.4|61/61|151|99/99' docs/tasks/FUTURE-PARITY-BACKLOG.md docs/TASK_TREE.md ROADMAP_V2.md"
---

`FUTURE-PARITY-BACKLOG.1.5.3` is closed. Its children replaced the corpus-oriented primary boundary, corrected the
native staged no-function case, composed native direct execution/canonical JSON, added the independent canonical
trace, and made the exact shared suite recurring. `dart/bin/corpus_runner.dart` remains a separate 99-fixture
developer command; it owns no primary-only behavior.

`tools/run_dart_local.sh` now runs formatting, fatal analyzer checks, all 151 Dart tests, primary/corpus help and a
bounded corpus smoke, 61/61 unchanged primary cases with `POSIXLY_CORRECT` unset, 61/61 with it set, and full 99/99
corpus execution. `LINKEDSPEC_RUN_DART=1 bash tools/run_ci_local.sh` remains the optional composition point for
machines with the Dart SDK. The core gate independently passes doctrines, focused suites, both Perl 61-case legs,
and Phase 0 `1..1028`.

This closes Dart's exact CLI obligation, not complete public backend parity. Global `.1.5.4` next proves one
four-backend conformance driver; `.1.6` and generated-source `.3` still own capability/codegen gaps before Lua.

Related facts: [[dart-primary-cli-boundary]], [[dart-primary-cli-native-execution-canonical-json]],
[[dart-canonical-primary-cli-trace]], [[dart-local-verification-gate]],
[[user-observable-backend-cli-parity-contract]].
