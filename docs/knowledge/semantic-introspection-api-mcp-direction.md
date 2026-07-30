---
id: semantic-introspection-api-mcp-direction
title: Deep semantic introspection belongs to one backend-neutral native API with MCP as thin transport
answers:
  - does deep semantic introspection make sense for LinkedSpec
  - should LinkedSpec expose semantic introspection through MCP
  - where should LinkedSpec semantic introspection semantics live
  - should MCP own LinkedSpec semantic behavior
  - what should a LinkedSpec semantic introspection API expose
  - how should semantic introspection stay identical across backends
  - what task owns semantic introspection and MCP design
  - what did FUTURE-PARITY-BACKLOG.10.0 capture
date: 2026-07-20
status: native six-runtime rollout admitted; MCP canonical, Perl/Rust/Dart at 3/5 + 3/6, rollout pending
tags: [introspection, semantic-api, mcp, backends, provenance, explainability, FUTURE-PARITY-BACKLOG]
evidence: "Director proposed deep semantic introspection through a clean API and MCP; FUTURE-PARITY-BACKLOG.10.0 captures the direction and .10.1 owns design before implementation."
evidence_update_2026_07_20: "FUTURE-PARITY-BACKLOG.10.1 and ADR 0049 accept the exact linkedspec-semantic-model-v1 / linkedspec-semantic-query-v1 direction, native SemanticIndex ownership, immutable compilation/runtime snapshots, stable snapshot-local ids, normalized records/relations/shapes/evidence, deterministic pages/cost, structural source privacy, exact fixtures, and two-tool handle-only MCP projection. Implementation remains pending under .10.2-.10.10."
evidence_update_2026_07_20_staged_schema: "Executable modeling in .10.2 exposed that ADR 0049 required staged payload/job/result provenance but named no staged record. ADR 0050 corrects v1 before implementation with explicit staged_artifact payload/parse_job/result records, consumes/produces relations, exact policy/status/value facts, source provenance, and a strict separation from generated_artifact."
evidence_update_2026_07_20_neutral_contract: "FUTURE-PARITY-BACKLOG.10.2 makes the model/query executable without backend behavior: six fixture groups, 20 independently derived digest-locked responses, record/relation/depth/page/source failures, exact staged topology, and unconditional canonical-CI registration. Correction .10.3.2.0 cross-gates static rules against linkedspec-rule-local-cursor-v1 and advances the mutation proof from 50 to 53. Neutral rollout is 1 complete / 8 pending; native backend admission remains 0 complete / 6 pending."
evidence_update_2026_07_21_generated_plan_correction: "FUTURE-PARITY-BACKLOG.10.3.3.0 cross-gates the calls snapshot's generated artifact against the actual generated-source-v2 authority. Exact emitted metadata says default, while the stale model said illegal and_acode. Correcting it and adding illegal/coordinated-family mutations advances the checker from 53 to 55 without changing query digests, behavior, rollout, or admission."
evidence_update_2026_07_21_spec_identity_correction: "FUTURE-PARITY-BACKLOG.10.3.3.1.0 derives spec names from caller logical identity after full calls RED found the model alone used short snapshot id calls instead of calls_and_staging. Direct and coordinated identity mutations advance the checker from 55 to 57 without changing any query digest, behavior, rollout, or admission."
evidence_update_2026_07_21_perl_admission: "FUTURE-PARITY-BACKLOG.10.3.6 composes the implemented Perl surface through one exact 12-role consumer, all 20 response digests, and path/role/driver/registration/admission mutation locks. The checker now rejects 65 mutations; only Perl advances, for rollout 2/9 and native admission 1/6."
evidence_update_2026_07_29_mcp_topology: "ADR 0054 and FUTURE-PARITY-BACKLOG.10.9.0 clarify the transport topology after all native admissions: one exact MCP contract, five native server implementations, and six runtime admissions because one Lua source runs unchanged on PUC Lua and LuaJIT. A future aggregator is outside .10.9 and may only route."
evidence_update_2026_07_29_mcp_protocol: "ADR 0055 and .10.9.1.0 select stable modern MCP 2026-07-28 over stdio: mandatory server/discover, per-request metadata, explicit handles, two tools, no legacy initialize/session/ping, exact policy/error/canonical/shutdown boundaries, and separately owned future compatibility."
evidence_update_2026_07_29_mcp_machine_contract: "FUTURE-PARITY-BACKLOG.10.9.1.1 encodes one neutral digest-pinned schema/payload/corpus/canonical-frame bundle and deterministic materializer without adding a native server or changing any native semantic response."
evidence_update_2026_07_29_mcp_validation: "FUTURE-PARITY-BACKLOG.10.9.1.2 adds an independent exact-schema/frame/raw/lifecycle/handle/policy validator and rejects 68 named mutations without a server or semantic-behavior change."
evidence_update_2026_07_29_perl_mcp: "FUTURE-PARITY-BACKLOG.10.9.2 implements and admits the native Perl server at 1/5 implementations + 1/6 runtimes, leaves shared rollout pending, and closes by unchanged-owner recomposition."
evidence_update_2026_07_29_rust_mcp_plan: "FUTURE-PARITY-BACKLOG.10.9.3.0 and ADR 0058 behavior-freeze a generated filesystem-free Rust binding, in-process linkedspec-runtime server, strict wire, OS entropy, monotonic expiry, panic sanitation, exact admission, and no CLI/executable/SDK/aggregator authority."
evidence_update_2026_07_29_rust_mcp_decoded: "FUTURE-PARITY-BACKLOG.10.9.3.1 implements the generated binding, frozen schema runtime, secure in-process registry, and decoded public Rust server without stdio, admission, semantic ownership, or ledger movement."
evidence_update_2026_07_29_rust_mcp_stdio: "FUTURE-PARITY-BACKLOG.10.9.3.2 implements strict bounded duplicate-safe stdio, canonical LF emission, cancellation through flush, fixed diagnostics, and EOF/read/write/flush release over borrowed streams without admission or ledger movement."
evidence_update_2026_07_29_rust_mcp_admission: "FUTURE-PARITY-BACKLOG.10.9.3.3 composes one exact twelve-role external Rust consumer, advances only Rust to 2/5 implementations + 2/6 runtimes, leaves shared rollout pending, and rejects 39 status/source/role/authority/order mutations without changing the transport digest or server behavior."
evidence_update_2026_07_29_rust_mcp_closeout: "FUTURE-PARITY-BACKLOG.10.9.3.4 recomposes every committed neutral, Perl, and Rust MCP owner unchanged, passes complete focused/canonical proof, closes parent .10.9.3, and hands off to Dart .10.9.4 only after the clean commit."
evidence_update_2026_07_29_dart_mcp_plan: "FUTURE-PARITY-BACKLOG.10.9.4.0 and ADR 0059 behavior-freeze one generated private-part binding/runtime, native in-process Dart server, secure registry, strict duplicate-safe canonical stdio, exact admission, and no-change closeout under .1-.4 without changing the 2/5 + 2/6 ledger."
evidence_update_2026_07_29_dart_mcp_decoded: "FUTURE-PARITY-BACKLOG.10.9.4.1 implements the Dart generated binding/runtime and secure decoded server while leaving strict stdio, formal admission, and the 2/5 + 2/6 ledger unchanged."
evidence_update_2026_07_29_dart_mcp_stdio: "FUTURE-PARITY-BACKLOG.10.9.4.2 implements bounded duplicate-safe canonical Dart stdio, cancellation through flush, fixed optional diagnostics, and EOF/I/O release while leaving formal admission and the 2/5 + 2/6 ledger unchanged."
evidence_update_2026_07_29_dart_mcp_admission: "FUTURE-PARITY-BACKLOG.10.9.4.3 composes one ordered twelve-role Dart consumer, advances only Dart to 3/5 implementations + 3/6 runtimes, leaves shared rollout pending, and rejects 58 admission mutations without changing production behavior or the transport digest."
evidence_update_2026_07_29_dart_mcp_closeout: "FUTURE-PARITY-BACKLOG.10.9.4.4 recomposes every committed neutral, Perl, Rust, and Dart MCP owner unchanged, preserves 3/5 implementations + 3/6 runtimes and all 58 mutations, closes the Dart parent, and hands off to Julia .10.9.5."
evidence_update_2026_07_29_julia_mcp_decoded: "FUTURE-PARITY-BACKLOG.10.9.5.1 implements Julia's generated Base64 binding, frozen runtime, secure registry, and public decoded transport over its native SemanticIndex without adding semantic ownership, strict stdio, admission, or status movement."
reverify: "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py && bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py && rg -n 'linkedspec-semantic-model-v1|FUTURE-PARITY-BACKLOG.10.[2-9]|linkedspec_semantic_query' docs/decisions/0049-versioned-semantic-introspection-model-and-thin-mcp.md docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

Deep semantic introspection is a strong fit for LinkedSpec because the project already constructs and relates
grammar, rule, edge, lifecycle, helper/action, compiled-state, runtime, diagnostic, and generated-source semantics.
ADR `0049` now fixes the future neutral model as `linkedspec-semantic-model-v1` and its request/response protocol as
`linkedspec-semantic-query-v1`. The immutable `SemanticIndex` derives normalized records, relations, shapes,
diagnostics, and evidence from existing semantic authorities without serializing their backend layouts.

The semantic owner is the native in-memory index exposed through each variant's idiomatic API. Snapshot-local ids,
fixed ordering, page/budget accounting, source ceilings/redactions, schema evolution, optional caller-captured
runtime observations, and exact cross-backend answers are model behavior. A query is read-only and never runs a
parser, loads a path, or enables tracing.

The accepted design covers deterministic read-only queries for:

- rules, symbols, edges, calls, regex and lifecycle meaning;
- source spans, stable ids, and provenance through lowering/generated source;
- inferred value and target shapes plus helper/function resolution;
- diagnostics and explain-why paths for compile/runtime decisions;
- ordering, pagination/cost bounds, schema evolution, and privacy/source controls.

Every backend must return equivalent semantic answers through exact shared fixtures. Backend AST/IR layouts, host
object identities, compiled regex/callable values, undeclared source paths, and MCP-specific behavior are not part
of the contract. Read-only introspection precedes any mutation/refactoring API.

MCP has only native capabilities and query projections over a caller-registered opaque handle. It never compiles,
reads implicit files, derives records, or invents explanations. ADR `0054` makes the transport topology exact:
one wire contract governs native Perl, Rust, Dart, Julia, and Lua implementations, with the same Lua source
admitted on PUC Lua and LuaJIT. `.10.2-.10.8` own the executable neutral contract and six-runtime native rollout,
`.10.9` owns the contract plus five MCP implementations and six-runtime transport admission, and `.10.10` owns
public no-drift. A future one-endpoint aggregator is outside `.10.9` and may only route.

ADR `0055` now fixes that transport to modern MCP `2026-07-28` over stdio. Each request carries version and client
capabilities, discovery is mandatory, and the two tools consume out-of-band registered opaque handles. Legacy
initialization, protocol sessions, and ping are absent; policy can only lower native ceilings, and successful
semantic payload bytes remain direct/MCP identical.

Machine leaves `.10.9.1.1-.2` encode and independently validate those rules once in the neutral
`linkedspec-mcp-transport-v1` artifact bundle, and `.10.9.1.3` closes its canonical composition. Perl `.10.9.2`,
Rust `.10.9.3`, and Dart `.10.9.4` are closed. Julia `.10.9.5.1` implements decoded transport while `.2-.4`, Lua
`.10.9.6`, and recurring six-runtime admission `.10.9.7` remain dependency-ordered.

ADR `0050` amends the v1 vocabulary so staged payloads, parse jobs, and stitched results are
explicit `staged_artifact` records related by `consumes`, `produces`, `staged_by`, and `lowered_from`. They are not
misclassified as generated artifacts.

The neutral contract is executable through six fixture groups and 20 exact response digests; its independent
checker rejects 105 schema, identity, ordering, topology, privacy, budget, consumer, rollout, MCP-ownership, and
coordinated static-rule/generated-plan/model-hash mutations. Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT are all
admitted, and the recurring six-runtime proof is complete. The MCP machine contract plus Perl, Rust, and Dart
servers are parent-closed; the Dart implementation remains exactly admitted at the unchanged 3/5 implementation
+ 3/6 runtime boundary. Julia decoded dispatch is implemented but unadmitted; its stdio/admission, Lua, recurring
transport admission, and public no-drift remain dependency-ordered.

Related facts: [[native-in-memory-backend-contract]],
[[user-observable-backend-cli-parity-contract]],
[[canonical-primary-cli-trace-protocol]], [[actionir-lowering-stack]],
[[runtimecontext-boundary]], [[julia-mcp-decoded-server]], [[dart-native-mcp-server-plan]],
[[dart-mcp-strict-stdio]].
