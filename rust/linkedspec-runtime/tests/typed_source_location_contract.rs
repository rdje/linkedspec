#![allow(unexpected_cfgs)]
#![cfg(linkedspec_typed_source_red)]

//! FUTURE-PARITY-BACKLOG.14.2.2.0.3 — dormant Rust typed source-location contract.
//!
//! Before admission, run the immutable-value contract with:
//!
//! `source tools/project_data_env.sh`, then run
//! `RUSTFLAGS='--cfg linkedspec_typed_source_red' cargo test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test typed_source_location_contract`.
//!
//! The projection leaf additionally supplies `--cfg linkedspec_typed_source_projection_red`.

use linkedspec_runtime::source_location::{
    DerivedTextPolicy, Position, SourceAuthority, SourceLocationContext, SourceLocationError, Span,
};
use serde_json::{Value, json};
use std::collections::{BTreeMap, HashMap};

const CONTRACT_JSON: &str = include_str!(concat!(
    env!("CARGO_MANIFEST_DIR"),
    "/../../capability_conformance/typed_source_location_contract.json"
));

fn contract() -> Value {
    serde_json::from_str(CONTRACT_JSON).expect("typed source-location contract JSON")
}

fn context() -> SourceLocationContext {
    SourceLocationContext::new(
        "typed_source_fixture_rule",
        "typed_source_fixture_invocation",
    )
}

fn decoded_sources(contract: &Value) -> BTreeMap<String, String> {
    contract["sources"]
        .as_array()
        .expect("source fixtures")
        .iter()
        .map(|source| {
            (
                source["id"].as_str().expect("source id").to_owned(),
                source["decoded_text"]
                    .as_str()
                    .expect("decoded source text")
                    .to_owned(),
            )
        })
        .collect()
}

fn position(
    authority: &SourceAuthority,
    source_id: &str,
    offset: u64,
    context: &SourceLocationContext,
) -> Position {
    authority
        .position(source_id, offset, context)
        .unwrap_or_else(|error| panic!("position {source_id}:{offset} failed: {error:?}"))
}

fn expect_error<T>(result: Result<T, SourceLocationError>, label: &str) -> SourceLocationError {
    match result {
        Ok(_) => panic!("{label} unexpectedly succeeded"),
        Err(error) => error,
    }
}

fn assert_error(
    contract: &Value,
    diagnostic_id: &str,
    error: SourceLocationError,
    expected_context: &[(&str, Value)],
) {
    let diagnostic = contract["diagnostics"]
        .as_array()
        .expect("diagnostics")
        .iter()
        .find(|diagnostic| diagnostic["id"] == diagnostic_id)
        .unwrap_or_else(|| panic!("missing diagnostic fixture {diagnostic_id}"));
    let record = error.as_record();

    assert_eq!(record["code"], diagnostic["code"], "{diagnostic_id}");
    assert_eq!(record["phase"], diagnostic["phase"], "{diagnostic_id}");
    for field in diagnostic["required_context"]
        .as_array()
        .expect("required diagnostic context")
    {
        let field = field.as_str().expect("context field");
        assert!(
            record.get(field).is_some(),
            "{diagnostic_id} is missing required context {field}"
        );
    }
    for (field, expected) in expected_context {
        assert_eq!(&record[*field], expected, "{diagnostic_id} context {field}");
    }
    for forbidden in [
        "decoded_text",
        "source_text",
        "path",
        "match",
        "parser_state",
        "host_reference",
    ] {
        assert!(
            record.get(forbidden).is_none(),
            "{diagnostic_id} leaked {forbidden}"
        );
    }
}

#[test]
fn immutable_values_match_all_neutral_positions_spans_and_derived_text() {
    let contract = contract();
    assert_eq!(
        contract["contract_id"],
        "linkedspec-typed-source-location-v1"
    );
    assert_eq!(contract["expected_counts"]["sources"], 3);
    assert_eq!(contract["expected_counts"]["position_conversions"], 7);
    assert_eq!(contract["expected_counts"]["direct_spans"], 6);
    assert_eq!(contract["expected_counts"]["derived_text_cases"], 3);

    let sources = decoded_sources(&contract);
    let authority = SourceAuthority::new(&sources);
    let context = context();

    for fixture in contract["position_conversions"]
        .as_array()
        .expect("position conversions")
    {
        let source_id = fixture["source_id"].as_str().expect("position source");
        let offset = fixture["offset"].as_u64().expect("position offset");
        let value = position(&authority, source_id, offset, &context);
        assert_eq!(
            value.as_record(),
            json!({"source_id": source_id, "offset": offset}),
            "{} value",
            fixture["id"]
        );
        assert_eq!(
            authority
                .coordinates(&value, &context)
                .expect("derive coordinates")
                .as_record(),
            json!({
                "source_id": source_id,
                "offset": offset,
                "line": fixture["line"],
                "column": fixture["column"],
                "utf8_byte_offset": fixture["utf8_byte_offset"],
            }),
            "{} coordinates",
            fixture["id"]
        );
    }

    let stable_position = position(&authority, "unicode", 1, &context);
    let mut detached_position = stable_position.as_record();
    detached_position["offset"] = json!(99);
    assert_eq!(stable_position.as_record()["offset"], 1);

    let mut spans = HashMap::<String, Span>::new();
    for fixture in contract["direct_spans"].as_array().expect("direct spans") {
        let source_id = fixture["source_id"].as_str().expect("span source");
        let start = fixture["start"].as_u64().expect("span start");
        let end = fixture["end"].as_u64().expect("span end");
        let provenance = fixture["provenance"].as_str().expect("span provenance");
        let span = authority
            .direct_span(
                &position(&authority, source_id, start, &context),
                &position(&authority, source_id, end, &context),
                provenance,
                &context,
            )
            .expect("construct direct span");
        assert_eq!(
            span.as_record(),
            json!({
                "source_id": source_id,
                "start": start,
                "end": end,
                "provenance": provenance,
            }),
            "{} value",
            fixture["id"]
        );
        assert_eq!(
            authority
                .materialize(&span, &context)
                .expect("materialize direct span"),
            fixture["expected_text"],
            "{} text",
            fixture["id"]
        );
        spans.insert(
            fixture["id"].as_str().expect("span fixture id").to_owned(),
            span,
        );
    }

    for fixture in contract["derived_text_cases"]
        .as_array()
        .expect("derived-text cases")
    {
        let ordered_spans = fixture["span_ids"]
            .as_array()
            .expect("derived span ids")
            .iter()
            .map(|span_id| spans[span_id.as_str().expect("derived span id")].clone())
            .collect::<Vec<_>>();
        let derived = authority
            .derived_text(
                DerivedTextPolicy::ConcatenateInOrder,
                &ordered_spans,
                &context,
            )
            .expect("construct derived text");
        assert_eq!(
            derived.as_record(),
            json!({
                "policy": "concatenate_in_order",
                "spans": ordered_spans.iter().map(Span::as_record).collect::<Vec<_>>(),
            }),
            "{} value",
            fixture["id"]
        );
        assert_eq!(
            authority
                .materialize(&derived, &context)
                .expect("materialize derived text"),
            fixture["expected_text"],
            "{} text",
            fixture["id"]
        );
    }
}

#[test]
fn immutable_authority_owns_text_and_reports_four_exact_private_errors() {
    let contract = contract();
    let mut sources = decoded_sources(&contract);
    let authority = SourceAuthority::new(&sources);
    let context = context();

    sources.insert("unicode".to_owned(), "changed".to_owned());
    let owned_span = authority
        .direct_span(
            &position(&authority, "unicode", 0, &context),
            &position(&authority, "unicode", 1, &context),
            "input",
            &context,
        )
        .expect("construct authority-owned span");
    assert_eq!(
        authority
            .materialize(&owned_span, &context)
            .expect("materialize authority-owned text"),
        "é"
    );

    let source_mismatch = expect_error(
        authority.direct_span(
            &position(&authority, "unicode", 0, &context),
            &position(&authority, "ascii", 1, &context),
            "input",
            &context,
        ),
        "source mismatch",
    );
    assert_error(
        &contract,
        "source_mismatch",
        source_mismatch,
        &[
            ("rule_role", json!("typed_source_fixture_rule")),
            ("invocation_role", json!("typed_source_fixture_invocation")),
            ("source_id", json!("unicode")),
            ("other_source_id", json!("ascii")),
        ],
    );

    let out_of_range = expect_error(
        authority.position("unicode", 5, &context),
        "position out of range",
    );
    assert_error(
        &contract,
        "position_out_of_range",
        out_of_range,
        &[
            ("rule_role", json!("typed_source_fixture_rule")),
            ("invocation_role", json!("typed_source_fixture_invocation")),
            ("source_id", json!("unicode")),
            ("position_offset", json!(5)),
            ("source_length", json!(4)),
        ],
    );

    let reversed = expect_error(
        authority.direct_span(
            &position(&authority, "unicode", 2, &context),
            &position(&authority, "unicode", 1, &context),
            "capture",
            &context,
        ),
        "reversed span",
    );
    assert_error(
        &contract,
        "reversed_span",
        reversed,
        &[
            ("rule_role", json!("typed_source_fixture_rule")),
            ("invocation_role", json!("typed_source_fixture_invocation")),
            ("source_id", json!("unicode")),
            ("start_offset", json!(2)),
            ("end_offset", json!(1)),
        ],
    );

    let foreign_sources = BTreeMap::from([("foreign".to_owned(), "foreign text".to_owned())]);
    let foreign_authority = SourceAuthority::new(&foreign_sources);
    let foreign_span = foreign_authority
        .direct_span(
            &position(&foreign_authority, "foreign", 0, &context),
            &position(&foreign_authority, "foreign", 1, &context),
            "input",
            &context,
        )
        .expect("construct foreign span");
    let invalid_provenance = expect_error(
        authority.derived_text(
            DerivedTextPolicy::ConcatenateInOrder,
            &[foreign_span],
            &context,
        ),
        "invalid derived provenance",
    );
    assert_error(
        &contract,
        "invalid_derived_provenance",
        invalid_provenance,
        &[
            ("rule_role", json!("typed_source_fixture_rule")),
            ("invocation_role", json!("typed_source_fixture_invocation")),
            ("provenance_index", json!(0)),
            ("source_id", json!("foreign")),
        ],
    );
}

#[cfg(linkedspec_typed_source_projection_red)]
mod projections {
    use super::{CONTRACT_JSON, contract};
    use linkedspec_core::compiler::compile;
    use linkedspec_core::types::CompiledSpec;
    use linkedspec_core::validation::validate;
    use linkedspec_runtime::engine::{Engine, ExecutionOptions};
    use linkedspec_runtime::runtime::{
        typed_source_compatibility_aliases, typed_source_projection_rows,
    };
    use linkedspec_runtime::source_emitter::{
        GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
        validate_generated_parser_plan_v2,
    };
    use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
    use serde_json::{Value, json};
    use std::collections::BTreeSet;

    const COMPLETE_MARK_JSON: &str = include_str!(concat!(
        env!("CARGO_MANIFEST_DIR"),
        "/../../capability_conformance/complete_named_mark_contract.json"
    ));
    const CURSOR_SOURCE: &str = include_str!(concat!(
        env!("CARGO_MANIFEST_DIR"),
        "/tests/corpus/capability_cursor_control_surface/input.spec"
    ));
    const CURSOR_INPUT: &str = include_str!(concat!(
        env!("CARGO_MANIFEST_DIR"),
        "/tests/corpus/capability_cursor_control_surface/input.txt"
    ));
    const CURSOR_EXPECTED: &str = include_str!(concat!(
        env!("CARGO_MANIFEST_DIR"),
        "/tests/corpus/capability_cursor_control_surface/expected.json"
    ));
    const ALIAS_SOURCE: &str = r#"Top::OR{1,1}
 /ab/
 I { started = capture_slice_here() }
 E { return(array(started, capture_from_rule_start(), capture_len_from_rule_start(), capture_slice_length(), capture_rest_length())) }
"#;

    const TOP_PLAN: &[GeneratedPlanRow] = &[GeneratedPlanRow {
        label: "Top",
        family: "rep_acode",
    }];
    const TOP_CHILD_PLAN: &[GeneratedPlanRow] = &[
        GeneratedPlanRow {
            label: "Top",
            family: "default",
        },
        GeneratedPlanRow {
            label: "Child",
            family: "default",
        },
    ];
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

    fn compile_source(source: &str) -> CompiledSpec {
        let parsed = parse_spec_with_user_functions(source).expect("parse typed-source fixture");
        validate(&parsed).expect("validate typed-source fixture");
        compile(&parsed).expect("compile typed-source fixture")
    }

    fn assert_carriers(
        source: &str,
        input: &str,
        identity: &str,
        plan: &[GeneratedPlanRow],
        expected: &Value,
    ) {
        let compiled = compile_source(source);
        assert_eq!(
            Engine::new(compiled.clone())
                .execute_value(input, &ExecutionOptions::new())
                .expect("execute native typed-source fixture"),
            *expected,
            "native carrier for {identity}"
        );

        let compiled_json =
            serde_json::to_string(&compiled).expect("serialize typed-source fixture");
        let reconstructed: CompiledSpec =
            serde_json::from_str(&compiled_json).expect("reconstruct typed-source fixture");
        assert_eq!(
            Engine::new(reconstructed)
                .execute_value(input, &ExecutionOptions::new())
                .expect("execute reconstructed typed-source fixture"),
            *expected,
            "reconstructed carrier for {identity}"
        );

        validate_generated_parser_plan_v2(
            &compiled_json,
            plan,
            identity,
            GENERATED_SOURCE_CONTRACT,
        )
        .expect("validate generated typed-source fixture");
        assert_eq!(
            execute_generated_parser_v2(
                &compiled_json,
                plan,
                input,
                identity,
                GENERATED_SOURCE_CONTRACT,
            )
            .expect("execute generated typed-source fixture"),
            *expected,
            "generated-plan carrier for {identity}"
        );
    }

    #[test]
    fn projection_catalog_is_exact_complete_unique_and_detached() {
        let contract = contract();
        let mut rows = typed_source_projection_rows();
        assert_eq!(rows, contract["helper_projections"]);

        let mut names = Vec::new();
        for family in contract["helper_projection_schema"]["families"]
            .as_array()
            .expect("projection families")
        {
            names.extend(
                rows[family.as_str().expect("projection family")]
                    .as_array()
                    .expect("projection rows")
                    .iter()
                    .map(|row| row[0].as_str().expect("projection name").to_owned()),
            );
        }
        assert_eq!(names.len(), 92);
        assert_eq!(names.iter().collect::<BTreeSet<_>>().len(), 92);
        assert_eq!(
            typed_source_compatibility_aliases(),
            contract["compatibility_aliases"]
        );
        assert_eq!(
            contract["compatibility_aliases"]
                .as_array()
                .expect("compatibility aliases")
                .len(),
            7
        );

        rows["capture_mark"][0][1] = json!("wrong");
        assert_eq!(
            typed_source_projection_rows(),
            contract["helper_projections"]
        );
    }

    #[test]
    fn projections_preserve_unicode_marks_capture_mutation_and_cursor_restore_on_all_carriers() {
        let mark_contract: Value =
            serde_json::from_str(COMPLETE_MARK_JSON).expect("complete named-mark contract JSON");
        assert_carriers(
            mark_contract["fixture"]["spec_source"]
                .as_str()
                .expect("named-mark source"),
            mark_contract["fixture"]["input"]
                .as_str()
                .expect("named-mark input"),
            "typed-source/complete-named-mark.spec",
            TOP_CHILD_PLAN,
            &mark_contract["fixture"]["expected"],
        );

        let cursor_expected: Value =
            serde_json::from_str(CURSOR_EXPECTED).expect("cursor-control expected JSON");
        assert_carriers(
            CURSOR_SOURCE,
            CURSOR_INPUT,
            "typed-source/cursor-control.spec",
            TOP_DONE_PLAN,
            &cursor_expected,
        );

        assert_carriers(
            ALIAS_SOURCE,
            "é🙂  ab",
            "typed-source/compatibility-aliases.spec",
            TOP_PLAN,
            &json!([null, "é🙂  ", 4, 4, 6]),
        );

        assert_eq!(
            serde_json::from_str::<Value>(CONTRACT_JSON).expect("typed contract")["compatibility_aliases"],
            typed_source_compatibility_aliases()
        );
    }
}
