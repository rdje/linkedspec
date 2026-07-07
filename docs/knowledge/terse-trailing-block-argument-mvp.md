---
id: terse-trailing-block-argument-mvp
title: "SPEC-FORMAT-TERSE.14 - trailing block arguments use immediate non-closure callbacks, with Perl/Rust with(value) support"
answers:
  - "which task owns trailing code blocks as helper arguments"
  - "what is the SPEC-FORMAT-TERSE.14 trailing block argument MVP"
  - "does trailing block syntax introduce closures"
  - "what helper is first for trailing block arguments"
  - "is with value trailing block syntax accepted yet"
  - "does Rust support with value trailing block syntax"
  - "what lexical context does a trailing with block execute in"
  - "why is bare with block deferred"
  - "what is the next leaf for trailing block arguments"
date: 2026-07-07
status: current
tags: [spec-format-terse, block-arguments, code-blocks, closures, task-tree]
evidence: "docs/tasks/SPEC-FORMAT-TERSE.md .14/.14.1/.14.2/.14.3; perl/LinkedSpec/ActionIR/AST/Parser.pm; perl/LinkedSpec/ActionIR/MethodLowering.pm; t/phase0_regression.t spec_format_terse_14_2_perl_helper_trailing_block_arguments; rust/linkedspec-core/src/expr.rs; rust/linkedspec-runtime/src/engine.rs; rust/linkedspec-runtime/tests/integration_test.rs terse_14_3_*; rust/linkedspec-runtime/tests/corpus/terse_14_3_with_helper_trailing_block"
reverify: "rg -n 'SPEC-FORMAT-TERSE\\.14\\.3|trailing_block_arg|spec_format_terse_14_2|terse_14_3|with\\(value\\)|with\\(\\)' docs/tasks/SPEC-FORMAT-TERSE.md perl/LinkedSpec/ActionIR/AST/Parser.pm perl/LinkedSpec/ActionIR/MethodLowering.pm t/phase0_regression.t rust/linkedspec-core/src/expr.rs rust/linkedspec-runtime/src/engine.rs rust/linkedspec-runtime/tests/integration_test.rs docs/linkedspec-book/src"
---

`SPEC-FORMAT-TERSE.14` owns trailing code blocks as final helper/receiver arguments.
It was reactivated by the user on 2026-07-07 and split before code in `.14.1`.
`.14.2` shipped the Perl reference helper-form surface, and `.14.3` shipped the
Rust interpreter parity surface plus an oracle fixture.

The MVP is an immediate callback argument, not a closure. Blocks are not assignable,
not returnable, and not callable later. The first implementation target is helper-form
`with(value) { ... }`: evaluate `value`, bind scoped scalar `value` during immediate
block execution, restore any prior binding afterward, and return the block result.
`with() { ... }` binds `value` to `undef`. `return(expr)` inside the block is
block-local. The trailing block executes in the caller's current action/runtime
context: captures, `retv`, cursor state, helper/function visibility, and ordinary
working-variable side effects are shared with the call site. Only the scalar
binding `value` is portable as the scoped block parameter in the MVP; mutations
to other variable names persist.
The AST parser flags trailing-block calls with `trailing_block_arg`;
MethodLowering accepts that flag only for `with`, and unknown trailing-block
callees emit an unsupported-helper diagnostic instead of raw fallback. The Rust
parser appends a trailing `BlockValue` only for helper-form `with(...) { ... }`;
the runtime evaluates `with` lazily, binds scoped `value`, restores the prior
same-name stores afterward, and uses existing expression-valued block return
semantics.

Bare `with { ... }` remains deferred because word-plus-brace is already a rule-body
lifecycle/code-block shape. Receiver `.with() { ... }` remains a separate child.
The next implementation leaf is `SPEC-FORMAT-TERSE.14.4` for receiver-form
trailing block arguments.
