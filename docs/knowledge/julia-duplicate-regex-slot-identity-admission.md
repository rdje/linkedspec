---
id: julia-duplicate-regex-slot-identity-admission
title: "Julia matches required authored regex slots directly and admits every duplicate-slot route"
answers:
  - "is Julia duplicate regex slot identity implemented"
  - "how does Julia match a required duplicate regex slot"
  - "does Julia reindex a singleton regex match"
  - "how does Julia generated source preserve duplicate regex slots"
  - "where does Julia validate compiled regex slot identity"
  - "what trace event reports Julia regex slot identity"
  - "what proves Julia duplicate regex slot parity"
date: 2026-07-20
status: current and composed-admitted through FUTURE-PARITY-BACKLOG.9.1.8.1.5
tags: [julia, regex, slot-identity, and, or, repetition, descriptor, generated-source, diagnostics, parity, FUTURE-PARITY-BACKLOG]
evidence: "Julia match_runtime_regex_slot selects an existing RuntimeRegexAlternative and returns its authored zero-based index without singleton recompilation or reindexing. Ordered/repeated execution uses that direct route; full alternation remains the OR/default choice owner. Action edges translate parent indices to {target_rule,child_regex_index} for invariant and julia_runtime:regex_slot_selected trace. validate_compiled_regex_slot_identities protects compile, engine, emitter, and generated-plan boundaries. Descriptor/emitted metadata publish linkedspec-duplicate-regex-slot-identity-v1; emitted v2 retains canonical normalized SpecFile JSON in ASCII hex and exact {label,family} plans. One module-isolated 15-role consumer passes 121 assertions; the complete Julia driver passes package 3,549, primary 65x2, and corpus 105/105. Governance is 5 complete + 2 pending with 41 rejected mutations."
evidence_update_2026_07_20_recurring_closeout: "Julia's recorded 5+2/41 count is its historical admission boundary. FUTURE-PARITY-BACKLOG.9.1.8.1.7 subsequently composes Julia with Perl, Rust, Dart, PUC Lua, and LuaJIT; current duplicate-slot governance is 7 complete / 0 pending with 59 rejected mutations."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include(\"julia/test/duplicate_regex_slot_identity_contract_test.jl\")' && bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()' && python3 tools/check_duplicate_regex_slot_identity_contract.py"
---

Julia's ordered executor already knows the parent alternative required at each
sequence step. `RuntimeRegexAlternation` retains every authored alternative;
`match_runtime_regex_slot` selects the requested row directly under the entered
rule's seek/consume policy. The returned `RuntimeRegexMatch.alternative_index`
is therefore the authored index itself. Duplicate pattern text never supplies or
repairs identity. `runtime_match` over the complete alternation remains the
choice path, with earliest start and lowest authored order as its tie-break.

Compiled action edges map that parent index to portable target-rule plus child
regex index. This matters for cross-target ordered rules: parent alternatives
zero and one project as `First#0` then `Second#0`. The same mapping feeds the
ordered invariant and `julia_runtime:regex_slot_selected` trace. Repeated AND
re-enters the sequence from its first required parent slot.

`validate_compiled_regex_slot_identities` runs after compilation and at runtime
engine, source-emitter, and generated-plan trust boundaries. It validates the
executed `child_regex_index`, its agreement with the target reference, the
target's authored-regex bound, and the parent dispatch bound. Invalid identity
uses `regex_slot_identity_invalid` / `validate_compiled_rule`; ordered matcher
identity loss uses `ordered_regex_slot_identity_lost` / `execute_rule`.
Descriptors and emitted modules publish the neutral contract id. Julia emitted
source remains v2/format 2, reconstructs canonical normalized `SpecFile` JSON,
and does not widen label/family plan rows.

The contract-declared consumer executes each of 15 roles once in its own module:
neutral fixtures, native ordered/choice, repeated duplicate/control,
cross-target, loaded, reconstructed, descriptor, emitted source, generated
direct, native/generated trace, primary command, and invalid diagnostics.

Related: [[duplicate-regex-slot-identity-contract]],
[[duplicate-regex-slot-identity-cross-backend-audit]],
[[julia-runtime-matching-state]], [[julia-runtime-rule-interpreter]],
[[julia-generated-source-v2-rule-local-cursor]], and
[[FUTURE-PARITY-BACKLOG]].
