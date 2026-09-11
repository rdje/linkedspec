---
id: julia-source-value-authority-reading
title: Julia source value authority reading completes decoded tables and typed projections
answers:
  - "where is complete Julia SourceLocation startup reading recorded"
  - "how does Julia source authority map exact codeunit boundaries to scalar positions"
  - "which Julia observation route test requires the shared query digest helper"
date: 2026-09-11
status: current source-reading evidence; no behavior change
tags: [julia, source-location, semantic-observation, startup, reading]
evidence: "JULIA-STARTUP-READING.1.20; activation7c856868b4e36eba189d7f41b37a6da295e98fff; completes SourceLocation1-646 and SemanticObservation1-130 alongside recognition terminal and staged authority prefix reading."
reverify: "Run the focused managed recipe below and the exact coverage recipe in julia-startup-reading-coverage."
---

# Completed source-value authority reading

The architecture and rollout owner remains [[typed-source-location-runtime-rollout-plan]].
Its near-capacity fact links here for bounded current Julia reading evidence.
SourceLocation owns copied decoded source text and immutable scalar-to-codeunit,
line, column and UTF-8-byte tables. LF alone advances the line. Binary search accepts
only exact codeunit boundaries; scalar positions include EOF. Authority ids are
atomic and exhaustion-guarded; positions/spans contain identity and coordinates,
without embedding decoded text or live authority handles.

Direct spans require same source and authority, ordered endpoints and nonempty
provenance. Derived text retains ordered typed spans in a tuple; materialization
validates ownership/bounds again and joins exact source slices. Serialization,
92 projection rows and seven compatibility aliases return detached plain records.
This private decoded-source authority is distinct from semantic source construction's
strict malformed-byte validation; the reading grants no additional input admission.

SemanticObservation has two immutable scalar event kinds, exact equality/hash and
fresh JSON records. Its constructor copies fields and deliberately leaves topology
validation to observed-index derivation. Final events hash the input bytes; runtime
no-sink and callback composition behavior belongs to the existing capture seam and
open [[julia-semantic-observer-action-failure-wrapping]] repair.

RecognitionTransaction822-1057 completes successful commit, rollback, escape,
discard, fixed-point effect classification, cursor-only progress and LIFO leave.
Commit retains staged state and falsey payload; rollback restores then invalidates.
An abandoned active token restores before frame retirement and terminal-required
failure. The classifier remains separately implemented from the known runtime
effect-closure gap; reading does not close Julia .2.3/.2.7 or startup .38.

StagedAstEnrichment1-488 establishes private registry/cache/resource/context shapes,
strict callback safe points, copied diagnostic fields, and host-only execution seeds.
Seed construction validates copied logical registry/options with placeholders without
calling the factory. Starting an execution requires its exact factory fields and
creates fresh registry/resource state. Resolution, stitching and recursive suffixes
remain owned by later unread groups. Existing staged facts remain canonical.

Existing recognition207/typed127/observation66/routes51/staged491 consumers pass942
assertions plus one helper-selection check. Neutral typed231, semantic6/20/128 and
staged123/public129 pass. Earlier gaps retain their owners; no repair is inferred.

## Exact focused replay

The observation-route consumer uses _semantic_query_kernel_digest from the ordinary
harness's earlier kernel test. An initial isolated run omitted that function: the
route suite had45 passes and6 harness errors, and staged tests were not reached.
Loading that exact existing function restores the intended independent digest check;
a second isolated process also lacked the direct-observation compile helper. The
complete recipe below loads both dependencies in their ordinary order. No
production/test source was changed, and repeated assertions receive no extra credit.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_READ20_COMPLETE'
using LinkedSpecJulia,JSON3,Test
const REPO_ROOT=pwd()
const selected=Set([:_semantic_query_kernel_digest])
const seen=Set{Symbol}()
for expression in Meta.parseall(read("julia/test/semantic_index_query_kernel_test.jl",String)).args
 if expression isa Expr && expression.head==:function && expression.args[1].args[1] in selected
  Core.eval(Main,expression);push!(seen,expression.args[1].args[1])
 end
end
@test seen==selected
include("julia/test/recognition_transaction_contract_test.jl")
include("julia/test/typed_source_location_contract_test.jl")
include("julia/test/semantic_index_runtime_observation_test.jl")
include("julia/test/semantic_index_runtime_observation_routes_test.jl")
include("julia/test/staged_ast_enrichment_contract_test.jl")
JULIA_READ20_COMPLETE
bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py
bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py
bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py
```

## September 11 — typed-source consumer reading complete .1.50

All449 lines are read. Fresh127 assertions cover3 sources,7 positions,6 direct
spans,3 ordered-derived texts, copied input authority and four private diagnostics.
The returned projection-row record is actually mutated and fetched again, unlike
the separate staged-copy gap. Exact92 rows and7 alias metadata are checked; named
marks, cursor save/rewind/restore and selected alias fixtures execute native,
SpecFile-JSON reconstructed and generated-plan routes. This consumer does not
execute emitted source or every helper spelling merely by comparing its catalog.
The separate alias consumer's emitted proof remains in its existing fact home.

At activation198e40a108054e0e1a4dffa833bedcdcd4b1f741, complete staged491,
lifecycle103, typed127, classifier1674 and identity130 pass2525 assertions.
The last includes a fresh emitted host. Four neutral checks pass staged123/public129,
typed14/0/231, Unicode806/9/8/2 and lifecycle14. All source bytes and contracts
remain unchanged; no package/canonical or other-backend execution is claimed.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include("julia/test/staged_ast_enrichment_contract_test.jl"); include("julia/test/standalone_lifecycle_block_contract_test.jl"); include("julia/test/typed_source_location_contract_test.jl"); include("julia/test/unicode_rule_label_classifier_test.jl"); include("julia/test/unicode_rule_label_identity_routes_test.jl")'
bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py
bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py
bash tools/run_python_project_data.sh tools/check_unicode_rule_label_contract.py
bash tools/run_python_project_data.sh tools/check_standalone_lifecycle_block_contract.py
```
