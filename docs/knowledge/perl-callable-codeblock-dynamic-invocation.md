---
id: perl-callable-codeblock-dynamic-invocation
title: Perl invokes callable codeblock records through explicit dynamic caller bindings
answers:
  - "does Perl execute cb args codeblock calls"
  - "how does Perl execute a codeblock variable"
  - "does Perl codeblock invocation capture lexical variables"
  - "are Perl codeblock parameters restored"
  - "do Perl codeblock mutations affect the caller"
  - "can a Perl codeblock result feed a receiver chain"
  - "what error does a non callable Perl value produce"
  - "does a helper shadow a same named codeblock variable"
date: 2026-07-12
status: current
tags: [perl, actionir, codeblock, callable, dynamic-scope, diagnostics, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.11.3.2 adds LinkedSpec::CodeblockRuntime, scalar working-slot dependency projection, bound-call and VALUE_DROP lowering, exact neutral fixture execution, standalone generated-source proof, static helper/user-function precedence, and typed arity/keyword/not-callable/recursion failures."
reverify: "PERL5LIB= prove -v -Iperl t/callable_codeblock_literal_contract.t && bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py"
---

# Perl Callable Codeblock Dynamic Invocation

Perl resolves a call such as `cb(args)` after governed helpers and registered user functions. When the call name is
a scalar working binding, generated source invokes the plain eight-field `codeblock_literal` record through
`LinkedSpec::CodeblockRuntime`; the record never gains a Perl coderef or captured environment.

The generated call site supplies explicit references to the rule's scalar working slots. Arguments evaluate before
binding, fixed values are recursively copied, a final rest parameter receives a fresh copied array, and all prior
parameter values restore on success or failure. Other variable reads and writes use the caller's current slots, so
nonparameter mutation remains visible. `return(expr)` is invocation-local; final values may chain and standalone
calls execute before discarding their result.

The runtime produces typed `LinkedSpec::CodeblockRuntime::Error` detail for arity mismatch, keyword arguments,
bound non-codeblock values, active recursion, and unsupported body calls. The existing runtime handler boundary
places that object in `runtime_ctx_ref->{last_error}{detail}`. Static helpers and registered user functions retain
precedence over same-named codeblock bindings.

This fact is Perl-specific. ADR 0032 declaration `.11.3.3.1` and generic attached/contextual final-block behavior
`.11.3.3.2` are complete; Perl closeout and Rust/Dart/Julia parity follow.

Related facts: [[callable-codeblock-literal-contract]], [[perl-callable-codeblock-literal-record]],
[[terse-user-function-value-call-execution]], [[perl-generic-final-codeblock-normalization]].
