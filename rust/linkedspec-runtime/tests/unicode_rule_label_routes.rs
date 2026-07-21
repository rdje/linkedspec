//! FUTURE-PARITY-BACKLOG.10.4.0.2 — Unicode labels across public Rust routes.

use linkedspec_core::compiler::compile;
use linkedspec_core::parser::parse_spec;
use linkedspec_core::trace::{TraceConfig, TraceLevel};
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, emit_rust_source_v2,
    execute_generated_parser_v2_with_options,
};
use linkedspec_runtime::spec_loader::{
    SpecLoadOptions, SpecPipelineCode, SpecPipelineStage, SpecRequest, load_and_compile_spec,
};
use serde_json::json;
use std::fs;
use std::path::{Path, PathBuf};
use std::time::{SystemTime, UNIX_EPOCH};

const DECOMPOSED_TOP: &str = "To\u{0308}p";
const SOURCE_IDENTITY: &str = "unicode/Töp.spec";
const SOURCE: &str = "Töp::\n /x/\n E { return(\"precomposed\") }\n\nTo\u{0308}p:\n /x/\n E { return(\"decomposed\") }\n\ntöp:\n /x/\n E { return(\"lowercase\") }\n";
const PLAN: &[GeneratedPlanRow] = &[
    GeneratedPlanRow {
        label: "Töp",
        family: "default",
    },
    GeneratedPlanRow {
        label: DECOMPOSED_TOP,
        family: "default",
    },
    GeneratedPlanRow {
        label: "töp",
        family: "default",
    },
];

struct ScratchDirectory(PathBuf);

impl ScratchDirectory {
    fn new() -> Self {
        let nonce = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("clock after Unix epoch")
            .as_nanos();
        let path = std::env::temp_dir().join(format!(
            "linkedspec-unicode-label-routes-{}-{nonce}",
            std::process::id()
        ));
        fs::create_dir_all(&path).expect("create Unicode-label scratch directory");
        Self(path)
    }

    fn path(&self) -> &Path {
        &self.0
    }
}

impl Drop for ScratchDirectory {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.0);
    }
}

fn compiled() -> CompiledSpec {
    let parsed = parse_spec(SOURCE).expect("parse Unicode route fixture");
    validate(&parsed).expect("validate Unicode route fixture");
    compile(&parsed).expect("compile Unicode route fixture")
}

fn select(label: &str) -> ExecutionOptions {
    ExecutionOptions::new().with_entry_rule(label)
}

#[test]
fn native_selector_descriptor_and_trace_keep_exact_scalar_identity() {
    let compiled = compiled();
    assert_eq!(
        compiled
            .rules
            .iter()
            .map(|rule| rule.label.as_str())
            .collect::<Vec<_>>(),
        ["Töp", DECOMPOSED_TOP, "töp"]
    );
    let descriptor = compiled
        .to_descriptor_json()
        .expect("project Unicode-label descriptor");
    assert_eq!(descriptor["spec"]["Töp"]["handler"]["label"], "Töp");
    assert_eq!(
        descriptor["spec"][DECOMPOSED_TOP]["handler"]["label"],
        DECOMPOSED_TOP
    );
    assert_eq!(descriptor["spec"]["töp"]["handler"]["label"], "töp");
    assert_eq!(
        descriptor["meta"]["definition_order"],
        json!(["Töp", DECOMPOSED_TOP, "töp"])
    );

    let engine = Engine::new(compiled);
    assert_eq!(
        engine
            .execute_value("x", &select("Töp"))
            .expect("execute precomposed selector"),
        json!("precomposed")
    );
    assert_eq!(
        engine
            .execute_value("x", &select(DECOMPOSED_TOP))
            .expect("execute decomposed selector"),
        json!("decomposed")
    );
    assert_eq!(
        engine
            .execute_value("x", &select("töp"))
            .expect("execute lowercase selector"),
        json!("lowercase")
    );

    let scratch = ScratchDirectory::new();
    let trace_path = scratch.path().join("unicode.trace");
    engine
        .execute_value_with_trace(
            "x",
            &select(DECOMPOSED_TOP),
            TraceConfig::enabled(TraceLevel::DEBUG)
                .with_trace_file(trace_path.clone())
                .with_reset_file(true),
        )
        .expect("execute traced decomposed selector");
    let trace = fs::read_to_string(trace_path).expect("read Unicode-label trace");
    assert!(trace.contains(&format!("entry_rule={DECOMPOSED_TOP}")));
    assert!(trace.contains(&format!("rule={DECOMPOSED_TOP}")));
}

#[test]
fn generated_plan_and_emitted_source_keep_unicode_labels_exact() {
    let compiled = compiled();
    let compiled_json = serde_json::to_string(&compiled).expect("serialize Unicode compiled spec");
    for (label, expected) in [
        ("Töp", json!("precomposed")),
        (DECOMPOSED_TOP, json!("decomposed")),
        ("töp", json!("lowercase")),
    ] {
        assert_eq!(
            execute_generated_parser_v2_with_options(
                &compiled_json,
                PLAN,
                "x",
                SOURCE_IDENTITY,
                GENERATED_SOURCE_CONTRACT,
                &select(label),
            )
            .unwrap_or_else(|error| panic!("generated selector {label:?}: {error}")),
            expected
        );
    }

    let emitted = emit_rust_source_v2(&compiled, SOURCE_IDENTITY)
        .expect("emit source containing Unicode identities");
    for exact in ["Töp", DECOMPOSED_TOP, "töp", SOURCE_IDENTITY] {
        assert!(emitted.contains(exact), "emitted source lost {exact:?}");
    }
}

#[test]
fn strict_file_loader_accepts_unicode_and_rejects_invalid_utf8_before_parsing() {
    let scratch = ScratchDirectory::new();
    let valid_path = scratch.path().join("unicode.spec");
    fs::write(&valid_path, SOURCE).expect("write valid Unicode spec");
    let loaded = load_and_compile_spec(
        &SpecRequest::path(valid_path.to_string_lossy().into_owned()),
        &SpecLoadOptions::new(scratch.path()),
    )
    .expect("strictly load and compile Unicode spec");
    assert_eq!(
        loaded
            .compiled()
            .rules
            .iter()
            .map(|rule| rule.label.as_str())
            .collect::<Vec<_>>(),
        ["Töp", DECOMPOSED_TOP, "töp"]
    );

    let invalid_path = scratch.path().join("invalid-utf8.spec");
    fs::write(&invalid_path, b"Top::\n /x/\n\xFF").expect("write invalid UTF-8 fixture");
    let error = load_and_compile_spec(
        &SpecRequest::path(invalid_path.to_string_lossy().into_owned()),
        &SpecLoadOptions::new(scratch.path()),
    )
    .expect_err("invalid UTF-8 must fail before parsing");
    assert_eq!(error.stage, SpecPipelineStage::DecodeSpecContent);
    assert_eq!(error.code, SpecPipelineCode::InvalidUtf8);
}
