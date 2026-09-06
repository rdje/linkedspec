---
id: terse-user-function-registry-seam
title: Perl user-function registry normalizes spec-owned definitions and versioned metadata
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
dispatch. The Perl pre-bootstrap bridge in `LinkedSpec::UserFunctionRegistry` now compiles and caches
`specs/user_function_definition.spec` at top `user_function_definitions`. It consumes that spec-returned
AST, validates records, and blanks each definition span while preserving newlines before ordinary
validation and bootstrap parsing. It no longer owns a separate raw definition-shell scanner.

The compiled state carries:

- `function_order`
- `functions_by_name`

The public descriptor carries:

- `functions`
- `meta.function_order`
- `meta.function_count`

Fixed version-1 definitions record `name`, ordered `params`, `arity`, source/body spans and text,
staged body records, and `body_ast`. Version-2 variadic definitions use the neutral callable signature
instead of `params`/`arity`. Typed final-codeblock declarations carry final parameter-kind metadata
internally and use the separately governed version-3 outward descriptor projection.

The registry rejects duplicate function names, invalid or duplicate params, reserved
runtime/lifecycle/function symbols, built-in helper/control-name collisions, and
rule-label collisions before runtime.

Registered calls were not executable in `.4.2.1`. `.4.2.2` makes exact-arity
registered calls executable in Perl value positions and compatible receiver-dot chains
with zero raw fallback and zero unresolved helpers. `.4.2.3` adds registry-aware
standalone discard: registered calls/chains lower as `VALUE_DROP`, while unregistered
standalone call-shaped statements stay raw compatibility debt. Wrong-arity registered
calls and variadic below-minimum calls report unresolved-helper metadata.

## September 6 complete registry reading

`SESSION-STARTUP-READING.3.2.53` reads all 773 lines / 30,552 bytes with exact baseline identity
(SHA-256 `805626ff7aeebdbb00565fa102afccdd3e6c8126e2e341f44bfeff1d0cd5361c`). Parser construction
uses a reentrancy flag restored after its guarded load and caches only a valid CODE parser. Fixed,
variadic, and typed-final records require matching body payload/job signature, text, and spans; ordinal
paths and job ids are rewritten deterministically. Body AST comes from the narrow staged registry.
The registry container stays version 1 even when contained function records use version 2.

Two managed existing suites pass 76 top-level tests in 29 seconds: variadic definitions/calls and
callable codeblock literals. Neutral signature proof is 3 definitions / 9 calls / 7 invalid definitions;
codeblock proof is 7 literals / 11 calls / 9 invalid literals / 7 invalid calls / 4 invalid declarations /
8 contextual forms / 23 governance mutations. The complete 174-line variadic consumer and the
codeblock metadata subtest at 346–397 were read; the remaining codeblock consumer is not newly credited.
The variadic suite checks emitted source text and native execution; generated runtime claims retain
their separate existing consumer evidence. No runtime, grammar, or descriptor contract changed.

Canonical successors: [[spec-defined-user-function-definition-parser]], [[perl-variadic-user-functions]],
[[perl-generic-final-codeblock-normalization]], and [[function-body-staged-registry-dispatch]].
