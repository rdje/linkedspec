//! TYPE-REFERENCE-BOOK.1.2.23.3.1.2 — selected-value receiver transitions.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::json;

#[test]
fn selected_values_continue_using_their_actual_kinds() {
    let source = r#"fn clone_first(values) { return(values.first().copy()) }
Top::
 I {
  nested=[[3,1],[2]]; saved=copy(nested); rows=[{"b":2,"a":1}];
  copied_array=clone_first(nested); copied_hash=clone_first(rows);
  repeated=[[[4,1],[2]]].first().first().sorted().last().add(2);
  order=""; calls=0;
  computed={order=cat(order,"S"); [{"a":1}]}.first().set_key("b",{order=cat(order,"V"); calls=num_add(calls,1); 2});
  invalid_effects=0;
  invalid={invalid_effects=num_add(invalid_effects,1); [" a "]}.first({invalid_effects=num_add(invalid_effects,1); 1}).trim();
  return([
   " a : b ".split(/:/).first().trim().uppercase(),
   [" A "," B "].last().trim().lowercase(),
   [[3,1],[2]].first().sorted().last().add(4),
   [{"b":2,"a":1}].first().sorted_keys().last().uppercase(),
   [2,3].last().mul(4),
   [].first().trim(),copied_array,copied_hash,repeated,computed,order,calls,
   nested,saved,rows,invalid,invalid_effects,[[3,1]].first().min(),[3].first().min(2),
   trim(undef),trim(""),
   [[3,1],[2]].first().copy().sorted().last().add(4),
   [{"b":2,"a":1}].first().copy().sorted_keys().last().uppercase()
  ]);
 }
"#;
    let parsed = parse_spec_with_user_functions(source).expect("parse");
    validate(&parsed).expect("validate");
    let spec = compile(&parsed).expect("compile");
    let expected = json!([
        "A", "b", 7, "B", 12, null, [3, 1], {"a": 1, "b": 2}, 6,
        {"a": 1, "b": 2}, "SV", 1, [[3, 1], [2]], [[3, 1], [2]],
        [{"a": 1, "b": 2}], null, 0, 1, 2, null, "", 7, "B"
    ]);
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
            "selected-value-receivers.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .expect("generated-plan execute"),
        expected
    );
}
