//! TYPE-REFERENCE-BOOK.1.2.23.3.27.2 — readonly input/cursor result composition.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

fn assert_selection(source: &str, input: &str, expected: Value, child: bool) {
    let parsed = parse_spec_with_user_functions(source).expect("parse reader source");
    validate(&parsed).expect("validate reader source");
    let compiled = compile(&parsed).expect("compile reader source");
    let serialized = serde_json::to_string(&compiled).expect("serialize");
    let restored: CompiledSpec = serde_json::from_str(&serialized).expect("restore");
    let mut plan = vec![GeneratedPlanRow {
        label: "Top",
        family: "default",
    }];
    if child {
        plan.push(GeneratedPlanRow {
            label: "Value",
            family: "default",
        });
    }
    let native = Engine::new(compiled).execute_value(input, &ExecutionOptions::new());
    let restored = Engine::new(restored).execute_value(input, &ExecutionOptions::new());
    let generated = execute_generated_parser_v2(
        &serialized,
        &plan,
        input,
        "input-cursor-results.spec",
        GENERATED_SOURCE_CONTRACT,
    );
    eprintln!("native={native:?}\nrestored={restored:?}\ngenerated={generated:?}");
    assert_eq!(native.expect("native"), expected);
    assert_eq!(restored.expect("restored"), expected);
    assert_eq!(generated.expect("generated"), expected);
}

fn assert_action(action: &str, expected: Value) {
    let source = format!(
        "Top::\n -> Value .push\n LX {{return(copy(Top))}}\nValue:\n /name/\n /=/\n /Alpha/\n -> Value[2] {{{action}}}\n"
    );
    assert_selection(&source, "name=Alpha", expected, true);
}

#[test]
fn unchanged_frozen_reader_target() {
    assert_selection(
        include_str!("../../../tests/fixtures/input_cursor_result_values.spec"),
        "name=Alpha",
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/input_cursor_result_values.json"
        ))
        .expect("oracle"),
        true,
    );
}

#[test]
fn reader_with_returns_actual_kinds_and_restores_scope() {
    assert_action(
        r#"
 order="";value="outer";
 a=input_text().with() {return(value)}.take({order=cat(order,"A");1});
 b=input_len().with() {return(value)}.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});
 c=input_text().with() {order=cat(order,"W");return(["a","b"])}.last().uppercase();
 d=input_len().with() {return({"k":[false]})}.sorted_values().first().first();
 return([a,b,c,d,order,value]);
"#,
        json!([[null, null, "B", false, "W", "outer"]]),
    );
}

#[test]
fn reader_operands_defaults_number_indices_and_named_controls() {
    assert_action(
        r#"
 order="";start=5;width=5;
 result=input_slice({order=cat(order,"S");start},{order=cat(order,"W");width}).coalesce({order=cat(order,"F");"bad"}).cat({order=cat(order,"C");start=0;width=4;"!"});
 items=["zero","one"];index=input_len().coalesce({order=cat(order,"F");7}).sub(10);items[index]="updated";
 a=input_text();b=input_len();c=cursor_rest();d=cursor_rest_len();
 return([result,order,start,width,items,input_slice(0,0).coalesce("late").cat("!"),a.coalesce("late").split("=")[-1].uppercase(),b.coalesce(0).add(1),c.coalesce("late").cat("!"),d.coalesce(7).add(1)]);
"#,
        json!([[
            "Alpha!",
            "SWC",
            0,
            4,
            ["updated", "one"],
            "!",
            "ALPHA",
            11,
            "!",
            1
        ]]),
    );
}

#[test]
fn reader_counts_and_legacy_bound_flat_results() {
    assert_action(
        r#"
 thunk={|| return([false,["tail"]])};
 return([input_text().count(),input_len().count_keys(),input_text().with() {return(value)}.count(),thunk()[0],thunk()[-1][0].uppercase(),thunk()[9].count(),thunk()["missing"].count(),flat([1])[9].count(),input_text("ignored").count(),input_slice(0).count()]);
"#,
        json!([[null, null, null, false, "TAIL", 0, 0, 0, 10, 0]]),
    );
}
