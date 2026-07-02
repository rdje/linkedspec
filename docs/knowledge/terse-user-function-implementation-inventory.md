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
date: 2026-07-01
status: current
tags: [spec-format-terse, user-functions, implementation-inventory, perl-actionir, rust-parity]
evidence: "SPEC-FORMAT-TERSE.4.1 inspected specs/spec.spec, BootstrapSpec.pm/Core.pm, Perl ActionIR::AST::Parser, MethodLowering, RewritePipeline, Rust expr.rs/ast.rs/types.rs/compiler.rs/engine.rs, oracle generation, and mdBook compiler/backend chapters. TOOLBOX probes showed Perl value slots diagnose user_fn(...) through LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:user_fn while standalone user_fn(...) remains raw. Rust source read showed Expr::Call/FluentChain parse the shapes but Engine::call_helper sends unknown names to warning+undef. The task tree split .4.2 into Perl grammar/registry, value-call execution, and discard/purity hardening; .4.3 split into Rust registry and runtime/oracle parity. SPEC-FORMAT-TERSE.4.2.1 then landed the Perl function_definition grammar/registry descriptor seam. SPEC-FORMAT-TERSE.4.2.2 landed Perl exact-arity registered value-call execution and receiver-chain composition; standalone discard/purity hardening remains .4.2.3."
reverify: "rg -n 'SPEC-FORMAT-TERSE\\.4\\.2\\.1|SPEC-FORMAT-TERSE\\.4\\.2\\.2|SPEC-FORMAT-TERSE\\.4\\.2\\.3|SPEC-FORMAT-TERSE\\.4\\.3\\.1|SPEC-FORMAT-TERSE\\.4\\.3\\.2|function_order|function_count|registered calls.*unresolved|standalone.*remains raw' docs/tasks/SPEC-FORMAT-TERSE.md DEVELOPMENT_NOTES.md LIVE_ACHIEVEMENT_STATUS.md"
---

`SPEC-FORMAT-TERSE.4.1` found that user-defined functions are too broad for one
implementation leaf.

Current ground truth:

- `specs/spec.spec` is the permanent owner for top-level `fn name(args) { ... }` and now has an active
  `function_definition` rule.
- The hardcoded bootstrap parser has no first-class `fn` grammar or function-definition node support.
- Perl ActionIR already parses `user_fn(...)` and `user_fn(...).method()` into typed `call` and
  `fluent_chain` nodes.
- Perl value slots currently diagnose unknown user calls as unresolved helpers; standalone unknown call
  statements remain raw until the function registry owns discard semantics.
- Rust `Expr::Call` and `Expr::FluentChain` already parse the call shapes, but runtime dispatch treats unknown
  callees as helper misses and returns `undef` after a warning.

Implementation is split as follows:

- `.4.2.1`: DONE — Perl `function_definition` grammar plus function registry/descriptor ingestion.
- `.4.2.2`: DONE — Perl user-function exact-arity value-call execution and receiver-chain composition.
- `.4.2.3`: Perl standalone discard, purity/collision diagnostics, and phase0 hardening.
- `.4.3.1`: Rust parsed/compiled function registry parity.
- `.4.3.2`: Rust runtime function execution plus oracle fixtures.

The next PNT frontier is `SPEC-FORMAT-TERSE.4.2.3`.
