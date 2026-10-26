//! TYPE-REFERENCE-BOOK.1.2.23.3.3.2 — count/length results feed actual-value methods.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::json;

#[test]
fn count_and_length_results_continue_without_recomputing_sources() {
    let source = r#"fn sized(values) { return(values.count().add(1)) }
Top:: I {
 items=[1,2]; saved=copy(items); meta={"a":1,"b":2}; order="";
 direct=[items.count().add(3),"abcd".length().add(2),meta.count_keys().mul(2)];
 empty=[ [].count().add(1), "".length().add(1), {}.count_keys().add(1) ];
 selected=[ [[1,2,3]].first().count().add(1), ["ab"].first().length().add(1), [{"a":1}].first().count_keys().add(1) ];
 pipeline=[items.sorted().length().add(1)," x ".trim().length().add(1),meta.sorted_values().count().add(1)];
 text=items.count().cat(" items").uppercase(); missing=[].first().length().add(1);
 from_function=sized(items); unicode_count="🙂a".length().add(1);
 counted={order=cat(order,"S"); items}.count().add({order=cat(order,"A"); items+=9; 3});
 raw="ab"; measured=raw.length().add({order=cat(order,"L"); raw="changed"; 3});
 keys={order=cat(order,"H"); meta}.count_keys().add({order=cat(order,"K"); meta["c"]=3; 3});
 invalid_effects=0;
 bad_count={invalid_effects=num_add(invalid_effects,1); [1]}.count({invalid_effects=num_add(invalid_effects,1); 1}).add(1);
 bad_length={invalid_effects=num_add(invalid_effects,1); "a"}.length({invalid_effects=num_add(invalid_effects,1); 1}).add(1);
 bad_keys={invalid_effects=num_add(invalid_effects,1); {"a":1}}.count_keys({invalid_effects=num_add(invalid_effects,1); 1}).add(1);
 return([direct,empty,selected,pipeline,text,missing,from_function,unicode_count,counted,measured,keys,order,items,saved,raw,meta,bad_count,bad_length,bad_keys,invalid_effects]);
}"#;
    let parsed = parse_spec_with_user_functions(source).expect("parse");
    validate(&parsed).expect("validate");
    let spec = compile(&parsed).expect("compile");
    let expected = json!([
        [5,6,4],[1,1,1],[4,3,2],[3,2,3],"2 ITEMS",null,3,3,5,5,5,"SALHK",
        [1,2,9],[1,2],"changed",{"a":1,"b":2,"c":3},null,null,null,0
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
            "count-length-receivers.spec",
            GENERATED_SOURCE_CONTRACT
        )
        .expect("generated-plan execute"),
        expected
    );
}
