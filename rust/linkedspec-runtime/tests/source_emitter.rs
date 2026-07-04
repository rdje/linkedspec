//! RUST-PARITY.8.2 — generated Rust-source scaffold compile/run proof.

use linkedspec_core::compiler::compile;
use linkedspec_core::parser::parse_spec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::Engine;
use linkedspec_runtime::source_emitter::emit_rust_source;
use serde_json::json;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

const SIMPLE_SOURCE_EMITTER_SPEC: &str = r#"Top::
 /hello[ \t]+(\w+)/
 E { return(array("?hello:", match_group(0))) }
"#;

struct TempProject {
    root: PathBuf,
}

impl TempProject {
    fn new(prefix: &str) -> Self {
        let nanos = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("system time should be after the Unix epoch")
            .as_nanos();
        let root = std::env::temp_dir().join(format!("{prefix}-{}-{nanos}", std::process::id()));
        if root.exists() {
            fs::remove_dir_all(&root).expect("remove stale generated-source temp project");
        }
        fs::create_dir_all(root.join("src")).expect("create generated-source temp project");
        Self { root }
    }

    fn path(&self) -> &Path {
        &self.root
    }
}

impl Drop for TempProject {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.root);
    }
}

#[test]
fn emitted_rust_source_compiles_and_runs_simple_parser() {
    let parsed = parse_spec(SIMPLE_SOURCE_EMITTER_SPEC).expect("parse source-emitter smoke spec");
    validate(&parsed).expect("validate source-emitter smoke spec");
    let compiled = compile(&parsed).expect("compile source-emitter smoke spec");

    let interpreted = Engine::new(compiled.clone())
        .execute("hello world")
        .expect("interpreted smoke parser should execute");
    assert_eq!(interpreted, json!([["?hello:", "world"]]));

    let generated = emit_rust_source(&compiled).expect("emit generated Rust source");
    assert!(generated.contains("LINKEDSPEC_GENERATED_SOURCE_FORMAT"));
    assert!(generated.contains("COMPILED_SPEC_JSON"));

    let project = TempProject::new("linkedspec-source-emitter");
    let runtime_manifest = Path::new(env!("CARGO_MANIFEST_DIR"));
    fs::write(
        project.path().join("Cargo.toml"),
        format!(
            r#"[package]
name = "linkedspec_generated_smoke"
version = "0.0.0"
edition = "2024"

[dependencies]
linkedspec-runtime = {{ path = "{}" }}
serde_json = "1"
"#,
            runtime_manifest.display()
        ),
    )
    .expect("write generated smoke Cargo.toml");

    fs::write(
        project.path().join("src/lib.rs"),
        format!(
            r#"{generated}

#[cfg(test)]
mod generated_source_tests {{
    #[test]
    fn generated_parser_runs() {{
        let actual = crate::parse("hello world").expect("generated parser should run");
        assert_eq!(actual, serde_json::json!([[ "?hello:", "world" ]]));
    }}
}}
"#
        ),
    )
    .expect("write generated smoke lib.rs");

    let output = Command::new("cargo")
        .arg("test")
        .arg("--offline")
        .arg("--quiet")
        .env("CARGO_TARGET_DIR", project.path().join("target"))
        .current_dir(project.path())
        .output()
        .expect("run generated smoke cargo test");

    assert!(
        output.status.success(),
        "generated smoke cargo test failed\nstatus: {}\nstdout:\n{}\nstderr:\n{}",
        output.status,
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    );
}
