---
id: current-call-name-inventory-does-not-prove-runtime-semantics
title: "Current ActionIR call-name identity does not prove executable semantic parity"
answers:
  - "does identical ActionIR call inventory prove backend feature parity"
  - "why did the 237 name coverage checker pass while Rust Dart and Julia failed fixtures"
  - "what did the 105 case capability diagnostic expose"
  - "why does language.current_mdbook_surface remain partial"
date: 2026-07-10
status: confirmed-gap
tags: [actionir, capability, corpus, rust, dart, julia, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.1.2.2.0 diagnostic run. The strict source checker reaches 237/237 after six governed fixtures are provisionally materialized, and Perl generates all 105 oracle values. Rust, Dart, and Julia each pass the original 99 fixtures plus cursor control but fail pure, position, marker-control, anonymous-capture, and named-capture families (100/105). Common pure mismatches include host booleans versus Perl numeric 1/0, non-splicing direct-literal flat, and non-mutating statement uppercase_each. Position, marker control, and missing capture/mark subsets differ by backend. Name recognition therefore proves only parser/contract-table breadth, not runtime semantics. The mandatory manifest remains at its green 99-case boundary until children of .1.6.1.2.2 repair all failures."
evidence_update_2026_07_10: "FUTURE-PARITY-BACKLOG.1.6.1.2.2.1.1 through `.1.3` repair the Rust, Dart, and Julia pure fixtures: numeric predicate results, direct-literal flat splicing, and explicit working-array statement transforms now match Perl. Position `.2.1` through `.3` then align exact absent-local-match null/empty/default values, numeric named presence, and real zero-width-at-zero no-regression locks on all three backends. Rust passes 137 library tests, 193 integration tests, and unchanged 99-case oracle; Dart passes 154 package tests, 61 shared CLI cases in both environments, and unchanged 99-case corpus; Julia passes 1,022 assertions, 61 shared CLI cases in both environments, and unchanged 99-case corpus. Rust marker-control `.3.1` is next; the overall card remains a confirmed gap until every mechanism/backend and final 105-case admission close."
reverify: "perl tools/check_language_capability_coverage.pl --report && perl -c tools/gen_oracle_corpus.pl"
---

# Call-Name Coverage Is Not Executable Parity

An identical current call-name set is necessary: it catches missing or extra public vocabulary and ensures every
name appears in the mdBook and neutral source. It is not sufficient. A backend can recognize a name yet return the
wrong value kind, apply the wrong mutation/flattening behavior, select the wrong control branch, synthesize a
different empty match, or fail to implement the runtime operation.

The final proof must therefore compose two gates:

1. strict 237-name documentation/source coverage; and
2. unchanged execution of every admitted exact-value fixture on every backend.

The diagnostic 105-case manifest was deliberately not retained as the mandatory boundary because that would make
the repository knowingly red. Its six governed sources remain under `capability_conformance/fixtures/`, and the
generator supports safe repo-relative `source_file` loading for final admission after the repair children close.

## Links

- Owner: [[FUTURE-PARITY-BACKLOG]] `.1.6.1.2.2.1` through `.1.6.1.2.2.5`.
- Census: [[backend-capability-census-2026-07-10]].
- Neutral oracle: [[rust-perl-output-oracle]].
