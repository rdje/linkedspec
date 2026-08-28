---
id: general-staged-ast-current-boundary
title: Current staged dispatch is a one-depth function-body path, not the general staged-AST contract
answers:
  - "what staged parsing behavior is implemented today"
  - "is general parse_job authoring implemented"
  - "which staged result policies work today"
  - "which staged failure policies work today"
  - "does the staged registry apply result policies"
  - "does the staged registry recursively enqueue jobs"
  - "does staged dispatch use typed source spans"
  - "which staged diagnostics lose job context"
  - "why does compile phase show unknown staged job fields"
  - "do all backends preserve staged compile diagnostic context"
  - "what did FUTURE-PARITY-BACKLOG.14.7.0 audit"
  - "what must happen before general staged AST enrichment"
date: 2026-08-25
status: current runtime audit; private Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT admissions independently recomposed; public authoring remains pending
tags: [staged-parsing, parse-job, diagnostics, registry, policies, recursive-queue, source-location, backend-parity]
evidence: "Toolbox-first source/runtime proof establishes the shipped boundary: five source backends/six runtimes implement only actionir-body.spec/action_block, one-depth ordering, fixed cache identity, and function-specific replace_field/body_ast/fail. FUTURE-PARITY-BACKLOG.14.7.1 repairs wrong-top diagnostic parity. FUTURE-PARITY-BACKLOG.14.7.2 adds the separate executable neutral v2 authority. Perl .14.7.3.1-.3 now add a dormant private marker/provenance carrier, caller-frozen pure resolution/cache, all policies/detachment, breadth-first recurrence, chain/resource bounds, and source-rebased diagnostics. They add no reconstructed/generated/emitted carriers, admission, rollout, or public authoring. Those remain .14.7.3.4-.10-owned."
evidence_update_2026_08_26_perl_admission: "FUTURE-PARITY-BACKLOG.14.7.3.4 adds four fresh-authority Perl routes, exact phase-0/canonical admission, and Perl-only rollout promotion. Public authoring, generated format, later backends, recurrence, and outward surfaces remain unchanged or pending."
evidence_update_2026_08_26_rust_dormant_red: "FUTURE-PARITY-BACKLOG.14.7.4.0 proves Rust's function-body v1 compatibility and the exact general-v2 boundary through one outer-cfg consumer. Authored parse_job remains generic Expr::Call, all four generic observation routes return null, expr-v1 is denied at v1 resolve, and only the final missing STAGED_PARSE_JOB_MARKER/staged_parse_job_v2 assertion fails. No Rust production, discovery, rollout, generated format, or outward surface moves."
evidence_update_2026_08_26_rust_marker_provenance: "FUTURE-PARITY-BACKLOG.14.7.4.1 makes the exact assignment form one exclusive Expr::StagedParseJobMarker with strict literal options and an inert detached staged_parse_job_v2 record. Live entry/match/capture spans materialize exact text and typed Unicode-scalar direct or ordered-derived provenance. Four logical routes agree; malformed, smuggled, residual, and transaction-reachable forms reject. Discovery, canonical topology, v1, format, rollout, public, and outward surfaces remain unchanged; only .14.7.4.2 authority is RED."
evidence_update_2026_08_26_rust_current_depth_authority: "FUTURE-PARITY-BACKLOG.14.7.4.2 adds a separate private general-v2 frozen registry and plan cache without widening the narrow v1 adapter. Pure pre-registered resolution, exact identities, isolated current-depth order, detached atomic stitching, every result/failure policy, and adversarial denials pass; only .14.7.4.3 recurrence/bounds/rebasing remains RED. Discovery, rollout, formats, public, and outward surfaces do not move."
evidence_update_2026_08_26_rust_recursive_authority: "FUTURE-PARITY-BACKLOG.14.7.4.3 adds breadth-first complete-depth recurrence, exact cycle/strict-decrease lineage, invocation-wide cancellation/deadline/step/call/depth/result/diagnostic bounds, callback safe points/expiry, and typed original-source rebasing without widening v1. Only .14.7.4.4 fresh carriers, production seam, admission, rollout, and parent closure remain RED."
evidence_update_2026_08_26_rust_admission: "FUTURE-PARITY-BACKLOG.14.7.4.4 constructs fresh registry/cache/recursive authority per top-level execution, runs it post-parent AST across native/reconstructed/generated/emitted routes, removes dormant cfg/dead-code scaffolding, and admits the ordinary consumer exactly once canonically. Rust is complete; Dart .14.7.5.0 is next."
evidence_update_2026_08_26_dart_dormant_red: "FUTURE-PARITY-BACKLOG.14.7.5.0 freezes Dart's exact next boundary without production changes. Assignment-form parse_job remains ActionAssignScalarExpr(ActionCallExpr), native and reconstructed execution diagnose unknown_helper, generated-plan and independently analyzed/executed emitted routes preserve that rejection, function-body v1 stays GREEN, and only the final dedicated-marker/typed-provenance assertion fails. Ordinary/canonical discovery and Dart rollout remain unchanged; .14.7.5.1 is next."
evidence_update_2026_08_26_dart_marker_provenance: "FUTURE-PARITY-BACKLOG.14.7.5.1 replaces only exact assignment-form parse_job with ActionStagedParseJobExpr, strict literal/static and recognition-effect closure, detached staged_parse_job_v2 data, and typed direct/ordered-derived Unicode-scalar provenance proven from live regex matches. Seven dormant groups and four logical routes agree; only .14.7.5.2 caller-frozen resolution/cache/result/failure authority remains RED. Function-body v1, neutral 85 mutations, discovery, rollout, generated format, public, and outward truth do not move."
evidence_update_2026_08_26_dart_current_depth_authority: "FUTURE-PARITY-BACKLOG.14.7.5.2 adds a separate private Dart general-v2 FrozenStagedRegistry and one-depth enrichStagedCurrentDepth path without widening staged_parser_registry.dart. Pure caller-frozen selection, exact identities, plan-only caching, typed current-depth order, fresh sibling state, detached atomic stitching, and all policies pass. Only .14.7.5.3 recurrence/bounds/rebasing is RED; discovery, rollout, formats, v1, public, and outward truth do not move."
evidence_update_2026_08_27_dart_recursive_authority: "FUTURE-PARITY-BACKLOG.14.7.5.3 adds private enrichStagedRecursively breadth-first queues, strict chain/cycle checks, shared cancellation/deadline/resource authority, expiring safe points, and direct/ordered-derived source rebasing without widening the v1 adapter. Complete-depth target reservation closes a latent pre-callback conflict. Only .14.7.5.4 carriers/admission/rollout remain RED; discovery, formats, public, and outward truth do not move."
evidence_update_2026_08_27_dart_admission: "FUTURE-PARITY-BACKLOG.14.7.5.4 attaches a fresh host-only staged seed to native, reconstructed, generated-plan, and emitted top-level execution after the parent AST. The consumer moves unchanged into ordinary discovery, passes 19/19, is registered exactly once canonically, and promotes only Dart. Generated format, function-body v1, public, and outward surfaces do not move."
evidence_update_2026_08_27_julia_dormant_red: "FUTURE-PARITY-BACKLOG.14.7.6.0 preserves Julia's narrow v1 adapter and adds one explicitly invoked final-path consumer. Eighty-six assertions pass before the sole missing STAGED_PARSE_JOB_MARKER/staged_parse_job_v2 RED; native/reconstructed/generated/emitted routes all preserve the generic unsupported parse_job helper. Ordinary/canonical discovery and Julia rollout do not move."
evidence_update_2026_08_27_julia_marker_provenance: "FUTURE-PARITY-BACKLOG.14.7.6.1 replaces only the exclusive Julia scalar-assignment boundary with ActionStagedParseJobExpr plus live native-capture-proven direct/ordered-derived Unicode-scalar provenance. Four logical routes agree at 131 GREEN/one .2 authority RED. Function-body v1, neutral governance, discovery, rollout, generated format, public, and outward surfaces do not move."
evidence_update_2026_08_27_julia_current_depth_authority: "FUTURE-PARITY-BACKLOG.14.7.6.2 adds a separate private Julia general-v2 frozen registry and one-depth enrichment path without widening StagedParserRegistry.jl. Pure caller-frozen selection, exact identities, plan-only caching, complete-depth target reservation and typed ordering, fresh sibling state, detached atomic stitching, and all policies pass. Only .14.7.6.3 recurrence/bounds/safe-points/rebasing is RED; discovery, rollout, formats, v1, public, and outward truth do not move."
evidence_update_2026_08_27_julia_recursive_authority: "FUTURE-PARITY-BACKLOG.14.7.6.3 adds a separate private Julia breadth-first entrypoint over exact returned-marker stitch paths and active lineage, strict cycle/decrease predicates, one shared cancellation/deadline/step/call/depth/result/diagnostic state, expiring callback safe points, and direct/ordered-derived source projection. The consumer is 386 GREEN/one .14.7.6.4 carrier/production/admission/rollout RED; discovery, neutral 92 mutations, formats, v1, public, and outward truth do not move."
evidence_update_2026_08_27_julia_admission: "FUTURE-PARITY-BACKLOG.14.7.6.4 adds Julia's host-only fresh-execution seed to the native and generated-v2 engine seams, runs recursive enrichment only after the complete parent value, admits the 491/491 consumer once in ordinary/canonical topology, and advances only Julia rollout plus exact topology governance to 97 mutations. Lua .14.7.7 is next."
evidence_update_2026_08_27_lua_dormant_red: "FUTURE-PARITY-BACKLOG.14.7.7.0 preserves Lua's narrow current function-body-v1 registry while adding one explicitly invoked shared dual-ABI general-v2 oracle. PUC Lua and LuaJIT each pass 153 pre-boundary assertions and fail only the missing dedicated marker/provenance assertion. Neutral lifecycle advances to Lua dormant_red at 98 mutations; Lua production, ordinary/canonical discovery, rollout, formats, and public behavior remain unchanged."
evidence_update_2026_08_27_lua_marker_provenance: "FUTURE-PARITY-BACKLOG.14.7.7.1 replaces only exact Lua scalar-assignment parse_job with a dedicated staged_parse_job_marker. Strict literal/static and recognition-effect closure reject malformed/residual forms. Private PCRE2 capture byte ranges feed existing typed source authority for direct/ordered-derived Unicode-scalar provenance without text search; four logical routes agree on PUC Lua and LuaJIT at 392 GREEN/one .2 authority RED. Function-body v1, neutral 98 mutations, discovery, rollout, generated format, public, and outward truth do not move."
evidence_update_2026_08_27_lua_current_depth_authority: "FUTURE-PARITY-BACKLOG.14.7.7.2 adds a separate private Lua-5.1 general-v2 FrozenStagedRegistry and enrich_current_depth path without widening staged_parser_registry.lua. Pure caller-frozen selection, exact identities, plan-only caching, complete-depth target reservation and typed order, fresh sibling state, detached atomic stitching, all policies, and adversarial denials pass on both ABIs. Only .14.7.7.3 recurrence/bounds/rebasing/fresh carriers are RED; discovery, rollout, formats, v1, public, and outward truth do not move."
evidence_update_2026_08_27_lua_recursive_carriers: "FUTURE-PARITY-BACKLOG.14.7.7.3 preserves the current-depth API and adds separate private enrich_recursively plus one opaque post-parent execution seed. Both ABIs pass 888 assertions over complete breadth-first recurrence, shared monotone authority, source rebasing, and four fresh production carriers while discovery, rollout, formats, v1, public, and outward truth stay fixed for .4."
evidence_update_2026_08_27_lua_admission: "FUTURE-PARITY-BACKLOG.14.7.7.4 moves only the unchanged shared consumer into exact ordinary/canonical dual-ABI discovery and promotes the two Lua rollout rows. Both hosts remain 888/888; production, function-body v1, generated format, public authoring, and outward surfaces do not move."
evidence_update_2026_08_28_lua_recomposition: "FUTURE-PARITY-BACKLOG.14.7.7.5 independently recomposes the committed shared Lua 888/888 carriers on both ABIs, every admitted peer/current projection, neutral 106-mutation governance, and exact topology without executable movement. Parent .14.7.7 closes and recurring proof .14.7.8 is next."
root_cause: "The first prototype deliberately separated a generic-looking registry record from a narrow trusted function-body integration. Compile helpers in Perl, Rust, and Dart were shaped around loaded parser identity plus top rule, so they synthesized a placeholder diagnostic record; Julia and Lua were implemented later with the complete job parameter but their formatter omitted payload_kind. Success-path and resolve-phase tests covered real context, but no cross-backend compile-phase assertion locked the ADR 0015 fields. Leaf .14.7.1 passes the normalized job through the three compile boundaries, adds payload_kind to the two later formatters, and locks all five source routes/six runtimes without expanding staged behavior."
last_verified: 2026-08-27
reverify:
  - "rg -n 'execute_parse_jobs|executeParseJobs|compile|_compile|result_policy|failure_policy|unsupported top rule|payload_kind' perl/LinkedSpec/StagedParserRegistry.pm rust/linkedspec-runtime/src/staged_parser_registry.rs dart/lib/src/parser/staged_parser_registry.dart julia/src/parser/StagedParserRegistry.jl lua/src/linkedspec/staged_parser_registry.lua"
  - "rg -n 'body_parse_job.*result_policy|body_parse_job.*failure_policy|result_policy must|failure_policy must' perl rust dart julia lua --glob '!**/generated*'"
  - "bash tools/run_cargo_local.sh test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test staged_ast_enrichment_contract"
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "perl tools/read_task_tree.pl --tree FUTURE-PARITY-BACKLOG --id FUTURE-PARITY-BACKLOG.14.7"
---

# General staged-AST current boundary

The current product implements one narrow staged family on five backend sources and six runtime routes:

| Boundary | Current behavior |
| --- | --- |
| Payload/job | Spec-returned `body_payload` plus `body_parse_job` for `function_definition` |
| Parser identity | `actionir-body.spec` -> `builtin:actionir-body.spec` only |
| Top rule | `action_block` only |
| Queue | One collected depth, stable parent-path/source-span/job-id order |
| Cache | Fixed adapter digest plus spec/top/version/capability fingerprint |
| Stitch | Function-specific `replace_field` into `body_ast` |
| Failure | Function-specific fail-fast behavior |
| Provenance | Copied exact text plus legacy numeric offset/line span |
| Runtimes | Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT |

The raw registry boundary normalizes and transports `result_policy`, `result_field`, and `failure_policy`; it does
not implement alternate policy behavior. Direct registry execution can therefore return records containing
`replace_marker`, `sibling_field`, `append_child`, `keep_text`, or `diagnostic_node`, but that is metadata transport,
not working stitch/failure semantics. The trusted function-body integration separately rejects anything other than
`replace_field` / `body_ast` / `fail` before it stitches the returned ActionIR body. General policy implementation
must not claim these inert strings as current behavior.

The current registry also does not scan stitched results for new jobs, advance stage depth, resolve several parser
families, enforce active-chain cycle/depth/call/resource bounds, or carry ADR `0056` typed source authority. Those
are the general `.14.7` program, not defects in the deliberately narrow success path.

One defect was independent of that feature boundary. A wrong `top_rule` failed in `compile` on every backend, but
Perl, Rust, and Dart constructed placeholder jobs while Julia and shared Lua omitted `payload_kind` from otherwise
real job context. `.14.7.1` now makes all five source backends/six runtimes report `phase=compile`, original
`job_id`, parent path, parser and resolved identities, rejected top rule, payload kind, source span, and failure
policy. This is diagnostic parity only. `.14.7.2` subsequently completes the separate executable neutral contract;
runtime behavior begins with the backend-owned `.14.7.3+` leaves. Perl `.14.7.3.0` froze the exact original
missing-marker boundary. Perl `.14.7.3.1-.4` now advance that same test to 143/143. The private exclusive marker, opaque sidecar, literal-option normalization, typed
direct/ordered-derived provenance, caller-frozen pure resolution, exact job/cache identity, breadth-first isolated
execution, all result/failure policies, detachment, exact-text/full-provenance chains, shared resource bounds,
diagnostic rebasing, malformed/smuggling rejection, and transaction closure exist. Native/reconstructed/generated/
emitted routes receive fresh host-only authority, and the consumer is admitted once in ordinary/canonical
discovery. This remains private Perl behavior, not public authoring. Rust `.14.7.4.0-.4` now implement and admit its
equivalent private boundary, declaration behavior, current-depth scheduler, recursive authority, and carriers:
current v1 remains
GREEN; the exact authored form becomes one inert detached marker with strict literals plus typed direct/ordered-
derived provenance; pure caller-frozen resolution/cache, isolated ordering, and every stitch/failure policy pass.
Complete depths run breadth-first; exact cycles and non-decreasing lineage reject; cancellation, deadlines, steps,
calls, depth, result nodes, and diagnostic bytes spend once across all depths; callback contexts expire; child
locations rebase through direct or ordered-derived provenance. One host-only seed now constructs a fresh
registry/cache/recursive authority for each top-level execution, and enrichment runs only after the complete parent
AST through native, reconstructed, generated-plan, and independently compiled emitted routes. The ordinary GREEN
consumer is registered exactly once in canonical CI; generated format and public authoring remain unchanged.
Dart `.14.7.5.0-.4` now implement and admit the equivalent private boundary.
The function-body-v1 adapter stays GREEN while exact assignment-form `parse_job(...)` becomes one inert typed
marker. A separate frozen resolver/cache/policy engine settles complete depths breadth-first, rejects exact cycles
and non-decreasing lineage, spends shared cancellation/deadline/step/call/depth/result/diagnostic authority,
expires callback safe points, and rebases direct/ordered-derived child diagnostics. Complete-depth target claims
are reserved before callbacks, including cross-plan conflicts. A host-only seed constructs fresh authority for
native, reconstructed, generated-plan, and independently executed emitted routes after the parent AST. The final
consumer passes 19/19 in ordinary discovery and is required once canonically; Dart rollout is complete while
format, public, and outward surfaces do not move.

Julia `.14.7.6.0-.4` now implement and admit its equivalent private declaration, current-depth, recursive, and
fresh-carrier boundary. The exact final-path consumer is included once by `julia/test/runtests.jl` and canonical
CI and preserves current function-body v1. Exact
scalar assignment-form `parse_job(...)` becomes one dedicated inert node; Julia's native absolute UTF-8 capture
offsets pass through the existing source authority to typed Unicode-scalar direct or nonempty ordered-derived
provenance. Native, `SpecFile`-JSON reconstructed, validated generated-plan, and independently included emitted-
module routes return the same detached marker. A separate tuple-frozen registry then performs pure resolution,
selected-top-before-id identity, plan-only caching, complete-depth target reservation and typed order, fresh
sibling execution, detached results, and all four result/three failure policies. Its separate recursive entrypoint
queues only successfully detached returned markers by exact stitch path, carries full active lineage, enforces
cycle/decrease and non-resetting resources, expires callback safe points, and rebases direct/ordered-derived child
locations. One opaque host seed starts a new registry/cache/recursive authority on each native, reconstructed,
generated-plan, or independently included emitted execution and enriches only after the complete parent value.
The Julia consumer is 491/491 GREEN and admitted. Lua now has one shared 888/888 admitted consumer on both ABIs
with private marker/provenance, current-depth authority, bounded recursive scheduling, source rebasing, and four
fresh production carriers complete. Its function-body-v1 path remains unchanged; ordinary and canonical drivers
run the stable source exactly once per ABI. Independent `.14.7.7.5` recomposes both committed ABI routes unchanged
and closes the shared backend parent.

The dependency plan then separates neutral contract, each backend, exact five-source/six-runtime recurrence,
public `parse_job(...)` authoring, and final whole-program recomposition. General staged dispatch reuses the typed source
algebra and authority-narrowing principles already established for progressive dispatch. ADR `0088` now fixes it
as a post-AST breadth-first deterministic queue: it does not reuse progressive `dispatch_span` syntax, expose host
callbacks, or interpret an authored parser id as permission to read a filesystem path.

The audit freezes 37 new stable staged owners, moving the authoritative partition-checker census from 557 to 594.
The existing part remains only 221 lines / 73,822 bytes under unchanged 5,000-line / 786,432-byte member limits;
no capacity or partition architecture changes. A raw grep also sees the root tree record; stable-ID claims must use
`scripts/check_task_tree_partitions.pl`, which deliberately counts the task leaves governed by the partition.

Related: [[function-body-staged-registry-dispatch]], [[staged-parser-registry-dispatch-contract]],
[[staged-parse-job-annotation-contract]], [[general-staged-ast-enrichment-neutral-contract]],
[[perl-staged-ast-enrichment-current-depth-authority]], [[perl-staged-ast-enrichment-recursive-authority]],
[[rust-staged-ast-enrichment-marker-provenance]], [[rust-staged-ast-enrichment-current-depth-authority]],
[[rust-staged-ast-enrichment-recursive-authority]], [[rust-staged-ast-enrichment-carriers-admission]],
[[dart-staged-ast-enrichment-dormant-red]],
[[dart-staged-ast-enrichment-current-depth-authority]],
[[dart-staged-ast-enrichment-recursive-authority]],
[[dart-staged-ast-enrichment-carriers-admission]],
[[julia-staged-ast-enrichment-dormant-red]],
[[julia-staged-ast-enrichment-current-depth-authority]],
[[julia-staged-ast-enrichment-recursive-authority]],
[[lua-staged-ast-enrichment-current-depth-authority]],
[[lua-staged-ast-enrichment-carriers-admission]],
[[progressive-span-dispatch-audit-plan]], and ADRs `0012`,
`0014`, `0015`, `0016`, `0056`, and `0088`.
