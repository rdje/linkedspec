//! The existing readiness test owns allocation; this module supplies lossless carrier probes.
use super::{LocalCrate, compiled};
use linkedspec_runtime::engine::Engine;
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, GeneratedRuleSpec, classify_generated_rule_family,
    emit_rust_source_v2, execute_generated_parser_with_diagnostic_output_v2_with_options,
    validate_generated_parser_plan_v2,
};
use serde_json::Value;
use sha2::{Digest, Sha256};
use std::fs;
use std::path::PathBuf;
use std::process::Command;
use std::sync::Arc;

#[path = "rust_checks.rs"]
mod checks;
use checks::Parser;

const SEGMENTS: &str = include_str!("../lossless-segments/grammar.spec");
const CASES: &str = include_str!("../lossless-segments/cases.json");
const PARENT: &str = include_str!("parent.spec");
const CHILD: &str = include_str!("child.spec");
const STRICT: &str = include_str!("cases.json");
const CHECKS: &str = include_str!("rust_checks.rs");

fn digest(source: &str) -> String {
    let hex: String = Sha256::digest(source.as_bytes())
        .iter()
        .map(|byte| format!("{byte:02x}"))
        .collect();
    format!("sha256:{hex}")
}

fn replace_once(source: &str, from: &str, to: &str) -> String {
    assert_eq!(source.matches(from).count(), 1, "mutation owner: {from}");
    source.replace(from, to)
}

fn segment_variants() -> Vec<(&'static str, String)> {
    let prefix = concat!(
        "  if(num_ne(cursor_pos(), 0));\n",
        "   push(parts, hash(\"kind\", \"entry_prefix\", \"span\", [0, cursor_pos()], \"text\", input_slice(0, cursor_pos())))\n",
        "  endif();\n"
    );
    let tail = " LX {\n  push(parts, hash(\"kind\", gap_kind(), \"span\", gap_span(), \"text\", gap_text()))\n";
    vec![
        ("selection", replace_once(SEGMENTS, "[0-9]", "[1-9]")),
        ("tail", replace_once(SEGMENTS, tail, " LX {\n")),
        (
            "item_span",
            replace_once(
                SEGMENTS,
                "[entry_start_pos(), entry_end_pos()]",
                "[entry_end_pos(), entry_end_pos()]",
            ),
        ),
        ("entry_prefix", replace_once(SEGMENTS, prefix, "")),
    ]
}

fn child_variants() -> Vec<(&'static str, bool, String)> {
    vec![
        (
            "leading_zero",
            false,
            replace_once(CHILD, "(0|[1-9][0-9]*)", "([0-9]+)"),
        ),
        (
            "wrong_span",
            false,
            replace_once(
                CHILD,
                "\"start\", entry_start_pos()",
                "\"start\", num_add(entry_start_pos(), 1)",
            ),
        ),
        (
            "whole_item",
            true,
            replace_once(PARENT, "parse_job(entry_group(0)", "parse_job(entry_text()"),
        ),
    ]
}

fn carriers(source: &str, labels: [&'static str; 2]) -> Vec<Parser> {
    let compiled = compiled(source);
    let encoded = serde_json::to_string(&compiled).unwrap();
    let restored = serde_json::from_str(&encoded).unwrap();
    assert_eq!(compiled.rules.len(), labels.len());
    let mut rules = Vec::new();
    let mut plan = Vec::new();
    for (rule, label) in compiled.rules.iter().zip(labels) {
        assert_eq!(rule.label, label);
        let family = classify_generated_rule_family(rule);
        rules.push(GeneratedRuleSpec { label, family });
        plan.push(GeneratedPlanRow {
            label,
            family: family.contract_name(),
        });
    }
    validate_generated_parser_plan_v2(
        &encoded,
        &plan,
        "lossless/readiness",
        GENERATED_SOURCE_CONTRACT,
    )
    .unwrap();
    let mut routes: Vec<Parser> = Vec::new();
    for compiled in [compiled, restored] {
        let engine = Arc::new(Engine::new(compiled));
        let native = engine.clone();
        routes.push(Arc::new(move |input, options| {
            checks::native(native.execute_value_with_diagnostic_output(input, options, None))
        }));
        let rules = rules.clone();
        routes.push(Arc::new(move |input, options| {
            checks::native(
                engine.execute_generated_value_with_plan_with_diagnostic_output_and_options(
                    &rules, input, None, options,
                ),
            )
        }));
    }
    // This public entry reconstructs an engine per call; it establishes isolation, not retained recovery.
    routes.push(Arc::new(move |input, options| {
        checks::generated(
            execute_generated_parser_with_diagnostic_output_v2_with_options(
                &encoded,
                &plan,
                input,
                "lossless/readiness",
                GENERATED_SOURCE_CONTRACT,
                None,
                options,
            ),
        )
    }));
    routes
}

#[test]
fn five_lossless_routes_preserve_actual_child_results_and_controls() {
    let cases: Value = serde_json::from_str(CASES).unwrap();
    let strict: Value = serde_json::from_str(STRICT).unwrap();
    let segments = carriers(SEGMENTS, ["Item", "Segments"]);
    let parents = carriers(PARENT, ["Item", "Segments"]);
    let children = carriers(CHILD, ["Number", "Digits"]);
    let mut original_records = None;
    for route in 0..5 {
        checks::segmentation(&cases, &segments[route]);
        let records = checks::children(
            &cases,
            &strict,
            &parents[route],
            &children[route],
            &digest(CHILD),
        );
        if let Some(expected) = &original_records {
            assert_eq!(
                &records, expected,
                "complete enriched results across carriers"
            );
        } else {
            original_records = Some(records);
        }
    }
    for (id, source) in segment_variants() {
        for parse in carriers(&source, ["Item", "Segments"]) {
            checks::segment_mutation(id, &cases, &parse);
        }
    }
    for (id, is_parent, source) in child_variants() {
        let variants = carriers(
            &source,
            if is_parent {
                ["Item", "Segments"]
            } else {
                ["Number", "Digits"]
            },
        );
        for route in 0..5 {
            let (parent, child, digest) = if is_parent {
                (&variants[route], &children[route], digest(CHILD))
            } else {
                (&parents[route], &variants[route], digest(&source))
            };
            checks::child_mutation(id, parent, child, &digest);
        }
    }
    println!(
        "lossless Rust: five in-process matched carriers; thirteen segmentation and composition cases twice; child4/15; seven mutants; four retained recoveries and one per-call isolation"
    );
}

#[test]
fn fresh_emitted_lossless_parent_and_children_preserve_oracles() {
    let root = PathBuf::from(
        std::env::var_os("LINKEDSPEC_REPO_ROOT").expect("use tools/run_cargo_local.sh"),
    );
    let project = LocalCrate::new(&root);
    fs::write(
        project.0.join("Cargo.toml"),
        r#"[package]
name = "lossless-child-readiness-emitted"
version = "0.0.0"
edition = "2024"
[workspace]
[dependencies]
linkedspec-runtime = { path = "../../../rust/linkedspec-runtime" }
serde_json = "1"
"#,
    )
    .unwrap();
    fs::copy(root.join("rust/Cargo.lock"), project.0.join("Cargo.lock")).unwrap();
    fs::write(project.0.join("cases.json"), CASES).unwrap();
    fs::write(project.0.join("strict.json"), STRICT).unwrap();
    fs::write(project.0.join("src/checks.rs"), CHECKS).unwrap();
    let mut modules = vec![
        ("segments".to_owned(), SEGMENTS.to_owned()),
        ("parent".to_owned(), PARENT.to_owned()),
        ("child".to_owned(), CHILD.to_owned()),
    ];
    modules.extend(
        segment_variants()
            .into_iter()
            .map(|(id, source)| (format!("segment_{id}"), source)),
    );
    modules.extend(
        child_variants()
            .into_iter()
            .map(|(id, _, source)| (id.to_owned(), source)),
    );
    let mut harness = String::from(
        "#![allow(dead_code)]\nmod checks;\nuse std::sync::Arc;\nuse checks::Parser;\n",
    );
    for (id, source) in modules {
        let emitted = emit_rust_source_v2(&compiled(&source), &format!("lossless/{id}")).unwrap();
        fs::write(project.0.join(format!("src/{id}.rs")), emitted).unwrap();
        harness.push_str(&format!(r#"
mod {id};
fn parser_{id}() -> Parser {{
    let metadata = {id}::metadata();
    assert_eq!(metadata.contract_id, "linkedspec-generated-source-v2");
    assert_eq!(metadata.format_version, 2);
    assert_eq!(metadata.source_identity, "lossless/{id}");
    {id}::validate_plan({id}::plan()).unwrap();
    Arc::new(|input, options| checks::generated({id}::execute_with_options_and_diagnostic_output(input, options, None)))
}}
"#));
    }
    harness.push_str(&format!(
        r#"
#[test]
fn original_segmentation() {{
    let cases = serde_json::from_str(include_str!("../cases.json")).unwrap();
    checks::segmentation(&cases, &parser_segments());
}}
#[test]
fn actual_child_composition() {{
    let cases = serde_json::from_str(include_str!("../cases.json")).unwrap();
    let strict = serde_json::from_str(include_str!("../strict.json")).unwrap();
    checks::children(&cases, &strict, &parser_parent(), &parser_child(), "{}");
}}
#[test]
fn seven_mutations() {{
    let cases = serde_json::from_str(include_str!("../cases.json")).unwrap();
"#,
        digest(CHILD)
    ));
    for (id, _) in segment_variants() {
        harness.push_str(&format!(
            "checks::segment_mutation(\"{id}\", &cases, &parser_segment_{id}());\n"
        ));
    }
    for (id, is_parent, source) in child_variants() {
        let (parent, child, digest) = if is_parent {
            (id, "child", digest(CHILD))
        } else {
            ("parent", id, digest(&source))
        };
        harness.push_str(&format!("checks::child_mutation(\"{id}\", &parser_{parent}(), &parser_{child}(), \"{digest}\");\n"));
    }
    harness.push_str("}\n");
    fs::write(project.0.join("src/lib.rs"), harness).unwrap();
    let cargo = std::env::var_os("LINKEDSPEC_CARGO_CMD").unwrap_or_else(|| "cargo".into());
    let output = Command::new(cargo)
        .args(["test", "--offline", "--quiet", "--color", "never"])
        .env(
            "CARGO_TARGET_DIR",
            root.join(".linkedspec-data/cache/nested-tree-rust-emitted-target"),
        )
        .current_dir(&project.0)
        .output()
        .expect("execute fresh emitted lossless modules");
    assert!(
        output.status.success(),
        "fresh lossless child failed: {}\n{}\n{}",
        output.status,
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    );
    let stdout = String::from_utf8(output.stdout).unwrap();
    assert_eq!(
        stdout.matches("3 passed; 0 failed;").count(),
        1,
        "all three fresh child tests executed: {stdout}"
    );
    println!(
        "lossless Rust emitted: ten modules, three child tests, original segmentation/child oracles and seven mutants; per-call isolation"
    );
}
