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
date: 2026-09-08
status: current private current-depth authority admitted through FUTURE-PARITY-BACKLOG.14.7.4.4
tags: [rust, staged-parsing, parse-job, registry, cache, policies, private, admission]
evidence: "FUTURE-PARITY-BACKLOG.14.7.4.2 adds private rust/linkedspec-runtime/src/staged_ast_enrichment.rs and extends the same outer-cfg consumer. FrozenStagedRegistry accepts only caller-completed candidate outcomes and already-compiled opaque callbacks; pure dispatch performs alias, declaring-relative, ordered-root, and ordered-provider selection plus authority narrowing without loading or ambient access. The exact v2 identity selects the default top first; the run-local cache stores only immutable compiled plans under the neutral eight-field identity. One complete current depth is prepared and target-validated before execution, ordered by typed path/provenance/job id, isolated with fresh sibling contexts, and stitched atomically through all four result and three failure policies after detached node-bounded validation. The final RED now names only .14.7.4.3 recurrence, bounds, and diagnostic rebasing. Ordinary discovery remains zero tests, canonical CI has zero references, function-body v1/generated v2/Rust rollout/public surfaces remain unchanged, and neutral governance stays at 79 mutations."
evidence_update_2026_08_26_recursive_authority: "FUTURE-PARITY-BACKLOG.14.7.4.3 preserves this API and adds a separate enrich_recursively entrypoint with complete breadth-first depths, exact-text/full-provenance chains, shared resources, expiring callback safe points, and direct/ordered-derived original-source rebasing. The sole RED advances to .14.7.4.4 carriers/admission/rollout/production seam; see rust-staged-ast-enrichment-recursive-authority."
evidence_update_2026_08_26_carrier_admission: "FUTURE-PARITY-BACKLOG.14.7.4.4 gives this authority its first production caller through StagedAstEnrichmentSeed. Every top-level route constructs a fresh registry/cache, the ordinary/canonical consumer is GREEN, Rust rollout is complete at 84 mutations, and the dormant cfg/check-cfg/dead-code scaffolding is removed."
root_cause: "The marker/provenance leaf deliberately produced only inert logical data. Rust had no general-v2 frozen registry, pure resolver, selected-top-before-id function, plan-only cache, current-depth ordering/isolation seam, or portable result/failure stitcher. The existing staged_parser_registry.rs is a separate narrow function-body-v1 adapter and cannot safely be widened into that authority."
reverify:
  - "bash tools/run_cargo_local.sh test --locked --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test staged_ast_enrichment_contract"
  - "bash tools/run_cargo_local.sh check --locked --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --lib"
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
[[rust-staged-ast-enrichment-recursive-authority]]. `.14.7.4.4` now attaches native/reconstructed/generated/emitted
fresh top-level authority, ordinary/canonical admission, and Rust rollout through `StagedAstEnrichmentSeed`.

The module remains private but is production-live. The first carrier removed the historical outer cfg, cfg-only
exports, manifest check-cfg registration, and conditional `allow(dead_code)`; ordinary builds now exercise the
real caller and exact consumer without lint suppression.

Related: [[rust-staged-ast-enrichment-marker-provenance]], [[rust-staged-ast-enrichment-dormant-red]],
[[rust-staged-ast-enrichment-recursive-authority]], [[general-staged-ast-enrichment-neutral-contract]],
[[general-staged-ast-current-boundary]], and ADR `0088`.

## September 7 registry and current-depth source reading

`SESSION-STARTUP-READING.3.3.36` reads staged_ast_enrichment.rs 1–1267. Snapshot construction validates explicit
preparation/access flags, nonempty unique entry identities, bound opaque callbacks, digests, allowed/default
tops, versions, capabilities, policies and ceilings; callback names are replaced by an opaque sentinel before
hashing the logical snapshot. It starts an empty Mutex-protected plan cache. Resolution rejects alias/relative
collisions or same-priority ambiguity, then checks prepared search-root/provider groups without ambient I/O.
Version/top checks, capability/policy intersections and source-detail/resource minima narrow each request.

The cached values contain only compiled callbacks, selected identities/top and effective capabilities.
Current-depth execution prepares/sorts every marker and validates targets before callbacks, then revalidates
each target against its unpublished working copy. Successful plain JSON is node-bounded before stitching;
returned errors and caught panics enter failure-policy settlement. Exact identity construction, discovery,
stitching/detachment and settlement helpers occur later in the file and are not counted as read here.
Fresh staged neutral 9 legs/123 base+129 public mutations passes; earlier native controls remain dated evidence.

## September 7 complete-depth target correction

`SESSION-STARTUP-READING.3.3.37` reads staged_ast_enrichment.rs 1268–2766 (1,499 lines/53,102 bytes),
identical to the accepted source baseline. The identity/cache key helpers use exact logical field sets;
cache identity includes normalized spec identity, both validated digests, top/version/helper/capability data.
Typed queue paths order strings before integer indices. Per-job target checks do not reserve all destinations
against other prepared jobs: paired Rust/Perl controls establish missing competing-target admission.
See `staged-target-preparation-gaps.md` and repair .73; earlier complete-depth validation claims are bounded
to individual targets and covered fixtures, not reservation. Source-derived helpers and public native controls
also expose returned-marker detachment/provenance gaps under .74. Root-only markers reject before callbacks;
this does not adopt a new root replacement contract.

## September 7 final registry validators

`SESSION-STARTUP-READING.3.3.38` reads staged_ast_enrichment.rs 2767–3058, completing the 3,058-line file.
Direct candidates validate declaring/authored identities and require a prepared entry; ordered groups require
positive distinct order values and sort by that order. String sets deduplicate through BTreeSet; ceilings and
version integers use as_u64 with positive/nonnegative checks, not a floating cast. Parser identity uses the
declared lowercase ASCII segment syntax; this helper's top-rule syntax is ASCII identifier form. Digest checks
require sha256 plus 64 lowercase hex digits. Canonical JSON sorts object keys recursively and preserves array
order before hashing. These exact source observations do not remove .73–.75's measured execution gaps.

## September 8 current-depth consumer reading

`SESSION-STARTUP-READING.3.3.63` reconciles the consumer prefix through line 920.
It prepares compiled fixtures and frozen callbacks, matches neutral resolution,
authority, cache-key and queue cases, and exercises all four result policies and
three failure policies. Shared-registry calls demonstrate plan-cache reuse while a
separate registry starts empty. Sibling callback contexts, unpublished input on a
later failure, existing-target collisions, missing targets, authority/budget denials,
and failure-versus-partial-plan caching have explicit controls. Those fixtures do
not close the competing-target, provenance and resource gaps owned by `.73`–`.75`.

The contained-panic control temporarily replaces the process panic hook, calls
`enrich_current_depth`, then restores the previous hook. Its quiet execution does
not exercise the default panic hook. Recursive authority begins at line 914 and
continues under `.3.3.64`; fresh four-carrier execution is also reconciled there.

The preceding `.3.3.61` canonical gate (`64d82792`) passed this composed native
consumer 1/1 in 802.08 test seconds. The selected .63 neutral check passes nine
rollout legs, 123 base and 129 public mutations; neither result closes the separate
measured repairs or establishes arbitrary-input coverage.
