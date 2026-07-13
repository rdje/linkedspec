---
id: terse-fluent-lifecycle-composability-split
title: SPEC-FORMAT-TERSE.2.3 split for fluent block chains, lifecycle values, composability, and method chaining
answers:
  - "how should SPEC-FORMAT-TERSE.2.3 be split"
  - "does Perl support fluent when otherwise block chains"
  - "does .when(cond) { } .otherwise { } work on the Perl reference"
  - "does .when(cond) { } otherwise { } work on the Perl reference"
  - "does no-dot otherwise after a fluent when block work"
  - "does Rust support fluent block chains on action edges"
  - "does Rust support fluent when otherwise block chains on action edges"
  - "does Rust support fluent when otherwise block chains on lifecycle markers"
  - "are lifecycle blocks value returning"
  - "are array end mutation methods value returning"
  - "what is the next SPEC-FORMAT-TERSE.2.3 leaf"
date: 2026-06-30
status: current
tags: [spec-format-terse, fluent, lifecycle, composability, rust-parity, mdbook]
evidence: "SPEC-FORMAT-TERSE.2.3/.2.3.1/.2.3.3.2 lock fluent attached control behavior and record the then-current statement-only array-end boundary. FUTURE-PARITY-BACKLOG.12.1.1-.6 later supersede only that array-end result boundary: all five backends return updated arrays and admit compatible continuations. The lifecycle/control findings remain unchanged."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'for my $stmt (q{Done.when(false) { return(\"bad\") }.otherwise { return(\"fallback\") }}, q{Done.when(false) { return(\"bad\") } otherwise { return(\"fallback\") }}, q{I.when(false) { set(value,\"yes\") }.otherwise { set(value,\"no\") } LX { return(value) }}, q{I.when(false) { set(value,\"yes\") } otherwise { set(value,\"no\") } LX { return(value) }}) { my $spec = $stmt =~ /^I/ ? qq{Top::\\n /x/ $stmt\\n} : qq{Top::\\n /x/ -> $stmt\\n\\nDone::\\n /x/\\n}; my $d=LinkedSpec::Get(\\$spec, return_descriptor=>1); my $m=$d->{spec}{Top}{meta}{action_rewriter}; my $p=LinkedSpec::Get(\\$spec, top_rule=>\"Top\", parse_mode=>\"consume\"); my $input=\"x\"; print qq{ready=$m->{language_agnostic_action_ir_ready} raw=$m->{raw_perl_dependency_count} fallback=$m->{raw_perl_fallback_count} unresolved=$m->{unresolved_helper_count} result=}.JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\\$input)).qq{\\n}; }' && cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml attached_fluent && cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_3_2"
---

`SPEC-FORMAT-TERSE.2.3` is a container, not one implementation leaf.

Accepted split:

1. `.2.3.1` Perl reference fluent block-chain contract lock.
2. `.2.3.2` lifecycle block final-value dropping and explicit `return(expr)` rule-channel semantics.
3. `.2.3.3` Rust fluent block-chain/action-edge parity, coordinated with `RUST-PARITY.7.5.3`.
4. `.2.3.4` full nested composability audit and gap split.
5. `.2.3.5` return-type method chaining design and first implementation split.

Current ground truth:

- Perl accepts exact fluent attached control-flow chains on action and lifecycle surfaces, including dotted and
  no-dot `otherwise` fallback continuations after a false `when` branch.
- Rust supports attached fluent `when/otherwise` block payloads on action-edge and lifecycle-marker surfaces,
  but not every compact lifecycle/body fluent continuation.
- Lifecycle blocks already parse and run, but their final expression value is not a block return value; explicit
  `return(expr)` has surrounding rule/action return semantics and needs a focused lock.
- Round 1 array receiver-dot mutations were statement-only. Uniform binding later makes named end mutations return
  updated arrays and feed compatible continuations; see [[uniform-binding-array-end-result-supersession]].
