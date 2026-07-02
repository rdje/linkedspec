---
id: terse-user-function-implementation-inventory
title: SPEC-FORMAT-TERSE.4.1 implementation inventory for user-defined functions
answers:
  - "what is the next user function implementation leaf"
  - "why was SPEC-FORMAT-TERSE.4.2 split"
  - "where should user function definitions be stored"
  - "how do unknown user_fn calls behave before implementation"
  - "does Rust need a user function registry"
  - "does Perl need a user function registry"
  - "what does SPEC-FORMAT-TERSE.4.2.1 own"
  - "what does SPEC-FORMAT-TERSE.4.2.2 own"
  - "what does SPEC-FORMAT-TERSE.4.2.3 own"
  - "what does SPEC-FORMAT-TERSE.4.3.1 own"
  - "what does SPEC-FORMAT-TERSE.4.3.2 own"
  - "what is the next user function finalization leaf"
  - "is SPEC-FORMAT-TERSE.4.4 done"
  - "what is the frontier after user function finalization"
date: 2026-07-02
status: current
tags: [spec-format-terse, user-functions, implementation-inventory, perl-actionir, rust-parity]
evidence: "SPEC-FORMAT-TERSE.4.1 inspected specs/spec.spec, BootstrapSpec.pm/Core.pm, Perl ActionIR::AST::Parser, MethodLowering, RewritePipeline, Rust expr.rs/ast.rs/types.rs/compiler.rs/engine.rs, oracle generation, and mdBook compiler/backend chapters. TOOLBOX probes showed Perl value slots diagnose user_fn(...) through LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:user_fn while standalone user_fn(...) remains raw. Rust source read showed Expr::Call/FluentChain parse the shapes but Engine::call_helper sent unknown names to warning+undef before implementation. The task tree split .4.2 into Perl grammar/registry, value-call execution, and discard/purity hardening; .4.3 split into Rust registry and runtime/oracle parity. SPEC-FORMAT-TERSE.4.2.1 landed the Perl function_definition grammar/registry descriptor seam; .4.2.2 landed Perl exact-arity registered value-call execution and receiver-chain composition; .4.2.3 landed registered standalone discard and hardening diagnostics; .4.3.1 landed Rust parsed/compiled function registry parity; .4.3.2 landed Rust runtime execution and oracle parity. SPEC-FORMAT-TERSE.4.4 finalized the function MVP surface and deferred extension ledger. SPEC-FORMAT-TERSE.3.2.2 then landed arithmetic symbol callees; .3.2.3 split comparison spelling policy; .3.2.3.1 locked the string bridge contract; .3.2.3.2 shipped explicit string helpers; .3.2.3.3 flipped numeric comparison word aliases; .3.2.3.4 landed numeric comparison symbol aliases. SPEC-FORMAT-TERSE.3.3 then split expression-valued assignment; the current frontier is .3.3.1 for scalar assignment expression values."
reverify: "rg -n 'SPEC-FORMAT-TERSE\\.4\\.2\\.1|SPEC-FORMAT-TERSE\\.4\\.2\\.2|SPEC-FORMAT-TERSE\\.4\\.2\\.3|SPEC-FORMAT-TERSE\\.4\\.3\\.1|SPEC-FORMAT-TERSE\\.4\\.3\\.2|SPEC-FORMAT-TERSE\\.4\\.4|SPEC-FORMAT-TERSE\\.3\\.2\\.2|SPEC-FORMAT-TERSE\\.3\\.2\\.3|FunctionDefinition|CompiledUserFunction|function_order|function_count|VALUE_DROP|standalone.*raw|terse_4_3_2_user_function_runtime' docs/tasks/SPEC-FORMAT-TERSE.md DEVELOPMENT_NOTES.md LIVE_ACHIEVEMENT_STATUS.md docs/knowledge"
---

`SPEC-FORMAT-TERSE.4.1` found that user-defined functions are too broad for one
implementation leaf.

Current ground truth:

- `specs/spec.spec` is the permanent owner for top-level `fn name(args) { ... }` and now has an active
  `function_definition` rule.
- The hardcoded bootstrap parser has no first-class `fn` grammar or function-definition node support.
- Perl ActionIR already parses `user_fn(...)` and `user_fn(...).method()` into typed `call` and
  `fluent_chain` nodes.
- Perl value slots diagnose unknown user calls as unresolved helpers; registered standalone user-function calls
  lower as `VALUE_DROP`, while unregistered standalone call-shaped statements remain raw compatibility debt.
- Rust `SpecFile` and `CompiledSpec` carry parsed/compiled user-function registry records, and Rust runtime
  dispatch now resolves registered callees before unknown-helper fallback with fresh function-local stores,
  receiver-chain continuation, standalone discard, and recursion diagnostics.

Implementation is split as follows:

- `.4.2.1`: DONE — Perl `function_definition` grammar plus function registry/descriptor ingestion.
- `.4.2.2`: DONE — Perl user-function exact-arity value-call execution and receiver-chain composition.
- `.4.2.3`: DONE — Perl standalone discard, purity/collision diagnostics, and phase0 hardening.
- `.4.3.1`: DONE — Rust parsed/compiled function registry parity.
- `.4.3.2`: DONE — Rust runtime function execution plus oracle fixtures.
- `.4.4`: DONE — function surface finalization and deferred extension ledger.

The next PNT frontier after the function and comparison slices is `SPEC-FORMAT-TERSE.3.3.1`, the scalar
assignment-expression implementation child created by the `.3.3` split.
