---
id: terse-user-function-value-call-execution
title: SPEC-FORMAT-TERSE.4.2.2 Perl user-function value-call execution
answers:
  - "does LinkedSpec execute user-defined functions"
  - "does Perl execute registered function calls"
  - "can user functions feed receiver-dot chains"
  - "what does SPEC-FORMAT-TERSE.4.2.2 own"
  - "how are user function arguments evaluated"
  - "how are user function locals scoped"
  - "what happens for wrong user function arity"
  - "are standalone user function calls implemented"
  - "which task owns standalone user function discard"
  - "does SPEC-FORMAT-TERSE.4.2.3 implement standalone discard"
date: 2026-07-01
status: current
tags: [spec-format-terse, user-functions, actionir, perl-reference, receiver-dot]
evidence: "SPEC-FORMAT-TERSE.4.2.2 threads LinkedSpec::UserFunctionRegistry through Compiler, SpecEntry, RuleIR::EmitContext, and ActionIR::MethodLowering. MethodLowering resolves exact-arity registered calls before helper fallback, eagerly lowers caller-context arguments into temporaries, binds function parameters inside a generated do block, declares function-local scalar/array/hash work variables, supports final-expression and body-local return(expr) results, composes array/hash return values with compatible receiver-dot chains, and leaves wrong-arity registered calls as unresolved-helper diagnostics with raw_perl_dependency_count == 0. SPEC-FORMAT-TERSE.4.2.3 then adds registry-aware canonical VALUE_DROP classification for registered standalone calls/chains and locks recursion/unsupported body diagnostics with zero raw fallback."
reverify: "prove -Iperl t/phase0_regression.t && rg -n 'function_registry|user_function_registry|_lower_ast_user_function_call_node|user_function_value_call_execution' perl/LinkedSpec/Compiler.pm perl/LinkedSpec/SpecEntry.pm perl/LinkedSpec/RuleIR/EmitContext.pm perl/LinkedSpec/ActionIR/MethodLowering.pm t/phase0_regression.t"
---

`SPEC-FORMAT-TERSE.4.2.2` makes registered Perl user-function calls executable in
value positions. This records the initial fixed-arity milestone; [[perl-variadic-user-functions]] owns the
later version-2 rest-signature extension alongside unchanged version-1 fixed signatures.

The original lowering boundary is:

- exact-arity registered calls resolve before built-in helper fallback
- arguments are evaluated eagerly in the caller context
- parameters are rebound inside a generated function-local `do { ... }` block
- function-local scalar, array, and hash working variables are declared in that block
- final expression bodies and body-local `return(expr)` produce the function result
- array/hash results can feed compatible receiver-dot chains such as `.length()`; current field reads use
  direct brackets, such as `name["key"]`. The earlier `scalar(hash(name), key)` replacement is retired too;
  see [[terse-retired-scalar-assign-spec-surface]] and [[perl-aggregate-selector-compile-rejection]]
- wrong arity remains an unresolved-helper diagnostic with zero raw fallback

`SPEC-FORMAT-TERSE.4.2.3` adds standalone registered-call discard: a standalone
`normalize(" x ")` or `normalize(" X ").lowercase()` is a canonical `VALUE_DROP`, so
the value is computed and then discarded with zero raw fallback. Recursion and
unsupported function-body forms remain deterministic unresolved-helper diagnostics.
