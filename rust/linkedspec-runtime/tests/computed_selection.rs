//! TYPE-REFERENCE-BOOK.1.2.23.3.24.2 — ordinary computed bracket selection.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

fn assert_selection(source: &str, expected: Value) {
    let parsed = parse_spec_with_user_functions(source).expect("parse computed source");
    validate(&parsed).expect("validate computed source");
    let compiled = compile(&parsed).expect("compile computed source");
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
        "computed-selection.spec",
        GENERATED_SOURCE_CONTRACT,
    );
    eprintln!("native={native:?}\nrestored={restored:?}\ngenerated={generated:?}");
    assert_eq!(native.expect("native"), expected);
    assert_eq!(restored.expect("restored"), expected);
    assert_eq!(generated.expect("generated"), expected);
}

#[test]
fn unchanged_complete_shared_target() {
    assert_selection(
        include_str!("../../../tests/fixtures/computed_selection_values.spec"),
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/computed_selection_values.json"
        ))
        .expect("oracle"),
    );
}

#[test]
fn existing_call_result_source_checks_kind_before_operands() {
    assert_selection(
        r#"Top:: I {
        order="";
        a=array(false)[0].take({order=cat(order,"A");1});
        b=array([1])[0].set_key({order=cat(order,"K");"a"},{order=cat(order,"V");2});
        return([a,b,order]);
    }"#,
        json!([null, null, ""]),
    );
}

#[test]
fn function_scopes_snapshots_and_repeated_selected_bridges() {
    assert_selection(
        r#"fn echo(value) {return(value)}
fn select(text) {position=-1;return(echo(text.split(","))[position].uppercase())}
Top:: I {
    position=9;order="";source=["old","tail"];
    selected=echo({order=cat(order,"S");source})[{order=cat(order,"I");source=["new"];-1}].uppercase().cat({order=cat(order,"C");"!"});
    return([selected,order,source,select("a,b"),position,
        [undef][0].coalesce([{"items":["a","b"]}])[0]["items"][-1].uppercase()]);
}"#,
        json!(["TAIL!", "SIC", ["new"], "B", 9, "B"]),
    );
}

#[test]
fn scoped_with_preserves_selected_kind_and_rejects_wrong_operands() {
    assert_selection(
        r#"Top:: I {
        order="";
        a=array(false)[0].with() {return(value)}.take({order=cat(order,"A");1});
        b=array([2,1])[0].with() {return(value)}.sorted()[0].add(2);
        return([a,b,order]);
    }"#,
        json!([null, 3, ""]),
    );
}

#[test]
fn existing_bound_call_results_keep_signed_reads_and_kinds() {
    assert_selection(
        r#"Top:: I {
        thunk={|| return([false,["tail"]])};
        return([thunk()[0],thunk()[-1][0].uppercase(),thunk()[9].count(),thunk()["missing"].count()]);
    }"#,
        json!([false, "TAIL", 0, 0]),
    );
}

#[test]
fn regex_split_index_and_string_methods_preserve_unicode() {
    assert_selection(
        r#"Top:: I {return(["αXβ".split(/[x]/i)[-1].uppercase(),split("aXb",/[x]/i)[1].uppercase()])}"#,
        json!(["Β", "B"]),
    );
}
