---
id: julia-generated-source-v2-rule-local-cursor
title: "Julia generated-source v2 derives cursor policy from a minimal validated family plan"
answers:
  - "what generated source version does Julia emit"
  - "how does Julia generated source derive seek and consume"
  - "which Julia generated families seek"
  - "which Julia generated families consume"
  - "does Julia generated source serialize cursor policy"
  - "how does Julia reject generated source v1"
  - "does Julia validate generated contract before decoding payload"
  - "what happens to old standalone Julia generated v1 files"
  - "does Julia generated source classify compact pipe as OR"
  - "what proves Julia generated source v2"
date: 2026-07-18
status: current, fully verified, and composed-admitted through FUTURE-PARITY-BACKLOG.9.1.6.6
tags: [julia, generated-source, cursor, rule-family, reconstruction, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.6.4 advances Julia emission to linkedspec-generated-source-v2 / format 2. The plan remains exact ordered label/family rows with no cursor field. Validation derives five seek and five consume policies and now classifies compact Pipe as OR. Emitted modules validate contract before normalized ASCII-hex payload reconstruction; v1 wins over a corrupt payload with validate_generated_plan/generated_source_contract_version_mismatch plus exact expected_contract/actual_contract and regenerate-from-.spec guidance. Current v2 direct/traced/fresh-loaded roles replace the private forced-seek v1 engine. Focused source-emitter proof is 65/65, complete Julia is 3,133 pass plus the frozen help mismatch, corpus is 105/105, primary is 32/65x2, and neutral governance remains 67 files / 4 complete + 4 pending / 39 mutations."
evidence_update_2026_07_18_option_removal: "FUTURE-PARITY-BACKLOG.9.1.6.5 removes high-level global cursor options without changing the v2 plan or execution. Complete Julia is 3,187, primary is 65/65 twice, corpus is 105/105, and neutral governance is 66/4+4/39."
evidence_update_2026_07_18_admission: "FUTURE-PARITY-BACKLOG.9.1.6.6 composes emitted v2 plus generated direct/trace roles exactly once. Complete Julia reaches 3,291 assertions and neutral governance reaches 67/5+3/44."
evidence_update_2026_07_23_semantic_observation: "FUTURE-PARITY-BACKLOG.10.6.6.3 adds the optional semantic_observation_sink keyword to emitted direct/traced wrappers without changing linkedspec-generated-source-v2, format 2, or the exact label/family plan."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:$HOME/.julia /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'using Test, JSON3, LinkedSpecJulia; const REPO_ROOT=pwd(); include(\"julia/test/source_emitter_test.jl\"); include(\"julia/test/rule_local_cursor_execution_test.jl\")' && perl tools/check_generated_source_contract.pl && python3 tools/check_rule_local_cursor_contract.py && python3 tools/check_logical_helper_contract.py"
---

## Fact

Julia now emits `linkedspec-generated-source-v2` / format 2 through
`emit_julia_source_v2(compiled, source_identity)`. The unversioned `emit_julia_source(compiled)` adapter emits the
same current format with `<inline>` identity. Generated modules expose metadata, plan, validation, direct
execution, traced execution, optional invocation-local `top_rule`, and optional invocation-local
`semantic_observation_sink` without a global cursor option. The observation keyword forwards to shared runtime
capture and does not enter serialized generated state.

The ordered generated plan deliberately contains only `label` and `family`. After exact contract, row-count,
label, known-family, and expected-family validation, execution derives policy as follows:

- seek: `default`, `or_acode`, `or_bcode`, `rep_acode`, and `rep_bcode`;
- consume: `and_single_acode`, `and_acode_seq`, `and_bcode`, `rep_and_acode`, and `rep_and_bcode`.

The same family selects choice/sequence and action/blind structural interpretation at every entered generated
rule. No cursor policy is serialized. Compact `Pipe` follows normalized OR identity and becomes `or_acode` or
`or_bcode`, instead of retaining v1's generated-only AND interpretation.

Generated modules call `validate_generated_source_contract_v2` before `_load_compiled_spec`. A v1 identity therefore
fails before even a corrupt normalized payload can be decoded, with stage `validate_generated_plan`, code
`generated_source_contract_version_mismatch`, exact expected/actual contract fields, and guidance to regenerate
from the originating `.spec`. Existing standalone v1 source cannot change retrospectively; it is a legacy artifact
outside v2 admission and must be regenerated. The private `_generated_v1_compatibility_engine` is deleted.

The focused source-emitter suite proves deterministic bytes, the exact ten-family policy map, native/direct value
identity, all four existing plan mutations, exact v1 rejection, accepted-subset execution, portable trace roles,
root selection, Unicode/ASCII-hex identity, and independently included all-family and corrupt-payload modules.
Adjacent root, diagnostic, logical-helper, variadic, binding, punctuation, and named-mark generated roles all use
the v2 APIs. Public/CLI global option removal is complete in `.9.1.6.5`; one exact 15-role consumer admits the
complete projection in `.9.1.6.6`.

Related: [[julia-generated-source-scaffold]], [[julia-generated-source-family-plan]],
[[julia-rule-local-cursor-execution]], [[julia-global-cursor-option-removal]],
[[julia-rule-local-cursor-admission]],
[[julia-root-rule-selection-routes]],
[[julia-semantic-runtime-observation-generated-routes]],
[[dart-generated-source-v2-rule-local-cursor]], [[rust-generated-source-v2-rule-local-cursor]], and
[[perl-generated-source-contract-v2]].
