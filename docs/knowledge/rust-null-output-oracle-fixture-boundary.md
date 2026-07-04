---
id: rust-null-output-oracle-fixture-boundary
title: RUST-PARITY.7.3.5 separates diagnostic Perl-null shipped specs from valid Rust oracle fixtures; spec.spec smokes are the landed JSON-safe cases
answers:
  - "why are BNF DT ifelse operators_try not Rust oracle fixtures"
  - "why did RUST-PARITY.7.3.5 not add BNF DT ifelse operators_try fixtures"
  - "which spec.spec smokes are in the Rust oracle corpus"
  - "why did operators_try emit Rust action parser warnings"
  - "how did Rust fix quoted braces in .spec code blocks"
  - "what happened to null-output oracle candidates in RUST-PARITY.7.3.5"
date: 2026-07-04
status: confirmed
tags: [rust, oracle, corpus, spec-spec, operators_try, RUST-PARITY]
evidence: "RUST-PARITY.7.3.5 probed the Perl reference with `perl -Iperl -MLinkedSpec -MJSON::PP`: representative `BNF`, `DT`, `ifelse`, and `operators_try` inputs returned JSON null, proving those inputs are diagnostic/debug-print paths rather than semantic-AST fixture candidates. Temporary Rust probes showed empty accumulators for the same cases and were removed. The real Rust gap was `operators_try`: `group`, `function_call`, and `string` lifecycle debug strings contain literal braces, and `rust/linkedspec-core/src/parser.rs` counted braces inside quoted strings while scanning code blocks. `scan_line_for_braces_chars` now ignores braces inside single- and double-quoted strings, honoring backslash escapes. Focused parser tests lock both generic quoted-brace code blocks and the real `operators_try` strings. `tools/gen_oracle_corpus.pl` now includes `spec_spec_minimal_rule`, `spec_spec_action_edge`, `spec_spec_user_function_definition`, and `spec_spec_comment_skip`; `perl -Iperl tools/gen_oracle_corpus.pl` emits 81 fixtures, `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle -- --nocapture` passes, and `parse_all_shipped_specs` passes with the target `operators_try` warnings gone."
reverify: "perl -c -Iperl tools/gen_oracle_corpus.pl; perl -Iperl tools/gen_oracle_corpus.pl; cargo test --manifest-path rust/Cargo.toml -p linkedspec-core parse_operators_try_debug_strings_with_braces -- --nocapture; cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime parse_all_shipped_specs -- --nocapture; cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle -- --nocapture"
---

# Rust Null-Output Oracle Fixture Boundary

**Confirmed 2026-07-04 (`RUST-PARITY.7.3.5`).** A Perl `null` result from a shipped
spec is not automatically a good Rust oracle fixture. For the probed `BNF`, `DT`,
`ifelse`, and `operators_try` inputs, the Perl reference returns `null`; those specs are
diagnostic/debug-print experiments for these paths, not semantic-AST producers. Rust's
empty accumulator on those inputs is therefore not a meaningful fixture target.

`operators_try` did expose a real Rust parser issue. Its debug `I` blocks print strings
containing literal braces, such as start/end group markers. Rust's `.spec` code-block
scanner counted braces inside quoted strings and truncated the block before the action
parser saw valid code. The scanner now tracks single- and double-quoted strings plus
backslash escapes, so braces inside string literals do not affect block depth.

`spec.spec` is a valid fixture owner. Four JSON-safe smokes are active in the oracle
corpus:

- `spec_spec_minimal_rule`
- `spec_spec_action_edge`
- `spec_spec_user_function_definition`
- `spec_spec_comment_skip`

After this leaf the Rust oracle corpus has 81 fixtures.
