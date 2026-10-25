//! Exercise the actual progressive JSON-to-RuntimeValue bridge with binary64 payloads.
use linkedspec_core::compiler::compile;
use linkedspec_runtime::bounded_child_parse_authority::{
    ProgressiveCancellationToken, ProgressiveCeilings, ProgressiveClock,
    ProgressiveCompiledAuthority, ProgressiveExecutionSeed, ProgressiveInvocationConfig,
    ProgressiveRegistry, ProgressiveRegistryEntry, ProgressiveSourceDetail,
};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2_with_options,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};
use std::collections::BTreeMap;
use std::sync::Arc;

fn options(number: f64) -> ExecutionOptions {
    let callback: ProgressiveCompiledAuthority =
        Arc::new(move |_, _| Ok(json!({"values":[number]})));
    let ceilings = ProgressiveCeilings::new(
        ProgressiveSourceDetail::Text,
        vec!["deterministic".to_owned(), "fail-only".to_owned()],
        100,
        100,
        4096,
    )
    .unwrap();
    let entry = ProgressiveRegistryEntry::new(
        "numeric-v1",
        callback,
        "sha256:1111111111111111111111111111111111111111111111111111111111111111",
        vec!["Value".to_owned()],
        vec!["parse".to_owned()],
        ceilings.clone(),
    )
    .unwrap();
    let config = ProgressiveInvocationConfig {
        sources: BTreeMap::from([("input".to_owned(), "x".to_owned())]),
        source_id: "input".to_owned(),
        cancellation_token: ProgressiveCancellationToken::new(),
        clock: ProgressiveClock::new(|| 0),
        deadline_tick: 100,
        remaining_steps: 100,
        max_depth: 8,
        max_calls: 16,
        active_chain: Vec::new(),
        total_calls: 0,
    };
    let seed = ProgressiveExecutionSeed::new(
        ProgressiveRegistry::new(vec![entry]).unwrap(),
        config,
        vec!["parse".to_owned()],
        vec!["parse".to_owned()],
        ceilings,
        ProgressiveSourceDetail::None,
        1,
    );
    ExecutionOptions::new().with_bounded_child_parse_authority(seed)
}

#[test]
fn numeric_child_payloads_survive_the_real_recursive_bridge() {
    let source = "Top: /x/\n I { span={\"source_id\":\"input\",\"start\":0,\"end\":1,\"provenance\":\"authored\"}; payload=dispatch_span(\"numeric-v1\",\"Value\",span); return(payload) }\n";
    let parsed = parse_spec_with_user_functions(source).unwrap();
    let compiled = compile(&parsed).unwrap();
    let serialized = serde_json::to_string(&compiled).unwrap();
    let plan = &[GeneratedPlanRow {
        label: "Top",
        family: "default",
    }];
    let fixture: Value =
        serde_json::from_str(include_str!("../../../tests/numeric-conversion/cases.json")).unwrap();
    let mut failures = Vec::new();
    for case in fixture["cases"]
        .as_array()
        .unwrap()
        .iter()
        .filter(|case| case["finite"] == true)
    {
        let bits = u64::from_str_radix(case["bits"].as_str().unwrap(), 16).unwrap();
        let number = f64::from_bits(bits);
        let native = Engine::new(compiled.clone()).execute_value("x", &options(number));
        let generated = execute_generated_parser_v2_with_options(
            &serialized,
            plan,
            "x",
            "numeric-bridge.spec",
            GENERATED_SOURCE_CONTRACT,
            &options(number),
        )
        .map_err(|error| error.detail.as_deref().unwrap_or(error.summary).to_owned());
        for (route, result) in [("native", native), ("generated_plan", generated)] {
            let matches = result.as_ref().is_ok_and(|result| {
                let value = &result["values"][0];
                match case["json_kind"].as_str().unwrap() {
                    "signed_integer" | "unsigned_integer" => {
                        !value.is_f64() && value.to_string() == case["integer"].as_str().unwrap()
                    }
                    _ => value.is_f64() && value.as_f64().map(f64::to_bits) == Some(bits),
                }
            });
            println!(
                "NUMERIC_BRIDGE\t{}",
                json!({"id":case["id"],"route":route,
                "ok":result.as_ref().ok(),"error":result.as_ref().err(),"matches":matches})
            );
            if !matches {
                failures.push(format!("{}:{route}", case["id"]));
            }
        }
    }
    assert!(
        failures.is_empty(),
        "numeric bridge mismatches: {failures:?}"
    );
}
