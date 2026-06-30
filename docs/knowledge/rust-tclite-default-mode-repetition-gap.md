---
id: rust-tclite-default-mode-repetition-gap
title: "Rust tclite default-mode repetition parity landed after the fluent retry isolated the gap"
answers:
  - "why does Rust tclite still return [] after fluent parity"
  - "what happened when tclite oracle was retried after SPEC-FORMAT-TERSE.2.3.3.3.2"
  - "which leaf owns Rust tclite default-mode repetition parity"
  - "why are tclite_command_subst and tclite_double_quote not in the Rust oracle corpus"
  - "what are the Perl reference outputs for tclite [] and empty double quote"
  - "when did tclite_command_subst and tclite_double_quote enter the Rust oracle corpus"
  - "how was Rust tclite default-mode repetition fixed"
date: 2026-06-30
status: resolved
tags: [rust, tclite, oracle, corpus, repetition, spec-format-terse]
evidence: "SPEC-FORMAT-TERSE.2.3.3.3.3 retried the deferred tclite oracle after Rust compact lifecycle/body fluent chains (.2.3.3.3.1) and action-edge explicit/flow fluent chains (.2.3.3.3.2) landed. Direct Perl reference probes returned `[\"?tcl_script:\",[[\"?command_subst:\",[]]]]` for input `[]` and `[\"?tcl_script:\",[[\"?double_quote:\",[]]]]` for input `\"\"`. Temporarily re-enabling `tclite_command_subst` and `tclite_double_quote` produced 41 fixtures but failed exactly those two cases because Rust returned `[]`. SPEC-FORMAT-TERSE.2.3.3.3.3.1 fixed the isolated gap by making Rust `RuleMode::Default` a zero-min repeated-choice mode and by honoring child-rule I-block return before local entry-regex matching. The two tclite fixtures are now committed in tools/gen_oracle_corpus.pl and rust/linkedspec-runtime/tests/corpus/, and `cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture` passes over 41 fixtures."
reverify: "perl -Iperl -MJSON::PP -MLinkedSpec -e 'my $p=LinkedSpec::get_parser(\"tclite\"); for my $input (\"[]\", \"\\\"\\\"\") { my $s=$input; my $v=$p->(\\$s); print $input, \" => \", JSON::PP->new->canonical(1)->allow_nonref(1)->encode($v), \"\\n\"; }'; cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture"
---

# Rust tclite Default-Mode Repetition Parity

`SPEC-FORMAT-TERSE.2.3.3.3.3` retried `tclite` after the Rust fluent-chain blockers
landed. The retry proved the remaining divergence is not fluent syntax support:

- Perl `tclite` on `[]` returns `["?tcl_script:",[["?command_subst:",[]]]]`.
- Perl `tclite` on `""` returns `["?tcl_script:",[["?double_quote:",[]]]]`.
- Rust still returned `[]` for both temporarily re-enabled oracle fixtures.

`SPEC-FORMAT-TERSE.2.3.3.3.3.1` then landed the implementation:

- Rust default rules are zero-min repeated-choice loops.
- A dispatched child rule whose `I` block returns exits before re-matching the entry regex locally.
- `tclite_command_subst` and `tclite_double_quote` are active oracle fixtures.
- The Rust corpus oracle passes with 41 fixtures.

Do not re-audit compact lifecycle chains or action-edge fluent chains for this historical
failure; those landed before the retry and were not the remaining root cause.
