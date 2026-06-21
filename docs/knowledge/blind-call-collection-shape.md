---
id: blind-call-collection-shape
title: A blind-call / repeated-rule collection surfaces each child's own return value (e.g. [1,1]); the auto-tag ['?Rule:',[]] shape is retired
answers:
  - "what shape does a blind-call collection return in linkedspec"
  - "does => child wrap each child result in a tag like ['?Rule:',[]]"
  - "what is the AND / OR / AND+ blind-call output shape"
  - "why do phase0 tests expect [1,1] instead of [['?First:',[]],['?Second:',[]]]"
  - "what does a repeated AND group return"
date: 2026-06-21
status: current
tags: [dsl, blind-call, runtime, output-shape, cross-variant, regression]
evidence: "cluster-A repro: Choice::OR+/::AND/::|/AND+/AND{N,M} with children '/a/ -> First { return(1) }' return [1,1] / 1 / [[1,1],...]; t/phase0_regression.t subtests 144/149/152/153/156/163/166 re-blessed in PHASE0-BACKHALF-TRIAGE.2.1"
reverify: "perl -Iperl -MLinkedSpec -e 'my $s=qq{Choice::OR+\\n => First\\n => Second\\n\\nFirst:\\n /a/ -> First { return(1) }\\n\\nSecond:\\n /b/ -> Second { return(1) }\\n}; my $p=LinkedSpec::Get(\\$s); my $in=q{ab}; use Data::Dumper; print Dumper($p->(\\$in))'"
---

When a parent rule blind-calls children (`=> First`, `=> Second`), the parent's result is built
from **each child's own return value** — not from an auto-generated tag. For children that each
carry `… { return(1) }`:

- **Single dispatch** (`:|` single-choice) → the one child's return: scalar `1`.
- **Repeated choice / sequence collection** (`:OR`, `:OR+`, `:+`, `:AND`, `:OR{N,M}`) → a flat list
  of the children's returns: `[1, 1]` (one entry per successful child hit).
- **Repeated AND** (`:AND+`, `:AND{N,M}`) → a list of per-iteration groups, each group itself a
  list of that iteration's child returns: `[[1, 1], [1, 1], …]`.
- **Zero allowed iterations matched** (`:OR{,2}` on empty input) → `[]`; **below the minimum** → `undef`.

The historical **auto-tag accumulator shape `['?Rule:', []]`** (e.g.
`[['?First:',[]],['?Second:',[]]]`) is **retired** — the engine no longer wraps child results in a
`'?Label:'`-tagged pair. A batch of `t/phase0_regression.t` subtests (cluster A of the back-half
triage) still asserted the old tag and were re-blessed to the current shape in
`PHASE0-BACKHALF-TRIAGE.2.1` (TEST-ONLY; engine unchanged). Distinct from the AND *codegen* defect
(`return(...)` on a multi-indexed AND edge), which was a real engine bug — see
[[and-return-edge-codegen-defect]].

This shape is part of the cross-variant contract: the Rust/Julia/Dart variants must mirror it (the
Perl reference is the oracle). Related: [[blind-call-rule-label-contract]],
[[and-return-edge-codegen-defect]], [[phase0-regression-structure]].
