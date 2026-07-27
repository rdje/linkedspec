---
id: dart-mdbook-usage-status
title: Dart mdBook usage/status docs describe the current 105-case interpreter boundary
answers:
  - "where does the mdBook document Dart usage"
  - "how does the mdBook explain Dart parity status"
  - "what does DART-BACKEND-PARITY.7.1 prove"
  - "is generated Dart source required for current Dart parity"
  - "what Dart commands should the book show"
date: 2026-07-27
status: current
tags: [dart, mdbook, corpus, parity, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.7.1 documents the 99/99 interpreter-first boundary; .7.2 defers generated source; .7.4 adds the backend-local corpus CLI; .7.5 closes the scoped milestone. ADR 0023 later distinguishes that milestone from complete CLI/capability parity, now owned globally by FUTURE-PARITY-BACKLOG.1.5/.1.6/.3."
evidence_update_2026_07_10: "FUTURE-PARITY-BACKLOG.1.6.1 raises the current mandatory interpreter corpus to 105/105 and closes exhaustive language-surface proof at 239 names; the historical DART-BACKEND-PARITY milestone remains 99/99."
reverify: "rg -n 'Dart Backend Commands|tools/run_dart_local|LINKEDSPEC_RUN_DART|source-emitter|corpus-green|linkedspec_dart\\.dart corpus|DART-BACKEND-PARITY\\.7\\.5|ADR 0023|scoped' docs/linkedspec-book/src/appendix/backend-handoff.md docs/linkedspec-book/src/overview/project-status.md docs/linkedspec-book/src/public-api/trace-api.md && bash tools/run_mdbook_local.sh"
---

The mdBook documents Dart backend usage in the backend handoff appendix, with
cross-references from project status and trace-status pages. The reader-facing
commands are:

```bash
bash tools/run_dart_local.sh
LINKEDSPEC_RUN_DART=1 bash tools/run_ci_local.sh
cd dart && bash ../tools/run_dart_project_data.sh test
cd dart && bash ../tools/run_dart_project_data.sh run bin/linkedspec_dart.dart --help
cd dart && bash ../tools/run_dart_project_data.sh run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute
```

The documented status boundary is interpreter-first and corpus-green: Dart
passes the current 105-fixture backend-neutral corpus through the runtime
interpreter path. Generated Dart source is not required for that scoped corpus
claim; `DART-BACKEND-PARITY.7.2` defers it to a future split source-emitter lane.
The backend-local corpus CLI closed under `.7.4`, and `.7.5` closed the scoped Dart
tree. ADR `0023` made the exact parser CLI and public codegen/capability surface
global completion obligations under `.1.5`, `.1.6`, and `.3`; `.1.5.3.4` now
closes recurring 61/61 primary verification, and `.1.6.1` closes exhaustive language proof; remaining outward
capabilities and generated source remain globally owned.

Related facts: [[user-observable-backend-cli-parity-contract]], [[dart-local-verification-gate]], [[dart-controlled-corpus-execution]],
[[dart-backend-interpreter-first-plan]], [[dart-generated-source-deferred]], [[dart-specific-cli]],
[[dart-scoped-parity-milestone-complete]], [[dart-primary-cli-boundary]], [[dart-primary-cli-closeout]].
