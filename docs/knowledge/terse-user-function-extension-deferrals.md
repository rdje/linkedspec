---
id: terse-user-function-extension-deferrals
title: SPEC-FORMAT-TERSE.4.4 user-function extension deferral ledger
answers:
  - "what user function syntax is accepted after SPEC-FORMAT-TERSE.4.4"
  - "are function endfunction definitions supported"
  - "is fn endfn supported"
  - "can zero arg user functions omit parentheses"
  - "are brace-less user function bodies supported"
  - "are recursive user functions supported"
  - "are user functions allowed to mutate caller state"
  - "are closures lambdas currying supported in user functions"
  - "are user function namespaces supported"
  - "what did SPEC-FORMAT-TERSE.4.4 finalize"
date: 2026-07-02
status: current
tags: [spec-format-terse, user-functions, deferrals, mdbook, task-tree]
evidence: "SPEC-FORMAT-TERSE.4.4 closed the user-function docs/retrieval surface after Perl/Rust MVP parity. The formal grammar, backend handoff, pipeline overview, descriptor/state model docs, task tree, and live docs now state that the accepted MVP is top-level fn name(args) { ... } with explicit parentheses for every arity, braced value-oriented bodies, exact arity, fresh function-local stores, final-expression or return(expr) results, value-call composition, receiver-chain continuation, and standalone result discard. The same sources explicitly defer alternate spellings, optional zero-arg parentheses, brace-less bodies, caller-state/parser-state/persistent side-effect functions, recursive user functions, closures, lambdas, currying/partial application, and namespace/module features."
reverify: "rg -n 'function MVP|function surface|explicit-paren|zero-arg|function \\.\\.\\. endfunction|fn \\.\\.\\. endfn|brace-less|caller-state|recursive user functions|closures/lambdas/currying|namespaces' docs/tasks/SPEC-FORMAT-TERSE.md docs/linkedspec-book/src docs/knowledge/terse-user-function-extension-deferrals.md"
---

`SPEC-FORMAT-TERSE.4.4` finalizes the user-function MVP surface after the Perl and Rust
implementations reached parity.

Accepted MVP:

- top-level `fn name(args) { ... }`
- explicit parentheses for every arity, including `fn name() { ... }`
- braced, value-oriented function bodies
- exact arity
- eager caller-context argument evaluation
- fresh function-local scalar/array/hash stores
- final-expression or `return(expr)` results
- calls usable as ordinary values, compatible receiver-chain receivers, and standalone
  discarded statements

Deferred until a future owning task-tree leaf and contract:

- `function name(args) ... endfunction`
- `fn name(args) ... endfn`
- omitted zero-argument parentheses such as `fn ready { ... }`
- brace-less or single-expression body forms
- functions whose observable purpose is caller-state, parser-state, or persistent side
  effects rather than returned values
- direct or mutual recursive user functions
- closures, lambdas, currying, or partial application
- namespace/module features for functions
