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

Current behavior is narrower. Perl, Rust, Dart, and Julia implement helper
`with(value) { ... }` / `with() { ... }`, receiver `.with() { ... }`, and selected
tree-traversal receiver blocks. Lua is planned but not implemented. The closed
`SPEC-FORMAT-TERSE.14` contract explicitly excluded the parenthesized final-block
form and arbitrary block-taking callables. A Perl reference lowering probe shows
`with("x") { return(value) }` succeeds while `with("x", { return(value) })` and
unknown-callee forms produce unsupported-helper lowering. Rust parsing is still
explicitly name-gated to helper `with` and selected receiver methods; Dart and
Julia parse generic trailing-block nodes but runtime dispatch still accepts only
the named supported surfaces.

Therefore generic equivalence cannot currently be confirmed for any variant,
and all-variant support cannot be claimed while Lua is absent. `FUTURE-PARITY-BACKLOG.11.1` and ADR 0031 now
close the corrective design: explicit callable literals use `{|params| body }`, execute later through `cb(args)`,
and use dynamic caller context without lexical capture. Attached/contextual final blocks remain signature-governed
sugar over the same canonical codeblock-argument node. `with` remains an ordinary block-taking helper rather than
a parser exception. Neutral contract `.11.2` precedes the split backend rollout as an adopted executable
schema/fixture. Perl `.11.3.1` now preserves inert literal records, while active `.11.3.2` owns invocation and
`.11.3.3` still owns the generic final-block equivalence described here.

Related facts: [[terse-trailing-block-argument-mvp]],
[[dart-runtime-value-control-tree-helpers]],
[[julia-runtime-value-control-tree-helpers]], [[cross-variant-output-parity]],
[[callable-codeblock-literal-contract]].
