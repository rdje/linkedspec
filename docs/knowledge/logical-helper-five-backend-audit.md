---
id: logical-helper-five-backend-audit
title: Logical-helper audit found three truthiness profiles; four backends now consume the target
answers:
  - "what are the current and or not semantics on all five LinkedSpec backends"
  - "are LinkedSpec logical helpers eager or short circuit"
  - "why are Perl logical helpers not eager"
  - "why does not false true select the second argument in Perl"
  - "is string false truthy in LinkedSpec"
  - "what do empty and or not return on each backend"
  - "do generated logical helpers match native execution"
  - "does ActionIR have a logical expression node"
  - "which task owns logical helper parity"
date: 2026-07-16
status: rollout-in-progress
tags: [logical, truthiness, arity, actionir, generated-source, perl, rust, dart, julia, lua, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.5.2.0 used call_spec_handler_subst, LinkedSpec::Get, return_descriptor, emitted-source execution, source ownership reads, and matching native/generated probes. Perl condition lowering uses lazy host &&/|| but direct value/return/receiver calls remain raw and broken; Rust/Julia/Lua eagerly evaluate every argument; Dart short-circuits. The same probes establish three truthiness profiles and confirm native/generated identity on Rust, Dart, Julia, and both Lua ABIs. The canonical narrative is the mdBook Boolean composition section and backend handoff; .5.2.1-.9 own policy and rollout."
evidence_update_2026_07_16_perl_rollout: "FUTURE-PARITY-BACKLOG.5.2.2 repairs the audited Perl split through typed ActionIR and LinkedSpec::RuntimeLogical. Direct/nested/assignment/return/condition/function/block/receiver calls now enforce pre-effect arity, eager left-to-right operands, real booleans, and ADR 0043 truthiness; lazy controls share truth but not eager branch execution. Rollout is 1 complete / 7 pending."
evidence_update_2026_07_17_rust_rollout: "FUTURE-PARITY-BACKLOG.5.2.3 repairs Rust through RuntimeValue::as_bool plus one pre-evaluation arity guard. Native, serialized, direct-value, generated-plan, and independently compiled emitted roles match all source-renderable neutral truth/helper/effect/receiver/control/arity cases. Rust now makes every nonempty string true and empty aggregates false; empty logical calls diagnose. That slice advanced rollout to 2 complete / 6 pending before Dart."
evidence_update_2026_07_17_dart_rollout: "FUTURE-PARITY-BACKLOG.5.2.4 repairs Dart helper short-circuit and empty/extra arities through runtimeLogicalTruth plus direct ActionCallExpr validation. Native, normalized, generated-plan, primary, and compiled standalone-emitted roles match the unchanged values/effects/receiver/control/arity fixtures; all 17 typed rows include an inert model-level codeblock. Rollout is 3 complete / 5 pending."
evidence_update_2026_07_17_julia_rollout: "FUTURE-PARITY-BACKLOG.5.2.5 preserves Julia's already-correct _runtime_truthy and eager composition, then rejects empty and/or/not plus multi-argument not before operand effects. Native, normalized, generated-plan, primary, and independently compiled emitted roles match all 17 typed rows and unchanged fixtures. Rollout is 4 complete / 4 pending."
reverify: "prove -Iperl t/logical_helper_perl_contract.t && python3 tools/check_logical_helper_contract.py && (cd dart && dart test test/logical_helper_contract_test.dart) && rg -n 'as_bool|runtimeLogicalTruth|_runtime_truthy|evaluate_runtime_logical|runtime_truthy' rust/linkedspec-core/src/types.rs dart/lib/src/runtime/interpreter.dart julia/src/runtime/Interpreter.jl lua/src/linkedspec/interpreter.lua"
---

The five implementations do not currently express one logical-helper contract:

| Backend | Evaluation | Empty `and/or/not` | Scalar `"0"` / `"false"` | Empty aggregates |
| --- | --- | --- | --- | --- |
| Perl | eager, once, left-to-right; controls remain branch/body-lazy | diagnostic / diagnostic / diagnostic | true / true | false |
| Rust | eager, once, left-to-right; controls remain branch/body-lazy | diagnostic / diagnostic / diagnostic | true / true | false |
| Dart | eager, once, left-to-right; controls remain branch/body-lazy | diagnostic / diagnostic / diagnostic | true / true | false |
| Julia | eager, once, left-to-right; controls remain branch/body-lazy | diagnostic / diagnostic / diagnostic | true / true | false |
| Lua | eager, once, left-to-right | false / false / true | false / true | true |

This is now two truthiness profiles rather than a reference-versus-interpreter split. Perl, Rust, Dart, and Julia
use nonempty-string/empty-aggregate truth and exact eager helper arity; Lua retains scalar `"0"`/empty-aggregate
host-compatible boundaries plus legacy empty/extra arities until its rollout leaf lands.

At audit time Perl had two mechanisms rather than an eager helper implementation: host operators inside conditions
and raw keyword calls in value sites, plus an optional-scope collision for `not(false, true)`. `.5.2.2` replaces
that split with typed logical call data and one runtime seam. Its full regression also records the Perl shared
false/zero scalar edge so numeric zero stays false without turning a real nonempty string `"0"` false.

Dart `.5.2.4` replaces its audited short-circuit loop and legacy arities with pre-effect validation plus eager
values. Julia `.5.2.5` preserves its correct truth/evaluation seam and fixes only pre-effect arity. Their
normalized, generated-plan, compiled emitted, and primary projections agree. Lua generated execution reproduces
its remaining native drift, so emission is not its source. `FUTURE-PARITY-BACKLOG.5.2.1` ratified ADR `0043`;
Perl `.5.2.2`, Rust `.5.2.3`, Dart `.5.2.4`, and Julia `.5.2.5` consume it. Dependency-ordered Lua,
generated/primary, recurring-gate, and public no-drift leaves `.5.2.6-.9` remain.

Related facts: [[cross-backend-condition-truthiness-drift]], [[julia-logical-helper-execution]],
[[lua-logical-helper-execution]], [[dart-helper-action-surface-bridge]], [[logical-helper-neutral-contract]],
[[rust-logical-helper-neutral-runtime]], [[dart-logical-helper-neutral-runtime]].
