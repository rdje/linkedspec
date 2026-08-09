---
id: exhaustive-current-actionir-capability-proof
title: Exhaustive current ActionIR proof is 246 bidirectionally checked names, 105 corpus fixtures, and one exact named-mark fixture
answers:
  - "what is the final current ActionIR call count"
  - "how many neutral interpreter fixtures are current"
  - "does every backend pass the complete current mdBook language surface"
  - "how does the coverage checker prevent identical backend inventory omissions"
  - "which leaf admitted the six governed capability fixtures"
date: 2026-08-09
status: current at 246 names / 105 corpus fixtures + 1 exact named-mark fixture / 122 public Perl contracts
tags: [actionir, capability, corpus, perl, rust, dart, julia, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.1.2.2.5 established the original 239-name proof. Subsequent admitted helper work advances the live tools/check_language_capability_coverage.pl result to 246 current names, 105 neutral corpus fixtures plus one exact named-mark fixture, and 122 independently covered public Perl contracts. Perl, Rust, Dart, Julia, and both Lua ABIs consume the governed current surface; FUTURE-PARITY-BACKLOG.14.3.0 uses this count to prove semantic introspection's three illustrative helper effects are not a closed recognition-only effect classification."
reverify: "perl tools/check_language_capability_coverage.pl --report && perl tools/check_capability_conformance.pl && jq '.case_count' rust/linkedspec-runtime/tests/corpus/manifest.json"
---

# Exhaustive Current ActionIR Capability Proof

The admitted current surface contains 246 ActionIR call names, 105 neutral corpus fixtures, one exact named-mark
fixture, and 122 independently covered public Perl contracts. Coverage is bidirectional: inventory names must be
documented and used by governed source, while every neutral call that is a current Perl contract must occur in the
aligned backend inventories. That second direction prevents backend-derived inventories from agreeing on the same
omission.

Name coverage remains a structural prerequisite, not a semantic substitute. Perl generates the frozen expected
values, and Rust, Dart, Julia, PUC Lua, and LuaJIT execute the governed corpus. In particular, 246-name coverage
cannot authorize a recognition-only transaction: `.14.3` must classify every ActionIR contract/effect transitively
and fail closed on unknown or dynamic effects.

## Links

- Owner: [[FUTURE-PARITY-BACKLOG]] `.1.6.1.2.2.5`.
- Oracle mechanics: [[rust-perl-output-oracle]].
- Why inventory identity alone is insufficient: [[current-call-name-inventory-does-not-prove-runtime-semantics]].
