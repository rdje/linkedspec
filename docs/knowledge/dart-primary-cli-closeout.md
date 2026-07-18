---
id: dart-primary-cli-closeout
title: Dart primary CLI is current at 63 cases with recurring local verification
answers:
  - is the Dart primary CLI complete
  - does the Dart local gate run both 61 case environments
  - what does FUTURE-PARITY-BACKLOG 1.5.3.4 prove
  - what remains after Dart primary CLI closeout
  - does the Dart primary CLI pass 63 cases after parse-mode removal
date: 2026-07-15
status: current
tags: [dart, cli, verification, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.5.3.4 historically closes Dart after tools/run_dart_local.sh passes format/analyzer, 151 tests, 61/61 default, 61/61 POSIX, and 99/99 corpus. FUTURE-PARITY-BACKLOG.9.1.5.5 removes the global cursor option and current proof is 260 tests, 63/63 default, 63/63 POSIX, and 105/105 corpus."
reverify: "bash tools/run_dart_local.sh && rg -n 'FUTURE-PARITY-BACKLOG.9.1.5.5|63/63|260|105/105' docs/tasks/FUTURE-PARITY-BACKLOG.md docs/TASK_TREE.md ROADMAP_V2.md"
---

`FUTURE-PARITY-BACKLOG.1.5.3` is closed. Its children replaced the corpus-oriented primary boundary, corrected the
native staged no-function case, composed native direct execution/canonical JSON, added the independent canonical
trace, and made the exact shared suite recurring. `dart/bin/corpus_runner.dart` remains a separate 99-fixture
developer command; it owns no primary-only behavior.

`tools/run_dart_local.sh` now runs formatting, fatal analyzer checks, all 260 Dart tests, primary/corpus help and a
bounded corpus smoke, 63/63 current primary cases with `POSIXLY_CORRECT` unset, 63/63 with it set, and full 105/105
corpus execution. `LINKEDSPEC_RUN_DART=1 bash tools/run_ci_local.sh` remains the optional composition point for
machines with the Dart SDK. The core gate independently passes doctrines, focused suites, both Perl 61-case legs,
and Phase 0 `1..1028`.

This closes Dart's exact CLI obligation, not complete public backend parity. Global `.1.5.4.3` closes the original
recurring four-backend conformance driver; Lua `.7.2` has since extended that driver to 5x2x61. `.1.6` and
generated-source `.3` still own the historical capability/codegen rollout.

Related facts: [[dart-primary-cli-boundary]], [[dart-primary-cli-native-execution-canonical-json]],
[[dart-canonical-primary-cli-trace]], [[dart-local-verification-gate]],
[[user-observable-backend-cli-parity-contract]], [[primary-cli-four-backend-matrix]].
