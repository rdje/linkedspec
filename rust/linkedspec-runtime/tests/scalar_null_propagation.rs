//! SESSION-STARTUP-READING.61.1 — preserve null before scalar text conversion.
use linkedspec_core::{compiler::compile, types::CompiledSpec, validation::validate};
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::json;

#[test]
fn scalar_transformations_preserve_null_and_defined_controls() {
    let source = r#"Top::
 I {
  absent=missing_value; order="";
  replaced=replace_substr({order=cat(order,"S"); undef},
   {order=cat(order,"N"); "x"},{order=cat(order,"R"); "y"});
  return([
   [length(undef),trim(undef),lowercase(undef),uppercase(undef),
    replace_substr(undef,"a","b"),rm_prefix(undef,"a"),rm_suffix(undef,"a")],
   [absent.length(),absent.trim(),absent.lowercase(),absent.uppercase(),
    absent.replace_substr("a","b"),absent.rm_prefix("a"),absent.rm_suffix("a")],
   [length(""),trim(""),lowercase(""),uppercase(""),
    replace_substr("","a","b"),rm_prefix("","a"),rm_suffix("","a")],
   [length(0),length(false),trim(0),lowercase(false),uppercase(0),
    replace_substr(false,"0","zero"),rm_prefix(0,"x"),rm_suffix(false,"x")],
   [length([1,2]),length("🙂"),lowercase("ΟΣ"),uppercase("Straße"),
    replace_substr("a-b-a","a","🙂"),rm_prefix("préfixe","pré"),rm_suffix("café","fé")],
   [replaced,order]
  ]);
 }
"#;
    let parsed = parse_spec_with_user_functions(source).expect("parse");
    validate(&parsed).expect("validate");
    let spec = compile(&parsed).expect("compile");
    let expected = json!([
        [null, null, null, null, null, null, null],
        [null, null, null, null, null, null, null],
        [0, "", "", "", "", "", ""],
        [1, 1, "0", "0", "0", "zero", "0", "0"],
        [2, 1, "ος", "STRASSE", "🙂-b-🙂", "fixe", "ca"],
        [null, "SNR"]
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
            "scalar-null-propagation.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .expect("generated-plan execute"),
        expected
    );
}
