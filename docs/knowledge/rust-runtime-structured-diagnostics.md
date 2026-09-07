---
id: rust-runtime-structured-diagnostics
title: Rust native execution exposes serializable structured runtime diagnostics with deepest-rule attribution
answers:
  - "does Rust runtime expose structured diagnostics"
  - "what is Rust RuntimeDiagnostic"
  - "how do Rust callers execute with diagnostics"
  - "how does Rust preserve failing child rule attribution"
  - "can Rust keep legacy string runtime errors"
  - "how do Rust callers attach spec name and path"
date: 2026-09-07
status: current
tags: [rust, runtime, diagnostics, public-api, embedding, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.3.1 adds RuntimeDiagnostic, RuntimeExecutionError, Engine::execute_with_diagnostics, Engine::execute_value_with_diagnostics, optional with_spec_name/with_spec_path identity, and first/deepest failure capture in RuntimeContext before execute_rule unwind. Five focused tests and the full runtime package pass: 137 unit, 105 oracle, 196 integration, five diagnostic, three generated-source, and ten trace tests."
evidence_update_2026_07_11: "FUTURE-PARITY-BACKLOG.1.6.3.2 reruns the complete Rust gate, passes 61/61 primary CLI cases in default and POSIX environments, promotes the capability to pass, and closes structured diagnostic parity across all four variants."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test runtime_diagnostics"
---

# Rust Runtime Structured Diagnostics

`linkedspec_runtime` exports `RuntimeDiagnostic` and `RuntimeExecutionError`. Native callers use
`Engine::execute_with_diagnostics(...)` for accumulator output or `execute_value_with_diagnostics(...)` for a
direct selected rule value. Both remain ordinary Rust `Result` APIs.

The initial diagnostic record supplied the base type/stage/summary/detail and optional source/rule identity.
Current `diagnostic.rs` also declares optional code, entry-rule, helper/arity, regex-slot, and callable/value-kind/
cycle context. Every optional field omits `None` during serialization. The engine's `with_spec_name(...)` /
`with_spec_path(...)` builders attach caller-owned source identity.

`RuntimeContext` retains only the first failure context. Because every interpreted child passes through
`Engine::execute_rule(...)`, the child's wrapper records its label before variable and recursion frames unwind;
parent wrappers therefore cannot overwrite it. Current root selection returns `entry_rule_not_found` at
`select_entry_rule`, or `no_rules_defined` at `validate_spec` for an empty compiled state. A later missing
cross-rule target uses the separate `rule_lookup` failure boundary.

Existing `execute(...)` and `execute_value(...)` delegate through the typed path and return the unchanged message
as `String`. Successful values, trace APIs, generated-plan APIs, and the canonical primary CLI projection are
unchanged. Final capability admission closed under `.1.6.3.2`.

## September 7 complete type reading

`SESSION-STARTUP-READING.3.3.14` reads all 127 lines / 5,269 bytes of `diagnostic.rs`.
`RuntimeExecutionError` retains its compatibility message and boxed diagnostic,
delegates Display to the message, and exposes borrow, consume-message and JSON APIs.
The updated field inventory is source evidence. Deepest-rule capture and entrypoint
execution retain their separate engine/runtime owners; the older native counts above
are dated July results, not a fresh suite run for this documentation checkpoint.

## September 7 execution-wrapper reading

`SESSION-STARTUP-READING.3.3.16` reads engine lines 1895–3394. The structured
adapter copies the retained failure code, stage, helper/slot/callable context and
caller-owned spec identity. `entry_rule` is populated for unknown explicit selection;
handler attribution uses the failing rule or the effective entry fallback. Rule-body
errors are captured before variable/recursion unwind. This is source proof of these
wrappers, without claiming every recognition-exit error has a separately captured label.
Fresh root-selection neutral proof passes 8 selections, 3 failures, 3 strict cases,
7 complete/0 pending legs and 54 mutations.
