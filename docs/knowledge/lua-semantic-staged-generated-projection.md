---
id: lua-semantic-staged-generated-projection
title: Lua retains exact private staged and generated semantic provenance at 22 records and 25 relations
answers:
  - "does Lua implement semantic staged payload job and result records"
  - "how many records and relations are in the complete Lua calls semantic projection"
  - "how does Lua validate a function staged payload before semantic projection"
  - "how does Lua validate StagedParseJob before semantic projection"
  - "does Lua expose staged body AST through semantic introspection"
  - "how does Lua select the semantic generated handler plan"
  - "does Lua semantic generated provenance rerun the plan builder"
  - "does Lua semantic generated provenance emit or execute Lua source"
  - "which Lua test proves exact staged and generated semantic parity"
  - "what is the next Lua semantic task after staged generated projection"
date: 2026-07-28
status: current exact private dual-ABI projection; parent composition-closed
tags: [lua, luajit, semantic-introspection, staged-parsing, generated-source, provenance, privacy]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaves .10.7.4.2-.3; lua/src/linkedspec/semantic_static_projection.lua; lua/test/semantic_index_call_staged_generated_test.lua; capability_conformance/semantic_introspection_model.json snapshot calls
reverify: "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py; for runtime in puc luajit; do bash tools/run_lua_project_data.sh \"$runtime\" lua/test/semantic_index_call_core_test.lua; bash tools/run_lua_project_data.sh \"$runtime\" lua/test/semantic_index_call_staged_generated_test.lua; done"
---

Lua leaf `.10.7.4.2` completes the private calls projection at the exact neutral 22-record / 25-relation target on
PUC Lua and LuaJIT. It adds three distinct staged artifacts and one generated handler-plan artifact to the
committed 18/16 typed core, with exactly three function `contains` relations, five staging-chain relations, and one
`generated_as` relation. The complete projection retains the same ten private source refs.

The staged projection validates native authority before neutralization. A function payload must identify the exact
accepted version, function/body/path/text/span and either its fixed parameters/arity/kinds or variadic signature.
Its typed `StagedParseJob` independently agrees on those fields plus `actionir-body.spec`, `action_block`,
`replace_field/body_ast`, `fail`, and `function_body`; the body result must exist and the typed-core proof has
already established exact JSON equality and resolved ActionIR contracts. The emitted records use only ADR `0050`
policies. Native payload/job maps, body AST, and typed ActionIR never leave the private owner.

Generated provenance consumes the already-retained plan input. Contract, format, caller logical identity, complete
ordered compiled labels, and one selected entry row must agree. Only the selected row's family is retained. The
projector does not require the source emitter, call the plan builder, emit Lua source, load a module, execute a
generated target, or derive facts from runtime, trace, diagnostics, observation, environment, clock, or randomness.

Focused proof is 136 assertions for the non-staged subset plus 97 assertions for complete staged/generated
provenance on each ABI. The complete Lua gate remains source/outcome/graph/remaining 379/122/64/122, package
`1..177`, PUC primary 66x2, corpus 105, and repository-storage proof. The staged suite deep-equals all 22/25,
locks every added id/fact/direction, rejects corrupted native sidecars and retained plan identity/order/selection,
and proves fresh detached plain JSON, private-surface omission, host/path denial, and no execution. No public query,
runtime observation, generated-format change, semantic rollout, or native admission moves.

Canonical proof passes all six doctrines, Rust admission 1/1 in 77.92s, Dart 1/1, Julia 416/416 in 27.3s,
containment/moved-root execution, reference primary 66x2, and Phase 0 1,031/1,031 in 616s. The Knowledge Map is
725 facts / 5,777 question keys.

No-change `.10.7.4.3` recomposes the six committed semantic suites at exact focused 920 per ABI and passes complete
Lua, primary 5x2x66, Unicode 10/10, all six unchanged ledgers, and canonical Rust 81.19s + Dart 1/1 + Julia
416/29.0s + reference primary 66x2 + Phase 0 1,031/648s. It changes no production/test/fixture/API/query/
observation/format/ledger file, closes parent `.10.7.4`, and hands off to behavior-free query audit `.10.7.5.0`.

See [[lua-semantic-call-staged-projection-plan]], [[lua-semantic-introspection-authority-map]],
[[semantic-introspection-staged-artifact-schema]], [[semantic-introspection-generated-plan-authority]], and
[[julia-semantic-staged-generated-projection]].
