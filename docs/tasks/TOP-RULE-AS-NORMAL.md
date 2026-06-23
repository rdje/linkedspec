# TOP-RULE-AS-NORMAL: treat the top rule as an ordinary rule (entered first) w.r.t. regex + recursion

## Metadata

- Tree ID: `TOP-RULE-AS-NORMAL`
- Status: `active` (created 2026-06-23)
- Roadmap lane: `Overall roadmap — .spec language model / engine evolution`
- Created: `2026-06-23`
- Last updated: `2026-06-23` (`.2` DONE — `.2.1` termination guard in `perl/LinkedSpec/SpecEntry.pm` + `.2.2`
  CONFIRMED no engine defect (top re-entry recursion already works with the `LX` accumulator idiom; the `null`
  was the missing-`LX` authoring case; engine stays frozen). phase0 960→964 green, full local gate EXIT 0.
  Frontier → `.3` (cross-variant parity, Rust) → `.4` (book reconciliation incl. recursive-top-rule-needs-`LX`).)
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

- ID: `TOP-RULE-AS-NORMAL` · Status: `active` · Children: `.1` (done), `.2`, `.3`, `.4`
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
- ID: `TOP-RULE-AS-NORMAL.3` · Status: `pending`
  Goal: Cross-variant parity — mirror the behavior in the Rust variant (and track for Julia/Dart); the new
    phase0 locks (or their cross-variant equivalents) produce identical output. Perl is the reference.
  Acceptance: Rust variant matches Perl on the new top-rule locks; parity evidence recorded.
  Verification: `pending`  ·  Commit: `pending`
- ID: `TOP-RULE-AS-NORMAL.4` · Status: `pending` (absorbs the superseded `PHASE0-BACKHALF-TRIAGE.6` book work)
  Goal: Book reconciliation to the new model — demote "Body rule only" / "no regex on top" from law to
    **idiom**; document `::` as "the rule entered first, otherwise ordinary"; document the
    consume-before-recurse termination rule; de-footgun the book's own `Pair::AND` regex-on-top teaching
    examples. Files: `appendix/formal-grammar.md`, `user-model/rule-modes-and-parse-modes.md`,
    `overview/what-is-linkedspec.md`, `worked-spec-walkthrough.md`,
    `user-model/spec-files-and-rule-paragraphs.md`.
  Acceptance: no book `.spec` example broken/doctrine-contradictory; law-vs-idiom explicit; termination
    rule documented; `mdbook build` EXIT 0; outputs verified via `LinkedSpec::Get`; book variant-agnostic.
  Verification: `pending`  ·  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | `.1` | `done` 2026-06-23 | Read-only investigation complete: regex/codegen already uniform; open gap = top re-entry recursion + termination. ADR `0010`. |
| — | `.2.1` | `done` 2026-06-23 | Forward-progress / consume-before-recurse termination guard (one-site (rule,pos) cutoff in `SpecEntry.pm`) + 3 phase0 locks; 960→963 green, full gate EXIT 0. |
| — | `.2.2` | `done` 2026-06-23 | Top re-entry recursion VALUE correctness — CONFIRMED no engine defect: the top-recursive grammar parses with the `LX` accumulator idiom (`null` was the missing-`LX` authoring case); TOP vs BODY are different grammars (different arity). Doc+lock, engine frozen. +1 phase0 lock; 963→964. |
| 1 | `.3` | `pending` | Cross-variant parity (Rust; track Julia/Dart) for `.2.1`'s termination guard + the top-recursion-with-`LX` behavior. After `.2`. |
| 2 | `.4` | `pending` | Book reconciliation to the new model (absorbs `PHASE0-BACKHALF-TRIAGE.6`); document the termination guarantee + that a recursive rule CAN be the top rule and (like any accumulating top rule) needs an `LX` accumulator-return. |

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

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.1` | `TOP-RULE-AS-NORMAL.1 — own the lane + read-only investigation; ADR 0010 (authorize engine change)` | this commit (DOC-ONLY; engine untouched) |
| `.2.1` | `TOP-RULE-AS-NORMAL.2.1 — forward-progress/consume-before-recurse termination guard (SpecEntry runtime-handler closure) + 3 phase0 locks; split .2; discover .2.2 top-recursion value gap` | `c2814da` (engine: 1 file, `perl/LinkedSpec/SpecEntry.pm`; +3 phase0 locks; ADR 0010) |
| `.2.2` | `TOP-RULE-AS-NORMAL.2.2 — confirm top re-entry recursion works with the LX accumulator idiom (NO engine defect; engine frozen); +1 phase0 lock; close .2` | this commit (TEST+DOC only; +1 phase0 lock; no engine/spec change) |

## Changelog

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
