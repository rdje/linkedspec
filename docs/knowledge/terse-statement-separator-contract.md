---
id: terse-statement-separator-contract
title: "SPEC-FORMAT-TERSE.1.5.4 — top-level DSL statements are separated by newlines or semicolons; same-line multiple statements require semicolons; nested semicolons stay protected."
answers:
  - "how are terse DSL statements separated"
  - "do newline separated helper statements work without semicolons"
  - "are semicolons still required for same-line helper statements"
  - "does same-line whitespace separate DSL statements"
  - "are semicolons inside return payloads protected"
  - "why does Top.if attached block with elseif still work"
  - "what owns SPEC-FORMAT-TERSE.1.5.4 statement separators"
date: 2026-06-29
status: confirmed
tags: [dsl, actionir, semicolons, statement-split, rust, parity, spec-format-terse, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.1.5.4, 2026-06-29. Perl phase0 subtest `spec_format_terse_1_5_4_statement_separator_contract` proves newline-separated `set(...)\nreturn(...)` splits and lowers to valid generated Perl with an inserted `;`, semicolon-separated same-line statements still lower, same-line whitespace adjacency remains raw, and nested semicolons inside `return(do { my $x = 1; $x })` stay protected. `StatementSplit::Core` now requires a line break for implicit method-boundary splitting; `RewritePipeline` inserts the generated terminator for newline-separated lowered statements. `BootstrapSpec::Core` normalizes captured fluent attached-control tails with newline separators so `Top.if(...) { ... } elseif(...) { ... } else { ... }` remains supported without making arbitrary same-line helper adjacency canonical. Rust parser tests `parse_newline_separated_statements_without_semicolons` and `parse_same_line_statements_require_semicolons`, runtime test `terse_1_5_4_newline_and_semicolon_statement_separators_run`, and oracle fixture `terse_1_5_4_newline_statements` lock parity."
reverify: "env PERL5LIB= prove -q -Iperl t/phase0_regression.t && cargo test --manifest-path rust/linkedspec-core/Cargo.toml parse_newline_separated_statements_without_semicolons && cargo test --manifest-path rust/linkedspec-core/Cargo.toml parse_same_line_statements_require_semicolons && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_1_5_4"
---

# Statement Separator Contract

Top-level helper statements in structured action/lifecycle blocks are separated by either:

- a newline between statements, or
- an explicit semicolon.

Multiple helper statements on one physical line still require semicolons. Plain spaces do not create a
statement boundary.

## Perl Lowering Detail

A newline in `.spec` source is not a Perl statement terminator. The Perl reference therefore records when two
canonical statements were newline-separated and inserts the generated `;` after the previous lowered Perl
statement when needed.

Nested semicolons inside expression payloads remain part of that payload. For example, the semicolon inside
`return(do { my $x = 1; $x })` does not split the outer DSL statement; a following newline does.

## Attached-Control Note

Fluent attached-control syntax can still use conventional branch tails such as:

```text
-> Top.if(on) {
  return_undef()
} elseif(alt_on) {
  say("alt")
} else {
  return_undef()
}
```

Bootstrap normalizes the captured `elseif`/`else` tail into newline-separated helper statements before ActionIR
splitting. That keeps attached-control syntax supported without treating arbitrary same-line helper adjacency
as canonical.

## Links

- Tree: [[SPEC-FORMAT-TERSE]] leaf `.1.5.4`.
- Supersedes the separator portion of [[terse-literals-calls-separators-access-ground-truth]].
- Call-spacing boundary: [[terse-call-spacing-contract]].
