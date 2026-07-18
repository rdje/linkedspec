---
id: perl-root-rule-selection-core
title: "Perl core resolves explicit selector, first authored marker, then first authored rule without rewriting source identity"
answers:
  - "how does Perl select the entry rule now"
  - "does Perl accept a spec with no double-colon rule"
  - "does Perl --top-rule override Rule::"
  - "which Perl module owns root rule precedence"
  - "does an explicit top_rule change descriptor is_top"
  - "where does Perl report an unknown explicit entry rule"
  - "what code and stage identify a missing Perl top_rule"
  - "what does the Perl descriptor publish for root selection"
  - "does root selection affect Perl strict unused rules"
  - "which Perl root-selection routes are implemented"
date: 2026-07-18
status: confirmed composed Perl reference; library and primary admission complete
tags: [perl, root-rule, top-rule, markerless, descriptor, diagnostics, strict-syntax, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.1.2.1.1 adds `LinkedSpec::EntryRuleSelection::select_entry_rule`, an ordered resolver over source-ordered `{label,is_top}` rows. Explicit selection wins, then the first authored marker, then row zero; zero rows return `no_rules_defined`/`validate_spec`, and an unknown explicit label returns `entry_rule_not_found`/`select_entry_rule`. Perl envelope validation accepts one-or-more-rule markerless sources. RuleIR projects normalized authored `is_top`, CompilerState publishes `entry_rule_contract = linkedspec-root-rule-selection-v1`, and definition order remains exact. The returned native parser checks an unknown selector before handler lookup while preserving compile-before-input ordering. Direct strict validation remains authored-edge graph analysis and `Get(strict_syntax => 1)` remains unwired. `.9.1.1.2.1.2` composes the same resolver through loaded, generated direct/traced/Get, and effective runtime-trace routes. `.9.1.1.2.1.3` topology-locks those core and route consumers, admits exact first-marker and markerless-default primary bytes in the 65-case shared manifest, and advances only the Perl rollout row."
reverify: "PERL5LIB= prove -Iperl t/root_rule_selection_perl_core.t t/root_rule_selection_perl_routes.t && python3 tools/check_root_rule_selection_contract.py"
---

# Perl core root-rule selection

The Perl compiler converts ordered bootstrap rows into one small resolver input: each row has its declared label
and immutable authored marker bit. `LinkedSpec::EntryRuleSelection` selects an effective entry without reparsing
the source or changing the descriptor:

1. a declared explicit `top_rule` wins;
2. otherwise the first row whose source header used `::` wins;
3. otherwise the first declared row wins.

An explicit ordinary rule therefore remains `is_top = 0`, and every actual `Rule::` remains `is_top = 1`.
`meta.definition_order` preserves authored order and `meta.entry_rule_contract` identifies the selection contract.

Zero-rule input is an envelope error before selection. Unknown explicit identity is different: the source still
compiles, preserving compilation-before-input behavior, but the returned parser records
`entry_rule_not_found` at `select_entry_rule` and dies before handler lookup or user code. Runtime context retains
the requested label for attribution.

Selection does not participate in strict-unused analysis. Only authored rule edges are references. Loaded,
generated-direct, generated-traced, generated `Get`, effective runtime-trace, and primary-command projections
consume the same resolver. The composed Perl reference is admitted; Rust and later variants remain staged.

Related: [[root-rule-selection-precedence]], [[perl-root-rule-selection-preflight]],
[[perl-root-rule-selection-routes]], [[perl-root-rule-selection-admission]], and
[[top-rule-is-ordinary-rule-entered-first]].
