---
id: backend-companion-book-architecture
title: LinkedSpec uses one normative neutral book plus five parity-gated backend implementation companions
answers:
  - why have separate LinkedSpec backend books
  - which LinkedSpec book owns portable semantics
  - what belongs in a backend companion book
  - are there separate Perl Rust Dart Julia and Lua books now
  - when will backend companion books be implemented
  - how do backend books avoid duplicated semantics and drift
  - what does ADR 0040 decide
date: 2026-07-15
status: accepted-direction
tags: [documentation, mdbook, backends, parity, architecture, ADR-0040]
evidence: "ADR 0040 and FUTURE-PARITY-BACKLOG.21 adopt the architecture; BACKEND-COMPANION-BOOKS.1+ is dependency-gated and no companion scaffold exists yet."
reverify: "sed -n '1,240p' docs/decisions/0040-backend-implementation-companion-books.md; sed -n '1,300p' docs/tasks/BACKEND-COMPANION-BOOKS.md"
---

LinkedSpec keeps `docs/linkedspec-book/` as its sole normative, backend-neutral book. It owns `.spec` and ActionIR
semantics, portable values and behavior, AST/diagnostic contracts, conformance policy, and common examples.

ADR `0040` adopts one optional implementation companion each for Perl, Rust, Dart, Julia, and Lua. A companion may
explain host APIs and embedding, toolchains and ABIs, native dependencies, frontend/compiler/runtime architecture,
loading and staging, trace/debug workflows, generated artifacts, performance/caching/deployment, troubleshooting,
and exact backend-specific limitations. It links to the neutral semantic owner instead of copying normative prose.

The books have not been scaffolded. `BACKEND-COMPANION-BOOKS.1+` is explicitly dependency-gated until full parity
among the current five variants. Rollout begins with a read-only retain/move/link/remove inventory, then establishes
shared structure, independent builds, navigation, canonical-owner metadata, and mechanical duplication/drift gates
before any content is migrated or populated.

Related records: [[user-observable-backend-cli-parity-contract]]. See ADR `0040` and
`docs/tasks/BACKEND-COMPANION-BOOKS.md` for the normative decision and implementation tree.
