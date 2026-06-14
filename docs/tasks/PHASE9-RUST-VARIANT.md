# PHASE9-RUST-VARIANT: Rust LinkedSpec Implementation

## Metadata

- Tree ID: `PHASE9-RUST-VARIANT`
- Status: `active`
- Roadmap lane: `Phase 9 — Rust variant implementation`
- Created: `2026-06-14`
- Last updated: `2026-06-14`
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
  Status: `active`
  Goal: `Implement a working Rust variant of LinkedSpec.`
  Children: `.1, .2, .3, .4, .5, .6, .7, .8, .9, .10`

### Container: Core Infrastructure (.1–.3)

- ID: `PHASE9-RUST-VARIANT.1`
  Status: `active`
  Goal: `Project bootstrap — Cargo workspace, crate structure, core types.`
  Children: `.1.1, .1.2`

- ID: `PHASE9-RUST-VARIANT.1.1`
  Status: `pending`
  Goal: `Create Cargo workspace with linkedspec-core and linkedspec-runtime crates. Configure dependencies (regex, serde, thiserror).`
  Acceptance: `cargo build passes; workspace compiles clean.`
  Verification: `pending`
  Commit: `pending`

- ID: `PHASE9-RUST-VARIANT.1.2`
  Status: `pending`
  Goal: `Define core types: SpecFile, Rule, RuleHeader, RuleMode, BodyElement, Lifecycle, Edge, RegexCluster, HandlerIR, ParseMode. Use serde for JSON serialization.`
  Acceptance: `Core types compile; serde Serialize/Deserialize derived; JSON round-trip test passes.`
  Verification: `pending`
  Commit: `pending`

### Container: .spec Parser (.2)

- ID: `PHASE9-RUST-VARIANT.2`
  Status: `active`
  Goal: `.spec parser — reads .spec files into AST.`
  Children: `.2.1, .2.2, .2.3`

- ID: `PHASE9-RUST-VARIANT.2.1`
  Status: `pending`
  Goal: `Implement paragraph-level parser: split file into rule paragraphs, parse rule headers (label, colon type, mode).`
  Acceptance: `Parses rule headers correctly for all mode variants (AND, OR, +, *, ?, {N,M} forms). Tests cover all mode spellings.`
  Verification: `pending`
  Commit: `pending`

- ID: `PHASE9-RUST-VARIANT.2.2`
  Status: `pending`
  Goal: `Implement body element parser: regex clusters, action edges, blind-call edges, code blocks, split markers, lifecycle markers, fluent chains.`
  Acceptance: `Parses all 12 body element types. Tests cover each type with representative examples.`
  Verification: `pending`
  Commit: `pending`

- ID: `PHASE9-RUST-VARIANT.2.3`
  Status: `pending`
  Goal: `Implement validation: duplicate rule detection, mixed-edge rejection, unclosed block detection, top-rule requirement.`
  Acceptance: `Validation errors correctly reported for each violation type. Valid specs pass.`
  Verification: `pending`
  Commit: `pending`

### Container: Compiler (.3)

- ID: `PHASE9-RUST-VARIANT.3`
  Status: `active`
  Goal: `Compiler — transforms parsed AST into HandlerIR.`
  Children: `.3.1, .3.2`

- ID: `PHASE9-RUST-VARIANT.3.1`
  Status: `pending`
  Goal: `Implement rule-level compilation: resolve rule dependencies, determine handler variant kind, assemble lifecycle code blocks.`
  Acceptance: `Produces correct variant kind for AND/OR/REP rules with acode/bcode children.`
  Verification: `pending`
  Commit: `pending`

- ID: `PHASE9-RUST-VARIANT.3.2`
  Status: `pending`
  Goal: `Implement HandlerIR assembly: build complete HandlerIR nodes with all lifecycle slots, dispatch refs, repetition bounds.`
  Acceptance: `HandlerIR nodes structurally match the HandlerIR specification. JSON serialization round-trip.`
  Verification: `pending`
  Commit: `pending`

### Container: Runtime (.4)

- ID: `PHASE9-RUST-VARIANT.4`
  Status: `active`
  Goal: `Runtime engine — execute compiled handlers.`
  Children: `.4.1, .4.2, .4.3`

- ID: `PHASE9-RUST-VARIANT.4.1`
  Status: `pending`
  Goal: `Implement regex engine: position-tracked matching, seek vs consume modes, alternative identification.`
  Acceptance: `Regex engine correctly identifies which alternative matched and advances position. Tests cover seek, consume, and no-match paths.`
  Verification: `pending`
  Commit: `pending`

- ID: `PHASE9-RUST-VARIANT.4.2`
  Status: `pending`
  Goal: `Implement lifecycle executor: I/LS/LE/E/EX/IT/LX execution order, variable store (declare/assign), accumulator arrays.`
  Acceptance: `Lifecycle blocks execute in correct order. Variables are scoped per rule invocation. Accumulators collect child results.`
  Verification: `pending`
  Commit: `pending`

- ID: `PHASE9-RUST-VARIANT.4.3`
  Status: `pending`
  Goal: `Implement handler dispatch: AND sequential, OR first-match-wins, repetition bounds, zero-progress guard.`
  Acceptance: `AND rules dispatch sequentially. OR rules use first-match-wins. REP bounds enforced. Zero-progress guard prevents hangs.`
  Verification: `pending`
  Commit: `pending`

### Container: Core Helpers (.5)

- ID: `PHASE9-RUST-VARIANT.5`
  Status: `active`
  Goal: `Core helper implementations — enough to run the test corpus.`
  Children: `.5.1, .5.2, .5.3`

- ID: `PHASE9-RUST-VARIANT.5.1`
  Status: `pending`
  Goal: `Implement declaration and array helpers: declare, assign, array, array_copy, push_value, count, return.`
  Acceptance: `Declare/assign work with type tracking. Array push/read works. Tests pass.`
  Verification: `pending`
  Commit: `pending`

- ID: `PHASE9-RUST-VARIANT.5.2`
  Status: `pending`
  Goal: `Implement scalar and capture helpers: entry_group, entry_text, scalar, coalesce, concat, capture helpers.`
  Acceptance: `Capture groups extracted correctly. Scalar read from array/hash works. Coalesce short-circuits.`
  Verification: `pending`
  Commit: `pending`

- ID: `PHASE9-RUST-VARIANT.5.3`
  Status: `pending`
  Goal: `Implement control flow: if/elseif/else, switch/case/default, return_undef, next, exit_now.`
  Acceptance: `If/else evaluation works. Switch dispatch works. exit_now terminates parser.`
  Verification: `pending`
  Commit: `pending`

### Container: Integration (.6–.7)

- ID: `PHASE9-RUST-VARIANT.6`
  Status: `active`
  Goal: `End-to-end integration — compile and run a spec.`
  Children: `.6.1`

- ID: `PHASE9-RUST-VARIANT.6.1`
  Status: `pending`
  Goal: `Wire the full pipeline: parse .spec → compile → emit Rust code → execute against input → return result. Test with simple_grammar.`
  Acceptance: `simple_grammar test corpus entry produces structurally equivalent output.`
  Verification: `pending`
  Commit: `pending`

### Container: Test Corpus Validation (.7)

- ID: `PHASE9-RUST-VARIANT.7`
  Status: `active`
  Goal: `Test corpus compliance.`
  Children: `.7.1`

- ID: `PHASE9-RUST-VARIANT.7.1`
  Status: `pending`
  Goal: `Implement test corpus runner: load corpus entries, compile specs, parse inputs, compare to expected.json. Add corpus entries to CI.`
  Acceptance: `cargo test --test corpus passes all seeded entries. Output structurally equivalent to expected.json.`
  Verification: `pending`
  Commit: `pending`

### Container: Code Generation (.8)

- ID: `PHASE9-RUST-VARIANT.8`
  Status: `active`
  Goal: `HandlerIR → Rust source code emitter.`
  Children: `.8.1`

- ID: `PHASE9-RUST-VARIANT.8.1`
  Status: `pending`
  Goal: `Implement Rust code-gen emitter for all 10 HandlerIR variant kinds. Emit compilable Rust source from HandlerIR nodes.`
  Acceptance: `All 10 variants emit valid Rust code. Generated code compiles and executes correctly.`
  Verification: `pending`
  Commit: `pending`

### Container: Documentation (.9)

- ID: `PHASE9-RUST-VARIANT.9`
  Status: `active`
  Goal: `Documentation and project integration.`
  Children: `.9.1, .9.2`

- ID: `PHASE9-RUST-VARIANT.9.1`
  Status: `pending`
  Goal: `Write rust/README.md with build instructions, architecture overview, and relationship to Perl reference.`
  Acceptance: `README exists with clear getting-started, architecture diagram, and cross-reference to specifications.`
  Verification: `pending`
  Commit: `pending`

- ID: `PHASE9-RUST-VARIANT.9.2`
  Status: `pending`
  Goal: `Update ROADMAP_V2.md, ROADMAP.md, mdBook (project-status.md), MEMORY.md, and CHANGES.md to reflect Phase 9 progress.`
  Acceptance: `All live docs updated. ROADMAP_V2 Phase 9 row reflects current status.`
  Verification: `pending`
  Commit: `pending`

### Container: Finalization (.10)

- ID: `PHASE9-RUST-VARIANT.10`
  Status: `active`
  Goal: `Finalization and close-out.`
  Children: `.10.1`

- ID: `PHASE9-RUST-VARIANT.10.1`
  Status: `pending`
  Goal: `Final verification: cargo test full pass, cargo clippy clean, memory-arch check, move tree to Completed.`
  Acceptance: `All tests pass. Clippy clean. Memory-arch check passes. Tree in Completed.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `PHASE9-RUST-VARIANT.1.1` | `pending` | Project bootstrap — create workspace before any code. |
| 2 | `PHASE9-RUST-VARIANT.1.2` | `pending` | Core types — foundation for all subsequent work. |

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
| `pending` | `pending` | `pending` | `pending` |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- | --- |
| `pending` | `pending` | `pending` |

## Changelog

- `2026-06-14`: Created task tree — 10 containers, 17 leaves covering bootstrap, parser, compiler, runtime, helpers, integration, test corpus, code-gen, docs, and finalization.
