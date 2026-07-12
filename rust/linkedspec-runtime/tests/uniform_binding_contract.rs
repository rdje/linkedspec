use linkedspec_core::compiler::compile;
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GeneratedPlanRow, GeneratedSourceError, execute_generated_parser_v1,
    validate_generated_parser_plan_v1,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

const CONTRACT_JSON: &str = include_str!(concat!(
    env!("CARGO_MANIFEST_DIR"),
    "/../../capability_conformance/uniform_binding_contract.json"
));

fn compile_source(source: &str) -> CompiledSpec {
    let parsed = parse_spec_with_user_functions(source).expect("parse uniform-binding fixture");
    validate(&parsed).expect("validate uniform-binding fixture");
    compile(&parsed).expect("compile uniform-binding fixture")
}

fn execute_value(source: &str) -> Value {
    Engine::new(compile_source(source))
        .execute_value("xx", &ExecutionOptions::new())
        .expect("execute uniform-binding fixture")
}

const TOP_DONE_PLAN: &[GeneratedPlanRow] = &[
    GeneratedPlanRow {
        label: "Top",
        family: "default",
    },
    GeneratedPlanRow {
        label: "Done",
        family: "default",
    },
];

const TOP_ITEMS_DONE_PLAN: &[GeneratedPlanRow] = &[
    GeneratedPlanRow {
        label: "Top",
        family: "default",
    },
    GeneratedPlanRow {
        label: "items",
        family: "default",
    },
    GeneratedPlanRow {
        label: "Done",
        family: "default",
    },
];

fn execute_generated_value(
    source: &str,
    plan: &[GeneratedPlanRow],
) -> Result<Value, GeneratedSourceError> {
    let compiled_json = serde_json::to_string(&compile_source(source)).expect("serialize fixture");
    execute_generated_parser_v1(&compiled_json, plan, "xx", "uniform-binding-test.spec")
}

fn assert_native_and_generated(source: &str, plan: &[GeneratedPlanRow], expected: Value) {
    assert_eq!(execute_value(source), expected, "native execution");
    assert_eq!(
        execute_generated_value(source, plan).expect("generated execution"),
        expected,
        "generated execution"
    );
}

#[test]
fn neutral_future_fixture_runs_natively_and_through_generated_plan() {
    let contract: Value =
        serde_json::from_str(CONTRACT_JSON).expect("uniform-binding contract JSON");
    assert_eq!(contract["contract_id"], "linkedspec-uniform-binding-v1");
    let source = contract["fixture"]["spec_source"]
        .as_str()
        .expect("fixture source");
    let input = contract["fixture"]["input"]
        .as_str()
        .expect("fixture input");
    let expected = contract["fixture"]["expected"].clone();
    let compiled = compile_source(source);

    assert_eq!(
        Engine::new(compiled.clone())
            .execute_value(input, &ExecutionOptions::new())
            .expect("native uniform-binding fixture"),
        expected
    );

    let compiled_json = serde_json::to_string(&compiled).expect("serialize compiled fixture");
    let identity = "uniform-binding-fixture.spec";
    validate_generated_parser_plan_v1(&compiled_json, TOP_DONE_PLAN, identity)
        .expect("uniform-binding generated plan");
    assert_eq!(
        execute_generated_parser_v1(&compiled_json, TOP_DONE_PLAN, input, identity)
            .expect("generated uniform-binding fixture"),
        expected
    );
}

#[test]
fn absent_push_returns_independent_updated_values() {
    let source = r#"Top::
 /x/ -> Done {
   first_push = push(items, "a")
   second_push = push(items, "b")
   items += "c"
   count = items.push_back("d").count()
   return({ "items" : items, "first_push" : first_push, "second_push" : second_push, "count" : count })
 }
Done::
 /x/
"#;

    assert_native_and_generated(
        source,
        TOP_DONE_PLAN,
        json!({
            "items": ["a", "b", "c", "d"],
            "first_push": ["a"],
            "second_push": ["a", "b"],
            "count": 4
        }),
    );
}

#[test]
fn registered_rule_keeps_ambiguous_push_precedence() {
    let source = r#"Top::
 I { items = ["unchanged"]; outputs = [] }
 /x/ -> Done { pushed = push(items, outputs); return([items, outputs, pushed]) }
items::
 /x/ I { return("child-result") }
Done::
 /x/
"#;

    assert_native_and_generated(
        source,
        TOP_ITEMS_DONE_PLAN,
        json!([["unchanged"], ["child-result"], ["child-result"]]),
    );
}

#[test]
fn mutable_and_pure_split_remain_distinct() {
    let source = r#"Top::
 /x/ -> Done {
   stored = split(parts, "a,b", ",")
   pure = split("c,d", ",")
   return({ "parts" : parts, "stored" : stored, "pure" : pure })
 }
Done::
 /x/
"#;

    assert_native_and_generated(
        source,
        TOP_DONE_PLAN,
        json!({"parts": ["a", "b"], "stored": ["a", "b"], "pure": ["c", "d"]}),
    );
}

#[test]
fn hash_index_mutation_returns_updated_harray() {
    let source = r#"Top::
 /x/ -> Done {
   updated = (meta["stage"] = "ok")
   snapshot = copy(meta)
   return({ "meta" : meta, "updated" : updated, "snapshot" : snapshot })
 }
Done::
 /x/
"#;

    assert_native_and_generated(
        source,
        TOP_DONE_PLAN,
        json!({
            "meta": {"stage": "ok"},
            "updated": {"stage": "ok"},
            "snapshot": {"stage": "ok"}
        }),
    );
}

#[test]
fn unused_values_are_dropped_without_changing_bindings() {
    let source = r#"Top::
 /x/ -> Done {
   set(items, ["a"])
   copy(items)
   updated = push(items, "b")
   return({ "items" : items, "updated" : updated })
 }
Done::
 /x/
"#;

    assert_native_and_generated(
        source,
        TOP_DONE_PLAN,
        json!({"items": ["a", "b"], "updated": ["a", "b"]}),
    );
}

#[test]
fn bare_collection_statements_rebind_the_typed_array() {
    let source = r#"Top::
 /x/ -> Done {
   trimmed = trim_each(set(words, [" a ", "", "b"]))
   trim_each(words)
   filter_nonempty(words)
   return({ "trimmed" : trimmed, "words" : words })
 }
Done::
 /x/
"#;

    assert_native_and_generated(
        source,
        TOP_DONE_PLAN,
        json!({"trimmed": ["a", "", "b"], "words": ["a", "b"]}),
    );
}

#[test]
fn wrong_kind_mutation_reports_neutral_fields() {
    let source = r#"Top::
 /x/ -> Done { items = "text"; push(items, "x"); return(items) }
Done::
 /x/
"#;
    let error = Engine::new(compile_source(source))
        .execute_value_with_diagnostics("xx", &ExecutionOptions::new())
        .expect_err("wrong-kind push must fail");
    let detail = error.diagnostic().detail.as_str();
    assert!(detail.contains("binding_kind_mismatch"), "{detail}");
    assert!(detail.contains("identifier=items"), "{detail}");
    assert!(detail.contains("expected_kind=array"), "{detail}");
    assert!(detail.contains("actual_kind=scalar"), "{detail}");

    let generated_error = execute_generated_value(source, TOP_DONE_PLAN)
        .expect_err("generated wrong-kind push must fail");
    let generated_detail = generated_error.detail.as_deref().unwrap_or_default();
    assert!(
        generated_detail.contains("binding_kind_mismatch"),
        "{generated_detail}"
    );
    assert!(
        generated_detail.contains("identifier=items"),
        "{generated_detail}"
    );
    assert!(
        generated_detail.contains("expected_kind=array"),
        "{generated_detail}"
    );
    assert!(
        generated_detail.contains("actual_kind=scalar"),
        "{generated_detail}"
    );
}

#[test]
fn set_returns_assigned_value_for_receiver_chaining() {
    let source = r#"Top::
 /x/ -> Done {
   first = set(items, ["b", "a"]).sorted().first()
   return([first, items])
 }
Done::
 /x/
"#;

    assert_native_and_generated(source, TOP_DONE_PLAN, json!(["a", ["b", "a"]]));
}
