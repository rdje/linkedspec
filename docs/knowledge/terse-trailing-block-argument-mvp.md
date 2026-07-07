---
id: terse-trailing-block-argument-mvp
title: "SPEC-FORMAT-TERSE.14 - trailing block arguments use immediate non-closure callbacks, starting with with(value)"
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
evidence: "docs/tasks/SPEC-FORMAT-TERSE.md .14/.14.1; docs/TASK_TREE.md active row and 2026-07-07 index note"
reverify: "rg -n 'SPEC-FORMAT-TERSE\\.14\\.1|with\\(value\\)|SPEC-FORMAT-TERSE\\.14\\.2|trailing block arguments' docs/tasks/SPEC-FORMAT-TERSE.md docs/TASK_TREE.md ROADMAP_V2.md"
---

`SPEC-FORMAT-TERSE.14` owns trailing code blocks as final helper/receiver arguments.
It was reactivated by the user on 2026-07-07 and split before code in `.14.1`.

The MVP is an immediate callback argument, not a closure. Blocks are not assignable,
not returnable, and not callable later. The first implementation target is helper-form
`with(value) { ... }`: evaluate `value`, bind scoped scalar `value` during immediate
block execution, restore any prior binding afterward, and return the block result.
`return(expr)` inside the block is block-local.

Bare `with { ... }` remains deferred because word-plus-brace is already a rule-body
lifecycle/code-block shape. Receiver `.with() { ... }`, Rust parity, and public
docs/KM/oracle closeout are separate children. The next implementation leaf is
`SPEC-FORMAT-TERSE.14.2`.
