---
id: dart-scoped-parity-milestone-complete
title: Dart scoped interpreter-first parity milestone is complete
answers:
  - "is the Dart backend milestone complete"
  - "what is the current Dart backend status"
  - "what comes after Dart backend parity"
  - "is Julia unblocked after Dart"
  - "does Dart still have an active task-tree frontier"
date: 2026-07-27
status: current
tags: [dart, backend, parity, corpus, FUTURE-PARITY-BACKLOG, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.7.5 closes the scoped Dart tree at 99/99 interpreter execution plus backend-local corpus CLI. ADR 0023 later distinguishes that milestone from complete public parity; FUTURE-PARITY-BACKLOG.1.5.3/.1.6/.3 own Dart's primary CLI, capability, and generated-source gaps."
reverify: "rg -n 'DART-BACKEND-PARITY\\.7\\.5|99/99|FUTURE-PARITY-BACKLOG\\.1\\.5\\.3|FUTURE-PARITY-BACKLOG\\.1\\.6|FUTURE-PARITY-BACKLOG\\.3|scoped' docs/tasks/DART-BACKEND-PARITY.md docs/TASK_TREE.md docs/tasks/FUTURE-PARITY-BACKLOG.md ROADMAP.md ROADMAP_V2.md docs/linkedspec-book/src/overview/project-status.md docs/linkedspec-book/src/appendix/backend-handoff.md"
---

The Dart backend task tree is closed at the scoped interpreter-first milestone.
The accepted claim is:

- Dart parses/validates `.spec` source into typed frontend structures.
- Dart parses helper/action text into typed ActionIR and builds compiled-spec state.
- Dart executes the current runtime interpreter, staged user-function body flow,
  diagnostics/trace controls, and manifest-backed corpus runner.
- `tools/run_dart_local.sh` is the focused Dart gate.
- `bash ../tools/run_dart_project_data.sh run bin/corpus_runner.dart --corpus <path> --execute` from `dart/` is the separate
  Dart corpus command; the later global `.1.5.3.1` primary boundary rejects corpus options.
- The checked-in 99-fixture corpus passes through Dart execute mode.

Generated Dart source is not part of this milestone. It remains a future split
proof lane. ADR `0023` later makes the exact parser CLI, full public capability
matrix, and generated source requirements for a complete Dart-parity claim; global
`.1.5.3`, `.1.6`, and `.3` own them without reopening the historical scoped tree.

Related facts: [[user-observable-backend-cli-parity-contract]], [[dart-backend-interpreter-first-plan]], [[dart-generated-source-deferred]],
[[dart-specific-cli]], [[dart-primary-cli-boundary]], [[language-agnostic-backend-vision]], [[julia-backend-interpreter-first-plan]].
