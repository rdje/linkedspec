---
id: terse-user-function-registry-seam
title: SPEC-FORMAT-TERSE.4.2.1 Perl user-function registry descriptor seam
answers:
  - "does LinkedSpec descriptor include user functions"
  - "where are user functions stored"
  - "what does the function registry contain"
  - "does SPEC-FORMAT-TERSE.4.2.1 execute user functions"
  - "are registered function calls still unresolved"
  - "does SPEC-FORMAT-TERSE.4.2.2 execute registered value calls"
  - "how are function definitions parsed before bootstrap"
  - "what rejects duplicate user functions"
  - "what fields are in descriptor functions"
  - "does function_definition live in spec.spec"
date: 2026-07-01
status: current
tags: [spec-format-terse, user-functions, descriptor, compiler-state, perl-reference]
evidence: "SPEC-FORMAT-TERSE.4.2.1 added specs/spec.spec function_definition grammar and spec_file dispatch; added LinkedSpec::UserFunctionRegistry; added compiled_spec_state function_order/functions_by_name and public descriptor functions/meta.function_order/meta.function_count; phase0 subtest user_function_registry_descriptor_seam proved descriptor projection, body ActionIR AST capture, duplicate/builtin/rule/parameter diagnostics, and the pre-execution boundary. SPEC-FORMAT-TERSE.4.2.2 then threaded the registry into Perl RuleIR/ActionIR lowering so exact-arity registered value calls execute with zero raw fallback/unresolved helpers. SPEC-FORMAT-TERSE.4.2.3 uses the same registry in canonical-event classification so registered standalone calls/chains lower as VALUE_DROP while unregistered standalone call-shaped statements remain raw compatibility debt."
reverify: "rg -n 'function_definition:|-> function_definition' specs/spec.spec && rg -n 'function_order|functions_by_name|compiled_spec_state_to_legacy_functions|functions =>' perl/LinkedSpec/CompilerState.pm docs/linkedspec-book/src/public-api/descriptor-introspection.md && prove -Iperl t/phase0_regression.t"
---

`SPEC-FORMAT-TERSE.4.2.1` landed definition registration, not execution.

Top-level function definitions now use:

```text
fn normalize(value) {
 return(trim(value))
}
```

`specs/spec.spec` owns the active `function_definition` grammar and `spec_file`
dispatch. The Perl reference still uses a temporary pre-bootstrap bridge in
`LinkedSpec::UserFunctionRegistry`: it scans only top-level definitions, records them,
and blanks their source span while preserving newlines before ordinary validation and
bootstrap parsing.

The compiled state carries:

- `function_order`
- `functions_by_name`

The public descriptor carries:

- `functions`
- `meta.function_order`
- `meta.function_count`

Each function definition records `name`, ordered `params`, `arity`, `source_span`,
`body_span`, `body_source`, and `body_ast`.

The registry rejects duplicate function names, invalid or duplicate params, reserved
runtime/lifecycle/function symbols, built-in helper/control-name collisions, and
rule-label collisions before runtime.

Registered calls were not executable in `.4.2.1`. `.4.2.2` makes exact-arity
registered calls executable in Perl value positions and compatible receiver-dot chains
with zero raw fallback and zero unresolved helpers. `.4.2.3` adds registry-aware
standalone discard: registered calls/chains lower as `VALUE_DROP`, while unregistered
standalone call-shaped statements stay raw compatibility debt. Wrong-arity registered
calls still report unresolved-helper metadata.
