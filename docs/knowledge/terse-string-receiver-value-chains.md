---
id: terse-string-receiver-value-chains
title: SPEC-FORMAT-TERSE.2.3.5.3 string receiver-dot value chains
answers:
  - "how do string receiver-dot value chains work"
  - "does raw.trim().lowercase work"
  - "does raw.split().join_values work"
  - "does string literal receiver-dot work"
  - "does receiver-dot substr work"
  - "can string terminal methods continue"
  - "which task follows SPEC-FORMAT-TERSE.2.3.5.3"
  - "are block-valued receiver chains task-tree owned"
date: 2026-07-01
status: current
tags: [spec-format-terse, method-chaining, receiver-dot, string, rust-parity, mdbook]
evidence: "SPEC-FORMAT-TERSE.2.3.5.3 landed string/scalar receiver-dot value chains on Perl and Rust. Perl normalizes compatible receiver-dot string chains into pure helper composition; bare scalar receivers are wrapped as scalar(name) before composition so generated Perl reads the scalar working variable. Rust parses fluent chains after string literals and evaluates Expr::FluentChain string receivers through the same helper family. String-returning links include trim, lowercase, uppercase, replace_substr, rm_prefix, rm_suffix, substr, concat/cat, and coalesce_nonempty. split(delim) returns an array and bridges into the array receiver-chain family. length, starts_with, ends_with, contains_substr, and matches are terminal values and invalid later receiver-dot continuations return undef/null. Value-form split(...) and substr(...) lower as portable helper payloads. Phase0 passed with 998 tests and the oracle corpus passed with 49 fixtures. The next implementation leaf is .2.3.5.4 number receiver-dot value chains; .2.3.5.5 now owns block-valued receiver chaining by yielded runtime type."
reverify: "prove -q -Iperl t/phase0_regression.t && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_5_3 --quiet && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture"
---

`SPEC-FORMAT-TERSE.2.3.5.3` is the string/scalar-family implementation leaf for return-type method chaining.

String receiver-dot chains are pure value composition. The receiver becomes the first string helper argument,
and each string-returning helper feeds the next compatible helper:

- `raw.trim().lowercase().replace_substr("-", "_")` reads scalar `raw`, trims it, lowercases it, and rewrites
  literal hyphens.
- `"abcdef".substr(1, 3).uppercase()` starts from a string literal receiver and returns `"BCD"`.
- `raw.trim().split("-").trim_each().lowercase_each().join_values("|")` bridges through `split(delim)` into
  the array receiver family.

Terminal string methods end the chain. `raw.length().trim()` and `raw.matches(/^a/).lowercase()` return
`undef` / JSON `null` rather than leaving generated host method residue.

The next task-tree leaf is `.2.3.5.4` for number receiver-dot value chains. The follow-on `.2.3.5.5` owns
block-valued receiver chaining by the runtime type yielded from an expression-valued block.
