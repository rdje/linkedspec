---
id: perl-actionir-fallback-boundary-audit
title: Perl ActionIR fallback boundary after AST migration audit
answers:
  - "what raw fallback remains after Perl ActionIR AST migration"
  - "which fallback paths are compatibility debt"
  - "do malformed covered helpers still leak to raw Perl"
  - "where should user function calls hook into ActionIR"
  - "does unknown user_fn lower as a host call today"
  - "does return user_fn still leak as a host call"
  - "is all-bare push A B a scalar append"
  - "does bootstrap currently implement fn grammar"
  - "what did PERL-ACTIONIR-AST-MIGRATION.5.4 prove"
  - "what did PERL-ACTIONIR-AST-MIGRATION.5.1 classify"
  - "what did PERL-ACTIONIR-AST-MIGRATION.5.3.2 change"
  - "does the function registry make registered calls executable"
  - "which user function calls remain raw or unresolved after .4.2.2"
date: 2026-07-01
status: current
tags: [actionir, ast, perl-reference, fallback, user-functions, diagnostics]
evidence: "PERL-ACTIONIR-AST-MIGRATION.5.1 used TOOLBOX call_spec_handler_subst, return_descriptor, and ActionIR AST parser probes plus code reads of CanonicalEvents, RewritePipeline, RuleIR::EmitContext, MethodLowering, and ActionIR::AST::Parser. Malformed covered helpers such as substr/count report unresolved-helper metadata with raw_perl_dependency_count == 0. Retired helpers and non-DSL host-shaped statements remain RAW_PERL compatibility debt. all-bare push(A,B) remains child-call aggregation. PERL-ACTIONIR-AST-MIGRATION.5.3.2 changed return/value-position unknown typed calls/chains such as return(user_fn(\"x\")) and return(user_fn(\"x\").trim()) from generated host calls into unresolved-helper diagnostics; unregistered standalone user_fn(\"x\") / user_fn(\"x\").trim() remain raw compatibility debt. PERL-ACTIONIR-AST-MIGRATION.5.4 proved bootstrap has no current first-class fn grammar/node support and locked permanent fn grammar ownership to specs/spec.spec. SPEC-FORMAT-TERSE.4.2.2 makes exact-arity registered value-position calls executable; SPEC-FORMAT-TERSE.4.2.3 makes exact-arity registered standalone calls/chains canonical VALUE_DROP with zero raw fallback."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'for my $s (q{return(substr(\"abc\"))}, q{return(count(1,2))}, q{return(user_fn(\"x\"))}, q{return(user_fn(\"x\").trim())}, q{user_fn(\"x\")}, q{user_fn(\"x\").trim()}, q{return_array(foo)}, q{my $x = 1}, q{push(A,B)}) { my $d=LinkedSpec::Get(\\qq{Top::\\n /x/ -> Done { $s }\\n\\nDone::\\n /x/\\n}, return_descriptor=>1); my $m=$d->{spec}{Top}{meta}{action_rewriter}; print \"$s raw=$m->{raw_perl_dependency_count} unresolved=$m->{unresolved_helper_count} ready=$m->{language_agnostic_action_ir_ready}\\n\" } my $spec = q{fn normalize(value) { return(trim(value)) }\\nTop::\\n /x/ -> Done { return(normalize(\" x \")) }\\nDone::\\n /x/\\n}; my $d=LinkedSpec::Get(\\$spec, return_descriptor=>1); my $m=$d->{spec}{Top}{meta}{action_rewriter}; print \"registered normalize raw=$m->{raw_perl_dependency_count} unresolved=$m->{unresolved_helper_count} ready=$m->{language_agnostic_action_ir_ready}\\n\"' && rg -n 'function_definition:|-> function_definition' specs/spec.spec && ! rg -n '\\bfn\\s+[A-Za-z_][A-Za-z0-9_]*\\s*\\(|function_definition|user_function_definition|FN_DEF' perl/LinkedSpec/BootstrapSpec.pm perl/LinkedSpec/BootstrapSpec/Core.pm"
---

After `PERL-ACTIONIR-AST-MIGRATION.5.1`, the remaining Perl ActionIR fallback boundary is classified before
code.

Malformed helper forms already covered by the typed AST path, such as unsupported `substr(...)` or `count(...)`
arities, use `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name>` and descriptor unresolved-helper metadata. They do
not increment `raw_perl_dependency_count`.

Retired helpers such as `return_array(...)` / `return_a(...)` and non-DSL host-shaped statements such as raw
`my $x = 1` or bare `print "x"` remain explicit `RAW_PERL` compatibility debt. Narrow return payload
compatibility shapes remain fenced too.

The all-bare `push(A,B)` form remains the existing child-call aggregation convention, not scalar append. Use
`items += value`, an unambiguous literal/value `push(...)`, or `push_value(...)` for append intent.

Unknown call names are different. The AST parser already represents `user_fn("x")` as a `call` node and
`user_fn("x").trim()` as a `fluent_chain` with a `call` receiver. After
`PERL-ACTIONIR-AST-MIGRATION.5.3.2`, return/value-position forms such as
`return(user_fn("x"))` and `return(user_fn("x").trim())` no longer lower as generated host calls. They use the
existing `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:user_fn` sentinel and descriptor unresolved-helper metadata.
Unregistered standalone `user_fn("x")` and `user_fn("x").trim()` still remain raw compatibility debt. After
`SPEC-FORMAT-TERSE.4.2.2`, an exact-arity registered function call such as
`return(normalize(" x "))` executes in value position with zero raw fallback/unresolved helpers; wrong-arity
registered calls remain unresolved-helper diagnostics. After `.4.2.3`, standalone registered calls/chains such as
`normalize(" x ")` and `normalize(" X ").lowercase()` lower as canonical `VALUE_DROP`.

`PERL-ACTIONIR-AST-MIGRATION.5.4` locked `specs/spec.spec` as the permanent
function-definition grammar surface. It also proved bootstrap has no current first-class
`fn name(...)` grammar pattern or named function-definition node support; current
`fn`-shaped text parses only as generic unsupported paragraph content. `.4.2.1` later
added the active self-hosted `function_definition` rule and the temporary Perl registry
bridge without changing the bootstrap parser. `.4.2.2` threads that registry into
RuleIR/ActionIR lowering for value-call execution.
