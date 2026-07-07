---
id: terse-trailing-block-argument-mvp
title: "SPEC-FORMAT-TERSE.14 - trailing block arguments use immediate non-closure callbacks, with Perl reference with(value) support"
answers:
  - "which task owns trailing code blocks as helper arguments"
  - "what is the SPEC-FORMAT-TERSE.14 trailing block argument MVP"
  - "does trailing block syntax introduce closures"
  - "what helper is first for trailing block arguments"
  - "is with value trailing block syntax accepted yet"
  - "why is bare with block deferred"
  - "what is the next leaf for trailing block arguments"
date: 2026-07-07
status: current
tags: [spec-format-terse, block-arguments, code-blocks, closures, task-tree]
evidence: "docs/tasks/SPEC-FORMAT-TERSE.md .14/.14.1/.14.2; perl/LinkedSpec/ActionIR/AST/Parser.pm; perl/LinkedSpec/ActionIR/MethodLowering.pm; t/phase0_regression.t spec_format_terse_14_2_perl_helper_trailing_block_arguments"
reverify: "rg -n 'SPEC-FORMAT-TERSE\\.14\\.2|trailing_block_arg|spec_format_terse_14_2|with\\(value\\)|with\\(\\)' docs/tasks/SPEC-FORMAT-TERSE.md perl/LinkedSpec/ActionIR/AST/Parser.pm perl/LinkedSpec/ActionIR/MethodLowering.pm t/phase0_regression.t docs/linkedspec-book/src"
---

`SPEC-FORMAT-TERSE.14` owns trailing code blocks as final helper/receiver arguments.
It was reactivated by the user on 2026-07-07 and split before code in `.14.1`.
`.14.2` shipped the Perl reference helper-form surface.

The MVP is an immediate callback argument, not a closure. Blocks are not assignable,
not returnable, and not callable later. The first implementation target is helper-form
`with(value) { ... }`: evaluate `value`, bind scoped scalar `value` during immediate
block execution, restore any prior binding afterward, and return the block result.
`with() { ... }` binds `value` to `undef`. `return(expr)` inside the block is
block-local. The AST parser flags trailing-block calls with `trailing_block_arg`;
MethodLowering accepts that flag only for `with`, and unknown trailing-block
callees emit an unsupported-helper diagnostic instead of raw fallback.

Bare `with { ... }` remains deferred because word-plus-brace is already a rule-body
lifecycle/code-block shape. Receiver `.with() { ... }`, Rust parity, and public
oracle closeout are separate children. The next implementation leaf is
`SPEC-FORMAT-TERSE.14.3` for Rust helper-form parity.
