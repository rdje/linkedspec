---
id: rust-lifecycle-i-return-dispatch-parity
title: "Rust child-dispatch parity requires I-block return to exit before local entry-regex matching"
answers:
  - "does I.return exit before E in Perl and Rust"
  - "why did Rust tclite consume every other token before the default-mode fix"
  - "how do action-edge child dispatch and I.return interact"
  - "why do tclite close rules return from I before matching"
date: 2026-06-30
status: confirmed
tags: [rust, perl, tclite, lifecycle, dispatch, repetition, spec-format-terse]
evidence: "Perl generated-source probes for a minimal edge-only grammar show the parent dependency regex matches the child entry token and passes that match into the child handler. The child handler's I-block `return(...)` exits immediately and does not run a second local regex match before returning the child value. SPEC-FORMAT-TERSE.2.3.3.3.3.1 mirrored this in Rust by checking `ctx.take_return_value()` immediately after executing `rule.preamble`, restoring caller return/match state, and returning that value. Focused Rust runtime test `default_mode_repeats_action_edge_choices_and_allows_zero_matches` proves repeated `x` children and the zero-match case; focused lifecycle tests now expect `I.return(...)` to exit before matching or `E`; the shipped tclite oracle fixtures pass in the 41-fixture corpus."
reverify: "cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml default_mode_repeats_action_edge_choices_and_allows_zero_matches -- --nocapture; cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_3_3_1_lifecycle_compact_return_records_rule_return -- --nocapture; cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture"
---

# Rust Lifecycle I-Return Dispatch Parity

Perl action-edge dispatch matches the dependency regex in the parent first. The child
invocation receives that match information as its entry context. If the child starts with
`I.return(...)`, that return exits the child immediately; the child does not re-match its
entry regex and does not continue to later matching or `E`.

Rust now mirrors that rule for preamble returns. This is why the minimal `tclite` close
rules can return tagged quote/bracket values at the right cursor position instead of
skipping every other token through a second match attempt.
