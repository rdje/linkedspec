---
id: startup-codebase-reading-inventory
title: Startup reading uses an exhaustive Git baseline with bounded source ranges
answers:
  - how large is the required startup codebase reading
  - which code is excluded from startup reading
  - where is complete codebase reading coverage tracked
  - does startup reading include noncore and generated fixtures
  - how are startup reading ranges bounded
date: 2026-09-06
status: inventory complete; codebase reading incomplete; physical mdBook reading complete, formal alignment pending
tags: [continuity, reading, codebase, inventory, task-tree]
evidence: "SESSION-STARTUP-READING.3.1 inventories exact Git blobs at baeb984e36a94a15951cd23d4c52def5064cdaca: 2,547 entries / 52,084,744 stored bytes, including one excluded rgx gitlink, 50 book entries, 1,197 durable-memory entries, 28 root Markdown files, and 1,271 source/tool/fixture entries. Source lanes contain 22,332,523 bytes; 1,267 text entries have 565,122 LF delimiters and four pinned gzip inputs add 54,500 decoded LFs. Enumeration/decompression is not reading credit."
reverify:
  - "git ls-tree -r -l --full-tree baeb984e36a94a15951cd23d4c52def5064cdaca"
  - "git diff --name-only baeb984e36a94a15951cd23d4c52def5064cdaca HEAD"
---

# Recover the reading plan from Git and its task owner

`docs/tasks/SESSION-STARTUP-READING.md` owns the exact ordered, disjoint path selectors, baseline counts,
completed coverage, and executable frontier. The only director-excluded source tree is the `rgx` gitlink and its
nested dependencies. First-party Rust, generated modules, corpus JSON, legacy `noncore`, authored `.spec`,
`conf`, `ebnf`, `tablescript`, test suites, repository tooling, and pinned reference data remain accounted for.

Book files belong to `.4`; root guidance belongs to `.3.10` and the already completed roadmap/bootstrap owners.
Durable task/decision/Knowledge/history records retain their indexed retrieval lifecycle. They are not a second
source tree to read wholesale, and loading the generated Knowledge Map is not codebase comprehension.

Every reading child must name exact files and inclusive ranges before execution. Bound each at 1,500 decoded
text lines and 65,536 bytes, use smaller output chunks, and retain unread suffixes. A single over-limit line
needs explicit byte ranges. The first child `.3.2.1` owns the five facade/invocation/context files at 1,430
lines / 56,706 bytes. The overall codebase answer stays No until complete reading and final delta review.
The physical mdBook answer is now Yes: `.31` and `.3.2.42` preserve complete 50-file coverage; formal
`.4` alignment remains pending. `.3.2.50` reconciles this status wording without granting unread source credit.

Do not copy this inventory into an unbounded parallel manifest. Git stores the exact population and object
identities; the task-tree stores the selectors, ownership, range progress, and completion evidence.

Related: [[linkedspec-pm-is-thin-facade]], [[project-data-liveness-permission-denial]].

## September 6 planning pressure census

Before the native reading split, `.3.2.51` records the slice `.3.2.50` candidate's read-only task
collection census: 100 files / 76,699 lines / 7,789,885 bytes against 128 / 80,000 / 8,388,608.
The general task member limit is 8,000 lines / 1,048,576 bytes; the 5,000-line limits apply only to
explicitly listed future-parity parts. Recompute the resulting collection before adding native children
or their evidence. This measurement neither increases a limit nor requires a partition by itself.
The current route authority is `doctrine/readme_stability/routes.jsonl` surface `task_evidence`.
