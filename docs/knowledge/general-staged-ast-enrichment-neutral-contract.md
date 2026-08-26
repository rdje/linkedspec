---
id: general-staged-ast-enrichment-neutral-contract
title: General staged-AST enrichment has one executable neutral contract governing backend rollout
answers:
  - "what is the general staged AST enrichment neutral contract"
  - "what does FUTURE-PARITY-BACKLOG 14.7.2 implement"
  - "how does parse_job v2 work"
  - "does parse_job execute a parser immediately"
  - "when are staged parser identities resolved"
  - "can parse_job load a filesystem path"
  - "how are staged parse jobs ordered across recursive depths"
  - "how are derived text parse jobs attributed to source"
  - "what are the four staged result policies"
  - "what are the three staged failure policies"
  - "how are staged parse cycles bounded"
  - "do staged parse jobs share parser runtime state"
  - "which staged AST backend consumers are planned"
  - "is general parse_job authoring public"
date: 2026-08-25
status: executable neutral with private Perl and Rust admissions complete; Dart current-depth authority dormant; Julia, Lua, recurrence admission, and public authoring pending
tags: [staged-parsing, parse-job, source-location, registry, queue, policies, diagnostics, portability]
evidence: "FUTURE-PARITY-BACKLOG.14.7.2 adds capability_conformance/staged_ast_enrichment_contract.json plus tools/check_staged_ast_enrichment_contract.py and ADR 0088. The independent oracle executes 4 immutable registry entries; 2 sources; 8 provenance, 3 deterministic-id, 8 resolution, 6 authority, 10 cache, 4 breadth-first queue, 3 sibling-isolation, 4 result-policy, 3 failure-policy, 10 chain, and 5 detachment cases; 37 diagnostics; five planned backend consumers over six routes; four carrier requirements; ten outward guards; nine rollout legs; 35 exact owners; and 72 reason-checked corruptions. FUTURE-PARITY-BACKLOG.14.7.3.1-.3 advance only the dormant Perl consumer through declaration/provenance, current-depth policies, breadth-first recurrence, bounded authority, and source-rebased diagnostics. It now has 141 GREEN top-level checks/one carrier-admission RED; four later consumers remain absent, only neutral rollout is complete, and outward surfaces remain absent."
evidence_update_2026_08_26_perl_admission: "FUTURE-PARITY-BACKLOG.14.7.3.4 advances the executable boundary to neutral+Perl complete with 78 reason-checked mutations. The 143-check Perl consumer proves four fresh-authority carriers and exact ordinary/canonical admission; later consumers and outward surfaces remain absent."
evidence_update_2026_08_26_rust_dormant_red: "FUTURE-PARITY-BACKLOG.14.7.4.0 advances only the Rust consumer lifecycle to dormant_red and the checker to 79 mutations. Ordinary Cargo discovers zero tests; the cfg-enabled final path passes every neutral, current-v1, and four-carrier observation before one exact missing STAGED_PARSE_JOB_MARKER/staged_parse_job_v2 RED. Rust rollout and canonical registration remain pending; Dart, Julia, and Lua consumers remain absent."
evidence_update_2026_08_26_rust_marker_provenance: "FUTURE-PARITY-BACKLOG.14.7.4.1 implements the Rust-only private declaration carrier: one exclusive static node, exact detached marker, strict literal normalization, exact materialized text, and Unicode-scalar direct/ordered-derived provenance built from live spans. The same cfg consumer proves four logical carrier routes and reaches only .14.7.4.2 authority RED; neutral lifecycle/mutations, ordinary/canonical topology, v1, format, rollout, public, and outward truth do not move."
evidence_update_2026_08_26_rust_current_depth_authority: "FUTURE-PARITY-BACKLOG.14.7.4.2 implements private Rust pure resolution over a caller-frozen already-compiled snapshot, selected-top-before-job-id identity, plan-only run-local caching, complete current-depth ordering/isolation, detached atomic stitching, and all four result/three failure policies. Only .14.7.4.3 recurrence/bounds/rebasing remains RED; lifecycle, mutations, discovery, rollout, v1/v2 formats, public, and outward truth do not move."
evidence_update_2026_08_26_rust_recursive_authority: "FUTURE-PARITY-BACKLOG.14.7.4.3 completes private Rust breadth-first recurrence, exact-text/full-provenance cycle and strict-decrease guards, monotone cancellation/deadline/step/call/depth/result/diagnostic authority, expiring callback safe points, and direct/ordered-derived source rebasing. Only .14.7.4.4 carriers/production seam/admission/rollout remain RED; lifecycle, 79 mutations, ordinary/canonical dormancy, formats, public, and outward truth do not move."
evidence_update_2026_08_26_rust_admission: "FUTURE-PARITY-BACKLOG.14.7.4.4 adds one host-only fresh-invocation seed, four equal native/reconstructed/generated/emitted production carriers, ordinary/canonical admission, and Rust-only rollout. The checker now rejects 84 mutations with Perl and Rust complete; Dart/Julia/Lua, recurrence, public authoring, formats, and outward surfaces remain pending or unchanged."
evidence_update_2026_08_26_dart_dormant_red: "FUTURE-PARITY-BACKLOG.14.7.5.0 advances only Dart's backend-consumer lifecycle to dormant_red and the checker to 85 mutations. Fatal analysis and four pre-boundary tests pass: neutral/current-v1 controls stay exact, authored syntax remains one generic ActionCallExpr, and native/reconstructed/generated-plan/independently executed emitted routes preserve the structured unknown_helper rejection. The fifth and only RED names missing STAGED_PARSE_JOB_MARKER/staged_parse_job_v2. The final path, ordinary/canonical registration, Dart rollout, production, format, public, and outward truth remain unchanged."
evidence_update_2026_08_26_dart_marker_provenance: "FUTURE-PARITY-BACKLOG.14.7.5.1 adds the private Dart declaration carrier without changing neutral lifecycle or mutation count: exact assignment-only lowering, normalized literal options, live-regex-proven Unicode-scalar direct/ordered-derived provenance, detached authority-free marker data, malformed/residual/transaction denial, and four equal logical routes. Seven groups pass and only .14.7.5.2 authority remains RED; final-path/canonical references, rollout, v1/v2 formats, public, and outward truth remain unchanged."
evidence_update_2026_08_26_dart_current_depth_authority: "FUTURE-PARITY-BACKLOG.14.7.5.2 adds Dart's separate private caller-frozen general-v2 registry, pure resolution, selected-top-before-id identity, immutable-plan cache, complete current-depth preflight/order/isolation, detached atomic stitching, and all four result/three failure policies. The same dormant consumer is +12/-1 and only .14.7.5.3 recurrence/bounds/rebasing remains RED; neutral lifecycle/mutations, discovery, rollout, formats, public, and outward truth do not move."
reverify:
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "rg -n 'staged-AST enrichment|STAGED_PARSE_JOB_MARKER|staged_parse_job_v2|neutral_perl_and_rust_complete' docs/decisions/0088-pre-resolved-breadth-first-staged-ast-enrichment.md capability_conformance/staged_ast_enrichment_contract.json tools/check_staged_ast_enrichment_contract.py"
  - "perl tools/read_task_tree.pl --tree FUTURE-PARITY-BACKLOG --id FUTURE-PARITY-BACKLOG.14.7.2"
---

# General staged-AST enrichment neutral contract

`parse_job(text_expr, options)` is selected as a dedicated future marker/sidecar operation, not an ordinary
callback and not immediate parser execution. Stage-N authored code constructs `STAGED_PARSE_JOB_MARKER` plus one
scheduler-owned `staged_parse_job_v2` record. Scheduling starts only after the complete stage-N AST returns.

The caller resolves all statically declared aliases, declaring-spec-relative identities, search roots, and
providers and freezes already-compiled immutable entries before authored execution. The later `resolve` phase is
pure selection from that snapshot. Authored code cannot read a path, query a provider, compile, mutate, or
enumerate the registry.

Direct text carries one same-source Unicode-scalar span. Derived text carries ordered direct spans under
`concatenate_in_order`. Deterministic v2 job identity digests declaring spec, parent path, node/payload kinds,
parser/top identities, and complete provenance. Default top selection occurs before the digest.

The scheduler validates a complete depth, then executes breadth-first by depth, typed parent path, typed
provenance, and job id. Field/source strings order by Unicode scalar value and nonnegative path indices order
numerically, so index `2` precedes `10` on every backend. Each child gets fresh cursor/mark/capture/variable/parser
state; siblings share only the immutable registry and narrowing cancellation/deadline/budget/call authority.
Newly stitched markers wait for the next depth.

The result policies are `replace_marker`, `replace_field`, `sibling_field`, and `append_child`. The failure policies
are `fail`, `keep_text`, and `diagnostic_node`. Exact tuple repeats are cycles; repeated parser/top lineage requires
strictly contained provenance with smaller scalar extent. Depth, calls, work, cancellation, deadline, result
nodes, and diagnostic bytes remain shared bounded authority. Results are detached plain data.

The existing v1 function-body adapter remains unchanged and explicit. Perl's exact final-path consumer is admitted.
Its private declaration carrier creates one exclusive opaque marker/sidecar with strict literal
options and typed direct/ordered-derived provenance. A separate private post-AST authority now consumes only a
caller-frozen already-compiled registry, executes breadth-first complete depths with isolated sibling state, caches
only immutable plans, enforces decreasing chains and shared limits, rebases diagnostics, and implements all four
result plus three failure policies over detached data. A host-only runtime constructs fresh scheduler/cache
authority for native, normalized-descriptor, generated-plan, and independently loaded emitted routes. The test is
143/143 and appears once in phase-0/canonical CI. This is private Perl admission, not public authoring; later
backends, recurrence, and public closeout retain their exact owners. Rust now admits the same private semantics
through a host-only fresh-invocation seed across native, reconstructed, generated-plan, and independently compiled
emitted routes. Each run starts an empty cache and fresh recursive authority after the parent AST; ordinary and
canonical discovery run one GREEN consumer, and Rust rollout is complete. Dart now has one deliberately excluded
dormant consumer: its current generic call reaches only a structured unknown-helper rejection, and `.14.7.5.1`
owns the missing dedicated marker plus typed provenance. Dart now also has one
private current-depth resolver/cache/policy engine; returned markers remain
inert until `.14.7.5.3` adds bounded breadth-first recurrence and source
rebasing.

Related: [[general-staged-ast-current-boundary]], [[perl-staged-ast-enrichment-current-depth-authority]], [[perl-staged-ast-enrichment-recursive-authority]], [[staged-parse-job-annotation-contract]],
[[staged-parser-registry-dispatch-contract]], [[typed-source-location-cursor-algebra-direction]], and
[[progressive-span-dispatch-audit-plan]], [[perl-staged-ast-enrichment-marker-provenance]], and
[[rust-staged-ast-enrichment-dormant-red]], [[rust-staged-ast-enrichment-marker-provenance]], and
[[rust-staged-ast-enrichment-current-depth-authority]], and
[[rust-staged-ast-enrichment-recursive-authority]], and
[[dart-staged-ast-enrichment-dormant-red]], and
[[dart-staged-ast-enrichment-current-depth-authority]].
