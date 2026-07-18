---
id: dart-root-rule-selection-core
title: "Dart core resolves explicit selector, first marker, then first rule from one compiled-state owner"
answers:
  - "how does Dart resolve the entry rule"
  - "does Dart accept a spec without Rule::"
  - "what is the Dart markerless default rule"
  - "does Dart --top-rule override Rule::"
  - "where is Dart root selection implemented"
  - "what diagnostic does Dart return for an unknown entry rule"
  - "what diagnostic does Dart return for a zero-rule spec"
  - "why must the Dart parser preserve an empty or comment-only spec"
  - "does Dart parsing or validation own no_rules_defined"
  - "does Dart root selection rewrite descriptor is_top"
  - "does Dart strict unused count the selected entry rule"
  - "is Dart root selection admitted"
date: 2026-07-18
status: core/native/primary implemented; composed routes and admission pending
tags: [dart, root-rule, top-rule, markerless, parser, validation, diagnostics, descriptor, strict-syntax, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.1.2.3.1 adds `CompiledSpec.resolveEntryRule`, the single ordered resolver over `compiledRuleOrder`: explicit exact selector, then first authored `header.isTop`, then row zero. Empty compiled state returns `no_rules_defined` / `validate_spec`; unknown explicit selection returns `entry_rule_not_found` / `select_entry_rule` with requested `entry_rule`, before runtime context or user code. Validation accepts one-or-more-rule markerless sources. Implementing portable zero-rule validation exposed that `parseSpec` rejected empty/comment-only sources before validation; it now preserves that empty `SpecFile` envelope while non-rule garbage remains a parse error. Descriptor root metadata publishes `linkedspec-root-rule-selection-v1`; definition order and per-rule authored `is_top` remain unchanged before/after selection. Neutral strict-unused rows remain authored-edge-only. Focused core/parser/validator/runtime/compiler/descriptor/primary proof passes 107 tests; full package passes 266, corpus 105, analyzer and format pass, and shared primary passes 65/65 with `POSIXLY_CORRECT` unset and set. Root governance remains 3 complete / 4 pending with 29 mutations because composed route proof `.3.2` and topology admission `.3.3` have not landed."
evidence_update_2026_07_18_signoff: "Complete Dart-local signoff passes format 58/0, analyzer, package 266/266, shared primary 65x2, and corpus 105/105. Canonical CI passes all four doctrines, root governance, Perl root 7+5, cursor 288, reference primary 65x2, and Phase 0 1,031/1,031. The mdBook passes and Knowledge Map closes at 605 facts / 4,348 question keys. Cleanup removes generated book/cache artifacts while retaining required Dart package state."
reverify: "cd dart && dart test test/root_rule_selection_core_test.dart test/spec_parser_test.dart test/spec_validator_test.dart test/runtime_interpreter_test.dart test/compiled_spec_test.dart test/rule_local_cursor_descriptor_test.dart test/primary_cli_test.dart && cd .. && python3 tools/check_root_rule_selection_contract.py && bash tools/run_dart_local.sh"
---

# Dart root-selection core

Dart validates structure before selecting an entry rule. A valid source must define one or more rules, but no
authored `::` marker is required. `CompiledSpec.resolveEntryRule(...)` is the single semantic owner: an explicit
exact label wins, otherwise the first authored marker wins, otherwise the first authored rule wins.

The empty-source envelope is intentional. `parseSpec('')` and comment-only input produce an empty `SpecFile` so
validation can return the portable `no_rules_defined` / `validate_spec` diagnostic. Text that is neither trivia
nor a rule still fails as a syntax error in the parser. This separates source-envelope recognition from structural
validity and prevents a backend-specific parser error from preempting the neutral diagnostic.

Selection is execution state, not source identity. The descriptor publishes the root-selection contract and
retains definition order plus every authored `is_top` bit; selecting an ordinary rule does not mark it. Strict
unused analysis continues to count only authored rule edges, so neither the selected rule nor a `::` marker gains
a reference or exemption.

This card covers core/native/primary behavior only. [[dart-root-rule-selection-preflight]] is the superseded
baseline. Loaded/normalized/generated/emitted/trace route composition remains `.3.2`, and topology/reference
admission remains `.3.3`; only admission may promote Dart in the 3/7 rollout.

Related: [[root-rule-selection-precedence]], [[rust-root-rule-selection-core]], and
[[top-rule-is-ordinary-rule-entered-first]].
