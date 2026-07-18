use linkedspec_core::compiler::compile;
use linkedspec_core::expr::CodeBlock;
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, GeneratedSourceCode, GeneratedSourceError,
    GeneratedSourceStage, emit_rust_source_v2, execute_generated_parser_v2,
    validate_generated_parser_plan_v2,
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
    execute_generated_parser_v2(
        &compiled_json,
        plan,
        "xx",
        "uniform-binding-test.spec",
        GENERATED_SOURCE_CONTRACT,
    )
}

fn assert_native_and_generated(source: &str, plan: &[GeneratedPlanRow], expected: Value) {
    assert_eq!(execute_value(source), expected, "native execution");
    assert_eq!(
        execute_generated_value(source, plan).expect("generated execution"),
        expected,
        "generated execution"
    );
}

fn compile_error(source: &str) -> String {
    let parsed = parse_spec_with_user_functions(source).expect("parse rejection fixture");
    validate(&parsed).expect("validate rejection fixture");
    match compile(&parsed) {
        Ok(_) => panic!("selector-shaped source compiled successfully: {source}"),
        Err(error) => error.to_string(),
    }
}

fn action_source(action: &str) -> String {
    format!("Top::\n /x/ -> Done {{ {action} }}\nDone::\n /x/\n")
}

#[test]
fn exact_aggregate_selectors_fail_at_the_rust_compile_boundary() {
    let contract: Value =
        serde_json::from_str(CONTRACT_JSON).expect("uniform-binding contract JSON");
    for case in contract["invalid_selector_cases"]
        .as_array()
        .expect("invalid selector cases")
    {
        let source = case["source"].as_str().expect("selector source");
        let surface = case["surface"].as_str().expect("selector surface");
        let identifier = case["identifier"].as_str().expect("selector identifier");
        let replacement = case["replacement"].as_str().expect("selector replacement");
        let error = compile_error(&action_source(source));
        let expected = format!(
            "aggregate_selector_removed surface={surface} identifier={identifier} replacement={replacement}"
        );
        assert!(error.contains(&expected), "{}: {error}", case["id"]);
    }
}

#[test]
fn dead_fluent_and_unused_function_selectors_also_fail_compilation() {
    let dead_error = compile_error(&action_source(
        "if(false) { return(array(items)) }; return([])", // selector-rejection fixture
    ));
    assert!(
        dead_error.contains(
            "aggregate_selector_removed surface=array identifier=items replacement=items"
        ),
        "{dead_error}"
    );

    let fluent_error = compile_error("Top::\n -> Done.return(hash(meta))\nDone::\n /x/\n"); // selector-rejection fixture
    assert!(
        fluent_error
            .contains("aggregate_selector_removed surface=hash identifier=meta replacement=meta"),
        "{fluent_error}"
    );

    let unused_error = compile_error(
        "fn retired() { return(array(items)) }\nTop::\n /x/ -> Done { return([]) }\nDone::\n /x/\n", // selector-rejection fixture
    );
    assert!(
        unused_error.contains(
            "aggregate_selector_removed surface=array identifier=items replacement=items"
        ),
        "{unused_error}"
    );
}

#[test]
fn generated_compiled_spec_decode_rejects_selector_ast() {
    let mut compiled = compile_source(&action_source("return([])"));
    compiled.rules[0].preamble =
        Some(CodeBlock::parse("array(items)").expect("parse synthetic selector code block")); // selector-rejection fixture

    let emit_error = emit_rust_source_v2(&compiled, "selector-generated.spec")
        .expect_err("generated source emission must reject selector AST");
    assert_eq!(emit_error.stage, GeneratedSourceStage::EmitSource);
    assert_eq!(
        emit_error.code,
        GeneratedSourceCode::GeneratedSourceEmitFailed
    );
    assert!(
        emit_error.detail.as_deref().unwrap_or_default().contains(
            "aggregate_selector_removed surface=array identifier=items replacement=items"
        ),
        "{emit_error:?}"
    );

    let compiled_json = serde_json::to_string(&compiled).expect("serialize synthetic fixture");
    let error = validate_generated_parser_plan_v2(
        &compiled_json,
        TOP_DONE_PLAN,
        "selector-generated.spec",
        GENERATED_SOURCE_CONTRACT,
    )
    .expect_err("generated plan must reject selector AST");
    assert_eq!(
        error.stage,
        GeneratedSourceStage::CompileOrLoadGeneratedSource
    );
    assert_eq!(
        error.code,
        GeneratedSourceCode::GeneratedSourceCompileFailed
    );
    assert!(
        error.detail.as_deref().unwrap_or_default().contains(
            "aggregate_selector_removed surface=array identifier=items replacement=items"
        ),
        "{error:?}"
    );
}

#[test]
fn retained_aggregate_constructors_and_literals_execute() {
    let source = action_source(
        r#"items = ["x"]
left = "l"
right = "r"
key = "key"
value = "r"
return([array(), array("items"), array(copy(items)), array(left, right), hash(), hash("key", value), [items], { key : value }])"#,
    );
    assert_native_and_generated(
        &source,
        TOP_DONE_PLAN,
        json!([[], ["items"], [["x"]], ["l", "r"], {}, {"key": "r"}, [["x"]], {"key": "r"}]),
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
    validate_generated_parser_plan_v2(
        &compiled_json,
        TOP_DONE_PLAN,
        identity,
        GENERATED_SOURCE_CONTRACT,
    )
    .expect("uniform-binding generated plan");
    assert_eq!(
        execute_generated_parser_v2(
            &compiled_json,
            TOP_DONE_PLAN,
            input,
            identity,
            GENERATED_SOURCE_CONTRACT,
        )
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
fn all_array_end_methods_return_independent_updated_arrays() {
    let source = r#"Top::
 /x/ -> Done {
   items = ["a", "b", "c"]
   after_push_back = items.push_back("d")
   after_push_front = items.push_front("z")
   after_pop_back = items.pop_back()
   after_pop_front = items.pop_front()
   count = items.push_back("e").count()
   return({
     "items" : items,
     "after_push_back" : after_push_back,
     "after_push_front" : after_push_front,
     "after_pop_back" : after_pop_back,
     "after_pop_front" : after_pop_front,
     "count" : count
   })
 }
Done::
 /x/
"#;

    assert_native_and_generated(
        source,
        TOP_DONE_PLAN,
        json!({
            "items": ["a", "b", "c", "e"],
            "after_push_back": ["a", "b", "c", "d"],
            "after_push_front": ["z", "a", "b", "c", "d"],
            "after_pop_back": ["z", "a", "b", "c"],
            "after_pop_front": ["a", "b", "c"],
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

#[test]
fn action_edge_fluent_push_updates_the_bare_typed_binding() {
    let source = r#"Top:: I { items = [] }
 -> Word.push(Word, items)
 -> Reset { set(items, []) }
 -> Word.push(Word, items)
 LX { return(items) }
Word: /x/ I.return(entry_text())
Reset: /,/
"#;

    let plan = &[
        GeneratedPlanRow {
            label: "Top",
            family: "default",
        },
        GeneratedPlanRow {
            label: "Word",
            family: "default",
        },
        GeneratedPlanRow {
            label: "Reset",
            family: "default",
        },
    ];
    let expected = json!(["x"]);
    assert_eq!(
        Engine::new(compile_source(source))
            .execute_value("x,x", &ExecutionOptions::new())
            .expect("native action-edge fluent push fixture"),
        expected
    );
    let compiled_json = serde_json::to_string(&compile_source(source)).expect("serialize fixture");
    assert_eq!(
        execute_generated_parser_v2(
            &compiled_json,
            plan,
            "x,x",
            "uniform-binding-action-edge-push.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .expect("generated action-edge fluent push fixture"),
        expected
    );
}

#[test]
fn explicit_binding_wins_over_an_implicit_descriptor_tag() {
    let source = r#"Top:: I { rule = [] }
 /x/ -> Child { child = call(Child); push(rule, "kept"); return(rule) }
Child::
 /x/ I.return(["rule", "descriptor"])
"#;
    let plan = &[
        GeneratedPlanRow {
            label: "Top",
            family: "default",
        },
        GeneratedPlanRow {
            label: "Child",
            family: "default",
        },
    ];
    assert_native_and_generated(source, plan, json!(["kept"]));
}
