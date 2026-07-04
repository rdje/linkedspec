//! Rust source emitter scaffold.
//!
//! `RUST-PARITY.8.2` introduces the generated-source path without replacing the
//! interpreted runtime. The emitted module embeds a serialized `CompiledSpec`
//! and exposes a small `parse(input)` entry point that delegates to `Engine`.
//! Direct per-handler source emission is split into later leaves.

use linkedspec_core::types::CompiledSpec;

/// Version of the generated-source scaffold format.
pub const GENERATED_SOURCE_FORMAT: u32 = 1;

/// Emit a standalone Rust module for `compiled`.
///
/// The returned source expects dependencies on `linkedspec-runtime` and
/// `serde_json`. It intentionally goes through the existing runtime engine; this
/// leaf proves the source-generation API and compile/run harness before later
/// leaves replace structural families with direct generated handlers.
pub fn emit_rust_source(compiled: &CompiledSpec) -> Result<String, String> {
    let spec_json = serde_json::to_string(compiled)
        .map_err(|e| format!("failed to serialize compiled spec for generated source: {e}"))?;
    let spec_literal = serde_json::to_string(&spec_json)
        .map_err(|e| format!("failed to encode compiled spec string literal: {e}"))?;

    let mut source = String::new();
    source.push_str("//! Generated LinkedSpec parser module.\n");
    source.push_str("//! Source format: linkedspec-runtime source_emitter v1.\n\n");
    source.push_str(&format!(
        "pub const LINKEDSPEC_GENERATED_SOURCE_FORMAT: u32 = {GENERATED_SOURCE_FORMAT};\n"
    ));
    source.push_str("const COMPILED_SPEC_JSON: &str = ");
    source.push_str(&spec_literal);
    source.push_str(";\n\n");
    source.push_str(
        r#"pub fn parse(input: &str) -> Result<serde_json::Value, String> {
    let compiled = serde_json::from_str(COMPILED_SPEC_JSON)
        .map_err(|e| format!("generated CompiledSpec JSON is invalid: {e}"))?;
    let engine = linkedspec_runtime::engine::Engine::new(compiled);
    engine.execute(input)
}
"#,
    );
    Ok(source)
}
