//! TYPE-REFERENCE-BOOK.1.2.23.3.55.2 — detached gap/slot record reads.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, classify_generated_rule_family,
    execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

fn routes(source: &str, input: &str) -> Vec<Result<Value, String>> {
    let parsed = parse_spec_with_user_functions(source).expect("parse gap-slot selections");
    validate(&parsed).expect("validate gap-slot selections");
    let compiled = compile(&parsed).expect("compile gap-slot selections");
    let serialized = serde_json::to_string(&compiled).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    let plan: Vec<_> = compiled
        .rules
        .iter()
        .map(|rule| GeneratedPlanRow {
            label: match rule.label.as_str() {
                "Top" => "Top",
                "List" => "List",
                "Item" => "Item",
                other => panic!("unexpected fixture label {other}"),
            },
            family: classify_generated_rule_family(rule).contract_name(),
        })
        .collect();
    vec![
        Engine::new(compiled)
            .execute_value(input, &ExecutionOptions::new())
            .map_err(|e| e.to_string()),
        Engine::new(restored)
            .execute_value(input, &ExecutionOptions::new())
            .map_err(|e| e.to_string()),
        execute_generated_parser_v2(
            &serialized,
            &plan,
            input,
            "gap-slot-selection.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|e| e.to_string()),
    ]
}
fn check(source: &str, input: &str, expected: Value) {
    let actual = routes(source, input);
    eprintln!("GAP_SLOT_ALL_ROUTES {actual:?}");
    for (route, value) in actual.into_iter().enumerate() {
        eprintln!("GAP_SLOT_SELECTION route{route} {value:?}");
        assert_eq!(
            value.expect("execute gap-slot selections"),
            expected,
            "route{route}"
        );
    }
}
fn gap_source(definitions: &str, action: &str, item: &str) -> String {
    format!(
        "{definitions}\nList::\n @capture_gaps\n I {{rows=[]}}\n -> Item[word] {{{action}}}\n LX {{return(rows)}}\nItem:\n word=/[^,;]+/\n I {{{item}}}\n"
    )
}

#[test]
fn frozen_gap_slot_record_selection_target() {
    check(
        include_str!("../../../tests/fixtures/gap_slot_record_selection_values.spec"),
        "a,b",
        serde_json::from_str(include_str!(
            "../../../tests/fixtures/gap_slot_record_selection_values.json"
        ))
        .unwrap(),
    );
}

#[test]
fn primitive_records_and_bound_fields_keep_existing_provenance() {
    let source = gap_source(
        "",
        "push(rows,[gap_span(),call(Item)])",
        "return(entry_slot())",
    );
    let slot = json!({"target_rule":"Item","regex_index":0,"slot_id":"word","selector_kind":"named","authored_selector":"word"});
    check(
        &source,
        "a,b",
        json!([
            [{"source_id":"input","start":0,"end":0,"provenance":"gap"},slot],
            [{"source_id":"input","start":1,"end":2,"provenance":"gap"},slot]
        ]),
    );
    let source = gap_source(
        "",
        "span=gap_span();push(rows,[span[\"start\"].add(1),call(Item)])",
        "entry_record=entry_slot();return(entry_record[\"slot_id\"].uppercase())",
    );
    check(&source, "a,b", json!([[1, "WORD"], [2, "WORD"]]));
}

#[test]
fn direct_compatible_fields_preserve_zero_and_skip_defaults() {
    let source = gap_source(
        "",
        "push(rows,[gap_span()[\"end\"].coalesce(99).cat(\"!\"),call(Item)])",
        "return([entry_slot()[\"regex_index\"].coalesce(99).add(1),entry_slot()[\"slot_id\"].uppercase()])",
    );
    check(
        &source,
        "a,b",
        json!([["0!", [1, "WORD"]], ["2!", [1, "WORD"]]]),
    );
}

#[test]
fn direct_slot_absence_can_recover_distinct_value_kinds() {
    check(
        r#"Top:: I {return([entry_slot(),entry_slot()["missing"].coalesce("M"),entry_slot()["missing"].coalesce(false),entry_slot()["missing"].coalesce(0),entry_slot()["missing"].coalesce(["a","tail"])[-1].uppercase()])}"#,
        "x",
        json!([null, "M", false, 0, "TAIL"]),
    );
}

#[test]
fn unavailable_gap_errors_precede_selected_field_defaults() {
    let primitive = "Top:: I {return(gap_span())}";
    let selected = "Top:: I {return(gap_span()[\"start\"].coalesce(99))}";
    let actual = routes(selected, "x");
    eprintln!("GAP_SLOT_CONTEXT_ALL_ROUTES {actual:?}");
    for (route, error) in actual.into_iter().enumerate() {
        let error = error.expect_err("gap context error must not become a default");
        eprintln!("GAP_SLOT_CONTEXT route{route} {error}");
        assert!(error.contains("gap_capture_context_unavailable"), "{error}");
    }
    let native_error = |source: &str| {
        let parsed = parse_spec_with_user_functions(source).unwrap();
        validate(&parsed).unwrap();
        Engine::new(compile(&parsed).unwrap())
            .execute_value_with_diagnostics("x", &ExecutionOptions::new())
            .expect_err("typed native gap context failure")
    };
    let before = native_error(primitive);
    let after = native_error(selected);
    assert_eq!(
        after.diagnostic.code.as_deref(),
        Some("gap_capture_context_unavailable")
    );
    assert_eq!(after.message, before.message);
    assert_eq!(after.diagnostic, before.diagnostic);
}

#[test]
fn pure_function_state_fence_and_explicit_records_stay_distinct() {
    for (helper, field) in [("gap_span", "start"), ("entry_slot", "slot_id")] {
        let definition =
            format!("fn selected(){{return({helper}()[\"{field}\"].coalesce(\"M\"))}}");
        let source = gap_source(&definition, "push(rows,selected())", "return(entry_text())");
        for (route, value) in routes(&source, "a,b").into_iter().enumerate() {
            let error = value.expect_err("pure function must not acquire parser state");
            eprintln!("GAP_SLOT_FUNCTION {helper} route{route} {error}");
            assert!(
                error.contains("parser-state helper") && error.contains(helper),
                "{error}"
            );
        }
    }
    let source = gap_source(
        "fn selected(span,item){return([span[\"start\"].add(1),item])}\nfn identify(slot){return(slot[\"slot_id\"].uppercase())}",
        "push(rows,selected(gap_span(),call(Item)))",
        "return(identify(entry_slot()))",
    );
    check(&source, "a,b", json!([[1, "WORD"], [2, "WORD"]]));
}

#[test]
fn extra_argument_helpers_keep_existing_arity_errors() {
    for (helper, field) in [("gap_span", "start"), ("entry_slot", "slot_id")] {
        let source = format!("Top:: I {{return({helper}(1)[\"{field}\"].coalesce(\"M\"))}}");
        for (route, value) in routes(&source, "x").into_iter().enumerate() {
            let error = value.expect_err("extra argument must not acquire zero-arity source role");
            eprintln!("GAP_SLOT_ARITY {helper} route{route} {error}");
            assert!(
                error.contains("helper_arity_mismatch") && error.contains(helper),
                "{error}"
            );
        }
    }
}
