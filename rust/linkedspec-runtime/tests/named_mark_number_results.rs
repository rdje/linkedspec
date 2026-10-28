//! TYPE-REFERENCE-BOOK.1.2.23.3.34.2 / 43.1 — named Number values and dynamic caller mark scope.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

fn routes(source: &str, input: &str) -> Value {
    let parsed = parse_spec_with_user_functions(source).expect("parse named mark source");
    validate(&parsed).expect("validate named mark source");
    let compiled = compile(&parsed).expect("compile named mark source");
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    let plan: Vec<_> = compiled
        .rules
        .iter()
        .map(|rule| GeneratedPlanRow {
            label: match rule.label.as_str() {
                "Top" => "Top",
                "Value" => "Value",
                "Other" => "Other",
                "First" => "First",
                "Second" => "Second",
                label => panic!("unowned named-mark test rule: {label}"),
            },
            family: classify_generated_rule_family(rule).contract_name(),
        })
        .collect();
    let mut result = serde_json::Map::new();
    for (route, value) in [
        (
            "native",
            Engine::new(compiled)
                .execute_value(input, &ExecutionOptions::new())
                .map_err(|e| e.to_string()),
        ),
        (
            "restored",
            Engine::new(restored)
                .execute_value(input, &ExecutionOptions::new())
                .map_err(|e| e.to_string()),
        ),
        (
            "plan",
            execute_generated_parser_v2(
                &serialized,
                &plan,
                input,
                "named-mark-number.spec",
                GENERATED_SOURCE_CONTRACT,
            )
            .map_err(|e| e.to_string()),
        ),
    ] {
        result.insert(
            route.to_string(),
            match value {
                Ok(value) => json!({"value":value}),
                Err(error) => json!({"error":error}),
            },
        );
    }
    Value::Object(result)
}
fn cases() -> Vec<(&'static str, &'static str, &'static str)> {
    vec![
        (
            "shared",
            include_str!("../../../tests/fixtures/named_mark_number_values.spec"),
            "αβ:cat",
        ),
        (
            "producers",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return([mark_pos(finish),mark_line(finish),mark_col(finish),capture_len_from(begin),capture_rest_len_from(begin),capture_until_cursor_len_from(begin),capture_len_between(begin,finish)])}
"###,
            "αβ:cat",
        ),
        (
            "missing_producers",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return([mark_pos(absent),mark_line(absent),mark_col(absent),capture_len_from(absent),capture_rest_len_from(absent),capture_until_cursor_len_from(absent),capture_len_between(absent,finish),capture_len_between(begin,absent)])}
"###,
            "αβ:cat",
        ),
        (
            "symbolic_shadow",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);begin="finish";finish="begin";return([capture_len_between(begin,finish),mark_pos(begin),mark_pos(finish)])}
"###,
            "αβ:cat",
        ),
        (
            "quoted_names",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return([mark_pos("finish"),capture_len_between("begin","finish")])}
"###,
            "αβ:cat",
        ),
        (
            "evaluated_name",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(mark_pos(cat("fin","ish")))}
"###,
            "αβ:cat",
        ),
        (
            "legacy_bound",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);p=mark_pos(finish);order="";a=p.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=p.take({order=cat(order,"T");1});c=p.add(0).set_key({order=cat(order,"X");"k"},{order=cat(order,"Y");1});return([a,b,c,order])}
"###,
            "αβ:cat",
        ),
        (
            "snapshot_bound",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);order="";p=mark_pos(finish);snapshot=p.cat({order=cat(order,"S");"!"});clear_mark(finish);return([snapshot,mark_pos(finish),mark_pos(begin),order])}
"###,
            "αβ:cat",
        ),
        (
            "direct_mark_pos",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(mark_pos(finish).coalesce(0).cat("!"))}
"###,
            "αβ:cat",
        ),
        (
            "direct_mark_line",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(mark_line(finish).coalesce(0).cat("!"))}
"###,
            "αβ:cat",
        ),
        (
            "direct_mark_col",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(mark_col(finish).coalesce(0).cat("!"))}
"###,
            "αβ:cat",
        ),
        (
            "direct_capture_len_from",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(capture_len_from(begin).coalesce(0).cat("!"))}
"###,
            "αβ:cat",
        ),
        (
            "direct_capture_until_cursor_len_from",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(capture_until_cursor_len_from(begin).coalesce(0).cat("!"))}
"###,
            "αβ:cat",
        ),
        (
            "direct_capture_rest_len_from",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(capture_rest_len_from(begin).coalesce(0).cat("!"))}
"###,
            "αβ:cat",
        ),
        (
            "direct_capture_len_between",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(capture_len_between(begin,finish).coalesce(0).cat("!"))}
"###,
            "αβ:cat",
        ),
        (
            "direct_legacy",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);order="";a=mark_pos(finish).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});b=mark_pos(finish).take({order=cat(order,"T");1});return([a,b,order])}
"###,
            "αβ:cat",
        ),
        (
            "other_label",
            r###"Top::
 -> Other .push
 LX {return(copy(Top))}
Other:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Other[2] {mark_input_start(left);mark_input_end(right);return([mark_pos(right).coalesce(0).sub(1),mark_line(right).coalesce(0).add(1),mark_col(right).coalesce(0).cat("!"),capture_len_from(left).coalesce(0).cat(":tail").split(":")[-1].uppercase(),capture_rest_len_from(left).coalesce(0).add(1),capture_until_cursor_len_from(left).coalesce(0).sub(1),capture_len_between(left,right).coalesce(0).add(1)])}
"###,
            "αβ:cat",
        ),
        (
            "partial_shared",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return([mark_pos(finish).coalesce(0).sub(1),mark_line(finish).coalesce(0).add(1),mark_col(finish).coalesce(0).cat("!"),capture_len_from(begin).coalesce(0).cat(":tail").split(":")[-1].uppercase(),capture_rest_len_from(begin).coalesce(0).add(1),capture_until_cursor_len_from(begin).coalesce(0).sub(1),capture_len_between(begin,finish).coalesce(0).add(1)])}
"###,
            "αβ:catTAIL",
        ),
        (
            "zero_missing_reversed",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);order="";a=mark_pos(begin).coalesce({order=cat(order,"Z");9}).add(1);b=capture_len_between(begin,begin).coalesce({order=cat(order,"E");9}).add(1);c=mark_pos(absent).coalesce({order=cat(order,"F");7}).add(1);d=capture_len_between(finish,begin).coalesce(9).add(1);return([a,b,c,d,order])}
"###,
            "αβ:cat",
        ),
        (
            "function_mark_pos",
            r###"fn forbidden(){return(mark_pos(finish).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
"###,
            "αβ:cat",
        ),
        (
            "function_mark_line",
            r###"fn forbidden(){return(mark_line(finish).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
"###,
            "αβ:cat",
        ),
        (
            "function_mark_col",
            r###"fn forbidden(){return(mark_col(finish).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
"###,
            "αβ:cat",
        ),
        (
            "function_capture_len_from",
            r###"fn forbidden(){return(capture_len_from(begin).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
"###,
            "αβ:cat",
        ),
        (
            "function_capture_until_cursor_len_from",
            r###"fn forbidden(){return(capture_until_cursor_len_from(begin).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
"###,
            "αβ:cat",
        ),
        (
            "function_capture_rest_len_from",
            r###"fn forbidden(){return(capture_rest_len_from(begin).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
"###,
            "αβ:cat",
        ),
        (
            "function_capture_len_between",
            r###"fn forbidden(){return(capture_len_between(begin,finish).coalesce(0).cat("!"))}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(forbidden())}
"###,
            "αβ:cat",
        ),
        (
            "literal_callback_all",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);cb={||return([mark_pos(finish).coalesce(0).cat("!"),mark_line(finish).coalesce(0).cat("!"),mark_col(finish).coalesce(0).cat("!"),capture_len_from(begin).coalesce(0).cat("!"),capture_until_cursor_len_from(begin).coalesce(0).cat("!"),capture_rest_len_from(begin).coalesce(0).cat("!"),capture_len_between(begin,finish).coalesce(0).cat("!")])};return(cb())}
"###,
            "αβ:cat",
        ),
        (
            "registered_callback",
            r###"fn apply(callback: codeblock){return(callback())}
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);return(apply(){return(mark_pos(finish).coalesce(0).cat("!"))})}
"###,
            "αβ:cat",
        ),
        (
            "callback_write_read_scope",
            r###"Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>αβ)/
 /:/
 /cat/
 -> Value[2] {mark_input_start(begin);mark_input_end(finish);cb={||mark_input_end(inside);return([mark_pos(inside),mark_pos(finish)])};result=cb();return([result,mark_pos(inside),mark_pos(finish)])}
"###,
            "αβ:cat",
        ),
        (
            "callback_cross_rule_scope",
            r###"Top:: I {a=call(First);b=call(Second);return([a,b])}
First:: I {cb={||mark_input_end(shared);return(mark_pos(shared))};a=cb();return([a,mark_pos(shared)])}
Second:: I {cb={||return(mark_pos(shared))};a=cb();return([a,mark_pos(shared)])}
"###,
            "x",
        ),
    ]
}
fn expected_value(id: &str) -> Option<Value> {
    Some(match id {
        "shared" | "other_label" => serde_json::from_str(include_str!(
            "../../../tests/fixtures/named_mark_number_values.json"
        ))
        .unwrap(),
        "producers" => json!([[6, 1, 7, 3, 6, 6, 6]]),
        "missing_producers" => json!([[null, null, null, null, null, null, null, null]]),
        "symbolic_shadow" => json!([[6, 0, 6]]),
        "quoted_names" => json!([[6, 6]]),
        "evaluated_name" => json!([6]),
        "legacy_bound" => json!([[{"k":1},[],null,"KVT"]]),
        "snapshot_bound" => json!([["6!", null, 0, "S"]]),
        "direct_mark_pos"
        | "direct_capture_rest_len_from"
        | "direct_capture_until_cursor_len_from"
        | "direct_capture_len_between" => json!(["6!"]),
        "direct_mark_line" => json!(["1!"]),
        "direct_mark_col" => json!(["7!"]),
        "direct_capture_len_from" => json!(["3!"]),
        "direct_legacy" => json!([[6, [], "KVT"]]),
        "partial_shared" => json!([[9, 2, "11!", "TAIL", 11, 5, 11]]),
        "zero_missing_reversed" => json!([[1, 1, 8, 10, "F"]]),
        _ => return None,
    })
}
fn expect_value(id: &str, source: &str, input: &str, expected: Value) {
    let observed = routes(source, input);
    eprintln!("NAMED_MARK_NUMBER {id} {observed}");
    for route in ["native", "restored", "plan"] {
        assert_eq!(observed[route], json!({"value":expected}), "{id} {route}");
    }
}
#[test]
fn ordinary_named_sources_preserve_coordinates_names_snapshots_and_root_policies() {
    for (id, source, input) in cases() {
        if let Some(expected) = expected_value(id) {
            expect_value(id, source, input, expected);
        }
    }
}
#[test]
fn every_named_source_keeps_the_pure_function_fence() {
    for (id, source, input) in cases() {
        let helper = if let Some(helper) = id.strip_prefix("function_") {
            helper
        } else if id == "registered_callback" {
            "mark_pos"
        } else {
            continue;
        };
        let function = if id == "registered_callback" {
            "apply"
        } else {
            "forbidden"
        };
        let observed = routes(source, input);
        eprintln!("NAMED_MARK_FENCE {id} {observed}");
        for route in ["native", "restored", "plan"] {
            let error = observed[route]["error"]
                .as_str()
                .expect("pure function must reject parser state");
            assert!(
                error.contains(&format!("user function '{function}'"))
                    && error.contains(&format!("parser-state helper '{helper}'"))
                    && error.contains("not supported in user functions"),
                "{id} {route}: {error}"
            );
            assert_eq!(
                error.starts_with("Generated Rust parser execution failed: "),
                route == "plan"
            );
        }
    }
}
fn scope_case(id: &str, expected: Value) {
    let (_, source, input) = cases()
        .into_iter()
        .find(|row| row.0 == id)
        .expect("owned callback scope source");
    expect_value(id, source, input, expected);
}
#[test]
fn literal_callback_reads_the_callers_named_marks() {
    scope_case(
        "literal_callback_all",
        json!([["6!", "1!", "7!", "3!", "6!", "6!", "6!"]]),
    );
}
#[test]
fn callback_mark_writes_remain_in_the_callers_rule_bucket() {
    scope_case("callback_write_read_scope", json!([[[6, 6], 6, 6]]));
}
#[test]
fn equal_callback_names_cannot_share_marks_between_different_rules() {
    scope_case("callback_cross_rule_scope", json!([[1, 1], [null, null]]));
}

#[test]
fn callback_scope_survives_helper_tree_and_nested_invocations() {
    let cases = [
        (
            "free_contextual",
            r#"result=with("x"){mark_input_end(inside);return([mark_pos(finish),value])};return([result,mark_pos(inside)])"#,
            json!([[[6, "x"], 6]]),
        ),
        (
            "receiver_contextual",
            r#"result="x".with(){mark_input_end(inside);return([mark_pos(finish),value])};return([result,mark_pos(inside)])"#,
            json!([[[6, "x"], 6]]),
        ),
        (
            "free_explicit",
            r#"cb={|item|mark_input_end(inside);return([mark_pos(finish),item])};result=with("x",cb);return([result,mark_pos(inside)])"#,
            json!([[[6, "x"], 6]]),
        ),
        (
            "receiver_explicit",
            r#"cb={|item|mark_input_end(inside);return([mark_pos(finish),item])};result="x".with(cb);return([result,mark_pos(inside)])"#,
            json!([[[6, "x"], 6]]),
        ),
        (
            "hash_tree",
            r#"items={"a":1};result=items.map_leaves(){mark_input_end(inside);return(mark_pos(finish))};return([result,mark_pos(inside)])"#,
            json!([[{"a":6}, 6]]),
        ),
        (
            "array_tree",
            r#"items=[1];result=items.map_leaves(){mark_input_end(inside);return(mark_pos(finish))};return([result,mark_pos(inside)])"#,
            json!([[[6], 6]]),
        ),
        (
            "nested_callback",
            r#"inner={||mark_input_end(inside);return(mark_pos(finish))};outer={||return(inner())};return([outer(),mark_pos(inside)])"#,
            json!([[6, 6]]),
        ),
    ];
    // Capture each public route before assertions so a RED run retains every case.
    let observations: Vec<_> = cases
        .into_iter()
        .map(|(id, action, expected)| {
            let source = format!(
                "Top::\n -> Value .push\n LX {{return(copy(Top))}}\nValue:\n /(?<head>αβ)/\n /:/\n /cat/\n -> Value[2] {{mark_input_end(finish);{action}}}\n"
            );
            let observed = routes(&source, "αβ:cat");
            eprintln!("CALLBACK_SCOPE {id} {observed}");
            (id, observed, expected)
        })
        .collect();
    for (id, observed, expected) in observations {
        for route in ["native", "restored", "plan"] {
            assert_eq!(observed[route], json!({"value":expected}), "{id} {route}");
        }
    }
}

#[test]
fn callback_scope_uses_the_invocation_rule_and_call_time_marks() {
    let source = r#"Top::
 I {reader=call(First);mark_input_start(shared);a=reader();mark_input_end(shared);b=reader();return([a,b])}
First::
 I {mark_input_end(shared);return({||return(mark_pos(shared))})}
"#;
    expect_value("dynamic_invocation", source, "αβ:cat", json!([0, 6]));
}
