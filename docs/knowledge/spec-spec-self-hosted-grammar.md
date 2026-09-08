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
  - "where should import syntax be implemented"
  - "where should parse_job syntax be implemented"
  - "are the spec_spec corpus inputs current copies of specs spec.spec"
  - "how is self-hosted corpus grammar freshness checked"
date: 2026-06-05
status: current
tags: [self-hosting, grammar, phase7]
evidence: "specs/spec.spec exists and compiles at language_agnostic_ready_ratio == 1.0000; docs/tasks/PHASE7-SELF-HOSTED-SPEC.md (5 leaves, done). PERL-ACTIONIR-AST-MIGRATION.5.4 added a spec.spec policy note that permanent fn name(args) { ... } grammar belongs to the self-hosted grammar and added phase0 proof that BootstrapSpec.pm and BootstrapSpec/Core.pm have no current first-class fn grammar/node support. SPEC-FORMAT-TERSE.4.1 kept that boundary and made .4.2.1 the first implementation leaf. SPEC-FORMAT-TERSE.4.2.1 then landed the active function_definition rule and spec_file dispatch in specs/spec.spec while the Perl reference uses a temporary pre-bootstrap registry bridge. ADR 0012 later made the broader rule explicit: for .spec language evolution, specs/spec.spec is the first authoritative grammar in the staged linked parsing architecture; hardcoded bootstrap grammar is bridge debt, not a competing permanent owner. ADR 0013 reserves future import/include directive syntax as a design contract; ADR 0014 reserves future parse_job(text_expr, options) annotation syntax as a design contract. specs/spec.spec must eventually grow those directive/helper nodes before implementation treats them as permanent syntax."
evidence_update_2026_07_22: "FUTURE-PARITY-BACKLOG.10.5.0.1.2.0 regenerates the complete 105-case oracle with ORACLE_TIMEOUT=30 and makes all four spec_spec_* input.spec files byte-identical to canonical specs/spec.spec at SHA-256 43cddeaea03cfaddce941ca87f66185de1abf81e281e86c29156fbad16f6d2ce. tools/check_unicode_rule_label_contract.py now fails on any byte or hash drift. Perl generation plus Rust, Dart, Julia, and Lua complete corpus routes preserve all expected outputs."
evidence_update_2026_08_29: "FUTURE-PARITY-BACKLOG.15.2 adds complete-line lifecycle precedence and standalone lifecycle-I normalization to canonical specs/spec.spec. The first canonical attempt rejects the stale spec_spec_minimal_rule snapshot, proving the existing freshness guard. All four spec_spec_* input.spec mirrors are then updated through the same three grammar hunks and are byte-identical to canonical source at SHA-256 03cfb50459984806c806e9ec3f2b072add897c207a2cb93fd267d640a5808004; the Unicode rule-label contract passes. Canonical Phase 0 then exposes that its bootstrap-ownership guard raw-scanned all serialized payload text and mistook return(value) inside a valid lifecycle ICODE node for function ownership. The repaired guard recursively inspects only array tags and hash kind/node_type/tag/type identities, so ordinary lifecycle source is allowed while exact fn/function/function_definition/user_function_definition/FN_DEF node identities remain forbidden."
evidence_update_2026_09_08: "SESSION-STARTUP-READING.3.3.44 reconciles its four baseline scopes (225 lines / 65,141 bytes), completing the action-edge grammar copy through EOF. Canonical specs/spec.spec and all four corpus mirrors are 83,452 bytes / 226 lines at unchanged SHA-256 03cfb50459984806c806e9ec3f2b072add897c207a2cb93fd267d640a5808004. The freshness/Unicode check passes: Unicode 17.0.0, 806 ranges, 9 positive labels, 8 negatives, 2 distinct pairs. This reading checkpoint does not rerun the complete native or CLI parsing matrix."
reverify: "bash tools/run_python_project_data.sh tools/check_unicode_rule_label_contract.py && rg -n 'function_definition:|-> function_definition|temporary pre-bootstrap registry bridge|SPEC-FORMAT-TERSE\\.4\\.2\\.1|staged linked parsing|0012' specs/spec.spec docs/tasks/SPEC-FORMAT-TERSE.md docs/tasks/STAGED-LINKED-PARSING.md docs/decisions/0012-staged-linked-parsing-architecture.md && ! rg -n '\\bfn\\s+[A-Za-z_][A-Za-z0-9_]*\\s*\\(|function_definition|user_function_definition|FN_DEF' perl/LinkedSpec/BootstrapSpec.pm perl/LinkedSpec/BootstrapSpec/Core.pm"
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
ADR `0013` extends that rule to future `import`/`include` directives: the design is
accepted, but permanent syntax still needs to land in `specs/spec.spec` rather than
becoming bootstrap-only behavior.
ADR `0014` applies the same rule to the future `parse_job(text_expr, options)`
annotation helper for staged parsing.
Canonical home: `docs/tasks/PHASE7-SELF-HOSTED-SPEC.md`, `specs/spec.spec` header.
Related: [[andplusplus-lx-parser-hang]].
