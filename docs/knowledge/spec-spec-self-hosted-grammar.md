---
id: spec-spec-self-hosted-grammar
title: specs/spec.spec is the self-hosted .spec grammar and the preferred surface for .spec evolution
answers:
  - "is there a self-hosted .spec grammar"
  - "what is specs/spec.spec"
  - "how should .spec language changes land"
  - "where is the LinkedSpec language defined in LinkedSpec itself"
date: 2026-06-05
status: current
tags: [self-hosting, grammar, phase7]
evidence: "specs/spec.spec exists and compiles at language_agnostic_ready_ratio == 1.0000; docs/tasks/PHASE7-SELF-HOSTED-SPEC.md (5 leaves, done)"
reverify: "ls specs/spec.spec"
---

`specs/spec.spec` is a first-class LinkedSpec grammar that captures the currently supported
`.spec` syntax/semantics envelope, delivered by Phase 7 (`PHASE7-SELF-HOSTED-SPEC`). It is the
**required change surface** for `.spec` language evolution: author the change in `spec.spec`
first and keep the phase-0 regression at ratio 1.0000; touching the bootstrap grammar
(`BootstrapSpec::Core`) for `.spec` changes is exception-only and must be explicitly justified
(known bootstrapping gaps are documented in the spec.spec header + DEVELOPMENT_NOTES.md).
Canonical home: `docs/tasks/PHASE7-SELF-HOSTED-SPEC.md`, `specs/spec.spec` header.
Related: [[andplusplus-lx-parser-hang]].
