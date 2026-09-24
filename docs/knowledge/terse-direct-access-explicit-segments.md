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
date: 2026-09-24
status: confirmed
tags: [dsl, nested-access, spec-format-terse, SPEC-FORMAT-TERSE, channel-2, actionir, rust, parser]
evidence: "Historical lowering text, superseded by guarded Perl reads in SESSION-STARTUP-READING.89. SPEC-FORMAT-TERSE.1.5.5.1 landed on 2026-06-29. Perl `LinkedSpec::call_spec_handler_subst(\"Top\", q{return(foo[\"a\"][9][\"b\"][scalar(z)])})` returns `return $foo->{\"a\"}->[9]->{\"b\"}->[$z]`; the single-quoted probe `return(foo['a'][0])` returns `return $foo->{'a'}->[0]`. SPEC-FORMAT-TERSE.1.2.3.3.3 later landed non-reserved bare path atoms, so `return(foo[\"a\"][9][\"b\"][z])` now lowers to `return $foo->{\"a\"}->[9]->{\"b\"}->[$z]`. A runtime probe with `set(foo, hash(\"a\", array(hash(\"b\", array(\"zero\",\"one\")))))`, `set(z,1)`, and direct access returns `\"one\"`. Rust added `AccessSegment::{Key,Index}` and `Expr::NestedAccess` for explicit paths under `.1.5.5.1`, and SPEC-FORMAT-TERSE.1.2.3.4 later accepted non-reserved bare path atoms through the existing `Expr::Variable` scalar read path. SCALAREF-RETIREMENT.4 later removed the legacy helper that direct access replaced."
reverify: "env PERL5LIB= bash tools/project_data_run.sh prove -v -Iperl t/generated_source_contract.t t/trace_actionir_compact_lowerers.t t/phase0_regression.t"
---

# Direct Nested Access, Explicit Segments

Direct nested access is implemented for explicit mixed hash/array paths:

```text
foo["a"][9]["b"][z]
```

Segment semantics are conservative and variant-neutral:

- quoted string segments, double- or single-quoted, are hash keys;
- numeric segments are array indexes;
- helper/value expressions in brackets are explicit array-index expressions;
- non-reserved bare path atoms such as `[z]` are scalar array-index reads.

The accepted direct form is the supported spelling for these scalar payload reads. The
former legacy `scalaref(base,path)` helper has since been retired under
`SCALAREF-RETIREMENT.4`.

The mixed path above is accepted on Perl and Rust. The historical `scalar(z)` probe in the evidence predates scalar-wrapper
retirement; current authoring uses bare `z`. The former next step `.1.2.3.5` was subsequently implemented
and superseded by typed value binding; [[terse-rhs-shape-type-inference-ground-truth]] preserves that chronology.

## Current Perl lowering

Startup `.89` replaces the historical raw dereference strings with guarded,
non-creating reads and retains each receiver through selector evaluation. Segment
classification and auto-declaration remain unchanged. The historical `scalar(z)`
wrapper is retired; current source uses bare `z`. See
[[perl-direct-read-autovivification-gap]] and [[perl-direct-read-selector-lifetime]].
