---
id: scalaref-retirement-directive
title: scalaref(...) is retired and removed; SCALAREF-RETIREMENT owns final drift cleanup
answers:
  - "should scalaref be retired"
  - "which task tree owns scalaref removal"
  - "what replaces scalaref"
  - "why was scalaref restored in Rust if it is being removed"
  - "what is the next scalaref retirement leaf"
  - "when can scalaref removal code changes start"
  - "is scalaref still supported"
date: 2026-07-02
status: confirmed
tags: [dsl, retirement, scalaref, task-tree, compatibility]
evidence: "User directive on 2026-07-02: scalaref() shall be retired/removed. SCALAREF-RETIREMENT.1 created docs/tasks/SCALAREF-RETIREMENT.md and indexed it from docs/TASK_TREE.md. SCALAREF-RETIREMENT.2 completed the inventory/replacement contract, .3 migrated live specs/tests/corpus/docs, and .4 removed Perl/Rust implementation support. RUST-PARITY.7.5.2 restored Rust parity only as temporary pre-retirement behavior."
reverify: "rg -n 'SCALAREF-RETIREMENT.4|scalaref.*retired|scalaref.*removed|SCALAREF-RETIREMENT.5' docs/TASK_TREE.md docs/tasks/SCALAREF-RETIREMENT.md ROADMAP_V2.md MEMORY.md"
---

# `scalaref(...)` Retirement Directive

`scalaref(...)` is retired and implementation support has been removed. The active
owner is `SCALAREF-RETIREMENT`, created after the 2026-07-02 user directive that
`scalaref()` shall be retired and removed.

This does not undo the historical value of `RUST-PARITY.7.5.2`. That earlier slice
restored Rust parity for the then-current shipped Lispish surface. The retirement tree
then changed the language contract: `.3` migrated live uses to direct access and `.4`
removed recognition/execution.

The next executable leaf is `SCALAREF-RETIREMENT.5`: final no-drift sweep and tree
close-out.

Replacement direction is direct nested access where it expresses scalar payload path
reads. The `.2` inventory card records the exact function-form and receiver-dot
replacement contract; the `.4` implementation card records current rejection behavior.
