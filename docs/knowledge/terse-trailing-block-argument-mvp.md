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
date: 2026-10-30
status: historical MVP implementation; current scoped with follows the generic contract
tags: [spec-format-terse, block-arguments, code-blocks, closures, task-tree]
evidence: "docs/tasks/SPEC-FORMAT-TERSE.md .14/.14.1/.14.2/.14.3/.14.4/.14.5; ROADMAP_V2.md; perl/LinkedSpec/ActionIR/AST/Parser.pm; perl/LinkedSpec/ActionIR/MethodLowering.pm; t/actionir_ast_parser.t; t/phase0_regression.t spec_format_terse_14_2_perl_helper_trailing_block_arguments and spec_format_terse_14_4_perl_receiver_trailing_block_arguments; rust/linkedspec-core/src/expr.rs; rust/linkedspec-runtime/src/engine.rs; rust/linkedspec-runtime/tests/integration_test.rs terse_14_3_* and terse_14_4_*; rust/linkedspec-runtime/tests/corpus/terse_14_3_with_helper_trailing_block; rust/linkedspec-runtime/tests/corpus/terse_14_4_receiver_with_trailing_block; docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md; docs/linkedspec-book/src/appendix/helper-contract-catalog.md"
reverify: "Recover current-only selector/names and public producer from perl-phase0-receiver-blocks-oracle-intake.json.gz; run bash tools/project_data_run.sh env PERL5LIB= perl -Iperl .linkedspec-data/verification/probe_phase0_current_selected.pl .linkedspec-data/verification/phase0-receiver-blocks-oracle-names.json .linkedspec-data/verification/receiver-block-current-seen.json. Use the existing generic contract/result records for broader contexts; historical corpus counts are not current gates."
---

`SPEC-FORMAT-TERSE.14` owns the original trailing code blocks as final helper-function or receiver-method arguments.
It was reactivated by the user on 2026-07-07 and split before code in `.14.1`.
`.14.2` shipped the Perl reference helper-function form surface, `.14.3` shipped the
Rust helper-function parity surface plus an oracle fixture, `.14.4` shipped
receiver-method form `.with() { ... }` on Perl and Rust plus the 95th oracle fixture,
and `.14.5` closed the mdBook/Knowledge Map/oracle/no-drift sweep for the
shipped `.14` surface.

This card records the original MVP. Its scoped `with` behavior remains supported, while the implemented
generic contract supersedes the original parser architecture; see [[generic-trailing-codeblock-argument-correction]]. Director clarification on 2026-07-10 defines
codeblock as the fourth object/value kind and requires attached `call(args) { block }` to be equivalent to
parenthesized `call(args, { block })` for any callable signature accepting a final codeblock, on every backend.
ADR 0031 and completed `FUTURE-PARITY-BACKLOG.11.1` now select `{|args| body }` callable literals, dynamic caller
context without lexical capture, and retained `with`. Neutral contract `.11.2` is adopted and checked. Perl now
preserves and dynamically invokes explicit literals and normalizes declared generic final blocks. Lua now executes
metadata-governed helper/receiver `with` in attached and parenthesized contextual form; complete generic callable
parity remains separately owned.

The MVP is an immediate callback argument, not a closure. Blocks are not assignable,
not returnable, and not callable later. The first implementation target is helper-function form
`with(value) { ... }`: evaluate `value`, bind scoped working value `value` during immediate
block execution, restore any prior binding afterward, and return the block result.
`with() { ... }` binds `value` to `undef`. `return(expr)` inside the block is
block-local. The trailing block executes in the caller's current action/runtime
context: captures, `retv`, cursor state, helper/function visibility, and ordinary
working-variable side effects are shared with the call site. Only the working
binding `value` is portable as the scoped block parameter in the MVP; mutations
to other variable names persist.
At the original MVP boundary, the AST parser flagged helper-function trailing blocks with `trailing_block_arg`;
MethodLowering accepted that flag only for `with`, and unknown trailing-block
callees emitted an unsupported-helper diagnostic instead of raw fallback. The Rust
parser then appended a trailing `BlockValue` only for helper-function `with(...) { ... }`.
The scoped runtime evaluated that body lazily, bound `value`, and restored the prior
same-name stores afterward, and used existing expression-valued block return
semantics.

Receiver `.with() { ... }` is also current on Perl, Rust, Dart, Julia, and Lua. It evaluates the
receiver first, exposes that receiver value as scoped working binding `value` while the
block executes immediately, restores the surrounding binding afterward, and
returns the block result. The result can be terminal or can continue into later
compatible receiver-family links, such as a string result flowing into `.trim()`
or an array result flowing into `.count()`. Explicit receiver
`.with(value) { ... }` is rejected/deferred; receiver form takes the receiver
itself as the only block input.

Bare `with { ... }` remains deferred because word-plus-brace is already a rule-body
lifecycle/code-block shape. `SPEC-FORMAT-TERSE.14` is closed after `.14.5`. Bare
`with { ... }` and explicit receiver `.with(value) { ... }` keep their boundaries.
Explicit callable values and metadata-governed generic final codeblocks follow the
implemented generic contract, rather than the original MVP exclusions. Closures
remain outside that no-capture callable model.

TYPE45.22 reconciles only two old selected-result source envelopes/16 healthy
assertions ->18 GREEN. Original four runtime sources and all healthy controls
remain exact; public native/fresh eight cases preserve String/Array results,
scope restoration and metadata/error fences without production changes. Helper
initialization controls and original action-edge sources keep their distinct
contexts. See [[ordinary-with-hash-result-continuation]] for broader result and
callback qualifications; no new peer/context/deferred admission is inferred.
