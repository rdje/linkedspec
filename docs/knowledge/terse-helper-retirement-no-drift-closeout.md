---
id: terse-helper-retirement-no-drift-closeout
title: "SPEC-FORMAT-TERSE.8.6 closed the helper-retirement no-drift audit."
answers:
  - "did SPEC-FORMAT-TERSE.8 helper retirement leave stale helper calls in current specs"
  - "are retired helper names still current LinkedSpec authoring syntax after .8.6"
  - "where are remaining declare assign concat array_copy hash_copy push_value push_nonempty references allowed"
  - "what did the final helper retirement no drift scan classify"
date: 2026-07-07
status: current
tags: [spec-format-terse, helper-retirement, no-drift, docs, corpus, perl, rust, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.8.6 ran final no-drift scans after Perl .8.3, Rust .8.4, and public doc/KM cleanup .8.5. Current shipped specs and checked-in oracle/corpus specs have no calls to retired helper spellings `declare(...)`, `assign(...)`, `array_copy(...)`, `hash_copy(...)`, `concat(...)`, `push_value(...)`, or `push_nonempty(...)`, and no current `scalar(...)` scalar-slot wrapper calls. Short-wrapper alias scan over those executable surfaces only hit literal input text `(a(b)c)`, not helper calls. Colon-prefixed scalar-slot scan only hit comments, Perl namespace examples, regex syntax, and string literals. Remaining old helper names are allowed only in retirement diagnostics, regression tests that assert retired calls fail, historical/migration notes, Knowledge fact cards, and explicit mdBook/reference retired-helper sections. The audit corrected one stale root-guide sentence so `USER_GUIDE.md` now teaches current `cat(...)` syntax and identifies source-spelled `concat(...)` as retired. NONCURRENT-HELPER-CODE-PURGE.4 later removed active fixture/tool/spec label collisions too: no exact retired helper call shapes, no retired label/tag collisions, and no exact `?concat:` remain in active test/tool/spec/corpus/book surfaces."
reverify: "rg -n '\\b(?:declare|assign|array_copy|hash_copy|concat|push_value|push_nonempty)\\s*\\(' specs tests/corpus rust/linkedspec-runtime/tests/corpus || true; rg -n '\\bscalar\\s*\\(' specs tests/corpus rust/linkedspec-runtime/tests/corpus || true; rg -n '(^|[^A-Za-z0-9_])(?:s|a|h)\\s*\\(' specs tests/corpus rust/linkedspec-runtime/tests/corpus || true; rg --pcre2 -n '(?<!\\?):[A-Za-z_][A-Za-z0-9_]*' specs tests/corpus rust/linkedspec-runtime/tests/corpus || true; rg -n 'Pure scalar assembly|source-spelled `concat|concat\\(\\.\\.\\.\\).*now|concat\\(\\.\\.\\.\\).*lets' USER_GUIDE.md docs/linkedspec-book/src"
---

# Terse Helper Retirement No-Drift Closeout

`SPEC-FORMAT-TERSE.8.6` closed the helper-retirement audit after the Perl and Rust behavior
changes plus public documentation cleanup. The executable spec/corpus surfaces no longer use
the retired helper spellings as current syntax.

Remaining occurrences are intentional:

- implementation diagnostics and Rust/Perl regression tests that prove retired calls fail;
- historical migration notes and Knowledge Map cards;
- mdBook/reference sections that explicitly describe retired syntax and current replacements;
- non-helper false positives such as regex colons, Perl namespace examples, comments, and literal input text.

The current authoring replacements remain auto-existing working variables, `name = value`,
`set(...)`, `push(...)`, `cat(...)`, `copy(...)`, `array(...)`, `hash(...)`, and bare scalar
reads in accepted value positions.

The later `NONCURRENT-HELPER-CODE-PURGE.4` pass also renamed active labels/tags that collided
with retired helper names: EBNF return annotations now use `return_scalar_value` /
`return_array_value`, and portmap concatenation nodes now use `?concatenation:`.
