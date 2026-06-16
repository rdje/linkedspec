# RUST-PARITY: Bring Rust Variant to Full Parity with Perl Reference

## Metadata

- Tree ID: `RUST-PARITY`
- Status: `active`
- Roadmap lane: `Phase 9 — Rust variant (parity follow-on)`
- Created: `2026-06-16`
- Last updated: `2026-06-16` (`.5.5.3` pre-work design finding recorded — capture_from match-start vs cursor parity question)
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
  Children: `.5.1` (done), `.5.2` (done), `.5.3` (done), `.5.4` (done), `.5.5` (active — split into `.5.5.1`–`.5.5.4`)
  Note: Split from a single broad leaf (PNT rule 5 — too broad for one signoff slice). The 3-agent audit in Decisions is the implementation spec. Sequenced retv-first because it gates correct output for nearly every grammar. The "0/20 runtime-tested corpus" gap stays in `.7` (test-corpus breadth).

- ID: `RUST-PARITY.5.1`
  Status: `done`
  Goal: Fix the child-return (retv) propagation BLOCKER
  Acceptance: After `->`/`=>` dispatch, the child rule's `return(expr)` value is propagated to the parent and readable as `retv` (so `scalar(retv)` in an `LE` block resolves to the child result, not undef); the half-built dead `set_retv` is completed or removed; new regression tests cover retv-in-LE across AND/OR/REP dispatch; `cargo test` + `cargo clippy` clean; the 182-test baseline stays green.
  Verification: Done — 2026-06-16. `execute_rule` now returns `Result<RuntimeValue, String>` (the rule's own return value, via a per-invocation save/restore channel in `RuntimeContext`); both `->` (acode) and `=>` (bcode) dispatch sites call `ctx.set_retv(child_retv)` after dispatching, so the parent's attached code / `LE` / `E` read the child result as `scalar(retv)`. `return(expr)` records the channel (still pushes the accumulator — `execute()`'s contract). The dead `set_retv` is now wired in (completed, not removed). `call(child)` returns the child's value and resolves a bare rule-name arg (latent bug fixed — enables the `assign(s(retv), call(child))` reference pattern). 4 new integration tests (acode/OR, blind-call/AND, REP, `call`). `cargo test` = 186 passed (182 baseline + 4), 0 failed; `cargo clippy` adds zero new warnings to `linkedspec-runtime` (lib stays at 16 pre-existing `doc_lazy_continuation` lints).
  Commit: `RUST-PARITY.5.1` (see Commit Log)

- ID: `RUST-PARITY.5.2`
  Status: `done`
  Goal: Separate `match_*` from `entry_*` (stop unifying them at engine.rs:171-174)
  Acceptance: `match_*` reads the current local match while `entry_*` reads the entry match; nested-match reads diverge correctly; regression test; baseline green; clippy clean.
  Verification: Done — 2026-06-16. The match-set site previously assigned the rule's own match to BOTH `entry_*` and `match_*`. Now `execute_rule` emulates Perl's per-handler `IMATCH`/`LMATCH` lexicals via a `SavedMatchState` save/restore on the shared `RuntimeContext`: the invocation's ENTRY match = the dispatcher's local match (`$info = $minfo`, `MethodLowering.pm:332` + `SpecEntry::_build_handler_preamble` `IMATCH=$$info{match}`); the rule's own match updates only the LOCAL match (`LMATCH`, `_build_lmatch_extraction`); the entry match is seeded from the rule's own first match only when empty (top-rule / dispatcher-less case); both registers are restored on exit (blind-call + normal returns) so a child's matching is transparent to the parent. 3 new integration tests (`match_5_2_child_entry_is_dispatcher_match_local_is_own`, `match_5_2_parent_local_match_survives_child_dispatch`, `match_5_2_top_rule_entry_equals_local_match`). `cargo test` = 189 passed (186 baseline + 3), 0 failed; `cargo clippy -p linkedspec-runtime --tests` adds zero new warnings (touched-file warning set identical to baseline, only line-shifted). No book change (the `.spec` contract already documents `entry_*`/`match_*`; Rust now conforms — book sync is `.9`).
  Commit: `RUST-PARITY.5.2` (see Commit Log)

- ID: `RUST-PARITY.5.3`
  Status: `done`
  Goal: Char-based (not byte) indexing for slicing + cursor line/col; fix hardcoded start positions
  Acceptance: `substr`/`input_slice`/`capture_slice`/`capture_from` and cursor line-col use char offsets (no panic on multibyte UTF-8; parity with Perl's char-based offsets); `entry/match_start_pos` no longer hardcoded to 0; multibyte regression tests; baseline green; clippy clean.
  Verification: Done — 2026-06-16. Internal positions stay byte-based (regex engine works in bytes); the DSL boundary is now char-based (Perl parity). New `byte_to_char_offset` + `char_substr`/`char_substr_from` helpers in `engine.rs`. `substr`/`input_slice` char-slice their DSL char-offset args (no more panic on a multibyte boundary). `cursor_pos`/`cursor_col`/`cursor_rest_len`/`input_len`/`input_end_pos`/`capture_slice_len`/`capture_slice_pos`/`mark_pos`/`entry_*_pos`/`entry_len`/`match_*_pos`/`match_len`/`length` convert byte→char. `entry_start_pos`/`match_start_pos` no longer hardcoded `0.0`: `RuntimeContext` gains `entry_start_byte`/`entry_end_byte`/`match_start_byte`/`match_end_byte` span fields (part of `SavedMatchState`, recorded from `m.start`/`m.end`, entry seeded by the same dispatcher-vs-own-first-match rule as `.5.2`). 7 new multibyte unit tests (`chars_5_3_*`). `cargo test` = 196 passed (189 baseline + 7), 0 failed; `cargo clippy -p linkedspec-runtime --tests` touched-file warning set identical to baseline (15), zero new. No book change (positions/lengths/`substr` are char-based in the documented `.spec` contract; Rust now conforms — book sync is `.9`). Out of scope: group indexing (`.5.2` note) and the `entry_line`/`entry_col`/`match_line`/`match_col` arg-taking quirk (left as-is; `cursor` line/col fixed as specified).
  Commit: `RUST-PARITY.5.3` (see Commit Log)

- ID: `RUST-PARITY.5.4`
  Status: `done`
  Goal: Remove duplicate/unreachable match arms; make the REP zero-progress guard check `pos`
  Acceptance: the shadowed arms (`hash`/`h`, `hash_copy`, `print`) are de-duplicated so the correct behavior wins; the REP loop's zero-progress guard actually compares `pos` before/after and breaks on no advance; regression tests; baseline green; clippy clean.
  Verification: Done — 2026-06-16. Removed the three earlier shadowing arms in `call_helper` (`print`, `hash`/`h`, `hash_copy`) so the later, more complete arms win: `hash`/`h` now merges Hash-valued args, `hash_copy` resolves its target via `resolve_array_target` (raw-AST), and `print` is served by the consolidated `say | print | print_each` arm. This also cleared 3 `unreachable_patterns` warnings. The REP loop's zero-progress guard previously checked `matches > rep_min && matches > 100` (an iteration cap, never `pos`); it now captures `pos_before` at the top of each iteration and breaks when `ctx.pos == pos_before` (Perl `loop_end_pos == loop_start_pos`), so a zero-width REP match terminates after one no-progress iteration and the post-loop min-bound check fails it if still under `rep_min`. 2 new tests (`rep_5_4_zero_progress_guard_terminates`, `hash_5_4_better_hash_arm_merges_hash_args`). `cargo test` = 198 passed (196 baseline + 2), 0 failed; `cargo clippy -p linkedspec-runtime --tests` touched-file warnings 15 → 12 (removed 3 unreachable-pattern duplicates; zero new). No book change (internal dedup + REP termination correctness, which already matches the documented Perl model — book sync is `.9`).
  Commit: `RUST-PARITY.5.4` (see Commit Log)

- ID: `RUST-PARITY.5.5`
  Status: `active`
  Goal: Implement the ~28 missing capture/mark/entry/match/input helpers (+ real aliases `tail`/`drop_last`/`flatten`)
  Children: `.5.5.1` (done), `.5.5.2` (done), `.5.5.3`, `.5.5.4`
  Note: Split 2026-06-16 (PNT rule 5 — too broad for one signoff slice; ~28 helpers across ~7 families, plus an alias-policy question). The `.1` Inventory (Gap 5) + `docs/linkedspec-book/src/appendix/helper-contract-catalog.md` are the implementation spec. Confirmed against engine.rs: only `drop_front`/`drop_back`/`array_copy`/`flat_array` of this family exist; all 28 below are genuinely missing. (`array_values`/`return_imatch`/`return_im` are explicitly NOT added — not real Perl helpers.)

- ID: `RUST-PARITY.5.5.1`
  Status: `done`
  Goal: Named-group helpers — `entry_named`/`entry_has`/`entry_map`/`entry_named_map` + `match_named`/`match_has`/`match_map`/`match_named_map`
  Acceptance: the 8 named-group readers read the existing `entry_named`/`match_named` maps (`entry_named(name)`→string, `entry_has(name)`→bool, `entry_map()`/`entry_named_map()`→hash; same for `match_*`) to helper-contract-catalog parity; per-family tests; baseline green; clippy clean.
  Verification: Done — 2026-06-16. Added 8 arms to `call_helper` (`rust/linkedspec-runtime/src/engine.rs`): the 4 `entry_*` after `entry_groups` read `ctx.entry_named`; the 4 `match_*` after `match_groups` read `ctx.match_named`. `entry_named(name)`/`match_named(name)` → `Scalar` or `Undef` (absent); `entry_has`/`match_has` → `Bool(contains_key)`; `entry_map`/`entry_named_map` and `match_map`/`match_named_map` are combined arms (the `_named_map` forms are the catalog's retired aliases) returning a `RuntimeValue::Hash` via a new free helper `named_map_to_hash` that sorts keys for deterministic projection (matching `sorted_keys`/`sorted_values`). Both maps already exist on `RuntimeContext`, populate from `MatchResult.named` (engine.rs:280 local / :291 entry-when-empty), and save/restore in `SavedMatchState` — purely additive, no struct/population changes. 6 new tests (`helpers_5_5_1_*`, end-to-end via `(?P<name>…)` regexes: entry_named present/absent, entry_has present/absent, entry_map + alias, match_named present/absent, match_has present/absent, match_map + alias). `cargo test --manifest-path rust/Cargo.toml` = 204 passed / 0 failed (198 baseline + 6). `cargo clippy --manifest-path rust/Cargo.toml -p linkedspec-runtime --tests` lint multiset byte-identical to the stashed HEAD baseline (13 = 13; zero new). No book change (catalog §8 already documents these — Rust now conforms; book sync is `.9`). No knowledge card (localized additive change reading existing infra).
  Commit: `RUST-PARITY.5.5.1` (see Commit Log)

- ID: `RUST-PARITY.5.5.2`
  Status: `done`
  Goal: Input-boundary helpers (`input_end_line`, `input_end_col`) + real compat aliases (`tail`, `drop_last`, `flatten`, and `flat` if missing)
  Acceptance: `input_end_line`/`input_end_col` return the char line/col at end-of-input; the aliases map per the catalog (`tail`→`drop_front`, `drop_last`→`drop_back`, `flatten`→`flat`) with `flat` added if absent; resolve the alias-retirement question (book §catalog says "retired alias", `ROADMAP_V2` says "remain compatibility syntax") against the Perl reference before landing; tests; baseline green; clippy clean.
  Verification: Done — 2026-06-16. **Open Question resolved against the Perl reference (see Decisions/Open Questions):** the Perl reference does NOT recognize `tail`/`drop_last`/`flatten`/`array_values` — they are absent from the helper-recognition regexes (`BootstrapSpec/Core.pm:82`, `FlowExpr.pm:81,270`, `MethodLowering.pm:1627,1635`), unused in all 20 shipped specs, and not regression-locked in `t/phase0_regression.t` (grep count 0). Retired in `COMPAT-ALIAS-RETIREMENT.1` (knowledge card `medium-term-alias-retirement-deferred`); the book catalog §Compatibility-Aliases also lists them "Retired". For cross-variant **parity** the Rust variant must match the reference's recognized surface, so the three retired aliases are deliberately NOT added (adding them would diverge, not converge). Only `flat` (canonical, recognized; catalog retired-table target of `flatten`) was missing in Rust and is added. Implemented 3 new `call_helper` arms in `rust/linkedspec-runtime/src/engine.rs`: `input_end_line` (= `1 + newline count over the whole input`, parity with Contracts.pm `INPUT_END_LINE_READ`), `input_end_col` (char distance past the last newline, `+1` when none — parity with `_build_column_read_expr(pos_expr => length($$STRING))`, modeled on the existing `cursor_col`), and the generic `flat(container)` splice (Array→Array, Hash→Hash, scalar→single-element list; consistent with `flat_array`/`flat_hash`). 3 new tests (`helpers_5_5_2_*`, end-to-end incl. multibyte + trailing-newline + flat-into-parent-hash). `cargo test --manifest-path rust/Cargo.toml` = 207 passed / 0 failed (204 baseline + 3). `cargo clippy --manifest-path rust/Cargo.toml -p linkedspec-runtime --tests`: `linkedspec-runtime` lib = 13 warnings = stashed baseline 13 (zero new; integration_test's lone `len_zero` at :199 pre-existing per MEMORY; vendored pgen/rgx-core ignored). No book change (catalog §9 documents `input_end_line`/`input_end_col`, §Compatibility-Aliases marks the three retired — Rust now conforms; book sync is `.9`). New knowledge card `docs/knowledge/rust-retired-array-aliases-not-added.md`.
  Commit: `RUST-PARITY.5.5.2` (see Commit Log)

- ID: `RUST-PARITY.5.5.3`
  Status: `pending`
  Goal: Mark-based capture family — `capture_*_from` (`capture_len_from`, `capture_until_cursor_from`, `capture_take_until_cursor_from`, `capture_take_len_from`, `capture_rest_from`, `capture_take_rest_from`), `capture_between`/`capture_len_between`, and `mark_copy`/`mark_input_start`/`mark_input_end`
  Acceptance: each reads the named mark(s) (byte offsets) and returns char-correct text/length per the catalog; `mark_*` set marks; tests with multibyte input; baseline green; clippy clean.
  Verification: `pending`
  Commit: `pending`

- ID: `RUST-PARITY.5.5.4`
  Status: `pending`
  Goal: Anonymous capture-slice variants — `capture_slice_until_cursor`, `capture_take_until_cursor`, `capture_take_len`, `capture_take_rest` (and any `_len` variants from the inventory)
  Acceptance: each operates on the anonymous `capture_start`/cursor per the catalog, char-correct; tests; baseline green; clippy clean.
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
| — | `RUST-PARITY.5.2` | `done` | match_*/entry_* split landed (2026-06-16); entry = dispatcher's match, local = own match, per-handler lexical save/restore |
| — | `RUST-PARITY.5.3` | `done` | char-based indexing + cursor line/col landed (2026-06-16); byte-internal, char-exposed; entry/match spans stored |
| — | `RUST-PARITY.5.4` | `done` | dedupe match arms + REP zero-progress guard landed (2026-06-16); better hash/hash_copy/print arms live, REP breaks on no cursor progress |
| — | `RUST-PARITY.5.5` | `active` | split into `.5.5.1`–`.5.5.4` (2026-06-16, PNT rule 5 — ~28 helpers across families) |
| — | `RUST-PARITY.5.5.1` | `done` | named-group helpers landed (2026-06-16); entry/match `_named`/`_has`/`_map`(+`_named_map` alias) read the existing maps, deterministic hash projection |
| — | `RUST-PARITY.5.5.2` | `done` | input-boundary helpers + `flat` landed (2026-06-16); Open Question resolved — retired aliases `tail`/`drop_last`/`flatten` NOT added (Perl reference doesn't recognize them; parity = match the reference) |
| 1 | `RUST-PARITY.5.5.3` | `pending` | mark-based capture family (`capture_*_from`/`_between`, `mark_*`) |
| 2 | `RUST-PARITY.5.5.4` | `pending` | anonymous capture-slice variants |

(`.5` split per PNT rule 5 — too broad for one signoff slice; `.5.5` further split the same way; `.6`–`.9` unchanged below it.)

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

- `2026-06-16` (`.5.2` implementation): match/entry separation landed. **Design:** the single match-set site (`engine.rs`) assigned the rule's own regex match to BOTH `entry_*` and `match_*`, so they could never diverge and a dispatched child clobbered the parent's match. The Perl reference keeps two per-handler `my` lexicals — `IMATCH` (entry, `= $$info{match}`, where a parent passes its own `$minfo` to the child at `ActionIR/MethodLowering.pm:332`, and the preamble sets `IMATCH=$$info{match}` at `SpecEntry::_build_handler_preamble`) and `LMATCH` (local, `= $$minfo{match}` at `HandlerVariantEmitter::_build_lmatch_extraction`). Fix: `execute_rule` now (1) saves the caller's `entry_*`/`match_*` into a `SavedMatchState`; (2) sets THIS invocation's entry match = the caller's local match (`$info = $minfo`) and starts the local match empty; (3) on each own match updates only `match_*`, and seeds `entry_*` from the first own match only when entry is still empty (the top-rule / dispatcher-less case — the framework passes the top rule's own match as `$info`); (4) restores the caller's registers on both the blind-call early return and the normal return, so a child's matching is transparent to the parent. **Oracle note:** the runtime Perl oracle was inconclusive for minimal hand-authored inline specs (`.spec` top-rule/lifecycle authoring friction returned empty/0), so the contract was taken directly from the authoritative Perl source (the three sites above) and pinned by Rust tests — the leaf's parity gate is `cargo test` + `cargo clippy`, not a Perl oracle. **Book:** no change (the `.spec` contract already documents `entry_*`/`match_*` in `dsl/capture-marks-and-source-locations.md`; Rust now conforms — Rust-parity book sync remains `.9`). Group-indexing parity (`match_group(0)` = first capture in Perl vs full match in Rust) is explicitly out of `.5.2` scope.

- `2026-06-16` (`.5.3` implementation): char-based offset/slicing parity. **Design:** the regex engine works in **byte** offsets, so internal positions (`ctx.pos`, `capture_start`, `marks`, `MatchResult.start`/`.end`, the new `entry/match_*_byte` spans) stay byte-based and input slicing between two of them is panic-safe; but the Perl reference exposes **char** offsets (`pos()`/`length`/`substr` are char-based), so every position/length surfaced to the DSL converts byte→char (`byte_to_char_offset`) and every helper taking DSL char-offset args char-slices (`char_substr`/`char_substr_from`). Concretely: `substr`/`input_slice` no longer byte-slice (they panicked on a multibyte boundary); `cursor_pos`/`cursor_col`/`cursor_rest_len`/`input_len`/`input_end_pos`/`capture_slice_len`/`capture_slice_pos`/`mark_pos`/`entry_*_pos`/`entry_len`/`match_*_pos`/`match_len`/`length` return char counts; line numbers (newline counts) were already byte/char-identical, only columns needed char counting. `entry_start_pos`/`match_start_pos` were hardcoded `0.0`; `RuntimeContext` now stores `entry/match_start_byte`+`_end_byte` spans (recorded from `m.start`/`m.end`, part of `SavedMatchState` so they save/restore per invocation like the `.5.2` groups, entry seeded by the same dispatcher-vs-own-first-match rule). **ASCII no-op:** byte==char for ASCII, so the 189 baseline is untouched; 7 multibyte `chars_5_3_*` tests pin the UTF-8 behavior. **Out of scope:** the `.5.2` group-indexing item, and the `entry_line`/`entry_col`/`match_line`/`match_col` arg-taking quirk (only `cursor` line/col was in this leaf's named scope). New knowledge card `docs/knowledge/rust-char-based-offsets.md`.

- `2026-06-16` (`.5.4` implementation): dedup + REP guard. **Dedup:** `call_helper` had three pairs of arms with the same pattern, where Rust matches top-to-bottom so the FIRST (worse) won and the later (better) was unreachable (3 `unreachable_patterns` warnings). Removed the first `print`, `hash`/`h`, and `hash_copy` arms so the later ones win: `hash`/`h` merges Hash-valued args (the dropped one ignored them), `hash_copy` resolves its target through `resolve_array_target` (raw-AST, not bare `to_str()`), and `print` is served by the consolidated `say | print | print_each` arm (identical behavior). **Note discovered while here:** there is no clean DSL idiom to *copy a declared hash by reference* — `hash(name)` eagerly builds an empty new hash (constructor, not a reference) and `resolve_array_target` only recognizes the `array(...)`/`a(...)` raw form, so `hash_copy(hash(config))` returns `{}`; the `hash`-as-reference gap is deeper than `.5.4` (flag for `.5.5`/a later leaf). The `.5.4` regression instead pins the better arm via its *distinguishing* behavior (Hash-arg merge). **REP guard:** the old guard `matches > rep_min && matches > 100` was an iteration cap that never inspected `pos`; replaced with a real progress check — capture `pos_before` at the top of each iteration, break when `ctx.pos == pos_before` (Perl `loop_end_pos == loop_start_pos`); a zero-width REP match now terminates after one no-progress iteration and the post-loop min-bound check fails it if still under `rep_min`. No knowledge card (localized fix, captured by tests + this tree).

- `2026-06-16` (`.5.5.2` implementation): input-boundary helpers + `flat`; retired-alias parity resolution. **Design:** added three `call_helper` arms to `rust/linkedspec-runtime/src/engine.rs`. (1) `input_end_line` returns `1 + (newline count over the whole input)` — parity with the Perl reference's `INPUT_END_LINE_READ` lowering (`Contracts.pm:1255`, `do { 1 + (() = substr($$STRING,0,length($$STRING)) =~ /\n/g) }`); newline counts are byte/char identical so a plain `'\n'` filter suffices. (2) `input_end_col` returns the char distance past the last newline (`+1` when none) — parity with `_build_column_read_expr(pos_expr => 'length($$STRING)')` (`Contracts.pm:111,1266`), modeled exactly on the existing char-based `cursor_col` (`.5.3`) but at end-of-input; multibyte-correct (e.g. `"héllo"` → 6, matching the `cursor_col` test). (3) `flat(container)` is the generic list-context splice (Perl `MethodLowering.pm:199`): an Array splices its elements, a Hash splices its key/value entries, any other value becomes a single-element list — consistent with the established Rust `flat_array` (Array→Array) and `flat_hash` (Hash→Hash) representation, so a parent `array(...)`/`hash(...)` consumes it the same way (the Rust `array(...)` constructor keeps args as-is; the splice is realized by the consuming helper, e.g. `hash(...)` merging Hash args). **Retired-alias resolution (the leaf's parked Open Question):** the Perl reference does NOT recognize `tail`/`drop_last`/`flatten`/`array_values` — absent from all helper-recognition regexes, unused in 20 specs, zero phase0 locks, retired in `COMPAT-ALIAS-RETIREMENT.1`, "Retired" in the book catalog. Cross-variant parity means matching the reference's recognized surface, so those three retired aliases are deliberately NOT added to Rust (an explicit code comment records this); only canonical `flat` was missing and is added. **Book:** no change (catalog §9 already documents `input_end_line`/`input_end_col`; §Compatibility-Aliases already marks the three retired — Rust now conforms; book sync remains `.9`). **Discovered drift:** `ROADMAP_V2` 256–262 still calls `tail`/`drop_last` "compatibility alias … remain supported" (stale pre-retirement text) — flagged for a Perl-side doc-sync slice, not bundled here.

## Open Questions

- (`.5.5.2`) **RESOLVED 2026-06-16.** Alias-retirement status of `tail`/`drop_last`/`flatten`/`array_values`: the Perl reference does **not** recognize them. They are absent from every current helper-recognition regex (`BootstrapSpec/Core.pm:82`, `FlowExpr.pm:81,270`, `MethodLowering.pm:1627,1635` list canonical `drop_front`/`drop_back`/`flat`/`flat_array`/`array_copy` but none of the four aliases), unused in all 20 shipped specs, and not regression-locked in `t/phase0_regression.t` (grep count 0). They were retired in `COMPAT-ALIAS-RETIREMENT.1` (knowledge card `medium-term-alias-retirement-deferred`), and the book catalog §Compatibility-Aliases lists them "Retired". **Decision:** for cross-variant parity the Rust variant matches the reference's recognized surface — the three retired aliases are NOT added (only `flat`, which is canonical and was missing). `entry_named_map`/`match_named_map` are a separate case (combined-arm retired aliases already added in `.5.5.1`, accepted for legacy specs). **Discovered drift (now FIXED):** `ROADMAP_V2.md`/`ROADMAP.md` + book `appendix/formal-grammar.md:357` still described `tail`/`drop_last`/`flatten`/`array_values` as live "compatibility aliases". Corrected to retirement across 16 lines / 3 files under the dedicated tree `ALIAS-RETIREMENT-DOC-SYNC` (completed 2026-06-16) — the docs are the variant-agnostic universal-contract surface, so this was contract truth to fix, not a deferrable "Perl-side" detail.
- (`.5.5.3` pre-work, **OPEN — decide first**) The mark-family readers have TWO end positions in the Perl reference (`Contracts.pm` ~700–905), and the existing Rust `capture_from` does not match the non-cursor one. **Non-cursor readers** (`capture_from`/`capture_len_from`/`capture_take`/`capture_take_len_from`) end at `$LSPOS - length $LMATCH` = the **start of the current local match** (= `ctx.match_start_byte` in Rust). **`_until_cursor_` readers** end at `pos $$STRING` = the cursor (= `ctx.pos`). **`capture_rest*`** ends at `length($$STRING)` (end of input). **`_take_` variants MUTATE the mark** (advance it to the read's end position) — non-take variants do not. `capture_between(a,b)` = `substr(start_mark, end_mark - start_mark)`; `capture_len_between` = the width. `mark_input_start(name)` = mark 0; `mark_input_end(name)` = mark `len(input)`; `mark_copy(target, source)` is **2-arg** (copies source's pos to target; returns it, or deletes target + returns undef if source absent — note the book catalog §7 wrongly shows a 1-arg `mark_copy(name)`, another book imprecision to flag). **The discrepancy:** the existing Rust `capture_from` (engine.rs:1044) returns `ctx.input[mark..ctx.pos]` (to match_END), but Perl `capture_from` goes to match_START (`pos - len(LMATCH)`); e.g. test `helpers_5_2_mark_and_capture_from` (mark at 0, whole-input match "hello") asserts `"hello"`, but strict Perl gives `""` (everything before the match). So `capture_len_from` per strict Perl would be `pos - mark - len(LMATCH)`, **inconsistent** with the existing `capture_from`. **Decide before implementing `.5.5.3`:** (a) fix `capture_from` to Perl's match-start semantics and update `helpers_5_2_mark_and_capture_from` (correct parity, but changes a landed test), or (b) implement the family consistent with the existing match-end `capture_from` (internally coherent, but a known parity gap). Recommend (a) with explicit justification, but it is a deliberate call that wants fresh focus. `LMATCH` length in Rust = `ctx.match_end_byte - ctx.match_start_byte` (`.5.2`/`.5.3` spans); positions byte-internal, char at the DSL boundary (`.5.3` `byte_to_char_offset`).
- None yet — inventory leaf will identify any.
- (`.5.2`) Group indexing differs between Perl (`match_group(0)` = first capture) and Rust (`entry_group(0)`/`match_group(0)` read index 0 = full match). Not a `.5.2` concern (that leaf is about *which* match, not indexing); flag for a later parity leaf if it proves user-visible.
- (`.5.3`) `entry_line`/`entry_col`/`match_line`/`match_col` take a position **argument** rather than deriving from the stored entry/match span (an existing quirk). `.5.3` fixed only `cursor` line/col (its named scope); revisit these in a later parity leaf alongside the group-indexing item.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-16` | `RUST-PARITY.1` | Full audit: Rust sources (`engine.rs:1984`, `helpers.rs:470`, `compiler.rs`, `parser.rs`, `validation.rs`) vs Perl lowering owners (`ControlFlow.pm`, `MethodLowering.pm`, `ValueExpr.pm`, `FlowExpr.pm`, `Contracts.pm`) | Done — 6 gap categories, 84/100+ helpers implemented |
| `2026-06-16` | `RUST-PARITY.5.1` | `cargo test --manifest-path rust/Cargo.toml` (all binaries); `cargo clippy --manifest-path rust/Cargo.toml` (linkedspec-runtime delta) | 186 passed / 0 failed (182 baseline + 4 new retv tests: acode/OR, blind-call/AND, REP, `call`); clippy adds zero new linkedspec-runtime warnings (lib stays at 16 pre-existing `doc_lazy_continuation`) |
| `2026-06-16` | `RUST-PARITY.5.2` | `cargo test --manifest-path rust/Cargo.toml` (all binaries); `cargo clippy --manifest-path rust/Cargo.toml -p linkedspec-runtime --tests` (baseline-diff) | 189 passed / 0 failed (186 baseline + 3 new `match_5_2_*`: child entry/local divergence, parent-match survives child dispatch, top-rule entry==local); clippy touched-file warning set identical to baseline (14 engine.rs + 1 pre-existing `len_zero` at integration_test.rs:199), only line-shifted — zero new warnings |
| `2026-06-16` | `RUST-PARITY.5.3` | `cargo test --manifest-path rust/Cargo.toml` (all binaries); `cargo clippy --manifest-path rust/Cargo.toml -p linkedspec-runtime --tests` (baseline-diff vs `.5.2` HEAD) | 196 passed / 0 failed (189 baseline + 7 new `chars_5_3_*`: substr no-panic, input_slice, cursor_pos, cursor_col, match_start_pos, entry_start_pos, length — all multibyte UTF-8); clippy touched-file warning count identical to baseline (15) — zero new warnings |
| `2026-06-16` | `RUST-PARITY.5.4` | `cargo test --manifest-path rust/Cargo.toml` (all binaries); `cargo clippy --manifest-path rust/Cargo.toml -p linkedspec-runtime --tests` (baseline-diff vs `.5.3` HEAD) | 198 passed / 0 failed (196 baseline + 2 new: `rep_5_4_zero_progress_guard_terminates`, `hash_5_4_better_hash_arm_merges_hash_args`); clippy touched-file warnings 15 → 12 (removed 3 unreachable-pattern duplicates; zero new) |
| `2026-06-16` | `RUST-PARITY.5.5.1` | `cargo test --manifest-path rust/Cargo.toml` (all binaries); `cargo clippy --manifest-path rust/Cargo.toml -p linkedspec-runtime --tests` (baseline-diff vs `.5.4` HEAD, stashed) | 204 passed / 0 failed (198 baseline + 6 new `helpers_5_5_1_*`: entry/match × named/has/map, present + absent edges + retired `_named_map` aliases); clippy lint multiset byte-identical to the stashed baseline (13 = 13) — zero new warnings |
| `2026-06-16` | `RUST-PARITY.5.5.2` | `cargo test --manifest-path rust/Cargo.toml` (all binaries); `cargo clippy --manifest-path rust/Cargo.toml -p linkedspec-runtime --tests` (baseline-diff vs `.5.5.1` HEAD) | 207 passed / 0 failed (204 baseline + 3 new `helpers_5_5_2_*`: `input_end_line` newline-count, `input_end_col` char-based incl. multibyte + trailing-newline, `flat` array + hash-into-parent splice); `linkedspec-runtime` lib clippy 13 = baseline 13 (zero new; integration_test `len_zero` :199 pre-existing; vendored pgen/rgx-core ignored) |

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
| `RUST-PARITY.5.2` | `RUST-PARITY.5.2 — separate entry_* from match_* in the Rust engine` | engine.rs SavedMatchState save/restore + 3 integration tests; 189/189 green |
| `RUST-PARITY.5.3` | `RUST-PARITY.5.3 — char-based offsets/slicing in the Rust engine` | engine.rs byte→char conversions + runtime.rs match-span fields + 7 multibyte unit tests; 196/196 green |
| `RUST-PARITY.5.4` | `RUST-PARITY.5.4 — dedup shadowed arms + fix REP zero-progress guard in the Rust engine` | engine.rs removed 3 duplicate arms + pos-based REP guard + 2 unit tests; 198/198 green |
| `RUST-PARITY.5.5.1` | `RUST-PARITY.5.5.1 — named-group reader helpers in the Rust engine` | engine.rs +8 `call_helper` arms (entry/match `_named`/`_has`/`_map`+`_named_map`) + `named_map_to_hash` + 6 tests; 204/204 green |
| `RUST-PARITY.5.5.2` | `RUST-PARITY.5.5.2 — input-boundary helpers + flat splice in the Rust engine` | engine.rs +3 `call_helper` arms (`input_end_line`/`input_end_col`/`flat`) + 3 tests; retired aliases resolved out; 207/207 green |

## Changelog

- `2026-06-16`: Created task tree.
- `2026-06-16`: `.4` (Rust self-hosting on spec.spec) marked `superseded` — wrong target; spec.spec rewritten on the Perl side under `SPEC-SPEC-SELFHOST`. Recorded the 3-agent parity audit (real follow-on). Committed in-flight Rust exploration (expr/parser/runtime/helpers) as a WIP checkpoint.
- `2026-06-16`: Split `.5` (PNT rule 5 — too broad for one signoff slice) into `.5.1` retv-propagation BLOCKER fix, `.5.2` match/entry split, `.5.3` char-based indexing + cursor line/col, `.5.4` dedupe match arms + REP zero-progress guard, `.5.5` ~30 missing helpers + real aliases. Sequenced retv-first. Confirmed the Rust baseline green (182 tests, 0 failed) before splitting. Frontier → `.5.1`. No code change (tree structuring only).
- `2026-06-16`: `.5.1` done — fixed the child-return (retv) propagation BLOCKER. `execute_rule` now returns the rule's value via a per-invocation channel; `->`/`=>` dispatch set `retv` to the child return; `return(...)` feeds the channel without disturbing the accumulator contract; `call(child)` now resolves a bare rule name and returns the child value. 4 new integration tests (acode/OR, blind-call/AND, REP, `call`); `cargo test` 186/186; clippy adds no new warnings. Frontier → `.5.2` (match_*/entry_* split).
- `2026-06-16`: `.5.2` done — separated `entry_*` from `match_*` in the Rust engine. `execute_rule` now emulates Perl's per-handler `IMATCH`/`LMATCH` lexicals via a `SavedMatchState` save/restore on the shared `RuntimeContext`: entry match = the dispatcher's local match (`$info = $minfo`), local match = the rule's own regex match, entry seeded from the first own match only for the dispatcher-less top rule, both restored on exit. 3 new integration tests (child entry/local divergence, parent match survives child dispatch, top-rule entry==local); `cargo test` 189/189; clippy adds no new warnings. New knowledge card `docs/knowledge/rust-entry-match-separation.md`. Frontier → `.5.3` (char-based indexing + cursor line/col).
- `2026-06-16`: `.5.3` done — char-based offsets/slicing in the Rust engine. Internal positions stay byte-based (the regex engine is byte-based); the DSL boundary is now char-based for Perl parity. `byte_to_char_offset`/`char_substr` helpers added; `substr`/`input_slice` char-slice (no multibyte panic); cursor/input/capture/mark/entry/match positions+lengths and `length` convert byte→char; `cursor_col` is char-distance. `entry_start_pos`/`match_start_pos` no longer hardcoded `0.0` — `RuntimeContext` stores `entry/match_*_byte` spans (part of `SavedMatchState`). 7 new multibyte tests (`chars_5_3_*`); `cargo test` 196/196; clippy adds no new warnings. New knowledge card `docs/knowledge/rust-char-based-offsets.md`. Frontier → `.5.4` (dedupe match arms + REP zero-progress guard).
- `2026-06-16`: `.5.4` done — dedup shadowed `call_helper` arms + fix the REP zero-progress guard. Removed the first `print`/`hash`/`hash_copy` arms so the better later arms win (Hash-arg merge for `hash`, raw-AST target resolution for `hash_copy`, consolidated `say|print|print_each`); cleared 3 `unreachable_patterns` warnings. REP loop now captures `pos_before` per iteration and breaks when `ctx.pos == pos_before` (no cursor progress) instead of an iteration cap. 2 new tests; `cargo test` 198/198; clippy touched-file warnings 15 → 12. No knowledge card (localized fix). Frontier → `.5.5` (~30 missing helpers + real aliases).
- `2026-06-16`: `.5.5` split (PNT rule 5 — too broad for one signoff slice). An engine.rs audit confirmed ~28 helpers across ~7 families are genuinely missing (only `drop_front`/`drop_back`/`array_copy`/`flat_array` of the family exist). Split into `.5.5.1` named-group readers (entry/match `_named`/`_has`/`_map`), `.5.5.2` input-boundary helpers + real compat aliases, `.5.5.3` mark-based capture family (`capture_*_from`/`_between`, `mark_*`), `.5.5.4` anonymous capture-slice variants. The `.1` Inventory (Gap 5) + the book helper-contract-catalog are the implementation spec. Surfaced an alias-policy Open Question (book §catalog says `tail`/`drop_last`/`entry_named_map` are "retired aliases"; `ROADMAP_V2` says they "remain compatibility syntax") to resolve against the Perl reference in `.5.5.2`. No code change (tree structuring only). Frontier → `.5.5.1`.
- `2026-06-16`: `.5.5.2` done — input-boundary helpers + the `flat` splice. Added 3 `call_helper` arms in `engine.rs`: `input_end_line` (1 + whole-input newline count), `input_end_col` (char distance past the last newline, +1 when none — modeled on `cursor_col`, multibyte-correct), and generic `flat(container)` (Array→Array / Hash→Hash / scalar→single-element list). **Resolved the parked alias-retirement Open Question against the Perl reference:** `tail`/`drop_last`/`flatten`/`array_values` are NOT recognized by the reference (no recognition regex, unused in 20 specs, 0 phase0 locks, retired in `COMPAT-ALIAS-RETIREMENT.1`, "Retired" in the book catalog) → deliberately NOT added to Rust (parity = match the reference's surface); only canonical `flat` was missing and is added. 3 new tests (`helpers_5_5_2_*`); `cargo test` 207/207; clippy 13 = baseline 13 (zero new). New knowledge card `docs/knowledge/rust-retired-array-aliases-not-added.md`. No book change (catalog already conforms; book sync `.9`). Flagged stale `ROADMAP_V2` 256–262 alias text as a separate Perl-side doc-sync follow-up. Frontier → `.5.5.3` (mark-based capture family).
- `2026-06-16`: `.5.5.1` done — added the 8 named-group reader helpers (`entry_named`/`entry_has`/`entry_map`/`entry_named_map` + the four `match_*`) as `call_helper` arms reading the existing `ctx.entry_named`/`ctx.match_named` maps (populate at engine.rs:280/291, save/restore in `SavedMatchState`). `entry_named_map`/`match_named_map` are combined-arm aliases of `entry_map`/`match_map` (the catalog's retired aliases); a new free `named_map_to_hash` sorts keys for a deterministic hash projection (matching `sorted_keys`/`sorted_values`). Purely additive — no struct/population changes. 6 new tests (`helpers_5_5_1_*`, end-to-end via `(?P<name>…)` regexes). `cargo test` 204/204; clippy lint multiset byte-identical to the stashed baseline (13 = 13; zero new). No book change (catalog §8 conforms; book sync `.9`); no knowledge card (localized additive). Frontier → `.5.5.2`.
