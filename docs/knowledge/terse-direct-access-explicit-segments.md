---
id: terse-direct-access-explicit-segments
title: "Direct nested access works for mixed hash/array path segments; non-reserved bare path atoms are scalar indexes after SPEC-FORMAT-TERSE.1.2.3.3.3."
answers:
  - "does foo[\"a\"][9][\"b\"][scalar(z)] work as direct nested access"
  - "what are the segment semantics for direct nested access"
  - "are quoted direct-access segments hash keys"
  - "does direct nested access replace scalaref"
  - "does foo[\"a\"][9][\"b\"][z] work as direct nested access"
  - "how does Rust represent direct nested access"
date: 2026-06-29
status: confirmed
tags: [dsl, nested-access, spec-format-terse, SPEC-FORMAT-TERSE, channel-2, actionir, rust, parser]
evidence: "SPEC-FORMAT-TERSE.1.5.5.1 landed on 2026-06-29. Perl `LinkedSpec::call_spec_handler_subst(\"Top\", q{return(foo[\"a\"][9][\"b\"][scalar(z)])})` returns `return $foo->{\"a\"}->[9]->{\"b\"}->[$z]`; the single-quoted probe `return(foo['a'][0])` returns `return $foo->{'a'}->[0]`. SPEC-FORMAT-TERSE.1.2.3.3.3 later landed non-reserved bare path atoms, so `return(foo[\"a\"][9][\"b\"][z])` now lowers to `return $foo->{\"a\"}->[9]->{\"b\"}->[$z]`. A runtime probe with `set(foo, hash(\"a\", array(hash(\"b\", array(\"zero\",\"one\")))))`, `set(z,1)`, and direct access returns `\"one\"`. Rust added `AccessSegment::{Key,Index}` and `Expr::NestedAccess` for explicit paths; Rust scalar parity for the later bare path atom rule is owned by `.1.2.3.4`."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $expr (q{return(foo[\"a\"][9][\"b\"][scalar(z)])}, q{return(foo['\"'\"'a'\"'\"'][0])}, q{return(foo[\"a\"][9][\"b\"][z])}) { my $out=LinkedSpec::call_spec_handler_subst(\"Top\",$expr); $out =~ s/\\n/\\\\n/g; print \"$expr => $out\\n\" }' && cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml parse_direct_nested_access && cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_1_5_5_1_direct_nested_access_explicit_segments_run"
---

# Direct Nested Access, Explicit Segments

Direct nested access is implemented for explicit mixed hash/array paths:

```text
foo["a"][9]["b"][scalar(z)]
```

Segment semantics are conservative and variant-neutral:

- quoted string segments, double- or single-quoted, are hash keys;
- numeric segments are array indexes;
- helper/value expressions in brackets are explicit array-index expressions;
- non-reserved bare path atoms such as `[z]` are scalar array-index reads.

The accepted direct form lowers/evaluates like the existing explicit `scalaref(...)` path. `scalaref(base,
path)` remains supported; direct access is not a helper retirement.

The full brainstorm spelling:

```text
foo["a"][9]["b"][z]
```

is now accepted on the Perl reference. Rust parity for the bare path-atom portion is tracked by
`SPEC-FORMAT-TERSE.1.2.3.4`.
