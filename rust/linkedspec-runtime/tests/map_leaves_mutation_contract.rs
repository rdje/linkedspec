//! FUTURE-PARITY-BACKLOG.19.3.2 — Rust `map_leaves!` mutation contract.

use linkedspec_core::ast::{BodyElementKind, SpecFile};
use linkedspec_core::compiler::compile;
use linkedspec_core::expr::{CodeBlock, Expr};
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, emit_rust_source_v2, execute_generated_parser_v2,
    validate_generated_parser_plan_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

const CONTRACT_JSON: &str = include_str!(concat!(
    env!("CARGO_MANIFEST_DIR"),
    "/../../capability_conformance/map_leaves_mutation_contract.json"
));
const COMPOSITION_JSON: &str = include_str!(concat!(
    env!("CARGO_MANIFEST_DIR"),
    "/../../capability_conformance/write_map_leaves_composition_contract.json"
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
    serde_json::from_str(CONTRACT_JSON).expect("map-leaves-mutation contract JSON")
}

fn spec_for_action(action: &str) -> String {
    // Top deliberately has no regex. Entering Top executes its loop; the edge
    // dispatch resolves and tests Done's entry regex.
    format!("Top::\n -> Done {{ {action} }}\n\nDone::\n /[a-z]+/\n")
}

fn compile_source(source: &str) -> CompiledSpec {
    let parsed = parse_spec_with_user_functions(source).expect("parse map_leaves! fixture");
    validate(&parsed).expect("validate map_leaves! fixture");
    compile(&parsed).expect("compile map_leaves! fixture")
}

fn execute_action(action: &str) -> Result<Value, String> {
    Engine::new(compile_source(&spec_for_action(action)))
        .execute_value("xhello", &ExecutionOptions::new())
}

fn diagnostic(error: &str) -> Value {
    let payload = error
        .strip_prefix("user function '")
        .and_then(|rest| rest.split_once(": ").map(|(_, payload)| payload))
        .unwrap_or(error);
    serde_json::from_str(payload)
        .unwrap_or_else(|_| panic!("expected structured map_leaves! diagnostic: {error}"))
}

#[test]
fn frozen_syntax_and_ast_inventory_is_projected_by_the_rust_parser() {
    let contract = contract();
    assert_eq!(contract["contract_id"], "linkedspec-map-leaves-mutation-v1");
    assert_eq!(contract["valid_syntax_cases"].as_array().unwrap().len(), 4);
    assert_eq!(
        contract["invalid_syntax_cases"].as_array().unwrap().len(),
        14
    );
    assert_eq!(
        contract["excluded_syntax_cases"].as_array().unwrap().len(),
        5
    );

    for case in contract["valid_syntax_cases"].as_array().unwrap() {
        let source = case["source"].as_str().unwrap();
        let block = CodeBlock::parse(source)
            .unwrap_or_else(|error| panic!("{} failed to parse: {error}", case["id"]));
        // Every admitted spelling must also survive compiled carrier validation.
        compile_source(&spec_for_action(source));
        let Expr::ReceiverMutationChain {
            receiver,
            mutation,
            continuation,
            ..
        } = &block.statements[0].expr
        else {
            panic!("{} did not use receiver_mutation_chain", case["id"]);
        };
        assert_eq!(receiver.kind, "binding_reference");
        assert_eq!(mutation.kind, "receiver_mutation_call");
        assert_eq!(mutation.method, "map_leaves");
        assert_eq!(mutation.source_method, "map_leaves!");
        assert_eq!(mutation.callback.kind, "block_value");
        assert_eq!(mutation.callback.body.kind, "action_block");
        assert!(
            continuation.iter().all(|call| call.kind == "fluent_call"),
            "{} continuation carrier",
            case["id"]
        );

        if let Some(expected) = case.get("expected_ast") {
            let actual = serde_json::to_value(&block.statements[0].expr).unwrap();
            assert_eq!(actual["kind"], expected["kind"], "{} kind", case["id"]);
            assert_eq!(
                actual["source"], expected["source"],
                "{} source",
                case["id"]
            );
            assert_eq!(
                actual["source_span"], expected["source_span"],
                "{} chain span",
                case["id"]
            );
            assert_eq!(
                actual["receiver"], expected["receiver"],
                "{} receiver",
                case["id"]
            );
            for field in [
                "kind",
                "method",
                "source_method",
                "source",
                "source_span",
                "method_span",
                "args_span",
            ] {
                assert_eq!(
                    actual["mutation"][field], expected["mutation"][field],
                    "{} mutation {field}",
                    case["id"]
                );
            }
            for field in ["kind", "source", "source_span"] {
                assert_eq!(
                    actual["mutation"]["callback"][field], expected["mutation"]["callback"][field],
                    "{} callback {field}",
                    case["id"]
                );
                assert_eq!(
                    actual["mutation"]["callback"]["body"][field],
                    expected["mutation"]["callback"]["body"][field],
                    "{} callback body {field}",
                    case["id"]
                );
            }
            assert_eq!(
                actual["continuation"].as_array().unwrap().len(),
                expected["continuation"].as_array().unwrap().len(),
                "{} continuation count",
                case["id"]
            );
        } else {
            assert_eq!(
                receiver.name,
                case["expected_receiver"].as_str().unwrap(),
                "{} receiver name",
                case["id"]
            );
            let actual_methods = continuation
                .iter()
                .map(|call| call.method.as_str())
                .collect::<Vec<_>>();
            let expected_methods = case["expected_continuation"]
                .as_array()
                .unwrap()
                .iter()
                .map(|method| method.as_str().unwrap())
                .collect::<Vec<_>>();
            assert_eq!(
                actual_methods, expected_methods,
                "{} continuation methods",
                case["id"]
            );
        }
    }

    let unicode_source = r#"tree.map_leaves!() { note = "é"; return(value) }.count_keys()"#;
    let unicode = CodeBlock::parse(unicode_source).expect("parse Unicode receiver mutation");
    let Expr::ReceiverMutationChain {
        source_span,
        mutation,
        continuation,
        ..
    } = &unicode.statements[0].expr
    else {
        panic!("Unicode source did not retain the typed receiver-mutation node");
    };
    assert_eq!(source_span.end, unicode_source.chars().count());
    assert!(source_span.end < unicode_source.len());
    assert_eq!(
        mutation.callback.body.source_span.end,
        unicode_source[..unicode_source.rfind('}').unwrap()]
            .chars()
            .count()
    );
    assert_eq!(
        continuation[0].source_span.end,
        unicode_source.chars().count()
    );

    for case in contract["invalid_syntax_cases"].as_array().unwrap() {
        let error = CodeBlock::parse(case["source"].as_str().unwrap()).unwrap_err();
        let expected = &case["diagnostic"];
        assert!(
            error.contains(expected["code"].as_str().unwrap()),
            "{}: {error}",
            case["id"]
        );
        assert!(
            error.contains("stage=action_parse"),
            "{}: {error}",
            case["id"]
        );
        assert!(
            error.contains(&format!(
                "start:{},end:{}",
                expected["source_span"]["start"].as_u64().unwrap(),
                expected["source_span"]["end"].as_u64().unwrap()
            )),
            "{}: {error}",
            case["id"]
        );
        assert!(
            error.contains(expected["message"].as_str().unwrap()),
            "{}: {error}",
            case["id"]
        );
    }

    for case in contract["excluded_syntax_cases"].as_array().unwrap() {
        let source = case["source"].as_str().unwrap();
        let parsed = CodeBlock::parse(source);
        match case["classification"].as_str().unwrap() {
            "ordinary_nonmutating_fluent_chain" => assert!(
                !matches!(
                    parsed.unwrap().statements[0].expr,
                    Expr::ReceiverMutationChain { .. }
                ),
                "{}",
                case["id"]
            ),
            "ordinary_unknown_method" => match parsed {
                Ok(block) => assert!(!matches!(
                    block.statements[0].expr,
                    Expr::ReceiverMutationChain { .. }
                )),
                Err(error) => assert!(
                    !error.contains("receiver_mutation"),
                    "{} was misclassified as receiver mutation: {error}",
                    case["id"]
                ),
            },
            "invalid_identifier_not_receiver_mutation" => {
                assert!(parsed.is_err(), "{} must remain invalid", case["id"]);
            }
            other => panic!("unknown exclusion classification {other}"),
        }
    }
}

#[test]
fn hash_array_snapshot_frames_cross_kind_leaves_and_continuations_execute() {
    let hash = execute_action(
        r#"tree = { "b" : { "z" : "B" }, "a" : "A", "arr" : [1, 2] };
           audit = [];
           result = tree.map_leaves!() {
             audit += join_values("/", path);
             return(if(str_eq(key, "arr"), ["array-leaf"], else(cat(key, "@", depth, "=", value))))
           };
           return(array(tree, result, audit))"#,
    )
    .expect("execute hash-root receiver mutation");
    let expected_hash = json!({
        "a": "a@1=A",
        "arr": ["array-leaf"],
        "b": {"z": "z@2=B"},
    });
    assert_eq!(
        hash,
        json!([expected_hash.clone(), expected_hash, ["a", "arr", "b/z"]])
    );

    let array = execute_action(
        r#"items = ["A", ["B", "C"], { "h" : "H" }];
           result = items.map_leaves!() {
             return(if(==(index, 2),
               { "kept" : "hash-leaf" },
               else(cat(join_values("/", path), "=", value))))
           }.count();
           return(array(items, result))"#,
    )
    .expect("execute array-root receiver mutation and continuation");
    assert_eq!(
        array,
        json!([["0=A", ["1/0=B", "1/1=C"], {"kept": "hash-leaf"}], 3])
    );
}

#[test]
fn callback_replacements_are_not_revisited_and_scoped_frames_are_detached() {
    let actual = execute_action(
        r#"tree = { "leaf" : "A" };
           result = tree.map_leaves!() {
             value = "local";
             path = ["changed"];
             return({ "new" : { "deep" : "X" } })
           };
           return(array(tree, result, value, path))"#,
    )
    .expect("execute detached callback frame");
    assert_eq!(
        actual,
        json!([
            {"leaf": {"new": {"deep": "X"}}},
            {"leaf": {"new": {"deep": "X"}}},
            null,
            null,
        ])
    );
}

#[test]
fn unrelated_effects_empty_roots_and_hash_continuation_follow_commit_order() {
    let effects = execute_action(
        r#"tree = { "b" : "B", "a" : "A" };
           audit = [];
           other = [];
           result = tree.map_leaves!() {
             audit += path;
             other = [value];
             return(cat(value, "!"))
           };
           return(array(tree, result, audit, other))"#,
    )
    .expect("execute unrelated callback effects");
    assert_eq!(
        effects,
        json!([
            {"a": "A!", "b": "B!"},
            {"a": "A!", "b": "B!"},
            [["a"], ["b"]],
            ["B"],
        ])
    );

    let empty = execute_action(
        r#"tree = {};
           items = [];
           audit = [];
           hash_result = tree.map_leaves!() { audit += "hash"; return(value) };
           array_result = items.map_leaves!() { audit += "array"; return(value) };
           return(array(tree, hash_result, items, array_result, audit))"#,
    )
    .expect("execute empty roots without callbacks");
    assert_eq!(empty, json!([{}, {}, [], [], []]));

    let continuation = execute_action(
        r#"tree = { "b" : "B", "a" : "A" };
           count = tree.map_leaves!() { return(cat(value, "!")) }.count_keys();
           return(array(tree, count))"#,
    )
    .expect("execute hash continuation after commit");
    assert_eq!(continuation, json!([{"a": "A!", "b": "B!"}, 2]));
}

#[test]
fn same_spelling_function_parameter_is_a_distinct_binding_identity() {
    let source = r#"fn call_shadow(tree) {
 original = tree;
 tree = ["local"];
 return(cat(original, "!"))
}

Top::
 -> Done { tree = { "a" : "A" }; result = tree.map_leaves!() { return(call_shadow(value)) }; return(array(tree, result)) }

Done::
 /[a-z]+/
"#;
    let actual = Engine::new(compile_source(source))
        .execute_value("xhello", &ExecutionOptions::new())
        .expect("execute same-spelling shadow binding");
    assert_eq!(actual, json!([{"a": "A!"}, {"a": "A!"}]));
}

#[test]
fn nested_write_compositions_execute_against_callback_and_shadow_identities() {
    let composition: Value =
        serde_json::from_str(COMPOSITION_JSON).expect("write/map-leaves composition JSON");
    assert_eq!(
        composition["contract_id"],
        "linkedspec-write-map-leaves-composition-v1"
    );
    assert_eq!(composition["callback_cases"].as_array().unwrap().len(), 6);
    assert_eq!(
        composition["continuation_cases"].as_array().unwrap().len(),
        1
    );

    let callback_value = execute_action(
        r#"tree = { "leaf" : [] };
           result = tree.map_leaves!() {
             value[0]["name"] = "A";
             return(value)
           };
           return(array(tree, result))"#,
    )
    .expect("vivify the detached callback value");
    assert_eq!(
        callback_value,
        json!([
            {"leaf": [{"name": "A"}]},
            {"leaf": [{"name": "A"}]},
        ])
    );

    let unrelated = execute_action(
        r#"tree = { "a" : "A" };
           result = tree.map_leaves!() {
             journal["seen"][0] = path;
             return(cat(value, "!"))
           };
           return(array(tree, result, journal))"#,
    )
    .expect("commit unrelated vivification before receiver publication");
    assert_eq!(
        unrelated,
        json!([
            {"a": "A!"},
            {"a": "A!"},
            {"seen": [["a"]]},
        ])
    );

    let shadow_source = r#"fn shadow_write(tree) {
 tree[0]["local"] = "A";
 return(tree)
}

Top::
 -> Done { tree = { "leaf" : [] }; result = tree.map_leaves!() { return(shadow_write(value)) }; return(array(tree, result)) }

Done::
 /[a-z]+/
"#;
    let shadow = Engine::new(compile_source(shadow_source))
        .execute_value("xhello", &ExecutionOptions::new())
        .expect("vivify same-spelling shadow parameter independently");
    assert_eq!(
        shadow,
        json!([
            {"leaf": [{"local": "A"}]},
            {"leaf": [{"local": "A"}]},
        ])
    );
}

#[test]
fn nonbang_and_aggregate_boundaries_remain_detached() {
    let nonbang = execute_action(
        r#"tree = { "leaf" : [{ "x" : "original" }] };
           result = tree.map_leaves() {
             value[0]["x"] = "changed";
             return(value)
           };
           return(array(tree, result))"#,
    )
    .expect("execute unchanged non-bang map_leaves");
    assert_eq!(
        nonbang,
        json!([
            {"leaf": [{"x": "original"}]},
            {"leaf": [{"x": "changed"}]},
        ])
    );

    let detached = execute_action(
        r#"initial = { "leaf" : ["A"] };
           tree = initial;
           result = tree.map_leaves!() {
             return(array(value.first(), { "nested" : ["B"] }))
           };
           initial["leaf"][0] = "initial-mutated";
           result["leaf"][0] = "returned-mutated";
           tree["leaf"][1]["nested"][0] = "committed-mutated";
           return(array(initial, tree, result))"#,
    )
    .expect("mutate each detached aggregate boundary independently");
    assert_eq!(
        detached,
        json!([
            {"leaf": ["initial-mutated"]},
            {"leaf": ["A", {"nested": ["committed-mutated"]}]},
            {"leaf": ["returned-mutated", {"nested": ["B"]}]},
        ])
    );
}

#[test]
fn receiver_validation_and_every_authored_reentrant_write_are_typed() {
    for (action, code, actual_kind) in [
        (
            "tree.map_leaves!() { return(value) }",
            "map_leaves_mutation_receiver_missing",
            None,
        ),
        (
            "tree = undef; tree.map_leaves!() { return(value) }",
            "map_leaves_mutation_receiver_kind_mismatch",
            Some("null"),
        ),
        (
            "tree = \"scalar\"; tree.map_leaves!() { return(value) }",
            "map_leaves_mutation_receiver_kind_mismatch",
            Some("string"),
        ),
    ] {
        let payload = diagnostic(&execute_action(action).expect_err(code));
        assert_eq!(payload["code"], code);
        assert_eq!(payload["operation"], "map_leaves_mutation");
        assert_eq!(payload["binding"], "tree");
        assert_eq!(payload["method"], "map_leaves");
        if let Some(actual_kind) = actual_kind {
            assert_eq!(payload["actual_kind"], actual_kind);
            assert_eq!(payload["expected_kinds"], json!(["harray", "array"]));
        }
    }

    for (action, attempt, span) in [
        (
            r#"tree = { "a" : "A" }; tree.map_leaves!() { tree = {}; return(value) }"#,
            "assign",
            (43, 47),
        ),
        (
            r#"tree = { "a" : "A" }; tree.map_leaves!() { tree["x"] = value; return(value) }"#,
            "nested_write",
            (43, 47),
        ),
        (
            r#"tree = { "a" : "A" }; tree.map_leaves!() { set(tree, {}); return(value) }"#,
            "helper:set",
            (43, 56),
        ),
        (
            r#"tree = { "a" : "A" }; tree.map_leaves!() { return(tree.map_leaves!() { return(value) }) }"#,
            "map_leaves!",
            (50, 54),
        ),
    ] {
        let payload = diagnostic(&execute_action(action).expect_err(attempt));
        assert_eq!(payload["code"], "receiver_mutation_reentrant");
        assert_eq!(payload["attempt"], attempt);
        assert_eq!(payload["source_span"]["start"], span.0);
        assert_eq!(payload["source_span"]["end"], span.1);
        assert_eq!(payload["source_span"]["unit"], "unicode_scalar");
        assert_eq!(payload["source_span"]["provenance"], "authored");
    }
}

#[test]
fn spec_compiled_serialized_and_generated_routes_share_the_typed_carrier() {
    let action = r#"tree = { "b" : "B", "a" : "A" }; return(tree.map_leaves!() { return(cat(value, "!")) }.count_keys())"#;
    let source = spec_for_action(action);
    let expected = json!(2);

    let parsed = parse_spec_with_user_functions(&source).expect("parse typed SpecFile");
    let spec_json = serde_json::to_string(&parsed).expect("serialize typed SpecFile");
    let reconstructed_spec: SpecFile =
        serde_json::from_str(&spec_json).expect("reconstruct typed SpecFile");
    validate(&reconstructed_spec).expect("validate reconstructed typed SpecFile");
    let compiled = compile(&reconstructed_spec).expect("compile reconstructed typed SpecFile");
    assert_eq!(
        Engine::new(compiled.clone())
            .execute_value("xhello", &ExecutionOptions::new())
            .unwrap(),
        expected
    );

    let compiled_json = serde_json::to_string(&compiled).expect("serialize CompiledSpec");
    assert!(compiled_json.contains(r#""kind":"receiver_mutation_chain""#));
    assert!(compiled_json.contains(r#""source_method":"map_leaves!""#));
    let reconstructed: CompiledSpec =
        serde_json::from_str(&compiled_json).expect("reconstruct CompiledSpec");
    assert_eq!(
        Engine::new(reconstructed)
            .execute_value("xhello", &ExecutionOptions::new())
            .unwrap(),
        expected
    );
    let emitted = emit_rust_source_v2(&compiled, "map-leaves-mutation-emitted.spec")
        .expect("emit receiver-mutation generated Rust");
    assert!(emitted.contains("receiver_mutation_chain"));
    assert!(emitted.contains("map_leaves!"));

    validate_generated_parser_plan_v2(
        &compiled_json,
        TOP_DONE_PLAN,
        "map-leaves-mutation.spec",
        GENERATED_SOURCE_CONTRACT,
    )
    .expect("validate generated plan");
    assert_eq!(
        execute_generated_parser_v2(
            &compiled_json,
            TOP_DONE_PLAN,
            "xhello",
            "map-leaves-mutation.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .expect("execute generated plan"),
        expected
    );

    let corrupted = compiled_json.replacen(
        r#""kind":"binding_reference""#,
        r#""kind":"corrupt_binding_reference""#,
        1,
    );
    let corrupted_compiled: CompiledSpec =
        serde_json::from_str(&corrupted).expect("decode deliberately corrupted carrier");
    let native_error = Engine::new(corrupted_compiled)
        .execute_value("xhello", &ExecutionOptions::new())
        .expect_err("native execution must reject malformed receiver-mutation state");
    assert!(
        native_error.contains("receiver_mutation_serialized_state_invalid"),
        "{native_error}"
    );
    let generated_error = validate_generated_parser_plan_v2(
        &corrupted,
        TOP_DONE_PLAN,
        "map-leaves-mutation-corrupt.spec",
        GENERATED_SOURCE_CONTRACT,
    )
    .expect_err("generated decode must reject malformed receiver-mutation state");
    assert!(
        generated_error
            .to_string()
            .contains("receiver_mutation_serialized_state_invalid"),
        "{generated_error}"
    );
    assert_independently_compiled_emitted_source(&compiled, &expected);
}

const EMPTY_ARGUMENTS: [&str; 7] = ["", " ", "\t", "\n", "\r\n", " \t\r\n ", "\u{b}\u{c}"];

// Keep the caller-supplied AST route independent of outer .spec block capture.
// The fidelity tests exercise both source entry paths with identical expectations.
fn spec_with_verbatim_action(action: &str) -> SpecFile {
    let mut spec = parse_spec_with_user_functions(&spec_for_action("return(null)")).unwrap();
    let BodyElementKind::ActionEdge { code, .. } = &mut spec.rules[0].body[0].kind else {
        panic!("expected an action edge in the fixture");
    };
    *code = Some(action.to_owned());
    validate(&spec).expect("validate supplied source AST");
    spec
}

#[test]
fn empty_arguments_retain_authored_text_and_scalar_spans() {
    let prefix = "note = \"é🦀\"; ";
    for inside in EMPTY_ARGUMENTS {
        let expression =
            format!("tree . map_leaves! ({inside}) {{ return(value) }} . count_keys()");
        let source = format!("{prefix}{expression}");
        for parse in [CodeBlock::parse, CodeBlock::parse_with_callable_candidates] {
            let block = parse(&source).expect("parse semantically empty arguments");
            let Expr::ReceiverMutationChain {
                source: retained,
                source_span,
                mutation,
                ..
            } = &block.statements[1].expr
            else {
                panic!("expected the typed mutation carrier");
            };
            assert_eq!(retained, &expression);
            assert_eq!(source_span.start, prefix.chars().count());
            assert_eq!(source_span.end, source.chars().count());
            let args_start = prefix.chars().count() + "tree . map_leaves! ".chars().count();
            assert_eq!(mutation.args_span.start, args_start);
            assert_eq!(
                mutation.args_span.end,
                args_start + inside.chars().count() + 2
            );
            assert_eq!(
                mutation.source,
                format!("map_leaves! ({inside}) {{ return(value) }}"),
            );
        }
        for parsed in [
            spec_with_verbatim_action(&source),
            parse_spec_with_user_functions(&spec_for_action(&source)).unwrap(),
        ] {
            let compiled = compile(&parsed).expect("compile retained action source");
            let retained = serde_json::to_value(
                &compiled.rules[0].acode_dispatch[0]
                    .code
                    .as_ref()
                    .expect("the authored action block is present")
                    .statements[1]
                    .expr,
            )
            .unwrap();
            assert_eq!(retained["source"], expression);
            assert_eq!(
                retained["source_span"],
                json!({"start": prefix.chars().count(), "end": source.chars().count()}),
            );
            let args_start = prefix.chars().count() + "tree . map_leaves! ".chars().count();
            assert_eq!(
                retained["mutation"]["args_span"],
                json!({"start": args_start, "end": args_start + inside.chars().count() + 2}),
            );
        }
    }
    for inside in ["1", "null", "\" \"", ",", "()", "[]", "\u{200b}"] {
        let error = CodeBlock::parse(&format!("tree.map_leaves!({inside}) {{ return(value) }}"))
            .expect_err("nonempty arguments must remain invalid");
        assert!(
            error.contains("map_leaves_mutation_arguments_invalid"),
            "{error}"
        );
    }
}

#[test]
fn empty_arguments_execute_through_reconstructed_and_emitted_carriers() {
    let mut action = "note = \"é🦀\"; results = []; ".to_owned();
    for inside in EMPTY_ARGUMENTS {
        action.push_str(&format!(
            "tree = {{ \"clé\" : 1 }}; results += tree.map_leaves!({inside}) {{ add(value, 1) }}; "
        ));
    }
    action.push_str("return(results)");
    let expected = Value::Array(EMPTY_ARGUMENTS.iter().map(|_| json!({"clé": 2})).collect());
    let supplied = spec_with_verbatim_action(&action);
    let whole = parse_spec_with_user_functions(&spec_for_action(&action)).unwrap();
    for parsed in [supplied, whole] {
        let BodyElementKind::ActionEdge { code, .. } = &parsed.rules[0].body[0].kind else {
            panic!("expected the fixture action edge");
        };
        assert_eq!(code.as_deref(), Some(action.as_str()));
        let reconstructed: SpecFile =
            serde_json::from_str(&serde_json::to_string(&parsed).unwrap()).unwrap();
        let compiled = compile(&reconstructed).expect("compile every empty-argument spelling");
        assert_eq!(execute_action(&action).unwrap(), expected);

        let encoded = serde_json::to_string(&compiled).unwrap();
        let decoded: CompiledSpec = serde_json::from_str(&encoded).unwrap();
        assert_eq!(
            serde_json::to_value(&decoded).unwrap(),
            serde_json::to_value(&compiled).unwrap()
        );
        assert_eq!(
            Engine::new(decoded)
                .execute_value("xhello", &ExecutionOptions::new())
                .unwrap(),
            expected,
        );
        validate_generated_parser_plan_v2(
            &encoded,
            TOP_DONE_PLAN,
            "empty-arguments.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .unwrap();
        assert_eq!(
            execute_generated_parser_v2(
                &encoded,
                TOP_DONE_PLAN,
                "xhello",
                "empty-arguments.spec",
                GENERATED_SOURCE_CONTRACT,
            )
            .unwrap(),
            expected,
        );
        assert_independently_compiled_emitted_source(&compiled, &expected);
    }
}

#[test]
fn regex_newline_preserves_following_mutation_through_emitted_source() {
    let prefix = "note = \"é🦀\"; tree = { \"clé\" : 1 }; rx = /x/\r\n";
    let mutation = "tree.map_leaves!() { add(value, 1) }";
    let action = format!("{prefix}{mutation}; return(copy(tree))");
    let parsed = parse_spec_with_user_functions(&spec_for_action(&action)).unwrap();
    let reconstructed: SpecFile =
        serde_json::from_str(&serde_json::to_string(&parsed).unwrap()).unwrap();
    let compiled = compile(&reconstructed).unwrap();
    let block = compiled.rules[0].acode_dispatch[0].code.as_ref().unwrap();
    assert_eq!(block.statements.len(), 5);
    let Expr::ReceiverMutationChain {
        source,
        source_span,
        ..
    } = &block.statements[3].expr
    else {
        panic!("expected the mutation after the regex assignment");
    };
    assert_eq!(source, mutation);
    assert_eq!(source_span.start, prefix.chars().count());
    assert_eq!(
        source_span.end,
        prefix.chars().count() + mutation.chars().count()
    );
    let expected = json!({"clé": 2});
    assert_eq!(execute_action(&action).unwrap(), expected);
    let encoded = serde_json::to_string(&compiled).unwrap();
    let decoded: CompiledSpec = serde_json::from_str(&encoded).unwrap();
    assert_eq!(
        Engine::new(decoded)
            .execute_value("xhello", &ExecutionOptions::new())
            .unwrap(),
        expected,
    );
    assert_eq!(
        execute_generated_parser_v2(
            &encoded,
            TOP_DONE_PLAN,
            "xhello",
            "regex-before-mutation.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .unwrap(),
        expected,
    );
    assert_independently_compiled_emitted_source(&compiled, &expected);
}

#[test]
fn subtraction_newline_retains_values_in_independently_emitted_source() {
    let prefix = "note = \"é🦀\"; out = -(10,3)\r\n tree = { \"clé\" : out }; ";
    let mutation = "tree.map_leaves!() { add(value, 1) }";
    let action = format!("{prefix}{mutation}; return(copy(tree))");
    let compiled = compile_source(&spec_for_action(&action));
    let block = compiled.rules[0].acode_dispatch[0].code.as_ref().unwrap();
    assert_eq!(block.statements.len(), 5);
    let Expr::ReceiverMutationChain {
        source,
        source_span,
        ..
    } = &block.statements[3].expr
    else {
        panic!("expected the mutation after subtraction");
    };
    assert_eq!(source, mutation);
    assert_eq!(source_span.start, prefix.chars().count());
    assert_eq!(
        source_span.end,
        prefix.chars().count() + mutation.chars().count()
    );
    let expected = json!({"clé": 8});
    assert_eq!(execute_action(&action).unwrap(), expected);
    assert_independently_compiled_emitted_source(&compiled, &expected);
}

#[test]
fn division_newline_retains_values_in_independently_emitted_source() {
    let prefix = "note = \"é🦀\"; out = /(14,2)\r\n tree = { \"clé\" : out }; ";
    let mutation = "tree.map_leaves!() { add(value, 1) }";
    let action = format!("{prefix}{mutation}; return(copy(tree))");
    let compiled = compile_source(&spec_for_action(&action));
    let block = compiled.rules[0].acode_dispatch[0].code.as_ref().unwrap();
    assert_eq!(block.statements.len(), 5);
    let Expr::ReceiverMutationChain { source, source_span, .. } = &block.statements[3].expr else {
        panic!("expected the mutation after division");
    };
    assert_eq!(source, mutation);
    assert_eq!(source_span.start, prefix.chars().count());
    assert_eq!(source_span.end, prefix.chars().count() + mutation.chars().count());
    let expected = json!({"clé": 8});
    assert_eq!(execute_action(&action).unwrap(), expected);
    assert_independently_compiled_emitted_source(&compiled, &expected);
}

#[test]
fn empty_arguments_do_not_admit_corrupted_argument_projections() {
    let original = compile_source(&spec_for_action("tree.map_leaves!( ) { return(value) }"));
    // Equal scalar lengths isolate argument validation from unrelated span mismatches.
    for bad in [
        "(1)",
        "(x)",
        "(,)",
        "(\u{200b})",
        "[ ]",
        "   ",
        "(  ",
        "  )",
    ] {
        let mut corrupted = original.clone();
        let Expr::ReceiverMutationChain {
            source, mutation, ..
        } = &mut corrupted.rules[0].acode_dispatch[0]
            .code
            .as_mut()
            .expect("the authored action block is present")
            .statements[0]
            .expr
        else {
            panic!("expected a standalone mutation carrier");
        };
        *source = source.replacen("( )", bad, 1);
        mutation.source = mutation.source.replacen("( )", bad, 1);
        let encoded = serde_json::to_string(&corrupted).unwrap();
        let restored: CompiledSpec = serde_json::from_str(&encoded).unwrap();
        let errors = [
            Engine::new(restored)
                .execute_value("xhello", &ExecutionOptions::new())
                .unwrap_err(),
            validate_generated_parser_plan_v2(
                &encoded,
                TOP_DONE_PLAN,
                "bad-arguments.spec",
                GENERATED_SOURCE_CONTRACT,
            )
            .unwrap_err()
            .to_string(),
            emit_rust_source_v2(&corrupted, "bad-arguments.spec")
                .unwrap_err()
                .to_string(),
        ];
        for error in errors {
            assert!(
                error.contains("receiver_mutation_serialized_state_invalid"),
                "{bad:?}: {error}"
            );
            assert!(error.contains("mutation_call_invalid"), "{bad:?}: {error}");
        }
    }
}

struct GeneratedTestProject {
    root: PathBuf,
}

impl GeneratedTestProject {
    fn new() -> Self {
        let nonce = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("system clock")
            .as_nanos();
        let root = Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("../target/test-workspaces")
            .join(format!(
                "map-leaves-mutation-emitted-{}-{nonce}",
                std::process::id()
            ));
        fs::create_dir_all(root.join("src")).expect("create emitted-source workspace");
        Self { root }
    }
}

impl Drop for GeneratedTestProject {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.root);
    }
}

fn assert_independently_compiled_emitted_source(compiled: &CompiledSpec, expected: &Value) {
    let emitted = emit_rust_source_v2(compiled, "map-leaves-mutation-emitted.spec")
        .expect("emit typed receiver-mutation source");
    let expected = serde_json::to_string(expected).expect("serialize emitted expected value");
    let module = format!(
        r#"{emitted}

#[cfg(test)]
mod emitted_map_leaves_mutation_tests {{
    #[test]
    fn receiver_mutation_executes() {{
        assert_eq!(
            super::execute("xhello").unwrap(),
            serde_json::from_str::<serde_json::Value>({expected:?}).unwrap()
        );
    }}
}}
"#
    );
    let project = GeneratedTestProject::new();
    fs::write(
        project.root.join("Cargo.toml"),
        r#"[package]
name = "linkedspec_map_leaves_mutation_emitted"
version = "0.0.0"
edition = "2024"

[dependencies]
linkedspec-runtime = { path = "../../../linkedspec-runtime" }
serde_json = "1"

[workspace]
"#,
    )
    .expect("write emitted manifest");
    fs::write(project.root.join("src/lib.rs"), module).expect("write emitted module");
    let output = Command::new("cargo")
        .arg("test")
        .arg("--offline")
        .arg("--quiet")
        .env("CARGO_TARGET_DIR", project.root.join("target"))
        .current_dir(&project.root)
        .output()
        .expect("run independently compiled emitted test");
    assert!(
        output.status.success(),
        "independently compiled emitted test failed\nstatus: {}\nstdout:\n{}\nstderr:\n{}",
        output.status,
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    );
}
