---
id: hash-literal-colon-migration-split
title: "SPEC-FORMAT-TERSE.9.1 split the hash-literal => to : migration and classified non-hash owners."
answers:
  - "what does SPEC-FORMAT-TERSE.9 split"
  - "which => occurrences are not hash literal association syntax"
  - "does hash literal colon migration remove blind call => edges"
  - "where are hash literal parser support sites in Perl and Rust"
  - "which files own the hash literal => to colon migration"
  - "how should VHDL association => be treated during hash literal migration"
date: 2026-07-07
status: current
tags: [spec-format-terse, hash-literal, colon-association, blind-call, perl, rust, corpus, docs, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.9.1 classified the overloaded `=>` surface before implementation. Direct ActionIR hash-literal association candidates are in current docs/root guides, mdBook DSL/helper/formal-grammar pages, current Knowledge facts, Perl ActionIR AST parser tests, oracle generator fixture strings, generated Rust oracle corpus inputs, and selected shipped-spec surfaces including `specs/user_function_definition.spec` plus legacy/raw Perl-ish `tablegrep` and `tkgui` forms. Blind-call edge `=>` remains distinct syntax in `specs/spec.spec`, generated corpus copies, and formal grammar docs and must stay valid. VHDL/source-language association syntax in `specs/vhdl.spec` and related corpus fixtures is not ActionIR hash-literal syntax and must not be migrated as part of .9. Perl parser ownership is `perl/LinkedSpec/ActionIR/AST/Parser.pm` (`_parse_hash_literal_expr`, `_find_top_level_fat_arrow`, top-level token detection). Rust parser/runtime ownership is `rust/linkedspec-core/src/expr.rs::parse_hash_literal` plus `HashLiteral` evaluation in `rust/linkedspec-runtime/src/engine.rs`. The split sequence is .9.2 Perl colon support, .9.3 Rust parity, .9.4 current source/docs/KM/corpus migration, .9.5 hard retirement of old hash-literal `=>`, and .9.6 final no-drift closeout."
reverify: "rg -n '\\{[^{}\\n]*=>[^{}\\n]*\\}' specs tests/corpus rust/linkedspec-runtime/tests/corpus tools/gen_oracle_corpus.pl t/actionir_ast_parser.t t/phase0_regression.t docs/linkedspec-book/src USER_GUIDE.md docs/knowledge --glob '!docs/linkedspec-book/book/**'; rg -n '^\\s*=>\\s*[A-Za-z_]\\w*|association_element|/=>\\[|=> Rule' specs rust/linkedspec-runtime/tests/corpus docs/linkedspec-book/src; rg -n 'parse_hash_literal|_find_top_level_fat_arrow|expected.*=>|HashLiteral' perl/LinkedSpec/ActionIR/AST/Parser.pm rust/linkedspec-core/src/expr.rs rust/linkedspec-runtime/src/engine.rs"
---

# Hash-Literal Colon Migration Split

`SPEC-FORMAT-TERSE.9.1` split the `{ key => value }` to `{ key : value }`
migration before parser/runtime changes.

The migration target is only direct ActionIR hash-literal association syntax. Do
not sweep these owners:

- blind-call edge syntax such as `=> Rule`;
- source-language grammar payloads such as VHDL associations;
- historical task/changelog/Knowledge evidence;
- tests that intentionally lock the retired spelling after hard retirement.

Implementation order is:

1. Perl reference colon hash-literal support (`.9.2`);
2. Rust parser/runtime parity (`.9.3`);
3. source/docs/KM/corpus migration (`.9.4`);
4. old hash-literal `=>` hard retirement (`.9.5`);
5. final no-drift closeout (`.9.6`).
