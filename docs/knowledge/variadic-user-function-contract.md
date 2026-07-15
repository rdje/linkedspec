---
id: variadic-user-function-contract
title: Variadic user functions use a final ...rest parameter and bind extras as one typed array
answers:
  - "what is the variadic user function syntax"
  - "how do I define a function with unlimited arguments"
  - "what does ...rest mean in a LinkedSpec function"
  - "can a variadic function have zero fixed parameters"
  - "what value does an empty rest parameter receive"
  - "are user function keyword arguments supported"
  - "do variadic user functions introduce overloads"
  - "what descriptor version represents a variadic function"
  - "do fixed user functions remain exact arity"
  - "can user functions be called as receiver methods"
date: 2026-07-12
status: current
tags: [functions, arity, variadic, rest-parameter, descriptor, staged-parsing, portability, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.4.1, ADR 0030, and capability_conformance/callable_signature_contract.json adopt linkedspec-callable-signature-v1. The independent checker validates three definitions, nine call cases, seven invalid signatures, versioned descriptor roles, and a deterministic .spec fixture. .4.2-.3 implement it on Perl/Rust/Dart/Julia; .4.4 routes Lua to LUA-BACKEND-PARITY.5.1/.5.3/.8."
reverify: "python3 tools/check_callable_signature_contract.py && rg -n 'variadic|rest_param|min_arity|max_arity|\.\.\.' docs/decisions/0030-variadic-callable-signature-contract.md capability_conformance/callable_signature_contract.json docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

The adopted definition form is:

```text
fn collect(prefix, ...items) {
  return({ "prefix": prefix, "items": items })
}
```

The rest marker and identifier form one token (`...items`). A definition may use no fixed parameters
(`fn all(...items)`) or any fixed prefix, but may have only one rest parameter and it must be final. The rest name
must satisfy the same identifier, uniqueness, and reserved-name rules as fixed parameters.

All call arguments remain positional and evaluate once, left to right, in caller scope. Fixed parameters receive
the prefix values. Extras become one fresh typed LinkedSpec array bound to the rest name; zero extras produce an
empty typed array. The array does not flatten nested arrays/harrays or erase null, boolean, or codeblock value
identity. The returned value remains chainable by runtime type.

Existing fixed definitions remain version 1 with exact `params`/`arity`. Variadic definitions are version 2 and
carry a version-1 `callable_signature` object with `positional_params`, `rest_param`, `min_arity`, and nullable
`max_arity`. Their staged payload/job and outward descriptor carry the same signature. This avoids reinterpreting
the old `arity` field as two different concepts.

This is not overload or host splat behavior. Function names remain unique; keyword/default/named parameters are
not accepted; user-defined functions do not become receiver methods. Existing built-in helpers and methods keep
their purpose-specific exact, bounded, or open arities.

Perl, Rust, Dart, and Julia implement the neutral contract through native and generated execution. Lua now
preserves the exact native signature-state union, resolves minimum/unbounded arity, and executes fresh typed rest
arrays under `LUA-BACKEND-PARITY.5.1.3.1/.2`; exact outward descriptor admission is complete in `.5.3.1`, while
generated preservation/execution/admission remains `.8.1-.4`.

Related routing facts: [[lua-variadic-user-function-routing]], [[lua-variadic-v2-signature-state]],
[[lua-variadic-v2-runtime]].
