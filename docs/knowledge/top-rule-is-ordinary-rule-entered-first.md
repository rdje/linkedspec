---
id: top-rule-is-ordinary-rule-entered-first
title: "A selected top rule is ordinary; root selection now follows explicit selector, authored `::`, then first authored `:` precedence."
answers:
  - "is the top (::) rule special-cased in the engine vs a normal (:) rule"
  - "what does :: actually do mechanically (entry marker vs dispatch loop)"
  - "where does the while(1) streaming loop come from (top rule or rule mode)"
  - "can a top rule carry a regex and does it work"
  - "can a :: rule carry a regex"
  - "do :: and : have the same rule features"
  - "what does the :: vs : colon mean for a rule"
  - "how is the top-level rule handled in the engine"
  - "should the top-level rule carry a regex"
  - "does regex on the top rule compile differently from a body rule"
  - "is 'no regex on the top rule' an engine law or an idiom"
  - "how does recursion into / re-entry of the top rule behave"
  - "why does naive top-rule recursion hang (termination / forward progress)"
  - "what did ADR 0010 decide about the top rule"
  - "what is the root rule selection precedence"
  - "does --top-rule override Rule::"
  - "what is the default root rule when there is no double colon rule"
date: 2026-06-23
status: confirmed runtime mechanics; ADR 0046 admitted on Perl, Rust, and Dart with Julia core implemented
tags: [engine, parser, top-rule, codegen, recursion, language-model, TOP-RULE-AS-NORMAL, ADR-0010, ADR-0046]
evidence: "Read-only TOOLBOX investigation 2026-06-23 (TOP-RULE-AS-NORMAL.1). (1) Entry point is just `sub Get { &{$descr->{spec}{$top_rule}}($descr,$_[0]) }` (Compiler.pm:1006) -- the top rule is NOT specially wrapped; it is invoked like any handler. (2) The while(1) loops live in HandlerVariantEmitter.pm and are MODE-driven (default/repeated-choice/REP repeat; :AND is a single ordered pass) -- the 'top = while(1) dispatch loop' behavior is an emergent idiom (default-mode top + dispatch edges + LX accumulator), not a property of `::`. (3) Regex on a top rule already compiles as a normal rule: `generate_only`+`dump_parser_source` on `Pair::AND` + regex slots emits a standard AND handler (`while ($idx < 2) { LinkedRE::or(...) ... }`) -- identical to a body rule; the earlier breakage was the AND-codegen defect already fixed under ADR 0008 / PHASE0-BACKHALF-TRIAGE.3. (4) Idiomatic recursion is body-rule + consume-before-recurse (specs/Lispish.spec: `parenthesis: /\\(/ ... -> parenthesis ... /\\)/`, green). Naive grammars recursing BACK INTO the top rule, or using zero-progress blind-call dispatch, HANG -- the genuinely open dimension (same family as the PHASE0-BACKHALF-TRIAGE.5.2 never-undef/while(1) non-termination). Design decision + engine-touch authorization recorded in ADR 0010."
evidence_update_2026_07_08: "SPEC-LANG-REFERENCE.8 reverified the current doctrine after a stale June 17 no-regex correction resurfaced. In a single spec defining both `Entry:: /foo/ -> Entry { return(match_text()) }` and `Body: /foo/ -> Body { return(match_text()) }`, selecting `top_rule=>Entry` and `top_rule=>Body` both returns `\"foo\"`; similarly, `Entry::AND` and selected `Body:AND` with equivalent regex slots both return `{name:\"name\",value:\"value\"}`. The remaining structural requirement is an entry marker in the spec so there is a default start rule; it is not a ban on regex-bearing `::` rule bodies."
decision_update_2026_07_18: "The director superseded the final structural-requirement sentence above. Exact intended precedence is: an explicit selector, including CLI `--top-rule NAME`, wins over authored markers and may name any declared rule; otherwise the first authored `Rule::` is the default; if no rule uses `::`, the first authored ordinary `Rule:` is the default. Read-only retrieval found marker-then-first fallback code in Dart runtime/source emission, but Dart/Rust/Julia/Lua validators still reject no-marker specs and current neutral docs still require `::`. `FUTURE-PARITY-BACKLOG.9.1.1.2` owns neutral ratification and five-backend rollout; do not report the fallback as implemented everywhere until that tree closes."
decision_ratification_2026_07_18: "ADR 0046 and `linkedspec-root-rule-selection-v1` now accept the exact selection order without backend behavior changes. The audit additionally found current Perl selects parsed row zero even before a later marker; Rust requires a marker and lacks fallback; Dart/Julia/Lua have unreachable fallback behind validation. Authored `is_top` remains source identity, selection is execution state, and strict-unused receives no reference or exemption from either selection or marker. Rollout is 1 complete / 6 pending."
implementation_update_2026_07_18: "FUTURE-PARITY-BACKLOG.9.1.1.2.1.1-.3 implement and admit the complete Perl reference at 65/65 shared primary cases in both option environments. Native, loaded, generated, descriptor, diagnostic, trace, strict, and primary routes apply explicit selector > first marker > first rule without rewriting authored `is_top`. The rollout ledger is 2 complete / 5 pending; Rust, Dart, Julia, Lua, and final admission remain ordered under `.2-.6`."
rust_admission_update_2026_07_18: "FUTURE-PARITY-BACKLOG.9.1.1.2.2.1-.3 implement and admit complete Rust parity through one topology-checked 15-role consumer and exact 65/65 primary cases in both option environments. The rollout ledger is 3 complete / 4 pending; Dart, Julia, Lua, and final admission remain ordered under `.3-.6`."
dart_core_update_2026_07_18: "FUTURE-PARITY-BACKLOG.9.1.1.2.3.1 implements the same precedence in one Dart compiled-state resolver, accepts markerless one-or-more-rule sources, returns portable zero/unknown failures before user code, and preserves descriptor marker identity. Dart composed routes and admission remain `.3.2-.3`; rollout therefore remains 3/7."
dart_routes_update_2026_07_18: "FUTURE-PARITY-BACKLOG.9.1.1.2.3.2 proves Dart loaded/normalized and generated/emitted direct/traced routes reuse that resolver, trace requested/effective/basis, preserve portable failures and generated v2 identity, and reject stale contracts before selection. Topology admission `.3.3` remains pending, so rollout stays 3/7."
dart_admission_update_2026_07_18: "FUTURE-PARITY-BACKLOG.9.1.1.2.3.3 admits Dart through one topology-checked 15-role consumer and exact package 270 / primary 65x2 / corpus 105 proof. Root-selection rollout is now 4 complete / 3 pending; Julia, Lua/LuaJIT, and final no-drift remain."
julia_core_update_2026_07_18: "FUTURE-PARITY-BACKLOG.9.1.1.2.4.1 implements marker-optional Julia core selection through one compiled-state resolver before user code, portable zero/unknown failures, strict authored-edge no-drift, and immutable descriptor root identity. Shared primary is exactly 32/65 twice with only the 33 cursor failures remaining; composed routes/admission stay pending, so rollout remains 4/7."
reverify: "perl -Iperl -e 'use LinkedSpec; my %c; my $s=\"Pair::AND\\n /a/\\n /b/\\n\"; LinkedSpec::Get(\\$s, generate_only=>1, dump_parser_source=>1, runtime_ctx_ref=>\\%c); print ${$c{parser_source_chunks_ref}};'  # emits a standard `Pair => sub { ... while ($idx < 2) { LinkedRE::or(...) } ... }` AND handler -- a top rule compiled exactly like a body rule"
---

# Engine mechanics: the top (`::`) rule is an ordinary rule entered first

**Current doctrine adopted 2026-06-23** (read-only investigation `TOP-RULE-AS-NORMAL.1`;
design decision ADR [0010](../decisions/0010-top-rule-is-ordinary-rule-entered-first.md)).
This supersedes the earlier June 17 "no regex on top / two-rule minimum" validity doctrine.

## What the engine actually does

- **`::` is an entry marker, not a special construct.** The generated parser's entry point is just
  `sub Get { &{$descr->{spec}{$top_rule}}($descr, $_[0]) }` (`Compiler.pm:1006`) — it invokes the top
  rule's handler exactly like any other rule's handler. There is **no** top-specific wrapper.
- **The `while(1)` streaming loop is mode-driven, not top-driven.** It lives in
  `HandlerVariantEmitter.pm` and belongs to the *default / repeated-choice / REP* rule modes; `:AND`
  emits a single ordered pass. The familiar "top rule is a `while(1)` dispatch loop" is an **emergent
  idiom** — a default-mode top rule with dispatch edges + an `LX` accumulator — **not** a property of
  `::`.
- **A regex on the top rule compiles as a normal rule.** `Pair::AND` with regex slots emits a
  standard AND handler (`while ($idx < 2) { LinkedRE::or(...) ... }`), identical to a body rule. The old
  breakage was the AND-codegen defect, **fixed** under ADR `0008` / `PHASE0-BACKHALF-TRIAGE.3`.
- **The feature surface is shared.** After a rule is selected as the parser entry point, a `::` rule
  can use the same regex slots, rule modes, action/blind-call edges, lifecycle blocks, and recursion
  model as a `:` rule. The only semantic distinction is entry selection: `::` marks the rule entered
  first by the authored-marker default. The accepted 2026-07-18 direction adds two surrounding selection rules:
  an explicit selector has higher priority than the marker, while the first authored ordinary rule is the fallback
  when no marker exists. Perl, Rust, and Dart implement and admit that exact order. Julia, Lua, and final five-
  backend admission remain tracked under
  `FUTURE-PARITY-BACKLOG.9.1.1.2.4-.6`.

## The idiom vs the law (ADR 0010)

"No regex on the top rule" and "`:AND`/`:OR`/... are Body-rule-only" are **not** current doctrine.
The old no-regex card is now a superseded historical redirect
([[spec-top-rule-no-regex-two-rule-minimum]]). The current doctrine is simpler: the top rule is an
ordinary rule merely **entered first**. A no-regex dispatch-loop wrapper remains a clean idiom for a
**stream of records**; a **single recursive document** can be expressed with a recursive top rule
directly.

## The open dimension: recursion into the top rule + termination

Idiomatic recursion is **body-rule + consume-before-recurse** (`specs/Lispish.spec`:
`parenthesis: /\(/ … -> parenthesis … /\)/`) and is green. Naive grammars that recurse **back into the
top rule**, or use a zero-progress blind-call dispatch, **hang** — the same non-termination family as
[[lispish-corpus-catastrophic-backtracking]] (`PHASE0-BACKHALF-TRIAGE.5.2`: a never-`undef` parser
spinning a `while(1)` loop). Making top re-entry work uniformly + adding a **forward-progress /
consume-before-recurse** guard is the actionable engine work (`TOP-RULE-AS-NORMAL.2`), authorized by
ADR `0010` as a scoped exception to the engine-frozen doctrine, with cross-variant parity required.

## Links

- Decision: [0010](../decisions/0010-top-rule-is-ordinary-rule-entered-first.md); precedent [0008](../decisions/0008-authorize-reference-engine-defect-fixes.md)
- Tree: [[TOP-RULE-AS-NORMAL]] (`.1` investigation done; `.2` engine impl; `.3` parity; `.4` book)
- Files: `perl/LinkedSpec/Compiler.pm:1006`, `perl/LinkedSpec/HandlerVariantEmitter.pm`, `specs/Lispish.spec`
- Related: [[spec-top-rule-no-regex-two-rule-minimum]], [[lispish-corpus-catastrophic-backtracking]],
  [[spec-contract-is-unique]], [[cross-variant-output-parity]]
