---
id: language-agnostic-backend-vision
title: LinkedSpec language-agnostic backend vision — Perl reference plus Rust and scoped Dart today; Julia and Lua future backends consume same .spec files in lockstep
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
evidence: "User-specified vision during MEDIUM-IMPACT.1.3 HandlerIR work; ADR 0006 formalized the multi-backend vision and accepted Julia/Dart as future targets. Phase 9 implemented the Rust interpreter under rust/. SPEC-FORMAT-TERSE.5.0 reverified the then-current backend inventory. ADR 0021 later accepted Lua and fixed the future rollout order as Dart, then Julia, then Lua, all to full parity with Perl5 and Rust. DART-BACKEND-PARITY.7.5 closes Dart's scoped interpreter-first milestone and returns rollout to Julia planning."
reverify: "grep -n 'Rust\\|Julia\\|Dart\\|Lua\\|backend' ROADMAP_V2.md docs/decisions/0006-multi-backend-vision.md docs/decisions/0021-future-backend-rollout-order.md docs/linkedspec-book/src/appendix/backend-handoff.md docs/tasks/FUTURE-PARITY-BACKLOG.md | head -60"
---

## Context

LinkedSpec currently has the Perl reference implementation, the Rust interpreter variant
under `rust/`, and a scoped interpreter-first Dart milestone under `dart/`. The accepted
future backend vision is to add Julia and Lua as separate implementation tracks — not
replacing Perl, but alongside it. ADR 0021 fixes the rollout order as Dart first, Julia
second, and Lua third; Dart's scoped milestone is now closed and rollout returns to Julia
planning. All backends consume the exact same `.spec` files and produce identical parser
behavior. JS and Wasm targets are reached via Rust (wasm-bindgen/wasm-pack) or Dart
(dart2js/dart2wasm).

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

## Consequences

- mdBook must be kept in lockstep with the codebase at all times — it is the spec.
- Every feature must be documented language-neutrally (describe behavior, not Perl
  implementation details).
- Knowledge Map cards should document contracts (what the system does) rather than
  implementation archaeology (how Perl does it).
- ROADMAP.md / ROADMAP_V2.md should eventually reflect backend milestones.

## Backend reach matrix

| Backend | CLI | Web (JS) | Wasm | Mobile |
|---------|-----|----------|------|--------|
| Perl    | ✅  | —        | —    | —      |
| Rust    | ✅ implemented | ✅ (wasm-bindgen future target) | ✅ future target | — |
| Dart    | ✅ scoped interpreter-first milestone complete | ✅ (dart2js future target) | ✅ (dart2wasm future target) | ✅ (Flutter future target) |
| Julia   | ✅ scheduled future target, second | —        | —    | —      |
| Lua     | ✅ scheduled future target, third | —        | —    | —      |

## Speculated VM consideration

A bytecode VM was discussed but is not the preferred path. Direct language emitters
(HandlerIR → Rust codegen, HandlerIR → Julia codegen, etc.) are more idiomatic and
performant than a VM layer. The HandlerIR already provides the structured representation
a VM would need; the decision of emit-vs-interpret is per-backend.

## Links

- [[handler-ir-design]] — formal HandlerIR specification (created 2026-06-14, PHASE8-MULTI-BACKEND-HANDOFF.3)
- [[specentry-backend-portability-ceiling]]
- [[actionir-lowering-stack]]
