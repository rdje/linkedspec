---
id: terse-retired-scalar-assign-spec-surface
title: "SPEC-FORMAT-TERSE.6.2.3.2 — authored spec files retired `scalar(...)` scalar-slot reads and `assign(...)` assignment aliases; use `:name`, `LHS = RHS` / `set(...)`, and remembered bare identifier kind instead. Backend Perl built-ins such as `scalar(@array)` are implementation details, not DSL surface."
answers:
  - "is scalar(...) still supported in authored spec files"
  - "is assign(...) still supported in authored spec files"
  - "what replaced scalar(name) in the terse spec DSL"
  - "what replaced assign(lhs, rhs) in the terse spec DSL"
  - "why can generated Perl still contain scalar(@...) after scalar(...) retirement"
  - "how does LinkedSpec remember whether a bare identifier is scalar array or hash"
  - "after items = [value] what does return(items) read"
  - "after meta = { key => value } what does copy(meta) read"
  - "what is the current spec-file scalar slot spelling"
date: 2026-07-04
status: confirmed
tags: [dsl, terse, scalar-slot, assignment, retirement, type-inference, bare-identifiers, spec-format-terse, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.6.2.3.2 retired the authored/current .spec DSL forms. Perl lowering now distinguishes parser-normalized internal `set(...)` from raw authored `assign(...)`, rejects raw `assign(...)`, lowers `:name` as the scalar slot, and collects/uses bare kind memory from direct assignments, parser-normalized assignments, and aggregate mutation/copy positions. Rust stores `RuntimeVarKind` beside runtime variables and evaluates `Expr::Variable` through the remembered kind, while `Expr::ScalarSlot` remains the explicit `:name` scalar path. Active authored spec/corpus scan `rg -n '\\bscalar\\s*\\(|\\bassign\\s*\\(' specs tests/corpus rust/linkedspec-runtime/tests/corpus --glob '*.spec' --glob '*.md'` returned no hits; mdBook scan over `docs/linkedspec-book/src` returned no hits. Verification included `prove -q -Iperl t/phase0_regression.t` PASS (1020 tests), `prove -q -Iperl t/actionir_ast_parser.t` PASS, `cargo fmt --manifest-path rust/Cargo.toml --all --check` PASS, and focused Rust tests for scalar-slot shorthand plus remembered bare identifier kind."
reverify: "rg -n '\\bscalar\\s*\\(|\\bassign\\s*\\(' specs tests/corpus rust/linkedspec-runtime/tests/corpus --glob '*.spec' --glob '*.md' ; rg -n '\\bscalar\\s*\\(|\\bassign\\s*\\(' docs/linkedspec-book/src ; prove -q -Iperl t/phase0_regression.t ; prove -q -Iperl t/actionir_ast_parser.t ; cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_6_2_3_2_bare_identifier_remembers_type_after_initialization"
---

# Retired spec-file scalar/assignment helpers

The current authored `.spec` surface no longer treats `scalar(...)` as the scalar-slot wrapper and no longer treats
`assign(...)` as an assignment alias. The replacement forms are:

- scalar slot read/target: `:name`
- assignment statement/expression: `name = value` or `set(name, value)`
- aggregate initialization: `items = [value]`, `meta = { key => value }`

After initialization, a bare identifier carries its known kind. `items = [value]` makes later `items` and
`copy(items)` array-valued; `meta = { key => value }` makes later `meta` and `copy(meta)` hash-valued; ordinary
non-shape assignment keeps scalar kind.

The boundary is the DSL surface. Generated backend Perl may still contain Perl built-ins such as `scalar(@items)`;
that does not mean the authored `.spec` helper spelling is supported again.
