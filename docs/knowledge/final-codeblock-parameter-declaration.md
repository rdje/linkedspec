---
id: final-codeblock-parameter-declaration
title: "Final contextual codeblock parameters use name: codeblock without an argument list"
answers:
  - "how do I declare a user function callback parameter"
  - "what is the syntax for a codeblock parameter"
  - "does a codeblock parameter declaration include callback arguments"
  - "who owns a codeblock invocation signature"
  - "can parameters follow a codeblock parameter"
  - "how does a contextual final block receive values"
date: 2026-07-12
status: current
tags: [codeblock, callable-signature, parameters, functions, helpers, receiver-methods]
evidence: "Director clarification 2026-07-12; ADR 0032; FUTURE-PARITY-BACKLOG.11.3.3.1; capability_conformance/callable_codeblock_contract.json; tools/check_callable_codeblock_contract.py"
reverify: "python3 tools/check_callable_codeblock_contract.py && rg -n 'name: codeblock|callback_signature_owner|codeblock_declaration_has_no_argument_list' docs/decisions/0032-final-codeblock-parameter-declaration.md capability_conformance/callable_codeblock_contract.json tools/check_callable_codeblock_contract.py"
---

A callable declares only the final parameter's value kind:

```text
fn apply(value, callback: codeblock) {
  return(callback())
}
```

The declaration is final-only and contains no callback argument list. `callback: codeblock(item)` is invalid.
An explicit value owns its own invocation signature through `{|item, ...rest| ...}` and enforces that signature
when called. A contextual attached or parenthesized `{ ... }` final argument has zero positional parameters and
reads the callee's current dynamic context.

Helper and receiver-method registries expose the same final-parameter kind metadata. This lets parsers normalize
attached and parenthesized forms without hard-coding callable names. Ordinary parameters remain duck-typed, and
harrays are never promoted to codeblocks by position.

Related facts: [[callable-codeblock-literal-contract]], [[generic-trailing-codeblock-argument-correction]],
[[perl-final-codeblock-signature-declaration-gap]].
