---
id: method-like-dsl-migration-status
title: The method-like DSL migration track is mostly done — all 19 shipped specs at zero compatibility-surface rules, 100+ helpers across 10 families, cross-nesting parity deferred, compat aliases partially retired
answers:
  - "what is the method-like DSL migration status"
  - "are there compatibility-surface rules left"
  - "what helpers are available in the DSL"
  - "what is deferred in the DSL migration"
date: 2026-06-12
status: current
tags: [dsl, migration, status, roadmap]
evidence: "METHOD-LIKE-DSL-MIGRATION tree completed (5 leaves, 2026-05-17); COMPAT-ALIAS-RETIREMENT.1 done (4 short-term aliases retired); ROADMAP_V2.md Method-like track: mostly done"
reverify: "grep -c 'compatibility_surface.*0' docs/tasks/METHOD-LIKE-DSL-MIGRATION.md"
---

The method-like DSL migration track (`METHOD-LIKE-DSL-MIGRATION`, 5 leaves, completed 2026-05-17)
established a backend-neutral method-style `.spec` action syntax. Status:

**Done:**
- All 19 shipped specs at **zero compatibility-surface rules**
- **100+ helpers across 10 families**, all regression-locked on fluent-chain and structured-block surfaces
- Families: declare/assign, scalar ops, numeric ops, array ops, hash ops, control flow, return/flow, state access, predicates, I/O
- Fluent-chain and structured-block equivalence verified across the full lifecycle family (I/LS/LE/E/EX/IT/LX)
- Accumulator convention audited and confirmed healthy
- Legacy return-helper cleanup audited (zero migrations needed)
- Missing DSL features inventory complete (no concrete gaps for shipped corpus)

**Deferred:**
- Deeper cross-nesting parity (marker if/switch mutual nesting beyond current surface)
- Medium-term alias retirement (return_a, return_m, return_ma, return_imatch/return_im)

**Partially done:**
- Short-term alias retirement (tail, drop_last, flatten, array_values) removed 2026-06-12
- Medium-term aliases still present; ~692 test references block automated migration

Related: [[medium-term-alias-retirement-deferred]], [[accumulator-convention-healthy]].
