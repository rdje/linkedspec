---
id: general-staged-ast-enrichment-neutral-contract
title: General staged-AST enrichment has one executable neutral contract before backend behavior
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
status: executable neutral authority complete; Perl private current-depth authority complete; recurrence, carriers, admissions, and public authoring pending
tags: [staged-parsing, parse-job, source-location, registry, queue, policies, diagnostics, portability]
evidence: "FUTURE-PARITY-BACKLOG.14.7.2 adds capability_conformance/staged_ast_enrichment_contract.json plus tools/check_staged_ast_enrichment_contract.py and ADR 0088. The independent oracle executes 4 immutable registry entries; 2 sources; 8 provenance, 3 deterministic-id, 8 resolution, 6 authority, 10 cache, 4 breadth-first queue, 3 sibling-isolation, 4 result-policy, 3 failure-policy, 10 chain, and 5 detachment cases; 37 diagnostics; five planned backend consumers over six routes; four carrier requirements; ten outward guards; nine rollout legs; 35 exact owners; and 72 reason-checked corruptions. FUTURE-PARITY-BACKLOG.14.7.3.1-.2 advance only the dormant Perl consumer through the private declaration/provenance and current-depth resolution/cache/policy boundaries. It now has 133 GREEN top-level checks/one recursive-authority RED; four later consumers remain absent, only neutral rollout is complete, and outward surfaces remain absent."
reverify:
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "rg -n 'staged-AST enrichment|STAGED_PARSE_JOB_MARKER|staged_parse_job_v2|neutral_complete_backends_pending' docs/decisions/0088-pre-resolved-breadth-first-staged-ast-enrichment.md capability_conformance/staged_ast_enrichment_contract.json tools/check_staged_ast_enrichment_contract.py"
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

The existing v1 function-body adapter remains unchanged and explicit. Perl's exact final-path consumer is present
but dormant. Its private declaration carrier creates one exclusive opaque marker/sidecar with strict literal
options and typed direct/ordered-derived provenance. A separate private post-AST authority now consumes only a
caller-frozen already-compiled registry, executes one complete depth with isolated sibling state, caches only
immutable plans, and implements all four result plus three failure policies over detached data. The test has 133
GREEN top-level checks and fails only at the recursive queue/bounds/rebased-diagnostic boundary. This is not backend
admission. Perl `.14.7.3.3-.4`, later backends, recurrence, and public closeout retain their exact owners.

Related: [[general-staged-ast-current-boundary]], [[perl-staged-ast-enrichment-current-depth-authority]], [[staged-parse-job-annotation-contract]],
[[staged-parser-registry-dispatch-contract]], [[typed-source-location-cursor-algebra-direction]], and
[[progressive-span-dispatch-audit-plan]], plus [[perl-staged-ast-enrichment-marker-provenance]].
