//! Public Engine probe owned by TYPE-REFERENCE-BOOK.1.2.23.2.14.
use linkedspec_core::{compiler::compile, types::CompiledSpec};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
fn main() {
    let source = include_str!(
        "../../../docs/checkpoints/type-operation-inventory/operand-snapshot-membership.spec"
    );
    let parsed = parse_spec_with_user_functions(source).expect("parse public probe");
    let compiled = compile(&parsed).expect("compile public probe");
    let value = Engine::new(compiled.clone())
        .execute_value("x", &ExecutionOptions::new())
        .expect("native public probe");
    println!("{}", serde_json::json!({"route":"native","value":value}));
    let serialized = serde_json::to_string(&compiled).expect("serialize probe");
    let restored: CompiledSpec = serde_json::from_str(&serialized).expect("restore probe");
    let value = Engine::new(restored)
        .execute_value("x", &ExecutionOptions::new())
        .expect("restored public probe");
    println!("{}", serde_json::json!({"route":"restored","value":value}));
    let plan = [GeneratedPlanRow {
        label: "Top",
        family: "default",
    }];
    let value = execute_generated_parser_v2(
        &serialized,
        &plan,
        "x",
        "operand-snapshot-membership.spec",
        GENERATED_SOURCE_CONTRACT,
    )
    .expect("generated-plan public probe");
    println!("{}", serde_json::json!({"route":"plan","value":value}));
}
