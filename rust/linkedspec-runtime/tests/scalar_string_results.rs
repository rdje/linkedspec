//! TYPE-REFERENCE-BOOK.1.2.23.3.19.2 — scalar String-helper result continuations.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

#[test]
fn existing_scalar_string_producers_preserve_values_unicode_identity_and_indices() {
    assert_consumers(
        r#"Top:: I { raw=[trim(" a "),lowercase("AB"),uppercase("ab"),replace_substr("a-b","-","_"),rm_prefix("pre_a","pre_"),rm_suffix("a_end","_end"),substr("abc",1),cat("a","b")];identity=[replace_substr(0,"","X"),rm_prefix(0,"x"),rm_suffix(false,"x")];values=["zero","one"];values[rm_prefix(0,"x")]="prefix";values[rm_suffix(1,"x")]="suffix";unicode=[lowercase("ΟΣ"),uppercase("Straße ﬃ"),substr("a🙂b",1,1)];source="a-b";order="";replaced=replace_substr({order=cat(order,"S");source},{order=cat(order,"O");source="changed";"-"},{order=cat(order,"N");"_"});return([raw,identity,values,unicode,replaced,order,source,cat(undef,"x")]); }"#,
        serde_json::json!([
            ["a", "ab", "AB", "a_b", "a", "a", "bc", "ab"],
            [0, 0, false],
            ["prefix", "suffix"],
            ["ος", "STRASSE FFI", "🙂"],
            "a_b",
            "SON",
            "changed",
            null
        ]),
    );
}

#[test]
fn scalar_string_results_preserve_kinds_bridges_shapes_and_source_snapshots() {
    assert_consumers(
        include_str!("../../../tests/fixtures/scalar_string_result_receiver_values.spec"),
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/scalar_string_result_receiver_values.json"
        ))
        .expect("scalar String result values"),
    );
}

#[test]
fn substring_null_and_fractional_inputs_preserve_guards_and_eager_operands() {
    assert_consumers(
        r#"Top:: I { order="";source=substr({order=cat(order,"S");undef},{order=cat(order,"I");0},{order=cat(order,"L");1});start=substr("abc",undef);return([source,start,undef.substr(0),"abc".substr(undef),substr("abc",0,undef),order,substr("abc",1.5),substr("abc",-1,1),substr("abc",0,1.5),substr("abc",0,-1),substr("abc",true)]); }"#,
        serde_json::json!([
            null, null, null, null, null, "SIL", "abc", "a", "", "", "bc"
        ]),
    );
}

#[test]
fn named_target_regex_mutation_keeps_its_dedicated_overload() {
    assert_consumers(
        r#"Top:: I { text="aba";substr(text,/a/,"x","g");other="aba";regex_subst(other,/a/,"y","");return([text,other]); }"#,
        serde_json::json!(["xbx", "yba"]),
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
            "scalar-string-results.spec",
            GENERATED_SOURCE_CONTRACT
        )
        .expect("generated-plan execute"),
        expected
    );
}
