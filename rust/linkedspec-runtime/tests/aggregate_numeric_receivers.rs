//! TYPE-REFERENCE-BOOK.1.2.23.3.4.2 — aggregate results feed actual-value methods.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::json;

#[test]
fn aggregate_results_continue_without_recomputing_sources() {
    let source = r#"fn reduced(values) { return(values.sum().mul(2)) }
Top:: I {
 items=[2,4,6]; saved=copy(items); meta={"b":4,"a":2};
 direct=[items.sum().add(1),items.avg().add(1),items.median().add(1),items.range().add(1),items.min().add(1),items.max().add(1)];
 empty_helpers=[num_sum([]),num_add(num_sum([]),1),num_sum(["bad"]),num_avg([])];
 empty=[ [].sum().add(1),[].avg().add(1),[].median().add(1),[].range().add(1),[].min().add(1),[].max().add(1) ];
 selected=[ [[2,4]].first().sum().mul(2), [[2,4]].last().max().add(1) ];
 pipeline=[items.sorted().take(2).sum().add(1),meta.sorted_values().avg().mul(2)];
 overloads=[ [2,4].sum().min(3).add(1),[2,4].sum().max(8).sub(1),5.min(3).add(1),[3].first().min(2).add(1) ];
 text=[1,2].sum().cat(" total").uppercase(); bridge=[1,2].sum().cat(":a").split(":").last().uppercase(); even=[4,1,3,2].median().mul(2);
 from_function=reduced(items); invalid_source=["bad"].sum().add(1);
 order="";
 summed={order=cat(order,"S");items}.sum().add({order=cat(order,"A");items+=8;1});
 effects=0;
 bad_sum={effects=num_add(effects,1);[1]}.sum({effects=num_add(effects,1);1}).add(1);
 bad_avg={effects=num_add(effects,1);[1]}.avg({effects=num_add(effects,1);1}).add(1);
 bad_median={effects=num_add(effects,1);[1]}.median({effects=num_add(effects,1);1}).add(1);
 bad_range={effects=num_add(effects,1);[1]}.range({effects=num_add(effects,1);1}).add(1);
 return([direct,empty,empty_helpers,selected,pipeline,overloads,text,bridge,even,from_function,invalid_source,summed,order,items,saved,bad_sum,bad_avg,bad_median,bad_range,effects,[1,2].sum().drop_front(1),[1,2].min().sorted()]);
}"#;
    let parsed = parse_spec_with_user_functions(source).expect("parse");
    validate(&parsed).expect("validate");
    let spec = compile(&parsed).expect("compile");
    let expected = json!([
        [13, 5, 5, 5, 3, 7],
        [1, null, null, null, null, null],
        [0, 1, null, null],
        [12, 5],
        [7, 6],
        [4, 7, 4, 3],
        "3 TOTAL",
        "A",
        5,
        24,
        null,
        13,
        "SA",
        [2, 4, 6, 8],
        [2, 4, 6],
        null,
        null,
        null,
        null,
        0,
        null,
        null
    ]);
    assert_eq!(
        Engine::new(spec.clone())
            .execute_value("x", &ExecutionOptions::new())
            .expect("native execute"),
        expected
    );
    let serialized = serde_json::to_string(&spec).expect("serialize");
    let restored: CompiledSpec = serde_json::from_str(&serialized).expect("restore");
    assert_eq!(
        Engine::new(restored)
            .execute_value("x", &ExecutionOptions::new())
            .expect("restored execute"),
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
            "aggregate-numeric-receivers.spec",
            GENERATED_SOURCE_CONTRACT
        )
        .expect("generated-plan execute"),
        expected
    );
}
