---
id: terse-call-spacing-contract
title: "SPEC-FORMAT-TERSE.1.5.3 — helper calls keep mandatory callee(args) parentheses; optional whitespace before '(' is accepted at supported call sites, but no-parenthesis helper spellings are not helper calls."
answers:
  - "can terse helper calls have whitespace before the opening parenthesis"
  - "does set (name, value) mean the same thing as set(name, value)"
  - "are parentheses mandatory for helper calls in terse .spec actions"
  - "does return scalar name parse as return(scalar(name))"
  - "does set name,value parse as set(name,value)"
  - "does return(cat \"a\",\"b\") parse as return(cat(\"a\",\"b\"))"
  - "what owns SPEC-FORMAT-TERSE.1.5.3 call spacing"
date: 2026-06-29
status: confirmed
tags: [dsl, calls, actionir, rust, parity, spec-format-terse, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.1.5.3, 2026-06-29. Perl phase0 subtest `spec_format_terse_1_5_3_call_spacing_and_parentheses_locks` proves spaced calls lower identically to tight calls for return, set, nested cat/scalar/array, array-append RHS, and hash-index key/RHS sites; it also locks no-parenthesis forms as outside helper recognition. A real spaced-call spec returns `[\"ab\",[\"cd\"],{\"stage\":\"ab\"}]` with canonical ASSIGN/PUSH/RETURN and fallback count 0. Rust parser test `parse_call_with_whitespace_before_parentheses` locks spaced-call acceptance, while `parse_no_paren_helper_keyword_is_not_single_call` locks the mandatory-parentheses contract by rejecting `return cat(...)` under same-line separator enforcement. Runtime test `terse_1_5_3_call_spacing_runs_like_tight_calls` and oracle fixture `terse_1_5_3_call_spacing` lock parity."
reverify: "env PERL5LIB= prove -q -Iperl t/phase0_regression.t && cargo test --manifest-path rust/linkedspec-core/Cargo.toml parse_call_with_whitespace_before_parentheses && cargo test --manifest-path rust/linkedspec-core/Cargo.toml parse_no_paren_helper_keyword_is_not_single_call && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_1_5_3"
---

# Call Spacing Contract

Helper calls use the uniform `callee(args)` shape. Whitespace between the helper name and the opening
parenthesis is a layout detail:

- `set (name, value)` is the same helper call as `set(name, value)`;
- `cat ("a","b")` is the same value expression as `cat("a","b")`;
- wrapped reads such as `scalar (name)` keep their normal meaning.

The parentheses remain mandatory. No-parenthesis spellings such as `set name,"v"`, `return scalar name`, and
`return cat("a","b")` are not helper calls and must not be treated as shorthand for the parenthesized forms.
Rust rejects same-line no-parenthesis spellings that would require whitespace as an implicit statement separator.

## Links

- Tree: [[SPEC-FORMAT-TERSE]] leaf `.1.5.3`.
- Related ground truth: [[terse-literals-calls-separators-access-ground-truth]].
- Primitive literal leaf: [[terse-primitive-literal-parity]].
