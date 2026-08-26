#![allow(unexpected_cfgs)]
#![cfg(linkedspec_progressive_span_dispatch_authority)]

//! FUTURE-PARITY-BACKLOG.14.6.3.1 — private Rust progressive-dispatch authority.
//!
//! Ordinary Cargo discovery compiles this target with zero active tests. Run the focused private
//! authority proof with:
//!
//! `RUSTFLAGS='--cfg linkedspec_progressive_span_dispatch_authority' bash tools/run_cargo_local.sh test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test progressive_span_dispatch_authority`.

use linkedspec_runtime::bounded_child_parse_authority::{
    ProgressiveCancellationToken, ProgressiveCeilings, ProgressiveChainFrame, ProgressiveClock,
    ProgressiveCompiledAuthority, ProgressiveDispatchArguments, ProgressiveDispatchError,
    ProgressiveInvocationConfig, ProgressiveRegistry, ProgressiveRegistryEntry,
    ProgressiveSourceDetail, ProgressiveSourceView, ProgressiveSourceViewError,
};
use serde_json::{Value, json};
use std::collections::{BTreeMap, BTreeSet};
use std::sync::{Arc, Mutex};

const CONTRACT_SOURCE: &str = include_str!(concat!(
    env!("CARGO_MANIFEST_DIR"),
    "/../../capability_conformance/progressive_span_dispatch_contract.json"
));
const CI_DRIVER_SOURCE: &str = include_str!(concat!(
    env!("CARGO_MANIFEST_DIR"),
    "/../../tools/run_ci_local.sh"
));
const ORIGIN: &str = "progressive_span_dispatch_authority";

fn contract() -> Value {
    serde_json::from_str(CONTRACT_SOURCE).expect("progressive span-dispatch contract JSON")
}

fn strings(value: &Value) -> Vec<String> {
    value
        .as_array()
        .expect("string array")
        .iter()
        .map(|item| item.as_str().expect("string item").to_owned())
        .collect()
}

fn ceilings(value: &Value) -> ProgressiveCeilings {
    ProgressiveCeilings::new(
        ProgressiveSourceDetail::parse(value["source_detail"].as_str().expect("source detail"))
            .expect("valid source detail"),
        strings(&value["policy_modes"]),
        value["max_steps"].as_u64().expect("max steps"),
        value["max_result_nodes"]
            .as_u64()
            .expect("max result nodes"),
        value["max_diagnostic_bytes"]
            .as_u64()
            .expect("max diagnostic bytes"),
    )
    .expect("valid progressive ceilings")
}

fn sources(neutral: &Value) -> BTreeMap<String, String> {
    neutral["sources"]
        .as_array()
        .expect("sources")
        .iter()
        .map(|row| {
            (
                row["id"].as_str().expect("source id").to_owned(),
                row["text"].as_str().expect("source text").to_owned(),
            )
        })
        .collect()
}

fn registry(neutral: &Value, callback: ProgressiveCompiledAuthority) -> ProgressiveRegistry {
    let entries = neutral["registry_entries"]
        .as_array()
        .expect("registry entries")
        .iter()
        .map(|row| {
            ProgressiveRegistryEntry::new(
                row["parser_id"].as_str().expect("parser id"),
                Arc::clone(&callback),
                row["fingerprint"].as_str().expect("fingerprint"),
                strings(&row["allowed_top_rules"]),
                strings(&row["capabilities"]),
                ceilings(&row["ceilings"]),
            )
            .expect("valid registry entry")
        })
        .collect();
    ProgressiveRegistry::new(entries).expect("valid immutable registry")
}

fn invocation_config(
    neutral: &Value,
    source_id: &str,
    token: ProgressiveCancellationToken,
    now_tick: u64,
    deadline_tick: u64,
    remaining_steps: u64,
    max_depth: usize,
    total_calls: u64,
    max_calls: u64,
    active_chain: Vec<ProgressiveChainFrame>,
) -> ProgressiveInvocationConfig {
    ProgressiveInvocationConfig {
        sources: sources(neutral),
        source_id: source_id.to_owned(),
        cancellation_token: token,
        clock: ProgressiveClock::new(move || now_tick),
        deadline_tick,
        remaining_steps,
        max_depth,
        max_calls,
        active_chain,
        total_calls,
    }
}

fn permissive_ceilings() -> ProgressiveCeilings {
    ProgressiveCeilings::new(
        ProgressiveSourceDetail::Text,
        ["deterministic", "fail-only", "trace", "strict-json"]
            .into_iter()
            .map(str::to_owned)
            .collect(),
        1_000,
        1_000,
        4_096,
    )
    .expect("permissive caller ceilings")
}

fn arguments(
    parser_id: Value,
    top_rule: Value,
    span: Value,
    token: ProgressiveCancellationToken,
    cost: u64,
) -> ProgressiveDispatchArguments {
    ProgressiveDispatchArguments {
        origin: ORIGIN.to_owned(),
        parser_id,
        top_rule,
        span,
        caller_capabilities: [
            "actionir-v1",
            "caller-only",
            "structured-result-v1",
            "typed-source-location-v1",
        ]
        .into_iter()
        .map(str::to_owned)
        .collect(),
        required_capabilities: Vec::new(),
        caller_ceilings: permissive_ceilings(),
        required_source_detail: ProgressiveSourceDetail::None,
        child_token: token,
        cost,
        transaction_active: false,
    }
}

fn basic_arguments(
    parser_id: &str,
    top_rule: &str,
    span: Value,
    token: ProgressiveCancellationToken,
    cost: u64,
) -> ProgressiveDispatchArguments {
    arguments(json!(parser_id), json!(top_rule), span, token, cost)
}

fn remember(observed: &mut BTreeMap<String, Value>, error: ProgressiveDispatchError) -> String {
    let code = error.code().to_owned();
    observed.insert(code.clone(), error.as_record());
    code
}

fn chain_frame(value: &Value) -> ProgressiveChainFrame {
    let row = value.as_array().expect("active chain row");
    ProgressiveChainFrame::new(
        row[0].as_str().expect("active parser id"),
        row[1].as_str().expect("active top rule"),
        row[2].as_str().expect("active source id"),
        row[3].as_u64().expect("active start"),
        row[4].as_u64().expect("active end"),
    )
    .expect("valid active chain row")
}

#[test]
fn neutral_authority_contract_is_fully_enforced() {
    let neutral = contract();
    let mut observed = BTreeMap::<String, Value>::new();

    let view_callback: ProgressiveCompiledAuthority = Arc::new(|request, _invocation| {
        let text = request
            .source_view()
            .text()
            .map_err(|error| error.to_string())?;
        let offsets = (0..=u64::try_from(text.chars().count()).expect("scalar count"))
            .map(|offset| request.source_view().local_to_global(offset))
            .collect::<Result<Vec<_>, _>>()
            .map_err(|error| error.to_string())?;
        Ok(json!({"text": text, "offsets": offsets}))
    });
    let view_registry = registry(&neutral, view_callback);
    for row in neutral["view_cases"].as_array().expect("view cases") {
        let token = ProgressiveCancellationToken::new();
        let mut invocation = view_registry
            .start_invocation(invocation_config(
                &neutral,
                row["authority_source_id"]
                    .as_str()
                    .expect("authority source id"),
                token.clone(),
                1,
                100,
                100,
                8,
                0,
                16,
                Vec::new(),
            ))
            .expect("view invocation");
        let outcome = invocation.dispatch(basic_arguments(
            "expr-v1",
            "Expr",
            row["span"].clone(),
            token,
            1,
        ));
        if row["accepted"].as_bool().expect("accepted") {
            let value = outcome.expect("accepted bounded view");
            assert_eq!(value["text"], row["view_text"], "{}", row["id"]);
            assert_eq!(value["offsets"], row["local_to_global"], "{}", row["id"]);
        } else {
            let code = remember(&mut observed, outcome.expect_err("rejected bounded view"));
            assert_eq!(code, row["diagnostic"], "{}", row["id"]);
        }
    }

    for row in neutral["authority_cases"]
        .as_array()
        .expect("authority cases")
    {
        let effective_seen = Arc::new(Mutex::new(None::<Value>));
        let effective_for_callback = Arc::clone(&effective_seen);
        let authority_callback: ProgressiveCompiledAuthority =
            Arc::new(move |request, _invocation| {
                *effective_for_callback.lock().expect("effective lock") =
                    Some(request.effective().as_record());
                Ok(json!(false))
            });
        let authority_registry = registry(&neutral, authority_callback);
        let token = ProgressiveCancellationToken::new();
        let mut call = basic_arguments(
            row["entry_id"].as_str().expect("entry id"),
            if row["entry_id"] == "json-v1" {
                "Document"
            } else {
                "Expr"
            },
            json!({
                "source_id": "unicode",
                "start": 0,
                "end": 1,
                "provenance": "authority-case",
            }),
            token.clone(),
            1,
        );
        call.caller_capabilities = strings(&row["caller_capabilities"]);
        call.required_capabilities = strings(&row["required_capabilities"]);
        call.caller_ceilings = ceilings(&row["caller_ceilings"]);
        call.required_source_detail = ProgressiveSourceDetail::parse(
            row["required_source_detail"]
                .as_str()
                .expect("required source detail"),
        )
        .expect("valid required source detail");
        let mut invocation = authority_registry
            .start_invocation(invocation_config(
                &neutral,
                "unicode",
                token,
                1,
                100,
                100,
                8,
                0,
                16,
                Vec::new(),
            ))
            .expect("authority invocation");
        let outcome = invocation.dispatch(call);
        if row["accepted"].as_bool().expect("accepted") {
            assert_eq!(
                outcome.expect("accepted narrowed authority sentinel"),
                json!(false),
                "{}",
                row["id"]
            );
            assert_eq!(
                effective_seen.lock().expect("effective lock").as_ref(),
                Some(&row["effective"]),
                "{}",
                row["id"]
            );
        } else {
            let code = remember(
                &mut observed,
                outcome.expect_err("rejected authority elevation"),
            );
            assert_eq!(code, row["diagnostic"], "{}", row["id"]);
        }
    }

    let success_callback: ProgressiveCompiledAuthority =
        Arc::new(|_request, _invocation| Ok(json!(true)));
    let success_registry = registry(&neutral, Arc::clone(&success_callback));
    for row in neutral["cancellation_cases"]
        .as_array()
        .expect("cancellation cases")
    {
        let token = ProgressiveCancellationToken::new();
        if row["cancelled"].as_bool().expect("cancelled") {
            token.cancel();
        }
        let child_token = if row["token"] == row["child_token"] {
            token.clone()
        } else {
            ProgressiveCancellationToken::new()
        };
        let remaining = row["remaining_steps"].as_u64().expect("remaining steps");
        let mut invocation = success_registry
            .start_invocation(invocation_config(
                &neutral,
                "unicode",
                token,
                row["now_tick"].as_u64().expect("now tick"),
                row["deadline_tick"].as_u64().expect("deadline tick"),
                remaining,
                8,
                0,
                16,
                Vec::new(),
            ))
            .expect("cancellation invocation");
        let outcome = invocation.dispatch(basic_arguments(
            "expr-v1",
            "Expr",
            json!({"source_id": "unicode", "start": 0, "end": 1, "provenance": "safe-point"}),
            child_token,
            row["cost"].as_u64().expect("cost"),
        ));
        if row["accepted"].as_bool().expect("accepted") {
            assert_eq!(outcome.expect("accepted safe point"), json!(true));
        } else {
            let code = remember(&mut observed, outcome.expect_err("rejected safe point"));
            assert_eq!(code, row["diagnostic"], "{}", row["id"]);
        }
        assert_eq!(
            invocation.remaining_steps(),
            row["remaining_after"].as_u64().expect("remaining after"),
            "{}",
            row["id"]
        );
    }

    for row in neutral["chain_cases"].as_array().expect("chain cases") {
        let candidate = row["candidate"].as_array().expect("candidate");
        let token = ProgressiveCancellationToken::new();
        let active_chain = row["active"]
            .as_array()
            .expect("active chain")
            .iter()
            .map(chain_frame)
            .collect();
        let mut invocation = success_registry
            .start_invocation(invocation_config(
                &neutral,
                candidate[2].as_str().expect("candidate source id"),
                token.clone(),
                1,
                100,
                100,
                usize::try_from(row["max_depth"].as_u64().expect("max depth"))
                    .expect("usize depth"),
                row["total_calls"].as_u64().expect("total calls"),
                row["max_calls"].as_u64().expect("max calls"),
                active_chain,
            ))
            .expect("chain invocation");
        let outcome = invocation.dispatch(basic_arguments(
            candidate[0].as_str().expect("candidate parser id"),
            candidate[1].as_str().expect("candidate top rule"),
            json!({
                "source_id": candidate[2].as_str().expect("candidate source id"),
                "start": candidate[3].as_u64().expect("candidate start"),
                "end": candidate[4].as_u64().expect("candidate end"),
                "provenance": "chain-case",
            }),
            token,
            1,
        ));
        if row["accepted"].as_bool().expect("accepted") {
            assert_eq!(outcome.expect("accepted chain"), json!(true));
        } else {
            let code = remember(&mut observed, outcome.expect_err("rejected chain"));
            assert_eq!(code, row["diagnostic"], "{}", row["id"]);
        }
    }

    for row in neutral["execution_cases"]
        .as_array()
        .expect("execution cases")
    {
        let child_result = row["child_result"].clone();
        let callback: ProgressiveCompiledAuthority =
            Arc::new(move |_request, _invocation| Ok(child_result.clone()));
        let execution_registry = registry(&neutral, callback);
        let token = ProgressiveCancellationToken::new();
        let parent_state = row["parent_before"].clone();
        let mut invocation = execution_registry
            .start_invocation(invocation_config(
                &neutral,
                "unicode",
                token.clone(),
                1,
                100,
                row["budget_before"].as_u64().expect("budget before"),
                8,
                0,
                16,
                Vec::new(),
            ))
            .expect("execution invocation");
        let outcome = invocation.dispatch(basic_arguments(
            "expr-v1",
            "Expr",
            json!({"source_id": "unicode", "start": 1, "end": 4, "provenance": "execution-case"}),
            token,
            row["child_cost"].as_u64().expect("child cost"),
        ));
        if row["accepted"].as_bool().expect("accepted") {
            assert_eq!(
                outcome.expect("accepted detached result"),
                row["child_result"]
            );
        } else {
            let code = remember(
                &mut observed,
                outcome.expect_err("rejected child execution"),
            );
            assert_eq!(code, row["diagnostic"], "{}", row["id"]);
        }
        assert_eq!(parent_state, row["parent_after"], "{}", row["id"]);
        assert_eq!(
            invocation.remaining_steps(),
            row["budget_after"].as_u64().expect("budget after"),
            "{}",
            row["id"]
        );
    }

    let token = ProgressiveCancellationToken::new();
    let mut invocation = success_registry
        .start_invocation(invocation_config(
            &neutral,
            "unicode",
            token.clone(),
            1,
            100,
            100,
            8,
            0,
            16,
            Vec::new(),
        ))
        .expect("diagnostic-seam invocation");
    let span = json!({"source_id": "unicode", "start": 0, "end": 1, "provenance": "seam"});
    let seam_calls = [
        arguments(json!(17), json!("Expr"), span.clone(), token.clone(), 1),
        arguments(json!("BAD"), json!("Expr"), span.clone(), token.clone(), 1),
        arguments(json!("expr-v1"), json!([]), span.clone(), token.clone(), 1),
        arguments(
            json!("expr-v1"),
            json!("bad/rule"),
            span.clone(),
            token.clone(),
            1,
        ),
        arguments(
            json!("expr-v1"),
            json!("Expr"),
            json!("copied"),
            token.clone(),
            1,
        ),
        basic_arguments("missing-v1", "Expr", span.clone(), token.clone(), 1),
        basic_arguments("expr-v1", "Document", span.clone(), token.clone(), 1),
    ];
    for call in seam_calls {
        remember(
            &mut observed,
            invocation
                .dispatch(call)
                .expect_err("rejected diagnostic seam"),
        );
    }
    let mut transaction = basic_arguments("expr-v1", "Expr", span, token, 1);
    transaction.transaction_active = true;
    remember(
        &mut observed,
        invocation
            .dispatch(transaction)
            .expect_err("transaction dispatch rejected"),
    );
    remember(
        &mut observed,
        success_registry
            .register("expr-v1")
            .expect_err("runtime registration rejected"),
    );
    remember(
        &mut observed,
        success_registry
            .load("expr-v1")
            .expect_err("runtime loading rejected"),
    );

    let expected = neutral["diagnostics"]
        .as_array()
        .expect("diagnostics")
        .iter()
        .map(|row| row["code"].as_str().expect("diagnostic code").to_owned())
        .collect::<BTreeSet<_>>();
    assert_eq!(observed.keys().cloned().collect::<BTreeSet<_>>(), expected);
    for row in neutral["diagnostics"].as_array().expect("diagnostics") {
        let code = row["code"].as_str().expect("diagnostic code");
        let record = observed
            .get(code)
            .unwrap_or_else(|| panic!("missing {code}"));
        for field in row["required_context"]
            .as_array()
            .expect("required context")
        {
            let field = field.as_str().expect("context field");
            assert!(record.get(field).is_some(), "{code} lacks {field}");
        }
    }
}

#[test]
fn nested_dispatch_rebases_locations_shares_limits_and_expires_views() {
    let neutral = contract();
    let retained = Arc::new(Mutex::new(None::<ProgressiveSourceView>));
    let retained_for_callback = Arc::clone(&retained);
    let token = ProgressiveCancellationToken::new();
    let token_for_callback = token.clone();
    let callback: ProgressiveCompiledAuthority = Arc::new(move |request, invocation| {
        *retained_for_callback.lock().expect("retained view lock") =
            Some(request.source_view().clone());
        let text = request
            .source_view()
            .text()
            .map_err(|error| error.to_string())?;
        if text.chars().count() > 3 {
            return invocation
                .dispatch(basic_arguments(
                    "expr-v1",
                    "Expr",
                    json!({"source_id": "unicode", "start": 1, "end": 4, "provenance": "nested"}),
                    token_for_callback.clone(),
                    3,
                ))
                .map_err(|error| error.to_string());
        }
        let position = request
            .source_view()
            .rebase_position(1)
            .map_err(|error| error.to_string())?;
        let span = request
            .source_view()
            .rebase_span(&json!({
                "source_id": "unicode",
                "start": 0,
                "end": 2,
                "provenance": "child-match",
            }))
            .map_err(|error| error.to_string())?;
        let diagnostic = request
            .source_view()
            .rebase_diagnostic(&json!({"offset": 1, "span": {
                "source_id": "unicode", "start": 0, "end": 2, "provenance": "child-diagnostic"
            }}))
            .map_err(|error| error.to_string())?;
        Ok(json!({
            "text": text,
            "position": position,
            "span": span,
            "diagnostic": diagnostic,
            "effective": request.effective().as_record(),
        }))
    });
    let nested_registry = registry(&neutral, callback);
    let mut invocation = nested_registry
        .start_invocation(invocation_config(
            &neutral,
            "unicode",
            token.clone(),
            1,
            100,
            20,
            4,
            0,
            8,
            Vec::new(),
        ))
        .expect("nested invocation");
    let result = invocation
        .dispatch(basic_arguments(
            "expr-v1",
            "Expr",
            json!({"source_id": "unicode", "start": 0, "end": 5, "provenance": "outer"}),
            token,
            2,
        ))
        .expect("strictly decreasing nested dispatch");
    assert_eq!(result["text"], "é🙂B");
    assert_eq!(result["position"]["offset"], 2);
    assert_eq!(result["span"]["start"], 1);
    assert_eq!(result["span"]["end"], 3);
    assert_eq!(result["diagnostic"]["offset"], 2);
    assert_eq!(result["diagnostic"]["span"]["start"], 1);
    assert_eq!(result["diagnostic"]["span"]["end"], 3);
    assert_eq!(invocation.remaining_steps(), 15);
    assert_eq!(invocation.total_calls(), 2);
    let expired = retained
        .lock()
        .expect("retained view lock")
        .clone()
        .expect("retained view");
    assert_eq!(expired.text(), Err(ProgressiveSourceViewError::Expired));
}

#[test]
fn registry_inputs_and_child_results_are_deeply_detached() {
    let neutral = contract();
    let result_seed = Arc::new(Mutex::new(json!({"kind": "seed", "items": [1]})));
    let result_for_callback = Arc::clone(&result_seed);
    let callback: ProgressiveCompiledAuthority = Arc::new(move |_request, _invocation| {
        Ok(result_for_callback
            .lock()
            .expect("result seed lock")
            .clone())
    });
    let mut parser_id = "expr-v1".to_owned();
    let mut fingerprint =
        "sha256:1111111111111111111111111111111111111111111111111111111111111111".to_owned();
    let mut top_rules = vec!["Expr".to_owned()];
    let mut capabilities = vec!["typed-source-location-v1".to_owned()];
    let entry = ProgressiveRegistryEntry::new(
        parser_id.clone(),
        callback,
        fingerprint.clone(),
        top_rules.clone(),
        capabilities.clone(),
        ProgressiveCeilings::new(
            ProgressiveSourceDetail::Span,
            vec!["deterministic".to_owned()],
            10,
            16,
            1_024,
        )
        .expect("entry ceilings"),
    )
    .expect("detached registry entry");
    parser_id.clear();
    fingerprint.clear();
    top_rules[0].clear();
    capabilities[0].clear();
    let detached_registry = ProgressiveRegistry::new(vec![entry]).expect("detached registry");
    let token = ProgressiveCancellationToken::new();
    let mut invocation = detached_registry
        .start_invocation(invocation_config(
            &neutral,
            "unicode",
            token.clone(),
            1,
            100,
            10,
            4,
            0,
            8,
            Vec::new(),
        ))
        .expect("detachment invocation");
    let mut call = basic_arguments(
        "expr-v1",
        "Expr",
        json!({"source_id": "unicode", "start": 0, "end": 1, "provenance": "detachment"}),
        token,
        1,
    );
    call.caller_capabilities = vec!["typed-source-location-v1".to_owned()];
    call.caller_ceilings = ProgressiveCeilings::new(
        ProgressiveSourceDetail::Span,
        vec!["deterministic".to_owned()],
        10,
        16,
        1_024,
    )
    .expect("caller ceilings");
    let result = invocation.dispatch(call).expect("detached child result");
    *result_seed.lock().expect("result seed lock") = json!({"kind": "mutated"});
    assert_eq!(result, json!({"kind": "seed", "items": [1]}));

    let oversized_callback: ProgressiveCompiledAuthority =
        Arc::new(|_request, _invocation| Ok(json!([1, 2])));
    let oversized_registry = registry(&neutral, oversized_callback);
    let token = ProgressiveCancellationToken::new();
    let mut invocation = oversized_registry
        .start_invocation(invocation_config(
            &neutral,
            "unicode",
            token.clone(),
            1,
            100,
            10,
            4,
            0,
            8,
            Vec::new(),
        ))
        .expect("node-ceiling invocation");
    let mut call = basic_arguments(
        "expr-v1",
        "Expr",
        json!({"source_id": "unicode", "start": 0, "end": 1, "provenance": "node-ceiling"}),
        token,
        1,
    );
    call.caller_ceilings = ProgressiveCeilings::new(
        ProgressiveSourceDetail::Span,
        vec!["deterministic".to_owned(), "fail-only".to_owned()],
        10,
        2,
        1_024,
    )
    .expect("node ceiling");
    assert_eq!(
        invocation
            .dispatch(call)
            .expect_err("oversized result rejected")
            .code(),
        "progressive_result_not_detached"
    );

    let diagnostic_callback: ProgressiveCompiledAuthority =
        Arc::new(|_request, _invocation| Err("éé".to_owned()));
    let diagnostic_registry = registry(&neutral, diagnostic_callback);
    let token = ProgressiveCancellationToken::new();
    let mut invocation = diagnostic_registry
        .start_invocation(invocation_config(
            &neutral,
            "unicode",
            token.clone(),
            1,
            100,
            10,
            4,
            0,
            8,
            Vec::new(),
        ))
        .expect("diagnostic-ceiling invocation");
    let mut call = basic_arguments(
        "expr-v1",
        "Expr",
        json!({"source_id": "unicode", "start": 0, "end": 1, "provenance": "diagnostic-ceiling"}),
        token,
        1,
    );
    call.caller_ceilings = ProgressiveCeilings::new(
        ProgressiveSourceDetail::Span,
        vec!["deterministic".to_owned(), "fail-only".to_owned()],
        10,
        16,
        1,
    )
    .expect("diagnostic ceiling");
    let error = invocation
        .dispatch(call)
        .expect_err("child diagnostic is bounded");
    assert_eq!(error.code(), "progressive_child_failed");
    assert_eq!(error.as_record()["child_diagnostic"], "?");
}

#[test]
fn private_authority_stays_unrouted_while_contract_consumer_is_admitted() {
    assert!(!CI_DRIVER_SOURCE.contains("progressive_span_dispatch_authority"));
    assert_eq!(
        CI_DRIVER_SOURCE
            .matches("--test progressive_span_dispatch_contract")
            .count(),
        1
    );
    assert_eq!(
        CI_DRIVER_SOURCE
            .matches("rust/linkedspec-runtime/tests/progressive_span_dispatch_contract.rs")
            .count(),
        1
    );
    assert!(CONTRACT_SOURCE.contains("\"rust\""));
}
