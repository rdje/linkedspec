---
id: terse-type-method-surface-backlog
title: "SPEC-FORMAT-TERSE.7 owns and closes the supported-type method audit/backfill, including string substr() verification."
answers:
  - "which task owns the type method audit"
  - "which task owns helper to method backfill"
  - "should useful helpers become methods on supported types"
  - "where is substr as a string method tracked"
  - "is substr a string receiver method"
date: 2026-07-04
status: current
tags: [spec-format-terse, methods, receiver-chain, substr, task-tree]
evidence: "The user clarified on 2026-07-03 that new directives become backlog unless they are the active leaf, then directed that `substr()` shall be a method on string type too and that supported types should be audited for useful helper-to-method candidates. SPEC-FORMAT-TERSE.7 owned and closed that backlog: .7.1 inventoried supported value/receiver families and helper candidates before code; .7.2 verified that string/scalar receiver methods including `substr()` were already implemented on Perl/Rust; .7.3 added terminal array/list numeric reducer receiver methods (`sum`, `avg`, `median`, `range`, `min`, `max`) while keeping hash/number mutation or ambiguous helpers explicit; and .7.4 closed the no-drift sweep across roadmap, task-tree, mdBook, examples, tests, and Knowledge Map. Existing SPEC-FORMAT-TERSE.2.3.5.3 had recorded string/scalar receiver value chains and listed `substr` among string-returning links, but .7.1/.7.2 were the explicit audit/backfill owners."
reverify: "rg -n 'SPEC-FORMAT-TERSE\\.7|SPEC-FORMAT-TERSE\\.7\\.1|SPEC-FORMAT-TERSE\\.7\\.2|SPEC-FORMAT-TERSE\\.7\\.3|SPEC-FORMAT-TERSE\\.7\\.4|substr\\(\\)' docs/tasks/SPEC-FORMAT-TERSE.md docs/TASK_TREE.md ROADMAP_V2.md docs/knowledge/terse-type-method-surface-backlog.md"
---

# Terse Type Method Surface Backlog

`SPEC-FORMAT-TERSE.7` owned the supported-type method audit and backfill after the `.6`
declaration/helper/wrapper migration lane. The lane is now closed.

`.7.1` inventoried supported value and receiver families, mapped existing helpers to reasonable method
candidates, and identified helpers that should remain function-only. `.7.2` verified string/scalar receiver
methods, including `substr()`, with no code change. `.7.3` added terminal array/list numeric reducer receiver
methods and kept hash/number mutation or ambiguous helpers explicit. `.7.4` reconciled drift and closed the lane.
