# RUST-EDGE-SEMANTICS: Fix Rust `->` edge dispatch to match Perl semantics

## Metadata

- Tree ID: `RUST-EDGE-SEMANTICS`
- Status: `active`
- Roadmap lane: `Phase 9 — Rust variant (correctness fix)`
- Created: `2026-06-15`
- Last updated: `2026-06-15`
- Owner: repo-local workflow

## Goal

Fix the Rust compiler and engine so that `->` action edges dispatch correctly.
In the Perl reference, each `-> Child` edge contributes the child rule's entrypoint
regex (at `reidx`) to the parent's dependency_regex_map alternation. The handler
matches against that alternation, and `$$minfo{index}` identifies which child to
dispatch to. The current Rust implementation incorrectly associates edges with
"the most recent regex in the current rule body" instead — rules with only `->`
edges (no explicit `/pattern/` regexes) have empty alternations and never fire.

## Non-Goals

- Does not change `.spec` syntax or bootstrap grammar.
- Does not touch the Perl implementation.
- Does not implement new helper functions or control flow — purely a correctness fix.
- Does not change the brainstorm design direction (captured separately).

## Acceptance Criteria

- `grep::` (and any rule with only `->` edges, zero explicit regexes) fires child
  dispatch correctly through the Rust engine.
- All 20 shipped specs produce structurally equivalent output in Perl and Rust
  for representative inputs.
- `cargo test` passes at current or higher count.
- `cargo clippy` clean (0 errors).
- Memory-architecture check passes.

## Task Tree

- ID: `RUST-EDGE-SEMANTICS`
  Status: `active`
  Goal: `Fix Rust compiler/engine to dispatch -> edges via child regex alternation (Perl build_dependency_regex_map model).`
  Children: `.1, .2, .3, .4`

- ID: `RUST-EDGE-SEMANTICS.1`
  Status: `pending`
  Goal: `Audit: inventory every Rust code path that builds regex patterns from body elements and every engine path that dispatches acode entries. Document the exact gap vs Perl semantics.`
  Acceptance: `A section in this tree (or a knowledge card) listing: (a) compiler.rs lines that build regex_patterns from BodyElementKind::Regex, (b) compiler.rs lines that build AcodeEntry with regex_idx, (c) engine.rs lines that match regex alternation and dispatch acode entries, (d) the delta vs Perl dependency_regex_map + emit.`
  Verification: `pending`
  Commit: `pending`

- ID: `RUST-EDGE-SEMANTICS.2`
  Status: `pending`
  Goal: `Rewrite compiler.rs to build regex patterns from child rule dependency refs. For each ACODE entry, add the child rule's entrypoint regex (at reidx) to the parent's regex_patterns. Recompute acode dispatch indices to align with the alternation order.`
  Acceptance: `Compiler output for grep:: includes regexes from re_term, or_op, and_op, group. AcodeEntry.regex_idx maps to alternation position. Existing tests still pass.`
  Verification: `pending`
  Commit: `pending`

- ID: `RUST-EDGE-SEMANTICS.3`
  Status: `pending`
  Goal: `Add regression tests: (a) rule with only -> edges dispatches correctly, (b) rule with mixed /regex/ and -> edges, (c) self-recursive rule with -> same_rule[N], (d) -> A | B { code } grouped targets. Test against representative inputs with expected output.`
  Acceptance: `New tests pass. All 20 shipped specs compile and produce output.`
  Verification: `pending`
  Commit: `pending`

- ID: `RUST-EDGE-SEMANTICS.4`
  Status: `pending`
  Goal: `Final verification: cargo test full pass, cargo clippy clean, memory-arch check, update TASK_TREE.md, mark tree done.`
  Acceptance: `Tree moved to Completed. MEMORY.md handoff-ready.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `RUST-EDGE-SEMANTICS.1` | `pending` | Audit the gap before making changes. |

## Decisions

- `2026-06-15`: Confirmed through Perl bootstrap/compiler/HandlerVariantEmitter analysis that `->` dispatch works via `dependency_regex_map` — child rule regexes are compiled into the parent's LinkedRE alternation. The Rust implementation's "preceding regex" model is incorrect.

## Open Questions

- None.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `pending` | `pending` | `pending` | `pending` |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `pending` | `pending` | `pending` |

## Changelog

- `2026-06-15`: Created task tree — 4 leaves covering audit, compiler rewrite, regression tests, finalization.
