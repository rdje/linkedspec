# 0006 — Multi-backend vision: Rust, Julia, Dart backends alongside Perl; same `.spec` files, lockstep semantics

- Date: 2026-06-14
- Status: accepted
- Tags: architecture, portability, backends, roadmap

## Context

LinkedSpec is currently Perl 5 only. The HandlerVariantEmitter now produces structured
HandlerIR (hashref-based AST) with a `%BACKEND_EMITTERS` dispatch table and a JSON
diagnostic backend as proof of pluggability. All 20 shipped `.spec` files compile with
`language_agnostic_ready_ratio == 1.0000` and zero compatibility-surface rules. The
ActionIR lowering stack (100+ helpers across 10 families) is largely backend-neutral
in intent.

The user's vision, discussed during MEDIUM-IMPACT.1.3 HandlerIR work (2026-06-12) and
now formalized, is to grow LinkedSpec beyond Perl — not by abandoning Perl, but by
adding Rust, Julia, and Dart backends alongside it.

## Decision

1. **Perl stays the reference implementation.** It is not abandoned, deprecated, or
   frozen. It remains the development platform for `.spec` language evolution and the
   canonical behavioral oracle.

2. **`.spec` files are the universal contract.** Each backend parses the identical
   `.spec` grammar files. No per-backend spec dialects. No Rust-specific or
   Julia-specific `.spec` variants. A `.spec` that compiles on Perl must compile
   identically on every backend.

3. **Backends stay in lockstep.** Same features, same runtime semantics, same `.spec`
   compatibility. The Phase 0 regression baseline defines the behavioral contract all
   backends must pass. No backend gets ahead of the contract.

4. **HandlerIR is the decoupling seam.** HandlerIR separates structural decisions
   (which loop, which dispatch) from code generation (Perl source strings). Future
   backends consume the same HandlerIR nodes and emit their own language equivalents.
   The JSON diagnostic backend (`_emit_handler_json`) already proves this pattern:
   same HandlerIR → different output.

5. **Specification-first, not reverse-engineering.** Phase 8
   (`PHASE8-MULTI-BACKEND-HANDOFF`) produces the specification and test-artifact
   surface so a Rust/Julia/Dart implementer can build a compliant runtime without
   reading Perl source: a formal `.spec` grammar, a HandlerIR specification, a helper
   contract catalog, a runtime semantics specification, and a language-neutral test
   corpus.

6. **JS and Wasm reach via Rust or Dart.** Rust → wasm-bindgen/wasm-pack for Wasm;
   Dart → dart2js/dart2wasm for JS + Wasm + mobile via Flutter. No separate JS
   backend is planned.

## Backend reach matrix

| Backend | CLI | Web (JS) | Wasm | Mobile |
|---------|-----|----------|------|--------|
| Perl    | ✅  | —        | —    | —      |
| Rust    | ✅  | ✅ (wasm-bindgen) | ✅ | — |
| Julia   | ✅  | —        | —    | —      |
| Dart    | ✅  | ✅ (dart2js) | ✅ (dart2wasm) | ✅ (Flutter) |

## Consequences

- **Every `.spec` language change must be neutral** — documented in mdBook first,
  implemented in Perl, then validated across all backends once they exist.
- **mdBook is elevated to a specification role.** It is not "the Perl docs." It is
  the behavioral description all backends implement. It must describe what LinkedSpec
  does, not how Perl does it.
- **Phase 0 regression must become backend-portable.** The current `t/phase0_regression.t`
  is Perl. Phase 8.6 creates a language-neutral test corpus (`tests/corpus/`) every
  backend validates against.
- **SpecEntry remains the portability ceiling.** Runtime handler generation still
  bottoms out in emitted Perl and `eval`. Backend-specific `SpecEntry` equivalents
  (consuming HandlerIR, emitting Rust/Julia/Dart) are the first implementation step
  for each new backend.
- **No bytecode VM.** Direct language emitters (HandlerIR → Rust codegen, HandlerIR →
  Julia codegen, etc.) are more idiomatic and performant than a VM layer. The HandlerIR
  already provides the structured representation a VM would need; the decision of
  emit-vs-interpret is per-backend.

## Links

- Phase 8 task tree: `docs/tasks/PHASE8-MULTI-BACKEND-HANDOFF.md`
- Knowledge Map card: `docs/knowledge/language-agnostic-backend-vision.md`
- KM card (portability ceiling): `docs/knowledge/specentry-backend-portability-ceiling.md`
- Invariant: `docs/decisions/0002-all-target-actionir-ready-invariant.md`
- DSL policy: `docs/decisions/0003-raw-perl-free-spec-authoring.md`
- Roadmap: `ROADMAP_V2.md` (Phase 8 row)
