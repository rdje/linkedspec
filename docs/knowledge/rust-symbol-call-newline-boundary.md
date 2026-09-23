---
id: rust-symbol-call-newline-boundary
title: Rust symbol-call lookahead loses the newline after closing parentheses
answers:
  - why does a Rust division call followed by a newline fail
  - why does slash arithmetic report an unterminated regex
  - which task owns Rust symbol-call newline boundaries
  - why were arithmetic newline controls separated from regex suffix repair
date: 2026-09-23
status: confirmed Rust boundary defect; immediate owner SESSION-STARTUP-READING.86 after .49
tags: [rust, parser, arithmetic, regex, newline]
evidence: "Untouched .49 core RED reports unterminated regex literal for a slash call before another statement. Six native controls show EOF/semicolon and named div plus newline return 7; slash LF, CRLF and spaced slash plus newline reject compilation. Exact sources/traces: .linkedspec-data/scratch/regex-boundary49/slash-before.jsonl. No production repair has been made."
reverify: "Run the public CLI probes below through tools/project_data_run.sh; .86 owns permanent recurrence and repair."
---

The first `.49` core regression has five failures: four expose regex suffix
whitespace consumption, while the arithmetic compatibility control fails in a
different function before any production change. `.86` is the immediate next
leaf; `.49` keeps already working EOF/semicolon arithmetic controls. The original
failure remains in `core-red.log`, with its unchanged required result here:

```rust
CodeBlock::parse("out = /(14, 2)\nreturn(out)")
// Required: two statements. Current: Err("unterminated regex literal").
```

`rust/linkedspec-core/src/expr.rs::symbol_call_paren_has_expression_boundary`
skips all ASCII whitespace after the matching closing parenthesis, then accepts
only EOF or selected punctuation. A newline followed by an identifier therefore
fails its call-boundary test. Slash falls through to regex parsing. This is
separate from `parse_regex` consuming whitespace before suffix letters.

The established distinction is deliberately narrow and preserves regex literals
with parenthesized content. See [[spec-arithmetic-call-surface-ground-truth]].
Repair must retain escaped, quoted and multiline regex controls rather than
blindly classifying every slash plus parenthesis as division.

These current Rust public controls all use input `x`:

```bash
bash tools/project_data_run.sh rust/target/debug/linkedspec-rust --inline-spec $'Top::\n I { out = /(14, 2)\nnote = 1 }\n /x/ E { return(out) }\n' --input x --trace low
bash tools/project_data_run.sh rust/target/debug/linkedspec-rust --inline-spec $'Top::\n I { out = /(14, 2); note = 1 }\n /x/ E { return(out) }\n' --input x --trace low
bash tools/project_data_run.sh rust/target/debug/linkedspec-rust --inline-spec $'Top::\n I { out = div(14, 2)\nnote = 1 }\n /x/ E { return(out) }\n' --input x --trace low
```

The first rejects at compilation; the latter two return 7. CRLF and horizontal
space before the slash-call parentheses retain the failure. The EOF arithmetic
control returns 7 on Rust, but the equivalent Perl outer block reports unclosed
rule syntax. That separate Perl scanner boundary remains under investigation in
`.86`; it must not be inferred fixed by the Rust repair.

Initial no-edge Perl arithmetic probes return the last I assignment (1) despite
`E { return(out) }`, matching the already owned `.27` lifecycle problem in
[[perl-lifecycle-final-value-e-drift]]. They are excluded as arithmetic result
authority. Six public explicit-action-edge controls independently return 7 with
no error, including all three newline forms. Their exact sources/results are in
`perl-edge-before.jsonl`. These establish the newline call's reference acceptance;
they do not establish bare slash-call EOF acceptance in the rejected outer block.

The pre-repair explicit-edge replay has 12 independently authored cases: Perl
returns 7 for all 12; Rust rejects exactly the three regex-newline cases owned by
`.49` and three symbol-call-newline cases owned by `.86`. Other controls return 7.
Logs: `perl-edge-all-before.jsonl` and `native-edge-before.jsonl` in the same
scratch directory. All probe jobs are consumed.

After the separately verified `.49` repair, the same 12-case native replay
returns 7 for all nine regex/compatibility controls and still rejects exactly
the three symbol-call newline forms. The 22-case combined replay passes with
binary SHA256 `2675f2ffb467b123ef6e866b3765c68232a519aac42f6771ed620eef8e0e4e24`;
`native-after.jsonl` records the exact source and trace. This isolates the next
repair without crediting `.49` with a symbol-call fix.
