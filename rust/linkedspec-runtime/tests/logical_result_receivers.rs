//! TYPE-REFERENCE-BOOK.1.2.23.3.17.2 — logical Boolean result continuations.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::Value;

#[test]
fn existing_logical_producers_keep_boolean_kinds_eager_truth_and_numeric_rejection() {
    assert_consumers(
        r#"Top:: I { raw=[and(true),and(false),or(false,true),or(false,0),not(false),not(true)];nested=[cat(and(true),"!"),cat(and(false),"!"),cat(or(false,true),"!"),cat(or(false,0),"!"),cat(not(false),"!"),cat(not(true),"!")];truthiness=[and("0"),or("false"),not([]),not({}),not([undef]),not({"a":undef})];numeric=[num_add(and(true),1),num_add(or(false),1)];source=true;order="";effected=cat(and({order=cat(order,"L");source},{order=cat(order,"R");source=false;false}),{order=cat(order,"C");source=undef;"!"});return({"raw":raw,"nested":nested,"truthiness":truthiness,"numeric":numeric,"effected":effected,"order":order,"source":source}); }"#,
        serde_json::json!({"raw":[true,false,true,false,true,false],"nested":["1!","0!","1!","0!","1!","0!"],"truthiness":[true,true,true,true,false,false],"numeric":[null,null],"effected":"0!","order":"LRC","source":null}),
    );
}

#[test]
fn logical_boolean_results_preserve_shapes_bridges_and_eager_snapshots() {
    assert_consumers(
        include_str!("../../../tests/fixtures/logical_result_receiver_values.spec"),
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/logical_result_receiver_values.json"
        ))
        .expect("logical result values"),
    );
}

#[test]
fn incompatible_consumers_keep_logical_sources_and_skip_their_own_operands() {
    assert_consumers(
        include_str!("../../../tests/fixtures/logical_rejected_consumer_effects.spec"),
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/logical_rejected_consumer_effects.json"
        ))
        .expect("rejected logical effects"),
    );
}

#[test]
fn logical_source_arity_still_precedes_unknown_or_effectful_operands() {
    for (helper, arity, call) in [
        ("and", 0, "and()"),
        ("or", 0, "or()"),
        ("not", 0, "not()"),
        (
            "not",
            2,
            r#"not({fail("must-not-run")},{fail("must-not-run")})"#,
        ),
        (
            "not",
            2,
            r#"not({print("must-not-run");true},{print("must-not-run");false})"#,
        ),
    ] {
        let source = format!("Top:: I {{ return({call}.cat(\"!\")) }}");
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
            assert_eq!(diagnostic.rule_label.as_deref(), Some("Top"));
        }
        let plan = [GeneratedPlanRow {
            label: "Top",
            family: "default",
        }];
        let error = execute_generated_parser_v2(
            &serialized,
            &plan,
            "x",
            "logical-results.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .expect_err("generated source error");
        let detail = error.to_string();
        assert!(detail.contains("helper_arity_mismatch"), "{detail}");
        assert!(
            detail.contains(&format!("helper_name={helper}")),
            "{detail}"
        );
        assert!(
            detail.contains(&format!("actual_arity={arity}")),
            "{detail}"
        );
    }
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
            "logical-results.spec",
            GENERATED_SOURCE_CONTRACT
        )
        .expect("generated-plan execute"),
        expected
    );
}
