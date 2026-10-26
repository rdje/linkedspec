//! TYPE-REFERENCE-BOOK.1.2.23.3.5.2 — joined Strings feed actual-value methods.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::json;

#[test]
fn joined_results_continue_without_recomputing_sources() {
    let source = r#"fn joined(values) { return(values.join_values(":").uppercase()) }
Top:: I {
 named_parts=["a","b"]; mutated=named_parts.push_back("c").join_values(",").uppercase(); incompatible_mutated=named_parts.push_back("d").join_values(",").sorted();
 parts=[" a ","b "]; saved=copy(parts); meta={"b":"y","a":"x"};
 direct=parts.join_values("-").trim().uppercase();
 selected=[["a","b"]].first().join_values("-").uppercase();
 pipeline=["b","a"].sorted().join_values(":").uppercase();
 from_hash=meta.sorted_values().join_values(":").uppercase();
 string="a-b".split("-").join_values(":").uppercase();
 numeric=["a","b"].join_values(":").length().add(1);
 repeated=["a","b"].join_values(":").split(":").last().uppercase();
 from_function=joined(["a","b"]); empty=[].join_values(",").cat("!");
 unicode=["ß","a"].join_values(" ").uppercase();
 items=["a","b"]; order="";
 effected={order=cat(order,"S");items}.join_values({order=cat(order,"D");items+="c";","}).cat({order=cat(order,"A");items+="d";"!"});
 bare=["x","y"]; named=bare.join_values({order=cat(order,"N");bare+="z";"-"}).uppercase();
 invalid_effects=0;
 missing={invalid_effects=num_add(invalid_effects,1);["a"]}.join_values().uppercase();
 extra={invalid_effects=num_add(invalid_effects,1);["a"]}.join_values({invalid_effects=num_add(invalid_effects,1);","},{invalid_effects=num_add(invalid_effects,1);"!"}).uppercase();
 incompatible=["a"].join_values(",").sorted();
 return([mutated,incompatible_mutated,named_parts,direct,selected,pipeline,from_hash,string,numeric,repeated,from_function,empty,unicode,effected,named,order,items,bare,parts,saved,meta,missing,extra,invalid_effects,incompatible]);
}"#;
    let parsed = parse_spec_with_user_functions(source).expect("parse");
    validate(&parsed).expect("validate");
    let spec = compile(&parsed).expect("compile");
    let expected = json!(["A,B,C",null,["a","b","c","d"],"A -B","A-B","A:B","X:Y","A:B",4,"B","A:B","!","SS A","a,b!","X-Y","SDAN",["a","b","c","d"],["x","y","z"],[" a ","b "],[" a ","b "],{"a":"x","b":"y"},null,null,0,null]);
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
            "joined-string-receivers.spec",
            GENERATED_SOURCE_CONTRACT
        )
        .expect("generated-plan execute"),
        expected
    );
}
