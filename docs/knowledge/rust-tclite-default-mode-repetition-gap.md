---
id: rust-tclite-default-mode-repetition-gap
title: "Rust tclite still returns [] after fluent parity because default-mode recursive repetition is not yet at Perl-reference parity"
answers:
  - "why does Rust tclite still return [] after fluent parity"
  - "what happened when tclite oracle was retried after SPEC-FORMAT-TERSE.2.3.3.3.2"
  - "which leaf owns Rust tclite default-mode repetition parity"
  - "why are tclite_command_subst and tclite_double_quote not in the Rust oracle corpus"
  - "what are the Perl reference outputs for tclite [] and empty double quote"
date: 2026-06-30
status: current
tags: [rust, tclite, oracle, corpus, repetition, spec-format-terse]
evidence: "SPEC-FORMAT-TERSE.2.3.3.3.3 retried the deferred tclite oracle after Rust compact lifecycle/body fluent chains (.2.3.3.3.1) and action-edge explicit/flow fluent chains (.2.3.3.3.2) landed. Direct Perl reference probes returned `[\"?tcl_script:\",[[\"?command_subst:\",[]]]]` for input `[]` and `[\"?tcl_script:\",[[\"?double_quote:\",[]]]]` for input `\"\"`. Temporarily re-enabling `tclite_command_subst` and `tclite_double_quote` in `tools/gen_oracle_corpus.pl` produced 41 fixtures; `cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture` failed exactly those two cases, with expected wrapped Perl values and actual Rust `[]`, while the other 39 fixtures passed. Therefore the next owned implementation leaf is SPEC-FORMAT-TERSE.2.3.3.3.3.1, not another fluent-continuation audit."
reverify: "perl -Iperl -MJSON::PP -MLinkedSpec -e 'my $p=LinkedSpec::get_parser(\"tclite\"); for my $input (\"[]\", \"\\\"\\\"\") { my $s=$input; my $v=$p->(\\$s); print $input, \" => \", JSON::PP->new->canonical(1)->allow_nonref(1)->encode($v), \"\\n\"; }'; cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture"
---

# Rust tclite Default-Mode Repetition Gap

`SPEC-FORMAT-TERSE.2.3.3.3.3` retried `tclite` after the Rust fluent-chain blockers
landed. The retry proved the remaining divergence is not fluent syntax support:

- Perl `tclite` on `[]` returns `["?tcl_script:",[["?command_subst:",[]]]]`.
- Perl `tclite` on `""` returns `["?tcl_script:",[["?double_quote:",[]]]]`.
- Rust still returned `[]` for both temporarily re-enabled oracle fixtures.

The failed fixtures are intentionally absent from the committed green corpus until
`SPEC-FORMAT-TERSE.2.3.3.3.3.1` lands default-mode recursive repetition/top-level
default-rule dispatch parity and re-enables:

- `tclite_command_subst`
- `tclite_double_quote`

Do not re-audit compact lifecycle chains or action-edge fluent chains for this failure;
those landed before the retry.
