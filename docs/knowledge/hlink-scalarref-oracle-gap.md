---
id: hlink-scalarref-oracle-gap
title: hlink_substitution bracket outputs contain Perl scalar references, so bracket/mixed fixtures need an oracle representation decision before JSON corpus inclusion
answers:
  - "why can't hlink_substitution bracket fixtures be added directly to the JSON oracle"
  - "which hlink_substitution delimiter fixture is JSON safe"
  - "what blocks hlink_substitution [abc] oracle fixture"
  - "what blocks hlink_substitution mixed bracket brace oracle fixture"
  - "which leaf owns hlink scalar ref oracle representation"
date: 2026-07-03
status: confirmed
tags: [rust, oracle, corpus, hlink-substitution, RUST-PARITY]
evidence: "RUST-PARITY.7.3.3.1 read specs/hlink_substitution.spec, existing hlink corpus fixtures, and phase0 hlink_substitution_parser_smoke. Perl returns [\\'abc'] for [abc] and a mixed array containing a scalar ref for foo[bar]{baz}; JSON::PP refuses scalar refs with 'cannot encode reference to scalar'. The {abc} case returns a plain string payload ['{abc}'] and is JSON-safe."
reverify: "perl -Iperl -MJSON::PP -e 'use LinkedSpec; my $p=LinkedSpec::get_parser(\"hlink_substitution\"); my $copy=\"[abc]\"; my $v=$p->(\\$copy); print ref($v->[0]),\"\\n\"; eval { print JSON::PP->new->encode($v) }; print $@ if $@'"
---

# hlink_substitution Scalar-Reference Oracle Gap

**Confirmed 2026-07-03 (`RUST-PARITY.7.3.3.1`).** The remaining
`hlink_substitution` delimiter candidates do not all have the same oracle shape.

- `{abc}` returns a plain string payload and can be represented directly in
  `expected.json`.
- `[abc]` returns a Perl scalar reference (`[\'abc']`) in the reference AST.
- `foo[bar]{baz}` returns a mixed array containing that scalar-reference bracket
  payload.

`JSON::PP` refuses to encode scalar references, so bracket and mixed
`hlink_substitution` fixtures need an explicit cross-variant representation
decision before they enter the language-neutral JSON corpus. The owned leaves are:

- `RUST-PARITY.7.3.3.2`: add the JSON-safe curly-brace fixture.
- `RUST-PARITY.7.3.3.3`: decide or defer scalar-ref canonicalization for bracket
  and mixed fixtures.
