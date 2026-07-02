---
id: scalaref-retirement-directive
title: scalaref(...) is removal-bound; SCALAREF-RETIREMENT owns inventory, migration, implementation removal, and final drift cleanup
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
evidence: "User directive on 2026-07-02: scalaref() shall be retired/removed. SCALAREF-RETIREMENT.1 creates docs/tasks/SCALAREF-RETIREMENT.md and indexes it from docs/TASK_TREE.md. RUST-PARITY.7.5.2 restored Rust parity for current shipped Lispish behavior only; the new tree owns removal after inventory/replacement/migration."
reverify: "rg -n 'SCALAREF-RETIREMENT|scalaref\\(\\.\\.\\.\\).*retired|scalaref\\(\\.\\.\\.\\).*removed|scalaref\\(\\.\\.\\.\\) shall' docs/TASK_TREE.md docs/tasks/SCALAREF-RETIREMENT.md ROADMAP_V2.md MEMORY.md"
---

# `scalaref(...)` Retirement Directive

`scalaref(...)` is removal-bound. The active owner is
`SCALAREF-RETIREMENT`, created after the 2026-07-02 user directive that
`scalaref()` shall be retired and removed.

This does not undo `RUST-PARITY.7.5.2`. That earlier slice restored Rust parity for the
current shipped Lispish surface, including legacy `scalaref(retv, {content})` path reads.
The retirement tree changes the future language contract; it must proceed separately.

The next executable leaf is `SCALAREF-RETIREMENT.2`: inventory every `scalaref(...)` use
and select the canonical replacement before editing shipped specs, public docs, Perl/Rust
parser/runtime behavior, or oracle fixtures.

Expected replacement direction is direct nested access where it expresses the current path
reads. Any gap tied to the existing Perl-shaped hash/object literal spelling must be named
by `.2` before removal work begins.
