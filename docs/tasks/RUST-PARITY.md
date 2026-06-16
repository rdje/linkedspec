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
  Status: `superseded`
  Goal: Implement self-hosting — Rust compiles and runs spec.spec against itself
  Acceptance: spec.spec compiles in Rust; Rust can parse .spec files using the spec.spec grammar (not just bootstrap); regression test; all existing tests pass
  Verification: Superseded 2026-06-16 — Rust-self-hosting on spec.spec is the wrong target. spec.spec is a Perl-side artifact (rewritten under `SPEC-SPEC-SELFHOST`); the real Rust-parity contract is reproducing `BootstrapSpec::Core` output, not self-hosting spec.spec. Real follow-on = the parity audit findings in Decisions (retv BLOCKER, etc.). In-flight exploration committed as a WIP checkpoint.
  Commit: WIP checkpoint (this session)

- ID: `RUST-PARITY.5`
  Status: `active`
  Goal: Close the real Rust↔Perl parity gaps found by the audit (retv blocker, match/entry split, char-indexing, dead arms, missing helpers)
  Children: `.5.1`, `.5.2`, `.5.3`, `.5.4`, `.5.5`
  Note: Split from a single broad leaf (PNT rule 5 — too broad for one signoff slice). The 3-agent audit in Decisions is the implementation spec. Sequenced retv-first because it gates correct output for nearly every grammar. The "0/20 runtime-tested corpus" gap stays in `.7` (test-corpus breadth).

- ID: `RUST-PARITY.5.1`
  Status: `done`
  Goal: Fix the child-return (retv) propagation BLOCKER
  Acceptance: After `->`/`=>` dispatch, the child rule's `return(expr)` value is propagated to the parent and readable as `retv` (so `scalar(retv)` in an `LE` block resolves to the child result, not undef); the half-built dead `set_retv` is completed or removed; new regression tests cover retv-in-LE across AND/OR/REP dispatch; `cargo test` + `cargo clippy` clean; the 182-test baseline stays green.
  Verification: Done — 2026-06-16. `execute_rule` now returns `Result<RuntimeValue, String>` (the rule's own return value, via a per-invocation save/restore channel in `RuntimeContext`); both `->` (acode) and `=>` (bcode) dispatch sites call `ctx.set_retv(child_retv)` after dispatching, so the parent's attached code / `LE` / `E` read the child result as `scalar(retv)`. `return(expr)` records the channel (still pushes the accumulator — `execute()`'s contract). The dead `set_retv` is now wired in (completed, not removed). `call(child)` returns the child's value and resolves a bare rule-name arg (latent bug fixed — enables the `assign(s(retv), call(child))` reference pattern). 4 new integration tests (acode/OR, blind-call/AND, REP, `call`). `cargo test` = 186 passed (182 baseline + 4), 0 failed; `cargo clippy` adds zero new warnings to `linkedspec-runtime` (lib stays at 16 pre-existing `doc_lazy_continuation` lints).
  Commit: `RUST-PARITY.5.1` (see Commit Log)

- ID: `RUST-PARITY.5.2`
  Status: `pending`
  Goal: Separate `match_*` from `entry_*` (stop unifying them at engine.rs:171-174)
  Acceptance: `match_*` reads the current local match while `entry_*` reads the entry match; nested-match reads diverge correctly; regression test; baseline green; clippy clean.
  Verification: `pending`
  Commit: `pending`

- ID: `RUST-PARITY.5.3`
  Status: `pending`
  Goal: Char-based (not byte) indexing for slicing + cursor line/col; fix hardcoded start positions
  Acceptance: `substr`/`input_slice`/`capture_slice`/`capture_from` and cursor line-col use char offsets (no panic on multibyte UTF-8; parity with Perl's char-based offsets); `entry/match_start_pos` no longer hardcoded to 0; multibyte regression tests; baseline green; clippy clean.
  Verification: `pending`
  Commit: `pending`

- ID: `RUST-PARITY.5.4`
  Status: `pending`
  Goal: Remove duplicate/unreachable match arms; make the REP zero-progress guard check `pos`
  Acceptance: the shadowed arms (`hash`/`h`, `hash_copy`, `print`) are de-duplicated so the correct behavior wins; the REP loop's zero-progress guard actually compares `pos` before/after and breaks on no advance; regression tests; baseline green; clippy clean.
  Verification: `pending`
  Commit: `pending`

- ID: `RUST-PARITY.5.5`
  Status: `pending`
  Goal: Implement the ~30 missing capture/mark/entry/match/input helpers (+ real aliases `tail`/`drop_last`/`flatten`)
  Acceptance: the missing helpers from the `.1` inventory (`capture_*_from`, `capture_between`, `mark_*`, `entry_named/has/map`, `match_named/has/map`, `input_end_line/col`, anonymous capture variants) are implemented to Perl-contract parity, plus the `tail`/`drop_last`/`flatten` aliases; per-family regression tests; baseline green; clippy clean. (`array_values`/`return_imatch`/`return_im` are explicitly NOT added — not real Perl helpers.)
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
| — | `RUST-PARITY.4` | `superseded` | Rust-self-hosting on spec.spec dropped; parity = reproducing BootstrapSpec::Core output (see Decisions audit) |
| — | `RUST-PARITY.5.1` | `done` | retv-propagation BLOCKER fixed (2026-06-16); child return now readable as `scalar(retv)` after `->`/`=>`/REP dispatch |
| 1 | `RUST-PARITY.5.2` | `pending` | match_*/entry_* split (now the retv channel is in place) |
| 2 | `RUST-PARITY.5.3` | `pending` | char-based indexing + cursor line/col |
| 3 | `RUST-PARITY.5.4` | `pending` | dedupe match arms + REP zero-progress guard |
| 4 | `RUST-PARITY.5.5` | `pending` | ~30 missing helpers + real aliases |

(`.5` split per PNT rule 5 — too broad for one signoff slice; `.6`–`.9` unchanged below it.)

## Decisions

- `2026-06-16`: Created task tree. Conditional flow (if/switch) is priority after inventory because it's the largest feature gap affecting the most specs. Code-gen emitter is last because interpreted mode works and emitter needs stable HandlerIR shapes.
- `2026-06-16` (`.1`): Inventory complete. 6 gap categories identified.
- `2026-06-16` (`.2`): Conditional flow landed. Lazy evaluation required modifying `eval_expr` to intercept `if`/`switch`/`elseif`/`else`/`case`/`default` before eager arg evaluation. New method `call_helper_lazy` added. 12 new tests. 177/177 PASS.
- `2026-06-16` (audit): 3-agent Rust↔Perl parity audit found the REAL gaps (the actual follow-on, replacing the superseded self-hosting `.4`):
  - **BLOCKER**: child-return value (`retv`) is never propagated to the parent after `->`/`=>` dispatch — `return(expr)` only pushes to the top accumulator and `execute_rule` never sets a `retv` scalar, so `scalar(retv)` in `LE` resolves to undef → virtually every real grammar yields wrong/null output. (`engine.rs` execute_rule + runtime.rs; the in-flight `set_retv` is the half-built, dead fix.)
  - MAJOR: `match_*` is wrongly unified with `entry_*` (`engine.rs:171-174` sets both to the same groups) — nested-match reads via `match_*` get the entry match.
  - MAJOR: byte-indexed slicing in `substr`/`input_slice`/`capture_slice`/`capture_from`/cursor line-col → panic on multibyte UTF-8 and offset divergence from Perl (char-based). Also `entry/match_start_pos` hardcoded to 0.
  - MAJOR: duplicate/unreachable match arms in `engine.rs` — `hash`/`h` (650 vs 1202), `hash_copy` (662 vs 1221, the worse arm wins), `print` (643 vs 798); REP "zero-progress guard" never checks `pos`.
  - MAJOR: ~30 capture/mark/named-entry/match helpers missing (`capture_*_from`, `capture_between`, `mark_*`, `entry_named/has/map`, `match_named/has/map`, `input_end_line/col`, …); `tail`/`drop_last`/`flatten` real Perl helpers also missing (drop `array_values`/`return_imatch`/`return_im` from the inventory — not in Perl).
  - MAJOR: 0/20 shipped specs are runtime-tested in Rust (compile-only) — need a Perl↔Rust output oracle corpus.
- `2026-06-16` (`.4` superseded): in-flight exploration toward `.4` committed as a WIP checkpoint (handoff decision) to preserve it durably; it is NOT signoff (`parse_inline_body` conditional-capture bug, dead `set_retv`, leftover debug `eprintln!`). Fold/clean into the real follow-on above.
- `2026-06-16` (`.5` split): `.5` was a single broad leaf bundling six independently-reviewable audit findings; split into `.5.1`–`.5.5` (the runtime-corpus oracle gap stays in `.7`). The 3-agent audit above is the implementation spec for each child. retv-first because it gates correct output for nearly every grammar. Rust baseline confirmed green (182 tests, 0 failed) before the split.
- `2026-06-16` (`.5.1` implementation): retv BLOCKER fixed. **Design:** the Rust engine shares one `RuntimeContext` and `execute_rule` previously returned `Result<(), String>` — no value channel — so a child's `return(expr)` went only to the single shared accumulator and `set_retv` was dead. Fix: (1) added a per-invocation `return_value: Option<RuntimeValue>` to `RuntimeContext` with `set_return_value`/`take_return_value`/`restore_return_value`; (2) `execute_rule` now returns `Result<RuntimeValue, String>` — it `take`s the channel on entry (saving the caller's pending return) and reads+restores it on exit, so each invocation reports exactly its own last `return(...)` (Runtime Semantics §5.4) and nested dispatch is transparent; (3) after both `->` (acode) and `=>` (bcode) dispatch the engine calls `ctx.set_retv(child_retv)`, so the parent's attached code / `LE` / `E` read the child result as `scalar(retv)` (§3.3/§6.1); (4) `return(expr)` records the channel **in addition to** pushing the accumulator — the accumulator stays `execute()`'s return contract, so the 182-test baseline is untouched. **Wired the dead `set_retv` in** (completed, not removed). **Latent bug found + fixed while here:** `call(child)` resolved the rule name from the *evaluated* arg, but a bare `call(RuleName)` evaluates to undef (a label is not a scalar) — so `call` never resolved a bare rule. Added `resolve_rule_name` (mirrors `resolve_array_target`) so `call(child)` returns the child's value, enabling the Perl reference pattern `assign(s(retv), call(child))` (`specs/tablegrep.spec`). Zero runtime-crate `call(` uses existed, so zero baseline risk. **Book:** no change — the documented `.spec` contract already specifies retv (`appendix/runtime-semantics.md` §3.3/§6.1); the Rust backend now conforms. Rust-parity book sync remains `.9`.

## Open Questions

- None yet — inventory leaf will identify any.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-16` | `RUST-PARITY.1` | Full audit: Rust sources (`engine.rs:1984`, `helpers.rs:470`, `compiler.rs`, `parser.rs`, `validation.rs`) vs Perl lowering owners (`ControlFlow.pm`, `MethodLowering.pm`, `ValueExpr.pm`, `FlowExpr.pm`, `Contracts.pm`) | Done — 6 gap categories, 84/100+ helpers implemented |
| `2026-06-16` | `RUST-PARITY.5.1` | `cargo test --manifest-path rust/Cargo.toml` (all binaries); `cargo clippy --manifest-path rust/Cargo.toml` (linkedspec-runtime delta) | 186 passed / 0 failed (182 baseline + 4 new retv tests: acode/OR, blind-call/AND, REP, `call`); clippy adds zero new linkedspec-runtime warnings (lib stays at 16 pre-existing `doc_lazy_continuation`) |

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
| `RUST-PARITY.5.1` | `RUST-PARITY.5.1 — fix child-return (retv) propagation in the Rust engine` | engine.rs + runtime.rs + 4 integration tests; 186/186 green |

## Changelog

- `2026-06-16`: Created task tree.
- `2026-06-16`: `.4` (Rust self-hosting on spec.spec) marked `superseded` — wrong target; spec.spec rewritten on the Perl side under `SPEC-SPEC-SELFHOST`. Recorded the 3-agent parity audit (real follow-on). Committed in-flight Rust exploration (expr/parser/runtime/helpers) as a WIP checkpoint.
- `2026-06-16`: Split `.5` (PNT rule 5 — too broad for one signoff slice) into `.5.1` retv-propagation BLOCKER fix, `.5.2` match/entry split, `.5.3` char-based indexing + cursor line/col, `.5.4` dedupe match arms + REP zero-progress guard, `.5.5` ~30 missing helpers + real aliases. Sequenced retv-first. Confirmed the Rust baseline green (182 tests, 0 failed) before splitting. Frontier → `.5.1`. No code change (tree structuring only).
- `2026-06-16`: `.5.1` done — fixed the child-return (retv) propagation BLOCKER. `execute_rule` now returns the rule's value via a per-invocation channel; `->`/`=>` dispatch set `retv` to the child return; `return(...)` feeds the channel without disturbing the accumulator contract; `call(child)` now resolves a bare rule name and returns the child value. 4 new integration tests (acode/OR, blind-call/AND, REP, `call`); `cargo test` 186/186; clippy adds no new warnings. Frontier → `.5.2` (match_*/entry_* split).
