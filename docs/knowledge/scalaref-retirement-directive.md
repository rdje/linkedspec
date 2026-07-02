---
id: scalaref-retirement-directive
title: scalaref(...) is removal-bound; SCALAREF-RETIREMENT owns migration, implementation removal, and final drift cleanup
answers:
  - "should scalaref be retired"
  - "which task tree owns scalaref removal"
  - "what replaces scalaref"
  - "why was scalaref restored in Rust if it is being removed"
  - "what is the next scalaref retirement leaf"
  - "when can scalaref removal code changes start"
date: 2026-07-02
status: confirmed
tags: [dsl, retirement, scalaref, task-tree, compatibility]
evidence: "User directive on 2026-07-02: scalaref() shall be retired/removed. SCALAREF-RETIREMENT.1 creates docs/tasks/SCALAREF-RETIREMENT.md and indexes it from docs/TASK_TREE.md. SCALAREF-RETIREMENT.2 completes the inventory/replacement contract. RUST-PARITY.7.5.2 restored Rust parity for current shipped Lispish behavior only; the retirement tree owns migration/removal."
reverify: "rg -n 'SCALAREF-RETIREMENT|scalaref\\(\\.\\.\\.\\).*retired|scalaref\\(\\.\\.\\.\\).*removed|scalaref\\(\\.\\.\\.\\) shall' docs/TASK_TREE.md docs/tasks/SCALAREF-RETIREMENT.md ROADMAP_V2.md MEMORY.md"
---

# `scalaref(...)` Retirement Directive

`scalaref(...)` is removal-bound. The active owner is
`SCALAREF-RETIREMENT`, created after the 2026-07-02 user directive that
`scalaref()` shall be retired and removed.

This does not undo `RUST-PARITY.7.5.2`. That earlier slice restored Rust parity for the
current shipped Lispish surface, including legacy `scalaref(retv, {content})` path reads.
The retirement tree changes the future language contract; it must proceed separately.

The next executable leaf is `SCALAREF-RETIREMENT.3`: migrate shipped specs, tests,
oracle fixtures, and public docs away from `scalaref(...)` before implementation removal.

Expected replacement direction is direct nested access where it expresses the current path
reads. The `.2` inventory card records the exact function-form and receiver-dot
replacement contract.
