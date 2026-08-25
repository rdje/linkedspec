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
status: accepted general architecture; narrow function-body registry current, general contract pending FUTURE-PARITY-BACKLOG.14.7
tags: [architecture, staged-parsing, parser-registry, dispatch, caching, language-neutral]
evidence: "ADR 0015 accepts the general staged parser registry/dispatch contract. The current five-backend/six-runtime function-body prototype implements resolve/load/compile/execute, one built-in identity, a fixed adapter cache key, stable one-depth ordering, and function-specific stitching. General alias/relative/search-root/provider resolution, several parser families, recursive enqueue, cycle/resource guards, and alternate policy semantics remain pending under FUTURE-PARITY-BACKLOG.14.7."
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
rule, payload digest, and source span.

The current shipped implementation is a deliberately narrow subset: all five backend
sources/six runtime routes execute stable one-depth function-body jobs through the built-in
`actionir-body.spec` / `action_block` adapter and stitch `body_ast`. They do not recursively
enqueue jobs, resolve several registered/parser-file families, apply the alternate
result/failure policies, or enforce the general cycle/resource contract. See
[[general-staged-ast-current-boundary]] for the exact implemented-versus-future inventory.
