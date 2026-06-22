---
id: lispish-corpus-catastrophic-backtracking
title: The phase0 corpus_regression "hang" is an UNBOUNDED multi-parse loop (the Lispish parser never returns undef on a no-progress call), NOT regex backtracking
answers:
  - "why does corpus_regression hang"
  - "why does t/phase0_regression.t hang at corpus_regression"
  - "is the corpus_regression subtest-941 tail a natural stop or a real failure"
  - "does the Lispish parser catastrophically backtrack on the conf corpus"
  - "does the Lispish parser return undef at end of input"
  - "why does parse_with_lispish_multi loop forever"
  - "why is phase0 not green after the back-half triage"
  - "what blocks green phase0 after PHASE0-BACKHALF-TRIAGE cluster .2"
date: 2026-06-22
status: accepted
tags: [phase0, lispish, corpus, parser-contract, regression-gate, streaming-loop]
evidence: "PHASE0-BACKHALF-TRIAGE.5.2 (2026-06-22): input bisection showed a SINGLE parse of the full 392-byte conf file = 0.03s (no regex blow-up); loop instrumentation showed iter1 pos 0->350 (defined), iter2..N pos 350->350 (+0, defined) — the stuck call re-returns form 1's exact AST. Confirmed general: single-form `(rise_o_fall...)` at EOF and `(R rise)\\n\\n` both return defined + zero-advance. The guarded multi-parse over all 76 conf+tablescript files = 76/76 ok, 0 hang."
reverify: "perl -Iperl -e 'use LinkedSpec; my $p=LinkedSpec::get_parser(q{Lispish}); my $d=qq{(R rise)\\n}; $p->(\\$d); my $b=pos($d)//0; my $a=$p->(\\$d); my $e=pos($d)//0; print( (defined($a) && $e==$b) ? qq{ROOT CAUSE PRESENT: 2nd call returns DEFINED with no pos advance ($b==$e)\\n} : qq{parser now signals end-of-stream (changed)\\n} )'"
---

# corpus_regression's "hang" is an unbounded multi-parse loop, not a regex

`t/phase0_regression.t`'s `corpus_regression` (top-level subtest ~941) burned hours of CPU not
because of a catastrophic-backtracking regex (an earlier hypothesis — **disproved**), but because
the **Lispish parser never returns `undef`** and the corpus driver looped on that.

## The mechanism (measured 2026-06-22, PHASE0-BACKHALF-TRIAGE.5.2)

- `parse_with_lispish_multi($file)` is a streaming loop: `while(1){ $ast = $lispish->(\$data); last
  unless defined $ast; push @ast_list, $ast; }` (+ a 100000-iteration cap). It relies on the parser
  returning `undef` at end-of-stream.
- **The Lispish parser never returns `undef`.** On any call that consumes no further input — at EOF,
  on trailing whitespace, or on the inter-form `\n\n` — it **re-returns the previous form's AST with
  `pos()` unchanged**. Proven:
  - a single `$p->(\$full_392B_conf)` = 0.03s and returns a defined AST (no regex blow-up);
  - repeated calls: `iter1 pos 0->350 (def)`, then `iter2.. pos 350->350 (+0, def)` forever — the
    stuck call re-emits form 1's exact `['regexps', …]`;
  - general, not file-specific: single-form `(rise_o_fall…)` at EOF → defined/zero-advance;
    `(R rise)\n\n` → defined/zero-advance.
- So the loop spins to its 100000 cap (~0.002s × 100000 ≈ **3 min per file** × 76 conf/tablescript
  files = the multi-CPU-hour "hang"). The `ebnf` dataset was healthy only because it uses the
  single-call probe (`parse_with_linkedspec`), not the loop. Long-masked behind the subtest-110
  RTLUtils hang ([[rtlutils-regex-hang]]), then the plugin `opendir` die (`PHASE0-BACKHALF-TRIAGE.5.1`).

## Two coupled defects (root cause)

1. **The streaming loop lacks a forward-progress guard** — a `while(1)` parse loop must stop when a
   call consumes no input; keying termination *only* on `defined($ast)` is incorrect against a parser
   that doesn't emit `undef`. **This is the fix applied in `.5.2`** (test-only: `last if pos_after <=
   pos_before` in `parse_with_lispish_multi`). Measured: all 76 conf+tablescript files then parse ok.
2. **The Lispish parser's contract** — it returns a stale defined AST instead of `undef` on a
   no-progress/EOF call (the top `Lispish::` dispatch-loop rule, on no match at the current pos, falls
   through returning the retained value). Making it return `undef` would be an *engine* change (broad,
   cross-variant) — deferred. Relatedly, the `Lispish::` top rule does not skip top-level inter-form
   whitespace, so a multi-form file parses only up to the first whitespace gap (a pre-existing grammar
   capability gap; ambitiming.conf's 2nd form `rise_o_fall` is dropped) — orthogonal to the hang.

## Diagnosis method (dogfooded `TOOLBOX.md`)

Input bisection (single-parse is fast → not a regex) → loop instrumentation (pos+defined per
iteration → the never-advance/never-undef fact) → generalization across inputs. Note: `alarm()`
cannot bound it (a no-progress *loop* in pure-Perl IS interruptible by alarm, unlike a C-level regex —
but the earlier fork+SIGKILL census was still the right tool to enumerate the affected files).

Distinct from [[rtlutils-regex-hang]] (a real catastrophic regex in the retired VHDL subsystem) and
[[andplusplus-lx-parser-hang]] (a spec.spec self-parse hang).
