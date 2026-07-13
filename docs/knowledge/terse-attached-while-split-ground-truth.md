---
id: terse-attached-while-split-ground-truth
title: Attached while(cond) blocks: portable Perl/Rust loop with deterministic safety
answers:
  - "what owns attached while(cond) blocks"
  - "does Perl support attached while blocks without raw fallback"
  - "does Rust support attached while statement blocks"
  - "what is the safety rule for terse while loops"
  - "how is SPEC-FORMAT-TERSE.2.2.6 split"
date: 2026-06-30
status: current
tags: [spec-format-terse, control-flow, while, actionir, rust-parity, safety]
evidence: "SPEC-FORMAT-TERSE.2.2.6 split/ownership plus .2.2.6.1 and .2.2.6.2 implementations, 2026-06-30. The split showed old Perl lowering for `while(false) { return(\"bad\") }` was raw host code (`ready=0 raw=1 fallback=1 unresolved=0`) and Rust had no attached statement-loop parser/runtime. `.2.2.6.1` added Perl `ControlFlow`, `Contracts`, `Scanner::FlowRules`, `CanonicalEvents`, and `RewritePipeline` ownership for attached `while(cond) { ... }`. `.2.2.6.2` added Rust parser/runtime parity by parsing attached while as a lazy statement loop over a parsed body block. Current probes show Perl descriptor metadata is `ready=1 raw=0 fallback=0 unresolved=0` with `WHILE` nodes; Rust focused parser/runtime tests PASS; counted loops re-evaluate the condition and return 3; non-terminating loops trip `LinkedSpec while iteration safety limit exceeded after 10000 iterations`. Phase0 PASS (`Files=1, Tests=992`) and the Rust oracle corpus has 39 fixtures."
evidence_update_2026_07_13: "Dart and Julia later implemented attached while. LUA-BACKEND-PARITY.4.3.6.3.3 makes Lua the fifth backend at 108/108 with state re-evaluation, return boundaries, Perl-reference next, and typed guard attribution. Exact-limit timing and next behavior are not actually uniform; FUTURE-PARITY-BACKLOG.5 owns normalization."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $stmt=q{count = 0; while(num_lt(count,3)) { count = num_add(count,1) }; return(count)}; my $spec=qq{Top::\\n /x/ -> Done { $stmt }\\n\\nDone::\\n /x/\\n}; my $d=LinkedSpec::Get(\\$spec, return_descriptor=>1); my $m=$d->{spec}{Top}{meta}{action_rewriter}; my $p=LinkedSpec::Get(\\$spec, top_rule=>\"Top\", parse_mode=>\"consume\"); my $in=\"x\"; print qq{ready=$m->{language_agnostic_action_ir_ready} raw=$m->{raw_perl_dependency_count} fallback=$m->{canonical_action_ir_fallback_count} unresolved=$m->{unresolved_helper_count} nodes=}.join(q{,}, @{$m->{canonical_action_ir_nodes}}).qq{ run=}.JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\\$in)).qq{\\n};' && cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml attached_while && cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_2_6_2 && cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle && bash tools/run_lua_local.sh"
---

`while(cond) { ... }` is the fourth portable Round 2 attached control-flow family after attached `if`,
`when/otherwise`, and `switch/case/default`.

Current state:

- **Perl:** attached `while` is ActionIR-owned on the reference implementation.
- **Rust:** attached `while` parses as a lazy statement loop with a parsed body block.
- **Dart/Julia/Lua:** attached `while` is also executable; Lua closes its runtime leaf at 108/108.
- **Safety:** each attached loop has a deterministic 10000-iteration guard so a non-terminating loop cannot
  hang a generated parser or Rust interpreter execution.

The exact-limit and `next()` edges are not portable; see [[cross-backend-attached-while-boundary-drift]].

Split:

1. `SPEC-FORMAT-TERSE.2.2.6.1` — Perl reference attached `while(cond) { ... }` with loop safety. DONE.
2. `SPEC-FORMAT-TERSE.2.2.6.2` — Rust parity for the accepted Perl loop/safety contract. DONE.
