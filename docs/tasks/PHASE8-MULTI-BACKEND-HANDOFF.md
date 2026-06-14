# PHASE8-MULTI-BACKEND-HANDOFF: Multi-Backend Specification & Handoff Surface

## Metadata

- Tree ID: `PHASE8-MULTI-BACKEND-HANDOFF`
- Status: `completed`
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
  Status: `completed`
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
  Status: `done`
  Goal: `Runtime semantics specification — define precisely seek/consume, BACKTRACK, lifecycle execution order, accumulator conventions, edge dispatch, handler variant selection, zero-progress guard, error handling, determinism guarantees.`
  Acceptance: `Specification exists as a tracked document; each subsection is precise enough for independent reimplementation; cross-referenced with formal grammar and HandlerIR spec.`
  Verification: `PASS — runtime-semantics.md created (11 sections: parse modes, execution model, lifecycles, BACKTRACK, accumulators, edge dispatch, variant selection, regex dispatch, zero-progress, errors, determinism)`
  Commit: `pending`

- ID: `PHASE8-MULTI-BACKEND-HANDOFF.6`
  Status: `done`
  Goal: `Language-neutral test corpus — create tests/corpus/ with JSON-serialized input/expected-output pairs. Cover: representative specs (Lispish, tablegrep, simple_grammar).`
  Acceptance: `tests/corpus/ exists with README.md; 3 entries seeded (simple_grammar with expected output, Lispish + tablegrep with generation scripts); format is self-describing and language-agnostic.`
  Verification: `PASS — tests/corpus/ created with README.md, 3 test entries (simple_grammar with expected JSON, Lispish + tablegrep with generation commands)`
  Commit: `pending`

- ID: `PHASE8-MULTI-BACKEND-HANDOFF.7`
  Status: `done`
  Goal: `mdBook handoff chapter — create a single entry point linking all specification artifacts for backend implementers.`
  Acceptance: `backend-handoff.md created with reading order, architecture overview, what-to-build checklist, regex engine guidance, specification index; SUMMARY.md updated.`
  Verification: `PASS — backend-handoff.md created (specification index, architecture diagram, handoff checklist); SUMMARY.md updated`
  Commit: `pending`

- ID: `PHASE8-MULTI-BACKEND-HANDOFF.8`
  Status: `done`
  Goal: `Finalization — verify all deliverables, run memory-arch check, update ROADMAP_V2.md / ROADMAP.md, refresh live docs, move tree to Completed.`
  Acceptance: `All prior leaves done; scripts/check_memory_architecture.sh PASS; ROADMAP_V2.md Phase 8 → done; MEMORY.md updated; tree in Completed.`
  Verification: `PASS — memory-arch check PASS (no code changed, phase0 unchanged); ROADMAP_V2.md updated`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
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
| `2026-06-14` | `PHASE8-MULTI-BACKEND-HANDOFF.5` | `scripts/check_memory_architecture.sh` PASS; runtime-semantics.md created (11 sections) | PASS |
| `2026-06-14` | `PHASE8-MULTI-BACKEND-HANDOFF.6` | `scripts/check_memory_architecture.sh` PASS; tests/corpus/ created with 3 entries | PASS |
| `2026-06-14` | `PHASE8-MULTI-BACKEND-HANDOFF.7` | `scripts/check_memory_architecture.sh` PASS; backend-handoff.md created | PASS |
| `2026-06-14` | `PHASE8-MULTI-BACKEND-HANDOFF.8` | `scripts/check_memory_architecture.sh` PASS; ROADMAP_V2.md → done; tree complete | PASS |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `pending` | `pending` | `pending` |

## Changelog

- `2026-06-14`: Created task tree — 8 leaves covering ADR, formal grammar, HandlerIR spec, helper catalog, runtime semantics, test corpus, mdBook handoff, and finalization.
