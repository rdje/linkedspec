---
id: julia-semantic-runtime-observation-generated-routes
title: Julia emitted parser modules forward typed runtime semantic observations without changing generated-source format
answers:
  - "do fresh emitted Julia parser wrappers accept semantic_observation_sink"
  - "how do I capture semantic observations from an emitted Julia parser"
  - "does Julia emitted semantic observation work with trace and diagnostics"
  - "do Julia emitted semantic observer callback failures preserve identity"
  - "does Julia semantic observation change generated-source format"
  - "does Julia generated semantic observation change parser results or trace bytes"
  - "does Julia emitted exit produce a final semantic result event"
date: 2026-07-23
status: current generated-plan and fresh-emitted direct/traced propagation; composition closeout pending
tags: [julia, semantic-introspection, runtime, observation, generated-source, trace, diagnostics]
evidence: julia/src/source/SourceEmitter.jl; julia/test/semantic_index_runtime_observation_routes_test.jl; docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.6.6.3
last_verified: 2026-07-23
reverify:
  - "JULIA_DEPOT_PATH=/private/var/folders/4h/29gg6nrx2pj9wfjkzc460hlr0000gn/T/linkedspec-julia-depot:/Users/richarddje/.julia /opt/homebrew/bin/julia --project=julia -e 'using Test, JSON3, LinkedSpecJulia; const REPO_ROOT=pwd(); include(\"julia/test/semantic_index_query_kernel_test.jl\"); include(\"julia/test/semantic_index_runtime_observation_test.jl\"); include(\"julia/test/semantic_index_runtime_projection_test.jl\"); include(\"julia/test/semantic_index_runtime_observation_routes_test.jl\")'"
  - "rg -n 'semantic_observation_sink' julia/src/source/SourceEmitter.jl julia/test/semantic_index_runtime_observation_routes_test.jl"
---

# Julia generated and emitted runtime observation routes

The public validated generated-plan helpers and fresh modules produced by `emit_julia_source_v2` accept the same
optional invocation-local `semantic_observation_sink`. Emitted `execute` forwards it to
`execute_generated_parser_v2`; emitted `execute_with_trace` forwards it to
`execute_generated_parser_with_trace_v2`. Capture still occurs only at the shared accepted-slot and successful-
result runtime seams. The emitted module creates no second event vocabulary, capture path, or derivation owner.

Direct and traced emitted calls produce the exact canonical two slot events plus final result. Passing those events
to `with_execution_observation` retains typed/raw-neutral digest
`36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887`. Installing the sink leaves result values,
diagnostic events, and trace bytes unchanged. Callback exceptions escape as the exact caller object through both
wrappers because the generated-plan helpers' existing semantic-specific marker bypasses broad generated-error
translation. Immediate exit emits its accepted slot but no final successful result.

The wrapper keywords are additive source API only. Deterministic emitted bytes remain
`linkedspec-generated-source-v2` / format 2, and the ordered plan remains `{label, family}` without serialized
observation state or cursor policy. No-sink execution follows the already-guarded runtime path and produces the
same output/source behavior as before.

The 51-assertion route suite covers public helper direct/traced calls, a freshly included emitted module, and a
separate isolated Julia host. It locks event order and digest, result/trace/diagnostic non-interference, exact
callback identity, exit omission, deterministic source, and unchanged contract/format metadata. All twelve Julia
semantic suites compose at 1,337 and complete Julia reaches 8,879 package assertions plus primary process
conformance and corpus 105/105. Semantic rollout remains 4/9 and native admission remains 3/6 until their separate
owners.

Full signoff passes primary 5x2x66, all ten Unicode-manifest legs, unchanged Unicode/semantic/capability/generated/
language/public ledgers, and canonical CI with Rust semantic admission 1/1 in 79.78 seconds, Dart 1/1, reference
primary 66x2, and Phase 0 1,031/1,031 in 637 seconds. mdBook and Knowledge Map 694/5,348 pass; exact
1,749,080-KiB cleanup preserves Julia package/registry caches and all 517 Pgen artifacts.

Related facts: [[julia-semantic-runtime-observation-direct-capture]],
[[julia-semantic-runtime-observation-derivation]], [[julia-semantic-runtime-observation-authority-map]],
[[julia-generated-source-v2-rule-local-cursor]].
