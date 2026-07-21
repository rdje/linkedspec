//! FUTURE-PARITY-BACKLOG.10.4.0.2 — pinned Unicode rule-label contract.

use linkedspec_core::ast::BodyElementKind;
use linkedspec_core::compiler::compile;
use linkedspec_core::error::LinkedSpecError;
use linkedspec_core::parser::parse_spec;
use linkedspec_core::unicode_rule_label::{
    UNICODE_RULE_LABEL_CONTRACT, UNICODE_RULE_LABEL_DATA_SHA256, UNICODE_RULE_LABEL_VERSION,
    is_rule_label, take_rule_label_prefix,
};
use linkedspec_core::validation::validate;

const DECOMPOSED_TOP: &str = "To\u{0308}p";

#[test]
fn generated_classifier_exposes_the_pinned_contract_and_boundaries() {
    assert_eq!(
        UNICODE_RULE_LABEL_CONTRACT,
        "linkedspec-unicode-rule-label-v1"
    );
    assert_eq!(UNICODE_RULE_LABEL_VERSION, "17.0.0");
    assert_eq!(
        UNICODE_RULE_LABEL_DATA_SHA256,
        "d1b00bda47306e61ee20a7f63db783f98b15d8d15b876c7506bc4b79ecebc0bb"
    );

    for label in [
        "ASCII_123",
        "1StartsWithDigit",
        "_",
        "Töp",
        DECOMPOSED_TOP,
        "Δelta",
        "變體",
        "a·b",
        "𐐀Rule",
    ] {
        assert!(is_rule_label(label), "valid fixture rejected: {label:?}");
    }
    for label in [
        "", "Bad-Name", "Bad Name", "😀", "A:B", "A/B", "$Top", "A\nB",
    ] {
        assert!(!is_rule_label(label), "invalid fixture accepted: {label:?}");
    }
    assert_eq!(take_rule_label_prefix("Töp[2]"), Some(("Töp", "[2]")));
    assert_eq!(take_rule_label_prefix("😀Top"), None);
}

#[test]
fn parser_uses_one_unicode_label_class_for_headers_and_all_edge_forms() {
    let source = format!(
        "Töp::AND\n /x/ -> Δelta | 變體[2]\n\nΔelta:\n /x/\n\n變體:\n /x/\n\n{DECOMPOSED_TOP}:\n /x/\n\n1Start:\n /x/\n\n_:\n /x/\n"
    );
    let parsed = parse_spec(&source).expect("parse Unicode declarations and action targets");
    assert_eq!(
        parsed
            .rules
            .iter()
            .map(|rule| rule.header.label.as_str())
            .collect::<Vec<_>>(),
        ["Töp", "Δelta", "變體", DECOMPOSED_TOP, "1Start", "_"]
    );
    let BodyElementKind::ActionEdge { targets, .. } = &parsed.rules[0].body[1].kind else {
        panic!("expected action edge");
    };
    assert_eq!(
        targets
            .iter()
            .map(|target| (target.label.as_str(), target.index))
            .collect::<Vec<_>>(),
        [("Δelta", 2), ("變體", 2)]
    );

    let blind =
        parse_spec("Töp::\n => 變體 [3]\n\n變體:\n /x/\n").expect("parse Unicode blind target");
    let BodyElementKind::BlindEdge { target, index, .. } = &blind.rules[0].body[0].kind else {
        panic!("expected blind edge");
    };
    assert_eq!((target.as_str(), *index), ("變體", Some(3)));

    let bare = parse_spec(&format!(
        "Töp::OR\n {DECOMPOSED_TOP} [1] | 1Start\n\n{DECOMPOSED_TOP}:\n /x/\n\n1Start:\n /x/\n"
    ))
    .expect("parse Unicode bare targets");
    let BodyElementKind::BareEdge { targets, .. } = &bare.rules[0].body[0].kind else {
        panic!("expected bare edge");
    };
    assert_eq!(
        targets
            .iter()
            .map(|target| (target.label.as_str(), target.index))
            .collect::<Vec<_>>(),
        [(DECOMPOSED_TOP, Some(1)), ("1Start", None)]
    );
}

#[test]
fn exact_scalar_identity_survives_validation_and_compilation() {
    let source = format!(
        "Töp::AND\n -> {DECOMPOSED_TOP}\n -> töp\n\n{DECOMPOSED_TOP}:\n /a/\n\ntöp:\n /b/\n"
    );
    let parsed = parse_spec(&source).expect("parse distinct Unicode identities");
    validate(&parsed).expect("validate distinct Unicode identities");
    let compiled = compile(&parsed).expect("compile distinct Unicode identities");
    assert_eq!(
        compiled
            .rules
            .iter()
            .map(|rule| rule.label.as_str())
            .collect::<Vec<_>>(),
        ["Töp", DECOMPOSED_TOP, "töp"]
    );
    assert_ne!("Töp", DECOMPOSED_TOP);
    assert_ne!("Töp", "töp");
}

#[test]
fn parser_never_accepts_a_non_contract_sequence_as_the_declaration_label() {
    for label in ["Bad-Name", "Bad Name", "😀", "A:B", "A/B", "$Top"] {
        let source = format!("{label}::\n /x/\n");
        if let Ok(parsed) = parse_spec(&source) {
            assert!(
                parsed.rules.iter().all(|rule| rule.header.label != label),
                "invalid sequence became a declaration label: {label:?}"
            );
        }
    }
}

#[test]
fn validator_rejects_invalid_labels_in_programmatic_asts() {
    let mut invalid_declaration = parse_spec("Top::\n /x/\n").expect("parse declaration fixture");
    invalid_declaration.rules[0].header.label = "Bad-Name".to_string();
    assert_invalid_label(validate(&invalid_declaration), "declaration", "Bad-Name");

    let mut invalid_target =
        parse_spec("Top::AND\n -> Child\n\nChild:\n /x/\n").expect("parse target fixture");
    let BodyElementKind::ActionEdge { targets, .. } = &mut invalid_target.rules[0].body[0].kind
    else {
        panic!("expected action edge");
    };
    targets[0].label = "Bad-Target".to_string();
    assert_invalid_label(validate(&invalid_target), "edge_target", "Bad-Target");
}

fn assert_invalid_label(result: Result<(), LinkedSpecError>, role: &str, label: &str) {
    let error = result.expect_err("invalid programmatic label must fail validation");
    let diagnostic = error
        .diagnostic()
        .expect("invalid label uses portable diagnostic");
    assert_eq!(diagnostic.code, "invalid_rule_label");
    assert_eq!(diagnostic.stage, "validate_rule_labels");
    assert_eq!(diagnostic.field("role"), Some(&serde_json::json!(role)));
    assert_eq!(diagnostic.field("label"), Some(&serde_json::json!(label)));
}
