---
id: julia-semantic-staged-generated-projection
title: Julia retains exact private staged and generated semantic provenance at 22 records and 25 relations
answers:
  - "does Julia implement semantic staged payload job and result records"
  - "how many records and relations are in the complete Julia calls semantic projection"
  - "how does Julia validate a function staged payload before semantic projection"
  - "how does Julia validate StagedParseJob before semantic projection"
  - "does Julia expose staged body AST through semantic introspection"
  - "how does Julia select the semantic generated handler plan"
  - "does Julia semantic generated provenance rerun the plan builder"
  - "does Julia semantic generated provenance emit or execute Julia source"
  - "which Julia test proves exact staged and generated semantic parity"
  - "what is the next Julia semantic task after staged generated projection"
date: 2026-07-22
status: current exact private projection; no-change composition closeout pending
tags: [julia, semantic-introspection, staged-parsing, generated-source, provenance, privacy]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.6.4.2; julia/src/semantic/SemanticCallProjection.jl; julia/src/semantic/SemanticStaticProjection.jl; julia/test/semantic_index_call_staged_test.jl; capability_conformance/semantic_introspection_model.json snapshot calls
reverify: "python3 tools/check_semantic_introspection_contract.py; JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-call-staged-depot:$HOME/.julia /opt/homebrew/bin/julia --project=julia -e 'using LinkedSpecJulia,Test,JSON3; include(\"julia/test/semantic_index_source_foundation_test.jl\"); include(\"julia/test/semantic_index_compilation_foundation_test.jl\"); include(\"julia/test/semantic_index_static_graph_test.jl\"); include(\"julia/test/semantic_index_static_remaining_test.jl\"); include(\"julia/test/semantic_index_call_core_test.jl\"); include(\"julia/test/semantic_index_call_staged_test.jl\")'"
---

Julia leaf `.10.6.4.2` completes the private calls projection at the exact neutral 22-record / 25-relation target.
It adds three distinct staged artifacts and one generated handler-plan artifact to the committed 18/16 typed core,
with exactly three function `contains` relations, five staging-chain relations, and one `generated_as` relation.

The staged projection validates native authority before neutralization. A function payload must identify the exact
accepted function/body/path/text/span and either its fixed parameters/arity or variadic signature. Its typed
`StagedParseJob` must independently agree on those fields plus `actionir-body.spec`, `action_block`,
`replace_field/body_ast`, `fail`, and `function_body`; a retained body AST must exist. The emitted neutral records
use ADR `0050` policies only. Native payload/job maps, body AST, and typed ActionIR never leave the private owner.

Generated provenance consumes the already-retained `SemanticGeneratedPlanInput`. Contract, format, caller logical
identity, complete ordered compiled labels, and one selected entry row must agree. Only the selected row's family
is retained. The projector does not call `build_generated_rule_plan`, emit Julia source, load a module, execute a
generated target, or derive facts from trace.

The 62-assertion staged suite deep-equals all 22/25 records and relations, locks ids/facts/directions, rejects
corrupted native sidecars and plan contract/identity/order/selection drift, and proves fresh detached plain JSON,
tuple-backed retention, private-surface omission, host/path denial, and no execution. Six-suite composition is 530;
complete Julia is 8,072/primary/105; full primary 5x2x66, ten Unicode legs, unchanged governance, and canonical
Rust 76.95s + Dart 1/1 + primary 66x2 + Phase 0 1,031/622s pass. No public query, runtime observation, rollout, or
native admission moves. `.10.6.4.3` is the next dependency-eligible no-change composition leaf after commit.

See [[julia-semantic-call-core-projection]], [[julia-semantic-call-staged-projection-plan]],
[[semantic-introspection-staged-artifact-schema]], and [[semantic-introspection-generated-plan-authority]].
