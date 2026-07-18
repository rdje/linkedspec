---
id: rust-generated-source-v1-result-projection
title: Rust v2 typed generated execution returns the direct rule value while compatibility parse keeps its accumulator envelope
answers:
  - "why did the Rust neutral generated fixture return an array around ok"
  - "what result does generated Rust execute return"
  - "what result does generated Rust parse return"
  - "does typed generated execution match Engine execute_value"
  - "does legacy generated tracing retain the accumulator envelope"
  - "how are portable generated trace roles exposed in Rust"
date: 2026-07-18
status: current
tags: [rust, generated-source, result-shape, compatibility, trace, contract]
evidence: "FUTURE-PARITY-BACKLOG.3.1.3.2 ran capability_conformance/generated_source/fixtures/default_action_result_trace_identity through the typed Rust generated executor. Initial output was [\"ok\"] versus expected \"ok\": execute_generated_with_plan_context discarded the top rule RuntimeValue and returned ctx.accumulator, mirroring legacy Engine::execute rather than already-adopted Engine::execute_value. Engine::execute_generated_value_with_plan and its traced role path now return execute_rule(...).to_json(); typed v1 execute/execute_with_trace use that seam. Legacy generated parse/parse_with_trace continue through accumulator-returning methods. A first full gate caught accidental legacy traced projection drift; trace_controls 10/10 passed after projection was selected explicitly. Focused source_emitter passes 5/5; clean full Rust gate passes 137/105/196/5/5/5/10 plus 61x2 CLI."
evidence_update_2026_07_18: "FUTURE-PARITY-BACKLOG.9.1.4.5 retains the deliberate result split through generated-source v2: typed execute roles return the direct value; compatibility parse roles return the accumulator. The neutral v2 source/trace fixture and fresh generated modules prove both projections."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter generated_source_v2_neutral_plan_and_trace_roles_are_exact; cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test trace_controls; rg -n 'execute_generated_value_with_plan|execute_generated_with_plan_context|generated_rule_enter|generated_family_decision|generated_rule_exit' rust/linkedspec-runtime/src/engine.rs rust/linkedspec-runtime/src/source_emitter.rs"
---

# Rust Generated-Source v1 Result Projection

Rust intentionally has two outward result shapes. The portable native API
`Engine::execute_value` returns the selected rule's value directly; historical
`Engine::execute` returns the accumulator array. Generated source now mirrors
that established split:

- typed v2 `execute` / `execute_with_trace` return the direct top-rule value;
- compatibility `parse` / `parse_with_trace` retain the accumulator envelope.

The neutral fixture made this observable: the contract value is `"ok"`, not
`["ok"]`. The fix is a generated-plan-aware direct-value engine seam, not an
unwrap heuristic. Arrays returned by a rule therefore remain arrays.

Typed traced execution also records `generated_rule_enter`,
`generated_family_decision`, and `generated_rule_exit` with source identity,
rule, and neutral family while retaining richer native generated-plan events.
Compatibility traced execution keeps its previous output and native topics.

Related facts: [[generated-source-contract-v1]],
[[rust-generated-source-contract-v1-gap]],
[[rust-generated-source-v1-metadata-errors]], and
[[rust-generated-source-v2-rule-local-cursor]].
