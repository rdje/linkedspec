---
id: top-rule-is-ordinary-rule-entered-first
title: "Engine mechanics: the top (::) rule is an ordinary rule that is merely ENTERED FIRST, not a special construct. The entry point is just `&{$descr->{spec}{$top_rule}}(...)`; the while(1) streaming loop is MODE-driven (default/OR/REP), not top-driven; a regex on the top rule already compiles as a normal rule (e.g. Pair::AND -> a standard AND handler). 'No regex on top' is the recommended IDIOM, not an engine law (ADR 0010)."
answers:
  - "is the top (::) rule special-cased in the engine vs a normal (:) rule"
  - "what does :: actually do mechanically (entry marker vs dispatch loop)"
  - "where does the while(1) streaming loop come from (top rule or rule mode)"
  - "can a top rule carry a regex and does it work"
  - "does regex on the top rule compile differently from a body rule"
  - "is 'no regex on the top rule' an engine law or an idiom"
  - "how does recursion into / re-entry of the top rule behave"
  - "why does naive top-rule recursion hang (termination / forward progress)"
  - "what did ADR 0010 decide about the top rule"
date: 2026-06-23
status: confirmed
tags: [engine, parser, top-rule, codegen, recursion, language-model, TOP-RULE-AS-NORMAL, ADR-0010]
evidence: "Read-only TOOLBOX investigation 2026-06-23 (TOP-RULE-AS-NORMAL.1). (1) Entry point is just `sub Get { &{$descr->{spec}{$top_rule}}($descr,$_[0]) }` (Compiler.pm:1006) -- the top rule is NOT specially wrapped; it is invoked like any handler. (2) The while(1) loops live in HandlerVariantEmitter.pm and are MODE-driven (default/repeated-choice/REP repeat; :AND is a single ordered pass) -- the 'top = while(1) dispatch loop' behavior is an emergent idiom (default-mode top + dispatch edges + LX accumulator), not a property of `::`. (3) Regex on a top rule already compiles as a normal rule: `generate_only`+`dump_parser_source` on `Pair::AND` + regex slots emits a standard AND handler (`while ($idx < 2) { LinkedRE::or(...) ... }`) -- identical to a body rule; the earlier breakage was the AND-codegen defect already fixed under ADR 0008 / PHASE0-BACKHALF-TRIAGE.3. (4) Idiomatic recursion is body-rule + consume-before-recurse (specs/Lispish.spec: `parenthesis: /\\(/ ... -> parenthesis ... /\\)/`, green). Naive grammars recursing BACK INTO the top rule, or using zero-progress blind-call dispatch, HANG -- the genuinely open dimension (same family as the PHASE0-BACKHALF-TRIAGE.5.2 never-undef/while(1) non-termination). Design decision + engine-touch authorization recorded in ADR 0010."
reverify: "perl -Iperl -e 'use LinkedSpec; my %c; my $s=\"Pair::AND\\n /a/\\n /b/\\n\"; LinkedSpec::Get(\\$s, generate_only=>1, dump_parser_source=>1, runtime_ctx_ref=>\\%c); print ${$c{parser_source_chunks_ref}};'  # emits a standard `Pair => sub { ... while ($idx < 2) { LinkedRE::or(...) } ... }` AND handler -- a top rule compiled exactly like a body rule"
---

# Engine mechanics: the top (`::`) rule is an ordinary rule entered first

**Confirmed 2026-06-23** (read-only investigation `TOP-RULE-AS-NORMAL.1`; design decision ADR
[0010](../decisions/0010-top-rule-is-ordinary-rule-entered-first.md)).

## What the engine actually does

- **`::` is an entry marker, not a special construct.** The generated parser's entry point is just
  `sub Get { &{$descr->{spec}{$top_rule}}($descr, $_[0]) }` (`Compiler.pm:1006`) — it invokes the top
  rule's handler exactly like any other rule's handler. There is **no** top-specific wrapper.
- **The `while(1)` streaming loop is mode-driven, not top-driven.** It lives in
  `HandlerVariantEmitter.pm` and belongs to the *default / repeated-choice / REP* rule modes; `:AND`
  emits a single ordered pass. The familiar "top rule is a `while(1)` dispatch loop" is an **emergent
  idiom** — a default-mode top rule with dispatch edges + an `LX` accumulator — **not** a property of
  `::`.
- **A regex on the top rule already compiles as a normal rule.** `Pair::AND` with regex slots emits a
  standard AND handler (`while ($idx < 2) { LinkedRE::or(...) … }`), identical to a body rule. The old
  breakage was the AND-codegen defect, **fixed** under ADR `0008` / `PHASE0-BACKHALF-TRIAGE.3`.

## The idiom vs the law (ADR 0010)

"No regex on the top rule" and "`:AND`/`:OR`/… are Body-rule-only" are the recommended **idiom/style**
([[spec-top-rule-no-regex-two-rule-minimum]]) — **not** engine laws. The user reframed (ADR `0010`):
the top rule is an ordinary rule merely **entered first**. The dispatch-loop-no-regex shape is the
clean choice for a **stream of records**; a **single recursive document** can be expressed with a
recursive top rule directly.

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
- Related: [[spec-top-rule-no-regex-two-rule-minimum]], [[feedback_spec-structure-top-plus-normal]],
  [[lispish-corpus-catastrophic-backtracking]], [[spec-contract-is-unique]], [[cross-variant-output-parity]]
