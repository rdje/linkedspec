//! TYPE-REFERENCE-BOOK.1.2.23.3.26.2 — inline conditional result selection.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

fn assert_selection(source: &str, expected: Value) {
    let parsed = parse_spec_with_user_functions(source).expect("parse conditional source");
    validate(&parsed).expect("validate conditional source");
    let compiled = compile(&parsed).expect("compile conditional source");
    let serialized = serde_json::to_string(&compiled).expect("serialize");
    let restored: CompiledSpec = serde_json::from_str(&serialized).expect("restore");
    let native = Engine::new(compiled).execute_value("x", &ExecutionOptions::new());
    let restored = Engine::new(restored).execute_value("x", &ExecutionOptions::new());
    let generated = execute_generated_parser_v2(
        &serialized,
        &[GeneratedPlanRow {
            label: "Top",
            family: "default",
        }],
        "x",
        "conditional-selection.spec",
        GENERATED_SOURCE_CONTRACT,
    );
    eprintln!("native={native:?}\nrestored={restored:?}\ngenerated={generated:?}");
    assert_eq!(native.expect("native"), expected);
    assert_eq!(restored.expect("restored"), expected);
    assert_eq!(generated.expect("generated"), expected);
}

#[test]
fn unchanged_frozen_conditional_target() {
    assert_selection(
        include_str!("../../../tests/fixtures/conditional_selection_values.spec"),
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/conditional_selection_values.json"
        ))
        .expect("oracle"),
    );
}

#[test]
fn conditional_selection_with_rejects_incompatible_operands() {
    assert_selection(
        r#"Top:: I {
 order="";
 a=if(true,[false],[])[0].with() {return(value)}.take({order=cat(order,"A");1});
 b=switch("k",case("k",[[1]]))[0].set_key({order=cat(order,"K");"key"},{order=cat(order,"V");1});
 return([a,b,order]);
}"#,
        json!([null, null, ""]),
    );
}

#[test]
fn conditional_lazy_order_and_block_local_return_are_preserved() {
    assert_selection(
        r#"Top:: I {
 order="";
 selected=if({order=cat(order,"C");false},["bad"],
  elseif({order=cat(order,"E");true},{order=cat(order,"T");return([{"items":["a","b"]}]);order="bad"}),
  else({order=cat(order,"F");["bad"]}))[0]["items"][-1].uppercase().cat({order=cat(order,"M");"!"});
 return([selected,order]);
}"#,
        json!(["B!", "CETM"]),
    );
}

#[test]
fn missing_inline_results_and_legacy_header_bound_flat_counts() {
    assert_selection(
        r#"Top:: I {
 thunk={|| return([false,["tail"]])};
 return([if(false,[1])[0].count(),switch("other",case("k",[1]))[0].count(),thunk()[0],thunk()[-1][0].uppercase(),thunk()[9].count(),thunk()["missing"].count(),if(true)[0].count(),switch("k")[0].count(),flat([1])[9].count()]);
}"#,
        json!([null, null, false, "TAIL", 0, 0, 0, 0, 0]),
    );
}
