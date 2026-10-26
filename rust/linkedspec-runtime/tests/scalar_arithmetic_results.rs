//! TYPE-REFERENCE-BOOK.1.2.23.3.16.2 — scalar arithmetic result continuations.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

#[test]
fn existing_scalar_arithmetic_producers_keep_kinds_domains_and_snapshots() {
    assert_consumers(
        r#"Top:: I { raw=[num_abs(-3),num_floor(3.7),num_ceil(3.2),num_round(2.5),num_add(2,3),num_sub(5,2),num_mul(2,3),num_div(7,2),num_mod(7,3),num_clamp(12,0,10),num_min(8,3),num_max(2,5)];aliases=[abs(-3),floor(3.7),ceil(3.2),round(2.5),add(2,3),sub(5,2),mul(2,3),div(7,2),mod(7,3),clamp(12,0,10),min(8,3),max(2,5)];symbols=[+(2,3),-(5,2),*(2,3),/(7,2),%(7,3)];invalid=[num_div(2,0),num_mod(2.5,2),num_clamp(2,3,1),num_add(false,1),num_add(undef,1),num_add("x",1),num_add([],1),num_add({},1)];text=[cat(num_add(2,3),"!"),cat(coalesce_nonempty(num_add(0,0),"late"),"!"),num_add(coalesce_nonempty(num_div(2,0),7),1),num_add("-.5",1)];source=2;order="";effected=cat(num_add({order=cat(order,"S");source},{order=cat(order,"O");source=9;3}),{order=cat(order,"C");source=undef;"!"});return({"raw":raw,"aliases":aliases,"symbols":symbols,"invalid":invalid,"text":text,"effected":effected,"order":order,"source":source}); }"#,
        serde_json::json!({"raw":[3,3,4,3,5,3,6,3.5,1,10,3,5],"aliases":[3,3,4,3,5,3,6,3.5,1,10,3,5],"symbols":[5,3,6,3.5,1],"invalid":[null,null,null,null,null,null,null,null],"text":["5!","0!",8,0.5],"effected":"5!","order":"SOC","source":null}),
    );
}

#[test]
fn scalar_arithmetic_results_preserve_kinds_shapes_bridges_and_operand_order() {
    assert_consumers(
        include_str!("../../../tests/fixtures/scalar_arithmetic_result_receiver_values.spec"),
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/scalar_arithmetic_result_receiver_values.json"
        ))
        .expect("expected scalar arithmetic results"),
    );
}

#[test]
fn scalar_arithmetic_and_scalar_min_results_remain_array_write_indexes() {
    assert_consumers(
        r#"Top:: I { values=["zero","one","two","three"];values[2.add(1)]="first";values[8.min("3")]="updated";return(values) }"#,
        serde_json::json!(["zero", "one", "two", "updated"]),
    );
}

#[test]
fn numeric_string_prefixes_keep_arithmetic_and_comparison_domains() {
    assert_consumers(
        r#"Top:: I { return([" 2 ".trim().add(3).cat("!")," 2 ".trim().eq(2).cat("!")," X ".trim().eq(2).coalesce_nonempty(7).add(1)]) }"#,
        serde_json::json!(["5!", "1!", 8]),
    );
}

fn assert_consumers(source: &str, expected: Value) {
    let parsed = parse_spec_with_user_functions(source).expect("parse");
    validate(&parsed).expect("validate");
    let spec = compile(&parsed).expect("compile");
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
            "scalar-arithmetic-results.spec",
            GENERATED_SOURCE_CONTRACT
        )
        .expect("generated-plan execute"),
        expected
    );
}
