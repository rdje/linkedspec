---
id: terse-control-flow-keyword-surface-ground-truth
title: Round 2 control-flow keyword surface is split by current portable support: marker/composite if and inline switch work today, attached if/when/while/switch-block forms need separate leaves
answers:
  - "what is the current support for Round 2 control flow keywords"
  - "does attached if(cond) { } lower without raw Perl"
  - "is when/otherwise a LinkedSpec DSL contract yet"
  - "does Rust support attached if or switch statement blocks"
  - "how should SPEC-FORMAT-TERSE.2.2 be split"
date: 2026-06-30
status: current
tags: [spec-format-terse, control-flow, actionir, rust-parity, mdbook]
evidence: "SPEC-FORMAT-TERSE.2.2.1/.2.2.2 ground truth. TOOLBOX `call_spec_handler_subst` and `LinkedSpec::Get(..., return_descriptor => 1)` probes show compact same-line Perl attached `if(true) { return(\"yes\") } else { return(\"no\") }` is RAW_PERL fallback (`language_agnostic_action_ir_ready=0`), while newline-separated attached branch clauses already lower through ActionIR. `when(true) { ... } otherwise { ... }` depends on host Perl experimental `when` behavior and is not ActionIR-ready, and `while(false) { ... }` is raw. Attached `switch(...) { case(...) { ... } default { ... } }` is Perl ActionIR-ready in metadata but still needs separator and Rust-parity ownership. Rust code-read shows statement-marker `if(cond); ... elseif(cond); else(); ... endif()` gating in `Engine::handle_statement_if_control` and lazy inline-composite `if`/`switch` in `call_helper`, but `CodeBlock::parse` has no attached statement-block AST for `if`, `switch`, `when`, `otherwise`, or `while`."
reverify: "perl -Iperl -MLinkedSpec -MData::Dumper -e 'for my $stmt (q{if(true) { return(\"yes\") } else { return(\"no\") }}, q{when(true) { return(\"yes\") } otherwise { return(\"no\") }}, q{while(false) { return(\"bad\") }}, q{switch(\"a\") { case(\"a\") { return(\"hit\") } default { return(\"miss\") } }}) { my $spec=qq{Top::\\n /x/ -> Done { $stmt }\\n\\nDone::\\n /x/\\n}; my $d=LinkedSpec::Get(\\$spec, return_descriptor=>1); my $m=$d->{spec}{Top}{meta}{action_rewriter}; print qq{$stmt => ready=$m->{language_agnostic_action_ir_ready} raw=$m->{raw_perl_dependency_count} unresolved=$m->{unresolved_helper_count}\\n}; }' && rg -n 'handle_statement_if_control|call_helper_lazy|\"switch\" =>' rust/linkedspec-runtime/src/engine.rs"
---

`SPEC-FORMAT-TERSE.2.2` is not one implementation slice. Current behavior divides by surface:

- **Portable today:** statement-marker `if(cond); ... elseif(cond); else(); ... endif()` and inline-composite
  lazy `if(cond, body, elseif(...), else(...))` / `switch(expr, case(...), default(...))`.
- **Perl attached-if split today:** newline-separated attached branch statements lower through ActionIR, but
  compact same-line `if(cond) { ... } elseif(cond2) { ... } else { ... }` remains raw Perl until `.2.2.2`
  lands the statement-splitting seam.
- **Not a DSL contract today:** `when(cond) { ... } otherwise { ... }` collides with host Perl's experimental
  `when` feature and is not represented as LinkedSpec control flow.
- **Raw today:** `while(cond) { ... }` is host code on Perl and has no Rust statement-loop runtime.
- **Needs its own leaf:** attached-block `switch(expr) { case(v) { ... } default { ... } }` is closer on Perl
  but still needs separator locks and Rust parser/runtime parity before it is a portable Round 2 contract.

The accepted split is:

1. Perl attached-block `if/elseif/else`.
2. Rust attached-block `if/elseif/else` parity.
3. `when/otherwise` aliases.
4. Attached-block `switch/case/default`.
5. `while(cond) { ... }` with explicit progress/iteration safety.
