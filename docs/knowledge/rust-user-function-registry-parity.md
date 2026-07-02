---
id: rust-user-function-registry-parity
title: Rust user-function registry parity now consumes the spec-defined definition AST
answers:
  - "does Rust parse user functions through spec file"
  - "does Rust still raw parse user functions"
  - "does Rust compile user functions"
  - "does Rust SpecFile include functions"
  - "does Rust CompiledSpec include functions"
  - "what did SPEC-FORMAT-TERSE.4.3.1 implement"
  - "when did Rust runtime execution land after the registry"
  - "what Rust diagnostics exist for user functions"
  - "where are Rust user function bodies stored"
date: 2026-07-02
status: current
tags: [spec-format-terse, rust, user-functions, compiler, registry]
evidence: "SPEC-FORMAT-TERSE.4.3.1 added the Rust SpecFile.functions / CompiledSpec.functions registry shape and SPEC-FORMAT-TERSE.4.3.2 added Rust runtime execution. STAGED-LINKED-PARSING.5.3.2 then retired the raw Rust top-level fn parser: linkedspec-runtime::spec_parser executes specs/user_function_definition.spec, validates returned function_definition / function_definition_error AST nodes, strips definition spans, and attaches FunctionDefinition records before validation/compile. rust/linkedspec-core/src/parser.rs now parses rule-only specs and rejects leading fn source when used directly; validation/compiler still reject duplicate names, rule-label collisions, helper/control/lifecycle/runtime/function-keyword collisions, invalid params, duplicate params, reserved params, and invalid bodies; CompiledUserFunction preserves body_payload."
reverify: "rg -n 'parse_spec_with_user_functions|parse_user_function_definition_asts|USER_FUNCTION_DEFINITION_SPEC' rust/linkedspec-runtime/src rust/linkedspec-runtime/tests && rg -n 'FunctionDefinition|CompiledUserFunction|body_payload|functions: Vec' rust/linkedspec-core/src && ! rg -n 'parse_top_level_user_function|parse_function_definition\\(' rust/linkedspec-core/src/parser.rs"
---

`SPEC-FORMAT-TERSE.4.3.1` gave the Rust backend the user-function registry shape needed
before runtime execution. `STAGED-LINKED-PARSING.5.3.2` changed the definition-shell
owner: Rust no longer parses top-level function declarations directly in the core rule
parser.

Rust now accepts top-level declarations such as:

```text
fn normalize(value) {
 return(trim(value))
}
```

Definitions may appear before or between rule paragraphs. The runtime adapter first runs
`specs/user_function_definition.spec` over the full source, validates the returned AST
shape, strips definition spans, and then passes rule-only source to the core parser. The
resulting `SpecFile.functions` records ordered params, exact arity, original source, body
source, source/body spans, and the neutral `body_payload`.

Validation rejects duplicate function names, rule-label collisions, built-in
helper/control-name collisions including the `.3.2.1` numeric word aliases,
lifecycle/runtime/function-keyword collisions, invalid params, duplicate params, and
reserved params before runtime.

Compilation records each validated definition as a `CompiledUserFunction` in
`CompiledSpec.functions`. The compiled record preserves source metadata and `body_payload`
and parses `body_source` into a `CodeBlock`; invalid body code becomes a compile error.

This card is the registry-parity fact. Runtime execution landed afterward in
`SPEC-FORMAT-TERSE.4.3.2`; see `rust-user-function-runtime-parity` for the resolver,
function-local scope, receiver-chain, standalone discard, recursion diagnostic, and
oracle-corpus details.
