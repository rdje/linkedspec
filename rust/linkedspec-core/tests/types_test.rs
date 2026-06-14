//! Tests for core type serialization/deserialization.

use linkedspec_core::types::{HandlerIR, HandlerKind, ParseMode};

#[test]
fn handler_ir_json_roundtrip() {
    let ir = HandlerIR {
        kind: HandlerKind::Default,
        label: "TestRule".into(),
        parse_mode: ParseMode::Seek,
        preamble: Some("declare(array, results)".into()),
        lxcode: None,
        lscode: Some("push_value(array(results), scalar(retv))".into()),
        lecode: None,
        ecode: Some("return(array_copy(array(results)))".into()),
        excode: None,
        itcode: None,
        acodes_ref: Some(vec!["action_code_1".into()]),
        bcodes_ref: None,
        bcalls_ref: None,
        and_icode: None,
        rep_min: None,
        rep_max: None,
    };

    let json = serde_json::to_string_pretty(&ir).unwrap();
    let parsed: HandlerIR = serde_json::from_str(&json).unwrap();

    assert_eq!(parsed.kind, HandlerKind::Default);
    assert_eq!(parsed.label, "TestRule");
    assert_eq!(parsed.parse_mode, ParseMode::Seek);
    assert_eq!(parsed.preamble, Some("declare(array, results)".into()));
    assert_eq!(parsed.acodes_ref, Some(vec!["action_code_1".into()]));
}

#[test]
fn handler_ir_rep_variant_roundtrip() {
    let ir = HandlerIR {
        kind: HandlerKind::RepAcode,
        label: "Repeated".into(),
        parse_mode: ParseMode::Seek,
        preamble: Some("declare(array, acc)".into()),
        lxcode: None,
        lscode: Some("push_value(array(acc), retv)".into()),
        lecode: None,
        ecode: Some("return(array_copy(array(acc)))".into()),
        excode: Some("exit_fallback".into()),
        itcode: Some("per_iter".into()),
        acodes_ref: Some(vec!["code0".into(), "code1".into()]),
        bcodes_ref: None,
        bcalls_ref: None,
        and_icode: None,
        rep_min: Some(1),
        rep_max: None, // unbounded
    };

    let json = serde_json::to_string_pretty(&ir).unwrap();
    let parsed: HandlerIR = serde_json::from_str(&json).unwrap();

    assert_eq!(parsed.kind, HandlerKind::RepAcode);
    assert!(parsed.is_rep_variant());
    assert_eq!(parsed.rep_min, Some(1));
    assert_eq!(parsed.rep_max, None);
    assert_eq!(parsed.acodes_ref.unwrap().len(), 2);
}

#[test]
fn parse_mode_serde() {
    assert_eq!(
        serde_json::to_string(&ParseMode::Seek).unwrap(),
        "\"seek\""
    );
    assert_eq!(
        serde_json::to_string(&ParseMode::Consume).unwrap(),
        "\"consume\""
    );
    assert_eq!(
        serde_json::from_str::<ParseMode>("\"seek\"").unwrap(),
        ParseMode::Seek
    );
}
