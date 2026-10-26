//! SESSION-STARTUP-READING.62.2.2 — documented receiver defaults stay lazy.
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
            "coalesce-receiver-values.spec",
            GENERATED_SOURCE_CONTRACT
        )
        .expect("generated-plan execute"),
        expected
    );
}

#[test]
fn documented_receiver_defaults_preserve_values_and_effect_order() {
    assert_routes(
        include_str!("../../../tests/fixtures/coalesce_receiver_values.spec"),
        json!([
            "first", "CHOSEN", "SELECTED", "empty", 0, false, null, "A", "ABCDEF"
        ]),
    );
}

#[test]
fn receiver_defaults_skip_only_unneeded_runtime_failures() {
    let needed =
        compiled(r#"Top:: I { return("".coalesce_nonempty({target=1; target[0]=2; "late"})); }"#);
    assert!(
        Engine::new(needed)
            .execute_value("x", &ExecutionOptions::new())
            .is_err()
    );
    assert_routes(
        r#"Top:: I { return("safe".coalesce_nonempty({target=1; target[0]=2; "late"})); }"#,
        json!("safe"),
    );
    assert_routes(
        r#"Top:: I { return(["safe"].first().coalesce_nonempty({target=1; target[0]=2; "late"})); }"#,
        json!("safe"),
    );
}
