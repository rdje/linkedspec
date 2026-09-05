---
id: mutation-capability-admission
title: "Nested write vivification and map_leaves bang are exact portable capabilities"
answers:
  - "are nested write vivification and map_leaves bang portable"
  - "what is the capability census after mutation admission"
  - "which capability rows own write vivification and map_leaves bang"
  - "what pins mutation capability admission"
  - "why do admitted mutation contracts still say future neutral"
  - "does mutation capability admission run the recurring six runtime matrix"
  - "which tasks own mutation recurrence and public closeout"
date: 2026-09-04
status: portable capability admission .19.7, recurring six-runtime proof .19.8, and public closeout .19.9 complete
tags: [capability, portability, mutation, autovivification, map-leaves, governance, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.19.7 adds language.nested_write_vivification and language.map_leaves_receiver_mutation immediately after language.standalone_lifecycle_block. Both are language-runtime rows with pass status and exact production/test references for Perl, Rust, Dart, Julia, and shared Lua; the Lua note requires independent PUC Lua and LuaJIT execution. The manifest advances from 18 capabilities / 90 pass states to 20 / 100 with zero partial and zero gap. tools/check_capability_conformance.pl pins the two row contracts, sources, ordering, backend evidence, Lua note, active/done owner, both frozen authority IDs/formats/statuses/canonical JSON digests, and the composition ID plus required paths/digests through 16 rejected admission mutations. The neutral files retain their original future-neutral status strings because .19.7 records later admission externally instead of rewriting frozen historical bytes. Recurring six-runtime execution is separately owned by .19.8; public-current examples, final no-drift, parent closeout, and push are .19.9."
evidence_update_2026_09_05_recurring_proof: "FUTURE-PARITY-BACKLOG.19.8 completes the recurring layer without changing capability rows or frozen artifacts. One repository-routed driver checks both authorities, executes exact Perl/Rust/Dart/Julia/PUC-Lua/LuaJIT consumers, and then runs generated-source, capability, and language-coverage ledgers. Seventeen recurring mutations bind the three historical authority digests/statuses, exact route/support order, project-data initialization, owner, driver, and exact-one canonical CI registration. Public-current examples, parent closeout, and push remain .19.9."
evidence_update_2026_09_05_public_closeout: "FUTURE-PARITY-BACKLOG.19.9 publishes exact current examples and closes parent .19 without changing the admitted capability rows or frozen authorities. tools/check_mutation_public_surface.py inventories 63 public Markdown files, requires 14 governed documents and eleven semantic example classes, rejects ten stale-current claims, and rejects 50 authority/document/status mutations. Canonical CI runs it unconditionally; the capability checker pins its owner and exact-one registration."
reverify: "bash tools/check_mutation_six_runtime.sh && perl tools/check_capability_conformance.pl && perl tools/read_task_tree.pl --tree FUTURE-PARITY-BACKLOG --id FUTURE-PARITY-BACKLOG.19.8"
---

# Mutation capability admission

Nested write vivification and `map_leaves!` are portable capabilities once `.19.7` lands. The capability manifest
contains one row for each mechanism, not a third row for their composition. Each row is green across Perl, Rust,
Dart, Julia, and Lua; the shared Lua implementation is independently exercised by PUC Lua and LuaJIT.

The frozen neutral contracts deliberately retain their original status strings and bytes. Admission is a later
governance fact represented by the capability rows, exact implementation references, and a checker that digest-
binds both authorities plus their shared composition dependency. This preserves the historical freeze boundary
while making current capability truth unambiguous.

Capability admission is distinct from recurring execution and public no-drift. `.19.8` supplies one routed Perl/
Rust/Dart/Julia/PUC-Lua/LuaJIT driver plus exact canonical registration. `.19.9` publishes the current examples,
adds recurring public no-drift, and closes parent `.19` without changing either capability row.

Related: [[write-vivification-neutral-contract]], [[map-leaves-mutation-neutral-contract]],
[[write-map-leaves-neutral-composition]], [[write-vivification-receiver-mutation-direction]], and ADR `0036`.
