---
id: rust-generated-source-v1-metadata-errors
title: Rust generated source exposes typed v1 identity metadata and errors beside compatibility adapters
answers:
  - "how do I emit Rust generated source with source identity"
  - "what metadata does generated Rust source expose"
  - "what type reports Rust generated-source failures"
  - "how does Rust report generated source compile failures"
  - "does emit_rust_source still return string errors"
  - "do generated Rust parse entrypoints remain compatible"
date: 2026-07-11
status: current
tags: [rust, generated-source, api, metadata, diagnostics, compatibility]
evidence: "FUTURE-PARITY-BACKLOG.3.1.3.1 adds emit_rust_source_v1(&CompiledSpec, source_identity) -> Result<String, GeneratedSourceError>; GeneratedSourceMetadata with linkedspec-generated-source-v1, format 1, and source identity; emitted contract/version/identity constants and metadata(); typed execute/execute_with_trace; GeneratedSourceError::compile_failed for caller-owned host compilation/loading; and typed malformed-state, plan-validation, and attributed execution failures. emit_rust_source retains Result<String,String> with <inline> identity, and emitted parse/parse_with_trace retain the original raw-string routes. source_emitter tests pass 4/4; complete Rust gate passes 137/105/196/5/4/5/10 plus 61x2 CLI."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter -- --nocapture && rg -n 'emit_rust_source_v1|GeneratedSourceMetadata|GeneratedSourceError|compile_failed|pub fn metadata|pub fn execute|pub fn parse' rust/linkedspec-runtime/src/source_emitter.rs rust/linkedspec-runtime/tests/source_emitter.rs"
---

# Rust Generated-Source v1 Metadata and Errors

Rust's new native emitter entrypoint is
`emit_rust_source_v1(&compiled, source_identity)`. It returns deterministic
Rust source or a typed `GeneratedSourceError`. Emitted modules expose the exact
contract id, format version, source identity, and `metadata()` projection.

Typed generated `execute` and `execute_with_trace` entrypoints report portable
emission, compile/load, plan-validation, and execution stages/codes with source
and available rule/family/detail attribution. Because the host caller owns
`rustc` or another loader, `GeneratedSourceError::compile_failed(...)` is its
projection seam.

Compatibility is deliberate: `emit_rust_source(&compiled)` still returns raw
string errors with `<inline>` identity, and generated `parse`/`parse_with_trace`
retain their original string-returning execution path. Exact neutral plan,
result, and trace roles landed separately under `.3.1.3.2`; this card remains
the narrower metadata/error fact and does not itself claim admission.

Related facts: [[generated-source-contract-v1]],
[[rust-generated-source-contract-v1-gap]], [[generated-source-parity-audit]].
