//! FUTURE-PARITY-BACKLOG.10.4.1 — Rust semantic source/outcome foundation.

use linkedspec_runtime::semantic_index::{
    SemanticIndex, SemanticIndexOptions, SemanticSnapshotState, SemanticSourceDetail,
    SemanticSourceSpan,
};

const GRAPH: &[u8] =
    include_bytes!("../../../capability_conformance/semantic_introspection/graph.spec");
const PRIVACY: &[u8] =
    include_bytes!("../../../capability_conformance/semantic_introspection/privacy.spec");
const FAILED: &[u8] =
    include_bytes!("../../../capability_conformance/semantic_introspection/failed.spec");

fn options(name: &str, detail: SemanticSourceDetail) -> SemanticIndexOptions {
    SemanticIndexOptions::new(name, detail)
}

#[test]
fn graph_construction_retains_opaque_compiled_and_generated_authority() {
    let mut source = GRAPH.to_vec();
    let index =
        SemanticIndex::from_utf8(&source, options("graph.spec", SemanticSourceDetail::Text))
            .expect("construct graph semantic foundation");
    source.fill(b'!');

    assert_eq!(index.snapshot().state, SemanticSnapshotState::Compiled);
    assert!(!index.snapshot().has_execution);
    assert!(index.parsed_authority_present());
    assert!(index.validated_authority_present());
    assert!(index.compiled_authority_present());
    assert_eq!(index.compilation_diagnostic(), None);
    assert_eq!(
        index
            .source_identity()
            .expect("source identity")
            .content_digest
            .as_deref(),
        Some("sha256:28505ba8524900f55e11452988acc6b7d35dccbccc1c0cb6194c8cda80a0cbcf")
    );
    assert_eq!(index.source_identity().expect("identity").byte_length, 128);
    assert_eq!(
        index.source_identity().expect("identity").logical_name,
        "graph.spec"
    );
    assert_eq!(
        index.entry_selection().expect("entry selection").basis,
        "first_authored_marker"
    );

    let mut plan = index
        .generated_plan()
        .expect("plan access")
        .expect("generated plan authority");
    assert_eq!(plan.contract_id, "linkedspec-generated-source-v2");
    assert_eq!(plan.format_version, 2);
    assert_eq!(plan.source_identity, "graph.spec");
    assert_eq!(
        plan.rows
            .iter()
            .map(|row| (row.label.as_str(), row.family.as_str()))
            .collect::<Vec<_>>(),
        [("Top", "and_acode_seq"), ("Child", "rep_acode")]
    );
    plan.rows[0].label = "/tmp/private.spec".to_string();
    assert_eq!(
        index
            .generated_plan()
            .expect("plan access")
            .expect("fresh plan")
            .rows[0]
            .label,
        "Top",
        "returned plan mutation cannot alter the index"
    );
    assert!(!format!("{index:?}").contains("return(\"first\")"));
}

#[test]
fn unicode_bytes_and_decoded_text_converge_on_exact_scalar_coordinates() {
    let raw =
        SemanticIndex::from_utf8(PRIVACY, options("privacy.spec", SemanticSourceDetail::Text))
            .expect("construct raw Unicode source");
    let decoded = std::str::from_utf8(PRIVACY).expect("fixture UTF-8");
    let text =
        SemanticIndex::from_source(decoded, options("privacy.spec", SemanticSourceDetail::Text))
            .expect("construct decoded Unicode source");

    assert_eq!(
        raw.source_identity().expect("raw identity"),
        text.source_identity().expect("text identity")
    );
    assert_eq!(raw.source_identity().expect("identity").byte_length, 13);
    assert_eq!(raw.source_identity().expect("identity").scalar_length, 11);
    assert_eq!(
        raw.source_span_for_bytes(0, 6).expect("header span"),
        SemanticSourceSpan {
            start_byte: 0,
            end_byte: 6,
            start_line: 1,
            start_column: 1,
            end_line: 1,
            end_column: 6,
        }
    );
    assert_eq!(
        raw.source_span_for_bytes(8, 12).expect("regex span"),
        SemanticSourceSpan {
            start_byte: 8,
            end_byte: 12,
            start_line: 2,
            start_column: 2,
            end_line: 2,
            end_column: 5,
        }
    );
    assert_eq!(
        raw.source_excerpt_for_bytes(0, 6).expect("header excerpt"),
        "Töp::"
    );
    assert_eq!(
        raw.source_excerpt_for_bytes(8, 12).expect("regex excerpt"),
        "/é/"
    );
    assert_eq!(
        raw.source_span_for_scalars(0, 5).expect("scalar span"),
        raw.source_span_for_bytes(0, 6).expect("byte span")
    );
    assert_eq!(
        raw.locate_exact("/é/", 0)
            .expect("exact lookup")
            .expect("fixture occurrence"),
        raw.source_span_for_bytes(8, 12).expect("expected span")
    );
    assert_eq!(
        raw.source_span_for_bytes(2, 3)
            .expect_err("mid-scalar range must fail")
            .code,
        "semantic_source_boundary_invalid"
    );
}

#[test]
fn failed_validation_remains_source_aware_and_immutable() {
    let index =
        SemanticIndex::from_utf8(FAILED, options("failed.spec", SemanticSourceDetail::Text))
            .expect("construct failed semantic foundation");
    assert_eq!(
        index.snapshot().state,
        SemanticSnapshotState::FailedCompilation
    );
    assert!(index.parsed_authority_present());
    assert!(!index.validated_authority_present());
    assert!(!index.compiled_authority_present());
    assert_eq!(index.generated_plan().expect("plan access"), None);
    let mut diagnostic = index.compilation_diagnostic().expect("portable failure");
    assert_eq!(diagnostic.code, "bare_edge_target_undefined");
    assert_eq!(diagnostic.stage, "normalize_edges");
    assert_eq!(
        diagnostic.message,
        "bare edge in rule 'Top' targets undefined rule 'Missing'"
    );
    assert_eq!(
        index
            .source_excerpt_for_bytes(6, 13)
            .expect("target excerpt"),
        "Missing"
    );
    diagnostic.code = "mutated".to_string();
    assert_eq!(
        index.compilation_diagnostic().expect("fresh failure").code,
        "bare_edge_target_undefined"
    );
}

#[test]
fn source_ceiling_is_enforced_before_foundation_data_leaves_the_index() {
    let none =
        SemanticIndex::from_utf8(PRIVACY, options("privacy.spec", SemanticSourceDetail::None))
            .expect("construct source-hidden index");
    assert_eq!(
        none.source_identity()
            .expect_err("none ceiling forbids identity")
            .code,
        "semantic_source_detail_forbidden"
    );
    assert_eq!(
        none.generated_plan()
            .expect_err("none ceiling forbids plan identity")
            .code,
        "semantic_source_detail_forbidden"
    );
    assert!(!format!("{none:?}").contains("privacy.spec"));

    let identity = SemanticIndex::from_utf8(
        PRIVACY,
        options("privacy.spec", SemanticSourceDetail::Identity),
    )
    .expect("construct identity-only index");
    assert_eq!(
        identity
            .source_identity()
            .expect("identity allowed")
            .content_digest,
        None
    );
    assert_eq!(
        identity
            .source_span_for_bytes(0, 6)
            .expect_err("identity ceiling forbids spans")
            .code,
        "semantic_source_detail_forbidden"
    );

    let span =
        SemanticIndex::from_utf8(PRIVACY, options("privacy.spec", SemanticSourceDetail::Span))
            .expect("construct span index");
    assert!(span.source_span_for_bytes(0, 6).is_ok());
    assert_eq!(
        span.source_excerpt_for_bytes(0, 6)
            .expect_err("span ceiling forbids text")
            .code,
        "semantic_source_detail_forbidden"
    );
}

#[test]
fn malformed_utf8_and_invalid_options_fail_before_language_compilation() {
    let malformed = SemanticIndex::from_utf8(
        &[0xC3, 0x28],
        options("bad.spec", SemanticSourceDetail::Text),
    )
    .expect_err("malformed UTF-8 must fail");
    assert_eq!(malformed.stage, "decode_source");
    assert_eq!(malformed.code, "semantic_index_invalid_utf8");

    let logical_name =
        SemanticIndex::from_utf8(GRAPH, options("private\npath", SemanticSourceDetail::Text))
            .expect_err("multiline logical name must fail");
    assert_eq!(logical_name.stage, "validate_options");
    assert_eq!(logical_name.code, "semantic_index_invalid_option");

    let selector = SemanticIndex::from_utf8(
        GRAPH,
        options("graph.spec", SemanticSourceDetail::Text).with_entry_rule("Bad-Rule"),
    )
    .expect_err("invalid rule-label selector must fail");
    assert_eq!(selector.stage, "validate_options");
    assert_eq!(selector.code, "semantic_index_invalid_option");
}

#[test]
fn unknown_exact_entry_selector_is_retained_as_a_failed_portable_outcome() {
    let index = SemanticIndex::from_utf8(
        GRAPH,
        options("graph.spec", SemanticSourceDetail::Span).with_entry_rule("Missing"),
    )
    .expect("unknown selector is a language outcome, not a constructor failure");
    assert_eq!(
        index.snapshot().state,
        SemanticSnapshotState::FailedCompilation
    );
    assert!(index.parsed_authority_present());
    assert!(index.validated_authority_present());
    assert!(!index.compiled_authority_present());
    let diagnostic = index.compilation_diagnostic().expect("selection failure");
    assert_eq!(diagnostic.code, "entry_rule_not_found");
    assert_eq!(diagnostic.stage, "select_entry_rule");
}
