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
  - "why does an ordinary Perl dynamic string hash read yield null"
date: "2026-10-23"
status: confirmed
tags: [dsl, nested-access, variables, type-inference, channel-2, spec-format-terse, SPEC-FORMAT-TERSE, actionir, perl]
evidence: "Historical bare-index/auto-declaration proof and later guarded reads remain unchanged; full original header/recipes: git show 92c98fb3de0f8392abde59043bd6f67ba0199452:docs/knowledge/terse-direct-access-bare-path-atoms.md. Signed intake17.0 retains the quoted-key/bare-index control and exact emitted ARRAY guard; the first provisional comparison target was wrong."
reverify: "Dated source-bound intake: bash tools/run_python_project_data.sh docs/checkpoints/signed-array-selectors/review.py. No current signed-policy admission."
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

## October23 control qualification

For `tree={"-1":"key"}; chosen_index="-1"; return(tree[chosen_index])`, current ordinary Perl selects the authored scalar-array-index branch and returns null for the harray receiver. The quoted literal twin returns `key`. Intake17.0 preserves the first wrong comparison target and every actual row; it changes no read policy.
