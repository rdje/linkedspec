---
id: rust-generated-source-v1-metadata-errors
title: Historical Rust generated-source v1 identity metadata and error boundary
answers:
  - "what was the Rust generated source v1 emitter"
  - "what metadata did Rust generated source v1 expose"
  - "how did Rust generated source v1 report failures"
  - "when was emit_rust_source_v1 replaced"
date: 2026-07-11
status: superseded by rust-generated-source-v2-rule-local-cursor
tags: [rust, generated-source, api, metadata, diagnostics, compatibility]
evidence: "FUTURE-PARITY-BACKLOG.3.1.3.1 adds emit_rust_source_v1(&CompiledSpec, source_identity) -> Result<String, GeneratedSourceError>; GeneratedSourceMetadata with linkedspec-generated-source-v1, format 1, and source identity; emitted contract/version/identity constants and metadata(); typed execute/execute_with_trace; GeneratedSourceError::compile_failed for caller-owned host compilation/loading; and typed malformed-state, plan-validation, and attributed execution failures. emit_rust_source retains Result<String,String> with <inline> identity, and emitted parse/parse_with_trace retain the original raw-string routes. source_emitter tests pass 4/4; complete Rust gate passes 137/105/196/5/4/5/10 plus 61x2 CLI."
evidence_update_2026_07_18: "FUTURE-PARITY-BACKLOG.9.1.4.5 replaces the v1 emitter with emit_rust_source_v2 and rejects v1 reconstruction. The metadata/error architecture remains, but current identity is linkedspec-generated-source-v2 / format 2."
reverify: "git show d7b1a5e7:rust/linkedspec-runtime/src/source_emitter.rs | rg 'emit_rust_source_v1|linkedspec-generated-source-v1|GeneratedSourceMetadata|GeneratedSourceError'; rg -n 'emit_rust_source_v2|generated_source_v2_rejects_v1' rust/linkedspec-runtime/src/source_emitter.rs rust/linkedspec-runtime/tests/source_emitter.rs"
---

# Rust Generated-Source v1 Metadata and Errors

This card records the historical v1 landing. Its native emitter entrypoint was
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

Current callers must use `emit_rust_source_v2`; see
[[rust-generated-source-v2-rule-local-cursor]].

Related facts: [[generated-source-contract-v1]],
[[rust-generated-source-contract-v1-gap]], [[generated-source-parity-audit]].
