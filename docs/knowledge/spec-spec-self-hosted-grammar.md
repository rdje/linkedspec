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
  - "does bootstrap own fn function syntax"
  - "is spec.spec the first grammar for staged .spec parsing"
date: 2026-06-05
status: current
tags: [self-hosting, grammar, phase7]
evidence: "specs/spec.spec exists and compiles at language_agnostic_ready_ratio == 1.0000; docs/tasks/PHASE7-SELF-HOSTED-SPEC.md (5 leaves, done). PERL-ACTIONIR-AST-MIGRATION.5.4 added a spec.spec policy note that permanent fn name(args) { ... } grammar belongs to the self-hosted grammar and added phase0 proof that BootstrapSpec.pm and BootstrapSpec/Core.pm have no current first-class fn grammar/node support. SPEC-FORMAT-TERSE.4.1 kept that boundary and made .4.2.1 the first implementation leaf. SPEC-FORMAT-TERSE.4.2.1 then landed the active function_definition rule and spec_file dispatch in specs/spec.spec while the Perl reference uses a temporary pre-bootstrap registry bridge. ADR 0012 later made the broader rule explicit: for .spec language evolution, specs/spec.spec is the first authoritative grammar in the staged linked parsing architecture; hardcoded bootstrap grammar is bridge debt, not a competing permanent owner."
reverify: "rg -n 'function_definition:|-> function_definition|temporary pre-bootstrap registry bridge|SPEC-FORMAT-TERSE\\.4\\.2\\.1|staged linked parsing|0012' specs/spec.spec docs/tasks/SPEC-FORMAT-TERSE.md docs/tasks/STAGED-LINKED-PARSING.md docs/decisions/0012-staged-linked-parsing-architecture.md && ! rg -n '\\bfn\\s+[A-Za-z_][A-Za-z0-9_]*\\s*\\(|function_definition|user_function_definition|FN_DEF' perl/LinkedSpec/BootstrapSpec.pm perl/LinkedSpec/BootstrapSpec/Core.pm"
---

`specs/spec.spec` is a first-class LinkedSpec grammar that captures the currently supported
`.spec` syntax/semantics envelope, delivered by Phase 7 (`PHASE7-SELF-HOSTED-SPEC`). It is the
**required change surface** for `.spec` language evolution: author the change in `spec.spec`
first and keep the phase-0 regression at ratio 1.0000; touching the bootstrap grammar
(`BootstrapSpec::Core`) for `.spec` changes is exception-only and must be explicitly justified
(known bootstrapping gaps are documented in the spec.spec header + DEVELOPMENT_NOTES.md).
The accepted user-function grammar follows that rule: final `fn <name>(...) { ... }`
support is a `specs/spec.spec` language-surface change, while any bootstrap parser
implementation is temporary migration debt to remove after text-to-AST handoff. After
`PERL-ACTIONIR-AST-MIGRATION.5.4`, the bootstrap parser has no current first-class
`fn` grammar or function-definition node support; that absence is phase0-locked.
`SPEC-FORMAT-TERSE.4.2.1` then landed the self-hosted `function_definition`
rule and `spec_file` dispatch edge. The hardcoded bootstrap parser still has no
first-class `fn` node; the Perl reference currently uses a temporary pre-bootstrap
registry bridge that strips top-level functions before ordinary bootstrap parsing.
ADR `0012` generalizes this into staged linked parsing: `specs/spec.spec` is the
first authoritative grammar for `.spec` evolution, and later `.spec` stages should
derive from source-provenance payloads rather than a competing bootstrap grammar.
Canonical home: `docs/tasks/PHASE7-SELF-HOSTED-SPEC.md`, `specs/spec.spec` header.
Related: [[andplusplus-lx-parser-hang]].
