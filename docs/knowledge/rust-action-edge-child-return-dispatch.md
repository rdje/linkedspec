---
id: rust-action-edge-child-return-dispatch
title: "Rust action-edge child calls must reuse the already matched edge child return; passive terminal children are not re-searched after parent edge consumption"
answers:
  - "why did ebnf duplicate rule headers in Rust"
  - "why did ebnf drop token payloads in Rust"
  - "why did portmap concatenation return an empty multi node in Rust"
  - "how should Rust execute call(child) inside an action-edge block"
  - "how should Rust execute push(child,target) after an action edge"
  - "what does push(child,index) mean in Rust action-edge blocks"
  - "should an action-edge child be re-searched after the parent edge matched it"
  - "what is a passive terminal child in the Rust runtime"
  - "why should whitespace/comment/comma child rules not execute after parent edge dispatch"
  - "which leaf fixed ebnf_expression_rules and ebnf_logging_annotation"
  - "which leaf fixed portmap_concatenation"
date: 2026-09-07
status: current
tags: [rust, runtime, action-edge, ebnf, portmap, oracle, RUST-PARITY]
evidence: "RUST-PARITY.7.3.4.3 used the LinkedSpec toolbox and Perl generated-source probes to confirm that an action-edge parent regex has already consumed the matched child edge. Generated Perl handlers call non-passive child handlers for the matched edge result, but passive terminal handlers with no lifecycle/dispatch body only expose that entry match and return undef. Rust now records scoped action-edge child results in RuntimeContext, routes call(child), push(child), push(child,target), and child-index push statement forms through that scoped result, skips passive terminal re-search, and keeps scalar/aggregate assignment boundaries intact. Focused Rust tests rust_parity_7_3_4_3_* pass; tools/gen_oracle_corpus.pl includes portmap_concatenation, ebnf_expression_rules, and ebnf_logging_annotation; Rust corpus_oracle passes 77 fixtures."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime rust_parity_7_3_4_3 -- --nocapture && perl -c -Iperl tools/gen_oracle_corpus.pl && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test corpus_oracle -- --nocapture"
---

# Rust Action-Edge Child Return Dispatch

`RUST-PARITY.7.3.4.3` closed the `ebnf` payload and `portmap` concatenation branch.

The runtime rule is: once a parent action-edge regex matches a child edge, child-call
forms inside the attached action surface must read that edge match's child return instead
of launching a fresh child search from the already advanced parent cursor. This applies to
`call(child)`, `push(child)`, `push(child, target)`, and `push(child, target, index)` /
`push(child, index)` statement forms.

Passive terminal children are the exception that proves the rule. A child rule with no
lifecycle code and no action/blind dispatch body is a body-less terminal reader in the
generated Perl shape: the parent edge regex has already consumed it, and the child handler
returns `undef` rather than scanning the same token again. Rust mirrors that by skipping
re-execution for passive terminal children after parent-edge consumption.

The shipped oracle locks are:

- `portmap_concatenation` — `{foo bar[2]}` keeps the `?bare` and `?bit` child payloads under `?concatenation`.
- `ebnf_expression_rules` — rule headers are not duplicated and body tokens are preserved.
- `ebnf_logging_annotation` — `push(quoted_string, 1)` preserves the indexed logging annotation payload.

Related: [[rust-simple-spec-structural-owners]], [[rust-perl-output-oracle]].

## September 7 native action-loop reading

`SESSION-STARTUP-READING.3.3.17` reads engine lines 3395–4887. A block with an
eager child call or `retv` dependency pre-dispatches once and installs a scoped
child result around block execution; that scope pops before propagating its Result.
A block without those dependencies runs before child dispatch, except the explicit
observation/self-edge branches. The observation detector recognizes the direct scalar
assignment shape; this is not a claim of unrestricted transitive observation analysis.

The dependency walkers recurse through current assignments, access segments,
aggregates, receiver callbacks and fluent arguments. Callable literal construction
is inert and excluded; a contextual codeblock argument's executable body is inspected.
Explicit repeated action returns are collected per hit while lifecycle returns retain
whole-rule authority. Fresh repeated-result proof passes 8 modes/10 specials/8 complete/
54 mutations; callable neutral proof passes 7 literals/11 calls/23 mutations.
The historical native/oracle counts above are not rerun by this reading checkpoint.
