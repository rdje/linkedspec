---
id: terse-control-flow-keyword-surface-ground-truth
title: Round 2 control-flow keyword surface: attached if/when/switch and inline if/switch are portable; Perl while is landed, Rust while parity remains
answers:
  - "what is the current support for Round 2 control flow keywords"
  - "does attached if(cond) { } lower without raw Perl"
  - "is when/otherwise a LinkedSpec DSL contract yet"
  - "does Rust support attached if or switch statement blocks"
  - "how should SPEC-FORMAT-TERSE.2.2 be split"
date: 2026-06-30
status: current
tags: [spec-format-terse, control-flow, actionir, rust-parity, mdbook]
evidence: "SPEC-FORMAT-TERSE.2.2.1 through .2.2.6.1 ground truth. Perl attached-block `if(true) { return(\"yes\") } else { return(\"no\") }` lowers through ActionIR after `.2.2.2`; Rust `.2.2.3` parses attached `if/elseif/else` branch bodies in `CodeBlock::parse` and normalizes them to the existing marker-control sequence gated by `Engine::handle_statement_if_control`; `.2.2.4` added attached `when/otherwise` aliases over the same if/else model on both variants. `.2.2.5.1` locked Perl attached `switch/case/default` separator/source behavior, and `.2.2.5.2` added Rust parser/runtime parity by normalizing attached switch branch blocks to `switch`/`case`/`default`/`endswitch` statement controls gated by a runtime switch stack. The Rust oracle corpus includes `terse_2_2_5_2_attached_switch_blocks` and now has 38 fixtures. `.2.2.6.1` landed Perl attached `while(cond) { ... }` loop/safety (`ready=1 raw=0 fallback=0 unresolved=0`, `WHILE` nodes, 10000-iteration guard); Rust has no attached statement-loop parser/runtime and remains `.2.2.6.2`."
reverify: "perl -Iperl -MLinkedSpec -MData::Dumper -e 'for my $stmt (q{if(true) { return(\"yes\") } else { return(\"no\") }}, q{when(true) { return(\"yes\") } otherwise { return(\"no\") }}, q{while(false) { return(\"bad\") }}, q{switch(\"a\") { case(\"a\") { return(\"hit\") } default { return(\"miss\") } }}) { my $spec=qq{Top::\\n /x/ -> Done { $stmt }\\n\\nDone::\\n /x/\\n}; my $d=LinkedSpec::Get(\\$spec, return_descriptor=>1); my $m=$d->{spec}{Top}{meta}{action_rewriter}; print qq{$stmt => ready=$m->{language_agnostic_action_ir_ready} raw=$m->{raw_perl_dependency_count} unresolved=$m->{unresolved_helper_count}\\n}; }' && cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-core attached_switch && cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_2_2_5_2 && cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle"
---

`SPEC-FORMAT-TERSE.2.2` is not one implementation slice. Current behavior divides by surface:

- **Portable cross-backend today:** attached-block `if(cond) { ... } elseif(cond2) { ... } else { ... }`,
  attached-block `when(cond) { ... } otherwise { ... }` as aliases over attached `if/else`,
  attached-block `switch(expr) { case(value) { ... } default { ... } }`,
  statement-marker `if(cond); ... elseif(cond); else(); ... endif()`, and inline-composite lazy
  `if(cond, body, elseif(...), else(...))` / `switch(expr, case(...), default(...))`.
- **Reference-only today:** Perl attached `while(cond) { ... }` has deterministic iteration safety; Rust has no
  attached statement-loop runtime yet.
- **Next leaf:** `.2.2.6.2` — Rust parity for the accepted Perl `while(cond) { ... }` loop/safety contract.

The accepted split is:

1. Perl attached-block `if/elseif/else`. DONE in `.2.2.2`.
2. Rust attached-block `if/elseif/else` parity. DONE in `.2.2.3`.
3. `when/otherwise` aliases. DONE in `.2.2.4`.
4. Attached-block `switch/case/default`: `.2.2.5.1` Perl separator/source lock, `.2.2.5.2` Rust parity. DONE.
5. `while(cond) { ... }` split into `.2.2.6.1` Perl reference loop/safety and `.2.2.6.2` Rust parity.
   `.2.2.6.1` DONE; FRONTIER: `.2.2.6.2`.
