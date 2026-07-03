---
id: terse-type-method-surface-backlog
title: "SPEC-FORMAT-TERSE.7 owns the supported-type method audit and backfill, including string substr() receiver-method verification."
answers:
  - "which task owns the type method audit"
  - "which task owns helper to method backfill"
  - "should useful helpers become methods on supported types"
  - "where is substr as a string method tracked"
  - "is substr a string receiver method"
date: 2026-07-03
status: confirmed
tags: [spec-format-terse, methods, receiver-chain, substr, task-tree]
evidence: "The user clarified on 2026-07-03 that new directives become backlog unless they are the active leaf, then directed that `substr()` shall be a method on string type too and that supported types should be audited for useful helper-to-method candidates. SPEC-FORMAT-TERSE.7 records that backlog: .7.1 inventories supported value/receiver families and helper candidates before code; .7.2 explicitly verifies or implements string/scalar receiver methods including `substr()`; .7.3 owns array/list, hash, and number method backfill; .7.4 closes docs/no-drift. Existing SPEC-FORMAT-TERSE.2.3.5.3 recorded string/scalar receiver value chains and listed `substr` among string-returning links, but .7.1/.7.2 are the new explicit audit/backfill owners before any further implementation or documentation expansion."
reverify: "rg -n 'SPEC-FORMAT-TERSE\\.7|SPEC-FORMAT-TERSE\\.7\\.1|SPEC-FORMAT-TERSE\\.7\\.2|substr\\(\\)' docs/tasks/SPEC-FORMAT-TERSE.md docs/TASK_TREE.md ROADMAP_V2.md docs/knowledge/terse-type-method-surface-backlog.md"
---

# Terse Type Method Surface Backlog

`SPEC-FORMAT-TERSE.7` owns the supported-type method audit and backfill. It is backlog after the `.6`
declaration/helper/wrapper migration lane unless the user explicitly reprioritizes it.

The first step is not code. `.7.1` must inventory the supported value and receiver families, map existing helpers
to reasonable method candidates, and identify helpers that should remain function-only. Then `.7.2` explicitly
verifies or implements string/scalar receiver methods, including `substr()`, before `.7.3` handles array/list,
hash, and number method candidates.
