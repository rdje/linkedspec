---
id: terse-when-otherwise-alias-seams
title: SPEC-FORMAT-TERSE.2.2.4 owns when/otherwise as aliases over attached if/else, not host Perl when
answers:
  - "what does SPEC-FORMAT-TERSE.2.2.4 own"
  - "where should when otherwise be implemented"
  - "why is Perl when not acceptable for LinkedSpec when otherwise"
  - "does when otherwise lower through ActionIR today"
  - "does Rust need a new runtime for when otherwise"
date: 2026-06-30
status: current
tags: [spec-format-terse, control-flow, actionir, rust-parity, aliases]
evidence: "SPEC-FORMAT-TERSE.2.2.4 ownership probes. `LinkedSpec::call_spec_handler_subst(\"Top\", q{when(true) { return(\"yes\") } otherwise { return(\"no\") }})` returns the full raw statement unchanged, while descriptor metadata for the same spec is `ready=0 raw=1 unresolved=2` with canonical nodes `[\"RAW_PERL\",\"RETURN\"]`. `dump_parser_source` shows raw `when(true) { return(\"yes\") } otherwise { return(\"no\") }` in the generated Top handler and the compiler emits `when is experimental at LinkedSpec::generated_handler:Top:_default line 31`; runtime for input `x` returns `\"no\"` despite `when(true)`, proving host Perl `when` is not the DSL contract. Code-read: Perl flow scanners/contracts/control-flow dispatch only recognize `if`/`i`/`elseif`/`elif`/`else`; `StatementSplit::Core` attached-if splitting only sees `if|i|elseif|elif` starts and `elseif|elif|else` continuations. Rust `CodeBlock::parse` starts attached chains only on `if`, continues only on `elseif`/`else`, and the runtime already gates normalized `if`/`elseif`/`else`/`endif` statements."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $stmt=q{when(true) { return(\"yes\") } otherwise { return(\"no\") }}; print LinkedSpec::call_spec_handler_subst(q{Top}, $stmt), qq{\\n}; my $spec=qq{Top::\\n /x/ -> Done { $stmt }\\n\\nDone::\\n /x/\\n}; my $d=LinkedSpec::Get(\\$spec, return_descriptor=>1); my $m=$d->{spec}{Top}{meta}{action_rewriter}; print qq{ready=$m->{language_agnostic_action_ir_ready} raw=$m->{raw_perl_dependency_count} unresolved=$m->{unresolved_helper_count}\\n}; my $p=LinkedSpec::Get(\\$spec, top_rule=>q{Top}, parse_mode=>q{consume}); my $in=q{x}; print JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\\$in)), qq{\\n};' && rg -n 'when|otherwise|try_parse_attached_if_chain|handle_statement_if_control' perl/LinkedSpec/ActionIR rust/linkedspec-core/src/expr.rs rust/linkedspec-runtime/src/engine.rs"
---

`SPEC-FORMAT-TERSE.2.2.4` should not preserve or expose Perl's `given/when` semantics. The adopted DSL
contract is a readable one-condition alias for the already-portable attached `if/else` form:

```text
when(cond) { ... } otherwise { ... }
```

The implementation should normalize to existing control-flow concepts:

- `when(cond) { body }` is `if(cond) { body }`.
- `otherwise { body }` is `else { body }`.
- The implicit close remains the attached-if close, equivalent to `endif`.

On Perl, this means adding aliases at the statement-splitting, scanner/contract, and `ControlFlow` dispatch
seams that already own attached `if/else`. On Rust, this means teaching the attached-if parser to start on
`when`, continue on `otherwise`, and emit the existing `if`/`else`/`endif` statements. The Rust runtime should
not need a new branch engine.
