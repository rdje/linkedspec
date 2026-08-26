---
id: dart-staged-ast-enrichment-current-depth-authority
title: Dart has private caller-frozen staged authority for one complete marker depth
answers:
  - "where is Dart staged AST enrichment resolution implemented"
  - "how does Dart resolve pre-registered parse_job parsers"
  - "can Dart staged parse_job load a path or query a provider"
  - "how does Dart select the default staged top rule"
  - "how does Dart compute staged parse job ids"
  - "how does Dart cache staged parser plans"
  - "does the Dart staged cache retain child results or failures"
  - "which staged result policies work privately in Dart"
  - "which staged failure policies work privately in Dart"
  - "how are current-depth Dart staged jobs ordered"
  - "do sibling staged parsers share Dart runtime state"
  - "how are Dart staged child results detached"
  - "does Dart recursively execute returned staged markers"
  - "what does FUTURE-PARITY-BACKLOG 14.7.5.2 implement"
date: 2026-08-26
status: current private one-depth authority; recursive bounds and source rebasing remain dormant RED for FUTURE-PARITY-BACKLOG.14.7.5.3
tags: [dart, staged-parsing, parse-job, registry, cache, result-policy, failure-policy, detachment, private]
evidence: "FUTURE-PARITY-BACKLOG.14.7.5.2 adds private staged_ast_enrichment.dart and extends the same excluded consumer. FrozenStagedRegistry accepts only caller-completed candidate outcomes plus already-compiled opaque callbacks; resolution is pure alias/declaring-relative/ordered-root/provider selection with exact authority narrowing and no ambient loading. Default top precedes the canonical v2 job id. The invocation-local cache stores immutable callback plans only under the neutral eight-field identity. One complete depth prepares every job and stitch target before callbacks, orders typed paths/provenance/job ids, gives siblings fresh cursor/mark/capture/variable state, detaches and node-bounds results, and atomically applies all four result plus three failure policies. The consumer is +12/-1 and only .14.7.5.3 recurrence/bounds/source-rebased diagnostics remain RED. Fatal analysis, 102 direct dependents, and all 416 ordinary Dart tests pass while discovery, canonical references, rollout, formats, v1, public, and outward truth remain unchanged."
root_cause: "FUTURE-PARITY-BACKLOG.14.7.5.1 intentionally stopped after inert declaration construction. Dart had no private general-v2 frozen snapshot, pure selector, selected-top-before-id function, immutable-plan cache, complete-depth preflight/order seam, fresh sibling context, or policy stitcher. The existing staged_parser_registry.dart is the deliberately narrow function-body-v1 adapter and cannot safely be widened into this authority."
last_verified: 2026-08-26
reverify:
  - "cd dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings"
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test_dormant/staged_ast_enrichment_contract_test.dart"
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/staged_parser_registry_test.dart test/progressive_span_dispatch_contract_test.dart test/typed_source_location_contract_test.dart test/runtime_matching_test.dart test/compiled_spec_test.dart test/source_emitter_test.dart test/runtime_interpreter_test.dart test/action_contracts_test.dart"
  - "rg -n 'FrozenStagedRegistry|enrichStagedCurrentDepth|stagedJobIdentity|stagedCacheIdentity|stagedCurrentDepthOrder' dart/lib/src/runtime/staged_ast_enrichment.dart dart/test_dormant/staged_ast_enrichment_contract_test.dart"
---

# Dart staged current-depth authority

`FrozenStagedRegistry` is an invocation-local private snapshot. The caller has
already completed alias, declaring-relative, ordered search-root, and ordered
provider discovery and supplies every executable entry as an opaque compiled
callback. Construction deeply owns logical snapshot data and rejects missing or
extra callback bindings. Runtime `register` and `load` operations are typed
denials; the module contains no filesystem, provider-query, import-enumeration,
environment, network, loader, compiler, or registry-mutation route.

Pure resolution selects only those frozen outcomes. Entry top/version/
capability/policy/source-detail/resource fields can narrow caller authority but
cannot expand it. The entry's default top is selected before the canonical
`parse_job:v2:sha256:<digest>` identity. Cache identity covers normalized parser
identity, content and import-graph digests, selected top, spec/helper/staged
versions, and sorted effective capabilities. The cache retains only immutable
callback plans; every child result and failure executes again.

`enrichStagedCurrentDepth` copies the parent AST, discovers only the current
marker depth, prepares all resolution and stitch targets before the first
callback, and orders work by typed path, typed provenance, and job id using
Unicode-scalar string and numeric-index comparison. Every sibling receives a
fresh cursor/mark/capture/variable context. Successful results must be finite,
acyclic, node-bounded plain data with no live authority key. The four result
policies and three failure policies mutate only the unpublished copy, so a
`fail` outcome cannot expose earlier sibling work. Continuing failures retain
the same detached diagnostic in scheduler sidecars.

Returned markers remain inert: this API never rescans them. Breadth-first
recurrence, decreasing-chain/cycle checks, shared cancellation/deadline/work/
call/depth/result/diagnostic authority, callback safe points, and typed
original-source diagnostic rebasing belong exclusively to `.14.7.5.3`. Fresh
native/reconstructed/generated/emitted authority and admission remain `.4`.

Related: [[dart-staged-ast-enrichment-marker-provenance]],
[[general-staged-ast-enrichment-neutral-contract]],
[[general-staged-ast-current-boundary]],
[[dart-progressive-span-dispatch-authority]], and ADR `0088`.
