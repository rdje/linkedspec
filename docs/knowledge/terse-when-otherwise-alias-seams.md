---
id: terse-when-otherwise-alias-seams
title: SPEC-FORMAT-TERSE.2.2.4 implements when/otherwise as aliases over attached if/else, not host Perl when
answers:
  - "what does SPEC-FORMAT-TERSE.2.2.4 own"
  - "where should when otherwise be implemented"
  - "why is Perl when not acceptable for LinkedSpec when otherwise"
  - "does when otherwise lower through ActionIR today"
  - "does Rust need a new runtime for when otherwise"
date: 2026-06-30
status: current
tags: [spec-format-terse, control-flow, actionir, rust-parity, aliases]
evidence: "SPEC-FORMAT-TERSE.2.2.4 implementation probes. Before the slice, `LinkedSpec::call_spec_handler_subst(\"Top\", q{when(true) { return(\"yes\") } otherwise { return(\"no\") }})` returned the full raw statement unchanged, descriptor metadata was `ready=0 raw=1 unresolved=2`, generated source kept host Perl `when(...)`, and runtime returned `\"no\"` for a true condition. The implementation adds aliases at Perl `StatementSplit::Core`, scanner/contract patterns, and `ControlFlow` dispatch; the same probe now lowers to `if (JSON::PP::true) { return \"yes\" } else { return \"no\" }`, descriptor metadata is `raw=0 unresolved=0`, generated source has no `when`/`otherwise` host keywords, and runtime returns `\"yes\"`. Rust `CodeBlock::parse` now starts attached chains on `when`, accepts `otherwise`, and emits existing `if`/`else`/`endif` statements; the Rust runtime still uses the existing branch engine."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $stmt=q{when(true) { return(\"yes\") } otherwise { return(\"no\") }}; print LinkedSpec::call_spec_handler_subst(q{Top}, $stmt), qq{\\n}; my $spec=qq{Top::\\n /x/ -> Done { $stmt }\\n\\nDone::\\n /x/\\n}; my $d=LinkedSpec::Get(\\$spec, return_descriptor=>1); my $m=$d->{spec}{Top}{meta}{action_rewriter}; print qq{ready=$m->{language_agnostic_action_ir_ready} raw=$m->{raw_perl_dependency_count} unresolved=$m->{unresolved_helper_count}\\n}; my $src=q{}; LinkedSpec::Get(\\$spec, generate_only=>1, dump_parser_source=>1, parser_source_ref=>\\$src); print qq{aliases_in_source=}.(($src =~ /\\b(?:when|otherwise)\\b/) ? 1 : 0).qq{\\n}; my $p=LinkedSpec::Get(\\$spec, top_rule=>q{Top}, parse_mode=>q{consume}); my $in=q{x}; print JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\\$in)), qq{\\n};' && cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-core when_otherwise && cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_2_2_4"
---

`SPEC-FORMAT-TERSE.2.2.4` does not preserve or expose Perl's `given/when` semantics. The adopted DSL
contract is a readable one-condition alias for the portable attached `if/else` form:

```text
when(cond) { ... } otherwise { ... }
```

The implementation normalizes to existing control-flow concepts:

- `when(cond) { body }` is `if(cond) { body }`.
- `otherwise { body }` is `else { body }`.
- The implicit close remains the attached-if close, equivalent to `endif`.

On Perl, the aliases live at the statement-splitting, scanner/contract, and `ControlFlow` dispatch seams that
already own attached `if/else`. On Rust, the attached-if parser starts on `when`, accepts `otherwise`, and emits
the existing `if`/`else`/`endif` statements. The Rust runtime does not need a new branch engine.
