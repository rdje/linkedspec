//! SESSION-STARTUP-READING.62.2.1 — nonempty selection evaluates only a prefix.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

fn compiled(source: &str) -> CompiledSpec {
    let parsed = parse_spec_with_user_functions(source).expect("parse");
    validate(&parsed).expect("validate");
    compile(&parsed).expect("compile")
}

fn assert_routes(source: &str, expected: Value) {
    let spec = compiled(source);
    assert_eq!(
        Engine::new(spec.clone())
            .execute_value("x", &ExecutionOptions::new())
            .expect("native execute"),
        expected
    );
    let serialized = serde_json::to_string(&spec).expect("serialize");
    let restored: CompiledSpec = serde_json::from_str(&serialized).expect("restore");
    assert_eq!(
        Engine::new(restored)
            .execute_value("x", &ExecutionOptions::new())
            .expect("restored execute"),
        expected
    );
    let plan = [GeneratedPlanRow {
        label: "Top",
        family: "default",
    }];
    assert_eq!(
        execute_generated_parser_v2(
            &serialized,
            &plan,
            "x",
            "coalesce-nonempty-values.spec",
            GENERATED_SOURCE_CONTRACT
        )
        .expect("generated-plan execute"),
        expected
    );
}

#[test]
fn nonempty_selection_preserves_values_and_skips_later_effects() {
    // Aggregate controls retain reference compatibility; the public signature stays scalar.
    assert_routes(
        include_str!("../../../tests/fixtures/coalesce_nonempty_values.spec"),
        json!([
            "first",
            "chosen",
            0,
            false,
            "nested",
            "selected",
            null,
            "ABCD",
            [],
            {}
        ]),
    );
}

#[test]
fn nonempty_selection_skips_only_unneeded_runtime_failures() {
    let needed =
        compiled(r#"Top:: I { return(coalesce_nonempty("",{target=1; target[0]=2; "late"})); }"#);
    assert!(
        Engine::new(needed)
            .execute_value("x", &ExecutionOptions::new())
            .is_err()
    );
    assert_routes(
        r#"Top:: I { return(coalesce_nonempty("safe",{target=1; target[0]=2; "late"})); }"#,
        json!("safe"),
    );
}
