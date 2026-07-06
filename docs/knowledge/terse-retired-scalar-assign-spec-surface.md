---
id: terse-retired-scalar-assign-spec-surface
title: "SPEC-FORMAT-TERSE.6.2.3.2 retired authored scalar(...) and assign(...); after SPEC-FORMAT-TERSE.15.3 current Perl authoring uses bare reads and LHS = RHS / set(...)."
answers:
  - "is scalar(...) still supported in authored spec files"
  - "is assign(...) still supported in authored spec files"
  - "what replaced scalar(name) in the terse spec DSL"
  - "what replaced assign(lhs, rhs) in the terse spec DSL"
  - "why can generated Perl still contain scalar(@...) after scalar(...) retirement"
  - "how does LinkedSpec remember whether a bare identifier is scalar array or hash"
  - "after items = [value] what does return(items) read"
  - "after meta = { key => value } what does copy(meta) read"
  - "what is the current spec-file scalar read spelling"
date: 2026-07-06
status: confirmed
tags: [dsl, terse, scalar-slot, assignment, retirement, type-inference, bare-identifiers, spec-format-terse, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.6.2.3.2 retired authored `scalar(...)` and `assign(...)`. At that time `:name` was the explicit scalar-slot path, but SPEC-FORMAT-TERSE.15.2.4 migrated current sources to bare reads, SPEC-FORMAT-TERSE.15.3 hard-retired Perl `:name` support, and SPEC-FORMAT-TERSE.15.4 hard-retired Rust `Expr::ScalarSlot`. Current authoring reads variables by bare name in value positions and uses `name = value` / `set(name, value)` for assignment; explicit `array(name)` / `hash(name)` targets mark aggregate-storage mutation boundaries."
reverify: "rg -n '\\bscalar\\s*\\(|\\bassign\\s*\\(' specs tests/corpus rust/linkedspec-runtime/tests/corpus --glob '*.spec' --glob '*.md' ; rg -n '\\bscalar\\s*\\(|\\bassign\\s*\\(' docs/linkedspec-book/src ; prove -q -Iperl t/phase0_regression.t ; prove -q -Iperl t/actionir_ast_parser.t ; cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_6_2_3_2_bare_identifier_remembers_type_after_initialization"
---

# Retired spec-file scalar/assignment helpers

The current authored `.spec` surface no longer treats `scalar(...)` as the scalar-slot wrapper and no longer treats
`assign(...)` as an assignment alias. After the `.15` migration, the replacement forms are:

- scalar read in value positions: `name`
- assignment statement/expression: `name = value` or `set(name, value)`
- aggregate initialization: `items = [value]`, `meta = { key => value }`
- explicit aggregate-storage mutation boundary: `array(items)` / `hash(meta)`

After initialization, a bare identifier carries its known kind. `items = [value]` makes later `items` and
`copy(items)` array-valued; `meta = { key => value }` makes later `meta` and `copy(meta)` hash-valued; ordinary
non-shape assignment keeps scalar kind.

The boundary is the DSL surface. Generated backend Perl may still contain Perl built-ins such as `scalar(@items)`;
that does not mean the authored `.spec` helper spelling is supported again.
