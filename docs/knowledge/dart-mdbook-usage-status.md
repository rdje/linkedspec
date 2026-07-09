---
id: dart-mdbook-usage-status
title: Dart mdBook usage/status docs describe the interpreter-first 99/99 parity boundary
answers:
  - "where does the mdBook document Dart usage"
  - "how does the mdBook explain Dart parity status"
  - "what does DART-BACKEND-PARITY.7.1 prove"
  - "is generated Dart source required for current Dart parity"
  - "what Dart commands should the book show"
date: 2026-07-09
status: current
tags: [dart, mdbook, corpus, parity, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.7.1 updates the backend handoff appendix, project status page, trace-status page, roadmaps, live docs, task tree, and architecture snapshot so the mdBook names the focused Dart gate, optional local-CI inclusion, direct Dart test/full-corpus commands, the 99/99 interpreter-first parity boundary, and generated-source / Dart-specific CLI follow-up lanes."
reverify: "rg -n 'Dart Backend Commands|tools/run_dart_local|LINKEDSPEC_RUN_DART|generated-source proof decision|corpus-green' docs/linkedspec-book/src/appendix/backend-handoff.md docs/linkedspec-book/src/overview/project-status.md docs/linkedspec-book/src/public-api/trace-api.md && mdbook build docs/linkedspec-book"
---

The mdBook documents Dart backend usage in the backend handoff appendix, with
cross-references from project status and trace-status pages. The reader-facing
commands are:

```bash
bash tools/run_dart_local.sh
LINKEDSPEC_RUN_DART=1 bash tools/run_ci_local.sh
cd dart && dart test
cd dart && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute
```

The documented status boundary is interpreter-first and corpus-green: Dart
passes the current 99-fixture backend-neutral corpus through the runtime
interpreter path. Generated Dart source is not required for the current parity
claim; it remains the `DART-BACKEND-PARITY.7.2` decision/proof lane. A
Dart-specific LinkedSpec CLI remains `DART-BACKEND-PARITY.7.4`.

Related facts: [[dart-local-verification-gate]], [[dart-controlled-corpus-execution]],
[[dart-backend-interpreter-first-plan]].
