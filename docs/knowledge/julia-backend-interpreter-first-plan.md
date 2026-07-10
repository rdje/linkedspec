---
id: julia-backend-interpreter-first-plan
title: Julia backend parity starts interpreter-first after the Dart milestone
answers:
  - "what is the Julia backend implementation strategy"
  - "what task tree owns Julia backend parity"
  - "what comes after Dart backend parity"
  - "does Julia need its own LinkedSpec CLI"
  - "is generated Julia source the primary parity gate"
date: 2026-07-09
status: current
tags: [julia, backend, parity, interpreter, FUTURE-PARITY-BACKLOG, JULIA-BACKEND-PARITY]
evidence: "FUTURE-PARITY-BACKLOG.1.2 creates docs/tasks/JULIA-BACKEND-PARITY.md after DART-BACKEND-PARITY.7.5 closes the scoped Dart milestone. The Julia plan follows the Dart lesson: start interpreter-first over typed .spec/helper-action AST and compiled state, require a Julia-specific CLI during package planning, prove corpus parity before milestone closeout, and leave generated Julia source as a later proof decision."
reverify: "rg -n 'JULIA-BACKEND-PARITY|interpreter-first|Julia-specific CLI|generated Julia source|FUTURE-PARITY-BACKLOG\\.1\\.2' docs/tasks/JULIA-BACKEND-PARITY.md docs/tasks/FUTURE-PARITY-BACKLOG.md docs/TASK_TREE.md ROADMAP.md ROADMAP_V2.md docs/linkedspec-book/src/overview/project-status.md docs/linkedspec-book/src/appendix/backend-handoff.md"
---

Julia backend parity is owned by `docs/tasks/JULIA-BACKEND-PARITY.md`, created
by `FUTURE-PARITY-BACKLOG.1.2`.

The plan starts interpreter-first, not generated-source-first:

- verify Julia toolchain and package layout before source code;
- parse `.spec` source into typed frontend structures;
- parse helper/action text into typed AST/IR nodes before execution;
- compile to a typed compiled-spec/interpreter model;
- implement runtime matching, helper/value semantics, staged function bodies,
  diagnostics/trace, and corpus execution;
- expose a distinct Julia-specific LinkedSpec CLI;
- prove the current manifest-backed corpus before milestone closeout.

Generated Julia source remains a later proof decision after interpreter parity,
mirroring the Dart closeout and Rust generated-source split.

Related facts: [[dart-scoped-parity-milestone-complete]], [[language-agnostic-backend-vision]],
[[variant-specific-cli-requirement]], [[text-to-ast-backend-doctrine]].
