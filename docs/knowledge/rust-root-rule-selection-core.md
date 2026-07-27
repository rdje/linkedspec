---
id: rust-root-rule-selection-core
title: "Rust core and native execution resolve explicit selector, first authored marker, then first authored rule"
answers:
  - "how does Rust select the entry rule now"
  - "does Rust accept a spec with no double-colon rule"
  - "does Rust --top-rule override Rule::"
  - "which Rust code owns root rule precedence"
  - "what diagnostic does Rust return for an unknown top rule now"
  - "what diagnostic does Rust return for a zero-rule spec"
  - "does Rust root selection change descriptor is_top"
  - "why does the Rust parser accept blank source before validation"
  - "does root selection affect Rust strict unused rules"
  - "which Rust root-selection routes remain pending"
date: 2026-07-18
status: superseded by rust-root-rule-selection-routes
supersedes: rust-root-rule-selection-preflight
tags: [rust, root-rule, top-rule, markerless, validation, descriptor, diagnostics, strict-syntax, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.1.2.2.1 adds `CompiledSpec::resolve_entry_rule`, the single ordered resolver over source-ordered `CompiledRule` rows. Explicit selection wins, then the first authored `is_top`, then row zero; empty state returns `no_rules_defined`/`validate_spec`, and an unknown explicit label returns `entry_rule_not_found`/`select_entry_rule` before user code. Validation now accepts one-or-more-rule markerless sources. The parser deliberately returns an empty/comment-only AST so structural validation, not parsing, owns the portable zero-rule stage; non-rule garbage remains a parse error. Native legacy/default and value/explicit execution use the resolver and effective-entry accumulator semantics. Descriptor metadata publishes `entry_rule_contract = linkedspec-root-rule-selection-v1` while definition order and every authored `is_top` bit remain immutable. Strict-unused stays authored-edge-only. `rust-root-rule-selection-routes` supersedes the former pending-route statement after `.2.2`; rollout admission remains `.2.3`."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test root_rule_selection_core --test runtime_diagnostics && bash tools/run_python_project_data.sh tools/check_root_rule_selection_contract.py"
---

# Rust core root-rule selection

Rust now has one compiled-state resolver for the effective entry rule. It borrows ordered `CompiledRule` state and
applies the neutral precedence without reparsing source or mutating `is_top`: explicit exact label, first authored
marker, then first declared rule. Native legacy/default and value/explicit entrypoints consume that resolver. The
primary command reaches the value path, so its markerless and explicit behavior is also aligned.

Rule-count validation is structurally separate from selection. Blank or comment-only source parses to an empty
AST so validation can return the portable `no_rules_defined` code at `validate_spec`; stray non-rule content still
fails parsing. Unknown explicit identity returns `entry_rule_not_found` at `select_entry_rule` before any rule or
user action runs. This also means a markerless single-rule source is no longer a valid negative validation fixture;
use another structural error such as a duplicate label when testing the validation projection.

The outward descriptor publishes the root contract id, definition order, and immutable boolean `is_top` for each
rule. Effective selection is per-execution state and adds no strict-unused reference or exemption. The subsequent
route slice aligned loaded, serialized/reconstructed, generated-plan, and emitted-module execution; follow
[[rust-root-rule-selection-routes]] for the current composed-route contract. `.2.3` alone may topology-check
admission and promote the Rust rollout row.

Related: [[root-rule-selection-precedence]], [[rust-root-rule-selection-preflight]],
[[rust-native-direct-value-execution]], and [[rust-outward-compiled-descriptor-projection]].
