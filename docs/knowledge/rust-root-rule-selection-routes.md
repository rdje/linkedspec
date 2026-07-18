---
id: rust-root-rule-selection-routes
title: "Rust loaded, reconstructed, generated, emitted, trace, and diagnostic routes share root selection"
answers:
  - "how does Rust generated source choose its entry rule"
  - "can Rust emitted execute select an ordinary rule"
  - "can Rust emitted parse select an ordinary rule"
  - "which Rust generated APIs accept ExecutionOptions"
  - "does Rust generated root selection require a format version bump"
  - "is the Rust explicit selector stored in the generated plan"
  - "how do Rust serialized compiled specs preserve root selection"
  - "what generated source error reports an unknown Rust entry rule"
  - "what happens when generated Rust receives a zero-rule compiled artifact"
  - "does stale generated-source validation happen before root selection"
  - "what Rust trace event records generated entry selection"
  - "which rule labels Rust generated execution errors"
  - "does invoking a Rust entry rule alter descriptor identity"
  - "which Rust root-selection work remains after route convergence"
date: 2026-07-18
status: current, admission pending
supersedes: rust-root-rule-selection-core
tags: [rust, root-rule, top-rule, generated-source, emitted-source, serialized-spec, trace, diagnostics, descriptor, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.1.2.2.2 threads `ExecutionOptions` through loaded/serde-reconstructed and generated-plan execution, while preserving every existing default API. Generated and emitted option-bearing execute/parse, traced, and diagnostic-output siblings select any declared rule; omission resolves first authored marker then first declared rule. Generated source keeps format v2 and its ordered `{label,family}` plan because `CompiledSpec` already serializes ordered `CompiledRule { label, is_top, ... }`; the selector remains invocation state. Typed unknown selection returns `entry_rule_not_found` at `select_entry_rule` with `entry_rule`, and zero-rule reconstructed state returns `no_rules_defined` at `validate_spec`. Contract-v1 mismatch still rejects before selection. Trace topic `rust_runtime:generated_plan:top_rule` reports effective label and basis; runtime failures use the effective label/family. Descriptor JSON remains identical before and after execution. `.2.3` still owns topology-check admission, primary-manifest cases, and promotion of the Rust rollout row."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test root_rule_selection_core --test root_rule_selection_routes --test source_emitter && python3 tools/check_root_rule_selection_contract.py"
---

Rust composed execution reuses the core ordered resolver instead of deriving a separate generated-source rule.
Loaded specs and JSON-reconstructed `CompiledSpec` values retain authored definition order and `is_top` bits.
Generated-plan adapters resolve from that immutable state; emitted modules expose new option-bearing siblings while
the old signatures retain neutral default selection. The same contract therefore covers direct-value and legacy
accumulator results, quiet and traced calls, and diagnostic-output combinations.

The generated family plan remains intentionally minimal: ordered label and neutral family are execution-shape
metadata, while authored marker identity already lives in the embedded compiled state and the explicit selector
belongs only to one invocation. This avoids a format bump and prevents descriptor or generated metadata from
becoming mutable runtime state.

Typed generated-source validation preserves precedence between boundaries. Contract/plan validation happens
before root selection; then zero-rule structural validation precedes explicit lookup; only a valid selected rule
can enter user execution. Successful trace and failure attribution use the same effective identity. Rust library
and generated/emitted routes are aligned, but `.2.3` must still admit the primary-command and topology surfaces
before the Rust rollout row can be declared complete.

Related: [[root-rule-selection-precedence]], [[rust-root-rule-selection-core]],
[[rust-generated-source-family-plan]], [[rust-outward-compiled-descriptor-projection]], and
[[perl-root-rule-selection-routes]].
