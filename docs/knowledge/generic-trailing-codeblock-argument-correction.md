---
id: generic-trailing-codeblock-argument-correction
title: "Trailing braces must be generic final-codeblock argument sugar, not a with-only parser feature"
answers:
  - "do all LinkedSpec variants support generic trailing codeblock arguments"
  - "is call(args) block equivalent to call(args comma block)"
  - "is a codeblock one of the LinkedSpec value kinds"
  - "does Lua support trailing codeblock arguments"
  - "should the with trailing block MVP be removed"
  - "what supersedes the narrow SPEC-FORMAT-TERSE 14 trailing block MVP"
  - "which task owns generic trailing codeblock argument parity"
date: 2026-07-10
status: current
tags: [spec-format-terse, codeblock, trailing-block, values, parity, future-parity-backlog]
evidence: "Director clarification 2026-07-10; FUTURE-PARITY-BACKLOG.11/.11.0/.11.1; docs/tasks/SPEC-FORMAT-TERSE.md .14; LinkedSpec::call_spec_handler_subst probes; perl/LinkedSpec/ActionIR/AST/Parser.pm; perl/LinkedSpec/ActionIR/MethodLowering.pm; rust/linkedspec-core/src/expr.rs; dart/lib/src/action/action_parser.dart; dart/lib/src/runtime/interpreter.dart; julia/src/action/ActionParser.jl; julia/src/runtime/Interpreter.jl; current focused tests and mdBook helper contract"
evidence_update_2026_08_01_five_implementations: "Perl .11.3, Rust .11.4, Dart .11.5, Julia .11.6, and Lua .11.8.1-.3 now implement explicit literals, dynamic calls, and metadata-governed contextual helper/user-function/receiver/tree equivalence through their ordinary evaluators. Lua five-backend recurring admission remains .11.8.4."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $s (q{return(with(\"x\") { return(value) })}, q{return(with(\"x\", { return(value) }))}, q{return(unknown(\"x\") { return(value) })}) { print LinkedSpec::call_spec_handler_subst(\"Top\", $s), qq{\\n}; }' && rg -n 'parse_optional_trailing_block_arg|name != \"with\"|parse_non_with_helper_does_not_accept|trailingBlockArg|trailing_block_arg|FUTURE-PARITY-BACKLOG\\.11' rust/linkedspec-core/src/expr.rs dart/lib/src julia/src docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

The director's language model has four object/value kinds: scalar, array, harray,
and codeblock. For a helper function, user function, or receiver method whose
signature accepts a final codeblock argument, these spellings must mean the same
call and normalize to the same canonical AST/IR shape:

```text
call(arg1, arg2) { statements }
call(arg1, arg2, { statements })
```

The callable signature decides whether a final codeblock is legal. The parser
must not hard-code one helper name as the meaning of trailing braces. Arity,
non-final codeblocks, receiver behavior, execution context, block-local return,
and hash-literal disambiguation remain contract-validation concerns shared by
every backend.

The pre-correction implementation was narrower: named `with` and selected tree forms were special cases, the
closed `SPEC-FORMAT-TERSE.14` contract excluded parenthesized final blocks and arbitrary block-taking callables,
and Lua was absent. ADRs 0031/0032 and neutral contract `.11.2` replaced that model with explicit
`{|params| body }` values plus final-only `name: codeblock` metadata. The parser records structure; the completed
registry/signature decides whether contextual braces are deferred.

Perl `.11.3`, Rust `.11.4`, Dart `.11.5`, Julia `.11.6`, and Lua `.11.8.1-.3` now implement that correction.
Metadata-governed helper, typed-user-function, receiver, and tree forms normalize to zero-positional contextual
codeblocks, while explicit literals retain their authored signatures. All enter each backend's ordinary dynamic
codeblock evaluator across its native/reconstructed/generated/emitted routes. `with` remains an ordinary helper,
not parser authority. The existing recurring public gate still admits four backends; Lua replacement admission is
separately owned by `.11.8.4`.

Related facts: [[terse-trailing-block-argument-mvp]],
[[dart-runtime-value-control-tree-helpers]],
[[julia-runtime-value-control-tree-helpers]], [[perl-final-codeblock-signature-declaration-gap]],
[[perl-generic-final-codeblock-normalization]],
[[cross-variant-output-parity]],
[[callable-codeblock-literal-contract]], [[lua-callable-codeblock-emitted-route-identity]].
