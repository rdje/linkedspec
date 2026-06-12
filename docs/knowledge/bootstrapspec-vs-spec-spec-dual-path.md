---
id: bootstrapspec-vs-spec-spec-dual-path
title: BootstrapSpec::Core remains the primary parse path; specs/spec.spec is a self-hosted validation grammar but not yet the active frontend
answers:
  - "which grammar actually parses .spec files"
  - "is spec.spec the active frontend"
  - "what is BootstrapSpec::Core vs spec.spec"
  - "how does spec.spec relate to the bootstrap grammar"
date: 2026-06-12
status: current
tags: [architecture, bootstrap, self-hosting, frontend, spec.spec]
evidence: "ARCHITECTURE_STATE.md §Main Hotspots and Risks: BootstrapSpec::Core is 'dense syntax hotspot, difficult to change safely, still central until self-hosting is stronger'"
reverify: "grep -n 'still central until self-hosting' ARCHITECTURE_STATE.md"
---

LinkedSpec currently has two `.spec` grammars, serving different roles:

- **`BootstrapSpec::Core`** — the hardcoded Perl bootstrap grammar. This is the **active parse
  path** — it actually parses `.spec` files. It is dense, difficult to change safely, and
  remains "the main bootstrap/frontend syntax hotspot" (per `ARCHITECTURE_STATE.md`).

- **`specs/spec.spec`** — the self-hosted `.spec` grammar, written in LinkedSpec's own DSL.
  Completed in `PHASE7-SELF-HOSTED-SPEC` (5 leaves, 2026-05-17). It compiles with
  `language_agnostic_ready_ratio == 1.0000` and is the **preferred surface for `.spec`
  language evolution**. But it does not yet REPLACE the bootstrap grammar as the active
  parse path.

The PHASE7 task tree defined an extension-surface policy: `spec.spec` is the required change
surface for `.spec` language evolution; bootstrap grammar changes are exception-only with
explicit justification. The practical handoff from bootstrap to self-hosted is a deferred
architectural goal — `BootstrapSpec::Core` density remains a recognized risk.

Related: [[spec-spec-self-hosted-grammar]], [[architectural-hotspots]].
