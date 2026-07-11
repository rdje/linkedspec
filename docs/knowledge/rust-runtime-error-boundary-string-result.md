---
id: rust-runtime-error-boundary-string-result
title: Rust runtime failures propagate as Engine Result strings, not the core runtime error variant
answers:
  - "what error type do Rust Engine execute methods return"
  - "does linkedspec runtime use LinkedSpecError Runtime"
  - "where must Rust structured runtime diagnostics be captured"
  - "how can Rust preserve failing child rule attribution"
  - "why was FUTURE PARITY BACKLOG 1.6.3 split"
date: 2026-07-11
status: resolved
tags: [rust, runtime, diagnostics, public-api, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.3.0 source/toolbox audit. rust/linkedspec-runtime/src/engine.rs exposes execute/execute_value/trace/generated-plan methods as Result<Value,String>, and internal runtime frames use Result<_,String>. rust/linkedspec-core/src/error.rs defines LinkedSpecError::Runtime(String), but linkedspec-runtime has no LinkedSpecError reference. execute_rule is the singular interpreted rule wrapper and receives a child error before variable/recursion frame unwind. RuntimeContext has no top/rule/diagnostic state and Engine stores only CompiledSpec."
evidence_update_2026_07_11: "FUTURE-PARITY-BACKLOG.1.6.3.1 adds typed diagnostic-aware Engine methods while preserving existing Result<Value,String> methods as compatibility adapters. RuntimeContext captures the deepest rule before unwind; optional Engine spec identity fills source fields. Five focused and the complete runtime package pass."
reverify: "rg -n 'pub fn execute|Result<.*String>|fn execute_rule' rust/linkedspec-runtime/src/engine.rs && rg -n 'LinkedSpecError' rust/linkedspec-runtime/src rust/linkedspec-core/src/error.rs"
---

# Rust Runtime Error Boundary Is the Engine String Result

The active Rust native failure boundary is `linkedspec_runtime::engine::Engine`, whose public execution methods and
internal runtime frames return raw string errors. The core crate's `LinkedSpecError::Runtime(String)` variant is a
separate unused declaration, not the type an embedded Rust caller receives.

`Engine::execute_rule(...)` is the correct attribution seam for interpreted execution. Child calls pass through it,
and an error reaches the child's wrapper before that wrapper removes its variable and recursion frames. Capturing a
diagnostic there preserves the deepest failing rule; parent and top-level wrappers must retain rather than replace
that richer payload. The engine also needs optional caller-supplied spec name/path identity because `CompiledSpec`
does not carry filesystem provenance.

`.1.6.3.1` implemented typed records and diagnostic-aware methods while retaining existing string-returning
adapters. `.1.6.3.2` owns full no-drift proof and capability admission.
