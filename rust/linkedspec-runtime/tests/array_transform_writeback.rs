//! FUTURE-PARITY-BACKLOG.5.3.1 — focused statement/pure transform boundary.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::json;

fn compiled(body: &str) -> CompiledSpec {
    let source = format!("Top::\n I {{ {body} }}\n");
    let parsed = parse_spec_with_user_functions(&source).expect("parse");
    validate(&parsed).expect("validate");
    compile(&parsed).expect("compile")
}

#[test]
fn standalone_transforms_rebind_while_value_and_receiver_forms_stay_pure() {
    let spec = compiled(
        r#"
        items=["a:b","a:a"]; saved=copy(items); calls=0;
        split_each(items,{ calls=num_add(calls,1); ":" }); split_snapshot=copy(items);
        filter_match(items,{ calls=num_add(calls,1); "^a$" }); filter_snapshot=copy(items);
        uniq(items); unique_snapshot=copy(items); items[0]="z";
        source=["b:b","a:a","b:b"];
        pure_split=split_each(source,":"); pure_filter=filter_match(source,/^a/);
        pure_unique=uniq(source); chain=source.split_each(":").filter_match(/^a$/).uniq();
        typed=[2,"2","x"]; filter_match(typed,/^2$/); uniq(typed);
        split_each(absent_split,":"); filter_match(absent_filter,/x/); uniq(absent_unique);
        return([items,saved,split_snapshot,filter_snapshot,unique_snapshot,calls,
            source,pure_split,pure_filter,pure_unique,chain,typed,
            absent_split,absent_filter,absent_unique]);
    "#,
    );
    let expected = json!([
        ["z"],
        ["a:b", "a:a"],
        ["a", "b", "a", "a"],
        ["a", "a", "a"],
        ["a"],
        2,
        ["b:b", "a:a", "b:b"],
        ["b", "b", "a", "a", "b", "b"],
        ["a:a"],
        ["b:b", "a:a"],
        ["a"],
        [2],
        [],
        [],
        []
    ]);
    let options = ExecutionOptions::new();
    assert_eq!(
        Engine::new(spec.clone())
            .execute_value("x", &options)
            .unwrap(),
        expected
    );
    let serialized = serde_json::to_string(&spec).unwrap();
    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();
    assert_eq!(
        Engine::new(restored).execute_value("x", &options).unwrap(),
        expected
    );
    let plan = [GeneratedPlanRow {
        label: "Top",
        family: "default",
    }];
    assert_eq!(
        execute_generated_parser_v2(
            &serialized,
            &plan,
            "x",
            "transform-writeback.spec",
            GENERATED_SOURCE_CONTRACT
        )
        .unwrap(),
        expected
    );
}

#[test]
fn standalone_transforms_reject_an_existing_wrong_kind() {
    for statement in [
        "split_each(target,\":\")",
        "filter_match(target,/x/)",
        "uniq(target)",
    ] {
        let spec = compiled(&format!("target=7; {statement}; return(target)"));
        let error = Engine::new(spec)
            .execute_value("x", &ExecutionOptions::new())
            .unwrap_err();
        assert!(
            error.contains(
                "binding_kind_mismatch identifier=target expected_kind=array actual_kind=scalar"
            ),
            "{statement}: {error}"
        );
    }
}
