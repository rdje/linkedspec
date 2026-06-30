---
id: terse-fluent-lifecycle-composability-split
title: SPEC-FORMAT-TERSE.2.3 split for fluent block chains, lifecycle values, composability, and method chaining
answers:
  - "how should SPEC-FORMAT-TERSE.2.3 be split"
  - "does Perl support fluent when otherwise block chains"
  - "does .when(cond) { } .otherwise { } work on the Perl reference"
  - "does Rust support fluent block chains on action edges"
  - "are lifecycle blocks value returning"
  - "are array end mutation methods value returning"
  - "what is the next SPEC-FORMAT-TERSE.2.3 leaf"
date: 2026-06-30
status: current
tags: [spec-format-terse, fluent, lifecycle, composability, rust-parity, mdbook]
evidence: "SPEC-FORMAT-TERSE.2.3 ownership pass. KM retrieval plus TOOLBOX probes showed Perl reference descriptor/runtime support for exact action and lifecycle fluent block chains such as `Done.when(true) { return(\"yes\") }.otherwise { return(\"no\") }` and `I.when(true) { set(value,\"yes\") }.otherwise { set(value,\"no\") }`, both reporting `ready=1 raw=0 fallback=0 unresolved=0` and returning the selected branch. Perl `BootstrapSpec::Core` has fluent-chain parsing/rendering with attached if-clause tails, and `ActionIR::ControlFlow` normalizes attached `when/otherwise` through the if/else path. Rust `expr.rs` has `Expr::FluentChain` for `.method(args)` only, `parser.rs` has attached statement blocks but no fluent attached-block payload, `compiler.rs` drops standalone/body fluent-chain elements, and `RUST-PARITY.7.5.3` already owns action-edge fluent continuation parity. Representative nested helper composition works, but receiver-dot array end mutations are statement-only; value-returning/chained forms fail today."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'for my $stmt (q{Done.when(true) { return(\"yes\") }.otherwise { return(\"no\") }}, q{I.when(true) { set(value,\"yes\") }.otherwise { set(value,\"no\") } LX { return(value) }}) { my $spec = $stmt =~ /^I/ ? qq{Top::\\n /x/ $stmt\\n} : qq{Top::\\n /x/ -> $stmt\\n\\nDone::\\n /x/\\n}; my $d=LinkedSpec::Get(\\$spec, return_descriptor=>1); my $m=$d->{spec}{Top}{meta}{action_rewriter}; print qq{ready=$m->{language_agnostic_action_ir_ready} raw=$m->{raw_perl_dependency_count} fallback=$m->{raw_perl_fallback_count} unresolved=$m->{unresolved_helper_count}\\n}; }' && cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml parse_array_end_mutation_fluent_receivers"
---

`SPEC-FORMAT-TERSE.2.3` is a container, not one implementation leaf.

Accepted split:

1. `.2.3.1` Perl reference fluent block-chain contract lock.
2. `.2.3.2` lifecycle block final-value dropping and explicit `return(expr)` rule-channel semantics.
3. `.2.3.3` Rust fluent block-chain/action-edge parity, coordinated with `RUST-PARITY.7.5.3`.
4. `.2.3.4` full nested composability audit and gap split.
5. `.2.3.5` return-type method chaining design and first implementation split.

Current ground truth:

- Perl already accepts exact fluent attached control-flow chains on action and lifecycle surfaces.
- Rust supports the attached statement control-flow family, but not fluent attached-block payloads or every
  action/body fluent continuation.
- Lifecycle blocks already parse and run, but their final expression value is not a block return value; explicit
  `return(expr)` has surrounding rule/action return semantics and needs a focused lock.
- Round 1 array receiver-dot mutations are statement-only. Value-returning or chained method calls are later
  `.2.3.5` work.
