---
id: rust-user-function-registry-parity
title: SPEC-FORMAT-TERSE.4.3.1 Rust parsed and compiled user-function registry parity
answers:
  - "does Rust parse user functions"
  - "does Rust compile user functions"
  - "does Rust SpecFile include functions"
  - "does Rust CompiledSpec include functions"
  - "what did SPEC-FORMAT-TERSE.4.3.1 implement"
  - "does Rust execute user functions yet"
  - "what Rust diagnostics exist for user functions"
  - "where are Rust user function bodies stored"
date: 2026-07-02
status: current
tags: [spec-format-terse, rust, user-functions, compiler, registry]
evidence: "SPEC-FORMAT-TERSE.4.3.1 added SpecFile.functions and FunctionDefinition/SourceSpan in rust/linkedspec-core/src/ast.rs; parser.rs now extracts top-level fn name(args) { ... } definitions before or between rules and stops rule body collection at top-level functions; validation.rs rejects duplicate names, rule-label collisions, helper/control collisions including the .3.2.1 numeric word aliases, lifecycle/runtime/function-keyword collisions, invalid params, duplicate params, and reserved params; types.rs adds CompiledUserFunction and CompiledSpec.functions; compiler.rs parses function body_source into CodeBlock. Rust runtime execution remains owned by SPEC-FORMAT-TERSE.4.3.2."
reverify: "rg -n 'FunctionDefinition|CompiledUserFunction|functions: Vec|compile_user_function|parse_top_level_user_function|validate_rejects_user_function' rust/linkedspec-core/src rust/linkedspec-core/tests && rg -n 'SPEC-FORMAT-TERSE\\.4\\.3\\.1|SPEC-FORMAT-TERSE\\.4\\.3\\.2' docs/tasks/SPEC-FORMAT-TERSE.md"
---

`SPEC-FORMAT-TERSE.4.3.1` gives the Rust backend the user-function registry shape
needed before runtime execution.

Rust now parses top-level declarations such as:

```text
fn normalize(value) {
 return(trim(value))
}
```

Definitions may appear before or between rule paragraphs. The parser records them in
`SpecFile.functions`, with ordered params, exact arity, original source, body source, and
source/body spans. Rule bodies stop before top-level `fn` definitions, so functions are
not swallowed as raw rule body text.

Validation rejects duplicate function names, rule-label collisions, built-in
helper/control-name collisions including the `.3.2.1` numeric word aliases,
lifecycle/runtime/function-keyword collisions, invalid params, duplicate params, and
reserved params before runtime.

Compilation records each validated definition as a `CompiledUserFunction` in
`CompiledSpec.functions`. The compiled record preserves source metadata and parses
`body_source` into a `CodeBlock`; invalid body code becomes a compile error.

This is registry parity only. Rust user-function call resolution, function-local
execution scope, receiver-chain continuation, standalone result discard, and oracle
fixtures remain `SPEC-FORMAT-TERSE.4.3.2`.
