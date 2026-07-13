---
id: terse-call-spacing-contract
title: "SPEC-FORMAT-TERSE.1.5.3 plus ADR 0033 — helper calls keep callee(args); only enumerated zero-argument marker and terminal-receiver aliases may omit parentheses."
answers:
  - "can terse helper calls have whitespace before the opening parenthesis"
  - "does set (name, value) mean the same thing as set(name, value)"
  - "are parentheses mandatory for helper calls in terse .spec actions"
  - "what are the narrow exceptions to mandatory call parentheses"
  - "does return scalar name parse as return(scalar(name))"
  - "does set name,value parse as set(name,value)"
  - "does return(cat \"a\",\"b\") parse as return(cat(\"a\",\"b\"))"
  - "what owns SPEC-FORMAT-TERSE.1.5.3 call spacing"
date: 2026-06-29
status: confirmed
tags: [dsl, calls, actionir, rust, parity, spec-format-terse, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.1.5.3, 2026-06-29, locks optional whitespace before `(` and rejects general no-parenthesis helper spellings. ADR 0033 and FUTURE-PARITY-BACKLOG.16.0, 2026-07-13, preserve that general contract while enumerating a narrow future-alignment surface: six standalone zero-argument markers and a final zero-argument receiver segment. Those aliases do not authorize general helper/user-function calls, argument-bearing calls, intermediate generic bare receiver segments, or parenthesis-free if/while headers."
reverify: "env PERL5LIB= prove -q -Iperl t/phase0_regression.t && cargo test --manifest-path rust/linkedspec-core/Cargo.toml parse_call_with_whitespace_before_parentheses && cargo test --manifest-path rust/linkedspec-core/Cargo.toml parse_no_paren_helper_keyword_is_not_single_call && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_1_5_3"
---

# Call Spacing Contract

Helper calls use the uniform `callee(args)` shape. Whitespace between the helper name and the opening
parenthesis is a layout detail:

- `set (name, value)` is the same helper call as `set(name, value)`;
- `cat ("a","b")` is the same value expression as `cat("a","b")`;
- wrapped reads such as `scalar (name)` keep their normal meaning.

The parentheses remain mandatory for general calls. No-parenthesis spellings such as `set name,"v"`,
`return scalar name`, and `return cat("a","b")` are not helper calls and must not be treated as shorthand for the
parenthesized forms. ADR 0033 adds only enumerated zero-argument control markers and a final zero-argument receiver
segment; implementation parity is owned by `FUTURE-PARITY-BACKLOG.16`.

## Links

- Tree: [[SPEC-FORMAT-TERSE]] leaf `.1.5.3`.
- Related ground truth: [[terse-literals-calls-separators-access-ground-truth]].
- Primitive literal leaf: [[terse-primitive-literal-parity]].
