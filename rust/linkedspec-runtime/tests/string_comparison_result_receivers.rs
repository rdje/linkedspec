//! TYPE-REFERENCE-BOOK.1.2.23.3.12.2 — explicit String comparison receivers.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

#[test]
fn existing_comparison_producer_domains() {
    let source = r#"Top:: I { word="abc"; zero_text="0"; raw=[str_eq(word,"abc"),str_ne(word,"z"),str_gt(word,"aaa"),str_ge(word,"abc"),str_lt(word,"zzz"),str_le(word,"abc"),str_eq(word,"z"),str_ne(word,"abc"),str_gt(word,"zzz"),str_ge(word,"zzz"),str_lt(word,"aaa"),str_le(word,"aaa")]; order=""; null_result=str_eq({order=cat(order,"S");undef},{order=cat(order,"O");"a"});return({"raw":raw,"boundaries":[str_eq(undef,""),str_eq("",undef),str_eq("",""),str_eq("0",zero_text),str_eq(zero_text,"0")],"text":[cat(str_eq("a","b"),"!"),cat(coalesce_nonempty(str_eq("a","b"),"late"),"!")],"null_result":null_result,"order":order}) }"#;
    let parsed = parse_spec_with_user_functions(source).expect("parse producer");
    let spec = compile(&parsed).expect("compile producer");
    let actual = Engine::new(spec)
        .execute_value("x", &ExecutionOptions::new())
        .expect("execute producer");
    let expected = serde_json::json!({"raw":[true,true,true,true,true,true,false,false,false,false,false,false],"boundaries":[true,true,true,true,true],"null_result":false,"order":"SO","text":["0!","0!"]});
    if actual != expected {
        println!("comparison_producers:{}", actual);
    }
    assert_eq!(actual, expected);
}

#[test]
fn string_comparison_results_preserve_kinds_shapes_and_operand_order() {
    let source =
        include_str!("../../../tests/fixtures/string_comparison_result_receiver_values.spec");
    let parsed = parse_spec_with_user_functions(source).expect("parse");
    validate(&parsed).expect("validate");
    let spec = compile(&parsed).expect("compile");
    let expected: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/string_comparison_result_receiver_values.json"
    ))
    .expect("expected fixture");
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
            "string-comparison-result-receivers.spec",
            GENERATED_SOURCE_CONTRACT
        )
        .expect("generated-plan execute"),
        expected
    );
}
