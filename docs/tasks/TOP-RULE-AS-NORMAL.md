# TOP-RULE-AS-NORMAL: treat the top rule as an ordinary rule (entered first) w.r.t. regex + recursion

## Metadata

- Tree ID: `TOP-RULE-AS-NORMAL`
- Status: `active` (created 2026-06-23)
- Roadmap lane: `Overall roadmap — .spec language model / engine evolution`
- Created: `2026-06-23`
- Last updated: `2026-06-23` (`.1` read-only investigation DONE — the regex/codegen dimension is already
  uniform; the open work is top-rule re-entry recursion + termination. ADR `0010` records the design
  decision + the engine-touch authorization. `.2`–`.4` pending.)
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
- ID: `TOP-RULE-AS-NORMAL.2` · Status: `pending` (engine — ADR `0010` authorized; recommend a fresh session)
  Goal: Perl reference engine — confirm the full {top}×{mode}×{regex}×{recursion} matrix; enable/verify
    **recursion back into the top rule** behaves identically to a body rule; add a **forward-progress /
    consume-before-recurse** guard so a no-consume recursive cycle cannot hang. Lock every confirmed/new
    behavior with `t/phase0_regression.t` subtests.
  Acceptance: the matrix is green; top re-entry recursion parses + terminates; phase0 960/960 + new locks;
    no regression; `perl -c` clean; `bash tools/run_ci_local.sh` EXIT 0. Behavior + emitted source verified
    via TOOLBOX (`dump_parser_source`, `return_descriptor`).
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
| 1 | `.2` | `pending` | Perl engine: confirm matrix + enable top re-entry recursion + forward-progress guard + phase0 locks. **Signoff-critical codegen — recommend a fresh session.** |
| 2 | `.3` | `pending` | Cross-variant parity (Rust; track Julia/Dart). After `.2`. |
| 3 | `.4` | `pending` | Book reconciliation to the new model (absorbs `PHASE0-BACKHALF-TRIAGE.6`). After `.2` lands the real behavior to document. |

## Decisions

- `2026-06-23` (user, via AskUserQuestion + follow-ups): the top rule is an ordinary rule merely entered
  first; the no-regex dispatch loop is an idiom, not a law; recursion into/through the top rule is allowed
  with a consume-before-recurse termination rule. The user then **authorized touching the Perl variant**
  to implement it. Recorded in ADR `0010` (sanctioned engine-frozen exception, like `0008`).
- `2026-06-23`: scope correction from the `.1` investigation — the regex/codegen dimension is **already
  uniform** (`.3` AND-codegen fix), so the actionable engine work is narrower than it first appeared:
  top-rule re-entry recursion + a forward-progress guard, then parity + docs.

## Open Questions

- Exactly where does top re-entry diverge from body-rule recursion (codegen, the `LinkedRE::or` dispatch,
  or the blind-call/zero-progress path)? `.2`'s first step pins this with `dump_parser_source` on a correct
  consume-before-recurse top-recursive grammar (vs the shipped `Lispish` body-recursive pattern).
- Should the forward-progress guard be global (every recursive handler) or scoped to top re-entry? Decide
  in `.2` from the matrix; keep it minimal and regression-locked.

## Blockers

- None. ADR `0010` clears the engine-frozen blocker for this specific change. `.2` is the next executable
  leaf; recommended in a fresh session for signoff-quality codegen work.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-23` | `.1` | TOOLBOX read-only probes (`LinkedSpec::Get`, `generate_only`+`dump_parser_source`, codegen grep of `Compiler.pm`/`HandlerVariantEmitter.pm`/`SpecEntry.pm`); `Pair::AND` emitted-source dump; `specs/Lispish.spec` recursion inspection | `done` — top rule is just a handler call; `while(1)` is mode-driven; regex-on-top already compiles normally; open gap = top re-entry recursion + termination. No code changed. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.1` | `TOP-RULE-AS-NORMAL.1 — own the lane + read-only investigation; ADR 0010 (authorize engine change)` | this commit (DOC-ONLY; engine untouched) |

## Changelog

- `2026-06-23`: Created. The user escalated the `PHASE0-BACKHALF-TRIAGE.6` book `:AND` reconciliation into
  an engine change: treat the top rule as an ordinary rule (entered first) w.r.t. regex + recursion, and
  **authorized touching the Perl variant**. Wrote ADR `0010` (design decision + sanctioned engine-frozen
  exception + cross-variant-parity obligation). Did the read-only investigation (`.1`): the regex/codegen
  dimension is already uniform (top rule is just `&{$descr->{spec}{$top_rule}}(...)`; `while(1)` is
  mode-driven; `Pair::AND`+regex emits a normal AND handler), so the actionable work is top-rule **re-entry
  recursion** + a **forward-progress termination guard**, then cross-variant parity, then the book reframe.
  `PHASE0-BACKHALF-TRIAGE.6` is superseded into `.4`. Engine implementation (`.2`) recommended for a fresh,
  sharp session (signoff-critical codegen).
