---
id: julia-staged-ast-enrichment-current-depth-authority
title: Julia has private caller-frozen staged authority for one complete marker depth
answers:
  - "where is Julia staged AST enrichment resolution implemented"
  - "how does Julia resolve pre-registered parse_job parsers"
  - "can Julia staged parse_job load a path or query a provider"
  - "how does Julia select the default staged top rule"
  - "how does Julia compute staged parse job ids"
  - "how does Julia cache staged parser plans"
  - "does the Julia staged cache retain child results or failures"
  - "which staged result policies work privately in Julia"
  - "which staged failure policies work privately in Julia"
  - "how are current-depth Julia staged jobs ordered"
  - "do sibling staged parsers share Julia runtime state"
  - "how are Julia staged child results detached"
  - "does Julia recursively execute returned staged markers"
  - "what does FUTURE-PARITY-BACKLOG 14.7.6.2 implement"
date: 2026-08-27
status: current private one-depth API; recursive sibling API current; dormant and not publicly admitted
tags: [julia, staged-parsing, parse-job, registry, cache, result-policy, failure-policy, detachment, private]
evidence: "FUTURE-PARITY-BACKLOG.14.7.6.2 adds the unexported runtime/StagedAstEnrichment.jl authority and extends the same dormant consumer. _FrozenStagedRegistry accepts only deeply owned caller-completed candidate outcomes plus an exact set of already-compiled opaque callbacks; its logical entries, rule/capability/policy sets, and candidate groups are immutable tuples. Resolution is pure alias/declaring-relative/ordered-root/provider selection with exact narrowing diagnostics and no ambient loading. Default top precedes canonical v2 job identity. The registry-local cache stores immutable callback plans only under the exact neutral eight-field identity. One complete depth prepares every job and reserves every stitch target before callbacks, orders typed paths/provenance/job ids, gives siblings fresh cursor/mark/capture/variable state, detaches finite acyclic node-bounded results, denies live-authority keys even inside marker-shaped callback results, and atomically applies all four result plus three failure policies. Child failures and results are never cached; valid returned markers remain inert. The consumer is 309 GREEN/one .14.7.6.3 recurrence/bounds/safe-point/source-rebasing RED. Function-body v1, marker/provenance bytes, four logical routes, discovery, rollout, neutral 92-mutation governance, formats, public, and outward truth remain unchanged."
evidence_update_2026_08_27_recursive_authority: "FUTURE-PARITY-BACKLOG.14.7.6.3 preserves _enrich_staged_current_depth and adds a separate recursive sibling API. Returned markers remain inert when the one-depth entrypoint is selected; only _enrich_staged_recursively records successfully detached returned-marker paths with active lineage and prepares later depths. The same consumer is now 386 GREEN/one .14.7.6.4 carrier/production/admission/rollout RED."
root_cause: "FUTURE-PARITY-BACKLOG.14.7.6.1 intentionally stopped after inert marker construction. Julia had no private general-v2 frozen snapshot, pure selector, selected-top-before-id function, immutable-plan cache, complete-depth preflight/order seam, fresh sibling context, detachment boundary, or policy stitcher. The existing parser/StagedParserRegistry.jl is the deliberately narrow function-body-v1 adapter and cannot safely be widened into this authority."
last_verified: 2026-08-27
reverify:
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no julia/test/staged_ast_enrichment_contract_test.jl 2>&1 | rg '386 passed, 1 failed|missing fresh_carriers=\\[native,reconstructed,generated_plan,emitted_module\\]'"
  - "rg -n '_freeze_staged_registry|_resolve_staged_pre_registered|_staged_job_identity|_staged_cache_identity|_staged_current_depth_order|_enrich_staged_current_depth' julia/src/runtime/StagedAstEnrichment.jl julia/test/staged_ast_enrichment_contract_test.jl"
  - "rg -n 'staged_ast_enrichment_contract_test.jl' julia/test/runtests.jl tools/run_ci_local.sh"
---

# Julia staged current-depth authority

`_FrozenStagedRegistry` is a private registry instance over a caller-completed
snapshot. Before authored execution, the caller supplies alias,
declaring-relative, ordered search-root, and ordered provider outcomes plus the
exact opaque callbacks named by the immutable entries. Construction deeply owns
the logical data, rejects missing or extra callback bindings, and converts all
logical collections to tuples. Only its plan cache is mutable, private, and
registry-local.

Post-AST resolution selects solely among those frozen outcomes. Entry versions,
allowed top rules, capabilities, policy modes, source detail, and numeric
ceilings can narrow caller authority but never expand it. The entry's default
top is selected before the canonical `parse_job:v2:sha256:<digest>` identity.
Cache identity covers normalized parser identity, content and import-graph
digests, selected top, spec/helper/staged versions, and sorted effective
capabilities. Cache values contain only the compiled callback and immutable
plan identity; child values, failures, contexts, and callback execution state
are never retained.

`_enrich_staged_current_depth` copies the parent AST, discovers only its current
marker depth, prepares every resolution/authority decision and every stitch
target before callback one, and sorts by typed parent path, typed provenance,
then job id. Field/source strings use Unicode-scalar ordering and array indices
remain numeric, so index 2 precedes 10. Every sibling receives new cursor,
mark, capture, and variable dictionaries.

Successful callback results must be detached finite acyclic node-bounded plain
data with no parser, registry, source, frame, transaction, cancellation,
callback, host, path, reference, or other live handle. `replace_marker`,
`replace_field`, `sibling_field`, and `append_child` stitch only into the
unpublished copy. `fail` aborts without publishing earlier sibling work;
`keep_text` and `diagnostic_node` retain one detached scheduler-sidecar
diagnostic. Cross-plan target conflicts reject before callbacks, and a stale
marker identity still rejects at settlement.

Marker shape grants no exception to detachment. A callback may return a valid
authority-free marker for the next depth, but adding a live key such as
`callback` makes that result fail with `staged_result_not_detached`; otherwise
an inert marker could become an authority-smuggling envelope.

Returned markers deliberately remain inert on this one-depth API. Leaf
`.14.7.6.3` adds a separate breadth-first recursive sibling API with active
lineage, shared resources, callback safe points/expiry, and source rebasing;
it does not alter this entrypoint. Leaf `.4` retains fresh native,
reconstructed, generated, and emitted carrier authority plus admission.

Related: [[julia-staged-ast-enrichment-marker-provenance]],
[[julia-staged-ast-enrichment-recursive-authority]],
[[julia-staged-ast-enrichment-dormant-red]],
[[general-staged-ast-enrichment-neutral-contract]],
[[general-staged-ast-current-boundary]],
[[julia-progressive-span-dispatch-authority]], and ADR `0088`.
