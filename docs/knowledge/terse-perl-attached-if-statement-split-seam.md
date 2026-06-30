---
id: terse-perl-attached-if-statement-split-seam
title: Perl attached-block if already lowers when branch clauses are separate statements; compact same-line elseif/else chains are blocked by statement splitting
answers:
  - "why does same-line attached if else remain raw on Perl"
  - "do newline-separated attached if branches lower through ActionIR"
  - "where is the Perl attached if implementation seam"
  - "what does SPEC-FORMAT-TERSE.2.2.2 own"
date: 2026-06-30
status: current
tags: [spec-format-terse, control-flow, actionir, statement-split, perl-reference]
evidence: "SPEC-FORMAT-TERSE.2.2.2 ownership probes. `call_spec_handler_subst` and descriptor metadata show `if(true) { return(\"yes\") }\\nelse { return(\"no\") }` and newline-separated `elseif` chains lower with `raw_perl_dependency_count=0`, while compact `if(false) { return(\"bad\") } elseif(true) { return(\"yes\") } else { return(\"no\") }` remains a single RAW_PERL statement. Code-read shows `Scanner/FlowRules.pm` captures optional attached branch blocks, `ControlFlow.pm` lowers individual attached `if`/`elseif`/`else` statements with implicit-close state, and `RewritePipeline.pm` keeps closures open across `elseif_flow`/`else_flow`. The missing seam is `StatementSplit/Core.pm`: it treats a complete attached block as one statement only when the tail after the closing brace is empty, so same-line `} elseif/else {` is not split."
reverify: "perl -Iperl -MLinkedSpec -e 'my @stmts=(qq{if(true) { return(\"yes\") }\\nelse { return(\"no\") }}, qq{if(false) { return(\"bad\") }\\nelseif(true) { return(\"yes\") }\\nelse { return(\"no\") }}, q{if(false) { return(\"bad\") } elseif(true) { return(\"yes\") } else { return(\"no\") }}); for my $stmt (@stmts) { my $d=LinkedSpec::Get(\\qq{Top::\\n /x/ -> Done { $stmt }\\n\\nDone::\\n /x/\\n}, return_descriptor=>1); my $m=$d->{spec}{Top}{meta}{action_rewriter}; print qq{$stmt => ready=$m->{language_agnostic_action_ir_ready} raw=$m->{raw_perl_dependency_count} unresolved=$m->{unresolved_helper_count}\\n}; }' && rg -n '_looks_like_complete_method_statement|_should_split_on_method_boundary|_lower_if_flow_statement|_statement_continues_attached_if_flow' perl/LinkedSpec/ActionIR"
---

`SPEC-FORMAT-TERSE.2.2.2` does not need to invent a new attached-if lowerer for Perl. The reference backend
already has most of the pieces:

- `Scanner::FlowRules` recognizes `if(...) { ... }`, `elseif(...) { ... }`, and `else { ... }` as flow events.
- `ControlFlow` lowers individual attached branch statements and marks them for implicit closure instead of
  requiring an explicit `endif()`.
- `RewritePipeline` treats `elseif_flow` and `else_flow` as continuations, so it does not close the attached
  `if` before those clauses.

The remaining gap is compact same-line branch continuation. Newline-separated clauses are separate statements
and already lower without raw fallback. Same-line `} elseif/else {` text stays inside one statement, so the
rewrite pipeline sees nested flow events inside an ambiguous raw statement and preserves the raw statement.
