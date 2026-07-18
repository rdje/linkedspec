# 0010 — The top rule is an ordinary rule that is merely entered first; authorize making Perl handle it uniformly w.r.t. regex + recursion

- Date: 2026-06-23
- Status: accepted; root-selection precedence and marker-required validity superseded by ADR `0046`
- Tags: engine, parser, dsl, language-model, top-rule, recursion, doctrine-exception, cross-variant-parity

## Context

Before this decision, the mdBook taught in several places that a `::` top rule **cannot carry a regex** and that
the `:AND`/`:OR`/… rule modes are **"Body rule only"** (`appendix/formal-grammar.md` mode table;
`overview/what-is-linkedspec.md:45`; `worked-spec-walkthrough.md:119-124`). The recorded authoring
doctrine ([[spec-top-rule-no-regex-two-rule-minimum]] / [[feedback_spec-structure-top-plus-normal]])
said the same: a valid `.spec` is a top `::` dispatch rule with **no** regex plus ≥1 normal `:` rule
that carries the regex. This June 17 no-regex doctrine is superseded by this decision.

That is contradicted by the engine. A read-only investigation (2026-06-23, TOOLBOX probes —
`LinkedSpec::Get`, `generate_only` + `dump_parser_source`, plus a grep of the codegen path)
established the real model:

- **The top rule is not specially wrapped.** The generated entry point is literally
  `sub Get { &{$descr->{spec}{$top_rule}}($descr, $_[0]) }` (`perl/LinkedSpec/Compiler.pm:1006`) —
  just an invocation of the top rule's handler, exactly like any other rule.
- **`while(1)` is mode-driven, not top-driven.** The streaming loop lives in
  `perl/LinkedSpec/HandlerVariantEmitter.pm` and belongs to the *default / repeated-choice / REP*
  rule modes; `:AND` emits a single ordered pass. The "top rule is a `while(1)` dispatch loop"
  behavior is therefore an emergent property of writing the top rule in default mode with dispatch
  edges + an `LX` accumulator — **an idiom, not a language law.**
- **Regex on the top rule already compiles as a normal rule.** `Pair::AND` carrying regex slots +
  a `return` edge emits a standard AND handler (`while ($idx < 2) { LinkedRE::or(...) … }`) and runs;
  the earlier breakage was the AND-codegen defect already fixed under ADR `0008` /
  `PHASE0-BACKHALF-TRIAGE.3`.
- **The genuinely open dimension is recursion *into* the top rule + termination.** The shipped
  recursive specs recurse on a **body** rule with consume-before-recurse (`specs/Lispish.spec`:
  `parenthesis: /\(/ … -> parenthesis … /\)/`) and are green. Naive grammars that recurse back into
  the top rule (or use zero-progress blind-call dispatch) **hang** — consistent with the recently
  fixed Lispish corpus non-termination (`PHASE0-BACKHALF-TRIAGE.5.2`, a never-`undef` parser spinning
  a `while(1)` loop).

The user reframed the design accordingly: **the top rule should be treated as any other rule, the
only difference being that it is the one entered first — which is exactly why it is marked `::`.**
The no-regex dispatch loop is an idiom; recursion through/into the top rule should be allowed, with
the standard termination requirement that every recursive cycle consume input.

Restated narrowly: `::` is the entry marker. After entry selection, `::` and `:` rules have the same
regex, mode, edge, lifecycle, and recursion feature surface.

## Decision

1. **Adopt the model.** `::` is the **entry marker** ("the rule entered first"); the top rule is
   otherwise an **ordinary rule**. "No regex on top" and "`:AND`/… are Body-rule-only" are recorded
   as the recommended **idiom/style**, **not** as engine laws. This makes the start symbol able to be
   a recursive grammar node directly (a single recursive *document*), instead of being forced through
   a streaming stream-of-records dispatcher. (It does not change the grammar class — recursive descent
   remains recursive descent; the gain is ergonomic/conceptual.)

2. **Authorize touching the Perl reference engine** to make top-rule handling **uniform with normal
   rules w.r.t. regex and recursion (re-entry)**, guarded by a **consume-before-recurse / forward-progress**
   termination rule. This is a **sanctioned, scoped exception** to the engine-frozen doctrine
   ([[feedback_do-not-fix-reference-engine]]), in the same spirit as ADR `0008`. The regex/codegen
   dimension is already uniform; the actionable engine work is to confirm the full
   {top}×{mode}×{regex}×{recursion} matrix, enable/verify top re-entry, and add termination safety,
   each locked by `t/phase0_regression.t`.

3. **Cross-variant parity is required.** Perl is the reference, but the `.spec` file is the one
   universal contract ([[spec-contract-is-unique]], [[cross-variant-output-parity]]); the same `.spec`
   must behave identically in the Rust (and future Dart/Julia/Lua) variants. The change is mirrored to /
   tracked for the other variants — it does not land as a Perl-only divergence.

4. **Ownership.** The work is owned by the new active task tree `TOP-RULE-AS-NORMAL`
   (`docs/tasks/TOP-RULE-AS-NORMAL.md`). The book reconciliation that was scoped as
   `PHASE0-BACKHALF-TRIAGE.6` is **superseded** into that tree (it now documents the new engine
   behavior, not a contradiction).

## Consequences

- The book's "Body rule only" / "no regex on top" statements become **historical drift or idiom
  guidance**, reframed (not deleted where the example style remains useful) so they no longer read as
  engine constraints or validity doctrine. The consume-before-recurse termination rule is documented.
  The 2-rule no-regex top wrapper is preserved only as a stream-parser style.
- `t/phase0_regression.t` must stay **960/960 green**; every newly-confirmed or newly-enabled behavior
  (regex-on-top across modes, top re-entry recursion, termination) gets an explicit regression lock.
- The reference engine is otherwise still frozen; this ADR is the named exception for this specific
  change, exactly as `0008` was for the two codegen/runtime defects.
- Execution cadence: the read-only investigation is done (findings recorded in `TOP-RULE-AS-NORMAL.1`);
  the engine implementation (`.2`) is a discrete, signoff-critical codegen slice and should be done in a
  sharp/fresh session, followed by cross-variant parity (`.3`) and the book reconciliation (`.4`).

## Links

- Owning tree: `docs/tasks/TOP-RULE-AS-NORMAL.md`
- Superseded by this direction: `docs/tasks/PHASE0-BACKHALF-TRIAGE.md` leaf `.6` (book `:AND` reconciliation)
- Precedent for a sanctioned engine-frozen exception: [0008](0008-authorize-reference-engine-defect-fixes.md)
- Universal-contract / parity doctrine: [0006](0006-multi-backend-vision.md), [[spec-contract-is-unique]], [[cross-variant-output-parity]]
- Knowledge: [[top-rule-is-ordinary-rule-entered-first]], [[spec-top-rule-no-regex-two-rule-minimum]], [[lispish-corpus-catastrophic-backtracking]]

## Supersession note (2026-07-18)

ADR `0046` supersedes this record only for entry-rule selection precedence and the requirement that a valid spec
contain a `::` marker. This record remains authoritative for the selected rule being an ordinary rule, uniform
regex/mode behavior, recursion, and forward-progress termination.
