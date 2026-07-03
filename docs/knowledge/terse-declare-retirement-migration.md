---
id: terse-declare-retirement-migration
title: "declare(...) is retirement-bound for spec files; SPEC-FORMAT-TERSE.6 owns migrating live specs to auto-existing variables, assignments, direct shape literals, and type-implying terse positions"
answers:
  - "should declare be used in spec files"
  - "what replaces declare in terse spec format"
  - "which task owns declare retirement"
  - "is lib_reader declare a runtime bug or terse migration"
  - "how many shipped specs still use declare"
date: 2026-07-03
status: confirmed
tags: [spec-format-terse, declare, migration, task-tree, dsl]
evidence: "SPEC-FORMAT-TERSE.6.1 created on 2026-07-03 after the user directive that `declare(...)` shall not be used in spec files because the terse format has replacements. The active inventory command `rg -n '(^|[.{;[:space:]])declare\\(' specs` found 70 hits across 13 shipped specs. SPEC-FORMAT-TERSE.6.2.1 then removed active `declare(...)` / `.declare(...)` use from shipped specs; `rg -n 'declare\\(|\\.declare\\(' specs` is clean, focused descriptor compilation passes for the edited shipped specs, phase0 is 1018 green, and the Rust corpus oracle passes over 66 fixtures. This is owned by `SPEC-FORMAT-TERSE`, not `RUST-PARITY`: `.1.1` already landed auto-existing variables, `.1.3` landed mutation forms, `.1.2.3.5` landed direct RHS shape target-kind inference, and `.3.3` landed expression-valued assignment forms. `.6.2.2` migrates old helper spellings; `.6.3` sweeps docs/corpus/tests; `.6.4` decides compatibility support after live spec use is gone."
reverify: "rg -n 'declare\\(|\\.declare\\(' specs || true; rg -n 'SPEC-FORMAT-TERSE\\.6\\.2\\.1|SPEC-FORMAT-TERSE\\.6\\.4' docs/tasks/SPEC-FORMAT-TERSE.md docs/TASK_TREE.md ROADMAP_V2.md docs/knowledge/terse-declare-retirement-migration.md"
---

# Terse Declare Retirement Migration

`declare(...)` is retirement-bound for spec files. The replacement is not a broader runtime
implementation of declaration keyword initializers; the replacement is the terse format already
landed in `SPEC-FORMAT-TERSE`:

- scalar initialization: `name = value`;
- array initialization/reset: `items = []` or `items = [value]`;
- hash initialization/reset: `meta = {}` or `meta = { key => value }`;
- array append on first use: `items += value`;
- hash mutation on first use: `meta[key] = value`;
- type-implying reads through accepted helper positions and direct path atoms.

The migration owner is `SPEC-FORMAT-TERSE.6`, with shipped specs first (`.6.2`), public
docs/corpus/tests second (`.6.3`), and compatibility-support policy last (`.6.4`).

As of `SPEC-FORMAT-TERSE.6.2.1`, active shipped specs are declare-free. The next declaration-migration work is
old helper spelling cleanup, not runtime `declare(...)` expansion.
