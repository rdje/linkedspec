---
id: dart-local-verification-gate
title: Dart parity has a focused local gate and optional local-CI integration
answers:
  - "how do I run Dart parity checks"
  - "how do I run the Dart local gate"
  - "does run_ci_local include Dart checks"
  - "does Dart local CI require a Dart SDK by default"
  - "what does DART-BACKEND-PARITY.6.4 prove"
date: 2026-07-09
status: current
tags: [dart, ci, verification, corpus, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.6.4 adds tools/run_dart_local.sh, which runs Dart format, analyzer, full tests, CLI help, and the full 99-fixture corpus execution. DART-BACKEND-PARITY.7.4 extends that gate with a bounded Dart-specific CLI corpus smoke. tools/run_ci_local.sh remains core-only by default and runs the Dart gate only when LINKEDSPEC_RUN_DART=1 is set, avoiding a hard Dart SDK dependency for ordinary local CI."
reverify: "rg -n 'LINKEDSPEC_RUN_DART|run_dart_local' tools/run_ci_local.sh tools/run_dart_local.sh README.md docs/linkedspec-book/src/development/local-ci-and-regression.md && bash tools/run_dart_local.sh"
---

Use the focused Dart gate when changing Dart backend code or Dart parity docs:

```bash
bash tools/run_dart_local.sh
```

The script runs `dart format --set-exit-if-changed .`, `dart analyze
--fatal-infos --fatal-warnings`, `dart test`, Dart CLI help checks, a bounded
Dart-specific CLI corpus smoke, and the full checked-in 99-fixture corpus
execution.

The canonical local CI gate remains Perl/core-only unless explicitly opted in:

```bash
LINKEDSPEC_RUN_DART=1 bash tools/run_ci_local.sh
```

That boundary is intentional. The repository can still run its core local gate
on machines without Dart installed, while Dart-capable checkouts have a single
opt-in command that includes the green Dart corpus gate.

Related facts: [[dart-controlled-corpus-execution]],
[[dart-backend-scaffold-package]], [[phase0-regression-structure]].
