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
date: 2026-09-07
status: current
tags: [rust, logical, truthiness, arity, runtime, diagnostics, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.5.2.3 changes RuntimeValue::as_bool to the ADR 0043 typed truth table and adds validate_logical_helper_arity before eager operand collection in engine.rs. rust/linkedspec-runtime/tests/logical_helper_contract.rs consumes linkedspec-logical-helper-v1 across all representable truth rows, values, ordered effects, receivers, lazy controls, four invalid calls, native compiled, serialized reconstruction, direct value, generated plan, and an offline compiled standalone emitted crate. Complete Rust package, Perl-oracle corpus, generated manifest, 197 integration, and 62x2 Rust primary proof pass; that slice advanced rollout to 2 complete / 6 pending before Dart."
reverify: "bash tools/run_python_project_data.sh tools/check_logical_helper_contract.py && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-core runtime_value_as_bool && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test logical_helper_contract && rg -n 'validate_logical_helper_arity|validate_eager_helper_arity|fn as_bool|helper_arity_mismatch' rust/linkedspec-core/src/types.rs rust/linkedspec-runtime/src/engine.rs rust/linkedspec-runtime/src/runtime.rs"
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

Eager helpers and lazy `if`/`while` conditions call the same `as_bool` seam.
Switch selects a string-coerced subject against literal/dynamic case labels; it does
not use truthiness to compare cases. Controls evaluate only the selected branch or
loop body. Serialized compiled specs, generated plans, direct-value execution, and emitted
modules all route back through this runtime owner rather than reimplementing truthiness.

At the initial July 17 logical-helper admission, Rust had no first-class codeblock value and its neutral source
fixture omitted that inert-codeblock truth row. Later `FUTURE-PARITY-BACKLOG.11.4.1` introduced the inert, truthy
`RuntimeValue::Codeblock`; dynamic invocation followed in `.11.4.2`. The current construction and value authority
is [[rust-callable-codeblock-literal-state]]. The earlier limitation is historical, not a current enum boundary.

Reading checkpoint `SESSION-STARTUP-READING.3.3.13` reads the complete 222-line core type-test file. Its truth
assertions distinguish nonempty strings (including `"0"` and `"false"`), numeric zero, booleans, and aggregate
emptiness. They do not exercise a codeblock value or establish exhaustive serialization across every variant.
The managed locked/offline core `types_test` target freshly passes all eight tests, with no ignored or
filtered cases, in 0.00 test seconds. This includes the selected serde, small-number JSON, truth, number,
nonempty and length examples; it does not cover `.55`'s large-number loss.
The fresh neutral checker passes 17 truthiness, ten helper, and three effect cases with 26 rejected mutations.
These bounded checks do not replace the separate logical-runtime and callable-carrier owners.

Related facts: [[logical-helper-neutral-contract]], [[logical-helper-five-backend-audit]],
[[cross-backend-condition-truthiness-drift]].

Reading `SESSION-STARTUP-READING.3.3.21` completes the helper dispatcher:
and/or inspect already-evaluated operands, whereas if/elseif/switch/while explicitly
evaluate selected raw expressions. While evaluates the condition before enforcing
the iteration ceiling. Unknown helpers first try a bound codeblock; active-codeblock
failure is typed, while ordinary unknown helpers warn and return undef. The neutral
logical checker passes 17 truthiness/10 helper/3 effect cases and 26 mutations;
this update does not rerun native generated logical consumers.
