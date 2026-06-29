---
id: terse-direct-access-bare-path-atoms
title: "SPEC-FORMAT-TERSE.1.2.3.3.3 — Perl direct-access bare path atoms are scalar array indexes."
answers:
  - "does foo[\"a\"][z] lower as scalar-index on Perl"
  - "how do bare path atoms work in direct nested access"
  - "are bare direct-access path atoms hash keys or array indexes"
  - "does direct-access bare path atom auto-declare my"
  - "does scalaref(foo,{\"a\"}[z]) change after direct path atoms"
  - "what is the next leaf after SPEC-FORMAT-TERSE.1.2.3.3.3"
  - "does Rust accept direct-access bare path atoms after SPEC-FORMAT-TERSE.1.2.3.4"
date: 2026-06-29
status: confirmed
tags: [dsl, nested-access, variables, type-inference, channel-2, spec-format-terse, SPEC-FORMAT-TERSE, actionir, perl]
evidence: "SPEC-FORMAT-TERSE.1.2.3.3.3 landed on 2026-06-29. Perl `LinkedSpec::call_spec_handler_subst(\"Top\", q{return(foo[\"a\"][z])})` now returns `return $foo->{\"a\"}->[$z]`, identical to `return(foo[\"a\"][scalar(z)])`. The same direct-access value lowering composes through `set(out, foo[\"a\"][z])`, `items += foo[\"a\"][z]`, and `meta[key] = foo[\"a\"][z]`. `_collect_auto_working_var_decls` records accepted bare path atoms through `_lower_direct_nested_access_value_expr` as the acceptance oracle, so generated handlers supply exactly one `my $z` / `my $idx` / `my $pos` and skip reserved atoms such as `true` and `CAPTURE`. `return(scalaref(foo,{\"a\"}[z]))` deliberately remains `return $foo->{\"a\"}->[z]`; write `[scalar(z)]` inside `scalaref(...)` when the legacy path notation should read a working scalar index. SPEC-FORMAT-TERSE.1.2.3.4 later landed Rust parser parity for bare direct-access path atoms using the existing `Expr::Variable` scalar read path. Phase0 passed with 987 tests."
reverify: "perl -Iperl -MLinkedSpec -e 'my @stmts=(q{return(foo[\"a\"][z])}, q{return(foo[\"a\"][scalar(z)])}, q{set(out, foo[\"a\"][z])}, q{items += foo[\"a\"][z]}, q{meta[key] = foo[\"a\"][z]}, q{return(foo[\"a\"][true])}, q{return(scalaref(foo,{\"a\"}[z]))}, q{push(A,B)}); for my $stmt (@stmts) { my $out=LinkedSpec::call_spec_handler_subst(\"Top\",$stmt); $out =~ s/\\n/\\\\n/g; print \"$stmt => $out\\n\" }' && cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml parse_direct_nested_access_accepts_bare_segments"
---

# Direct-Access Bare Path Atoms

Perl direct nested access now accepts non-reserved bare path atoms:

```text
foo["a"][z]
```

The bare atom is a scalar array index, so the direct form is equivalent to:

```text
foo["a"][scalar(z)]
```

Segment semantics are now:

- quoted string segments are hash keys;
- numeric and helper/value-expression segments are array indexes;
- non-reserved bare path atoms are scalar array indexes;
- primitive literals and engine locals are not claimed as path variables.

This is direct-access-only. The legacy `scalaref(base, path)` helper keeps its historical path notation:

```text
scalaref(foo, {"a"}[z])
```

still emits `[z]` literally. Use `[scalar(z)]` in a `scalaref(...)` path when the index should read the scalar
working variable `z`.

`SPEC-FORMAT-TERSE.1.2.3.3` is closed on the Perl reference, and Rust parity landed under
`SPEC-FORMAT-TERSE.1.2.3.4`. The next frontier is `SPEC-FORMAT-TERSE.1.2.3.5`, RHS-shape/type-inference split
before code.
