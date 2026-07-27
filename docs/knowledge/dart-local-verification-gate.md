---
id: dart-local-verification-gate
title: Dart parity has a focused local gate and optional local-CI integration
answers:
  - "how do I run Dart parity checks"
  - "how do I run the Dart local gate"
  - "does run_ci_local include Dart checks"
  - "does Dart local CI require a Dart SDK by default"
  - "what does DART-BACKEND-PARITY.6.4 prove"
  - "does the Dart local gate prove project data stays on repository storage"
date: 2026-07-27
status: current
tags: [dart, ci, verification, corpus, DART-BACKEND-PARITY]
evidence: "FUTURE-PARITY-BACKLOG.1.5.3.4 makes tools/run_dart_local.sh recurring. PROJECT-DATA-SSD-ROOTING.2.3 adds repository-filesystem storage proof. Current proof is format, strict analyzer, 337 tests, 18-owner/47-package offline storage oracle, primary help, bounded corpus smoke, 66/66 default, 66/66 POSIX, and 105/105 corpus."
reverify: "rg -n 'LINKEDSPEC_RUN_DART|run_dart_local' tools/run_ci_local.sh tools/run_dart_local.sh README.md docs/linkedspec-book/src/development/local-ci-and-regression.md && bash tools/run_dart_local.sh"
---

Use the focused Dart gate when changing Dart backend code or Dart parity docs:

```bash
bash tools/run_dart_local.sh
```

The script runs the routed Dart formatter, strict analyzer, and package tests, shared primary-CLI help, a bounded
`bin/corpus_runner.dart` smoke, both 66-case primary environments, and the full checked-in 105-fixture corpus
execution. It also runs the 18-owner/47-package storage oracle after package tests.

The canonical local CI gate remains Perl/core-only unless explicitly opted in:

```bash
LINKEDSPEC_RUN_DART=1 bash tools/run_ci_local.sh
```

That boundary is intentional. The repository can still run its core local gate
on machines without Dart installed, while Dart-capable checkouts have a single
opt-in command that includes the green Dart corpus gate.

Related facts: [[dart-controlled-corpus-execution]], [[dart-primary-cli-boundary]],
[[dart-backend-scaffold-package]], [[phase0-regression-structure]], [[dart-primary-cli-closeout]],
[[dart-project-data-ssd-storage]], [[project-data-process-locality-proof]].
