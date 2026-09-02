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
evidence_update_2026_07_29_readme_routing: "README-STABILITY-POLICY.1 removes two duplicate historical selector mentions from root README while keeping README in the discovered 59-file public scan. The exact current classified count becomes 25 with zero current examples; canonical migration history remains in the guide/mdBook/Knowledge owners."
evidence_update_2026_08_25_staged_ast_enrichment_page: "FUTURE-PARITY-BACKLOG.14.7.2 adds compiler/staged-ast-enrichment.md to the discovered mdBook surface. The public selector checker reviews the new chapter, advances the exact inventory to 60 files, and keeps classified/current selector counts at 25/0."
evidence_update_2026_08_29_codegen_inspector_page: "FUTURE-PARITY-BACKLOG.13.1 adds development/codegen-inspector.md to the discovered mdBook surface. The exact staged canonical gate catches the resulting cardinality change; the checker now locks 61 public files while classified/current selector counts remain 25/0."
evidence_update_2026_08_30_migration_contrasts: "FUTURE-PARITY-BACKLOG.23.1 restores two rejected selector examples plus five ordered old-to-new mappings that ac217f6c had mechanically collapsed. The checker now validates the uniquely bounded migration section through eleven in-memory contrast mutations and reports 61 public files / 32 classified historical references / zero current examples."
evidence_update_2026_09_02_macos_latency_page: "FUTURE-PARITY-BACKLOG.19.3.4.0 added development/macos-rust-launch-latency.md to the discovered mdBook surface. The exact staged canonical gate for .19.4.1 caught the stale cardinality guard; the checker now locks 62 public files while classified/current selector counts remain 32/0."
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
root README/roadmaps/architecture state, capability guide, and every mdBook source page. Its exact current inventory
is 62 public files. It composes the runtime/source retirement checker so public and executable admission cannot
diverge. Its current inventory is 32 genuine removed/history references and zero current examples. Seven concrete
retired spellings are confined to one uniquely bounded migration section: two rejected examples and five ordered
old-to-new contrasts guarded by eleven in-memory mutations. Four earlier counted occurrences were prose false
positives and two later duplicate root-README history mentions were routed to canonical owners.

The capability census already proves every current language surface on all four census backends at 64/0/0; the
separate Lua rejection proof is locked by the aggregate-retirement checker. Therefore selector retirement is no
longer listed under `excluded_or_future`.

Related facts: [[aggregate-selector-retirement-no-drift]],
[[spec-facing-aggregate-selector-retirement-inventory]], [[uniform-binding-neutral-contract]].
