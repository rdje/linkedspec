---
id: logical-helper-five-backend-audit
title: Logical-helper audit found three truthiness profiles; all five native backends now consume the target
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
evidence_update_2026_07_17_lua_rollout: "FUTURE-PARITY-BACKLOG.5.2.6 aligns Lua runtime_truthy and built-in arity while retaining eager once-left-to-right composition and registry-first user-function precedence. Native, reconstructed, generated-plan, loaded emitted-module, primary, lazy-control, inert-codeblock, and exact diagnostic roles pass 238/238 on PUC Lua and LuaJIT. Rollout is 5 complete / 3 pending."
evidence_update_2026_07_17_generated_primary: "FUTURE-PARITY-BACKLOG.5.2.7 expands all five consumers across every available direct/traced generated role and adds success_logical_helpers_eager to the shared 63-case primary manifest. Values, eager effects, typed arity failures, source attribution, and direct/trace identity agree; Rust intentionally keeps direct-value typed v1 distinct from compatibility parse-output arrays. Rollout is 6 complete / 2 pending."
evidence_update_2026_07_17_recurring_gate: "FUTURE-PARITY-BACKLOG.5.2.8 composes the neutral checker, exact native/generated role inventory for Perl/Rust/Dart/Julia/PUC Lua/LuaJIT, success_logical_helpers_eager across five commands and two environments, and generated-source/capability/coverage ledgers. The checker reports 7 complete / 1 pending and rejects 22 semantic/topology mutations."
evidence_update_2026_07_17_public_no_drift: "FUTURE-PARITY-BACKLOG.5.2.9 locks 20 authoritative public documents, forbids 13 stale-current claims, adds four public mutation classes, and closes rollout at 8 complete / 0 pending. Parent .5.2 is closed."
reverify: "bash tools/check_logical_helper_five_backend.sh"
---

All five implementations now express one logical-helper contract:

| Backend | Evaluation | Empty `and/or/not` | Scalar `"0"` / `"false"` | Empty aggregates |
| --- | --- | --- | --- | --- |
| Perl | eager, once, left-to-right; controls remain branch/body-lazy | diagnostic / diagnostic / diagnostic | true / true | false |
| Rust | eager, once, left-to-right; controls remain branch/body-lazy | diagnostic / diagnostic / diagnostic | true / true | false |
| Dart | eager, once, left-to-right; controls remain branch/body-lazy | diagnostic / diagnostic / diagnostic | true / true | false |
| Julia | eager, once, left-to-right; controls remain branch/body-lazy | diagnostic / diagnostic / diagnostic | true / true | false |
| Lua | eager, once, left-to-right; controls remain branch/body-lazy | diagnostic / diagnostic / diagnostic | true / true | false |

All five native backends now use nonempty-string/empty-aggregate truth and exact eager helper arity. The three
profiles and evaluation splits above the current table are the durable pre-repair audit baseline, not remaining
native divergence.

At audit time Perl had two mechanisms rather than an eager helper implementation: host operators inside conditions
and raw keyword calls in value sites, plus an optional-scope collision for `not(false, true)`. `.5.2.2` replaces
that split with typed logical call data and one runtime seam. Its full regression also records the Perl shared
false/zero scalar edge so numeric zero stays false without turning a real nonempty string `"0"` false.

Dart `.5.2.4` replaces its audited short-circuit loop and legacy arities with pre-effect validation plus eager
values. Julia `.5.2.5` preserves its correct truth/evaluation seam and fixes only pre-effect arity. Lua `.5.2.6`
replaces its audited string-zero, empty-aggregate, and legacy arity boundaries through the shared `runtime_truthy`
seam. Normalized/reconstructed, generated-plan, compiled emitted, and primary projections agree within every
backend. `FUTURE-PARITY-BACKLOG.5.2.1` ratified ADR `0043`; all five native leaves `.5.2.2-.6` consume it.
Generated/primary `.5.2.7` now closes every available direct/traced role and one shared default/POSIX primary case.
Recurring gate `.5.2.8` makes that exact six-consumer/primary/support topology omission-checked. Public no-drift
`.5.2.9` locks the authoritative guidance and closes parent `.5.2` at 8/0.

Related facts: [[cross-backend-condition-truthiness-drift]], [[julia-logical-helper-execution]],
[[lua-logical-helper-execution]], [[dart-helper-action-surface-bridge]], [[logical-helper-neutral-contract]],
[[rust-logical-helper-neutral-runtime]], [[dart-logical-helper-neutral-runtime]].
Generated/primary details: [[logical-helper-generated-primary-projection]]. Recurring gate details:
[[logical-helper-recurring-five-backend-gate]]. Public contract details: [[logical-helper-public-no-drift]].
