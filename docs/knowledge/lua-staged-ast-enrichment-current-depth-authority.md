---
id: lua-staged-ast-enrichment-current-depth-authority
title: Lua has private caller-frozen staged authority for one complete marker depth
answers:
  - "where is Lua staged AST enrichment resolution implemented"
  - "how does Lua resolve pre-registered parse_job parsers"
  - "can Lua staged parse_job load a path or query a provider"
  - "how does Lua select the default staged top rule"
  - "how does Lua compute staged parse job ids"
  - "how does Lua cache staged parser plans"
  - "does the Lua staged cache retain child results or failures"
  - "which staged result policies work privately in Lua"
  - "which staged failure policies work privately in Lua"
  - "how are current-depth Lua staged jobs ordered"
  - "do sibling staged parsers share Lua runtime state"
  - "how are Lua staged child results detached"
  - "does Lua recursively execute returned staged markers"
  - "what does FUTURE-PARITY-BACKLOG 14.7.7.2 implement"
date: 2026-08-27
status: current private dual-ABI one-depth API; recursive scheduling and production carriers remain dormant RED
tags: [lua, PUC-Lua, LuaJIT, staged-parsing, parse-job, registry, cache, policies, detachment, private]
evidence: "FUTURE-PARITY-BACKLOG.14.7.7.2 adds private Lua-5.1-compatible staged_ast_enrichment.lua beside, not inside, the narrow function-body-v1 registry. FrozenStagedRegistry deeply owns caller-completed alias/declaring-relative/ordered-root/provider outcomes and an exact already-compiled opaque callback set. Resolution is pure and cannot discover, load, query, compile, access a path, or mutate the registry. Default top precedes exact v2 job identity; the registry-local cache stores immutable callback plans only under the neutral eight-field identity and never retains child results, failures, contexts, or partial AST state. One complete marker depth resolves every job and reserves every target before callback one, rejects cross-plan conflicts, sorts typed paths/provenance/job ids, gives siblings fresh cursor/mark/capture/variable contexts, detaches finite acyclic node-bounded plain results, and applies all four result plus three failure policies on an unpublished parent copy. Live keys and marker-shaped authority smuggling reject; failed child values do not poison later execution; valid returned markers stay inert. The same consumer reports 597 GREEN/one exact .14.7.7.3 recurrence/bounds/rebasing/fresh-carrier RED on both PUC Lua and LuaJIT. Ordinary/canonical discovery, both rollout rows, function-body v1, generated format v2, public/outward behavior, neutral 98 mutations, and other backends remain unchanged."
root_cause: "FUTURE-PARITY-BACKLOG.14.7.7.1 intentionally stopped at detached marker construction. Lua had no separate general-v2 frozen snapshot, pure resolver, selected-top-before-id function, immutable-plan cache, complete-depth target reservation/order seam, fresh sibling context, detachment boundary, or policy stitcher. lua/src/linkedspec/staged_parser_registry.lua is the deliberately narrow function-body-v1 adapter and must not be widened into this authority."
last_verified: 2026-08-27
reverify:
  - "bash tools/run_lua_project_data.sh puc lua/test/staged_ast_enrichment_contract_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/staged_ast_enrichment_contract_test.lua"
  - "rg -n 'freeze_registry|resolve_pre_registered|job_identity|cache_identity|current_depth_order|enrich_current_depth' lua/src/linkedspec/staged_ast_enrichment.lua lua/test/staged_ast_enrichment_contract_test.lua"
  - "rg -n 'staged_ast_enrichment_contract_test.lua' tools/run_lua_local.sh lua/test/run.lua tools/run_ci_local.sh"
---

# Lua staged current-depth authority

`FrozenStagedRegistry` is an opaque private token over a caller-completed
snapshot. Before authored execution, trusted host code supplies logical alias,
declaring-relative, ordered search-root, and ordered provider outcomes plus the
exact compiled callback named by each entry. Construction deeply copies the
logical data, copies the callback binding set, rejects missing or extra
bindings, and exposes only a detached snapshot identity and cache counters.

Post-AST resolution selects only among those frozen outcomes. Entry top rules,
versions, capabilities, policy modes, source-detail ceilings, and numeric
ceilings can narrow caller authority but cannot elevate it. The selected or
default top is fixed before `parse_job:v2:sha256:<digest>` is constructed.
Cache identity covers normalized parser identity, content and import-graph
digests, selected top, spec/helper/staged versions, and sorted effective
capabilities. Cached values contain only the compiled callback and immutable
plan identity; child values, failures, contexts, and partial AST work are not
retained.

`enrich_current_depth` copies the parent AST, discovers only its current marker
depth, prepares every resolution and authority decision, and reserves every
stitch target before callback one. Cross-plan target overlap rejects during
that preflight. Jobs then sort by typed parent path, typed provenance, and job
id. UTF-8 string ordering is Unicode-scalar compatible, while array components
stay numeric, so index 2 precedes 10. Every sibling receives a fresh cursor,
marks, captures, and variables table.

Successful callbacks must return detached finite acyclic node-bounded plain
data. Parser, registry, source, frame, transaction, cancellation, callback,
host, path, reference, and other live-authority keys reject even inside an
otherwise valid marker shape. `replace_marker`, `replace_field`,
`sibling_field`, and `append_child` update only the unpublished copy. `fail`
publishes nothing; `keep_text` and `diagnostic_node` retain one detached
scheduler-side diagnostic. Multiple appends to one array are valid and follow
the deterministic job order, while incompatible shared targets reject before
execution.

Returned authority-free markers remain inert on this one-depth API. Leaf
`.14.7.7.3` owns a separate breadth-first recursive entrypoint, strict lineage,
shared cancellation/resource limits, safe points, source rebasing, and fresh
native/reconstructed/generated/emitted carriers. It must preserve this
current-depth boundary unchanged.

Related: [[lua-staged-ast-enrichment-marker-provenance]],
[[lua-staged-ast-enrichment-dormant-red]],
[[general-staged-ast-enrichment-neutral-contract]],
[[general-staged-ast-current-boundary]],
[[julia-staged-ast-enrichment-current-depth-authority]],
[[dart-staged-ast-enrichment-current-depth-authority]],
[[rust-staged-ast-enrichment-current-depth-authority]],
[[perl-staged-ast-enrichment-current-depth-authority]], and ADR `0088`.
