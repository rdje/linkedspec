---
id: phase0-all-target-actionir-ready-invariant
title: Every shipped .spec must compile ActionIR-ready (ratio == 1.0000, zero compatibility-surface rules)
answers:
  - "what must every shipped .spec satisfy"
  - "what does the phase0 regression gate enforce about specs"
  - "what is language_agnostic_ready_ratio and what value is required"
  - "can a spec introduce a compatibility-surface rule"
  - "why did phase0 fail on my new spec"
date: 2026-06-05
status: current
tags: [parser, invariant, phase0, actionir]
evidence: "docs/decisions/0002-all-target-actionir-ready-invariant.md; t/phase0_regression.t asserts language_agnostic_ready_ratio == 1.0000 with zero blocked / compatibility-surface rules"
reverify: "grep -n language_agnostic_ready_ratio t/phase0_regression.t"
---

A phase-0 guard (since 2026-05-11) requires every discovered target `.spec` to compile to
descriptor metadata with `language_agnostic_ready_ratio == 1.0000`, **zero** language-agnostic
blocked rules, and **zero** compatibility-surface rules. A spec that introduces raw-Perl /
compatibility-shaped action code fails the gate and must be migrated to canonical method-like
helpers before it can land.

This is the measurable expression of the raw-Perl-free authoring policy. Canonical homes:
`docs/decisions/0002-all-target-actionir-ready-invariant.md`,
`docs/decisions/0003-raw-perl-free-spec-authoring.md`, and `t/phase0_regression.t`.
Related: [[hosted-ci-disabled-run-local-gate]].
