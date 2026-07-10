---
id: variant-specific-cli-requirement
title: Each backend owns a distinct executable name for one identical LinkedSpec CLI interface
answers:
  - should each LinkedSpec variant have a different CLI
  - should Dart Julia and Lua share one LinkedSpec CLI
  - where is the per variant CLI requirement recorded
  - does Dart need its own LinkedSpec CLI
  - do future backend variants need distinct CLI entrypoints
  - can backend CLI options differ by variant
  - must backend CLIs have the same positional arguments
date: 2026-07-09
status: current
tags: [cli, variants, dart, future-backends, DART-BACKEND-PARITY, FUTURE-PARITY-BACKLOG]
evidence: "The 2026-07-09 directive gives each variant a distinct CLI entrypoint. ADR 0023 records the 2026-07-10 clarification: those distinct executable names expose the exact same user-facing API. JULIA-BACKEND-PARITY.7.3.0 proves current drift; FUTURE-PARITY-BACKLOG.1.5 owns repair."
reverify: "rg -n 'identical.*CLI|same user-facing command|exact same.*CLI|JULIA-BACKEND-PARITY\\.7\\.3\\.0|distinct.*executable' docs/tasks/JULIA-BACKEND-PARITY.md docs/tasks/FUTURE-PARITY-BACKLOG.md docs/TASK_TREE.md docs/linkedspec-book/src/appendix/backend-handoff.md docs/linkedspec-book/src/overview/project-status.md README.md"
---

Each LinkedSpec backend variant should expose its own distinct executable name. The name identifies the selected
backend; it does not authorize a different interface. Every variant command must expose the same command structure,
option names and meanings, positional arguments, output/error behavior, and exit semantics.

For the original Dart lane, the directive is recorded as
`DART-BACKEND-PARITY.7.3`, and its backend-local implementation was closed by
`DART-BACKEND-PARITY.7.4`. `dart/bin/linkedspec_dart.dart` owns the
Dart-specific executable name; global `.1.5.3.4` has since replaced the historical corpus interface and closed
the exact shared parser command at recurring 61/61 default/POSIX. Corpus work remains in `bin/corpus_runner.dart`.

The future-backlog tree carries the cross-variant rule. `JULIA-BACKEND-PARITY`
now includes the requirement directly: `.1.1` must define the Julia-specific CLI
entrypoint during toolchain/package preflight. Lua planning must include the
same ownership when that lane activates. Do not treat a single ambiguous shared
`linkedspec` command as the only user-facing entrypoint for every variant, and do not let distinct names drift into
different products.

Related facts: [[user-observable-backend-cli-parity-contract]], [[cross-backend-cli-contract-gap]], [[dart-runtime-hash-helpers]], [[trace-cross-variant-capability-contract]],
[[rust-source-emitter-lane-split]], [[dart-specific-cli]], [[dart-primary-cli-closeout]],
[[julia-backend-interpreter-first-plan]].
