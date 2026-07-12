---
id: terse-trailing-block-argument-mvp
title: "SPEC-FORMAT-TERSE.14 - trailing block arguments use immediate non-closure callbacks, with Perl/Rust helper-function and receiver-method with support"
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
  - "is SPEC-FORMAT-TERSE.14 closed"
  - "what closed the trailing block argument no-drift sweep"
date: 2026-07-07
status: current
tags: [spec-format-terse, block-arguments, code-blocks, closures, task-tree]
evidence: "docs/tasks/SPEC-FORMAT-TERSE.md .14/.14.1/.14.2/.14.3/.14.4/.14.5; ROADMAP_V2.md; perl/LinkedSpec/ActionIR/AST/Parser.pm; perl/LinkedSpec/ActionIR/MethodLowering.pm; t/actionir_ast_parser.t; t/phase0_regression.t spec_format_terse_14_2_perl_helper_trailing_block_arguments and spec_format_terse_14_4_perl_receiver_trailing_block_arguments; rust/linkedspec-core/src/expr.rs; rust/linkedspec-runtime/src/engine.rs; rust/linkedspec-runtime/tests/integration_test.rs terse_14_3_* and terse_14_4_*; rust/linkedspec-runtime/tests/corpus/terse_14_3_with_helper_trailing_block; rust/linkedspec-runtime/tests/corpus/terse_14_4_receiver_with_trailing_block; docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md; docs/linkedspec-book/src/appendix/helper-contract-catalog.md"
reverify: "rg -n 'SPEC-FORMAT-TERSE\\.14\\.5|receiver_trailing_block_arg|spec_format_terse_14_4|terse_14_4|\\.with\\(\\) \\{' docs/tasks/SPEC-FORMAT-TERSE.md ROADMAP_V2.md perl/LinkedSpec/ActionIR/AST/Parser.pm perl/LinkedSpec/ActionIR/MethodLowering.pm t/actionir_ast_parser.t t/phase0_regression.t rust/linkedspec-core/src/expr.rs rust/linkedspec-runtime/src/engine.rs rust/linkedspec-runtime/tests/integration_test.rs docs/linkedspec-book/src && rg -n '\"case_count\" : 99|terse_14_4_receiver_with_trailing_block' rust/linkedspec-runtime/tests/corpus/manifest.json"
---

`SPEC-FORMAT-TERSE.14` owns trailing code blocks as final helper-function or receiver-method arguments.
It was reactivated by the user on 2026-07-07 and split before code in `.14.1`.
`.14.2` shipped the Perl reference helper-function form surface, `.14.3` shipped the
Rust helper-function parity surface plus an oracle fixture, `.14.4` shipped
receiver-method form `.with() { ... }` on Perl and Rust plus the 95th oracle fixture,
and `.14.5` closed the mdBook/Knowledge Map/oracle/no-drift sweep for the
shipped `.14` surface.

This card remains the factual record of the currently implemented MVP, but its abstraction is superseded for
future design by [[generic-trailing-codeblock-argument-correction]]. Director clarification on 2026-07-10 defines
codeblock as the fourth object/value kind and requires attached `call(args) { block }` to be equivalent to
parenthesized `call(args, { block })` for any callable signature accepting a final codeblock, on every backend.
ADR 0031 and completed `FUTURE-PARITY-BACKLOG.11.1` now select `{|args| body }` callable literals, dynamic caller
context without lexical capture, and retained `with`. Neutral contract `.11.2` is adopted and checked. Perl now
preserves inert explicit literals, but invocation `.11.3.2` and generic final-block behavior have not landed.

The MVP is an immediate callback argument, not a closure. Blocks are not assignable,
not returnable, and not callable later. The first implementation target is helper-function form
`with(value) { ... }`: evaluate `value`, bind scoped scalar `value` during immediate
block execution, restore any prior binding afterward, and return the block result.
`with() { ... }` binds `value` to `undef`. `return(expr)` inside the block is
block-local. The trailing block executes in the caller's current action/runtime
context: captures, `retv`, cursor state, helper/function visibility, and ordinary
working-variable side effects are shared with the call site. Only the scalar
binding `value` is portable as the scoped block parameter in the MVP; mutations
to other variable names persist.
The AST parser flags helper-function form trailing-block calls with `trailing_block_arg`;
MethodLowering accepts that flag only for `with`, and unknown trailing-block
callees emit an unsupported-helper diagnostic instead of raw fallback. The Rust
parser appends a trailing `BlockValue` only for helper-function form `with(...) { ... }`;
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
lifecycle/code-block shape. `SPEC-FORMAT-TERSE.14` is closed after `.14.5`; future
expansions such as bare `with { ... }`, explicit receiver `.with(value) { ... }`,
closures, delayed callbacks, or arbitrary non-`with` trailing blocks need a new
owned leaf before implementation.
