---
id: variant-specific-cli-requirement
title: Each LinkedSpec backend variant should own a distinct CLI entrypoint
answers:
  - should each LinkedSpec variant have a different CLI
  - should Dart Julia and Lua share one LinkedSpec CLI
  - where is the per variant CLI requirement recorded
  - does Dart need its own LinkedSpec CLI
  - do future backend variants need distinct CLI entrypoints
date: 2026-07-09
status: current
tags: [cli, variants, dart, future-backends, DART-BACKEND-PARITY, FUTURE-PARITY-BACKLOG]
evidence: "Director directive on 2026-07-09: each LinkedSpec backend variant should have a different CLI. DART-BACKEND-PARITY.7.3 records the directive, and DART-BACKEND-PARITY.7.4 productizes the Dart-specific CLI under dart/bin/linkedspec_dart.dart. FUTURE-PARITY-BACKLOG records that Julia and Lua planning must include equivalent variant-specific CLI ownership when activated."
reverify: "rg -n 'variant-specific CLI|distinct LinkedSpec CLI|DART-BACKEND-PARITY\\.7\\.4|per-variant CLI|bin/linkedspec_dart\\.dart|corpus --corpus' docs/tasks/DART-BACKEND-PARITY.md docs/tasks/FUTURE-PARITY-BACKLOG.md docs/TASK_TREE.md docs/linkedspec-book/src/appendix/backend-handoff.md docs/linkedspec-book/src/overview/project-status.md dart/README.md"
---

Each LinkedSpec backend variant should expose its own distinct CLI entrypoint.

For the active Dart lane, the directive is recorded as
`DART-BACKEND-PARITY.7.3`, and implementation/productization is closed by
`DART-BACKEND-PARITY.7.4`. `dart/bin/linkedspec_dart.dart` owns the
Dart-specific CLI name, help text, argument contract, runtime/corpus invocation
path, docs, and smoke tests.

The future-backlog tree carries the cross-variant rule: Julia and Lua planning
must include equivalent variant-specific CLI ownership when those backend lanes
activate. Do not treat a single ambiguous shared `linkedspec` command as the
only user-facing entrypoint for every variant.

Related facts: [[dart-runtime-hash-helpers]], [[trace-cross-variant-capability-contract]],
[[rust-source-emitter-lane-split]], [[dart-specific-cli]].
