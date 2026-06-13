---
id: bootstrapspec-vs-spec-spec-dual-path
title: BootstrapSpec::Core remains the primary parse path; spec.spec is wired as a dual-path side-channel parse via run_bootstrap_parse()
answers:
  - "which grammar actually parses .spec files"
  - "is spec.spec the active frontend"
  - "what is BootstrapSpec::Core vs spec.spec"
  - "how does spec.spec relate to the bootstrap grammar"
  - "does spec.spec run alongside bootstrap"
  - "dual-path parse"
date: 2026-06-13
status: current
tags: [architecture, bootstrap, self-hosting, frontend, spec.spec, dual-path]
evidence: "MEDIUM-IMPACT.3.5: BootstrapSpec.pm _build_spec_spec_parser() lazy-builds + caches spec.spec parser; run_bootstrap_parse() runs spec.spec alongside bootstrap (diagnostic side channel). Bootstrap always primary."
reverify: "grep -n '_build_spec_spec_parser\|run_bootstrap_parse' perl/LinkedSpec/BootstrapSpec.pm"
---

LinkedSpec currently has two `.spec` grammars, serving different roles:

- **`BootstrapSpec::Core`** — the hardcoded Perl bootstrap grammar. This is the **primary parse
  path** — it actually parses `.spec` files. It is dense, difficult to change safely, and
  remains "the main bootstrap/frontend syntax hotspot" (per `ARCHITECTURE_STATE.md`).

- **`specs/spec.spec`** — the self-hosted `.spec` grammar, written in LinkedSpec's own DSL.
  Completed in `PHASE7-SELF-HOSTED-SPEC` (5 leaves, 2026-05-17). It compiles with
  `language_agnostic_ready_ratio == 1.0000` and is the **preferred surface for `.spec`
  language evolution**.

As of **2026-06-13** (MEDIUM-IMPACT.3.5), spec.spec is now wired as a **dual-path parse**:
`BootstrapSpec.pm` gains `_build_spec_spec_parser()` which lazily builds the spec.spec-generated
parser via the bootstrap seed (BootstrapSpec::Core → Compiler → spec.spec → parser) and caches
it. `run_bootstrap_parse()` runs the spec.spec parser alongside the bootstrap parser as a
**diagnostic side channel** — BootstrapSpec::Core output is always primary (format compatibility).
A recursion guard prevents infinite loop (spec.spec trying to parse itself).

The PHASE7 task tree defined an extension-surface policy: `spec.spec` is the required change
surface for `.spec` language evolution; bootstrap grammar changes are exception-only with
explicit justification. The dual-path wire-up (.3.5) does not yet make spec.spec the primary
path — full parity (cross-check match on all 20 specs) is still in progress (.3.4), currently
at 2/20 exact match.

Related: [[spec-spec-self-hosted-grammar]], [[architectural-hotspots]].
