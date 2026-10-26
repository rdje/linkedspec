//! TYPE-REFERENCE-BOOK.1.2.23.3.18.2 — defined-only default receivers.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

#[test]
fn existing_defined_defaults_preserve_kinds_laziness_copies_and_numeric_indices() {
    assert_consumers(
        r#"Top:: I { raw=[coalesce(undef,"fallback"),coalesce("","late"),coalesce(0,7),coalesce(false,true),coalesce(undef,undef),coalesce(undef,[2,3]),coalesce(undef,{"a":"a","b":"b"})];nested=[uppercase(trim(coalesce(undef," chosen "))),cat(coalesce(false,true),"!")];hits=0;lazy=coalesce("",{hits=num_add(hits,1);"late"},{target=1;target[0]=2;"bad"});items=["a","b"];chosen=coalesce(undef,items);items[0]="z";values=["zero","one"];values[coalesce(undef,1)]="updated";return([raw,nested,lazy,hits,chosen,items,values]); }"#,
        serde_json::json!([["fallback","",0,false,null,[2,3],{"a":"a","b":"b"}],["CHOSEN","0!"],"",0,["a","b"],["z","b"],["zero","updated"]]),
    );
}

#[test]
fn defined_default_receivers_preserve_actual_kinds_lazy_snapshots_and_boundaries() {
    assert_consumers(
        include_str!("../../../tests/fixtures/defined_default_receiver_values.spec"),
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/defined_default_receiver_values.json"
        ))
        .expect("defined default values"),
    );
}

#[test]
fn selected_scalar_defaults_and_malformed_shapes_skip_forbidden_effects() {
    assert_consumers(
        r#"Top:: I { order="";named=undef;flag=false;return([named.coalesce("kept").sorted(),[].first().coalesce("kept").sorted_values(),flag.coalesce(true).take({order=cat(order,"A");1}),{order=cat(order,"S");true}.coalesce().cat({order=cat(order,"C");"!"}),order]); }"#,
        serde_json::json!([null, null, null, null, ""]),
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
            "defined-defaults.spec",
            GENERATED_SOURCE_CONTRACT
        )
        .expect("generated-plan execute"),
        expected
    );
}
