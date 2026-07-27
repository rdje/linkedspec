---
id: aggregate-selector-public-admission
title: "Public LinkedSpec authoring admits bare typed bindings and classifies removed selector mentions"
answers:
  - "is aggregate selector retirement fully admitted"
  - "can public docs still show array name or hash name as current syntax"
  - "which checker prevents aggregate selector documentation drift"
  - "why are removed selector spellings still visible in some documentation"
date: 2026-07-12
status: current
tags: [language, bindings, retirement, documentation, capability, no-drift]
evidence: "FUTURE-PARITY-BACKLOG.12.1.9 adds tools/check_public_aggregate_selector_surface.py and registers it in canonical local CI. The checker scans 47 root/capability/mdBook public files, requires every exact selector-shaped mention to carry explicit removed/rejected/migrated historical context, forbids stale future/remaining-backend status, requires current bare set/push/copy examples, removes future.uniform_binding_selector_retirement from capability_conformance/manifest.json, and composes the five-backend runtime/source checker plus the 60/0/0 capability checker. On 2026-07-12 it classifies 31 removed/history references, reports zero current public examples, and passes canonical CLI 61x2 plus Phase 0 1031/1031 in 626 seconds."
evidence_update_2026_07_12_lua_array_closeout: "LUA-BACKEND-PARITY.4.3.4.6 reworded four formal-grammar array end-mutation comments from `named working array (statement)` to explicit updated-snapshot semantics. The public check's code-block recognizer had counted each prose fragment `array (statement)` as an exact selector shape, so the corrected inventory is 27 genuine removed/history references, not 31. The expected count and capability guide now lock 27; all 27 retain explicit negative context and current examples remain zero."
reverify: "bash tools/run_python_project_data.sh tools/check_public_aggregate_selector_surface.py"
---

# Aggregate-selector public admission

Uniform-binding selector retirement is fully admitted. Current `.spec` guidance uses bare typed bindings:
`set(items, [])`, `push(items, value)`, `copy(items)`, `items = [...]`, and `meta = {...}`. Exact one-bare-name
`array(...)` / `hash(...)` calls are not compatibility forms or typed reads; all five backends reject them before
execution with `aggregate_selector_removed`.

Public documentation may retain the removed spelling only to state a boundary, explain a migration, or preserve a
clearly historical milestone. It may not present the spelling as an accepted example, a remaining compatibility
surface, or future work. `tools/check_public_aggregate_selector_surface.py` enforces that distinction across the
root README/roadmaps/architecture state, capability guide, and every mdBook source page. It composes the runtime/
source retirement checker so public and executable admission cannot diverge. Its current inventory is 27 genuine
removed/history references; four earlier counted occurrences were prose false positives shaped as
`array (statement)` inside the formal-grammar code block.

The capability census already proves every current language surface on all four census backends at 64/0/0; the
separate Lua rejection proof is locked by the aggregate-retirement checker. Therefore selector retirement is no
longer listed under `excluded_or_future`.

Related facts: [[aggregate-selector-retirement-no-drift]],
[[spec-facing-aggregate-selector-retirement-inventory]], [[uniform-binding-neutral-contract]].
