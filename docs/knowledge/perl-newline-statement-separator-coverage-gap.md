---
id: perl-newline-statement-separator-coverage-gap
title: "Historical Perl newline assignment gap resolved; comment coverage remains incomplete"
answers:
  - "do all newline separated ActionIR statements currently lower in Perl"
  - "why do newline separated capture helper assignments fail in Perl"
  - "why do newline separated cursor controls fail in Perl"
  - "why do newline separated if elseif marker chains fail in Perl"
  - "what does FUTURE-PARITY-BACKLOG.1.6.1.1 own"
date: 2026-09-06
status: qualified
tags: [actionir, statement-split, newline, semicolon, perl-reference, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.1.0 toolbox audit, 2026-07-10. `call_spec_handler_subst` on `slice = capture_slice()\nslice_len = capture_slice_len()` emitted the first assignment as `$slice = do { ... }` without a generated separator and left `slice_len = do { ... }` as a raw target. Cursor-control sequences showed the same missing boundary/raw-target pattern. Newline-separated `if`/`elseif` marker sequences left inner assignments or `elseif(...)` raw, while the same marker sequence on one physical line with explicit semicolon separators lowered and executed. The established contract remains that physical newlines separate statements and semicolons only separate multiple statements on one line; this is an implementation coverage gap, not a contract change. FUTURE-PARITY-BACKLOG.1.6.1.1 owns root cause, repair, focused locks, and unchanged cross-backend proof."
evidence_update_2026_07_10: "FUTURE-PARITY-BACKLOG.1.6.1.1 resolved the gap in `StatementSplit::Core`: every unquoted depth-zero LF/CRLF/CR now pushes the current statement, including the newline that closes a line comment. Existing nesting modes continue to protect parentheses, brackets, blocks, single/double quotes, slash substitutions, and attached same-line continuations. Toolbox output now has independent `$slice`/`$slice_len` targets and complete cursor/if/switch-marker lowering with generated terminators. The 17-assertion focused subtest and all Phase 0 `1..1029` pass; unchanged Perl regeneration and Rust/Dart/Julia corpus execution each pass 99 fixtures."
reverify: "PERL5LIB= prove -v -Iperl t/phase0_regression.t && perl -Iperl -MLinkedSpec -e 'print LinkedSpec::call_spec_handler_subst(\"Top\", \"slice = capture_slice()\\nslice_len = capture_slice_len()\"), \"\\n\"'"
---

# Historical Perl Newline Statement-Separator Repair

The public statement-separator contract is unchanged:

- a physical newline separates adjacent top-level statements;
- a semicolon separates adjacent statements only when they share one physical line; and
- the final statement on a line does not require a trailing semicolon.

The earlier focused lock proved a narrow `set(...)` then `return(...)` path. The exhaustive current-call audit
showed that this did not establish universal Perl reference coverage: the splitter recognized complete method-call
statements before newlines, but assignment-form statements absorbed the following line.

`.1.6.1.1` closed the measured non-comment assignment seam. Its universal wording and the dated evidence
above overstate comment coverage; the 2026-09-06 qualification below records the remaining failures. Quote and
nesting state protects multiline call arguments, expression blocks, strings, and substitutions. Same-line whitespace still does not create a boundary, and same-line statements still require the
semicolon separator between them.

The audit fixture sources live under `capability_conformance/fixtures/`. `.1.6.1.2` owns their final timing design,
oracle admission, strict inventory closure, and unchanged execution on every backend.

This card concerns statement segmentation. A later fixture audit found a distinct emitted-Perl terminator gap after
newline `endswitch()`; see [[perl-newline-switch-close-terminator-gap]].

## 2026-09-06 comment qualification

`SESSION-STARTUP-READING.3.2.33` measures twelve public Perl combinations. An inline comment after an
assignment hides the generated semicolon for LF/CRLF, causing handler compilation failure. CR-only comments
absorb a following return even with an explicit semicolon or standalone comment. No-comment controls pass
for all three newline spellings. [[perl-comment-newline-lowering-drift]] records the exact toolbox probes,
source mechanisms, and repair ownership `.34.1`/`.34.2`; the authored separator contract is unchanged.

## Links

- Contract: [[terse-statement-separator-contract]].
- Historical narrow repair: [[terse-literals-calls-separators-access-ground-truth]].
- Attached-control seam: [[terse-perl-attached-if-statement-split-seam]].
- Residual emitted-control seam: [[perl-newline-switch-close-terminator-gap]].
- Owner: [[FUTURE-PARITY-BACKLOG]] `.1.6.1.1`.
