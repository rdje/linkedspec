---
id: spec-spec-self-hosted-grammar
title: specs/spec.spec is the self-hosted .spec grammar and the preferred surface for .spec evolution
answers:
  - "is there a self-hosted .spec grammar"
  - "what is specs/spec.spec"
  - "how should .spec language changes land"
  - "where is the LinkedSpec language defined in LinkedSpec itself"
  - "where should fn syntax be implemented"
  - "does spec.spec own user function syntax"
date: 2026-06-05
status: current
tags: [self-hosting, grammar, phase7]
evidence: "specs/spec.spec exists and compiles at language_agnostic_ready_ratio == 1.0000; docs/tasks/PHASE7-SELF-HOSTED-SPEC.md (5 leaves, done). On 2026-07-01 the user clarified that permanent fn <name>(...) { ... } support belongs in specs/spec.spec and bootstrap-parser support must be retired once the text-to-AST path can carry it."
reverify: "ls specs/spec.spec && rg -n 'specs/spec\\.spec|bootstrap-parser fn|bootstrap parser support|Function syntax' docs/tasks/SPEC-FORMAT-TERSE.md DEVELOPMENT_NOTES.md LIVE_ACHIEVEMENT_STATUS.md"
---

`specs/spec.spec` is a first-class LinkedSpec grammar that captures the currently supported
`.spec` syntax/semantics envelope, delivered by Phase 7 (`PHASE7-SELF-HOSTED-SPEC`). It is the
**required change surface** for `.spec` language evolution: author the change in `spec.spec`
first and keep the phase-0 regression at ratio 1.0000; touching the bootstrap grammar
(`BootstrapSpec::Core`) for `.spec` changes is exception-only and must be explicitly justified
(known bootstrapping gaps are documented in the spec.spec header + DEVELOPMENT_NOTES.md).
The accepted user-function grammar follows that rule: final `fn <name>(...) { ... }`
support is a `specs/spec.spec` language-surface change, while any bootstrap parser
implementation is temporary migration debt to remove after text-to-AST handoff.
Canonical home: `docs/tasks/PHASE7-SELF-HOSTED-SPEC.md`, `specs/spec.spec` header.
Related: [[andplusplus-lx-parser-hang]].
