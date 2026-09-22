---
id: rust-rule-code-rejection-routes
title: Rust rejects malformed rule code before compiled artifacts exist
answers:
  - does reconstructed Rust source AST reject malformed rule code
  - does traced Rust compilation reject malformed lifecycle blocks
  - what does the native file loader report for malformed rule code
  - can a failed Rust semantic snapshot expose a generated plan
  - can a generated artifact recover rule code dropped by an older compiler
  - does the Rust source emitter accept raw rule code
  - which test executes emitted Rust after the rule code rejection repair
date: 2026-09-22
status: current
tags: [rust, compiler, generated-source, diagnostics, serialization]
evidence: "SESSION-STARTUP-READING.45.2 adds four route tests in rust/linkedspec-runtime/tests/source_emitter.rs. Eight independently specified malformed sources cover I/E/LX, the invalid infix document guard, explicit action/blind and default/AND bare-edge code. Assertions cover source and reconstructed AST under ordinary/traced compilation, path/name loaders and failed semantic snapshots; a valid control executes reconstructed compiled state, a generated plan and a freshly compiled emitted Rust module."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test source_emitter rule_code_"
---

The native full-source parser produces `SpecFile`, whose rule bodies retain authored
code strings. Serializing and reconstructing that AST preserves the input to rule-code
parsing. Both `compile` and `compile_with_trace` propagate the shared compiler's
attributed `LinkedSpecError::Compile`; malformed code produces no `CompiledSpec` to
serialize or pass to an emitter.

`load_and_compile_spec` reports `compile_spec` / `spec_compile_failed`, with the
requested name/path, resolved path and original compiler detail. `SemanticIndex`
retains parsed and validated source authority, but its snapshot is `failed_compilation`,
with no compiled authority, execution or generated plan. Its portable diagnostic is
`semantic_index_compilation_failed` at `compile_source`.

The source emitters accept an already compiled specification. Rule lifecycle and edge
code in `CompiledSpec` is parsed ActionIR, not the original rule-code string. Generated
modules embed that compiled JSON and a validated family plan. Consequently, upgrading
a decoder cannot recover authored rule code discarded by an older compiler: regenerate
such artifacts from the original `.spec` through the corrected compiler. No generated
format change or blanket validation of arbitrary serialized ActionIR is claimed here.

The positive control initializes 41 and returns 42. It checks file loaders, reconstructed
compiled execution, the generated-plan executor and an actual emitted module built and
run by Cargo; direct/traced generated results are 42 and the compatibility result is
[42]. Merely inspecting emitted source would not establish execution.

The .45.1 core and primary-CLI regressions own exhaustive lifecycle/call-site coverage
and the before/after reproduction. These route tests add carrier coverage without
changing production code. Unicode diagnostic safety and other parser defects remain
separately owned by startup .46/.47/.49. See [[rust-action-parser-boundary-defects]],
[[rust-native-spec-resolution]] and [[rust-generated-source-v2-rule-local-cursor]].
