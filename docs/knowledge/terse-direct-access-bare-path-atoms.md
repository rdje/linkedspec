---
id: terse-direct-access-bare-path-atoms
title: "SPEC-FORMAT-TERSE.1.2.3.3.3 — Perl direct-access bare path atoms are scalar array indexes."
answers:
  - "does foo[\"a\"][z] lower as scalar-index on Perl"
  - "how do bare path atoms work in direct nested access"
  - "are bare direct-access path atoms hash keys or array indexes"
  - "does direct-access bare path atom auto-declare my"
  - "what is the next leaf after SPEC-FORMAT-TERSE.1.2.3.3.3"
  - "does Rust accept direct-access bare path atoms after SPEC-FORMAT-TERSE.1.2.3.4"
date: 2026-09-24
status: confirmed
tags: [dsl, nested-access, variables, type-inference, channel-2, spec-format-terse, SPEC-FORMAT-TERSE, actionir, perl]
evidence: "Historical lowering text, superseded by guarded Perl reads in SESSION-STARTUP-READING.89. SPEC-FORMAT-TERSE.1.2.3.3.3 landed on 2026-06-29. Perl `LinkedSpec::call_spec_handler_subst(\"Top\", q{return(foo[\"a\"][z])})` now returns `return $foo->{\"a\"}->[$z]`, identical to `return(foo[\"a\"][scalar(z)])`. The same direct-access value lowering composes through `set(out, foo[\"a\"][z])`, `items += foo[\"a\"][z]`, and `meta[key] = foo[\"a\"][z]`. `_collect_auto_working_var_decls` records accepted bare path atoms through `_lower_direct_nested_access_value_expr` as the acceptance oracle, so generated handlers supply exactly one `my $z` / `my $idx` / `my $pos` and skip reserved atoms such as `true` and `CAPTURE`. SPEC-FORMAT-TERSE.1.2.3.4 later landed Rust parser parity for bare direct-access path atoms using the existing `Expr::Variable` scalar read path. SCALAREF-RETIREMENT.4 later removed the old legacy helper comparison surface. Phase0 passed with 987 tests at the original leaf."
reverify: "env PERL5LIB= bash tools/project_data_run.sh prove -v -Iperl t/generated_source_contract.t t/trace_actionir_compact_lowerers.t t/phase0_regression.t"
---

# Direct-Access Bare Path Atoms

Perl direct nested access accepts non-reserved bare path atoms:

```text
foo["a"][z]
```

The bare atom is a scalar array index. The historical equivalent below used the now-retired scalar wrapper:

```text
foo["a"][scalar(z)]
```

Segment semantics are now:

- quoted string segments are hash keys;
- numeric and helper/value-expression segments are array indexes;
- non-reserved bare path atoms are scalar array indexes;
- primitive literals and engine locals are not claimed as path variables.

This is direct-access-only. The former `scalaref(base, path)` comparison surface was
retired later under `SCALAREF-RETIREMENT.4`; direct nested access is now the supported
spelling for these payload reads.

`SPEC-FORMAT-TERSE.1.2.3.3` is closed on the Perl reference, and Rust parity landed under
`SPEC-FORMAT-TERSE.1.2.3.4`. The historical next frontier was `SPEC-FORMAT-TERSE.1.2.3.5`, later superseded by typed value binding.

## Current Perl lowering

Startup `.89` replaces the historical raw dereference strings with guarded,
non-creating reads and retains each receiver through selector evaluation. Segment
classification and auto-declaration remain unchanged. The historical `scalar(z)`
wrapper is retired; current source uses bare `z`. See
[[perl-direct-read-autovivification-gap]] and [[perl-direct-read-selector-lifetime]].
