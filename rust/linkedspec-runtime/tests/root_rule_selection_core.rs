use linkedspec_core::compiler::compile;
use linkedspec_core::entry_rule::ENTRY_RULE_CONTRACT_ID;
use linkedspec_core::parser::parse_spec;
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::{validate, validate_with_options};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use serde::Deserialize;
use serde_json::json;

const CONTRACT_JSON: &str =
    include_str!("../../../capability_conformance/root_rule_selection_contract.json");

#[derive(Debug, Deserialize)]
struct Contract {
    contract_id: String,
    selection_cases: Vec<SelectionCase>,
    failure_cases: Vec<FailureCase>,
    strict_cases: Vec<StrictCase>,
}

#[derive(Debug, Deserialize)]
struct RuleRow {
    label: String,
    authored_is_top: bool,
}

#[derive(Debug, Deserialize)]
struct SelectionCase {
    id: String,
    rules: Vec<RuleRow>,
    explicit_selector: Option<String>,
    expected_label: String,
    expected_basis: String,
}

#[derive(Debug, Deserialize)]
struct FailureCase {
    id: String,
    rules: Vec<RuleRow>,
    explicit_selector: Option<String>,
    expected_code: String,
    expected_stage: String,
}

#[derive(Debug, Deserialize)]
struct StrictCase {
    id: String,
    expected_unused: Vec<String>,
}

fn contract() -> Contract {
    serde_json::from_str(CONTRACT_JSON).expect("root-rule selection contract must decode")
}

fn source_for_rows(rows: &[RuleRow]) -> String {
    rows.iter()
        .map(|row| {
            let separator = if row.authored_is_top { "::" } else { ":" };
            format!(
                "{}{separator}\n /x/\n E {{ return(\"{}\") }}\n",
                row.label, row.label
            )
        })
        .collect::<Vec<_>>()
        .join("\n")
}

fn compiled_for_rows(rows: &[RuleRow]) -> CompiledSpec {
    if rows.is_empty() {
        return CompiledSpec {
            functions: Vec::new(),
            rules: Vec::new(),
        };
    }
    let parsed = parse_spec(&source_for_rows(rows)).expect("contract rule source must parse");
    validate(&parsed).expect("non-empty contract rule source must validate");
    compile(&parsed).expect("contract rule source must compile")
}

fn engine(source: &str) -> Engine {
    let parsed = parse_spec(source).expect("native selection fixture must parse");
    validate(&parsed).expect("native selection fixture must validate");
    Engine::new(compile(&parsed).expect("native selection fixture must compile"))
}

#[test]
fn neutral_selection_and_failure_rows_resolve_exactly() {
    let contract = contract();
    assert_eq!(contract.contract_id, ENTRY_RULE_CONTRACT_ID);

    for case in contract.selection_cases {
        let compiled = compiled_for_rows(&case.rules);
        let authored_before = compiled
            .rules
            .iter()
            .map(|rule| (rule.label.clone(), rule.is_top))
            .collect::<Vec<_>>();
        let selection = compiled
            .resolve_entry_rule(case.explicit_selector.as_deref())
            .unwrap_or_else(|error| panic!("{} unexpectedly failed: {error}", case.id));
        assert_eq!(selection.rule.label, case.expected_label, "{}", case.id);
        assert_eq!(selection.basis.as_str(), case.expected_basis, "{}", case.id);
        assert_eq!(
            compiled
                .rules
                .iter()
                .map(|rule| (rule.label.clone(), rule.is_top))
                .collect::<Vec<_>>(),
            authored_before,
            "{} must not rewrite authored identity",
            case.id
        );
    }

    for case in contract.failure_cases {
        let error = match compiled_for_rows(&case.rules)
            .resolve_entry_rule(case.explicit_selector.as_deref())
        {
            Ok(_) => panic!("{} must reject selection", case.id),
            Err(error) => error,
        };
        assert_eq!(error.code, case.expected_code, "{}", case.id);
        assert_eq!(error.stage, case.expected_stage, "{}", case.id);
        if case.expected_code == "entry_rule_not_found" {
            assert_eq!(
                error.field("entry_rule").and_then(|value| value.as_str()),
                case.explicit_selector.as_deref(),
                "{}",
                case.id
            );
        } else {
            assert!(error.fields.is_empty(), "{}", case.id);
        }
    }
}

#[test]
fn markerless_validation_accepts_rules_and_rejects_zero_rules_first() {
    let markerless = parse_spec("First:\n /x/\n\nSecond:\n /y/\n").unwrap();
    validate(&markerless).expect("one-or-more markerless rules are valid");

    for source in ["", "# no rules\n"] {
        let parsed = parse_spec(source).unwrap();
        let error = validate(&parsed).expect_err("zero rules must fail structural validation");
        let diagnostic = error.diagnostic().expect("portable zero-rule diagnostic");
        assert_eq!(diagnostic.code, "no_rules_defined");
        assert_eq!(diagnostic.stage, "validate_spec");
    }

    let empty = Engine::new(CompiledSpec {
        functions: Vec::new(),
        rules: Vec::new(),
    });
    let error = empty
        .execute_value_with_diagnostics("", &ExecutionOptions::new().with_entry_rule("Missing"))
        .expect_err("structural emptiness must win over explicit selection");
    assert_eq!(error.diagnostic.code.as_deref(), Some("no_rules_defined"));
    assert_eq!(error.diagnostic.stage, "validate_spec");
    assert_eq!(error.diagnostic.top_rule, None);
}

#[test]
fn native_default_and_explicit_execution_apply_contract_precedence() {
    let marked = engine(
        r#"Earlier:
 /x/
 E { return("earlier") }

Marked::
 /x/
 E { return("marked") }

Later::
 /x/
 E { return("later") }
"#,
    );
    assert_eq!(
        marked.execute_value("x", &ExecutionOptions::new()).unwrap(),
        json!("marked")
    );
    assert_eq!(marked.execute("x").unwrap(), json!(["marked"]));
    assert_eq!(
        marked
            .execute_value("x", &ExecutionOptions::new().with_entry_rule("Earlier"))
            .unwrap(),
        json!("earlier")
    );
    assert_eq!(
        marked
            .execute_value("x", &ExecutionOptions::new().with_entry_rule("Later"))
            .unwrap(),
        json!("later")
    );

    let markerless = engine(
        r#"First:
 /x/
 E { return("first") }

Second:
 /x/
 E { return("second") }
"#,
    );
    assert_eq!(
        markerless
            .execute_value("x", &ExecutionOptions::new())
            .unwrap(),
        json!("first")
    );
    assert_eq!(markerless.execute("x").unwrap(), json!(["first"]));
    assert_eq!(
        markerless
            .execute_value("x", &ExecutionOptions::new().with_entry_rule("Second"))
            .unwrap(),
        json!("second")
    );
}

#[test]
fn unknown_explicit_selector_fails_before_user_code_with_portable_identity() {
    let engine = engine(
        r#"Top::
 /x/
 I { exit_now(99) }
"#,
    );
    let error = engine
        .execute_value_with_diagnostics("x", &ExecutionOptions::new().with_entry_rule("Missing"))
        .expect_err("unknown selector must fail before entering Top");
    assert_eq!(error.message(), "entry rule 'Missing' is not defined");
    assert_eq!(
        error.diagnostic.code.as_deref(),
        Some("entry_rule_not_found")
    );
    assert_eq!(error.diagnostic.stage, "select_entry_rule");
    assert_eq!(error.diagnostic.top_rule.as_deref(), Some("Missing"));
    assert_eq!(error.diagnostic.entry_rule.as_deref(), Some("Missing"));
    assert_eq!(error.diagnostic.rule_label.as_deref(), Some("Missing"));
}

#[test]
fn descriptor_retains_order_and_authored_markers_separately_from_selection() {
    let rows = vec![
        RuleRow {
            label: "Earlier".to_string(),
            authored_is_top: false,
        },
        RuleRow {
            label: "Marked".to_string(),
            authored_is_top: true,
        },
        RuleRow {
            label: "Later".to_string(),
            authored_is_top: true,
        },
    ];
    let compiled = compiled_for_rows(&rows);
    let selection = compiled.resolve_entry_rule(Some("Earlier")).unwrap();
    assert_eq!(selection.rule.label, "Earlier");

    let descriptor = compiled.descriptor_state();
    assert_eq!(descriptor.meta.entry_rule_contract, ENTRY_RULE_CONTRACT_ID);
    assert_eq!(
        descriptor.meta.definition_order,
        ["Earlier", "Marked", "Later"]
    );
    assert!(!descriptor.spec["Earlier"].meta.is_top);
    assert!(descriptor.spec["Marked"].meta.is_top);
    assert!(descriptor.spec["Later"].meta.is_top);
}

#[test]
fn neutral_strict_rows_remain_authored_edge_graph_analysis() {
    for case in contract().strict_cases {
        let source = match case.id.as_str() {
            "explicit_selection_is_not_reference" => "A:\n /a/\n\nB:\n /b/\n",
            "marker_selection_is_not_reference" => {
                "Top::\n /x/ -> Child\n\nChild:\n /x/ -> Child\n"
            }
            "closed_reference_cycle_has_no_unused_rules" => "A:\n /a/ -> B\n\nB:\n /b/ -> A\n",
            other => panic!("unhandled neutral strict case {other}"),
        };
        let parsed = parse_spec(source).unwrap();
        if case.expected_unused.is_empty() {
            validate_with_options(&parsed, true)
                .unwrap_or_else(|error| panic!("{} unexpectedly failed: {error}", case.id));
        } else {
            let error = match validate_with_options(&parsed, true) {
                Ok(()) => panic!("{} must reject unused rules", case.id),
                Err(error) => error.to_string(),
            };
            assert!(
                error.contains(&case.expected_unused.join(", ")),
                "{}: {error}",
                case.id
            );
        }
    }
}
