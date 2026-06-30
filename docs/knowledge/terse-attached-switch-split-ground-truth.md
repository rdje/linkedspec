---
id: terse-attached-switch-split-ground-truth
title: Attached switch/case/default split: Perl separator/source lock landed, Rust attached statement-block parity remains
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
evidence: "SPEC-FORMAT-TERSE.2.2.5/.2.2.5.1 probes and implementation, 2026-06-30. The split finding remains: Rust has lazy value-form `switch(expr, case(...), default(...))` in `Engine::call_helper`, but no attached statement-block parser. The Perl reference lock has now landed in `.2.2.5.1`: `StatementSplit::Core` splits complete attached `case(...) { ... }` / `default { ... }` branch bodies before same-line branch continuations, compact adjacent switch probes report ready=1/raw=0/unresolved=0, generated lowering has no host-shaped `case(...)` or `default { ... }` residue, runtime probes cover first case/later case/default, and same-line ordinary statements after the final switch still require `;`."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'for my $stmt (q{switch(\"a\") { case(\"a\") { return(\"hit\") } default { return(\"miss\") } }}, q{switch(\"a\") { case(\"a\") { return(\"hit\") } case(\"a\") { return(\"second\") } default { return(\"miss\") } }}) { my $spec=qq{Top::\\n /x/ -> Done { $stmt }\\n\\nDone::\\n /x/\\n}; my $d=LinkedSpec::Get(\\$spec, return_descriptor=>1); my $m=$d->{spec}{Top}{meta}{action_rewriter}; my $lower=LinkedSpec::call_spec_handler_subst(\"Top\", $stmt); $lower =~ s/\\n/\\\\n/g; print qq{$stmt => ready=$m->{language_agnostic_action_ir_ready} raw=$m->{raw_perl_dependency_count} unresolved=$m->{unresolved_helper_count}\\n$lower\\n}; }' && rg -n 'try_parse_attached_if_chain|switch|case|default' rust/linkedspec-core/src/expr.rs rust/linkedspec-runtime/src/engine.rs"
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

Rust parity now follows the locked `.2.2.5.1` Perl reference contract. That is `.2.2.5.2`.
