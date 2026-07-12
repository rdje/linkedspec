---
id: perl-final-codeblock-signature-declaration-gap
title: "Perl has no callable declaration for contextual final-codeblock acceptance"
answers:
  - "how does Perl declare that a callable accepts a final codeblock"
  - "why can final-codeblock normalization not be implemented from ADR 0031 yet"
  - "do user function signatures record parameter value kinds"
  - "where are block-taking receiver methods declared"
  - "what blocks FUTURE-PARITY-BACKLOG 11.3.3"
date: 2026-07-12
status: current
tags: [perl, codeblock, callable-signature, trailing-block, design-gap]
evidence: "FUTURE-PARITY-BACKLOG.11.3.3.0; LinkedSpec::call_spec_handler_subst probes; exact ActionIR JSON probes; LinkedSpec return_descriptor function record; specs/user_function_definition.spec; perl/LinkedSpec/UserFunctionRegistry.pm; perl/LinkedSpec/ActionIR/AST/Parser.pm; perl/LinkedSpec/ActionIR/MethodLowering.pm; ADR 0031"
reverify: "perl -Iperl -MLinkedSpec -e 'for my $s (q{return(with(\"x\") { return(value) })}, q{return(with(\"x\", { return(value) }))}) { print LinkedSpec::call_spec_handler_subst(\"Top\", $s), qq{\\n}; }' && rg -n 'positional_params|rest_param|unless \\$name eq .with.|receiver_trailing_block_arg' specs/user_function_definition.spec perl/LinkedSpec/UserFunctionRegistry.pm perl/LinkedSpec/ActionIR/MethodLowering.pm"
---

ADR 0031 requires callable signatures—not parser callee-name checks—to govern contextual final-codeblock sugar,
but the Perl reference currently has no declaration capable of expressing that contract.

The exact seams are:

- fixed user-function records expose only `params` plus `arity`; variadic version-2 records add the existing
  `callable_signature` names/rest/min/max fields, but neither form records a parameter value kind;
- helper arity and lowering behavior live in implementation tables/branches rather than one callable-contract
  record;
- receiver attached-block parsing explicitly admits only `with`, `walk_leaves`, `map_leaves`, and
  `reduce_leaves`; and
- an attached block and its parenthesized `{ statements }` counterpart already contain equivalent final
  `block_value` payloads, but only the attached form carries a trailing-block marker.

Arity alone is insufficient. A declaration must say both that the call's final parameter accepts a contextual
codeblock and what parameters that callback body receives. Inferring this from an ordinary final parameter, from
calls inside a user-function body, from the callee name, or from brace contents would contradict the adopted
signature-governed model and either promote harrays incorrectly or admit accidental trailing blocks.

`FUTURE-PARITY-BACKLOG.11.3.3.0` therefore splits declaration design `.1` from Perl behavior `.2`. No parser or
runtime behavior changed in the audit slice. The director must select a source/schema declaration before `.2`.

Related facts: [[generic-trailing-codeblock-argument-correction]],
[[callable-codeblock-literal-contract]], [[perl-callable-codeblock-dynamic-invocation]].
