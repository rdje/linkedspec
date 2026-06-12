---
id: language-agnostic-backend-vision
title: LinkedSpec language-agnostic backend vision — Perl stays primary; Rust/Julia/Dart backends consume same .spec files in lockstep
answers:
  - what backends will LinkedSpec support
  - what is the language-agnostic architecture vision
  - how do backends stay in lockstep
  - does the Perl version go away
  - what is the role of .spec files across backends
  - how does HandlerIR help portability
  - what is the backend roadmap for LinkedSpec
date: 2026-06-12
status: accepted
tags: [architecture, portability, backends, roadmap, vision]
evidence: "User-specified vision during MEDIUM-IMPACT.1.3 HandlerIR work. Speculated backends: Rust, Julia, Dart. JS+Wasm reach via Rust or Dart. All backends consume identical .spec files."
reverify: "grep -n 'backend\|portability' ROADMAP_V2.md ARCHITECTURE_STATE.md | head -10"
---

## Context

LinkedSpec is currently Perl 5 only. The user's vision is to add Rust, Julia, and Dart
backends — not replacing Perl, but alongside it. All backends consume the exact same
`.spec` files and produce identical parser behavior. JS and Wasm targets are reached via
Rust (wasm-bindgen/wasm-pack) or Dart (dart2js/dart2wasm).

## Decision

1. **Perl version stays** — it is not abandoned. It remains the reference implementation
   and the development platform for `.spec` language evolution.
2. **`.spec` files are the universal contract** — each backend parses the identical `.spec`
   grammar files. No per-backend spec dialects.
3. **Backends stay in lockstep** — same features, same runtime semantics, same `.spec`
   compatibility. A spec that compiles on Perl must compile identically on Rust/Julia/Dart.
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
| Rust    | ✅  | ✅ (wasm-bindgen) | ✅ | — |
| Julia   | ✅  | —        | —    | —      |
| Dart    | ✅  | ✅ (dart2js) | ✅ (dart2wasm) | ✅ (Flutter) |

## Speculated VM consideration

A bytecode VM was discussed but is not the preferred path. Direct language emitters
(HandlerIR → Rust codegen, HandlerIR → Julia codegen, etc.) are more idiomatic and
performant than a VM layer. The HandlerIR already provides the structured representation
a VM would need; the decision of emit-vs-interpret is per-backend.

## Links

- [[handler-ir-design]] (to be created — formal HandlerIR contract)
- [[specentry-backend-portability-ceiling]]
- [[actionir-lowering-stack]]
