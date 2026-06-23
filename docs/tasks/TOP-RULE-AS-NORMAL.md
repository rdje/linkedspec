# TOP-RULE-AS-NORMAL: treat the top rule as an ordinary rule (entered first) w.r.t. regex + recursion

## Metadata

- Tree ID: `TOP-RULE-AS-NORMAL`
- Status: `active` (created 2026-06-23)
- Roadmap lane: `Overall roadmap — .spec language model / engine evolution`
- Created: `2026-06-23`
- Last updated: `2026-06-23` (**`.4` DONE** — book reconciliation to the new model. Demoted "Body rule
  only" / "no regex on top" / "needs at least two rules" from law to **idiom** across 6 book files
  (`appendix/formal-grammar.md`, `user-model/{rule-modes-and-parse-modes,spec-files-and-rule-paragraphs,worked-spec-walkthrough}.md`,
  `overview/what-is-linkedspec.md`, `appendix/helper-contract-catalog.md`); documented `::` = entry marker /
  ordinary-rule-entered-first, the consume-before-recurse forward-progress **termination** rule (formal-grammar
  §5.4), and the recursive-top-rule-needs-`LX` model; **de-footgunned** the `Pair::AND` regex-on-top example
  (`entry_text()`→`match_group(0)` from a post-match edge; folded the bare separator slot) and **fixed** the
  worked-walkthrough multi-pair output bug (two pairs is a `seek` result, not `consume`). All examples verified
  via `LinkedSpec::Get` (dump-don't-transcribe); `mdbook build` EXIT 0; book variant-agnostic. +1 phase0 lock
  (`top_rule_as_normal_regex_on_top_reads_own_match_with_match_family`, 3 assertions): **phase0 964→965 green**;
  new KM card [[top-rule-reads-own-match-with-match-family]]. **All `.4` children done; tree acceptance met.**
  Earlier this day: `.3` SPLIT → `.3.1` (DONE) + `.3.2` (BLOCKED on `RUST-PARITY`).)
- Owner: repo-local workflow

## Goal

Make the **top rule** behave as an **ordinary rule that is merely entered first** (`::` = entry marker),
uniform with normal rules with respect to **regex** and **recursion (re-entry)**, guarded by a
**consume-before-recurse / forward-progress** termination rule. Reframe the book so "no regex on top" /
"`:AND`… Body-rule-only" read as the recommended **idiom**, not as engine laws. Per the user design
decision + engine-touch authorization in ADR [0010](../decisions/0010-top-rule-is-ordinary-rule-entered-first.md).

## Non-Goals

- Changing the grammar class (it stays recursive descent; the gain is ergonomic/conceptual).
- Removing the 2-rule idiom as recommended style — it stays, demoted from "law" to "idiom".
- A Perl-only divergence: the `.spec` contract is universal ([[spec-contract-is-unique]]), so the change
  is mirrored to / tracked for Rust (and future Julia/Dart) for parity ([[cross-variant-output-parity]]).
- Touching unrelated engine behavior. The engine stays frozen except for this ADR-`0010`-sanctioned change.

## Acceptance Criteria

- The top rule works as an ordinary rule across the {mode}×{regex}×{recursion} matrix, including
  **recursion back into the top rule**, with a forward-progress guard so a no-consume cycle cannot hang.
- `t/phase0_regression.t` stays **960/960 green**; new behavior is locked by explicit regression subtests;
  `bash tools/run_ci_local.sh` EXIT 0.
- Cross-variant parity: the Rust variant produces identical match/no-match + output for the new locks
  (Perl is the reference).
- The mdBook reframes the "Body rule only" / "no regex on top" claims as idiom, documents `::` as
  "entered first, otherwise ordinary", and documents the consume-before-recurse termination rule;
  `mdbook build` EXIT 0; book stays variant-agnostic.

## Task Tree

- ID: `TOP-RULE-AS-NORMAL` · Status: `active` (acceptance MET; tree stays open only because `.3.2` is
    `blocked` on `RUST-PARITY` — frontier is otherwise empty) · Children: `.1` (done), `.2` (done),
    `.3` (active: `.3.1` done, `.3.2` blocked), `.4` (done)
- ID: `TOP-RULE-AS-NORMAL.1` · Status: `done` (2026-06-23)
  Goal: Read-only investigation — what does the engine actually special-case about `::` w.r.t. regex and
    recursion? Establish the real model + the precise gap, before any engine edit.
  Acceptance: model + gap recorded with evidence (TOOLBOX probes). **MET.**
  Findings (TOOLBOX: `LinkedSpec::Get`, `generate_only`+`dump_parser_source`, codegen grep):
    • The entry point is just `sub Get { &{$descr->{spec}{$top_rule}}($descr,$_[0]) }`
      (`Compiler.pm:1006`) — the top rule is **not** specially wrapped.
    • `while(1)` is **mode-driven** (default/OR/REP repeat; `:AND` is single-pass) in
      `HandlerVariantEmitter.pm`, **not** top-driven. The "top = `while(1)` dispatch loop" behavior is an
      idiom (default-mode top + dispatch edges + `LX` accumulator), not a language law.
    • Regex on a top rule **already** compiles as a normal rule: `Pair::AND` + regex slots + a `return`
      edge emits a standard AND handler (`while ($idx < 2) { LinkedRE::or(...) … }`) and runs — the earlier
      breakage was the AND-codegen defect already fixed (ADR `0008` / `PHASE0-BACKHALF-TRIAGE.3`).
    • Idiomatic recursion is body-rule + consume-before-recurse (`specs/Lispish.spec`:
      `parenthesis: /\(/ … -> parenthesis … /\)/`) and is green. Naive grammars that recurse **back into
      the top rule** (or use zero-progress blind-call dispatch) **hang** — the open dimension. (Same family
      as the `PHASE0-BACKHALF-TRIAGE.5.2` never-`undef`/`while(1)` non-termination.)
  Verification: probe scripts under the session scratchpad; emitted-source dump for `Pair::AND`; Lispish
    recursion inspection; codegen grep. No code changed.
  Commit: (this commit)
- ID: `TOP-RULE-AS-NORMAL.2` · Status: `done` (2026-06-23 — `.2.1` termination guard landed + `.2.2` confirmed no engine defect; engine work for this tree complete)
  Goal: Perl reference engine — confirm the full {top}×{mode}×{regex}×{recursion} matrix; enable/verify
    **recursion back into the top rule** behaves identically to a body rule; add a **forward-progress /
    consume-before-recurse** guard so a no-consume recursive cycle cannot hang. Lock every confirmed/new
    behavior with `t/phase0_regression.t` subtests.
  Children: `.2.1` (forward-progress termination guard + matrix confirmation + locks — done),
    `.2.2` (top re-entry recursion VALUE correctness — discovered during `.2.1`, pending).
- ID: `TOP-RULE-AS-NORMAL.2.1` · Status: `done` (2026-06-23)
  Goal: Forward-progress / consume-before-recurse termination guard so a no-consume recursive cycle
    cannot hang; confirm the recursion matrix; lock the termination properties with phase0 subtests.
  Findings (TOOLBOX ground-truth, scratchpad probes 1–7; KM [[top-rule-recursion-forward-progress-guard]]):
    • **Real re-entry seam:** `call(rule)`/`-> rule` lower to `&{$$descr{spec}{$rule}{handler}}(...)`
      (`ActionIR/Contracts.pm:134`, `MethodLowering.pm:332`); `{handler}` IS the
      `SpecEntry::_build_runtime_handler` closure (`SpecEntry.pm:438`) — so every cross-rule call + every
      recursion passes through that ONE real-Perl closure. `dump_parser_source` is a simplified standalone
      artifact (`&{…{$rule}}`) that does NOT match the runtime shape (`…{$rule}{handler}`).
    • **The per-handler `while(1)` already makes forward progress:** `LinkedRE::or` seek `/…/gcp` scans to
      EOF→undef; consume `/\G…/gcp` is protected by Perl's repeated-zero-width-match prohibition. A battery
      of zero-width/lookahead grammars in seek+consume NEVER hangs.
    • **The one reproduced engine hang:** `top:: /a/ I { return(call(top)) }` — an unconditional no-consume
      self-tail-call (no match, no loop, empty dep-regex map) → OOM.
    • **Fix:** a **(rule, pos) active-stack non-progress cutoff** in the runtime-handler closure
      (`perl/LinkedSpec/SpecEntry.pm`): file-lexical `%__ls_recursion_active` keyed by `"$descr\0$label\0pos"`;
      re-entry at a position already active for that rule ⇒ return `undef` (cut). Pushed on entry / popped
      after the eval-wrapped invocation (balanced). Legitimate consume-before-recurse recursion always
      advances `pos()` first, so the cutoff never fires for a terminating grammar.
  Acceptance: a no-consume cycle terminates instead of hanging; legitimate recursion unaffected;
    phase0 stays green + new locks; full local gate EXIT 0. **MET.**
  Verification: `perl -c` clean (SpecEntry.pm, LinkedSpec.pm, test); probe5 E4 HANG→`null` (guard trace
    fires); probes 2/4/7 consume-recursion unchanged; **phase0 960→963** (3 new locks: no-consume-cycle
    terminates+undef, body-recursion parses `(a(b)c)`→`["a",["b"],"c"]`, top-recursion terminates);
    `bash tools/run_ci_local.sh` **EXIT 0** ("Result: PASS", 963 tests). Zero regression.
  Commit: (this commit)
- ID: `TOP-RULE-AS-NORMAL.2.2` · Status: `done` (2026-06-23 — CONFIRMED no engine defect; doc + lock outcome, engine untouched)
  Goal: Top re-entry recursion **VALUE correctness** — make a recursive rule used directly AS the top/entry
    rule parse identically to the same rule used as a body rule. Root-cause the entry-alignment divergence
    first (TOOLBOX trace + `dump_parser_source` of the runtime handler), then a minimal, regression-locked
    engine change; keep phase0 green; cross-variant parity tracked for `.3`.
  Open finding (the gap to fix): a recursive S-expression grammar with `sexpr::` as the **top** rule returns
    `null` on `(a(b)c)`, while the IDENTICAL `sexpr` reached via a no-consume `top:: -> sexpr {return(call(sexpr))}`
    wrapper returns `["a",["b"],"c"]`. The handler source is the same; the divergence is the entry alignment —
    who consumes the leading token (the body form's wrapper eats the outermost `(` before delegating; the top
    form must match its own `(`, firing the `-> sexpr` recurse edge on the open paren). `.2.1`'s phase0 lock
    `top_rule_as_normal_top_recursion_terminates` already pins TERMINATION (no hang) but deliberately does NOT
    assert the (currently-wrong) value — `.2.2` will assert the correct value and tighten that lock.
  ROOT CAUSE (confirmed 2026-06-23 by reading the dispatch + `call` lowering; the empirical fix-direction probe
    is PENDING — blocked momentarily by a sandbox-classifier/Bash outage, dump-don't-transcribe still owed):
    • The default-handler `while(1)` loop (`HandlerVariantEmitter::_emit_default_handler`) ends each no-match
      iteration with `unless($minfo){ <lxcode> }`, and the **default `lxcode` is `return undef`**
      (`_emit_default_handler`: `$ir->{lxcode} || 'return undef'`).
    • A single-regex I-block rule (`atom: /…/ I.return(entry_text())`) consumes via the **caller's** dispatch
      match and processes the **incoming** `$info` (it does not re-match), so the parent rule's dispatch
      (`LinkedRE::or` over `dependency_regex_map{$label}`) is what advances `pos()` and the child just reads it.
    • Therefore, for `sexpr::` as the entry rule: the OUTERMOST frame matches the first `(` (branch 0 → the
      `-> sexpr` recurse edge), recurses, and the recursion consumes the entire balanced input incl. the
      matching `)`. Control returns to the outermost frame, whose `while(1)` iterates once more at EOF, matches
      nothing, and hits `lxcode = return undef` — **discarding its accumulated `items`** → `null`. The BODY
      form never loops to EOF: its `top:: -> sexpr {return(call(sexpr))}` wrapper `return`s on the first
      dispatch, and the inner `sexpr` closes via the `-> sexpr[1]` (`)`) edge while parens are balanced inside.
  REASONED fix-direction (to CONFIRM empirically before any edit): adding `LX { return(array_copy(a(items))) }`
    to the `sexpr::` top rule should make the EOF branch return the accumulator instead of `undef` (no more
    `null`), but the result is expected to be one wrapping level deeper than BODY (`[["a"]]` vs `["a"]`) because
    the top-level accumulating loop wraps the sequence — i.e. the TOP and BODY forms are arguably **different
    grammars** (different arity), and a recursive top rule needs an `LX` accumulator-return exactly like any
    accumulating top rule (the documented `top:: -> x .push` + `LX{…}` idiom). If confirmed, `.2.2` is likely a
    DOC + LOCK outcome (NO engine change — engine-frozen doctrine), NOT an engine defect; the alternative (make
    a bare recursive top rule auto-return its non-empty accumulator at EOF) is a broader default-`lxcode` change
    and must clear phase0. DECIDE from the probe (`probe9.pl`: TOP+LX vs BODY on `(a)`/`(a(b)c)`/`(a) (b)`).
  CONFIRMED (2026-06-23, `probe9.pl`, dump-don't-transcribe): the reasoned fix-direction holds exactly —
    `sexpr::` + `LX { return(array_copy(a(items))) }` parses (NO null): `(a)`->`[["a"]]`,
    `(a(b)c)`->`[["a",["b"],"c"]]`, `(a) (b)`->`[["a"],["b"]]`. The `(a) (b)` case is decisive: the TOP form
    accumulates the **sequence** of top-level forms (`[["a"],["b"]]`), while the BODY wrapper parses **one**
    form and returns it (`["a"]`) — the two are **intentionally different grammars (different arity)**, NOT an
    engine defect. **Conclusion: top re-entry recursion already works as an ordinary recursive rule** (ADR
    `0010`'s goal is met by the engine; the authorized engine change is NOT needed for the VALUE — only `.2.1`'s
    termination guard was). The original `null` was the **missing-`LX` authoring case**: a bare accumulating top
    rule returns `undef` at EOF (the documented `top:: -> x .push` + `LX{...}` idiom applies to recursive top
    rules too). So `.2.2` is a DOC + LOCK outcome; the engine stays frozen.
  Acceptance: top re-entry recursion parses + terminates with the `LX` idiom; confirmed no engine defect; locked
    by a phase0 subtest; phase0 green; `perl -c` clean; `bash tools/run_ci_local.sh` EXIT 0; verified via TOOLBOX.
    **MET** (no engine change). Book documentation of the recursive-top-rule-needs-`LX` model deferred to `.4`.
  Verification: `probe9.pl` (TOP+LX vs BODY); new phase0 lock `top_rule_as_normal_recursion_with_lx_parses_sequence`
    (`(a(b)c)`->`[["a",["b"],"c"]]`, `(a) (b)`->`[["a"],["b"]]`); `perl -c` clean; **phase0 963->964 green**;
    `bash tools/run_ci_local.sh` **EXIT 0** ("Result: PASS", 964 tests); zero regression.
  Commit: (this commit)
- ID: `TOP-RULE-AS-NORMAL.3` · Status: `active` (split 2026-06-23 into `.3.1` + `.3.2` after a Rust-side
    diagnosis showed the cross-variant gap has two independent layers — see Decisions/Changelog)
  Goal: Cross-variant parity — mirror the behavior in the Rust variant (and track for Julia/Dart); the new
    phase0 locks (or their cross-variant equivalents) produce identical output. Perl is the reference.
  Children: `.3.1` (termination parity — forward-progress guard, the genuinely top-rule-as-ordinary-specific
    obligation), `.3.2` (value parity on recursive top-rule grammars — the GENERAL recursive-grammar parse
    gap, owned/blocked by `RUST-PARITY`).
- ID: `TOP-RULE-AS-NORMAL.3.1` · Status: `done` (2026-06-23)
  Goal: **Termination parity** — mirror the Perl `.2.1` forward-progress / consume-before-recurse guard in
    the Rust variant so a no-consume recursive cycle TERMINATES cleanly (no native stack overflow / process
    abort) instead of crashing, exactly as the Perl reference returns `undef`. Lock with a Rust test.
  Diagnosis (TOOLBOX "reproduce-first", scratchpad diagnostic test driven through `parse_spec`→`validate`→
    `compile`→`Engine::execute`, dump-don't-transcribe; Rust baseline 242 tests green / `cargo build` clean):
    • **GAP CONFIRMED:** the no-consume grammar `top:: /a/  I { return(call(top)) }` on `"aaa"` makes the Rust
      engine recurse natively through `Engine::execute_rule` (`call(child)` → `execute_rule(&child,…)` at
      `engine.rs:756`, NO depth/forward-progress guard) → **stack overflow → SIGABRT (process abort)**, while
      the Perl reference returns `undef` cleanly (phase0 `top_rule_as_normal_no_consume_recursion_terminates_not_hang`).
    • Real re-entry seam = `Engine::execute_rule(label, entry_regex_idx, ctx)` (every blind-call edge,
      action-edge, and `call(rule)` helper flows through it: `engine.rs:222/340/756`) — the Rust analogue of
      Perl's single `SpecEntry::_build_runtime_handler` closure ([[top-rule-recursion-forward-progress-guard]]).
  Fix: a **(rule-label, input-pos) active-set non-progress cutoff** in `RuntimeContext` + a thin
    `Engine::execute_rule` wrapper around the renamed `execute_rule_inner` — re-entry at a `(label, pos)`
    already on the active recursion set ⇒ return `Undef` (cut). Inserted on entry / removed on exit (balanced
    across the Ok and Err paths). Mirrors the Perl `%__ls_recursion_active` keyed by `"$descr\0$label\0$pos"`.
    Legitimate consume-before-recurse recursion always advances `ctx.pos` first, so the cutoff never fires for
    a terminating grammar.
  Acceptance: a no-consume recursive cycle terminates cleanly in Rust (no overflow/abort) instead of crashing;
    existing Rust tests stay green; new Rust regression lock; Perl phase0 + full local gate unaffected. **MET.**
  Verification: see Verification Log (`.3.1`).
  Commit: (this commit)
- ID: `TOP-RULE-AS-NORMAL.3.2` · Status: `blocked`
  Goal: **Value parity** — the Rust variant produces the same parse OUTPUT as Perl for recursive top-rule
    grammars: body-recursion `(a(b)c)`→`["a",["b"],"c"]`, top-recursion-with-`LX` `(a(b)c)`→`[["a",["b"],"c"]]`
    and `(a) (b)`→`[["a"],["b"]]` (subject to the documented Perl↔Rust accumulator output-shape rule).
  Diagnosis (same probe): the Rust engine returns **nulls** for ALL of these — body-recursion (the standard
    `top:: -> sexpr` wrapper idiom) `(a(b)c)`→`[[null],[null]]`, top-`LX` `(a(b)c)`→`[[null],[null]]` and
    `(a) (b)`→`[[null],[null]]`, top-no-`LX` `(a(b)c)`→`[[null]]`. Because **the standard body-recursion idiom
    is ALSO wrong**, this is NOT a top-rule-as-ordinary issue — it is the **general recursive-grammar parse
    gap** (atoms/`entry_text()` in nested dispatch + multi-slot `-> rule[1]` self-entry + accumulator return),
    which the Rust corpus harness already documents as deferred and landing incrementally under `RUST-PARITY`
    (`tests/corpus_oracle.rs`: Lispish needs `RUST-PARITY.7.5.2`; recursive specs deferred from the corpus).
  Blocker: the Rust engine cannot yet correctly parse recursive S-expression-class grammars (returns nulls);
    that capability is owned by `RUST-PARITY` (recursive-spec parity, e.g. Lispish `.7.5.2`+).
  Unblock condition: `RUST-PARITY` lands recursive-grammar parse parity (a recursive body grammar like
    `specs/Lispish.spec` produces the Perl-matching nested AST in Rust). Then `.3.2` adds the top-rule
    recursion oracle corpus entries / Rust locks on top of that capability.
  Next task instead: `.4` (book reconciliation) is PNT-eligible now; `.3.2` re-enters the frontier when the
    blocker clears.
  Verification: `pending`  ·  Commit: `pending`
- ID: `TOP-RULE-AS-NORMAL.4` · Status: `done` (2026-06-23) (absorbs the superseded `PHASE0-BACKHALF-TRIAGE.6` book work)
  Goal: Book reconciliation to the new model — demote "Body rule only" / "no regex on top" from law to
    **idiom**; document `::` as "the rule entered first, otherwise ordinary"; document the
    consume-before-recurse termination rule; de-footgun the book's own `Pair::AND` regex-on-top teaching
    examples. Files: `appendix/formal-grammar.md`, `user-model/rule-modes-and-parse-modes.md`,
    `overview/what-is-linkedspec.md`, `worked-spec-walkthrough.md`,
    `user-model/spec-files-and-rule-paragraphs.md` (+ `appendix/helper-contract-catalog.md`, discovered
    during the whole-book consistency sweep — it carried the same "needs at least two rules" law claim).
  What landed (all examples verified via `LinkedSpec::Get`, dump-don't-transcribe):
    • **Canonical model** in `spec-files-and-rule-paragraphs.md`: a new "The top (`::`) rule is an ordinary
      rule, entered first" section (`::` = entry marker; modes/regex/recursion all legal on a top rule;
      two-rule no-regex shape = idiom), plus the `entry_*` vs `match_*` distinction, the
      consume-before-recurse termination rule, and the recursive-top-rule-needs-`LX` model with a verified
      `sexpr::`+`LX` example (`(a(b)c)`→`[["a",["b"],"c"]]`, `(a) (b)`→`[["a"],["b"]]`; no-`LX`→`null`).
    • **formal-grammar.md**: §2.1 `::` = entry marker / ordinary-rule note; §2.2 table column "Body rule only"
      → "Typical placement" with every mode cell "Body rule (idiom)" + an idiom-not-law note (modes legal on
      a top rule: `Top::AND`, `Stream::OR+`, `Pair::&`); new **§5.4 Recursion and Forward-Progress
      Termination** (recursion may re-enter the top rule; consume-before-recurse; a non-progressing cycle is
      cut to `undef`; backends MUST guarantee this — confirmed cross-variant by the `.3.1` Rust mirror).
    • **what-is-linkedspec.md** / **worked-spec-walkthrough.md** / **helper-contract-catalog.md**: reframed
      "normal shape of every `.spec`" / "every `.spec` ... at least two rules" / "regex ... never on the `::`
      entry rule" / "a valid `.spec` needs at least two rules" from law to recommended idiom.
    • **De-footgun (`rule-modes-and-parse-modes.md`)**: the `Pair::AND` action example used `entry_text()`
      (→ `{name:null,value:null}` — a top rule has no entering match); fixed to a post-match edge action +
      `match_group(0)` and folded the bare `\s*=\s*` separator into the name slot (→ `{name:"name",
      value:"value"}`). Added a model-tie note up top.
    • **Correctness fix (`worked-spec-walkthrough.md`)**: the multi-pair `'a = 1, b = 2'` two-pair output was
      a `seek` result presented in the `consume` context (under `consume` only the first pair matches —
      cursor stops at the comma); reframed accurately as the consume-vs-seek distinction in miniature.
    • **Lock + KM**: +1 phase0 lock `top_rule_as_normal_regex_on_top_reads_own_match_with_match_family`
      (3 assertions: builds; `match_group(0)`→populated; `entry_text()`→null); new KM card
      [[top-rule-reads-own-match-with-match-family]].
  Acceptance: no book `.spec` example broken/doctrine-contradictory; law-vs-idiom explicit; termination
    rule documented; `mdbook build` EXIT 0; outputs verified via `LinkedSpec::Get`; book variant-agnostic.
    **MET.**
  Discovered (out of `.4` scope — tracked as an open question): in `AND` mode a bare edge-less middle regex
    slot is a positional anchor that is not separately consumed (the value slot's `match_*` started before
    the un-consumed separator). Affects only illustrative no-output structural sketches; not a broken example.
  Verification: see Verification Log (`.4`).
  Commit: (this commit)

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | `.1` | `done` 2026-06-23 | Read-only investigation complete: regex/codegen already uniform; open gap = top re-entry recursion + termination. ADR `0010`. |
| — | `.2.1` | `done` 2026-06-23 | Forward-progress / consume-before-recurse termination guard (one-site (rule,pos) cutoff in `SpecEntry.pm`) + 3 phase0 locks; 960→963 green, full gate EXIT 0. |
| — | `.2.2` | `done` 2026-06-23 | Top re-entry recursion VALUE correctness — CONFIRMED no engine defect: the top-recursive grammar parses with the `LX` accumulator idiom (`null` was the missing-`LX` authoring case); TOP vs BODY are different grammars (different arity). Doc+lock, engine frozen. +1 phase0 lock; 963→964. |
| — | `.3.1` | `done` 2026-06-23 | Termination parity — Rust forward-progress / consume-before-recurse guard (mirror of `.2.1`): a no-consume recursive cycle now terminates cleanly (no native stack overflow / SIGABRT) instead of crashing; +1 Rust lock; Rust 242→243 green, zero regression. |
| — | `.3.2` | `blocked` | Value parity on recursive top-rule grammars — blocked on the GENERAL recursive-grammar parse gap (Rust returns nulls even for the standard body-recursion idiom), owned by `RUST-PARITY` (Lispish `.7.5.2`+). Out of frontier until that capability lands. |
| — | `.4` | `done` 2026-06-23 | Book reconciliation to the new model (absorbs `PHASE0-BACKHALF-TRIAGE.6`): demoted law→idiom across 6 book files; documented `::`=entry-marker, the consume-before-recurse termination rule (formal-grammar §5.4), and recursive-top-rule-needs-`LX`; de-footgunned the `Pair::AND` example (`entry_text()`→`match_group(0)`) + fixed the multi-pair consume/seek output bug; +1 phase0 lock (964→965); KM card [[top-rule-reads-own-match-with-match-family]]; `mdbook build` EXIT 0. |
| — | _(empty)_ | — | **No PNT-eligible leaf remains.** Tree acceptance is MET; only `.3.2` (value parity) remains, `blocked` on `RUST-PARITY` recursive-grammar parse parity — out of frontier until that capability lands. PNT should select the next active tree (`SPEC-FORMAT-TERSE.1.x`). |

## Decisions

- `2026-06-23` (user, via AskUserQuestion + follow-ups): the top rule is an ordinary rule merely entered
  first; the no-regex dispatch loop is an idiom, not a law; recursion into/through the top rule is allowed
  with a consume-before-recurse termination rule. The user then **authorized touching the Perl variant**
  to implement it. Recorded in ADR `0010` (sanctioned engine-frozen exception, like `0008`).
- `2026-06-23`: scope correction from the `.1` investigation — the regex/codegen dimension is **already
  uniform** (`.3` AND-codegen fix), so the actionable engine work is narrower than it first appeared:
  top-rule re-entry recursion + a forward-progress guard, then parity + docs.

## Open Questions

- ~~Exactly where does top re-entry diverge from body-rule recursion?~~ **Answered (`.2.1`):** NOT in
  codegen (the handler source is identical) and NOT in the per-handler `while(1)` (`LinkedRE::or`'s `/gc`
  matching is already forward-progress-safe). Two distinct things were found: (a) a no-consume self-recursion
  hang — fixed by the `.2.1` guard; (b) a **value** divergence — a recursive rule AS the top rule returns
  `null` while the same rule as a body rule parses — an **entry-alignment** difference (who consumes the
  leading token). (b) is owned by `.2.2`.
- ~~Should the forward-progress guard be global or scoped to top re-entry?~~ **Decided (`.2.1`): global but
  precise** — one cutoff in the shared `SpecEntry` runtime-handler closure (every cross-rule call/recursion
  flows through it), firing ONLY on a genuine (rule,pos) non-progress cycle, so it protects all recursion
  yet never touches a terminating grammar (proven: phase0 963/963).
- ~~`.2.2`: what is the minimal engine change that makes a top-recursive entry rule align like the body form?~~
  **Answered (`.2.2`): none — no engine change.** `probe9.pl` confirmed a recursive rule used AS the top rule
  parses correctly with an `LX` accumulator-return; the `null` was the missing-`LX` authoring case (a bare
  accumulating top rule returns `undef` at EOF). The TOP and BODY forms are intentionally different grammars
  (different arity: TOP accumulates the sequence of top-level forms, BODY returns a single form), so "align them"
  was a mis-framing. The engine already treats the top rule as an ordinary recursive rule. Doc + lock; engine
  frozen (ADR `0010`'s authorized change unused for the value — only `.2.1`'s termination guard was needed).

## Blockers

- None. ADR `0010` clears the engine-frozen blocker for this specific change. `.2` is the next executable
  leaf; recommended in a fresh session for signoff-quality codegen work.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-23` | `.1` | TOOLBOX read-only probes (`LinkedSpec::Get`, `generate_only`+`dump_parser_source`, codegen grep of `Compiler.pm`/`HandlerVariantEmitter.pm`/`SpecEntry.pm`); `Pair::AND` emitted-source dump; `specs/Lispish.spec` recursion inspection | `done` — top rule is just a handler call; `while(1)` is mode-driven; regex-on-top already compiles normally; open gap = top re-entry recursion + termination. No code changed. |
| `2026-06-23` | `.2.1` | TOOLBOX probes (`call_spec_handler_subst` re-entry seam, `dump_parser_source`, fork+SIGKILL hang census across zero-width/recursive grammars); `perl -c` SpecEntry.pm+LinkedSpec.pm+test; full `perl -Iperl t/phase0_regression.t`; `bash tools/run_ci_local.sh` | `done` — engine guard added to `SpecEntry.pm`; E4 no-consume hang→`null`; consume-recursion unchanged; **phase0 960→963** (3 new locks, 0 regression); full local gate **EXIT 0** ("Result: PASS"). Discovered the `.2.2` top-recursion value gap. |
| `2026-06-23` | `.2.2` | `probe9.pl` (TOP+`LX` vs BODY on `(a)`/`(a(b)c)`/`(a) (b)`, dump-don't-transcribe); `perl -c`; full `perl -Iperl t/phase0_regression.t`; `bash tools/run_ci_local.sh` | `done` — CONFIRMED no engine defect: `sexpr::`+`LX` parses (`(a(b)c)`→`[["a",["b"],"c"]]`, `(a) (b)`→`[["a"],["b"]]` = sequence vs BODY's single `["a"]`); the `null` was the missing-`LX` authoring case. +1 phase0 lock; **phase0 963→964**; full local gate **EXIT 0** ("Result: PASS", 964). No engine/spec change. |
| `2026-06-23` | `.3.1` | Rust reproduce-first diagnostic (scratchpad test via `parse_spec`→`validate`→`compile`→`Engine::execute`, dump-don't-transcribe): baseline `cargo build` clean + 242 tests green; no-consume `top:: /a/ I{return(call(top))}` on `"aaa"` → **stack overflow → SIGABRT** (GAP). After guard: `cargo build` clean; the 2 new locks pass (`top_rule_as_normal_3_1_no_consume_recursion_terminates` ⇒ `[null]`; `..._consume_before_recurse_is_not_cut` ⇒ array); **full Rust suite 242→244 green** (integration 23→25; corpus/core/unit unchanged); clippy on the changed lib clean (no findings in `runtime.rs`/the added `engine.rs` wrapper; pre-existing `clippy --tests` debt untouched); **phase0 964/964** + `bash tools/run_ci_local.sh` **EXIT 0** (Perl untouched). | `done` — Rust mirror of the `.2.1` `(rule,pos)` forward-progress cutoff; a no-consume recursive cycle terminates cleanly instead of crashing; legitimate consume-before-recurse recursion left intact; zero regression. |
| `2026-06-23` | `.4` | `LinkedSpec::Get` example verification (scratchpad `verify4*.pl`, dump-don't-transcribe): de-footgunned `Pair::AND`→`{"name":"name","value":"value"}`; `entry_text()` footgun→`{"name":null,"value":null}`; `sexpr::`+`LX` `(a(b)c)`→`[["a",["b"],"c"]]`, `(a) (b)`→`[["a"],["b"]]`, no-`LX`→`null`; worked-spec consume `answer = 42`→1 pair, seek `a = 1, b = 2`→2 pairs, consume `a = 1, b = 2`→1 pair; what-is kv→`[{"key":"foo","val":"bar"},{"key":"baz","val":"qux"}]`; no-consume cycle→`null`. `mdbook build` EXIT 0 (anchor verified from generated HTML). `perl -c` clean; **phase0 964→965** (new lock + its 3 assertions pass); doctrine driver 2/2 PASS (KM regenerated); `bash tools/run_ci_local.sh` EXIT 0. | `done` — 6 book files reconciled law→idiom; `::`=entry-marker + §5.4 termination + recursive-top-rule-needs-`LX` documented; `Pair::AND` de-footgunned; multi-pair consume/seek bug fixed; +1 phase0 lock; KM card added; book variant-agnostic; zero regression. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.1` | `TOP-RULE-AS-NORMAL.1 — own the lane + read-only investigation; ADR 0010 (authorize engine change)` | this commit (DOC-ONLY; engine untouched) |
| `.2.1` | `TOP-RULE-AS-NORMAL.2.1 — forward-progress/consume-before-recurse termination guard (SpecEntry runtime-handler closure) + 3 phase0 locks; split .2; discover .2.2 top-recursion value gap` | `c2814da` (engine: 1 file, `perl/LinkedSpec/SpecEntry.pm`; +3 phase0 locks; ADR 0010) |
| `.2.2` | `TOP-RULE-AS-NORMAL.2.2 — confirm top re-entry recursion works with the LX accumulator idiom (NO engine defect; engine frozen); +1 phase0 lock; close .2` | this commit (TEST+DOC only; +1 phase0 lock; no engine/spec change) |
| `.3.1` | `TOP-RULE-AS-NORMAL.3.1 — Rust forward-progress/consume-before-recurse termination guard (mirror of .2.1); split .3; +2 Rust locks` | `808ce0d` (Rust: `rust/linkedspec-runtime/src/{runtime,engine}.rs` + 2 integration locks; Perl untouched) |
| `.4` | `TOP-RULE-AS-NORMAL.4 — book reconciliation (law→idiom across 6 book files; ::=entry-marker + §5.4 termination + recursive-top-rule-needs-LX; de-footgun Pair::AND; fix multi-pair consume/seek bug); +1 phase0 lock; KM card` | this commit (BOOK+TEST+DOC; 6 book files + `t/phase0_regression.t` + KM card; no engine/spec change) |

## Changelog

- `2026-06-23` (`.4`): **Book reconciliation DONE; tree acceptance MET.** Reconciled the mdBook to the
  ADR-`0010` model across **6 files**. Demoted the law claims to **idiom**: `formal-grammar.md` §2.2 table
  column "Body rule only" → "Typical placement" / "Body rule (idiom)" + a "modes are legal on a top rule"
  note; the "needs at least two rules" / "regex ... never on the `::` entry rule" / "normal shape of every
  `.spec`" lines in `what-is-linkedspec.md`, `worked-spec-walkthrough.md`, `helper-contract-catalog.md`.
  Documented the new model: `spec-files-and-rule-paragraphs.md` gained the canonical "the top (`::`) rule is
  an ordinary rule, entered first" section (entry marker; modes/regex/recursion legal; idiom vs law; the
  `entry_*` vs `match_*` rule; the consume-before-recurse termination rule; the recursive-top-rule-needs-`LX`
  model with a verified `sexpr::`+`LX` example); `formal-grammar.md` §2.1 (entry-marker note) + new **§5.4
  Recursion and Forward-Progress Termination** (a backend MUST cut a non-progressing recursive re-entry to
  `undef` — confirmed cross-variant by the `.3.1` Rust mirror). **De-footgunned** the `Pair::AND`
  regex-on-top example in `rule-modes-and-parse-modes.md`: it read `entry_text()` (null on a top rule, which
  has no entering match) → fixed to a post-match edge action + `match_group(0)`, folding the bare `\s*=\s*`
  separator into the name slot (`{name:"name",value:"value"}`). **Fixed a correctness bug** in
  `worked-spec-walkthrough.md`: the multi-pair `'a = 1, b = 2'` two-pair output is a **`seek`** result that
  was presented in the `consume` context (under `consume` only the first pair matches) — reframed as the
  consume-vs-seek distinction. Every runnable example **verified via `LinkedSpec::Get`** (dump-don't-transcribe,
  scratchpad `verify4*.pl`); `mdbook build` EXIT 0 (cross-ref anchor verified from generated HTML); book stays
  variant-agnostic. Locked the de-footgun with phase0 `top_rule_as_normal_regex_on_top_reads_own_match_with_match_family`
  (**964→965 green**); wrote KM card [[top-rule-reads-own-match-with-match-family]] (regenerated the derived
  map). Discovered (tracked, out of scope): a bare edge-less `AND` middle slot is a positional anchor that is
  not separately consumed — affects only illustrative no-output sketches. `bash tools/run_ci_local.sh` EXIT 0;
  doctrine driver 2/2 PASS. Marked `.4` `done`; tree stays `active` only because `.3.2` is `blocked` on
  `RUST-PARITY` (frontier otherwise empty).
- `2026-06-23` (`.3.1`): **SPLIT `.3` → `.3.1` + `.3.2`; landed `.3.1` (Rust termination parity).** A
  reproduce-first Rust diagnosis (the four Perl phase0 top-rule grammars driven through
  `parse_spec`→`validate`→`compile`→`Engine::execute`) showed the cross-variant gap has **two independent
  layers**: (a) **termination** — the no-consume grammar `top:: /a/ I{return(call(top))}` makes the Rust
  engine recurse natively through `Engine::execute_rule` (the `call(rule)` helper) with NO forward-progress
  guard → **stack overflow → SIGABRT**, while Perl returns `undef`; and (b) **value** — the Rust engine
  returns nulls for ALL the recursive S-expression cases, *including the standard body-recursion idiom*
  (`top:: -> sexpr` wrapper) → `[[null],[null]]`, so the value gap is the **general recursive-grammar parse
  gap** (atoms/`entry_text()` in nested dispatch, multi-slot `-> rule[1]` self-entry, accumulator), NOT a
  top-rule-as-ordinary issue — the Rust corpus harness already documents recursive specs (Lispish) as
  deferred under `RUST-PARITY` (`tests/corpus_oracle.rs`). Layer (a) is the genuinely top-rule-specific
  obligation and is cleanly ownable; layer (b) is `RUST-PARITY` territory. **`.3.1`** added the Rust mirror of
  the `.2.1` `(rule,pos)` cutoff: a `recursion_active: HashSet<(String,usize)>` on `RuntimeContext`
  (`enter_recursion`/`exit_recursion`) + a thin `Engine::execute_rule` guard wrapper around the renamed
  `execute_rule_inner` (re-entry at a `(label,pos)` already active ⇒ return `undef`; inserted on entry /
  removed on both the Ok and Err exit paths). A no-consume cycle now terminates cleanly and returns `[null]`
  (= Perl's `undef` wrapped one level by the documented Perl↔Rust accumulator output-shape rule); legitimate
  consume-before-recurse recursion (which advances `ctx.pos` first) is untouched. +2 integration locks; Rust
  suite **242→244 green**; **phase0 964/964** + `bash tools/run_ci_local.sh` **EXIT 0** (Perl unchanged).
  KM card [[top-rule-recursion-forward-progress-guard]] updated with the Rust parity. **`.3.2`** records the
  diagnosed value gap and is `blocked` on `RUST-PARITY` recursive-grammar parity. Book reconciliation stays
  owned by `.4`. Marked `.3` `active` (container), `.3.1` `done`, `.3.2` `blocked`.
- `2026-06-23` (`.2.2`): **CONFIRMED no engine defect — `.2` complete; engine stays frozen.** `probe9.pl`
  (dump-don't-transcribe) showed a recursive rule used AS the top rule parses correctly with an `LX`
  accumulator-return: `(a)`→`[["a"]]`, `(a(b)c)`→`[["a",["b"],"c"]]`, `(a) (b)`→`[["a"],["b"]]`. The `(a) (b)`
  case is decisive — the TOP form accumulates the **sequence** of top-level forms while the BODY wrapper returns
  a **single** form (`["a"]`); they are intentionally different grammars (different arity), not an engine bug.
  The original `null` was the **missing-`LX` authoring case** (a bare accumulating top rule returns `undef` at
  EOF — the documented `top:: -> x .push` + `LX{...}` idiom applies to recursive top rules too). So ADR `0010`'s
  goal (top rule = ordinary rule, incl. recursion) is **met by the engine**; the authorized engine change was
  NOT needed for the value (only `.2.1`'s termination guard was). Outcome: a DOC + LOCK slice — added the phase0
  lock `top_rule_as_normal_recursion_with_lx_parses_sequence` (963→964 green; full gate EXIT 0); the
  recursive-top-rule-needs-`LX` book documentation is deferred to `.4`. Marked `.2` and `.2.2` `done`. No
  engine/spec change. Updated KM card [[top-rule-recursion-forward-progress-guard]] with the resolution.
- `2026-06-23` (`.2.1`): Split `.2` → `.2.1` (done) + `.2.2` (pending). Implemented the forward-progress /
  consume-before-recurse termination guard as a precise **(rule, pos) active-stack non-progress cutoff** in
  the single `SpecEntry::_build_runtime_handler` runtime-handler closure (the seam every cross-rule call +
  recursion flows through — confirmed via `call_spec_handler_subst`/`Contracts.pm:134`/`MethodLowering.pm:332`,
  NOT the simplified `dump_parser_source` artifact). Ground-truth via TOOLBOX: the per-handler `while(1)` +
  `LinkedRE::or` `/gc` matching is already forward-progress-safe (no zero-width grammar hangs); the only
  reproduced engine hang was an unconditional no-consume self-tail-call (`top:: /a/ I{return(call(top))}`),
  now cut to `undef`. Added 3 phase0 locks (no-consume-terminates, body-recursion-parses, top-recursion-
  terminates); **960→963 green; `tools/run_ci_local.sh` EXIT 0; zero regression.** KM card
  [[top-rule-recursion-forward-progress-guard]]. **Discovered `.2.2`:** a recursive rule used AS the top rule
  returns `null` while the identical body rule parses (`(a(b)c)`→`["a",["b"],"c"]`) — an entry-alignment
  divergence; the value-correctness is owned by `.2.2` (the `.2.1` top-recursion lock pins termination only).
- `2026-06-23`: Created. The user escalated the `PHASE0-BACKHALF-TRIAGE.6` book `:AND` reconciliation into
  an engine change: treat the top rule as an ordinary rule (entered first) w.r.t. regex + recursion, and
  **authorized touching the Perl variant**. Wrote ADR `0010` (design decision + sanctioned engine-frozen
  exception + cross-variant-parity obligation). Did the read-only investigation (`.1`): the regex/codegen
  dimension is already uniform (top rule is just `&{$descr->{spec}{$top_rule}}(...)`; `while(1)` is
  mode-driven; `Pair::AND`+regex emits a normal AND handler), so the actionable work is top-rule **re-entry
  recursion** + a **forward-progress termination guard**, then cross-variant parity, then the book reframe.
  `PHASE0-BACKHALF-TRIAGE.6` is superseded into `.4`. Engine implementation (`.2`) recommended for a fresh,
  sharp session (signoff-critical codegen).
