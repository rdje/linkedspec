---
id: perl-final-codeblock-signature-declaration-gap
title: "Perl's former contextual final-codeblock declaration gap"
answers:
  - "what gap blocked Perl final codeblock normalization before ADR 0032"
  - "why was arity insufficient for contextual codeblocks"
date: 2026-07-12
status: resolved
tags: [perl, codeblock, callable-signature, trailing-block, design-gap]
evidence: "FUTURE-PARITY-BACKLOG.11.3.3.0/.1; LinkedSpec::call_spec_handler_subst probes; exact ActionIR JSON probes; LinkedSpec return_descriptor function record; specs/user_function_definition.spec; perl/LinkedSpec/UserFunctionRegistry.pm; perl/LinkedSpec/ActionIR/AST/Parser.pm; perl/LinkedSpec/ActionIR/MethodLowering.pm; ADR 0031; ADR 0032"
reverify: "git show edf1b953:docs/knowledge/perl-final-codeblock-signature-declaration-gap.md && PERL5LIB= prove -q -Iperl t/callable_codeblock_literal_contract.t"
---

ADR 0031 required callable signatures—not parser callee-name checks—to govern contextual final-codeblock sugar,
but the Perl reference initially had no declaration capable of expressing that contract.

The exact seams are:

- fixed user-function records expose only `params` plus `arity`; variadic version-2 records add the existing
  `callable_signature` names/rest/min/max fields, but neither form records a parameter value kind;
- helper arity and lowering behavior live in implementation tables/branches rather than one callable-contract
  record;
- receiver attached-block parsing explicitly admits only `with`, `walk_leaves`, `map_leaves`, and
  `reduce_leaves`; and
- an attached block and its parenthesized `{ statements }` counterpart already contain equivalent final
  `block_value` payloads, but only the attached form carries a trailing-block marker.

Arity alone is insufficient: a declaration must say that the call's final parameter accepts a contextual
codeblock. The audit initially overreached by also requiring the receiving slot to duplicate the callback's
argument signature. Director clarification rejects that duplication: an explicit `{|params| ...}` value already
owns its signature, while a contextual `{ ... }` block has zero positional parameters and reads dynamic context.

ADR 0032 and `FUTURE-PARITY-BACKLOG.11.3.3.1` resolved the design gap with exact final-only `name: codeblock`, no
nested argument list. Perl behavior `.11.3.3.2` has since consumed that contract through
`LinkedSpec::CallableContract`, typed user-function metadata, and generic parser recognition followed by
lowering-time validation. This card remains the historical causal record; the current behavior is
[[perl-generic-final-codeblock-normalization]].

Related facts: [[generic-trailing-codeblock-argument-correction]],
[[callable-codeblock-literal-contract]], [[perl-callable-codeblock-dynamic-invocation]],
[[perl-generic-final-codeblock-normalization]].
