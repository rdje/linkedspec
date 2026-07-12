---
id: perl-generic-final-codeblock-normalization
title: "Perl normalizes contextual final blocks through callable metadata"
answers:
  - "does Perl support attached final codeblock arguments"
  - "does Perl support parenthesized contextual codeblock arguments"
  - "how does Perl declare that a callable accepts a final codeblock"
  - "do Perl user function signatures record parameter value kinds"
  - "where are Perl block taking helper and receiver methods declared"
  - "does Perl hard code receiver method names for trailing blocks"
  - "what is a codeblock_argument"
  - "does Perl promote a harray in a codeblock parameter"
  - "does callback codeblock include an argument list"
date: 2026-07-12
status: current
tags: [perl, actionir, codeblock, callable-contract, trailing-block, user-functions, generated-source]
evidence: "FUTURE-PARITY-BACKLOG.11.3.3.2 adds LinkedSpec::CallableContract; typed final parameter metadata in user_function_definition.spec and UserFunctionRegistry; generic receiver attached parsing; metadata-governed MethodLowering normalization; typed final-value validation; focused live and standalone generated execution."
reverify: "PERL5LIB= prove -q -Iperl t/callable_codeblock_literal_contract.t && python3 tools/check_callable_codeblock_contract.py"
---

# Perl Generic Final-Codeblock Normalization

Perl user functions declare only a final value kind:

```text
fn apply(value, callback: codeblock) { return(callback()) }
```

The definition, staged body payload, and staged parse job preserve ordered `params`, exact `arity`, and
`parameter_kinds => { callback => "codeblock" }`. The declaration contains no callback argument list. An explicit
`{|item, ...rest| ...}` value continues to own and enforce its own invocation signature.

`LinkedSpec::CallableContract` is the common acceptance seam for builtin helpers, receiver methods, and typed user
functions. The ActionIR parser recognizes receiver attached-block syntax without a method-name allowlist; lowering
then consults the callable contract. When the declared final argument is an immediate contextual `{ ... }` block,
both attached and parenthesized spellings normalize to one version-1 `codeblock_argument` with an exact zero-
positional signature and the same typed body/source payload.

Typed user functions execute that record through the dynamic codeblock runtime in live and standalone generated
source. Governed immediate helpers and receiver methods consume the same canonical node but retain their existing
full-breadth immediate block lowering; normalization does not narrow previously supported block-body helpers.
Contextual blocks read current dynamic values such as `value`; explicit literals retain their own parameters.
Harray literals remain harrays and a typed final slot rejects them with `final_argument_not_codeblock`. Invalid
non-final, nested-argument-list, missing-name, and unknown-type declarations fail before parser construction.

Current builtin contracts cover helper `with` and receiver `with`, `walk_leaves`, `map_leaves`, and
`reduce_leaves`. Unknown attached receiver methods may parse structurally but fail callable-contract validation;
syntax recognition no longer grants semantics.

Related facts: [[final-codeblock-parameter-declaration]], [[callable-codeblock-literal-contract]],
[[perl-callable-codeblock-dynamic-invocation]], [[perl-final-codeblock-signature-declaration-gap]].
