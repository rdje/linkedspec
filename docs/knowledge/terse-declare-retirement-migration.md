---
id: terse-declare-retirement-migration
title: "declare(...) is retired on current runtimes; SPEC-FORMAT-TERSE.6 migrated sources and SPEC-FORMAT-TERSE.8 hard-retired compatibility."
answers:
  - "should declare be used in spec files"
  - "what replaces declare in terse spec format"
  - "which task owns declare retirement"
  - "is lib_reader declare a runtime bug or terse migration"
  - "how many shipped specs still use declare"
date: 2026-07-03
status: confirmed
tags: [spec-format-terse, declare, migration, task-tree, dsl]
evidence: "SPEC-FORMAT-TERSE.6.1 created on 2026-07-03 after the user directive that `declare(...)` shall not be used in spec files because the terse format has replacements. The active inventory command `rg -n '(^|[.{;[:space:]])declare\\(' specs` found 70 hits across 13 shipped specs. SPEC-FORMAT-TERSE.6.2.1 then removed active `declare(...)` / `.declare(...)` use from shipped specs; `rg -n 'declare\\(|\\.declare\\(' specs` is clean, focused descriptor compilation passed, phase0 was 1018 green, and the Rust corpus oracle passed over 66 fixtures. This is owned by `SPEC-FORMAT-TERSE`, not `RUST-PARITY`: `.1.1` already landed auto-existing variables, `.1.3` landed mutation forms, `.1.2.3.5` historically landed direct RHS shape target-kind inference, `.3.3` landed expression-valued assignment forms, and `.11.2`/`.11.3` later superseded the storage-class inference part with duck-typed value binding. `.6.2.2` migrated old helper spellings; `.6.3` swept docs/corpus/tests; `.6.4` and ADR 0018 originally decided compatibility retention after live spec/example use was gone."
evidence_update_2026_07_07: "SPEC-FORMAT-TERSE.8 superseded the `.6.4` compatibility-retention decision for this unreleased project. Perl `.8.3` and Rust `.8.4` now diagnose `declare(...)` and declaration aliases as retired helpers. Current authoring uses terse replacements only."
reverify: "rg -n 'declare\\(|\\.declare\\(' specs || true; rg -n 'SPEC-FORMAT-TERSE\\.8\\.3|SPEC-FORMAT-TERSE\\.8\\.4' docs/tasks/SPEC-FORMAT-TERSE.md docs/TASK_TREE.md ROADMAP_V2.md docs/knowledge/terse-declaration-helper-compatibility-policy.md; cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime helpers_5_1_retired_terse_8_4_spellings_diagnose --quiet"
---

# Terse Declare Retirement Migration

`declare(...)` is retired on current runtimes. The replacement is not a broader runtime
implementation of declaration keyword initializers; the replacement is the terse format already
landed in `SPEC-FORMAT-TERSE`:

- scalar initialization: `name = value`;
- array initialization/reset: `items = []` or `items = [value]` binds an array value to `items`;
- hash initialization/reset: `meta = {}` or `meta = { key => value }` binds a hash value to `meta`;
- array append on first use: `items += value`;
- hash mutation on first use: `meta[key] = value`;
- type-implying reads through accepted helper positions and direct path atoms.

The migration owner is `SPEC-FORMAT-TERSE.6`, with shipped specs first (`.6.2`), public
docs/corpus/tests second (`.6.3`), and compatibility-support policy last (`.6.4`).

As of `SPEC-FORMAT-TERSE.8.4`, active shipped specs, current-facing mdBook examples, and root corpus examples no
longer use declaration helpers as normal authoring syntax, and both current runtimes diagnose declaration helpers
instead of executing them successfully. See [[terse-declaration-helper-compatibility-policy]] for the hard-retirement
policy.
