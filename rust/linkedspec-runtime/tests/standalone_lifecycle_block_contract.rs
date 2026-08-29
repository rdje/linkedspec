//! FUTURE-PARITY-BACKLOG.15.1 — Rust standalone lifecycle-block contract.

use linkedspec_core::ast::{BodyElement, BodyElementKind, SpecFile};
use linkedspec_core::compiler::compile;
use linkedspec_core::expr::CodeBlock;
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, emit_rust_source_v2, execute_generated_parser_v2,
    validate_generated_parser_plan_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};

const CONTRACT_JSON: &str = include_str!(concat!(
    env!("CARGO_MANIFEST_DIR"),
    "/../../capability_conformance/standalone_lifecycle_block_contract.json"
));

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

fn contract() -> Value {
    serde_json::from_str(CONTRACT_JSON).expect("standalone lifecycle block contract JSON")
}

fn parse(source: &str) -> SpecFile {
    parse_spec_with_user_functions(source).expect("parse standalone lifecycle fixture")
}

fn compile_source(source: &str) -> CompiledSpec {
    let parsed = parse(source);
    validate(&parsed).expect("validate standalone lifecycle fixture");
    compile(&parsed).expect("compile standalone lifecycle fixture")
}

fn execute(compiled: CompiledSpec, input: &str) -> Value {
    Engine::new(compiled)
        .execute_value(input, &ExecutionOptions::new())
        .expect("execute standalone lifecycle fixture")
}

fn compiled_top(compiled: &CompiledSpec) -> &linkedspec_core::types::CompiledRule {
    compiled
        .rules
        .iter()
        .find(|rule| rule.label == "Top")
        .expect("compiled Top rule")
}

fn top_rule(spec: &SpecFile) -> &linkedspec_core::ast::Rule {
    spec.rules
        .iter()
        .find(|rule| rule.header.label == "Top")
        .expect("Top rule")
}

fn lifecycle_i_elements(spec: &SpecFile) -> Vec<&BodyElement> {
    top_rule(spec)
        .body
        .iter()
        .filter(|element| {
            matches!(
                &element.kind,
                BodyElementKind::CodeBlock { lifecycle, .. } if lifecycle == "I"
            )
        })
        .collect()
}

fn lifecycle_code(element: &BodyElement) -> &str {
    match &element.kind {
        BodyElementKind::CodeBlock { lifecycle, code } if lifecycle == "I" => code,
        other => panic!("expected lifecycle I element, got {other:?}"),
    }
}

fn strip_provenance(value: &mut Value) {
    match value {
        Value::Array(items) => {
            for item in items {
                strip_provenance(item);
            }
        }
        Value::Object(fields) => {
            fields.remove("source");
            fields.remove("line");
            for value in fields.values_mut() {
                strip_provenance(value);
            }
        }
        _ => {}
    }
}

fn semantic_body(spec: &SpecFile) -> Value {
    let mut value = serde_json::to_value(&top_rule(spec).body).expect("serialize semantic body");
    strip_provenance(&mut value);
    value
}

fn assert_expected_owner(element: &BodyElement, expected: &str, case_id: &str) {
    let matches = match expected {
        "action_edge" => matches!(element.kind, BodyElementKind::ActionEdge { .. }),
        "blind_edge" => matches!(element.kind, BodyElementKind::BlindEdge { .. }),
        "bare_edge" => matches!(element.kind, BodyElementKind::BareEdge { .. }),
        "code_block" => matches!(element.kind, BodyElementKind::CodeBlock { .. }),
        other => panic!("unsupported owner fixture kind {other}"),
    };
    assert!(matches, "{case_id}: expected {expected}, got {element:?}");
}

#[test]
fn placement_twins_normalize_to_lifecycle_i_with_exact_provenance() {
    let contract = contract();
    assert_eq!(
        contract["contract_id"],
        "linkedspec-standalone-lifecycle-block-v1"
    );

    for case in contract["placement_twins"]
        .as_array()
        .expect("placement twins")
    {
        let case_id = case["id"].as_str().expect("placement case id");
        let explicit_source = case["explicit"].as_str().expect("explicit source");
        let shorthand_source = case["shorthand"].as_str().expect("shorthand source");
        let explicit = parse(explicit_source);
        let shorthand = parse(shorthand_source);
        validate(&explicit)
            .unwrap_or_else(|error| panic!("{case_id} explicit validation: {error}"));
        validate(&shorthand)
            .unwrap_or_else(|error| panic!("{case_id} shorthand validation: {error}"));

        assert_eq!(
            semantic_body(&shorthand),
            semantic_body(&explicit),
            "{case_id}: semantic body and position"
        );
        assert!(
            top_rule(&shorthand)
                .body
                .iter()
                .all(|element| !matches!(element.kind, BodyElementKind::PlainBlock { .. })),
            "{case_id}: source parsing must not emit PlainBlock"
        );

        let explicit_i = lifecycle_i_elements(&explicit);
        let shorthand_i = lifecycle_i_elements(&shorthand);
        assert_eq!(explicit_i.len(), 1, "{case_id}: explicit I count");
        assert_eq!(shorthand_i.len(), 1, "{case_id}: shorthand I count");
        let expected_line = case["opening_line"].as_u64().expect("opening line") as usize;
        assert_eq!(
            explicit_i[0].line, expected_line,
            "{case_id}: explicit line"
        );
        assert_eq!(
            shorthand_i[0].line, expected_line,
            "{case_id}: shorthand line"
        );

        let expected_interior = case["interior"].as_str().expect("interior").trim();
        assert_eq!(
            lifecycle_code(explicit_i[0]),
            expected_interior,
            "{case_id}: explicit interior"
        );
        assert_eq!(
            lifecycle_code(shorthand_i[0]),
            expected_interior,
            "{case_id}: shorthand interior"
        );
        assert_eq!(
            explicit_i[0].source,
            format!("I {{{}}}", case["interior"].as_str().expect("interior")),
            "{case_id}: explicit source"
        );
        assert_eq!(
            shorthand_i[0].source,
            format!("{{{}}}", case["interior"].as_str().expect("interior")),
            "{case_id}: shorthand source"
        );

        let explicit_action = CodeBlock::parse(lifecycle_code(explicit_i[0]))
            .unwrap_or_else(|error| panic!("{case_id} explicit ActionIR: {error}"));
        let shorthand_action = CodeBlock::parse(lifecycle_code(shorthand_i[0]))
            .unwrap_or_else(|error| panic!("{case_id} shorthand ActionIR: {error}"));
        assert_eq!(
            shorthand_action, explicit_action,
            "{case_id}: ActionIR nodes and interior spans"
        );

        assert_eq!(
            serde_json::to_value(compile(&shorthand).expect("compile shorthand twin"))
                .expect("serialize shorthand twin"),
            serde_json::to_value(compile(&explicit).expect("compile explicit twin"))
                .expect("serialize explicit twin"),
            "{case_id}: compiled semantic twin"
        );
    }
}

#[test]
fn multiline_source_nested_braces_and_quotes_are_exact() {
    let contract = contract();
    let fixture = &contract["provenance_twin"];
    let explicit = parse(
        fixture["explicit"]
            .as_str()
            .expect("explicit provenance source"),
    );
    let shorthand = parse(
        fixture["shorthand"]
            .as_str()
            .expect("shorthand provenance source"),
    );
    validate(&explicit).expect("validate explicit provenance fixture");
    validate(&shorthand).expect("validate shorthand provenance fixture");
    let explicit_i = lifecycle_i_elements(&explicit);
    let shorthand_i = lifecycle_i_elements(&shorthand);
    assert_eq!(explicit_i.len(), 1);
    assert_eq!(shorthand_i.len(), 1);
    assert_eq!(
        explicit_i[0].source,
        fixture["explicit_block_source"]
            .as_str()
            .expect("explicit block source")
    );
    assert_eq!(
        shorthand_i[0].source,
        fixture["shorthand_block_source"]
            .as_str()
            .expect("shorthand block source")
    );
    assert_eq!(
        lifecycle_code(shorthand_i[0]),
        lifecycle_code(explicit_i[0])
    );
    assert_eq!(
        CodeBlock::parse(lifecycle_code(shorthand_i[0])).expect("shorthand multiline ActionIR"),
        CodeBlock::parse(lifecycle_code(explicit_i[0])).expect("explicit multiline ActionIR")
    );
}

#[test]
fn explicit_and_shorthand_duplicates_append_in_authored_order() {
    let contract = contract();
    let expected = contract["duplicate_expected"].clone();
    let input = contract["duplicate_input"]
        .as_str()
        .expect("duplicate input");
    let mut canonical_preamble = None;

    for case in contract["duplicate_cases"]
        .as_array()
        .expect("duplicate cases")
    {
        let case_id = case["id"].as_str().expect("duplicate case id");
        let source = case["source"].as_str().expect("duplicate source");
        let parsed = parse(source);
        let lifecycle = lifecycle_i_elements(&parsed);
        assert_eq!(lifecycle.len(), 2, "{case_id}: parsed lifecycle count");
        assert_eq!(
            lifecycle
                .iter()
                .map(|element| lifecycle_code(element))
                .collect::<Vec<_>>(),
            vec![r#"set(out, "first")"#, r#"return(cat(out, "-second"))"#,],
            "{case_id}: parsed authored order"
        );

        let compiled = compile_source(source);
        let top = compiled_top(&compiled);
        let preamble = top.preamble.as_ref().expect("compiled I preamble");
        assert_eq!(
            preamble.statements.len(),
            2,
            "{case_id}: appended statement count"
        );
        if let Some(canonical) = &canonical_preamble {
            assert_eq!(
                preamble, canonical,
                "{case_id}: mixed and explicit ActionIR spans"
            );
        } else {
            canonical_preamble = Some(preamble.clone());
        }
        assert_eq!(
            execute(compiled.clone(), input),
            expected,
            "{case_id}: native result"
        );

        let encoded = serde_json::to_string(&compiled).expect("serialize duplicate CompiledSpec");
        let reconstructed: CompiledSpec =
            serde_json::from_str(&encoded).expect("deserialize duplicate CompiledSpec");
        assert_eq!(
            execute(reconstructed, input),
            expected,
            "{case_id}: serialized result"
        );
    }
}

#[test]
fn edge_callable_nested_and_function_braces_keep_their_owner() {
    for case in contract()["ownership_cases"]
        .as_array()
        .expect("ownership cases")
    {
        let case_id = case["id"].as_str().expect("ownership case id");
        let parsed = parse(case["source"].as_str().expect("ownership source"));
        validate(&parsed).unwrap_or_else(|error| panic!("{case_id} validation: {error}"));
        let top = top_rule(&parsed);
        let expected = case["expected_kind"].as_str().expect("expected owner kind");
        let owned = top
            .body
            .iter()
            .find(|element| match expected {
                "action_edge" => matches!(element.kind, BodyElementKind::ActionEdge { .. }),
                "blind_edge" => matches!(element.kind, BodyElementKind::BlindEdge { .. }),
                "bare_edge" => matches!(element.kind, BodyElementKind::BareEdge { .. }),
                "code_block" => matches!(element.kind, BodyElementKind::CodeBlock { .. }),
                _ => false,
            })
            .unwrap_or_else(|| panic!("{case_id}: expected owner not found in {top:?}"));
        assert_expected_owner(owned, expected, case_id);
        let expected_lifecycle_count = usize::from(case_id == "nested_lifecycle_block");
        assert_eq!(
            lifecycle_i_elements(&parsed).len(),
            expected_lifecycle_count,
            "{case_id}: accidental lifecycle count"
        );
        if case_id == "function_body" {
            assert_eq!(
                parsed.functions.len(),
                1,
                "function body remains top-level function syntax"
            );
        }
    }
}

#[test]
fn malformed_explicit_and_shorthand_twins_reject_equivalently() {
    for case in contract()["malformed_twins"]
        .as_array()
        .expect("malformed twins")
    {
        let case_id = case["id"].as_str().expect("malformed case id");
        let expected_fragment = case["rust_error_fragment"]
            .as_str()
            .expect("Rust error fragment");
        let mut errors = Vec::new();
        for form in ["explicit", "shorthand"] {
            let parsed = parse(case[form].as_str().expect("malformed source"));
            let error = validate(&parsed).unwrap_err().to_string();
            assert!(
                error.contains(expected_fragment),
                "{case_id} {form}: expected {expected_fragment:?}, got {error:?}"
            );
            assert!(
                error.contains("Top"),
                "{case_id} {form}: rule provenance: {error}"
            );
            assert!(
                error.contains("line 2") || case_id == "missing_close",
                "{case_id} {form}: opening line: {error}"
            );
            errors.push(error);
        }
        let normalize = |error: &str| error.replace("I {", "{");
        assert_eq!(
            normalize(&errors[1]),
            normalize(&errors[0]),
            "{case_id}: explicit/shorthand diagnostic class and fields"
        );
    }
}

#[test]
fn legacy_plain_block_remains_readable_and_inert() {
    let mut parsed = parse("Top::\n /x/\n");
    parsed.rules[0].body.push(BodyElement {
        kind: BodyElementKind::PlainBlock {
            code: r#"return("must-not-run")"#.to_string(),
        },
        source: r#"{ return("must-not-run") }"#.to_string(),
        line: 2,
    });
    validate(&parsed).expect("legacy PlainBlock remains structurally readable");
    let compiled = compile(&parsed).expect("legacy PlainBlock remains compilable");
    assert!(
        compiled_top(&compiled).preamble.is_none(),
        "legacy PlainBlock must not acquire lifecycle semantics"
    );
    assert_eq!(execute(compiled, "x"), Value::Null);
}

#[test]
fn legacy_programmatic_lifecycle_nodes_retain_interior_balance_validation() {
    let mut parsed = parse("Top::\n /x/\n");
    parsed.rules[0].body.push(BodyElement {
        kind: BodyElementKind::CodeBlock {
            lifecycle: "I".to_string(),
            code: "if(true) { return(\"x\")".to_string(),
        },
        source: "programmatic lifecycle I".to_string(),
        line: 2,
    });

    let error = validate(&parsed).expect_err("legacy lifecycle interior remains balance-checked");
    assert!(
        error.to_string().contains("unbalanced braces"),
        "legacy lifecycle balance diagnostic: {error}"
    );
}

#[test]
fn mixed_fixture_survives_emitted_and_generated_rust_paths() {
    let contract = contract();
    let generated_case_id = contract["generated_fixture_case"]
        .as_str()
        .expect("generated case id");
    let case = contract["duplicate_cases"]
        .as_array()
        .expect("duplicate cases")
        .iter()
        .find(|case| case["id"] == generated_case_id)
        .expect("generated fixture case");
    let compiled = compile_source(case["source"].as_str().expect("generated fixture source"));
    let input = contract["duplicate_input"]
        .as_str()
        .expect("generated input");
    let expected = contract["duplicate_expected"].clone();
    let identity = "standalone-lifecycle-block.spec";
    let compiled_json = serde_json::to_string(&compiled).expect("serialize generated fixture");

    let emitted = emit_rust_source_v2(&compiled, identity).expect("emit generated Rust source");
    assert!(emitted.contains(identity));
    assert!(emitted.contains(GENERATED_SOURCE_CONTRACT));
    validate_generated_parser_plan_v2(
        &compiled_json,
        TOP_DONE_PLAN,
        identity,
        GENERATED_SOURCE_CONTRACT,
    )
    .expect("validate standalone lifecycle generated plan");
    assert_eq!(
        execute_generated_parser_v2(
            &compiled_json,
            TOP_DONE_PLAN,
            input,
            identity,
            GENERATED_SOURCE_CONTRACT,
        )
        .expect("execute standalone lifecycle generated fixture"),
        expected
    );
    assert_eq!(execute(compiled, input), json!("first-second"));
}
