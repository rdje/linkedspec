---
id: terse-trailing-block-argument-mvp
title: "SPEC-FORMAT-TERSE.14 - trailing block arguments use immediate non-closure callbacks, with Perl/Rust helper and receiver with support"
answers:
  - "which task owns trailing code blocks as helper arguments"
  - "what is the SPEC-FORMAT-TERSE.14 trailing block argument MVP"
  - "does trailing block syntax introduce closures"
  - "what helper is first for trailing block arguments"
  - "is with value trailing block syntax accepted yet"
  - "does Rust support with value trailing block syntax"
  - "does receiver .with trailing block syntax work"
  - "does .with() { } bind the receiver value as value"
  - "can receiver .with() { } continue into later receiver methods"
  - "what lexical context does a trailing with block execute in"
  - "why is bare with block deferred"
  - "what is the next leaf for trailing block arguments"
date: 2026-07-07
status: current
tags: [spec-format-terse, block-arguments, code-blocks, closures, task-tree]
evidence: "docs/tasks/SPEC-FORMAT-TERSE.md .14/.14.1/.14.2/.14.3/.14.4; perl/LinkedSpec/ActionIR/AST/Parser.pm; perl/LinkedSpec/ActionIR/MethodLowering.pm; t/actionir_ast_parser.t; t/phase0_regression.t spec_format_terse_14_2_perl_helper_trailing_block_arguments and spec_format_terse_14_4_perl_receiver_trailing_block_arguments; rust/linkedspec-core/src/expr.rs; rust/linkedspec-runtime/src/engine.rs; rust/linkedspec-runtime/tests/integration_test.rs terse_14_3_* and terse_14_4_*; rust/linkedspec-runtime/tests/corpus/terse_14_3_with_helper_trailing_block; rust/linkedspec-runtime/tests/corpus/terse_14_4_receiver_with_trailing_block"
reverify: "rg -n 'SPEC-FORMAT-TERSE\\.14\\.4|receiver_trailing_block_arg|spec_format_terse_14_4|terse_14_4|\\.with\\(\\) \\{' docs/tasks/SPEC-FORMAT-TERSE.md perl/LinkedSpec/ActionIR/AST/Parser.pm perl/LinkedSpec/ActionIR/MethodLowering.pm t/actionir_ast_parser.t t/phase0_regression.t rust/linkedspec-core/src/expr.rs rust/linkedspec-runtime/src/engine.rs rust/linkedspec-runtime/tests/integration_test.rs docs/linkedspec-book/src && rg -n '\"case_count\" : 95|terse_14_4_receiver_with_trailing_block' rust/linkedspec-runtime/tests/corpus/manifest.json"
---

`SPEC-FORMAT-TERSE.14` owns trailing code blocks as final helper/receiver arguments.
It was reactivated by the user on 2026-07-07 and split before code in `.14.1`.
`.14.2` shipped the Perl reference helper-form surface, `.14.3` shipped the
Rust interpreter parity surface plus an oracle fixture, and `.14.4` shipped
receiver-form `.with() { ... }` on Perl and Rust plus the 95th oracle fixture.

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
The AST parser flags helper-form trailing-block calls with `trailing_block_arg`;
MethodLowering accepts that flag only for `with`, and unknown trailing-block
callees emit an unsupported-helper diagnostic instead of raw fallback. The Rust
parser appends a trailing `BlockValue` only for helper-form `with(...) { ... }`;
the runtime evaluates `with` lazily, binds scoped `value`, restores the prior
same-name stores afterward, and uses existing expression-valued block return
semantics.

Receiver `.with() { ... }` is also current on Perl and Rust. It evaluates the
receiver first, exposes that receiver value as scoped scalar `value` while the
block executes immediately, restores the surrounding binding afterward, and
returns the block result. The result can be terminal or can continue into later
compatible receiver-family links, such as a string result flowing into `.trim()`
or an array result flowing into `.count()`. Explicit receiver
`.with(value) { ... }` is rejected/deferred; receiver form takes the receiver
itself as the only block input.

Bare `with { ... }` remains deferred because word-plus-brace is already a rule-body
lifecycle/code-block shape. The next leaf is `SPEC-FORMAT-TERSE.14.5` for final
trailing block-argument no-drift closeout.
