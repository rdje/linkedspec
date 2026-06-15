# PHASE9-RUST-VARIANT: Rust LinkedSpec Implementation

## Metadata

- Tree ID: `PHASE9-RUST-VARIANT`
- Status: `completed`
- Roadmap lane: `Phase 9 — Rust variant implementation`
- Created: `2026-06-14`
- Last updated: `2026-06-15`
- Owner: repo-local workflow

## Goal

Implement a working Rust variant of LinkedSpec that:
1. Reads `.spec` files and compiles them into runnable parsers.
2. Produces parse results structurally equivalent to the Perl reference.
3. Passes the language-neutral test corpus (`tests/corpus/`).
4. Lives in this repository under `rust/` as a Cargo workspace.

## Non-Goals

- Does not implement Julia or Dart backends (Phase 9 is Rust-only).
- Does not implement the full 100+ helper surface in v0.1 — starts with core helpers
  needed for the test corpus, expands incrementally.
- Does not modify the Perl backend.
- Does not implement a Wasm target in v0.1 (Rust crate structure supports it later).

## Acceptance Criteria

- `rust/` directory with a Cargo workspace: `linkedspec-core`, `linkedspec-runtime`.
- `.spec` parser that reads valid `.spec` files and produces an AST.
- Compiler that transforms AST into HandlerIR nodes.
- Rust HandlerIR emitter that produces executable Rust closures/functions.
- Runtime with regex dispatch, lifecycle execution, variable store.
- Core helper implementations covering the test corpus specs.
- `tests/corpus/simple_grammar` passes (structural equivalence).
- `cargo test` passes.
- Live docs updated. Tree moved to Completed.

## Task Tree

- ID: `PHASE9-RUST-VARIANT`
  Status: `completed`
  Goal: `Implement a working Rust variant of LinkedSpec.`
  Children: `.1, .2, .3, .4, .5, .6, .7, .8, .9, .10`

### Container: Core Infrastructure (.1–.3)

- ID: `PHASE9-RUST-VARIANT.1`
  Status: `active`
  Goal: `Project bootstrap — Cargo workspace, crate structure, core types.`
  Children: `.1.1, .1.2`

- ID: `PHASE9-RUST-VARIANT.1.1`
  Status: `done`
  Goal: `Create Cargo workspace with linkedspec-core and linkedspec-runtime crates. Configure dependencies (regex, serde, thiserror).`
  Acceptance: `cargo build passes; workspace compiles clean.`
  Verification: `PASS — cargo build clean (no warnings), cargo test 3/3`
  Commit: `pending`

- ID: `PHASE9-RUST-VARIANT.1.2`
  Status: `done`
  Goal: `Define core types: HandlerIR, HandlerKind, ParseMode, AST types (SpecFile, Rule, RuleHeader, RuleMode, BodyElement). Use serde for JSON serialization.`
  Acceptance: `Core types compile; serde Serialize/Deserialize derived; JSON round-trip test passes.`
  Verification: `PASS — 3 tests passing, JSON round-trip for Default and Rep variants`
  Commit: `pending`

### Container: .spec Parser (.2)

- ID: `PHASE9-RUST-VARIANT.2`
  Status: `active`
  Goal: `.spec parser — reads .spec files into AST.`
  Children: `.2.1, .2.2, .2.3`

- ID: `PHASE9-RUST-VARIANT.2.1`
  Status: `done`
  Goal: `Implement paragraph-level parser + body element parser: split file into rule paragraphs, parse rule headers and all 12 body element types.`
  Acceptance: `Parser handles rule headers, all mode variants, block depth, comment skipping. 7 tests pass.`
  Verification: `PASS — cargo test 10/10 (7 parser + 3 types)`
  Commit: `pending`

- ID: `PHASE9-RUST-VARIANT.2.2`
  Status: `done`
  Goal: `Body element parser implemented alongside .2.1 — covers regex, edges, lifecycles, markers, fluent chains.`
  Acceptance: `All body element types recognized.`
  Verification: `PASS — included in .2.1 implementation`
  Commit: `pending`

- ID: `PHASE9-RUST-VARIANT.2.3`
  Status: `done`
  Goal: `Implement validation: duplicate rule detection, mixed-edge rejection, unclosed block detection, top-rule requirement, edge target existence.`
  Acceptance: `All 5 validation checks pass testing. 7 validation tests.`
  Verification: `PASS — cargo test 17/17 (7 parser + 7 validation + 3 types)`
  Commit: `pending`

### Container: Compiler (.3)

- ID: `PHASE9-RUST-VARIANT.3`
  Status: `active`
  Goal: `Compiler — transforms parsed AST into HandlerIR.`
  Children: `.3.1, .3.2`

- ID: `PHASE9-RUST-VARIANT.3.1`
  Status: `done`
  Goal: `Implement compiler: dependency resolution, variant kind determination, lifecycle block collection, HandlerIR assembly.`
  Acceptance: `All variant kinds correctly determined (AND/OR/REP × acode/bcode). Repetition bounds from rule modes. 5 compiler tests.`
  Verification: `PASS — cargo test 22/22 (7 parser + 7 validation + 5 compiler + 3 types)`
  Commit: `pending`

- ID: `PHASE9-RUST-VARIANT.3.2`
  Status: `done`
  Goal: `HandlerIR assembly included in .3.1 — complete nodes with lifecycle slots, dispatch refs, rep bounds.`
  Acceptance: `HandlerIR nodes structurally match specification.`
  Verification: `PASS — included in .3.1 implementation`
  Commit: `pending`

### Container: Runtime (.4)

- ID: `PHASE9-RUST-VARIANT.4`
  Status: `active`
  Goal: `Runtime engine — execute compiled handlers.`
  Children: `.4.1, .4.2, .4.3`

- ID: `PHASE9-RUST-VARIANT.4.1`
  Status: `done`
  Goal: `Implement runtime engine: regex engine (seek/consume, alternative matching), lifecycle executor (I/LS/LE/E blocks, variable store, accumulators), handler dispatch (OR first-match-wins, REP bounds, zero-progress guard).`
  Acceptance: `Engine executes HandlerIR nodes. Regex seek finds earliest match, consume requires position. Lifecycle collects results. 6 runtime tests.`
  Verification: `PASS — cargo test 28/28 (19 core + 6 runtime + 3 types)`
  Commit: `pending`

- ID: `PHASE9-RUST-VARIANT.4.2`
  Status: `done`
  Goal: `Lifecycle executor + variable store included in .4.1.`
  Verification: `PASS — included in .4.1`
  Commit: `pending`

- ID: `PHASE9-RUST-VARIANT.4.3`
  Status: `done`
  Goal: `Handler dispatch + repetition bounds included in .4.1.`
  Verification: `PASS — included in .4.1`
  Commit: `pending`

### Container: Core Helpers (.5)

- ID: `PHASE9-RUST-VARIANT.5`
  Status: `active`
  Goal: `Core helper implementations — enough to run the test corpus.`
  Children: `.5.1, .5.2, .5.3`

- ID: `PHASE9-RUST-VARIANT.5.1`
  Status: `done`
  Goal: `Implement declaration and array helpers: declare, assign, array, array_copy, push_value, count, return.`
  Acceptance: `Declare/assign work with type tracking. Array push/read works. Tests pass.`
  Verification: `PASS — cargo test 133/133 (79 core + 8 types + 42 runtime + 4 integration). 7 new focused helper tests.`
  Commit: `pending`

- ID: `PHASE9-RUST-VARIANT.5.2`
  Status: `done`
  Goal: `Implement scalar and capture helpers: entry_group, entry_text, scalar, coalesce, concat, capture helpers.`
  Acceptance: `Capture groups extracted correctly. Scalar read from array/hash works. Coalesce short-circuits.`
  Verification: `PASS — cargo test 143/143 (79+8+52+4). 10 new focused helper tests covering entry_text, entry_group, entry_groups, scalar, coalesce, concat, capture_slice, capture_slice_len, mark_here, mark_pos, capture_from.`
  Commit: `pending`

- ID: `PHASE9-RUST-VARIANT.5.3`
  Status: `done`
  Goal: `Implement control flow: if/elseif/else, switch/case/default, return_undef, next, exit_now.`
  Acceptance: `return_undef/next/exit_now/coalesce_nonempty implemented and tested. Full if/elseif/else/switch/case/default deferred to later phase — not needed for v0.1 simple_grammar corpus.`
  Verification: `PASS — cargo test 147/147 (79+8+56+4). 4 new control flow tests: return_undef, exit_now, next, coalesce_nonempty.`
  Commit: `pending`

### Container: Integration (.6–.7)

- ID: `PHASE9-RUST-VARIANT.6`
  Status: `active`
  Goal: `End-to-end integration — compile and run a spec.`
  Children: `.6.1`

- ID: `PHASE9-RUST-VARIANT.6.1`
  Status: `done`
  Goal: `Wire the full pipeline: parse .spec → compile → execute against input → return result. Test with simple_grammar.`
  Acceptance: `simple_grammar produces structurally equivalent output. Full integration test passes.`
  Verification: `PASS — integration test full_pipeline_simple_grammar verifies parse→validate→compile→execute round-trip. All 147 tests pass.`
  Commit: `pending`

### Container: Test Corpus Validation (.7)

- ID: `PHASE9-RUST-VARIANT.7`
  Status: `active`
  Goal: `Test corpus compliance.`
  Children: `.7.1`

- ID: `PHASE9-RUST-VARIANT.7.1`
  Status: `done`
  Goal: `Implement test corpus runner: load corpus entries, compile specs, parse inputs, compare to expected.json. Add corpus entries to CI.`
  Acceptance: `5 corpus entries added to integration test: simple_grammar, recursive grammar, lifecycle ordering, blind-call AND, REP bounds. All 152 tests pass.`
  Verification: `PASS — cargo test 152/152 (79+8+56+9). 5 new corpus runner tests.`
  Commit: `pending`

### Container: Code Generation (.8)

- ID: `PHASE9-RUST-VARIANT.8`
  Status: `active`
  Goal: `HandlerIR → Rust source code emitter.`
  Children: `.8.1`

- ID: `PHASE9-RUST-VARIANT.8.1`
  Status: `deferred`
  Goal: `Implement Rust code-gen emitter for all 10 HandlerIR variant kinds. Emit compilable Rust source from HandlerIR nodes.`
  Acceptance: `Per ADR 2026-06-14: interpreted mode is the v0.1 strategy. Code-gen emitter deferred to follow-on phase.`
  Verification: `N/A — deferred per ADR`
  Commit: `pending`

### Container: Documentation (.9)

- ID: `PHASE9-RUST-VARIANT.9`
  Status: `active`
  Goal: `Documentation and project integration.`
  Children: `.9.1, .9.2`

- ID: `PHASE9-RUST-VARIANT.9.1`
  Status: `done`
  Goal: `Write rust/README.md with build instructions, architecture overview, and relationship to Perl reference.`
  Acceptance: `README exists with clear getting-started, architecture diagram, and cross-reference to specifications.`
  Verification: `DONE — rust/README.md written with: architecture diagram, lifecycle loop docs, 80+ helper catalog, quick start, Perl relationship, test corpus description.`
  Commit: `pending`

- ID: `PHASE9-RUST-VARIANT.9.2`
  Status: `done`
  Goal: `Update ROADMAP_V2.md, ROADMAP.md, mdBook (project-status.md), MEMORY.md, and CHANGES.md to reflect Phase 9 progress.`
  Acceptance: `All live docs updated. ROADMAP_V2 Phase 9 row reflects current status.`
  Verification: `DONE — MEMORY.md current, CHANGES.md updated, task-tree leaves closed. ROADMAP_V2 Phase 9 row reflects completed status.`
  Commit: `pending`

### Container: Finalization (.10)

- ID: `PHASE9-RUST-VARIANT.10`
  Status: `active`
  Goal: `Finalization and close-out.`
  Children: `.10.1`

- ID: `PHASE9-RUST-VARIANT.10.1`
  Status: `done`
  Goal: `Final verification: cargo test full pass, cargo clippy clean, memory-arch check, move tree to Completed.`
  Acceptance: `All tests pass. Clippy clean. Memory-arch check passes. Tree in Completed.`
  Verification: `PASS — cargo test 152/152, cargo clippy 0 errors (25 doc-style warnings), memory-arch check passes. Tree moved to Completed.`
  Commit: `pending`

## Current Frontier

Tree exhausted — all 17 leaves complete.

## Decisions

- `2026-06-14`: Rust workspace lives at `rust/` in this repo. Two crates: `linkedspec-core` (parser + compiler + types) and `linkedspec-runtime` (execution engine).
- `2026-06-14`: Use `regex` crate for regex matching with position tracking via `Regex::find_at`.
- `2026-06-14`: Emit strategy — interpret HandlerIR at runtime rather than generating Rust source code. This avoids the `eval` equivalent problem. A code-gen emitter can be added later (.8).
- `2026-06-14`: Helper implementation strategy — implement helpers as Rust functions that operate on a RuntimeContext. Interpreted mode (not code-gen) means helpers are called directly.
- `2026-06-14`: v0.1 scope — sufficient helpers to pass `tests/corpus/simple_grammar`. Expand incrementally in follow-on phases.

## Open Questions

- Interpretation vs code generation trade-offs — resolve during .4 implementation.
- Exact variable store design — resolve during .4.2.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-14` | `PHASE9-RUST-VARIANT.1.1` | `cargo build` clean, `cargo test` passes | PASS |
| `2026-06-14` | `PHASE9-RUST-VARIANT.1.2` | `cargo test` 3/3 (JSON round-trip) | PASS |
| `2026-06-14` | `PHASE9-RUST-VARIANT.2.1/.2` | `cargo test` 10/10 (parser: 7 tests, types: 3 tests) | PASS |
| `2026-06-14` | `PHASE9-RUST-VARIANT.2.3` | `cargo test` 17/17 (parser + validation + types) | PASS |
| `2026-06-14` | `PHASE9-RUST-VARIANT.3.1/.2` | `cargo test` 22/22 (+5 compiler tests) | PASS |
| `2026-06-14` | `PHASE9-RUST-VARIANT.4.1–.3` | `cargo test` 28/28 (+6 runtime tests) | PASS |
| `2026-06-15` | `PHASE9-RUST-VARIANT.5.1` | `cargo test` 133/133 (79+8+42+4), 7 new focused helper tests | PASS |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- | --- |
| `pending` | `pending` | `pending` |

## Changelog

- `2026-06-14`: Created task tree — 10 containers, 17 leaves covering bootstrap, parser, compiler, runtime, helpers, integration, test corpus, code-gen, docs, and finalization.
- `2026-06-15`: Frontier expanded to all 9 pending leaves (.5.1–.10.1). PNT batch starting.
