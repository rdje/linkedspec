---
id: dart-backend-interpreter-first-plan
title: Dart backend parity starts interpreter-first; generated Dart source is a later proof lane
answers:
  - what is the Dart backend implementation strategy
  - should the Dart backend start with an interpreter or generated source
  - is generated Dart source the primary parity gate
  - how should Dart reach LinkedSpec parity
  - what task tree owns Dart backend parity
date: 2026-07-09
status: current
tags: [dart, backends, parity, interpreter, generated-source]
evidence: "docs/tasks/DART-BACKEND-PARITY.md decisions select the interpreter-first path; ADR 0011 requires typed helper/action AST for new backends; the mdBook backend handoff states Rust interpreter parity is the full 99-fixture gate while generated source is a curated-subset proof. DART-BACKEND-PARITY.7.2 explicitly defers generated Dart source to a future split source-emitter lane."
reverify: "rg -n 'interpreter-first|Generated Dart|DART-BACKEND-PARITY|typed AST|99-fixture' docs/tasks/DART-BACKEND-PARITY.md docs/linkedspec-book/src/appendix/backend-handoff.md docs/decisions/0011-text-to-ast-backend-doctrine.md"
---

Dart backend parity starts with an interpreter over typed `.spec` and helper/action AST/IR,
not generated Dart source. The primary path is `.spec` parser -> typed helper/action AST ->
compiled-spec state -> Dart runtime interpreter -> manifest-backed corpus runner.

Generated Dart source is deferred to a future split source-emitter lane after
interpreter parity. This matches the current Rust status: the Rust interpreter is
the full-corpus parity gate, while generated source is a structural and
curated-subset proof. The task owner is `docs/tasks/DART-BACKEND-PARITY.md`.

Related facts: [[language-agnostic-backend-vision]], [[text-to-ast-backend-doctrine]],
[[rust-perl-output-oracle]], [[dart-generated-source-deferred]].
