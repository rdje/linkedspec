---
id: terse-attached-switch-split-ground-truth
title: Attached switch/case/default is split before code: Perl needs a separator/source lock, then Rust needs attached statement-block parity
answers:
  - "what owns attached switch/case/default"
  - "why was SPEC-FORMAT-TERSE.2.2.5 split"
  - "what is the current Perl attached switch behavior"
  - "does Rust support attached switch statement blocks"
  - "what is the separator issue for attached switch case/default"
date: 2026-06-30
status: current
tags: [spec-format-terse, control-flow, switch, actionir, rust-parity]
evidence: "SPEC-FORMAT-TERSE.2.2.5 ownership probes, 2026-06-30. Perl `switch(\"a\") { case(\"a\") { return(\"hit\") } default { return(\"miss\") } }` reports ready=1/raw=0/unresolved=0 and can return hit/miss, but lowering still needs a source lock because branch continuations can leave host-like `default { ... }` residue. Adjacent `case` blocks without an explicit separator are not ready: the two-case probe reports ready=0/unresolved_helper_count=1 for the second `case` and can generate invalid Perl. Adding explicit separators changes the split behavior, proving the seam is statement splitting / attached-switch body lowering. Rust code-read shows lazy value-form `switch(expr, case(...), default(...))` in `Engine::call_helper` with existing cond_switch tests, but `CodeBlock::parse` attached-branch parsing only covers `if`/`when`, so attached switch statement blocks need a Rust parity leaf after the Perl reference contract is locked."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'for my $stmt (q{switch(\"a\") { case(\"a\") { return(\"hit\") } default { return(\"miss\") } }}, q{switch(\"a\") { case(\"a\") { return(\"hit\") } case(\"a\") { return(\"second\") } default { return(\"miss\") } }}) { my $spec=qq{Top::\\n /x/ -> Done { $stmt }\\n\\nDone::\\n /x/\\n}; my $d=LinkedSpec::Get(\\$spec, return_descriptor=>1); my $m=$d->{spec}{Top}{meta}{action_rewriter}; my $lower=LinkedSpec::call_spec_handler_subst(\"Top\", $stmt); $lower =~ s/\\n/\\\\n/g; print qq{$stmt => ready=$m->{language_agnostic_action_ir_ready} raw=$m->{raw_perl_dependency_count} unresolved=$m->{unresolved_helper_count}\\n$lower\\n}; }' && rg -n 'try_parse_attached_if_chain|switch|case|default' rust/linkedspec-core/src/expr.rs rust/linkedspec-runtime/src/engine.rs"
---

`SPEC-FORMAT-TERSE.2.2.5` is a container, not an implementation leaf.

Perl already has the control-flow lowerers for `switch`, `case`, `default`, `endcase`, and `endswitch`, including
attached-block branches. The remaining Perl reference risk is the boundary between adjacent branch blocks:
`case(...) { ... } case(...) { ... } default { ... }` must be split and lowered as canonical switch branches, not
left as host-like labels or unresolved helper residue. That is `.2.2.5.1`.

Rust already has the lazy value-form helper family:

```text
switch(expr, case(value, result), default(result))
```

It does not yet parse attached statement blocks such as:

```text
switch(expr) {
  case(value) { return("hit") }
  default { return("miss") }
}
```

Rust parity should follow after `.2.2.5.1` locks the reference contract. That is `.2.2.5.2`.
