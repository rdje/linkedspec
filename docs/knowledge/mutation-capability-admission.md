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
status: portable capability admission complete under FUTURE-PARITY-BACKLOG.19.7; recurrence/public closeout remain .19.8-.19.9
tags: [capability, portability, mutation, autovivification, map-leaves, governance, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.19.7 adds language.nested_write_vivification and language.map_leaves_receiver_mutation immediately after language.standalone_lifecycle_block. Both are language-runtime rows with pass status and exact production/test references for Perl, Rust, Dart, Julia, and shared Lua; the Lua note requires independent PUC Lua and LuaJIT execution. The manifest advances from 18 capabilities / 90 pass states to 20 / 100 with zero partial and zero gap. tools/check_capability_conformance.pl pins the two row contracts, sources, ordering, backend evidence, Lua note, active/done owner, both frozen authority IDs/formats/statuses/canonical JSON digests, and the composition ID plus required paths/digests through 16 rejected admission mutations. The neutral files retain their original future-neutral status strings because .19.7 records later admission externally instead of rewriting frozen historical bytes. Recurring six-runtime execution is separately owned by .19.8; public-current examples, final no-drift, parent closeout, and push are .19.9."
reverify: "perl tools/check_capability_conformance.pl && bash tools/run_python_project_data.sh tools/check_write_vivification_contract.py && bash tools/run_python_project_data.sh tools/check_map_leaves_mutation_contract.py && perl tools/read_task_tree.pl --tree FUTURE-PARITY-BACKLOG --id FUTURE-PARITY-BACKLOG.19.7"
---

# Mutation capability admission

Nested write vivification and `map_leaves!` are portable capabilities once `.19.7` lands. The capability manifest
contains one row for each mechanism, not a third row for their composition. Each row is green across Perl, Rust,
Dart, Julia, and Lua; the shared Lua implementation is independently exercised by PUC Lua and LuaJIT.

The frozen neutral contracts deliberately retain their original status strings and bytes. Admission is a later
governance fact represented by the capability rows, exact implementation references, and a checker that digest-
binds both authorities plus their shared composition dependency. This preserves the historical freeze boundary
while making current capability truth unambiguous.

Capability admission is not the recurring execution layer. `.19.8` owns one routed Perl/Rust/Dart/Julia/PUC-Lua/
LuaJIT driver and canonical registration. `.19.9` owns final public-current examples, no-drift, parent `.19`
closeout, and the push boundary.

Related: [[write-vivification-neutral-contract]], [[map-leaves-mutation-neutral-contract]],
[[write-map-leaves-neutral-composition]], [[write-vivification-receiver-mutation-direction]], and ADR `0036`.
