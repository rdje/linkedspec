---
id: split-marker-cross-backend-semantics
title: Anonymous split-marker scope currently differs across Perl, Lua, Rust, Dart, and Julia
answers:
  - "is capture_slice marker behavior portable across backends"
  - "does move_pos execute on Rust Dart or Julia"
  - "is move_pos rule level or attached to the preceding regex"
  - "why does Lua split marker behavior differ from Perl"
  - "which backends execute split marker rule members"
  - "does mark name have the same scope as move_pos in Perl"
date: 2026-07-17
status: current divergence; reconciliation task-owned
tags: [capture, marker, move-pos, perl, rust, dart, julia, lua, parity, INTER-MATCH-GAP-CAPTURE]
evidence: "INTER-MATCH-GAP-CAPTURE.0 code audit: perl/LinkedSpec/RuleIR.pm lowers anonymous MOVE_POS unconditionally into LECODE while guarding MARK_POS by preceding regex index; Rust compiler drops SplitMarker and CompiledRule has no event/body field; Dart and Julia preserve source body elements but their native interpreters never consume them; Lua compiled_spec.lua creates preceding-slot rule_slot_events consumed post-action/pre-LE by interpreter.lua."
reverify: "rg -n 'MOVE_POS|MARK_POS' perl/LinkedSpec/RuleIR.pm && rg -n 'SplitMarker' rust/linkedspec-core/src/compiler.rs rust/linkedspec-core/src/types.rs && rg -n 'SplitMarkerBodyElementKind|bodyElements' dart/lib/src/compiler/compiled_spec.dart dart/lib/src/runtime/interpreter.dart && rg -n 'SplitMarkerBodyElementKind|body_elements' julia/src/compiler/CompiledSpec.jl julia/src/runtime/Interpreter.jl && rg -n 'rule_slot_events|execute_rule_slot_events' lua/src/linkedspec/compiled_spec.lua lua/src/linkedspec/interpreter.lua"
---

# Split-marker cross-backend semantics

The parsed spellings `@capture_slice`, `@capture_from_here`, `@move_pos`, and `@mark(name)` do not
currently have one five-backend execution contract.

- Perl maps all three anonymous spellings to `MOVE_POS`, then appends unconditional
  `$IPOS = pos $$STRING` to rule-level `LECODE`. Once present, that update runs after every successful
  action iteration in the rule. Perl's named `@mark(name)` lowering is different: it records the
  preceding regex index and guards its `LECODE` write with that matched index.
- Lua/LuaJIT compile both anonymous and named forms into typed events attached to the preceding regex
  slot and execute matching events after that slot's action/child dispatch and before `LE`.
- Rust parses `SplitMarker` but drops it during compilation; native `CompiledRule` has no retained
  body/event field, so the runtime has nothing to execute.
- Dart and Julia parse the forms and preserve original body elements in compiled/source state, but
  create no executable marker event and their native interpreters do not consume those body fields.

The Lua implementation is therefore a later positional reinterpretation, not parity with the
historical anonymous Perl rule-level rolling mechanism. Explicit action helpers such as
`start_capture_slice()` and `mark_here(name)` are separate surfaces and are not invalidated by this
finding.

`INTER-MATCH-GAP-CAPTURE.1` must define legacy migration and the neutral `@capture_gaps` contract from
this actual matrix. No current runtime behavior changes in the historical-recovery leaf.

## Links

- Owner: [[INTER-MATCH-GAP-CAPTURE]] `.0` audit and `.1` reconciliation.
- Historical contract: [[inter-match-gap-capture-origin-and-contract]].
- Earlier timing claim corrected by this audit: [[split-boundary-marker-action-timing]].
- Lua implementation fact: [[lua-rule-slot-marker-execution]].
