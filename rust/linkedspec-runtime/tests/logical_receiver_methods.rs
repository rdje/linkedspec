//! TYPE-REFERENCE-BOOK.1.2.23.3.23.2 — eager logical receiver methods.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

#[test]
fn existing_eager_logical_producers_keep_real_bool_and_typed_truth() {
    assert_methods(
        r#"Top:: I { return([and(true,false),or(false,true),not(false),not("0"),not(0),not([]),not([null]),not({}),not({"key":null})]); }"#,
        json!([false, true, true, false, true, true, false, true, false]),
    );
}

#[test]
fn generic_logical_methods_use_actual_sources_rhs_and_result_kinds() {
    assert_methods(
        include_str!("../../../tests/fixtures/logical_receiver_method_values.spec"),
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/logical_receiver_method_values.json"
        ))
        .expect("logical method oracle"),
    );
}

#[test]
fn malformed_new_method_shapes_reject_before_all_effects() {
    assert_methods(
        r#"Top:: I { order="";a={order=cat(order,"S");true}.and().cat({order=cat(order,"C");"!"});b={order=cat(order,"S");false}.or().cat({order=cat(order,"C");"!"});c={order=cat(order,"S");false}.not({order=cat(order,"A");true}).cat({order=cat(order,"C");"!"});d={order=cat(order,"S");false}.not(fail("must-not-run"));return([a,b,c,d,order]); }"#,
        json!([null, null, null, null, ""]),
    );
}

#[test]
fn valid_logical_prefixes_keep_effects_and_skip_wrong_consumers() {
    assert_methods(
        r#"Top:: I { order="";a={order=cat(order,"S");false}.and({order=cat(order,"R");true}).take({order=cat(order,"A");1});first=[a,order];order="";b={order=cat(order,"S");false}.or({order=cat(order,"R");true}).cat({order=cat(order,"C");"!"}).set_key({order=cat(order,"K");"key"},{order=cat(order,"V");1});return([first,[b,order]]); }"#,
        json!([[null, "SR"], [null, "SRC"]]),
    );
}

#[test]
fn existing_with_scope_restores_before_logical_result_rejection() {
    assert_methods(
        r#"Top:: I { value="outer";order="";a="x".with() {order=cat(order,"W");return(false)}.not();return([a,order,value]); }"#,
        json!([true, "W", "outer"]),
    );
    assert_methods(
        r#"Top:: I { value="outer";order="";a="x".with() {order=cat(order,"W");return(false)}.not().take({order=cat(order,"A");1});return([a,order,value]); }"#,
        json!([null, "W", "outer"]),
    );
}

#[test]
fn existing_with_prefix_keeps_scalar_copy_boundary_and_container_recovery() {
    assert_methods(
        r#"Top:: I { scalar="x".with() {return(false)}.not().copy();hash="x".with() {return(false)}.not().add(1).coalesce({"key":7}).copy().sorted_values().first().add(1);array="x".with() {return(false)}.not().add(1).coalesce([7]).copy().first().add(1);return([scalar,hash,array]); }"#,
        json!([null, 8, 8]),
    );
}

#[test]
fn invalid_free_sources_keep_typed_errors_through_valid_new_methods() {
    for (helper, arity, expression) in [
        ("and", 0, "and().not()"),
        (
            "not",
            2,
            r#"not({fail("must-not-run")},{fail("must-not-run")}).or(true)"#,
        ),
    ] {
        let source = format!("Top:: I {{ return({expression}) }}");
        let parsed = parse_spec_with_user_functions(&source).expect("parse");
        validate(&parsed).expect("validate");
        let compiled = compile(&parsed).expect("compile");
        let serialized = serde_json::to_string(&compiled).expect("serialize");
        let restored: CompiledSpec = serde_json::from_str(&serialized).expect("restore");
        for spec in [compiled, restored] {
            let error = Engine::new(spec)
                .execute_value_with_diagnostics("x", &ExecutionOptions::new())
                .expect_err("typed source error");
            let diagnostic = error.diagnostic();
            assert_eq!(diagnostic.code.as_deref(), Some("helper_arity_mismatch"));
            assert_eq!(diagnostic.helper_name.as_deref(), Some(helper));
            assert_eq!(diagnostic.actual_arity, Some(arity));
        }
        let error = execute_generated_parser_v2(
            &serialized,
            &[GeneratedPlanRow {
                label: "Top",
                family: "default",
            }],
            "x",
            "logical-method-source-errors.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .expect_err("generated typed source error")
        .to_string();
        assert!(error.contains("helper_arity_mismatch"), "{error}");
        assert!(error.contains(&format!("helper_name={helper}")), "{error}");
        assert!(error.contains(&format!("actual_arity={arity}")), "{error}");
    }
}

fn assert_methods(source: &str, expected: Value) {
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
            "logical-receiver-methods.spec",
            GENERATED_SOURCE_CONTRACT
        )
        .expect("generated-plan execute"),
        expected
    );
}
