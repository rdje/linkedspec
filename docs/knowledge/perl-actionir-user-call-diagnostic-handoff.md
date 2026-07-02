---
id: perl-actionir-user-call-diagnostic-handoff
title: Perl ActionIR unknown user-call values diagnose before function registry resolution
answers:
  - "what happens to return user_fn now"
  - "does return user_fn still become a host call"
  - "do unknown typed calls leak as generated Perl"
  - "are standalone unknown user function calls dropped"
  - "which leaf prepared user-function calls for AST resolution"
date: 2026-07-01
status: current
tags: [actionir, ast, perl-reference, user-functions, diagnostics]
evidence: "PERL-ACTIONIR-AST-MIGRATION.5.3.2 changed MethodLowering so return/value-position unknown typed call and fluent_chain nodes such as return(user_fn(\"x\")) and return(user_fn(\"x\").trim()) lower to LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:user_fn instead of generated host-language calls. Existing DSL/compatibility helper names are fenced before unknown-call diagnostics. SPEC-FORMAT-TERSE.4.2.3 later added registry-aware standalone discard for registered calls/chains; unregistered standalone user_fn(\"x\") and user_fn(\"x\").trim() remain raw compatibility debt."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'for my $s (q{return(user_fn(\"x\"))}, q{return(user_fn(\"x\").trim())}, q{user_fn(\"x\")}, q{user_fn(\"x\").trim()}, q{return(items.push_back(\"a\"))}) { my $out=LinkedSpec::call_spec_handler_subst(q{Top}, $s); $out =~ s/\\n/ /g; print \"$s => $out\\n\" }'"
---

`PERL-ACTIONIR-AST-MIGRATION.5.3.2` is a diagnostic handoff, not the function registry.

The fixed leak was return/value-position host-call emission. `return(user_fn("x"))` and
`return(user_fn("x").trim())` now lower to the existing unresolved-helper sentinel:
`LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:user_fn`. Descriptor metadata therefore records
`unresolved_helper_count` and marks the rule not language-agnostic-ready instead of
pretending the generated Perl host call is portable.

Standalone unknown function-shaped statements were intentionally unchanged in this leaf.
`SPEC-FORMAT-TERSE.4.2.3` later implements standalone result discard only for calls that
the actual function registry can prove are registered user functions. Unregistered
standalone `user_fn("x")` and `user_fn("x").trim()` still remain raw, preserving the
compatibility boundary for host-shaped statements.

Known DSL and compatibility helper names are fenced before the unknown-call diagnostic.
That preserves existing behavior for declaration aliases, source-boundary helpers,
retired return helpers, internal trace calls, and statement-only array mutation methods
such as `push_back`.
