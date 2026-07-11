---
id: language-agnostic-backend-vision
title: LinkedSpec language-agnostic backend vision — Perl reference plus Rust, Dart, and active Julia; Lua follows under one lockstep .spec contract
answers:
  - what backends will LinkedSpec support
  - what is the language-agnostic architecture vision
  - how do backends stay in lockstep
  - does the Perl version go away
  - what LinkedSpec backends are implemented today
  - what is the role of .spec files across backends
  - how does HandlerIR help portability
  - what is the backend roadmap for LinkedSpec
  - is Lua an accepted LinkedSpec backend
date: 2026-06-12
status: accepted
tags: [architecture, portability, backends, roadmap, vision]
evidence: "ADR 0006 formalized lockstep backends, ADR 0021 fixed Dart/Julia/Lua order, and ADR 0022 made native embedding primary. ADR 0023 now makes complete parity exact user-observable capability/behavior identity plus one identical primary CLI; current Dart/Julia milestones remain scoped and global FUTURE-PARITY-BACKLOG.1.5/.1.6/.3 own convergence."
evidence_update_2026_07_11: "Exact primary CLI parity is closed at 61x2 on Perl/Rust/Dart/Julia, and all four expose native inline plus named/file roles; generated source and Dart full-pipeline trace still prevent complete parity."
reverify: "rg -n 'Rust|Julia|Dart|Lua|backend|primary CLI|complete parity' ROADMAP_V2.md docs/decisions/0006-multi-backend-vision.md docs/decisions/0021-future-backend-rollout-order.md docs/decisions/0022-native-in-memory-backend-embedding.md docs/decisions/0023-user-observable-backend-and-cli-parity.md docs/linkedspec-book/src/appendix/backend-handoff.md docs/tasks/FUTURE-PARITY-BACKLOG.md | head -100"
---

## Context

LinkedSpec currently has the Perl reference implementation, the Rust interpreter variant
under `rust/`, a closed scoped interpreter-first Dart milestone under `dart/`, and an active
Julia backend under `julia/`. Lua follows as a separate implementation track — not replacing
Perl, but alongside it. ADR 0021 fixes the rollout order as Dart first, Julia second, and Lua
third. All backends consume the exact same `.spec` files and produce identical parser
behavior. ADR 0022 additionally makes native in-memory host-language embedding the primary
product surface; see [[native-in-memory-backend-contract]]. JS and Wasm targets are reached
through adapters over Rust or Dart rather than separate `.spec` dialects.
ADR `0023` makes “lockstep” user-observable: complete parity requires the same public
capabilities/behavior and the same primary CLI interface.

## Decision

1. **Perl version stays** — it is not abandoned. It remains the reference implementation
   and the development platform for `.spec` language evolution.
2. **`.spec` files are the universal contract** — each backend parses the identical `.spec`
   grammar files. No per-backend spec dialects.
3. **Backends stay in lockstep** — same features, same runtime semantics, same `.spec`
   compatibility. A spec that compiles on Perl must compile identically on Rust/Dart/Julia/Lua
   once those backend tracks exist.
4. **Language-agnostic architecture** — every component that can be language-neutral should
   be:
   - HandlerIR defines handler structure without language-specific code generation
   - mdBook is the user-facing specification (not a Perl tutorial)
   - Phase0 regression defines the behavioral contract all backends must pass
   - ActionIR lowering is already largely backend-neutral
5. **HandlerIR is the first concrete decoupling step** — it separates structural decisions
   (which loop, which dispatch) from code generation (Perl source strings). Future backends
   consume the same HandlerIR nodes and emit their own language equivalents.
6. **Native in-memory embedding is primary** — every backend exposes host-process
   parse/compile/execute APIs. CLIs and corpus runners are thin adapters and may not own
   exclusive language or runtime semantics.
7. **Primary CLI identity is exact** — distinct backend executable tokens expose the same
   commands, options/meanings, positional arguments, outputs/errors, and exits.

## Consequences

- mdBook must be kept in lockstep with the codebase at all times — it is the spec.
- Every feature must be documented language-neutrally (describe behavior, not Perl
  implementation details).
- Knowledge Map cards should document contracts (what the system does) rather than
  implementation archaeology (how Perl does it).
- ROADMAP.md / ROADMAP_V2.md should eventually reflect backend milestones.

## Backend reach matrix

| Backend | Current primary CLI status | Web (JS) | Wasm | Mobile |
|---------|-----|----------|------|--------|
| Perl    | Exact ADR 0023 parser command; 61x2 pass | — | — | — |
| Rust    | Exact `linkedspec-rust`; 61x2 pass | ✅ (wasm-bindgen future target) | ✅ future target | — |
| Dart    | Exact Dart parser command; 61x2 pass | ✅ (dart2js future target) | ✅ (dart2wasm future target) | ✅ (Flutter future target) |
| Julia   | Exact `linkedspec_julia`; 61x2 pass | — | — | — |
| Lua     | Scheduled; must implement ADR 0023 from its first CLI slice | — | — | — |

## Speculated VM consideration

A bytecode VM was discussed but is not the preferred path. Direct language emitters
(HandlerIR → Rust codegen, HandlerIR → Julia codegen, etc.) are more idiomatic and
performant than a VM layer. The HandlerIR already provides the structured representation
a VM would need; the decision of emit-vs-interpret is per-backend.

## Links

- [[handler-ir-design]] — formal HandlerIR specification (created 2026-06-14, PHASE8-MULTI-BACKEND-HANDOFF.3)
- [[native-in-memory-backend-contract]] — primary host-process library surface (ADR 0022)
- [[user-observable-backend-cli-parity-contract]] — complete public capability and exact CLI contract (ADR 0023)
- [[specentry-backend-portability-ceiling]]
- [[actionir-lowering-stack]]
