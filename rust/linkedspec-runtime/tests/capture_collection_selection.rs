//! TYPE-REFERENCE-BOOK.1.2.23.3.25.2 — readonly capture result composition.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

fn assert_selection(source: &str, input: &str, expected: Value, child: bool) {
    let parsed = parse_spec_with_user_functions(source).expect("parse capture source");
    validate(&parsed).expect("validate capture source");
    let compiled = compile(&parsed).expect("compile capture source");
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
        "capture-collection-selection.spec",
        GENERATED_SOURCE_CONTRACT,
    );
    eprintln!("native={native:?}\nrestored={restored:?}\ngenerated={generated:?}");
    assert_eq!(native.expect("native"), expected);
    assert_eq!(restored.expect("restored"), expected);
    assert_eq!(generated.expect("generated"), expected);
}

#[test]
fn unchanged_frozen_capture_target() {
    assert_selection(
        include_str!("../../../tests/fixtures/capture_collection_selection_values.spec"),
        "name=Alpha",
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/capture_collection_selection_values.json"
        ))
        .expect("oracle"),
        true,
    );
}

#[test]
fn capture_aliases_and_with_check_kind_before_operands() {
    assert_selection(
        r#"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>name)/
 /=/
 /(?<value>Alpha)/
 -> Value[1] {separator=match_text()}
 -> Value[2] {
  order="";
  a=match_groups()[-1].with() {return(value)}.take({order=cat(order,"A");1});
  b=entry_named_map()["head"].set_key({order=cat(order,"K");"key"},{order=cat(order,"V");1});
  c=match_named_map()["value"].take({order=cat(order,"C");1});
  return([a,b,c,order]);
 }"#,
        "name=Alpha",
        json!([[null, null, null, ""]]),
        true,
    );
}

#[test]
fn capture_text_kinds_compaction_and_static_helper_names() {
    assert_selection(
        r#"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>0)(?<empty>)(?<missing>x)?/
 /=/
 /(?<value>Alpha)(?<empty>)(?<missing>x)?/
 -> Value[1] {separator=match_text()}
 -> Value[2] {
  entry_groups={|| return(["shadow"]) };
  match_map={|| return({"value":"shadow"}) };
  return([entry_groups()[0],entry_groups()[1],entry_groups()[2].coalesce("missing"),entry_map()["empty"],match_groups()[-1],match_map()["value"],entry_named_map()["head"],match_named_map()["empty"]]);
 }"#,
        "0=Alpha",
        json!([["0", "", "missing", "", "", "Alpha", "0", ""]]),
        true,
    );
}

#[test]
fn missing_capture_results_are_guarded_and_legacy_sources_keep_counts() {
    assert_selection(
        r#"Top:: I {
 thunk={|| return([false,["tail"]])};
 return([entry_groups()[0].count(),entry_map()["head"].count(),match_groups()[0].count(),match_map()["value"].count(),entry_named_map()["head"].count(),match_named_map()["value"].count(),thunk()[0],thunk()[-1][0].uppercase(),thunk()[9].count(),thunk()["missing"].count(),cursor_rest()[0].count(),flat([1])[9].count()]);
}"#,
        "x",
        json!([
            null, null, null, null, null, null, false, "TAIL", 0, 0, 0, 0
        ]),
        false,
    );
}
