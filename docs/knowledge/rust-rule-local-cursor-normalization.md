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
date: 2026-07-17
status: verified for FUTURE-PARITY-BACKLOG.9.1.4.2; live policy migration remains .9.1.4.3
tags: [rust, dsl, cursor, bare-edge, parser, compiler, validation, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "Rust core now classifies compact `|` as authored OR and `&` as authored AND, retains complete-line/header-rest bare targets as `BareEdge`, validates all neutral edge diagnostics with stable code/stage/fields, and lowers family-derived ownership into typed acode/bcode tables. Transitional runtime/descriptor/emitter callers use `uses_legacy_and_interpretation()` so `.9.1.4.2` does not spend the future per-rule cursor policy assigned to `.9.1.4.3-.5`. Contract-driven core tests consume all 36 family and 18 edge cases plus six ownership sets; runtime tests lock the staged live boundary. Complete focused proof passes core 189/3/5/8, runtime 137 unit, 105 oracle, 105 generated, 197 integration, all adjacent suites, and reaches only the governed CLI 51/63 migration boundary. Neutral 36/18/8/14/72 at 2/6 plus 29 mutations and canonical local CI also pass."
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

This representation leaf deliberately does not complete the execution/artifact
rollout. Existing runtime, descriptor, and generated-source callers temporarily use
`RuleMode::uses_legacy_and_interpretation()`. That helper preserves compact-`|` and
blind-call cursor behavior until `.9.1.4.3-.5` replace each consumer. The compiler
unit test locks this boundary, while the runtime integration test proves the current
observable split: an AND bare child reaches the typed blind table; default/header-rest
action entry and compact-OR seeking remain at their staged pre-`.3` behavior.

`PortableDiagnostic` is a sorted, serializable Rust core record with stable `code`,
`stage`, human message, and contract-declared fields. The normalization suite checks
every governed diagnostic identity directly. Primary-command diagnostic projection
and retired global option bytes remain assigned to later Rust leaves.

Related: [[rule-local-cursor-and-bare-edge-contract]],
[[rule-local-cursor-neutral-contract]], [[rust-local-verification-gate]], and
[[FUTURE-PARITY-BACKLOG]].
