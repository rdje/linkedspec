# RUST-PARITY: Bring Rust Variant to Full Parity with Perl Reference

## Metadata

- Tree ID: `RUST-PARITY`
- Status: `active`
- Roadmap lane: `Phase 9 — Rust variant (parity follow-on)`
- Created: `2026-06-16`
- Last updated: `2026-06-16`
- Owner: repo-local workflow

## Goal

Bring the Rust variant (`rust/`) to full behavioral parity with the Perl reference
implementation across all deferred v1 gaps: conditional flow, BACKTRACK, self-hosting,
remaining helpers, strict_syntax, test corpus expansion, and code-gen emitter.

## Non-Goals

- Plugin/legacy support (PluginBridge, PPlugin, .plg) — Perl-specific, out of scope
- Wasm/Julia/Dart backends — ADR 0006 envisions these but they are not this tree
- Architecture convergence — Rust keeps its native pipeline (parse→AST→CompiledSpec→interpret)

## Acceptance Criteria

- All deferred gap items implemented to functional parity with Perl
- All existing 166 Rust tests pass
- New tests added for each gap closed
- `cargo test` and `cargo clippy` clean in `rust/`
- Live docs updated (ROADMAP_V2.md, CHANGES.md, DEVELOPMENT_NOTES.md, MEMORY.md)
- Each completed leaf committed through `COMMIT.md`

## Task Tree

- ID: `RUST-PARITY`
  Status: `active`
  Goal: Bring Rust variant to full parity with Perl reference
  Children: `.1`, `.2`, `.3`, `.4`, `.5`, `.6`, `.7`, `.8`, `.9`

- ID: `RUST-PARITY.1`
  Status: `done`
  Goal: Complete gap inventory — list exact Perl features not yet in Rust with file:line references
  Acceptance: Inventory document with categorized gaps, Perl reference locations, and Rust locations where implementation is needed
  Verification: Done — 2026-06-16: full audit of Rust `engine.rs` (1984 lines, 84 helpers) and `helpers.rs` (470 lines, regex engine) against Perl `LinkedSpec::ActionIR::*` lowering owners. Inventory recorded below.
  Commit: `pending`

- ID: `RUST-PARITY.2`
  Status: `done`
  Goal: Implement conditional control flow — if/elseif/else and switch/case/default
  Acceptance: if/elseif/else/endif and switch/case/default/endswitch interpreters working in Rust runtime; regression tests; all existing tests pass
  Verification: Done — 2026-06-16: 177/177 PASS (86 core + 8 types + 67 engine + 16 integration). 12 new tests: 4 if/elseif/else, 3 switch/case/default, 2 lazy evaluation, 2 no-op markers, 1 combined. Lazy evaluation via `call_helper_lazy` + `eval_expr` intercept for conditional flow calls.
  Commit: `pending`

- ID: `RUST-PARITY.3`
  Status: `done`
  Goal: Implement BACKTRACK/IBACKTRACK cursor save/restore
  Acceptance: BACKTRACK saves cursor, IBACKTRACK restores it; regression tests covering both markers; all existing tests pass
  Verification: Done — 2026-06-16: 181/181 PASS. `backtrack_stack: Vec<usize>` added to RuntimeContext with `push_backtrack()`/`pop_backtrack()`. 4 new tests: save/restore, retry restore, empty stack no-op, multiple push/pop.
  Commit: `pending`

- ID: `RUST-PARITY.4`
  Status: `pending`
  Goal: Implement self-hosting — Rust compiles and runs spec.spec against itself
  Acceptance: spec.spec compiles in Rust; Rust can parse .spec files using the spec.spec grammar (not just bootstrap); regression test; all existing tests pass
  Verification: `pending`
  Commit: `pending`

- ID: `RUST-PARITY.5`
  Status: `pending`
  Goal: Implement remaining helpers not yet in Rust (capture/mark extensions, entry/match detail, flow refinements)
  Acceptance: All helpers from Perl's 100+ surface present in Rust; regression tests per helper family; all existing tests pass
  Verification: `pending`
  Commit: `pending`

- ID: `RUST-PARITY.6`
  Status: `pending`
  Goal: Implement strict_syntax validation mode
  Acceptance: strict_syntax mode rejects reference warnings as hard errors; test covering strict mode
  Verification: `pending`
  Commit: `pending`

- ID: `RUST-PARITY.7`
  Status: `pending`
  Goal: Expand Rust test corpus to match Perl's regression coverage breadth
  Acceptance: All 20 shipped specs exercised in Rust integration tests; corpus files added to tests/corpus/; regression guard
  Verification: `pending`
  Commit: `pending`

- ID: `RUST-PARITY.8`
  Status: `pending`
  Goal: Implement code-gen emitter — HandlerIR to Rust source generation
  Acceptance: Rust source emitter produces compilable Rust from HandlerIR nodes; test proving generated code compiles and runs
  Verification: `pending`
  Commit: `pending`

- ID: `RUST-PARITY.9`
  Status: `pending`
  Goal: Documentation sync and finalization — update book, roadmap, live docs
  Acceptance: ROADMAP_V2.md tracker updated; CHANGES.md + DEVELOPMENT_NOTES.md + MEMORY.md updated; book backend-handoff.md refreshed; ARCHITECTURE_STATE.md updated
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `RUST-PARITY.4` | `pending` | Self-hosting — Rust compiles and runs spec.spec against itself |

## Decisions

- `2026-06-16`: Created task tree. Conditional flow (if/switch) is priority after inventory because it's the largest feature gap affecting the most specs. Code-gen emitter is last because interpreted mode works and emitter needs stable HandlerIR shapes.
- `2026-06-16` (`.1`): Inventory complete. 6 gap categories identified.
- `2026-06-16` (`.2`): Conditional flow landed. Lazy evaluation required modifying `eval_expr` to intercept `if`/`switch`/`elseif`/`else`/`case`/`default` before eager arg evaluation. New method `call_helper_lazy` added. 12 new tests. 177/177 PASS.

## Open Questions

- None yet — inventory leaf will identify any.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-16` | `RUST-PARITY.1` | Full audit: Rust sources (`engine.rs:1984`, `helpers.rs:470`, `compiler.rs`, `parser.rs`, `validation.rs`) vs Perl lowering owners (`ControlFlow.pm`, `MethodLowering.pm`, `ValueExpr.pm`, `FlowExpr.pm`, `Contracts.pm`) | Done — 6 gap categories, 84/100+ helpers implemented |

### RUST-PARITY.1 Inventory — 2026-06-16

**Gap 1: Conditional control flow (largest gap)**
- `if(cond, then, elseif(...), else(...))` / `if(cond) { ... } elseif(cond) { ... } else { ... }` / `endif()`
- `switch(expr) { case(val) { ... } default { ... } }` / `endswitch()` / `endcase()`
- Perl owners: `ActionIR::ControlFlow.pm` (~20 lowering subs), `ActionIR::FlowExpr.pm`
- Rust: `engine.rs` has no if/elseif/else/switch/case/default match arms

**Gap 2: BACKTRACK/IBACKTRACK**
- `BACKTRACK` saves cursor position, `IBACKTRACK` restores it (local rewind, not systemic backtracking)
- Perl: `ActionIR::MethodLowering.pm`, `RuntimeContext` cursor stack
- Rust: `RuntimeContext` has `pos` and `capture_start` but no cursor stack

**Gap 3: Self-hosting (spec.spec)**
- Rust cannot compile and run `specs/spec.spec` through itself
- Perl: `BootstrapSpec.pm` + `spec.spec` → dual-path parse (bootstrap primary, spec.spec as diagnostic side channel)
- Rust: only bootstrap-style parser in `parser.rs` — no spec.spec-based self-parse path

**Gap 4: strict_syntax validation mode**
- Perl: `Validation.pm` `validate_dsl_syntax(...)` with `strict_syntax => 1` promotes reference warnings to hard errors
- Rust: `validation.rs` has 6 checks but no `strict_syntax` mode

**Gap 5: Remaining helpers** (implemented = ✓, missing = ✗)
- Capture/mark extensions: `capture_len_from` ✗, `capture_until_cursor_from` ✗, `capture_until_cursor_len_from` ✗, `capture_take_until_cursor_from` ✗, `capture_take_until_cursor_len_from` ✗, `capture_take_len_from` ✗, `capture_rest_from` ✗, `capture_rest_len_from` ✗, `capture_take_rest_from` ✗, `capture_take_rest_len_from` ✗, `capture_between` ✗, `capture_len_between` ✗, `mark_copy` ✗, `mark_input_start` ✗, `mark_input_end` ✗
- Entry/match named: `entry_named` ✗, `entry_has` ✗, `entry_map`/`entry_named_map` ✗, `match_named` ✗, `match_has` ✗, `match_map`/`match_named_map` ✗
- Input boundaries: `input_end_line` ✗, `input_end_col` ✗
- Anonymous capture variants: `capture_slice_until_cursor` ✗, `capture_slice_until_cursor_len` ✗, `capture_take_until_cursor` ✗, `capture_take_until_cursor_len` ✗, `capture_take_len` ✗, `capture_take_rest` ✗, `capture_take_rest_len` ✗
- Return helpers: `return(expr)` ✓ (general return works), but `return_imatch`/`return_im` ✗ (compat aliases — low priority)
- Compat aliases: `tail(...)` ✗, `drop_last(...)` ✗ (aliases for `drop_front`/`drop_back`), `array_values(...)` ✗, `flatten(...)` ✗ (aliases for `array_copy`/`flat`)
- `IBACKTRACK` cursor-seek ✗ (tied to Gap 2)

**Gap 6: Code-gen emitter**
- Perl: `HandlerVariantEmitter.pm` dispatches to `%BACKEND_EMITTERS` (Perl default, JSON/AST diagnostic)
- Rust: interpreter-only mode — no `HandlerIR → Rust source` emitter
- Deferred in v0.1 design — needed for `cargo build`-able parser output

**Gap 7: Test corpus breadth**
- Rust `tests/corpus/`: 4 entries (simple_grammar, recursive, lifecycle, AND+REP)
- Perl `t/phase0_regression.t`: 1005 subtests across 20 shipped specs
- All 20 shipped specs parse+validate+compile in Rust (serde roundtrip), but only 4 exercised in runtime execution

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `pending` | `pending` | `pending` |

## Changelog

- `2026-06-16`: Created task tree.
