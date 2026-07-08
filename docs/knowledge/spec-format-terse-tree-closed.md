---
id: spec-format-terse-tree-closed
title: SPEC-FORMAT-TERSE parent task tree is closed
answers:
  - "is SPEC-FORMAT-TERSE closed"
  - "is there anything left in SPEC-FORMAT-TERSE"
  - "does SPEC-FORMAT-TERSE have a current PNT leaf"
  - "why is SPEC-FORMAT-TERSE not active"
date: 2026-07-08
status: current
tags: [spec-format-terse, task-tree, status, closeout, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.13.5 reconciled the parent terse-format task tree closed after SPEC-FORMAT-TERSE.13.4 left no current PNT-eligible leaf. docs/TASK_TREE.md and docs/tasks/SPEC-FORMAT-TERSE.md now mark the parent tree done/closed. Stale internal split-container rows that still looked active were converted to historical done/closed wording. Future terse-format work requires a newly activated/split leaf."
reverify: "rg -n 'SPEC-FORMAT-TERSE.*done.*closed|Status:.*done.*closed|SPEC-FORMAT-TERSE\\.13\\.5|no current PNT-eligible leaf|is SPEC-FORMAT-TERSE closed' docs/TASK_TREE.md docs/tasks/SPEC-FORMAT-TERSE.md docs/knowledge/spec-format-terse-tree-closed.md MEMORY.md && bash scripts/check_task_tree_metadata.sh"
---

`SPEC-FORMAT-TERSE` is closed as a parent task tree.

The last behavior/doc lane was array-tree traversal:

- `.13.2` landed the Perl reference implementation.
- `.13.3` landed Rust/oracle parity and the 97th oracle fixture.
- `.13.4` closed array-tree docs, Knowledge Map, live-doc, and oracle-count drift.
- `.13.5` reconciled the parent task-tree metadata from active-with-empty-frontier to `done` / `closed`.

There is no current PNT-eligible `SPEC-FORMAT-TERSE` leaf. Future terse-format work needs a new owned leaf.
