---
id: dart-scoped-parity-milestone-complete
title: Dart scoped interpreter-first parity milestone is complete
answers:
  - "is the Dart backend milestone complete"
  - "what is the current Dart backend status"
  - "what comes after Dart backend parity"
  - "is Julia unblocked after Dart"
  - "does Dart still have an active task-tree frontier"
date: 2026-07-09
status: current
tags: [dart, backend, parity, corpus, FUTURE-PARITY-BACKLOG, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.7.5 closes the Dart task tree after parser/frontend, typed ActionIR, compiled state, runtime interpretation, staged user-function execution, diagnostics/trace, focused local verification, Dart-specific CLI productization, and 99/99 corpus execution. Generated Dart source remains deferred to a future source-emitter proof lane. FUTURE-PARITY-BACKLOG.1.2 then created JULIA-BACKEND-PARITY, whose active frontier is JULIA-BACKEND-PARITY.1.1."
reverify: "rg -n 'DART-BACKEND-PARITY\\.7\\.5|No active Dart frontier|99/99 corpus|FUTURE-PARITY-BACKLOG\\.1\\.2|JULIA-BACKEND-PARITY\\.1\\.1|Julia planning' docs/tasks/DART-BACKEND-PARITY.md docs/TASK_TREE.md docs/tasks/FUTURE-PARITY-BACKLOG.md docs/tasks/JULIA-BACKEND-PARITY.md ROADMAP.md ROADMAP_V2.md docs/linkedspec-book/src/overview/project-status.md docs/linkedspec-book/src/appendix/backend-handoff.md"
---

The Dart backend task tree is closed at the scoped interpreter-first milestone.
The accepted claim is:

- Dart parses/validates `.spec` source into typed frontend structures.
- Dart parses helper/action text into typed ActionIR and builds compiled-spec state.
- Dart executes the current runtime interpreter, staged user-function body flow,
  diagnostics/trace controls, and manifest-backed corpus runner.
- `tools/run_dart_local.sh` is the focused Dart gate.
- `dart run bin/linkedspec_dart.dart corpus --corpus <path> --execute` is the
  Dart-specific CLI corpus command.
- The checked-in 99-fixture corpus passes through Dart execute mode.

Generated Dart source is not part of this milestone. It remains a future split
proof lane. After Dart closed, `FUTURE-PARITY-BACKLOG.1.2` created
`JULIA-BACKEND-PARITY`; executable Julia work now starts at
`JULIA-BACKEND-PARITY.1.1`. No Julia or Lua implementation happened in the Dart
closeout or in the Julia planning slice.

Related facts: [[dart-backend-interpreter-first-plan]], [[dart-generated-source-deferred]],
[[dart-specific-cli]], [[language-agnostic-backend-vision]], [[julia-backend-interpreter-first-plan]].
