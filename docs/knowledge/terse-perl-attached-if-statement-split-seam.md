---
id: terse-perl-attached-if-statement-split-seam
title: Perl attached-block if lowers without raw fallback; the former compact same-line elseif/else splitter gap was closed in SPEC-FORMAT-TERSE.2.2.2
answers:
  - "why does same-line attached if else remain raw on Perl"
  - "do newline-separated attached if branches lower through ActionIR"
  - "where is the Perl attached if implementation seam"
  - "what does SPEC-FORMAT-TERSE.2.2.2 own"
  - "does compact attached if elseif else work on Perl now"
date: 2026-06-30
status: current
tags: [spec-format-terse, control-flow, actionir, statement-split, perl-reference]
evidence: "SPEC-FORMAT-TERSE.2.2.2 implementation. `StatementSplit/Core.pm` now splits a complete attached `if`/`elseif` branch body before same-line attached `elseif(...) { ... }` or bare `else { ... }` continuations. `call_spec_handler_subst`, descriptor metadata, and runtime probes show compact `if(false) { return(\"bad\") } elseif(true) { return(\"yes\") } else { return(\"no\") }` lowers with `raw_perl_dependency_count=0`, `unresolved_helper_count=0`, and returns `\"yes\"`. The change deliberately leaves older same-line no-semicolon marker-helper blockers intact. `Scanner/FlowRules.pm` captures optional attached branch blocks, `ControlFlow.pm` lowers individual attached `if`/`elseif`/`else` statements with implicit-close state, and `RewritePipeline.pm` keeps closures open across `elseif_flow`/`else_flow`."
reverify: "perl -Iperl -MJSON::PP -MLinkedSpec -e 'my $stmt=q{if(false) { return(\"bad\") } elseif(true) { return(\"yes\") } else { return(\"no\") }}; my $d=LinkedSpec::Get(\\qq{Top::\\n /x/ -> Done { $stmt }\\n\\nDone::\\n /x/\\n}, return_descriptor=>1); my $m=$d->{spec}{Top}{meta}{action_rewriter}; print qq{ready=$m->{language_agnostic_action_ir_ready} raw=$m->{raw_perl_dependency_count} unresolved=$m->{unresolved_helper_count}\\n}; my $p=LinkedSpec::Get(\\qq{Top::\\n /x/ -> Done { $stmt }\\n\\nDone::\\n /x/\\n}, top_rule=>q{Top}, parse_mode=>q{consume}); my $in=q{xx}; print JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\\$in)), qq{\\n};' && prove -q -Iperl t/phase0_regression.t"
---

`SPEC-FORMAT-TERSE.2.2.2` did not need to invent a new attached-if lowerer for Perl. The reference backend
already had most of the pieces:

- `Scanner::FlowRules` recognizes `if(...) { ... }`, `elseif(...) { ... }`, and `else { ... }` as flow events.
- `ControlFlow` lowers individual attached branch statements and marks them for implicit closure instead of
  requiring an explicit `endif()`.
- `RewritePipeline` treats `elseif_flow` and `else_flow` as continuations, so it does not close the attached
  `if` before those clauses.

The remaining gap was compact same-line branch continuation. `.2.2.2` closes it in `StatementSplit::Core` by
splitting a complete attached `if`/`elseif` branch body before same-line attached `elseif(...) { ... }` and
bare `else { ... }`. That narrow split does not make plain same-line marker-helper chains into implicit
statements.
