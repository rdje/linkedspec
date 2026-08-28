---
id: staged-parser-registry-dispatch-contract
title: Staged parser dispatch uses a deterministic registry, cache keys, and work queue
answers:
  - "how are staged parse jobs dispatched"
  - "how should parser spec ids be resolved"
  - "what is the staged parser registry"
  - "what belongs in a staged parser cache key"
  - "how are multiple parse jobs ordered"
  - "how are staged parse dispatch cycles diagnosed"
  - "can one stage route to multiple next specs"
  - "are staged dispatch caches language neutral"
date: 2026-07-02
status: executable general-v2 authority and exact public assignment authoring current; narrow v1 remains separate
tags: [architecture, staged-parsing, parser-registry, dispatch, caching, language-neutral]
evidence: "ADR 0015 accepts the general deterministic registry/queue. FUTURE-PARITY-BACKLOG.14.7.2 and ADR 0088 make the neutral target executable: all alias/relative/search-root/provider discovery and compilation is caller-complete before authored execution; post-AST selection uses an immutable snapshot/cache; scheduling is breadth-first by depth/path/provenance/id; all policies, isolation, decreasing chains, bounds, detachment, diagnostics, carriers, rollout, and 35 owners are mutation-checked. The five-backend/six-runtime product remains the narrow v1 function-body adapter until .14.7.3+ admissions."
evidence_update_2026_08_28_general_v2_admission: "FUTURE-PARITY-BACKLOG.14.7.3-.9 admit general v2 on five backend sources/six runtime routes, bind recurrence, and make only exact scalar assignment-form parse_job public. The scheduler still selects only caller-frozen already-compiled entries; authored parser ids grant no loading, provider, compilation, or mutation authority."
reverify: "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
---

Staged parse jobs dispatch through a neutral registry, not host-language module loading.

The registry operations are `resolve`, `load`, `compile`, and `execute`. Resolution checks
parent import aliases/composed identities, declaring-spec-relative paths, configured
search roots, and explicit registry providers in declared order. Missing, ambiguous, or
colliding resolutions are hard diagnostics.

Cache keys include normalized spec identity, content digest, import/include graph
fingerprint, selected top rule, `.spec` language version, helper/action contract version,
staged parsing contract version, and backend capability set.

Dispatch is a stable queue: collect jobs after the current stage parse, order by parent
AST path, source span, and `job_id`, resolve/compile, execute in that order, stitch
results, then enqueue parse jobs emitted by stitched results at the next stage depth.

Cycles are hard diagnostics when the active chain repeats normalized spec identity, top
rule, payload digest, and source span.

The shipped product keeps two paths separate. The stable one-depth function-body-v1 adapter still uses built-in
`actionir-body.spec` / `action_block` and stitches `body_ast`. General v2 separately supports exact assignment-form
public authoring, the caller-frozen registry, all policies, breadth-first recurrence, cycle/resource authority,
and typed diagnostics on all six runtime routes. See [[general-staged-ast-current-boundary]] for the boundary.
