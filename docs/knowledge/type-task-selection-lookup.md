---
id: type-task-selection-lookup
title: Type-reference selection leaves resolve through the overview semantic part
answers:
  - "where do TYPE-REFERENCE-BOOK fluent selection leaves live"
  - "why does the type task index have no per-leaf ID entries"
  - "why does read_task_tree print the whole semantic part"
date: 2026-11-07
status: current routing/retrieval guidance under ADR0139
tags: [tasks, continuity, lookup, documentation]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.76.5 handoff; tools/read_task_tree.pl::owns_id and docs/tasks/TYPE-REFERENCE-BOOK.index.jsonl define routing. Stable selection23.1.36 and parent23.1 resolve through the canonical reader; pending selection37 is added to overview with parent Children continuity."
reverify: "perl tools/read_task_tree.pl --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.37 | sed -n '/^- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.37`/,+8p'"
---

The strict task index records semantic part paths, identities and bounds.
`tools/read_task_tree.pl::owns_id` resolves stable IDs by the registered numeric
routing policy; the index has no per-leaf ID list. TYPE-REFERENCE-BOOK IDs outside
helper-family children23.3 resolve to docs/tasks/TYPE-REFERENCE-BOOK.overview.md.
Fluent selection leaves23.1.N and their parent therefore live in overview;
helper-family76 children live in docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md.

The canonical reader validates the selected part's digest and exact ID presence,
then prints that complete semantic part. Use the stable-ID lookup first and a
bounded node/header filter for targeted recovery. The reverify command prints
selection37's initial fields; it is not a complete historical reading audit.
After editing either mutable owner, refresh the same-slice index with
`perl tools/update_task_tree_index.pl --tree TYPE-REFERENCE-BOOK`.
