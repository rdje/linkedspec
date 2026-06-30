---
id: terse-attached-while-split-ground-truth
title: Attached while(cond) blocks are split before code: Perl reference loop/safety first, Rust parity second
answers:
  - "what owns attached while(cond) blocks"
  - "does Perl support attached while blocks without raw fallback"
  - "does Rust support attached while statement blocks"
  - "what is the safety rule for terse while loops"
  - "how is SPEC-FORMAT-TERSE.2.2.6 split"
date: 2026-06-30
status: current
tags: [spec-format-terse, control-flow, while, actionir, rust-parity, safety]
evidence: "SPEC-FORMAT-TERSE.2.2.6 split/ownership, 2026-06-30. KM retrieval (`terse-control-flow-keyword-surface-ground-truth`, `spec-format-brainstorm-rounds-1-3`, `top-rule-recursion-forward-progress-guard`) and TOOLBOX probes show current Perl lowers `while(false) { return(\"bad\") }` as raw host code: `ready=0 raw=1 fallback=1 unresolved=0`. Perl code-read found existing ActionIR control-flow ownership for attached if/switch, but no while contract in `ControlFlow.pm`, `Contracts.pm`, or `Scanner/FlowRules.pm`. Rust code-read found attached parsers/runtimes for if and switch in `expr.rs`/`engine.rs`, but no attached statement-loop parser/runtime. `.2.2.6` is split into `.2.2.6.1` Perl reference loop/safety and `.2.2.6.2` Rust parity."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $stmt (q{while(false) { return(\"bad\") }}, q{while(true) { return(\"hit\") }}) { my $lower=LinkedSpec::call_spec_handler_subst(\"Top\", $stmt); my $spec=qq{Top::\\n /x/ -> Done { $stmt }\\n\\nDone::\\n /x/\\n}; my $d=LinkedSpec::Get(\\$spec, return_descriptor=>1); my $m=$d->{spec}{Top}{meta}{action_rewriter}; print qq{$stmt => $lower :: ready=$m->{language_agnostic_action_ir_ready} raw=$m->{raw_perl_dependency_count} fallback=$m->{canonical_action_ir_fallback_count} unresolved=$m->{unresolved_helper_count}\\n}; }'"
---

`while(cond) { ... }` is the remaining Round 2 control-flow leaf after attached `if`, `when/otherwise`, and
attached `switch/case/default` landed on both variants.

Current state:

- **Perl:** attached `while` lowers as raw host code, so it is not ActionIR-owned and not portable.
- **Rust:** no attached statement-loop parser/runtime exists yet.
- **Safety:** the accepted DSL contract must include deterministic iteration safety so a non-terminating loop
  cannot hang a generated parser.

Split:

1. `SPEC-FORMAT-TERSE.2.2.6.1` — Perl reference attached `while(cond) { ... }` with loop safety.
2. `SPEC-FORMAT-TERSE.2.2.6.2` — Rust parity for the accepted Perl loop/safety contract.
