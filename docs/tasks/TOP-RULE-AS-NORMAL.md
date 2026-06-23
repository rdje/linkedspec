# TOP-RULE-AS-NORMAL: treat the top rule as an ordinary rule (entered first) w.r.t. regex + recursion

## Metadata

- Tree ID: `TOP-RULE-AS-NORMAL`
- Status: `active` (created 2026-06-23)
- Roadmap lane: `Overall roadmap — .spec language model / engine evolution`
- Created: `2026-06-23`
- Last updated: `2026-06-23` (`.2.1` DONE — forward-progress/consume-before-recurse termination guard landed
  in `perl/LinkedSpec/SpecEntry.pm` (one-site (rule,pos) cutoff) + 3 phase0 locks; 960→963 green, full local
  gate EXIT 0. `.2` split into `.2.1` (done) + `.2.2` (top re-entry VALUE correctness, discovered during
  `.2.1`). Frontier → `.2.2` → `.3` → `.4`.)
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
- ID: `TOP-RULE-AS-NORMAL.2` · Status: `active` (split 2026-06-23 into `.2.1` done + `.2.2` pending)
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
- ID: `TOP-RULE-AS-NORMAL.2.2` · Status: `pending` (discovered during `.2.1`; engine — ADR `0010` authorized)
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
  Acceptance: top-recursive grammar parses identically to its body-recursive equivalent; phase0 green + the
    tightened lock; `perl -c` clean; `bash tools/run_ci_local.sh` EXIT 0; verified via TOOLBOX.
  Verification: `pending`  ·  Commit: `pending`
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
| 1 | `.2.2` | `pending` | Top re-entry recursion **VALUE correctness** (top-recursive returns `null` vs body-recursive parses — entry-alignment divergence discovered during `.2.1`). Root-cause then minimal engine change. |
| 2 | `.3` | `pending` | Cross-variant parity (Rust; track Julia/Dart). After `.2.2`. |
| 3 | `.4` | `pending` | Book reconciliation to the new model (absorbs `PHASE0-BACKHALF-TRIAGE.6`); document the termination guarantee + the recursive-document idiom. After `.2.2` lands the value behavior. |

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
- `.2.2`: what is the minimal engine change that makes a top-recursive entry rule consume/align its leading
  token like the body form, without regressing the shipped specs?

## Blockers

- None. ADR `0010` clears the engine-frozen blocker for this specific change. `.2` is the next executable
  leaf; recommended in a fresh session for signoff-quality codegen work.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-23` | `.1` | TOOLBOX read-only probes (`LinkedSpec::Get`, `generate_only`+`dump_parser_source`, codegen grep of `Compiler.pm`/`HandlerVariantEmitter.pm`/`SpecEntry.pm`); `Pair::AND` emitted-source dump; `specs/Lispish.spec` recursion inspection | `done` — top rule is just a handler call; `while(1)` is mode-driven; regex-on-top already compiles normally; open gap = top re-entry recursion + termination. No code changed. |
| `2026-06-23` | `.2.1` | TOOLBOX probes (`call_spec_handler_subst` re-entry seam, `dump_parser_source`, fork+SIGKILL hang census across zero-width/recursive grammars); `perl -c` SpecEntry.pm+LinkedSpec.pm+test; full `perl -Iperl t/phase0_regression.t`; `bash tools/run_ci_local.sh` | `done` — engine guard added to `SpecEntry.pm`; E4 no-consume hang→`null`; consume-recursion unchanged; **phase0 960→963** (3 new locks, 0 regression); full local gate **EXIT 0** ("Result: PASS"). Discovered the `.2.2` top-recursion value gap. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.1` | `TOP-RULE-AS-NORMAL.1 — own the lane + read-only investigation; ADR 0010 (authorize engine change)` | this commit (DOC-ONLY; engine untouched) |
| `.2.1` | `TOP-RULE-AS-NORMAL.2.1 — forward-progress/consume-before-recurse termination guard (SpecEntry runtime-handler closure) + 3 phase0 locks; split .2; discover .2.2 top-recursion value gap` | this commit (engine: 1 file, `perl/LinkedSpec/SpecEntry.pm`; +3 phase0 locks; ADR 0010) |

## Changelog

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
