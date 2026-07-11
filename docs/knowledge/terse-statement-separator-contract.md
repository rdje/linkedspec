---
id: terse-statement-separator-contract
title: "SPEC-FORMAT-TERSE.1.5.4 — newlines separate top-level DSL statements; semicolons separate adjacent same-line statements; nested semicolons stay protected."
answers:
  - "how are terse DSL statements separated"
  - "do newline separated helper statements work without semicolons"
  - "are semicolons still required for same-line helper statements"
  - "does the last statement on a line need a semicolon"
  - "does same-line whitespace separate DSL statements"
  - "are semicolons inside return payloads protected"
  - "why does Top.if attached block with elseif still work"
  - "what owns SPEC-FORMAT-TERSE.1.5.4 statement separators"
date: 2026-06-29
status: confirmed
tags: [dsl, actionir, semicolons, statement-split, rust, parity, spec-format-terse, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.1.5.4, 2026-06-29. Perl phase0 subtest `spec_format_terse_1_5_4_statement_separator_contract` proves newline-separated `set(...)\nreturn(...)` splits and lowers to valid generated Perl with an inserted `;`, semicolon-separated same-line statements still lower, same-line whitespace adjacency remains raw, and nested semicolons inside `return(do { my $x = 1; $x })` stay protected. `StatementSplit::Core` now requires a line break for implicit method-boundary splitting; `RewritePipeline` inserts the generated terminator for newline-separated lowered statements. `BootstrapSpec::Core` normalizes captured fluent attached-control tails with newline separators so `Top.if(...) { ... } elseif(...) { ... } else { ... }` remains supported without making arbitrary same-line helper adjacency canonical. Rust parser tests `parse_newline_separated_statements_without_semicolons` and `parse_same_line_statements_require_semicolons`, runtime test `terse_1_5_4_newline_and_semicolon_statement_separators_run`, and oracle fixture `terse_1_5_4_newline_statements` lock parity. STATEMENT-SEPARATOR-EXAMPLE-ALIGNMENT.1, 2026-07-10, removed redundant line-ending semicolons from the Dart hash-helper executable fixture and its focused runtime test passed unchanged."
reverify: "env PERL5LIB= prove -q -Iperl t/phase0_regression.t && cargo test --manifest-path rust/linkedspec-core/Cargo.toml parse_newline_separated_statements_without_semicolons && cargo test --manifest-path rust/linkedspec-core/Cargo.toml parse_same_line_statements_require_semicolons && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_1_5_4 && (cd dart && dart test test/runtime_interpreter_test.dart --name 'executes hash helpers receiver chains and mutation boundaries')"
---

# Statement Separator Contract

Top-level helper statements in structured action/lifecycle blocks are separated by either:

- a newline between statements, or
- an explicit semicolon between adjacent statements on the same physical line.

The semicolon is a separator, not a line terminator: `first(); second()` needs the middle semicolon, while the
last statement does not need a trailing semicolon. Plain spaces do not create a statement boundary.

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

## Current Coverage Qualification

The focused `.1.5.4` lock established the separator contract and the ordinary `set(...)` then `return(...)`
lowering path. A later exhaustive helper audit found that the Perl reference does not yet apply the contract
universally to consecutive capture assignments, cursor controls, and marker-style control sequences. See
[[perl-newline-statement-separator-coverage-gap]] and its repair owner
`FUTURE-PARITY-BACKLOG.1.6.1.1`. This is an implementation gap; the contract above is unchanged.

## Links

- Tree: [[SPEC-FORMAT-TERSE]] leaf `.1.5.4`.
- Example-alignment follow-up: [[STATEMENT-SEPARATOR-EXAMPLE-ALIGNMENT]] leaf `.1`.
- Current implementation gap: [[perl-newline-statement-separator-coverage-gap]].
- Supersedes the separator portion of [[terse-literals-calls-separators-access-ground-truth]].
- Call-spacing boundary: [[terse-call-spacing-contract]].
