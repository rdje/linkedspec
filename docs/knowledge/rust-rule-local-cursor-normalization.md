---
id: rust-rule-local-cursor-normalization
title: "Rust retains typed bare edges and separates authored family identity from staged cursor execution"
answers:
  - "does Rust parse bare rule edges"
  - "where does Rust normalize bare edge ownership"
  - "how does Rust classify compact pipe"
  - "where are Rust rule local cursor diagnostics represented"
  - "why does Rust have uses_legacy_and_interpretation"
  - "does Rust default bare edge execute yet"
  - "does Rust AND bare edge execute after normalization"
  - "which Rust leaf changes live cursor execution"
  - "how is Rust cursor execution frozen during normalization"
date: 2026-07-18
status: verified normalization; normal live policy migrated by FUTURE-PARITY-BACKLOG.9.1.4.3
tags: [rust, dsl, cursor, bare-edge, parser, compiler, validation, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "Rust core classifies compact `|` as authored OR and `&` as authored AND, retains complete-line/header-rest bare targets as `BareEdge`, validates all neutral edge diagnostics with stable code/stage/fields, and lowers family-derived ownership into typed acode/bcode tables. FUTURE-PARITY-BACKLOG.9.1.4.3 spends that normalized family in normal live/loaded/ordinary-reconstructed execution; .9.1.4.4 projects it through descriptor v1. Only generated-source v1 retains the bounded legacy artifact adapter for .5. Contract-driven core tests consume all 36 family and 18 edge cases plus six ownership sets; runtime execution tests consume all 36 family rows, eight parent/child mechanisms, and two structural replacements."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-core --test rule_local_cursor_normalization_test; cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test rule_local_cursor_normalization; python3 tools/check_rule_local_cursor_contract.py"
---

Rust syntax/representation normalization is current at four exact seams:

- `linkedspec-core/src/ast.rs` defines authored family identity. `RuleMode::is_and()`
  includes `&`, `AND`, `AND+`, and bounded AND, but not compact `|`.
- `linkedspec-core/src/parser.rs` retains a complete physical-line or header-rest
  bare plain/indexed/grouped/block/fluent member as `BodyElementKind::BareEdge`.
  Reserved lifecycle markers are recognized first, and a suffix after another
  same-line member does not become a bare edge.
- `linkedspec-core/src/validation.rs` resolves against the complete rule-label set,
  derives AND bare ownership as blind and OR/default ownership as action, rejects
  invalid shape/mixed ownership, and emits `PortableDiagnostic` code/stage/fields.
- `linkedspec-core/src/compiler.rs` lowers valid normalized bare ownership into
  `bcode_dispatch` for AND and `acode_dispatch` for OR/default. It no longer loses
  governed candidates through `Raw`.

Normalization `.9.1.4.2` deliberately stopped before cursor execution. Follow-up
`.9.1.4.3` now makes normal live, loaded, and ordinary reconstructed rules derive
policy from their exact authored family and makes blind orchestration follow that
family. Descriptor `.9.1.4.4` now projects the same normalized family/policy/edges.
Generated-source v1 alone retains the bounded `legacy_artifact_parse_mode()` adapter
until `.9.1.4.5`; the compatibility predicate is no longer a live or descriptor
authority.

`PortableDiagnostic` is a sorted, serializable Rust core record with stable `code`,
`stage`, human message, and contract-declared fields. The normalization suite checks
every governed diagnostic identity directly. Primary-command diagnostic projection
and retired global option bytes remain assigned to later Rust leaves.

Related: [[rule-local-cursor-and-bare-edge-contract]],
[[rule-local-cursor-neutral-contract]], [[rust-rule-local-cursor-execution]],
[[rust-local-verification-gate]], and
[[FUTURE-PARITY-BACKLOG]].
