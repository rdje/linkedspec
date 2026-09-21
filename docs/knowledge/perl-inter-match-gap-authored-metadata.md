---
id: perl-inter-match-gap-authored-metadata
title: Perl admits named regex-slot identity and stages native-live capture-gaps behavior
answers:
  - "how does Perl declare a named regex slot"
  - "does Perl support Rule name selectors"
  - "what fields are in resolved_slot_edges"
  - "does Perl capture inter match gaps yet"
  - "where does Perl get Unicode slot name membership"
  - "are digit only slot names valid"
  - "does capture_gaps execute in Perl"
  - "how does generated Perl preserve selector provenance"
date: 2026-09-21
status: historical authored/native staging; current complete rollout owned by inter-match-gap-recurring-governance
tags: [perl, capture, named-slots, unicode, descriptor, generated-source, diagnostics, dormant]
evidence: "INTER-MATCH-GAP-CAPTURE.2.1 from clean 8f826923 permanently adds named declarations, named selectors, and capture_gaps parsing to specs/spec.spec and the reference bridge. Its 108-assertion dormant Perl consumer proves metadata and ordinary named selection while live and generated gap modes remain deliberately unavailable. The neutral rollout remains 1 complete + 8 pending with 55 mutations, plus 10 independent Perl dormancy mutations."
evidence_update_2026_08_13_live: "INTER-MATCH-GAP-CAPTURE.2.2 from clean 912fc5ed makes the private native live mode pass all nine lifecycle/accessor groups and advances recognition effects to 137/246/58. Default metadata mode now passes 110 assertions. The exact consumer remains absent from ordinary/canonical/recurring admission, independently loaded generated execution remains .2.3, and gap rollout remains 1 complete + 8 pending / 55 mutations plus the same 10 dormancy locks."
reverify: "prove -Iperl t/inter_match_gap_capture_perl_contract.t && bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py && bash tools/run_python_project_data.sh tools/check_unicode_rule_label_contract.py"
---

# Current boundary — September 21

CONFORMANCE-SOURCE-READING.1.35 confirms that the consumer defaults to all roles;
unchanged canonical proof at 87b35665e passes 124 top-level tests. The pending/dormant
statements below describe the August 13 staging checkpoint, not current availability.
[[inter-match-gap-perl-implementation-plan]] and [[inter-match-gap-recurring-governance]]
own subsequent generated, all-runtime and public admission. This reading closes no repair.

# Historical authored inter-match-gap metadata — August 13

The Perl reference accepts a same-line rule member `name=/regex/`, with optional horizontal whitespace on either
side of `=`. `Rule`, `Rule[N]`, and `Rule[name]` are the selector forms. Named and anonymous declarations share
one zero-based authored sequence, but only a named selector follows stable identity when declarations are
reordered. An unindexed selector is the legacy zero selection; a numeric selector remains positional.

Every slot-name scalar must belong to the repository-pinned Unicode 17.0.0 `XID_Continue` class. Identity is exact,
case-sensitive, and normalization-sensitive. ASCII digit-only strings are reserved for positional selectors.
`perl/LinkedSpec/UnicodeXIDContinue.pm` is generated from the pinned repository table, so host Perl Unicode data is
not semantic authority.

Perl RuleIR retains ordered `regex_slots` rows and separate `resolved_slot_edges` rows with exactly
`selector_kind`, `authored_selector`, `target_rule`, `regex_index`, and nullable `target_slot_id`. Dependency
references and generated `dependency_slot_map` rows preserve named provenance, including self-target expansion.
Legacy `resolved_edges` and anonymous dependency row shapes remain compatible.

An eligible `@capture_gaps` directive now activates private native-live invocation state on the existing
recognition guard. `entry_slot()` and the three `gap_*` accessors lower through dedicated source-read ActionIR
nodes; candidate, accepted-commit, terminal-tail, rollback, and recursive isolation behavior match the neutral
contract. Independently loaded generated execution remains `.2.3`. The final consumer stays outside ordinary,
canonical, and recurring runtime routes until `.2.4` admits the completed Perl path.

Focused `.2.2` proof preserves the private staging boundary: default metadata passes 110 assertions, native-live
mode passes all nine behavior groups, recognition is 137/246/58 with 122 public helpers, and gap/typed-source/
duplicate-slot cross-runtime matrices remain green at 1/8/55, 9/5/114, and 59 mutations respectively. Canonical
signoff and its exact rendered/Knowledge counts are recorded in the owning task rather than inherited from `.2.1`.
