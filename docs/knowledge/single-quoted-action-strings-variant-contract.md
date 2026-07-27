---
id: single-quoted-action-strings-variant-contract
title: Single-quoted and double-quoted action strings are a variant-agnostic LinkedSpec contract
answers:
  - are single quoted strings supported by all LinkedSpec variants
  - can substr regex mutation use a single quoted pattern
  - is single quote syntax Julia specific
  - which quote style should be used around a pattern containing double quotes
date: 2026-07-10
status: current
tags: [dsl, strings, quotes, perl, rust, dart, julia, variants]
evidence: "The mdBook formal grammar defines both \"text\" and 'text' as string literals. Perl ActionIR ValueExpr recognizes single_quoted_literal and double_quoted_literal. JULIA-BACKEND-PARITY.6.2.4.5.2 locks the exact single-quoted pattern containing an embedded double quote and \\s in Perl actionir_ast_parser.t, Rust parse_string_literal_single_quotes, Dart action_ast_parser_test.dart, and Julia's executable statement-mutation test. All four preserve the same pattern value. This is a language contract for every backend, including future variants, not Julia-specific syntax."
reverify: "prove -Iperl t/actionir_ast_parser.t && cargo test --manifest-path rust/linkedspec-core/Cargo.toml parse_string_literal_single_quotes && (cd dart && bash ../tools/run_dart_project_data.sh test test/action_ast_parser_test.dart)"
---

Both quote delimiters denote scalar string literals in `.spec` action code. Every backend must accept them with the
same value meaning; a backend may not treat single quotes as a variant extension or compatibility-only spelling.

Prefer the delimiter that minimizes escaping. A regex-substitution pattern containing a double quote is clearer as
`substr(value, '"|\s', "", go)` than as a double-quoted string with an escaped embedded quote. The equivalent
double-quoted form remains valid.

Backslash content still belongs to the string/pattern. In a single-quoted pattern, `\s` remains the regex whitespace
escape across the current Perl, Rust, Dart, and Julia parsers.
