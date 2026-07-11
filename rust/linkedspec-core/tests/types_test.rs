//! Tests for core type serialization/deserialization and RuntimeValue semantics.

use linkedspec_core::ast::RuleMode;
use linkedspec_core::types::{AcodeEntry, CompiledRule, CompiledSpec, ParseMode, RuntimeValue};

#[test]
fn parse_mode_serde() {
    assert_eq!(serde_json::to_string(&ParseMode::Seek).unwrap(), "\"seek\"");
    assert_eq!(
        serde_json::to_string(&ParseMode::Consume).unwrap(),
        "\"consume\""
    );
    assert_eq!(
        serde_json::from_str::<ParseMode>("\"seek\"").unwrap(),
        ParseMode::Seek
    );
    assert_eq!(
        serde_json::from_str::<ParseMode>("\"consume\"").unwrap(),
        ParseMode::Consume
    );
}

#[test]
fn compiled_rule_json_roundtrip() {
    let rule = CompiledRule {
        label: "TestRule".into(),
        is_top: true,
        parse_mode: ParseMode::Seek,
        mode: RuleMode::Default,
        regex_patterns: vec!["hello".into(), "world".into()],
        dependency_refs: Vec::new(),
        acode_dispatch: vec![AcodeEntry {
            regex_idx: 0,
            child_label: "Child".into(),
            child_regex_idx: 0,
            code: None,
            fluent_chain: Vec::new(),
            has_parent_regex: true,
        }],
        bcode_dispatch: Vec::new(),
        preamble: None,
        lxcode: None,
        lscode: None,
        lecode: None,
        ecode: None,
        excode: None,
        itcode: None,
        rep_min: None,
        rep_max: None,
    };

    let json = serde_json::to_string_pretty(&rule).unwrap();
    let parsed: CompiledRule = serde_json::from_str(&json).unwrap();

    assert_eq!(parsed.label, "TestRule");
    assert!(parsed.is_top);
    assert_eq!(parsed.parse_mode, ParseMode::Seek);
    assert_eq!(parsed.regex_patterns.len(), 2);
}

#[test]
fn compiled_spec_json_roundtrip() {
    let spec = CompiledSpec {
        functions: Vec::new(),
        rules: vec![
            CompiledRule {
                label: "Top".into(),
                is_top: true,
                parse_mode: ParseMode::Seek,
                mode: RuleMode::Default,
                regex_patterns: vec!["/a/".into()],
                dependency_refs: Vec::new(),
                acode_dispatch: vec![AcodeEntry {
                    regex_idx: 0,
                    child_label: "Child".into(),
                    child_regex_idx: 0,
                    code: None,
                    fluent_chain: Vec::new(),
                    has_parent_regex: true,
                }],
                bcode_dispatch: Vec::new(),
                preamble: None,
                lxcode: None,
                lscode: None,
                lecode: None,
                ecode: None,
                excode: None,
                itcode: None,
                rep_min: None,
                rep_max: None,
            },
            CompiledRule {
                label: "Child".into(),
                is_top: false,
                parse_mode: ParseMode::Consume,
                mode: RuleMode::And,
                regex_patterns: vec!["/b/".into()],
                dependency_refs: Vec::new(),
                acode_dispatch: vec![],
                bcode_dispatch: Vec::new(),
                preamble: None,
                lxcode: None,
                lscode: None,
                lecode: None,
                ecode: None,
                excode: None,
                itcode: None,
                rep_min: None,
                rep_max: None,
            },
        ],
    };

    let json = serde_json::to_string_pretty(&spec).unwrap();
    let parsed: CompiledSpec = serde_json::from_str(&json).unwrap();

    assert_eq!(parsed.rules.len(), 2);
    assert!(parsed.top_rule().is_some());
    assert_eq!(parsed.top_rule().unwrap().label, "Top");
}

#[test]
fn runtime_value_json_conversion() {
    // Scalar
    let sv = RuntimeValue::Scalar("hello".into());
    assert_eq!(sv.to_json(), serde_json::Value::String("hello".into()));

    // Number
    let nv = RuntimeValue::Number(42.0);
    assert_eq!(
        nv.to_json(),
        serde_json::Value::Number(serde_json::Number::from(42))
    );

    // Array
    let av = RuntimeValue::Array(vec![
        RuntimeValue::Scalar("a".into()),
        RuntimeValue::Scalar("b".into()),
    ]);
    let arr_json = av.to_json();
    assert!(arr_json.is_array());
    assert_eq!(arr_json.as_array().unwrap().len(), 2);

    // Undef
    assert_eq!(RuntimeValue::Undef.to_json(), serde_json::Value::Null);

    // Bool
    assert_eq!(
        RuntimeValue::Bool(true).to_json(),
        serde_json::Value::Bool(true)
    );
}

#[test]
fn runtime_value_as_bool() {
    assert!(!RuntimeValue::Undef.as_bool());
    assert!(!RuntimeValue::Scalar("".into()).as_bool());
    assert!(!RuntimeValue::Scalar("0".into()).as_bool());
    assert!(RuntimeValue::Scalar("hello".into()).as_bool());
    assert!(RuntimeValue::Number(1.0).as_bool());
    assert!(!RuntimeValue::Number(0.0).as_bool());
    assert!(RuntimeValue::Bool(true).as_bool());
}

#[test]
fn runtime_value_as_number() {
    assert_eq!(RuntimeValue::Number(42.0).as_number(), Some(42.0));
    assert_eq!(RuntimeValue::Scalar("2.5".into()).as_number(), Some(2.5));
    assert_eq!(RuntimeValue::Undef.as_number(), None);
    assert_eq!(
        RuntimeValue::Scalar("not a number".into()).as_number(),
        None
    );
}

#[test]
fn runtime_value_is_nonempty() {
    assert!(!RuntimeValue::Undef.is_nonempty());
    assert!(!RuntimeValue::Scalar("".into()).is_nonempty());
    assert!(RuntimeValue::Scalar("x".into()).is_nonempty());
    assert!(!RuntimeValue::Array(vec![]).is_nonempty());
    assert!(RuntimeValue::Array(vec![RuntimeValue::Scalar("x".into())]).is_nonempty());
}

#[test]
fn runtime_value_len() {
    assert_eq!(RuntimeValue::Undef.len(), 0);
    assert_eq!(RuntimeValue::Scalar("hello".into()).len(), 5);
    assert_eq!(
        RuntimeValue::Array(vec![
            RuntimeValue::Scalar("a".into()),
            RuntimeValue::Scalar("b".into())
        ])
        .len(),
        2
    );
    assert_eq!(RuntimeValue::Hash(vec![]).len(), 0);
}
