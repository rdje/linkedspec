---
id: rust-staged-ast-enrichment-current-depth-authority
title: Rust has private caller-frozen staged authority for one complete marker depth
answers:
  - "where is Rust staged AST enrichment resolution implemented"
  - "how does Rust resolve pre-registered parse_job parsers"
  - "what does FUTURE-PARITY-BACKLOG 14.7.4.2 implement"
  - "how does Rust cache staged parser plans"
  - "which staged result and failure policies work privately in Rust"
  - "does Rust recursively execute newly returned staged markers"
  - "can Rust staged parse_job access the filesystem or providers"
  - "how are Rust staged sibling parser contexts isolated"
  - "why does the Rust staged AST module allow dead_code"
  - "when is the Rust staged AST dead_code allowance removed"
date: 2026-08-26
status: current private dormant current-depth authority; recursive extension is complete under FUTURE-PARITY-BACKLOG.14.7.4.3
tags: [rust, staged-parsing, parse-job, registry, cache, policies, private, dormant]
evidence: "FUTURE-PARITY-BACKLOG.14.7.4.2 adds private rust/linkedspec-runtime/src/staged_ast_enrichment.rs and extends the same outer-cfg consumer. FrozenStagedRegistry accepts only caller-completed candidate outcomes and already-compiled opaque callbacks; pure dispatch performs alias, declaring-relative, ordered-root, and ordered-provider selection plus authority narrowing without loading or ambient access. The exact v2 identity selects the default top first; the run-local cache stores only immutable compiled plans under the neutral eight-field identity. One complete current depth is prepared and target-validated before execution, ordered by typed path/provenance/job id, isolated with fresh sibling contexts, and stitched atomically through all four result and three failure policies after detached node-bounded validation. The final RED now names only .14.7.4.3 recurrence, bounds, and diagnostic rebasing. Ordinary discovery remains zero tests, canonical CI has zero references, function-body v1/generated v2/Rust rollout/public surfaces remain unchanged, and neutral governance stays at 79 mutations."
evidence_update_2026_08_26_recursive_authority: "FUTURE-PARITY-BACKLOG.14.7.4.3 preserves this API and adds a separate enrich_recursively entrypoint with complete breadth-first depths, exact-text/full-provenance chains, shared resources, expiring callback safe points, and direct/ordered-derived original-source rebasing. The sole RED advances to .14.7.4.4 carriers/admission/rollout/production seam; see rust-staged-ast-enrichment-recursive-authority."
root_cause: "The marker/provenance leaf deliberately produced only inert logical data. Rust had no general-v2 frozen registry, pure resolver, selected-top-before-id function, plan-only cache, current-depth ordering/isolation seam, or portable result/failure stitcher. The existing staged_parser_registry.rs is a separate narrow function-body-v1 adapter and cannot safely be widened into that authority."
reverify:
  - "RUSTFLAGS='--cfg linkedspec_staged_ast_enrichment_red' bash tools/run_cargo_local.sh test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test staged_ast_enrichment_contract"
  - "bash tools/run_cargo_local.sh test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test staged_ast_enrichment_contract"
  - "RUSTFLAGS='--cfg linkedspec_staged_ast_enrichment_red' bash tools/run_cargo_local.sh check --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --lib"
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "rg -n 'FrozenStagedRegistry|enrich_current_depth|staged_job_identity|staged_cache_identity|staged_current_depth_order' rust/linkedspec-runtime/src/staged_ast_enrichment.rs rust/linkedspec-runtime/tests/staged_ast_enrichment_contract.rs"
---

# Rust staged current-depth authority

`FrozenStagedRegistry` is an invocation-local immutable snapshot. Its entries already contain compiled opaque
callbacks and caller-supplied alias, relative, search-root, and provider candidate outcomes. Resolution is pure:
the module has no loader, compiler, filesystem, environment, network, provider-query, import-enumeration, or
registry-mutation path. Top, version, capability, policy, source-detail, and resource fields only narrow authority.

Default-top selection happens before `parse_job:v2:sha256:<digest>` construction. The cache key covers the neutral
content/import digests, marker/entry contract versions, selected top, and sorted effective capabilities. The cache
stores only immutable prepared callback plans for the current invocation; results, failures, and partial work are
never cached, and a new `FrozenStagedRegistry` begins with an empty cache.

`enrich_current_depth` discovers one complete marker depth, resolves and validates every job and stitch target,
then executes in typed parent-path/provenance/job-id order. Every child receives a fresh cursor, mark, capture, and
variable context. Results must be detached node-bounded plain JSON. `replace_marker`, `replace_field`,
`sibling_field`, and `append_child`, plus `fail`, `keep_text`, and `diagnostic_node`, operate on an unpublished AST
copy so a fail path cannot publish partial work. Newly returned markers remain inert and are not rescanned.

`FUTURE-PARITY-BACKLOG.14.7.4.3` preserves this one-depth entrypoint and adds a separate recursive entrypoint with
breadth-first recurrence, decreasing-chain/cycle/depth/call/cancellation/resource authority, callback safe points,
and original-source diagnostic rebasing. Its exact mechanism is recorded in
[[rust-staged-ast-enrichment-recursive-authority]]. Native/reconstructed/generated/emitted fresh top-level
authority, ordinary/canonical admission, and Rust rollout remain `.14.7.4.4`.

The module is private and has no production caller until `.14.7.4.4`; only the cfg-enabled dormant consumer uses
it today. Rust therefore diagnoses its items as dead in an ordinary build. `lib.rs` applies `allow(dead_code)` only
when `linkedspec_staged_ast_enrichment_red` is absent, and the runtime manifest registers that custom cfg for lint
checking. `.14.7.4.4` must remove the allowance when it attaches the first production carrier.

Related: [[rust-staged-ast-enrichment-marker-provenance]], [[rust-staged-ast-enrichment-dormant-red]],
[[rust-staged-ast-enrichment-recursive-authority]], [[general-staged-ast-enrichment-neutral-contract]],
[[general-staged-ast-current-boundary]], and ADR `0088`.
