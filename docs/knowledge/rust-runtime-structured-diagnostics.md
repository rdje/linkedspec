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
date: 2026-07-11
status: current
tags: [rust, runtime, diagnostics, public-api, embedding, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.3.1 adds RuntimeDiagnostic, RuntimeExecutionError, Engine::execute_with_diagnostics, Engine::execute_value_with_diagnostics, optional with_spec_name/with_spec_path identity, and first/deepest failure capture in RuntimeContext before execute_rule unwind. Five focused tests and the full runtime package pass: 137 unit, 105 oracle, 196 integration, five diagnostic, three generated-source, and ten trace tests."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test runtime_diagnostics && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime"
---

# Rust Runtime Structured Diagnostics

`linkedspec_runtime` exports `RuntimeDiagnostic` and `RuntimeExecutionError`. Native callers use
`Engine::execute_with_diagnostics(...)` for accumulator output or `execute_value_with_diagnostics(...)` for a
direct selected rule value. Both remain ordinary Rust `Result` APIs.

The diagnostic serializes the neutral fields `type`, `stage`, `owner_stage`, `summary`, `detail`, `spec_name`,
`spec_path`, `top_rule`, `rule_label`, and `handler_source_label`; unavailable optional fields are omitted. The
engine's `with_spec_name(...)` / `with_spec_path(...)` builders attach caller-owned source identity.

`RuntimeContext` retains only the first failure context. Because every interpreted child passes through
`Engine::execute_rule(...)`, the child's wrapper records its label before variable and recursion frames unwind;
parent wrappers therefore cannot overwrite it. Missing selected entries use `rule_lookup`, and an empty compiled
state uses `top_rule_selection`.

Existing `execute(...)` and `execute_value(...)` delegate through the typed path and return the unchanged message
as `String`. Successful values, trace APIs, generated-plan APIs, and the canonical primary CLI projection are
unchanged. Final capability admission remains `.1.6.3.2`.
