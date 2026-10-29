---
id: julia-blind-target-regex-projection
title: Julia blind declarations and regex dependencies have separate compiler checks
answers:
  - why did Julia reject blind targets without regex slots
  - can Julia call a pure-code blind child
  - how does Julia separate blind call dependencies from regex dependencies
  - does a Julia pure-code blind call create an entry slot
  - which Julia referenced blind push runtime cases remain open
date: 2026-10-29
status: bounded compiler repair48.4; blind parent-push48.4.1 next
tags: [julia, compiler, validation, blind, regex, dependency, entry-slot]
evidence: "julia-referenced-intake.json.gz retains36 source roles,17 compiler RED to22 valid builds/14 exact rejects,10 healthy runtime controls and3 separately owned push failures,22 fresh modules and575 selected assertions."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error julia/test/referenced_blind_targets_test.jl"
---

`julia/src/spec/Validator.jl` `_check_target` previously checked a regex slot
after every target lookup, including blind calls and bare AND members. It now
requires the declared target, then applies slot checks only for structural
action ownership. Existing source checks still reject unknown targets, indexed
blind calls and indexed bare AND members with unchanged diagnostic objects.

`julia/src/compiler/CompiledSpec.jl` `_build_dependency_regex_state` previously
resolved every call dependency to a regex. Exclusively blind owners now project
only targets with actual regex patterns into that map; their complete call refs
remain on the compiled rule. Unknown targets remain in the projection so lookup
still throws. Action and mixed owners retain full slot validation even with
source validation disabled. A real empty pattern `[""]` remains a regex slot;
an absent pattern list does not manufacture one. Existing Julia vector storage
semantics are unchanged.

Independent original12/qualified12/pure8/strict4 roles yielded5 healthy builds,
17 intended-valid compiler failures and14 intended rejects. Validator-only
repair accepted12 referenced roles and exposed5 pure-code dependency errors.
Final compilation accepts all22 valid roles;14 full rejection records and5
original healthy artifact/result records remain exact. Three validation-bypass
controls and one real-empty-pattern control also retain their exact results.

The10 runtime controls (qualified referenced4 plus pure6) pass native,
JSON-restored, plan and separate-process emitted routes. Pure children have0
patterns/slots and `entry_slot()` is null; the mixed sequence retains both call
refs but only Token/x in its regex map. All22 fresh modules preserve v2 metadata
and plan. Five original healthy and12 validator-epoch modules are reused;5
previously un-emittable pure sources are newly emitted. New180/postcall274/
duplicate slots121 pass575 assertions, focused/fresh stderr empty. Precompile
coordination output from earlier epochs is retained separately.

Qualified `blind_no_regex`, `marked_blind_target`, `markerless_blind` compile
but raise `push() in rule Top requires an action-edge child context` on native/
restored and the wrapped plan/fresh routes. `_require_runtime_action_edge_child!`
requires an action edge while blind post-call code has none. P1 `48.4.1` owns
the immediate enclosing-parent call repair, with shared13 push controls before
safe Lua48.5. No child-result append substitute is authorized. Original3 parent
LX runtime rows remain unqualified48.2.2.1; no broad ordinary progress/lifecycle,
peer or admission claim follows from this compiler repair.
