---
id: exhaustive-current-actionir-capability-proof
title: Exhaustive current ActionIR proof is 239 bidirectionally checked names and 105 exact cross-backend fixtures
answers:
  - "what is the final current ActionIR call count"
  - "how many neutral interpreter fixtures are current"
  - "does every backend pass the complete current mdBook language surface"
  - "how does the coverage checker prevent identical backend inventory omissions"
  - "which leaf admitted the six governed capability fixtures"
date: 2026-07-10
status: confirmed
tags: [actionir, capability, corpus, perl, rust, dart, julia, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.1.2.2.5. tools/check_language_capability_coverage.pl reports 239 current call names documented and present in 105 neutral fixtures, with zero book omissions, zero corpus omissions, and zero neutral Perl contract calls missing from Dart/Julia inventories. Perl regeneration and the full Rust, Dart, and Julia gates pass the same 105 exact outputs; capability_conformance/manifest.json marks language.current_mdbook_surface pass on all four backends."
reverify: "perl tools/check_language_capability_coverage.pl --report && perl tools/check_capability_conformance.pl && jq '.case_count' rust/linkedspec-runtime/tests/corpus/manifest.json"
---

# Exhaustive Current ActionIR Capability Proof

The admitted current surface contains 239 ActionIR call names and 105 neutral exact-output fixtures. Coverage is
bidirectional: inventory names must be documented and used by neutral source, while every neutral call that is a
current Perl contract must occur in the aligned Dart and Julia inventories. That second direction prevents two
backend-derived inventories from agreeing on the same omission.

Name coverage remains a structural prerequisite, not a semantic substitute. Perl generates the frozen expected
values, and Rust, Dart, and Julia execute those same 105 fixtures. The capability census therefore records the
complete current mdBook language surface as `pass` for all four variants.

## Links

- Owner: [[FUTURE-PARITY-BACKLOG]] `.1.6.1.2.2.5`.
- Oracle mechanics: [[rust-perl-output-oracle]].
- Why inventory identity alone is insufficient: [[current-call-name-inventory-does-not-prove-runtime-semantics]].
