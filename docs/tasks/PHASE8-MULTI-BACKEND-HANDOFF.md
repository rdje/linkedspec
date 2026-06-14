# PHASE8-MULTI-BACKEND-HANDOFF: Multi-Backend Specification & Handoff Surface

## Metadata

- Tree ID: `PHASE8-MULTI-BACKEND-HANDOFF`
- Status: `active`
- Roadmap lane: `Phase 8 — Multi-backend specification and handoff`
- Created: `2026-06-14`
- Last updated: `2026-06-14`
- Owner: repo-local workflow

## Goal

Produce the specification, contract, and test-artifact surface so that a Rust, Julia, or Dart
backend implementer can build a compliant LinkedSpec runtime **without reading Perl source code**.
Every deliverable must answer "what does LinkedSpec do?" in language-neutral terms, backed by a
canonical test corpus every backend runs against.

## Non-Goals

- Does not implement any non-Perl backend.
- Does not remove or rewrite the Perl backend — Perl stays the reference implementation.
- Does not change `.spec` language syntax or semantics (only documents them).
- Does not migrate or retire legacy plugin infrastructure.
- Does not create a formal mathematical semantics (engineering precision, not formal methods).

## Acceptance Criteria

- Multi-backend ADR (0006) recorded in `docs/decisions/`.
- Formal `.spec` grammar specification exists as a standalone, unambiguous reference.
- HandlerIR specification (`docs/knowledge/handler-ir-design.md`) exists — every node type,
  every field, semantics defined without Perl reference.
- Helper contract catalog covers all 100+ helpers: one canonical entry per helper with
  signature, input/output types, edge cases, and behavioral contract.
- Runtime semantics specification defines seek/consume, BACKTRACK, lifecycles, rule modes,
  accumulator conventions, and edge dispatch precisely enough for independent reimplementation.
- Language-neutral test corpus (`tests/corpus/`) with JSON-serialized input/expected-AST pairs
  covering representative specs and edge cases.
- mdBook gains a "Backend Handoff" chapter (or section) linking all of the above.
- Knowledge Map grown to cover all new durable facts.
- `ROADMAP_V2.md` and `ROADMAP.md` reflect Phase 8 status.
- `scripts/check_memory_architecture.sh` PASS; local CI gate PASS.

## Task Tree

- ID: `PHASE8-MULTI-BACKEND-HANDOFF`
  Status: `active`
  Goal: `Produce specification, contract, and test-artifact surface for multi-backend handoff.`
  Children: `PHASE8-MULTI-BACKEND-HANDOFF.1, PHASE8-MULTI-BACKEND-HANDOFF.2, PHASE8-MULTI-BACKEND-HANDOFF.3, PHASE8-MULTI-BACKEND-HANDOFF.4, PHASE8-MULTI-BACKEND-HANDOFF.5, PHASE8-MULTI-BACKEND-HANDOFF.6, PHASE8-MULTI-BACKEND-HANDOFF.7, PHASE8-MULTI-BACKEND-HANDOFF.8`

- ID: `PHASE8-MULTI-BACKEND-HANDOFF.1`
  Status: `done`
  Goal: `Multi-backend ADR 0006 — formalize the Rust/Julia/Dart backend vision as a durable decision record (layer C), with explicit lockstep contracts, the universal .spec surface, and HandlerIR as the decoupling seam.`
  Acceptance: `ADR 0006 recorded in docs/decisions/; INDEX.md updated; linked from ROADMAP_V2.md; linked from the owning task-tree.`
  Verification: `PASS — ADR 0006 created, INDEX.md updated, memory-arch check PASS`
  Commit: `pending`

- ID: `PHASE8-MULTI-BACKEND-HANDOFF.2`
  Status: `done`
  Goal: `Formal .spec grammar specification — produce a standalone, unambiguous grammar reference that defines valid .spec syntax without depending on the Perl bootstrap parser. Covers rule labels, modes, regexes, lifecycles, edges, code blocks, split markers, fluent chains, and paragraph structure.`
  Acceptance: `Specification exists as a tracked document (mdBook chapter or standalone reference); covers all 37 syntax categories from PHASE7-SELF-HOSTED-SPEC.1 inventory; readable by a non-Perl implementer.`
  Verification: `PASS — docs/linkedspec-book/src/appendix/formal-grammar.md created (12 sections, covers all syntax categories); SUMMARY.md updated`
  Commit: `pending`

- ID: `PHASE8-MULTI-BACKEND-HANDOFF.3`
  Status: `done`
  Goal: `HandlerIR specification — create the missing docs/knowledge/handler-ir-design.md card. Define every HandlerIR node type, every field, its semantics, and the contract between variant builders and backend emitters. Reference the existing JSON diagnostic backend as a concrete output example.`
  Acceptance: `docs/knowledge/handler-ir-design.md exists; all 10 variant builders' IR shapes documented; field semantics defined without Perl references; linked from language-agnostic-backend-vision.md (replaces the "(to be created)" placeholder).`
  Verification: `PASS — handler-ir-design.md created (all 10 variant kinds, field tables, emitter contract, lifecycle semantics, current limitations); language-agnostic-backend-vision.md placeholder fixed`
  Commit: `pending`

- ID: `PHASE8-MULTI-BACKEND-HANDOFF.4`
  Status: `done`
  Goal: `Helper contract catalog — produce one canonical reference covering all 100+ helpers across 10 families. Each entry: helper name, signature, input/output types, behavioral contract, edge cases. Extract and formalize from existing Contracts.pm + USER_GUIDE files; organize by family.`
  Acceptance: `Catalog exists as a tracked document; covers all helper families (scalar, array, hash, arithmetic, string, flow, capture/mark, declaration, assignment, control-flow); each helper has a signature, type contract, and behavioral description in language-neutral terms.`
  Verification: `PASS — helper-contract-catalog.md created (10 families, 100+ helpers, cross-cutting contracts, compatibility alias table)`
  Commit: `pending`

- ID: `PHASE8-MULTI-BACKEND-HANDOFF.5`
  Status: `pending`
  Goal: `Runtime semantics specification — define precisely: (a) seek vs consume parse modes, (b) BACKTRACK/IBACKTRACK local-rewind contract, (c) lifecycle execution order and interaction with rule modes, (d) accumulator conventions and implicit-target rules, (e) edge dispatch (action vs blind-call, regex-slot indexing), (f) handler variant selection logic.`
  Acceptance: `Specification exists as a tracked document; each subsection is precise enough that two independent implementers would produce identical behavior; cross-referenced with the formal grammar (.2) and HandlerIR spec (.3).`
  Verification: `pending`
  Commit: `pending`

- ID: `PHASE8-MULTI-BACKEND-HANDOFF.6`
  Status: `pending`
  Goal: `Language-neutral test corpus — create tests/corpus/ with JSON-serialized input/expected-output pairs. Cover: representative specs (Lispish, tablegrep, ebnf, portmap, verilog, vhdl), edge cases (nested blocks, deep fluent chains, switch/if cross-nesting, lifecycle variants), and error paths. Format must be consumable by any language.`
  Acceptance: `tests/corpus/ exists with a README.md explaining the format; at least 6 representative specs covered; each entry has input .spec content + expected parse result as canonical JSON; format is self-describing and language-agnostic.`
  Verification: `pending`
  Commit: `pending`

- ID: `PHASE8-MULTI-BACKEND-HANDOFF.7`
  Status: `pending`
  Goal: `mdBook handoff chapter — add a "Backend Handoff" chapter (or section) to the mdBook that links the formal grammar, HandlerIR spec, helper catalog, runtime semantics, and test corpus into one coherent entry point for a new backend implementer. Update project-status.md to reflect Phase 8.`
  Acceptance: `New mdBook chapter (or expanded existing chapter) exists under an appropriate section; links all five specification artifacts; includes a "How to build a new backend" walkthrough; SUMMARY.md updated; project-status.md reflects Phase 8.`
  Verification: `pending`
  Commit: `pending`

- ID: `PHASE8-MULTI-BACKEND-HANDOFF.8`
  Status: `pending`
  Goal: `Finalization — verify all deliverables, run memory-arch check + local CI gate, update ROADMAP_V2.md / ROADMAP.md, refresh KNOWLEDGE_MAP.md, update live docs, move tree to Completed.`
  Acceptance: `All prior leaves done; scripts/check_memory_architecture.sh PASS; tools/run_ci_local.sh PASS (phase0 baseline unchanged — no code changed); ROADMAP_V2.md Phase 8 row reflects status; MEMORY.md updated; tree in Completed.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `PHASE8-MULTI-BACKEND-HANDOFF.5` | `pending` | Runtime semantics — depends on .2 (grammar) and .4 (helpers) for cross-references. |
| 2 | `PHASE8-MULTI-BACKEND-HANDOFF.6` | `pending` | Test corpus — depends on .2 (grammar) and .5 (semantics) to encode correct expectations. |
| 4 | `PHASE8-MULTI-BACKEND-HANDOFF.4` | `pending` | Helper catalog — extraction/formalization of existing Contracts.pm + USER_GUIDE content. |
| 5 | `PHASE8-MULTI-BACKEND-HANDOFF.5` | `pending` | Runtime semantics — depends on .2 (grammar) and .4 (helpers) for cross-references. |
| 6 | `PHASE8-MULTI-BACKEND-HANDOFF.6` | `pending` | Test corpus — depends on .2 (grammar) and .5 (semantics) to encode correct expectations. |
| 7 | `PHASE8-MULTI-BACKEND-HANDOFF.7` | `pending` | mdBook handoff — links all prior artifacts; depends on .1–.6 being substantially complete. |
| 8 | `PHASE8-MULTI-BACKEND-HANDOFF.8` | `pending` | Finalization — gates on all prior leaves done. |

## Decisions

- `2026-06-14`: This is a **specification-only** tree — zero code changes. The Perl backend is unchanged. Every deliverable is a document or test artifact.
- `2026-06-14`: The formal grammar (.2) targets engineering precision, not formal methods. It must be unambiguous enough for independent reimplementation but does not need BNF/EBNF formality.
- `2026-06-14`: The test corpus (.6) uses JSON because it's the most universally parseable format across Rust/Julia/Dart/Perl. Test entries are input `.spec` + expected parse result — not expected Perl internal state.
- `2026-06-14`: Leaves .2 and .3 can run in parallel (grammar and HandlerIR are independent). Leaves .5 and .6 depend on earlier specs. Leaf .7 gates on substantial completion of .1–.6.

## Open Questions

- Exact format of the test corpus JSON schema — resolve during .6.
- Whether the formal grammar should live as a standalone file or an mdBook chapter — resolve during .2.
- Whether the helper catalog should be one large file or one-per-family — resolve during .4.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-14` | `PHASE8-MULTI-BACKEND-HANDOFF.1` | `scripts/check_memory_architecture.sh` PASS; ADR 0006 created + INDEX.md updated | PASS |
| `2026-06-14` | `PHASE8-MULTI-BACKEND-HANDOFF.2` | `scripts/check_memory_architecture.sh` PASS; formal-grammar.md created (12 sections), SUMMARY.md updated | PASS |
| `2026-06-14` | `PHASE8-MULTI-BACKEND-HANDOFF.3` | `scripts/check_memory_architecture.sh` PASS; handler-ir-design.md created, old card placeholder fixed | PASS |
| `2026-06-14` | `PHASE8-MULTI-BACKEND-HANDOFF.4` | `scripts/check_memory_architecture.sh` PASS; helper-contract-catalog.md created (10 families, cross-cutting contracts) | PASS |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `pending` | `pending` | `pending` |

## Changelog

- `2026-06-14`: Created task tree — 8 leaves covering ADR, formal grammar, HandlerIR spec, helper catalog, runtime semantics, test corpus, mdBook handoff, and finalization.
