---
id: current-call-name-inventory-does-not-prove-runtime-semantics
title: "Current ActionIR call-name identity does not prove executable semantic parity"
answers:
  - "does identical ActionIR call inventory prove backend feature parity"
  - "why did the 237 name coverage checker pass while Rust Dart and Julia failed fixtures"
  - "what did the 105 case capability diagnostic expose"
  - "why does language.current_mdbook_surface remain partial"
date: 2026-07-10
status: resolved
tags: [actionir, capability, corpus, rust, dart, julia, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.1.2.2.0 diagnostic run. The strict source checker reaches 237/237 after six governed fixtures are provisionally materialized, and Perl generates all 105 oracle values. Rust, Dart, and Julia each pass the original 99 fixtures plus cursor control but fail pure, position, marker-control, anonymous-capture, and named-capture families (100/105). Common pure mismatches include host booleans versus Perl numeric 1/0, non-splicing direct-literal flat, and non-mutating statement uppercase_each. Position, marker control, and missing capture/mark subsets differ by backend. Name recognition therefore proves only parser/contract-table breadth, not runtime semantics. The mandatory manifest remains at its green 99-case boundary until children of .1.6.1.2.2 repair all failures."
evidence_update_2026_07_10: "FUTURE-PARITY-BACKLOG.1.6.1.2.2.1.1 through `.1.3` repair pure fixtures; position `.2.1` through `.3` align absent-local-match values; marker-control `.3.1` through `.3` aligns short aliases and nesting-aware first-match/default chains on Rust, Dart, and Julia. Rust passes 137 library tests, 194 integration tests, and unchanged 99-case oracle; Dart passes 155 package tests, 61 shared CLI cases in both environments, and unchanged 99-case corpus; Julia passes 1,023 assertions, 61 shared CLI cases in both environments, and unchanged 99-case corpus. Rust capture/mark `.4.1` is next; the overall card remains a confirmed gap until every mechanism/backend and final 105-case admission close."
evidence_update_2026_07_10_capture: "Rust `.4.1`, Dart `.4.2`, and Julia `.4.3` now pass both exact capture/mark fixtures. Julia passes 1,028 assertions, primary CLI conformance, and 99 corpus. The capture audit also proves that matching Dart/Julia inventories are insufficient: current Perl contracts start_capture_slice_from and mark_capture_slice are used by governed sources but omitted by both provisional 237-name sets, so active final `.5` must reconcile the reference registry before strict admission."
evidence_update_2026_07_10_final: "FUTURE-PARITY-BACKLOG.1.6.1.2.2.5 reconciles the two omissions for a final 239-name inventory, adds the reverse neutral-Perl-contract-call-to-backend-inventory check, and admits all six governed families into the 105-case mandatory corpus. Perl regeneration, Rust, Dart, and Julia pass exact outputs; language.current_mdbook_surface is pass for all four backends."
reverify: "perl tools/check_language_capability_coverage.pl --report && perl -c tools/gen_oracle_corpus.pl"
---

# Call-Name Coverage Is Not Executable Parity

An identical current call-name set is necessary: it catches missing or extra public vocabulary and ensures every
name appears in the mdBook and neutral source. It is not sufficient. A backend can recognize a name yet return the
wrong value kind, apply the wrong mutation/flattening behavior, select the wrong control branch, synthesize a
different empty match, or fail to implement the runtime operation.

The final proof composes two gates:

1. strict bidirectional reconciled-name documentation/source coverage (239 current names); and
2. unchanged execution of every admitted exact-value fixture on every backend (105 cases).

The six diagnostic families stayed outside the mandatory manifest while repairs were in flight. Final admission
materialized them atomically after all four variants passed, preserving a green mandatory boundary throughout.

## Links

- Owner: [[FUTURE-PARITY-BACKLOG]] `.1.6.1.2.2.1` through `.1.6.1.2.2.5`.
- Census: [[backend-capability-census-2026-07-10]].
- Neutral oracle: [[rust-perl-output-oracle]].
