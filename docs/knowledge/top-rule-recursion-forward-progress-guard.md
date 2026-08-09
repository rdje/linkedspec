---
id: top-rule-recursion-forward-progress-guard
title: "Engine mechanics (TOP-RULE-AS-NORMAL): recursion re-enters through the SpecEntry runtime-handler closure (`&{$descr->{spec}{$rule}{handler}}(...)`), NOT the dump_parser_source artifact. The per-handler while(1)+LinkedRE::or /gc matching is already forward-progress-safe; the only engine-level hang is an unconditional NO-CONSUME self-recursion. A precise (rule,pos) non-progress cutoff terminates such cycles. RESOLVED: a recursive rule used AS the top/entry rule parses correctly with an LX accumulator-return; TOP vs BODY differ by arity, not an engine defect. Rust now mirrors termination and recursive value parity: declare(type, name) resolves bare type tokens literally and declared working vars are scoped per rule invocation."
answers:
  - "where does cross-rule call / recursion actually re-enter at runtime"
  - "is dump_parser_source the real runtime handler code"
  - "what makes the per-handler while(1) loop terminate (forward progress)"
  - "does a zero-width regex match hang the engine handler loop"
  - "what actually hangs the engine on recursion (no-consume cycle)"
  - "how is the forward-progress / consume-before-recurse termination guard implemented"
  - "where is the recursion termination guard in the code"
  - "does the recursion guard affect legitimate consume-before-recurse recursion"
  - "does a top-recursive grammar parse the same as the equivalent body-recursive grammar"
  - "why does a recursive rule as the top rule return null"
  - "does the rust variant terminate a no-consume recursive cycle or stack overflow"
  - "where is the rust forward-progress recursion guard (execute_rule / recursion_active)"
  - "why did the rust engine return nulls or leaked values for recursive s-expression grammars"
  - "how was Rust TOP-RULE-AS-NORMAL.3.2 fixed"
date: 2026-08-09
status: current termination guard; structured progress diagnostic migration pending under FUTURE-PARITY-BACKLOG.14.3
tags: [engine, parser, top-rule, recursion, termination, forward-progress, SpecEntry, TOP-RULE-AS-NORMAL, ADR-0010]
evidence: "TOOLBOX probes 2026-06-23 (TOP-RULE-AS-NORMAL.2.1). (1) call_spec_handler_subst shows call(rule) lowers to `&{$$descr{spec}{$rule}{handler}}($descr,$STRING,$minfo)` (ActionIR/Contracts.pm:134, MethodLowering.pm:332); {handler} is the SpecEntry::_build_runtime_handler closure (SpecEntry.pm:438 stores it; line ~262 IS it) -- so EVERY cross-rule call + recursion goes through that one real-Perl closure. dump_parser_source emits a SIMPLIFIED standalone artifact (`&{$descr->{spec}{$rule}}`) that differs from the runtime (`{...}{handler}`). (2) LinkedRE::or: seek = `/(?{...})$re/gcp` (scans FORWARD to EOF -> returns undef); consume = `/\\G(?{...})$re/gcp` (Perl's repeated-zero-width-match prohibition + /gc). Battery of zero-width grammars (probe3/probe4, seek+consume) -- NONE hang. (3) The ONLY reproduced engine hang: `top:: /a/ I { return(call(top)) }` whose handler is an unconditional self-tail-call with NO match/while(1) (dependency_regex_map empty); it OOMs. (4) Fix: a (rule,pos) active-stack non-progress cutoff in the SpecEntry runtime-handler closure -- re-entry at a position already active for that rule => return undef. phase0 960->963 (3 new locks), full run_ci_local.sh EXIT 0, zero regression. (5) SEPARATE GAP: a recursive S-expression grammar with `sexpr::` as the top rule returns null on `(a(b)c)`, while the IDENTICAL inner rule reached via a no-consume `top:: -> sexpr {return(call(sexpr))}` wrapper returns `[\"a\",[\"b\"],\"c\"]` -- the off-by-one in who consumes the leading token. Owned by .2.2."
evidence_update_2026_07_04: "TOP-RULE-AS-NORMAL.3.2 closed the Rust value parity gap after RUST-PARITY closed the recursive-grammar blocker. Root cause: Rust parsed `declare(array, items)` with raw first arg `Variable(\"array\")`, but the helper evaluated that as a runtime variable and got `\"\"`, making the declaration a no-op; recursive frames then shared the same auto-existing `items` array. Fix: Rust `declare(...)` resolves a raw first positional variable as the literal type token (`scalar`/`array`/`hash`) and RuntimeContext snapshots/restores declared working variables per rule invocation around interpreted and generated-plan direct rule execution. User functions suspend rule declaration tracking because they already use local variable stores; undeclared rule mutations remain caller-visible. Focused top-rule integration passes, corpus_oracle passes over 91 fixtures, and the corpus includes top_rule_body_recursion_sexpr, top_rule_lx_recursion_nested, and top_rule_lx_recursion_sequence."
evidence_update_2026_08_09: "FUTURE-PARITY-BACKLOG.14.3.0 reruns the documented scalar-reference LinkedSpec::Get probe for `Top:: I { return(call(Top)) }`: the runtime returns undef, emits `rule_handler_forward_progress:Top` with `non-progressing recursive re-entry at pos 0; cut to terminate`, and leaves runtime_ctx_ref last_error null. The guard remains correct termination protection, but the future portable source_location_nonprogress_direct_recursion/mutual_recursion records are not implemented yet. .14.3 owns that diagnostic migration without changing intrinsic child cursor policy."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test integration_test top_rule_as_normal -- --nocapture && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle -- --nocapture"
---

# Top-rule recursion: the runtime re-entry seam, the forward-progress guard, and the value gap

**Confirmed 2026-06-23** (`TOP-RULE-AS-NORMAL.2.1`; engine change authorized by ADR
[0010](../decisions/0010-top-rule-is-ordinary-rule-entered-first.md)). Refines
[[top-rule-is-ordinary-rule-entered-first]] with the `.2` ground-truth.

## Where recursion actually re-enters (not what `dump_parser_source` shows)

`call(rule)` / `-> rule` edges lower to `&{$$descr{spec}{$rule}{handler}}($descr, $STRING, $minfo)`
(`ActionIR/Contracts.pm:134`, `MethodLowering.pm:332`). `{handler}` is the closure built by
`SpecEntry::_build_runtime_handler` (stored at `SpecEntry.pm:438`). So **every** cross-rule call and
**every** recursion (top or body) passes through that single real-Perl closure. The
`dump_parser_source` output is a **simplified standalone artifact** (`&{$descr->{spec}{$rule}}`, a
direct CODE deref) and does **not** match the runtime structure (`…{$rule}{handler}`, a HASH with a
handler slot) — read the lowering, not the dump, when reasoning about runtime recursion.

## The per-handler loop already makes forward progress

`LinkedRE::or` (`perl/LinkedRE.pm`): **seek** is `/(?{…})$re/gcp` (no `\G`) — it scans *forward* for
the next match and reaches EOF → `undef`; **consume** is `/\G(?{…})$re/gcp` — anchored, but Perl's
prohibition on a repeated zero-width match at the same position plus `/gc` prevents same-position
spinning. A battery of zero-width / lookahead grammars in both modes (`probe3`/`probe4`) **never
hangs**. So the `while(1)` handler loop is not the non-termination source.

## The real engine hang, and the guard

The one reproduced engine-level hang is an **unconditional no-consume self-recursion**:
`top:: /a/  I { return(call(top)) }` compiles to a handler that is literally
`sub { … return &{…top…{handler}}(…) }` — no match, no `while(1)`, empty `dependency_regex_map` — so it
recurses forever and OOMs. Fix (`perl/LinkedSpec/SpecEntry.pm`, the `_build_runtime_handler` closure):
a **(rule, pos) active-stack non-progress cutoff** — a file-lexical `%__ls_recursion_active` keyed by
`"$descr\0$label\0" . pos`; if a rule is re-entered at a position already active on its own recursion
stack, no input was consumed since the enclosing entry, so the handler returns `undef` to terminate the
branch. Pushed on entry / popped after the eval-wrapped invocation (balanced). Legitimate
consume-before-recurse recursion always advances `pos()` first, so the cutoff never fires for a
terminating grammar — **phase0 960 → 963** (3 new locks), `tools/run_ci_local.sh` **EXIT 0**, zero
regression.

The cutoff is not yet the portable progress diagnostic. A current direct no-consume probe returns `undef`, emits
the trace decision above, and leaves `runtime_ctx_ref->{last_error}` null. `FUTURE-PARITY-BACKLOG.14.3` retains the
guard as a runtime backstop while adding invocation identity and exact structured direct/mutual non-progress
records. Zero-width success outside a progress obligation remains representable; repetition/recursive edges may
not silently spend it as progress.

## Top re-entry recursion VALUE: RESOLVED (`.2.2`) — no engine defect, missing-`LX` authoring case

A recursive S-expression grammar with `sexpr::` **as the top rule** at first appeared to return `null` on
`(a(b)c)` while the **identical** `sexpr` reached via a no-consume `top:: -> sexpr { return(call(sexpr)) }`
wrapper returned `["a",["b"],"c"]`. `.2.2` root-caused this and confirmed it is **not** an engine defect:

- **Root cause:** the default-handler `while(1)` ends each no-match iteration with `unless($minfo){ <lxcode> }`
  and the **default `lxcode` is `return undef`**. When the recursive rule is the entry rule, its OUTERMOST
  frame loops once more at EOF after the recursion consumes all input, hits `return undef`, and **discards its
  accumulator** => `null`. The BODY wrapper `return`s on the first dispatch and never loops to EOF.
- **Fix = the documented idiom, not engine code.** Adding `LX { return(array_copy(a(items))) }` (the same
  accumulator-return any accumulating top rule needs) makes it parse: `(a)`->`[["a"]]`,
  `(a(b)c)`->`[["a",["b"],"c"]]`, `(a) (b)`->`[["a"],["b"]]` (`probe9.pl`, dump-don't-transcribe).
- **TOP vs BODY are different grammars (different arity), by design.** `(a) (b)`: the TOP form accumulates the
  **sequence** of top-level forms (`[["a"],["b"]]`); the BODY wrapper parses **one** form (`["a"]`). "Make top
  re-entry behave identically to a body rule" was therefore a mis-framing — the engine already treats the top
  rule as an ordinary recursive rule; ADR `0010`'s authorized engine change was **not needed** for the value
  (only `.2.1`'s termination guard was). The recursive-top-rule-needs-`LX` model is documented in the book by
  `TOP-RULE-AS-NORMAL.4`. Locked by phase0 `top_rule_as_normal_recursion_with_lx_parses_sequence`.

## Cross-variant parity (Rust) — termination and value parity mirrored (`.3.1` + `.3.2`)

**Confirmed 2026-06-23** (`TOP-RULE-AS-NORMAL.3.1`). The Rust re-entry seam is
`Engine::execute_rule(label, entry_regex_idx, ctx)` — every blind-call edge, action edge, and the
`call(rule)` helper (`rust/linkedspec-runtime/src/engine.rs`) flows through it, the analogue of Perl's single
`SpecEntry::_build_runtime_handler` closure. A reproduce-first diagnosis (the four Perl phase0 grammars driven
through `parse_spec`→`validate`→`compile`→`Engine::execute`, dump-don't-transcribe) split the cross-variant
gap into two independent layers:

- **Termination (`.3.1`, DONE):** the no-consume grammar `top:: /a/ I { return(call(top)) }` made the Rust
  engine recurse **natively** (no forward-progress guard) → **stack overflow → SIGABRT (process abort)**,
  whereas Perl's `.2.1` guard returns `undef`. Fixed by the Rust mirror of the `(rule,pos)` cutoff: a
  `recursion_active: HashSet<(String,usize)>` on `RuntimeContext` (`enter_recursion`/`exit_recursion`) + a thin
  `Engine::execute_rule` wrapper around the renamed `execute_rule_inner` — re-entry at a `(label,pos)` already
  active ⇒ return `undef`; inserted on entry, removed on both the Ok and Err exit paths. A no-consume cycle now
  returns `[null]` (= Perl's `undef` wrapped one level by the Perl↔Rust accumulator output-shape rule);
  legitimate consume-before-recurse recursion (advances `ctx.pos` first) is untouched. Rust suite 242→244 green
  (2 new integration locks). phase0 + full local gate unaffected (no Perl change).
- **Value (`.3.2`, DONE 2026-07-04):** after `RUST-PARITY` closed the recursive-grammar blocker, the remaining
  Rust gap was declaration state, not top-rule dispatch. `declare(array, items)` had been a no-op because Rust
  evaluated the bare type token `array` as a variable. Recursive frames therefore mutated the same auto-existing
  `items` array. Rust now resolves raw declaration type tokens literally and scopes declared working variables per
  rule invocation, while preserving caller-visible mutations for undeclared variables. Focused top-rule locks pass,
  and the 91-fixture oracle corpus includes body recursion, nested top-rule `LX` recursion, and top-rule sequence
  recursion.

## Links

- Decision: [0010](../decisions/0010-top-rule-is-ordinary-rule-entered-first.md)
- Tree: [[TOP-RULE-AS-NORMAL]] (closed; `.2.1`/`.3.1` termination guards, `.2.2` Perl top-recursion value model,
  `.3.2` Rust recursive value parity)
- Files: `perl/LinkedSpec/SpecEntry.pm` (`_build_runtime_handler` closure + `%__ls_recursion_active`),
  `perl/LinkedRE.pm` (`or`), `perl/LinkedSpec/ActionIR/Contracts.pm:134`, `t/phase0_regression.t` (4 locks);
  Rust mirror (`.3.1`/`.3.2`): `rust/linkedspec-runtime/src/runtime.rs` (`recursion_active` +
  `enter_recursion`/`exit_recursion`, declaration scopes), `rust/linkedspec-runtime/src/engine.rs`
  (`execute_rule` guard wrapper, `declare(...)` type-token handling, generated-plan rule scopes),
  `rust/linkedspec-runtime/tests/integration_test.rs`, `tools/gen_oracle_corpus.pl`, and
  `rust/linkedspec-runtime/tests/corpus/` (recursive value locks)
- Related: [[top-rule-is-ordinary-rule-entered-first]], [[spec-top-rule-no-regex-two-rule-minimum]],
  [[lispish-corpus-catastrophic-backtracking]], [[cross-variant-output-parity]],
  [[cursor-transaction-safety-audit-plan]]
