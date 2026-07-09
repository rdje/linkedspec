---
id: spec-derived-roundtrip-future-lane
title: Spec-derived parser and stimuli generation is parked as a future design lane
answers:
  - "where is the foo.spec parser stimuli idea tracked"
  - "is spec-derived stimuli generation planned"
  - "what owns single-source spec roundtrip validation"
  - "does foo.spec become the sole source of truth for parser and generator"
date: 2026-07-09
status: current
tags: [future-backlog, spec-source-of-truth, roundtrip, stimuli-generation]
evidence: "FUTURE-PARITY-BACKLOG.8.0 captures the director's 2026-07-09 brainstorm: derive both the parser for foo and the stimuli generator for that parser solely from foo.spec, enabling closed-loop roundtrip validation with .spec as the sole semantic source of truth. FUTURE-PARITY-BACKLOG.8.1 owns the future design pass before code; no implementation is active, and Dart remains the current implementation frontier."
reverify: "rg -n 'FUTURE-PARITY-BACKLOG\\.8|parser/stimuli|sole source|roundtrip|stimuli generator' docs/tasks/FUTURE-PARITY-BACKLOG.md docs/TASK_TREE.md ROADMAP.md ROADMAP_V2.md docs/linkedspec-book/src/overview/project-status.md MEMORY.md"
---

The idea is valuable because it would close a feedback loop around one source of
truth:

- `foo.spec` defines the parser contract.
- The same normalized `.spec` contract would drive stimuli generation.
- Roundtrip checks would then test parser behavior without maintaining a second
  hand-written generator grammar.

The open design risk is drift. `FUTURE-PARITY-BACKLOG.8.1` must specify how
generation is derived from `.spec` metadata, how it is bounded, how negative
cases and shrinking work, and how the generated checks compare across backends.

Related facts: [[staged-linked-parsing-architecture]],
[[spec-defined-user-function-definition-parser]], [[rust-perl-output-oracle]].
