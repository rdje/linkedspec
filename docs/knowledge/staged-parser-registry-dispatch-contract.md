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
status: current
tags: [architecture, staged-parsing, parser-registry, dispatch, caching, language-neutral]
evidence: "ADR 0015 accepts the design-only staged parser registry/dispatch contract. The registry operations are resolve, load, compile, and execute. Parse-job resolution checks parent import aliases/composed identities, declaring-spec-relative paths, configured search roots, and registry providers in declared order. Cache keys include normalized spec identity, content digest, import/include graph fingerprint, top rule, spec language version, helper/action contract version, staged parsing contract version, and backend capabilities. Dispatch uses a stable work queue ordered by parent AST path, source span, and job_id; cycles repeat normalized spec id + top rule + payload digest + source span."
reverify: "rg -n 'resolve\\(spec_id|load\\(resolved_spec_id|compile\\(resolved_spec_id|execute\\(compiled_parser|stable order|cache key|capability|cycle|0015|STAGED-LINKED-PARSING.4' docs/decisions docs/tasks docs/linkedspec-book/src ROADMAP_V2.md"
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
rule, payload digest, and source span. Current shipped parsers do not yet implement this
staged registry/dispatch queue.
