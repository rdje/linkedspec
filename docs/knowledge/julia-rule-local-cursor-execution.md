---
id: julia-rule-local-cursor-execution
title: "Julia normal execution derives cursor and composition policy at every entered rule"
answers:
  - "does Julia use rule local cursor policy"
  - "where does Julia derive seek versus consume"
  - "does a Julia parent propagate cursor policy to a child"
  - "does Julia AND consume and OR seek"
  - "does loaded Julia execution use rule local cursor policy"
  - "does normalized Julia SpecFile JSON use rule local cursor policy"
  - "how does Julia trace entered rule cursor policy"
  - "does Julia generated source v1 use intrinsic cursor policy"
  - "why does Julia keep a generated v1 compatibility engine"
  - "did Julia remove the generated v1 compatibility engine"
  - "does Julia generated source v2 derive cursor policy"
  - "does Julia still accept an explicit global parse mode"
  - "what tests prove Julia rule local cursor execution"
date: 2026-07-18
status: verified normal, generated-v2, option-free, and composed-admitted execution
tags: [julia, runtime, cursor, rule-family, trace, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.6.2 derives family/cursor/sequence-choice once at every ordinary _execute_runtime_rule! entry. Live, loaded-default, normalized SpecFile JSON, recursive, and traced routes pass 104 neutral assertions over all 36 families, eight parent-child mechanisms, and two structural replacements. Generated v1 remains behind a private seek/family compatibility engine and focused emitter proof passes 60. Complete package is 2,320 pass plus the one frozen help mismatch; corpus is 105/105; shared primary remains 32/65 twice; neutral governance remains 67 files / 4 complete + 4 pending / 39 mutations."
evidence_update_2026_07_18_generated_v2: "FUTURE-PARITY-BACKLOG.9.1.6.4 removes _generated_v1_compatibility_engine after every current generated role moves to v2. Generated entry policy derives from the validated ten-family plan: five seek and five consume, with the same sequence/choice dimension. Focused emitter is 65/65; complete Julia is 3,133 plus the frozen help mismatch; corpus 105 and primary 32/65x2 remain exact."
evidence_update_2026_07_18_option_removal: "FUTURE-PARITY-BACKLOG.9.1.6.5 deletes LinkedSpecRuntimeEngine global state and every engine/loader/corpus/primary high-level override. Legacy API keys fail at prepare_options with parse_mode_override_removed; CLI help/trace omit the field and exact shared primary reaches 65/65 twice."
evidence_update_2026_07_18_admission: "FUTURE-PARITY-BACKLOG.9.1.6.6 composes every current execution projection exactly once in a 15-role consumer. Complete Julia reaches 3,291 assertions; neutral governance advances only julia_backend to 67 files / 5 complete + 3 pending / 44 mutations."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:/Users/richarddje/.julia /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'using Test, JSON3, LinkedSpecJulia; const REPO_ROOT=pwd(); include(\"julia/test/rule_local_cursor_execution_test.jl\")' && python3 tools/check_rule_local_cursor_contract.py"
---

## Fact

Normal Julia rule execution has one high-level authority: the family of the rule currently being entered.
`_execute_runtime_rule!` derives one `_RuntimeRuleExecutionPolicy` before lifecycle or matching work:

- exact AND family maps to consume plus ordered sequence;
- default/OR family maps to seek plus choice;
- every blind, action, explicit-call, and recursive child receives the current cursor but derives policy again
  from its own compiled rule.

The derived cursor value is passed into ordinary alternation and specific-slot matching. Low-level
`runtime_match`, `seek_match`, and `consume_match` remain unchanged. No-option `LinkedSpecRuntimeEngine(compiled)`
and loaded `create_engine(...)` are intrinsic; ordinary normalized `SpecFile` JSON reconstructs the same family
metadata. Rule trace entries identify `family=and|or_default` and `cursor_policy=consume|seek`, and regex decisions
record the effective policy.

No staged compatibility boundary remains in high-level Julia execution. A supplied legacy engine, loader, or
corpus option fails before input/user code instead of being honored or ignored. Generated-source v2 uses no private engine: validated family
derives both cursor and sequence/choice at every generated rule entry. A v1 contract is rejected before payload
reconstruction and must be regenerated. Descriptor v1, generated v2, and public option removal are current through
`.5`; the exact 15-role consumer admits the complete Julia projection in `.6`, so rollout is 5 complete / 3
pending.

`julia/test/rule_local_cursor_execution_test.jl` reads the unchanged neutral JSON contract. It covers every one
of the 36 family spellings on live and normalized routes, all eight parent-child mechanisms, both structural
replacements, loaded execution, recursion, trace attribution, and generated-v1 isolation. Existing generated
tests additionally lock all ten v1 families and the historical repeated-child ordering.

Related: [[julia-rule-local-cursor-normalization]], [[julia-rule-local-cursor-descriptor]],
[[julia-generated-source-v2-rule-local-cursor]],
[[julia-global-cursor-option-removal]],
[[julia-rule-local-cursor-admission]],
[[julia-rule-local-cursor-preflight]],
[[julia-runtime-rule-interpreter]], [[julia-runtime-matching-state]],
[[dart-rule-local-cursor-execution]], and [[rust-rule-local-cursor-execution]].
