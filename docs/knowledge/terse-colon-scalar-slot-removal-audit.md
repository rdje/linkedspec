---
id: terse-colon-scalar-slot-removal-audit
title: "SPEC-FORMAT-TERSE.15.1 split: colon-prefixed scalar-slot removal is broad and must migrate current surfaces before parser/runtime retirement"
answers:
  - "where is colon scalar slot removal split"
  - "how broad is colon scalar slot removal"
  - "what owns removing Expr::ScalarSlot"
  - "what is the SPEC-FORMAT-TERSE.15 split"
  - "which leaf migrates current :name examples"
  - "which leaf removes Perl colon scalar slot parsing"
  - "which leaf removes Rust Expr::ScalarSlot"
  - "why is :name removal not one safe slice"
date: 2026-07-05
status: confirmed
tags: [spec-format-terse, scalar-slot, variables, task-tree, audit, rust, perl, docs, corpus]
evidence: "SPEC-FORMAT-TERSE.15.1 audited `:name` scalar-slot usage before implementation. The scan found current usage across shipped specs/root corpora, generated Rust oracle fixtures, mdBook current guidance, Knowledge Map facts, `tools/gen_oracle_corpus.pl`, active Perl trace/phase0 tests, Rust parser/runtime/source-emitter tests, and parser/runtime code including Rust `Expr::ScalarSlot` plus Perl scalar-slot extraction/lowering. The lane is split: `.15.2` migrates current authored specs, corpus fixtures, mdBook guidance, and current Knowledge Map facts to bare-name value reads while compatibility remains; `.15.3` removes or hard-retires Perl reference `:name` parsing/lowering; `.15.4` removes or hard-retires Rust `Expr::ScalarSlot` parsing/runtime support; `.15.5` performs the final no-drift closeout. Hash-literal key positions remain a separate grammar boundary and must not be reinterpreted as value reads."
reverify: "rg -n ':[A-Za-z_][A-Za-z0-9_]*|ScalarSlot|scalar-slot|scalar slot' specs tests t tools perl rust docs/linkedspec-book/src docs/knowledge --glob '*.spec' --glob '*.md' --glob '*.t' --glob '*.pl' --glob '*.pm' --glob '*.rs'"
---

# Terse Colon Scalar-Slot Removal Audit

`SPEC-FORMAT-TERSE.15.1` confirmed that removing `:name` scalar-slot syntax is not one safe implementation slice.
The current spelling appears in authored specs and fixtures, public guidance, Knowledge Map facts, tests,
generator sources, and both Perl and Rust implementation paths.

The safe order is:

1. `SPEC-FORMAT-TERSE.15.2`: migrate current specs, corpus fixtures, mdBook guidance, and current Knowledge Map
   facts to bare-name value reads while compatibility still exists.
2. `SPEC-FORMAT-TERSE.15.3`: retire Perl reference scalar-slot parsing/lowering.
3. `SPEC-FORMAT-TERSE.15.4`: retire Rust `Expr::ScalarSlot` parser/runtime support.
4. `SPEC-FORMAT-TERSE.15.5`: perform the final no-drift scan and closeout.

The migration must preserve the grammar boundary between bare names in value positions, which read variables, and
bare names in hash-literal key positions, which remain stringified field names.
