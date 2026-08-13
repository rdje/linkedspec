---
id: perl-inter-match-gap-authored-metadata
title: Perl admits named regex-slot authored identity and dormant capture-gaps metadata
answers:
  - "how does Perl declare a named regex slot"
  - "does Perl support Rule name selectors"
  - "what fields are in resolved_slot_edges"
  - "does Perl capture inter match gaps yet"
  - "where does Perl get Unicode slot name membership"
  - "are digit only slot names valid"
  - "does capture_gaps execute in Perl"
  - "how does generated Perl preserve selector provenance"
date: 2026-08-13
status: confirmed; authored and static staging complete, live gap runtime pending
tags: [perl, capture, named-slots, unicode, descriptor, generated-source, diagnostics, dormant]
evidence: "INTER-MATCH-GAP-CAPTURE.2.1 from clean 8f826923 permanently adds named declarations, named selectors, and capture_gaps parsing to specs/spec.spec and the reference bridge. Its 108-assertion dormant Perl consumer proves metadata and ordinary named selection while live and generated gap modes remain deliberately unavailable. The neutral rollout remains 1 complete + 8 pending with 55 mutations, plus 10 independent Perl dormancy mutations."
reverify: "prove -Iperl t/inter_match_gap_capture_perl_contract.t && bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py && bash tools/run_python_project_data.sh tools/check_unicode_rule_label_contract.py"
---

# Perl authored inter-match-gap metadata

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

An eligible `@capture_gaps` directive currently produces authored/static descriptor metadata only. There is no
gap invocation state, lifecycle integration, transaction checkpoint, accessor lowering, tail delivery, or
generated/loaded gap execution. `entry_slot()` and all `gap_*` accessors therefore remain unsupported. The final
consumer stays outside canonical and recurring runtime routes until the later Perl leaves implement and admit
those behaviors.

Signoff preserves the private/static boundary: eight focused Perl files pass 599 assertions, the Unicode generator
locks all 806 ranges, and five-backend self-host passes 5x2. The canonical gate passes all eight doctrines,
repository containment and relocation, CLI 66/66 in both option environments, RAM 65%, Phase 0 1,031/1,031 in
755 seconds, and the opt-in neutral-plus-six-pending gap route through local-CI exit 0.
