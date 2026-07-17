---
id: rust-logical-helper-neutral-runtime
title: Rust logical helpers and lazy controls share one typed truthiness and arity boundary
answers:
  - "where is Rust logical truthiness implemented"
  - "are string zero and string false true in Rust LinkedSpec"
  - "does Rust validate logical helper arity before operand effects"
  - "are Rust logical helpers eager or short circuit"
  - "do Rust logical helpers and lazy controls share truthiness"
  - "which Rust generated roles prove the logical helper contract"
  - "what fields are in a Rust logical arity diagnostic"
  - "does Rust logical parity activate explicit codeblock literals"
date: 2026-07-17
status: current
tags: [rust, logical, truthiness, arity, runtime, diagnostics, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.5.2.3 changes RuntimeValue::as_bool to the ADR 0043 typed truth table and adds validate_logical_helper_arity before eager operand collection in engine.rs. rust/linkedspec-runtime/tests/logical_helper_contract.rs consumes linkedspec-logical-helper-v1 across all representable truth rows, values, ordered effects, receivers, lazy controls, four invalid calls, native compiled, serialized reconstruction, direct value, generated plan, and an offline compiled standalone emitted crate. Complete Rust package, Perl-oracle corpus, generated manifest, 197 integration, and 62x2 Rust primary proof pass; rollout is 2 complete / 6 pending."
reverify: "python3 tools/check_logical_helper_contract.py && cargo test --manifest-path rust/Cargo.toml -p linkedspec-core runtime_value_as_bool && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test logical_helper_contract && rg -n 'validate_logical_helper_arity|validate_eager_helper_arity|fn as_bool|helper_arity_mismatch' rust/linkedspec-core/src/types.rs rust/linkedspec-runtime/src/engine.rs rust/linkedspec-runtime/src/runtime.rs"
---

`RuntimeValue::as_bool` is Rust's one language-truth boundary. It makes undef, false, numeric zero (including
negative zero), the empty string, and empty arrays/harrays false. Every other finite number, every nonempty string
including `"0"` and `"false"`, and every nonempty aggregate are true. Scalar display and numeric parsing remain
separate operations.

`and`, `or`, and `not` validate authored positional arity before the engine evaluates any operand: `and`/`or`
require one or more and `not` requires exactly one. Valid operands then evaluate once left-to-right before boolean
composition. The helper dispatcher repeats the validation defensively, but the expression-boundary check is what
guarantees no invalid-call effects. Native `RuntimeDiagnostic` records `code`, `helper_name`, `actual_arity`, and
`expected_arity`; generated execution preserves the same tokens in its deterministic detail.

Eager helpers and lazy `if`/`switch`/`while` conditions call the same `as_bool` seam. Controls still evaluate only
the selected branch or loop body. Serialized compiled specs, generated plans, direct-value execution, and emitted
modules all route back through this runtime owner rather than reimplementing truthiness.

Rust's current `RuntimeValue` enum has no first-class codeblock value. The neutral source fixture therefore omits
the model's inert-codeblock truth row, as the contract permits until `FUTURE-PARITY-BACKLOG.11` admits explicit
portable literals. This rollout does not activate that syntax.

Related facts: [[logical-helper-neutral-contract]], [[logical-helper-five-backend-audit]],
[[cross-backend-condition-truthiness-drift]].
