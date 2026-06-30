---
id: terse-attached-switch-split-ground-truth
title: Attached switch/case/default split is closed: Perl separator lock and Rust parser/runtime parity landed
answers:
  - "what owns attached switch/case/default"
  - "why was SPEC-FORMAT-TERSE.2.2.5 split"
  - "what is the current Perl attached switch behavior"
  - "does Rust support attached switch statement blocks"
  - "what is the separator issue for attached switch case/default"
  - "is Perl attached switch case default locked"
date: 2026-06-30
status: current
tags: [spec-format-terse, control-flow, switch, actionir, rust-parity]
evidence: "SPEC-FORMAT-TERSE.2.2.5/.2.2.5.1/.2.2.5.2 probes and implementation, 2026-06-30. The Perl reference lock landed in `.2.2.5.1`: `StatementSplit::Core` splits complete attached `case(...) { ... }` / `default { ... }` branch bodies before same-line branch continuations, compact adjacent switch probes report ready=1/raw=0/unresolved=0, generated lowering has no host-shaped `case(...)` or `default { ... }` residue, runtime probes cover first case/later case/default, and same-line ordinary statements after the final switch still require `;`. Rust parity landed in `.2.2.5.2`: `CodeBlock::parse` recognizes attached `switch(expr) { case(value) { ... } default { ... } }`, normalizes to `switch`/`case`/`default`/`endswitch`, and `Engine` gates branches with `StatementSwitchFrame` in lifecycle and expression-valued block evaluation. Focused Rust parser/runtime/lazy-switch tests pass, and oracle fixture `terse_2_2_5_2_attached_switch_blocks` makes the corpus 38 fixtures."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'for my $stmt (q{switch(\"a\") { case(\"a\") { return(\"hit\") } default { return(\"miss\") } }}, q{switch(\"a\") { case(\"a\") { return(\"hit\") } case(\"a\") { return(\"second\") } default { return(\"miss\") } }}) { my $spec=qq{Top::\\n /x/ -> Done { $stmt }\\n\\nDone::\\n /x/\\n}; my $d=LinkedSpec::Get(\\$spec, return_descriptor=>1); my $m=$d->{spec}{Top}{meta}{action_rewriter}; my $lower=LinkedSpec::call_spec_handler_subst(\"Top\", $stmt); $lower =~ s/\\n/\\\\n/g; print qq{$stmt => ready=$m->{language_agnostic_action_ir_ready} raw=$m->{raw_perl_dependency_count} unresolved=$m->{unresolved_helper_count}\\n$lower\\n}; }' && cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-core attached_switch && cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_2_2_5_2 && cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle"
---

`SPEC-FORMAT-TERSE.2.2.5` is a container, not an implementation leaf.

Perl already had the control-flow lowerers for `switch`, `case`, `default`, `endcase`, and `endswitch`,
including attached-block branches. The missing Perl reference boundary was adjacent branch splitting:
`case(...) { ... } case(...) { ... } default { ... }` had to become separate DSL branch statements instead of
host-like labels or unresolved helper residue. That is now landed in `.2.2.5.1`.

The accepted Perl reference behavior is:

- Adjacent attached `case/default` branch blocks lower without raw fallback or unresolved helper residue.
- Generated handlers do not retain host-shaped `case(...)` or `default { ... }` branch text.
- Runtime selection is first-match with default fallback.
- A same-line ordinary statement after the final attached `switch` still requires an explicit semicolon.

Rust has the lazy value-form helper family:

```text
switch(expr, case(value, result), default(result))
```

Rust now also parses attached statement blocks such as:

```text
switch(expr) {
  case(value) { return("hit") }
  default { return("miss") }
}
```

The parser lowers those blocks to statement controls and the runtime gates them with the same first-match/default
behavior. The lazy value-form helper stays separate and unchanged.
