//! TYPE-REFERENCE-BOOK.1.2.23.3.31.6.1 — distinct callback invocation and real-cycle controls.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};
fn routes(source: &str, input: &str, child: bool) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse with result");
    validate(&parsed).expect("validate with result");
    let compiled = compile(&parsed).expect("compile with result");
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
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
    vec![
        Engine::new(compiled)
            .execute_value(input, &ExecutionOptions::new())
            .map_err(|error| error.to_string()),
        Engine::new(restored)
            .execute_value(input, &ExecutionOptions::new())
            .map_err(|error| error.to_string()),
        execute_generated_parser_v2(
            &serialized,
            &plan,
            input,
            "with-hash-results.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|error| error.to_string()),
    ]
}
fn check(source: &str, input: &str, expected: Value, child: bool) {
    for (route, value) in routes(source, input, child).into_iter().enumerate() {
        eprintln!("CALLBACK_IDENTITY route{route} {value:?}");
        assert_eq!(
            value.expect("execute with result"),
            expected,
            "route{route}"
        );
    }
}
fn top(body: &str) -> String {
    format!("Top:: I {{{body}}}")
}
fn reject(body: &str, code: &str, identity: &str, cycle: &str) {
    for (route, result) in routes(&top(body), "x", false).into_iter().enumerate() {
        eprintln!("CALLBACK_ERROR route{route} {result:?}");
        let error = result.expect_err("callback must reject this exact failure");
        assert!(error.contains(code), "{error}");
        assert!(error.contains(identity), "{error}");
        if !cycle.is_empty() {
            assert!(error.contains(cycle), "{error}");
        }
    }
}
#[test]
fn distinct_nested_helper_callbacks_and_outer_scope() {
    check(
        &top(
            r#"value="outer";result=with("outside"){return(with("inside"){return(value)})};return([result,value]);"#,
        ),
        "x",
        json!(["inside", "outer"]),
        false,
    );
}
#[test]
fn distinct_nested_tree_callbacks() {
    check(
        &top(r#"return([1].map_leaves(){return([value].map_leaves(){return(value)})})"#),
        "x",
        json!([[1]]),
        false,
    );
}
#[test]
fn helper_bound_cycle_keeps_the_binding_identity() {
    reject(
        r#"calls=0;cb={|v|calls=num_add(calls,1);return(if(num_lt(calls,4),with(v,cb),"escaped"))};return(cb("x"));"#,
        "codeblock_recursion_unsupported",
        "callable_name=\"cb\"",
        r#"cycle=["cb", "cb"]"#,
    );
}
#[test]
fn receiver_bound_cycle_keeps_the_binding_identity() {
    reject(
        r#"calls=0;cb={|v|calls=num_add(calls,1);return(if(num_lt(calls,4),v.with(cb),"escaped"))};return(cb("x"));"#,
        "codeblock_recursion_unsupported",
        "callable_name=\"cb\"",
        r#"cycle=["cb", "cb"]"#,
    );
}
#[test]
fn opaque_helper_value_cannot_escape_active_cycle_detection() {
    reject(
        r#"calls=0;cb={|v|calls=num_add(calls,1);return(if(num_lt(calls,4),with(v,coalesce(cb,cb)),"escaped"))};return(cb("x"));"#,
        "codeblock_recursion_unsupported",
        "callable_name=\"cb\"",
        r#"cycle=["cb", "cb"]"#,
    );
}
#[test]
fn anonymous_context_keeps_unknown_helper_diagnostics() {
    reject(
        r#"return(with("x"){return(missing())})"#,
        "unknown_helper",
        "name=\"missing\"",
        "",
    );
}
#[test]
fn direct_and_mutual_cycles_keep_their_order() {
    reject(
        r#"calls=0;reader={||calls=num_add(calls,1);return(if(num_lt(calls,4),reader(),"escaped"))};return(reader());"#,
        "codeblock_recursion_unsupported",
        "callable_name=\"reader\"",
        r#"cycle=["reader", "reader"]"#,
    );
    reject(
        r#"calls=0;a={|v|calls=num_add(calls,1);return(if(num_lt(calls,4),b(v),"escaped"))};b={|v|return(a(v))};return(a("x"));"#,
        "codeblock_recursion_unsupported",
        "callable_name=\"a\"",
        r#"cycle=["a", "b", "a"]"#,
    );
}

#[test]
fn helper_cycle_projects_the_bound_diagnostic_identity() {
    let source = top(
        r#"calls=0;cb={|v|calls=num_add(calls,1);return(if(num_lt(calls,4),with(v,cb),"escaped"))};return(cb("x"));"#,
    );
    let parsed = parse_spec_with_user_functions(&source).unwrap();
    validate(&parsed).unwrap();
    let compiled = compile(&parsed).unwrap();
    let restored: CompiledSpec =
        serde_json::from_str(&serde_json::to_string(&compiled).unwrap()).unwrap();
    for candidate in [compiled, restored] {
        let failure = Engine::new(candidate)
            .execute_with_diagnostics("x")
            .unwrap_err();
        let diagnostic = failure.diagnostic();
        assert_eq!(
            diagnostic.code.as_deref(),
            Some("codeblock_recursion_unsupported")
        );
        assert_eq!(diagnostic.callable_name.as_deref(), Some("cb"));
        assert_eq!(diagnostic.cycle, Some(vec!["cb".into(), "cb".into()]));
        assert_eq!(diagnostic.stage, "callable_codeblock_invocation");
    }
}
