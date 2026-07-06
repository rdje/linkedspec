//! RUST-PARITY.8.2/.8.3.1-.8.4 — generated Rust-source compile/run proof.

use linkedspec_core::ast::RuleMode;
use linkedspec_core::compiler::compile;
use linkedspec_core::parser::parse_spec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::Engine;
use linkedspec_runtime::source_emitter::{
    GeneratedRuleFamily, GeneratedRuleSpec, classify_generated_rule_family, emit_rust_source,
    execute_generated_parser,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde::Deserialize;
use serde_json::{Value, json};
use std::collections::BTreeSet;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

const SIMPLE_SOURCE_EMITTER_SPEC: &str = r#"Top::
 I { set(array(words), []) }
 /hello[ \t]+(\w+)/
 LE { push(array(words), match_group(0)) }
 E { return(copy(array(words))) }
"#;

const OR_ACODE_SOURCE_EMITTER_SPEC: &str = r#"Top::OR
 /go/ -> Done { return(cat("or-acode:", call(Done))) }

Done:
 /go/
 E { return(entry_text()) }
"#;

const AND_SINGLE_ACODE_SOURCE_EMITTER_SPEC: &str = r#"Top::AND
 /one/ -> Done { return("and-single") }

Done:
 /one/
"#;

const AND_ACODE_SEQ_SOURCE_EMITTER_SPEC: &str = r#"Top::AND
 /a/ -> First
 /[ \t]+b/ -> Second { return("and-seq") }

First:
 /a/

Second:
 /[ \t]+b/
"#;

const AND_BCODE_SOURCE_EMITTER_SPEC: &str = r#"Top::AND
 I { set(array(log), []) }
 => ChildA { push(array(log), retv) }
 => ChildB { push(array(log), retv) }
 E { return(copy(array(log))) }

ChildA:
 /a/
 E { return("A") }

ChildB:
 /[ \t]+b/
 E { return("B") }
"#;

const OR_BCODE_SOURCE_EMITTER_SPEC: &str = r#"Top::OR
 => ChildA
 => ChildB
 E { return(cat("or-bcode:", retv)) }

ChildA:
 /a/
 E { return("A") }

ChildB:
 /[ \t]+b/
 E { return("B") }
"#;

const OR_BCODE_LX_SOURCE_EMITTER_SPEC: &str = r#"Top::OR
 => ChildA
 => ChildB
 LX { return("or-miss") }
 E { return("unexpected") }

ChildA::
 I { return_undef() }

ChildB::
 I { return_undef() }
"#;

const REP_ACODE_SOURCE_EMITTER_SPEC: &str = r#"Top::OR{2,3}
 I { set(array(out), []) }
 /a/ -> A { push(array(out), match_text()) }
 /b/ -> B { push(array(out), match_text()) }
 E { return(copy(array(out))) }

A:
 /a/

B:
 /b/
"#;

const REP_BCODE_SOURCE_EMITTER_SPEC: &str = r#"Top::OR{2,3}
 I { set(array(out), []) }
 => A
 => B
 LE { push(array(out), retv) }
 E { return(copy(array(out))) }

A:&
 /a/
 LE { return("A") }

B:&
 /b/
 LE { return("B") }
"#;

const REP_AND_ACODE_SOURCE_EMITTER_SPEC: &str = r#"Top::AND{2}
 I { set(array(pairs), []); set(array(pair), []) }
 /a/ -> A { push(array(pair), match_text()) }
 /b/ -> B { push(array(pair), match_text()) }
 IT { push(array(pairs), copy(array(pair))); set(array(pair), []) }
 E { return(copy(array(pairs))) }

A:
 /a/

B:
 /b/
"#;

const REP_AND_BCODE_SOURCE_EMITTER_SPEC: &str = r#"Top::AND{2}
 I { set(array(groups), []); set(array(group), []) }
 => A { push(array(group), retv) }
 => B { push(array(group), retv) }
 IT { push(array(groups), copy(array(group))); set(array(group), []) }
 E { return(copy(array(groups))) }

A:&
 /a/
 LE { return("A") }

B:&
 /b/
 LE { return("B") }
"#;

const REP_ZERO_PROGRESS_SOURCE_EMITTER_SPEC: &str = r#"Top::OR+
 I { set(array(iters), []) }
 /x*/
 LE { push(array(iters), "i") }
 E { return(copy(array(iters))) }
"#;

const REP_RECURSION_GUARD_SOURCE_EMITTER_SPEC: &str = r#"Top::OR+
 /x*/ -> Top { return(cat("guard:", call(Top))) }
"#;

const GENERATED_SOURCE_CORPUS_SUBSET: &[&str] = &[
    "proof_edge_array_literal",
    "proof_edge_scalar_literal",
    "autoexist_array_bare_arg",
    "terse_1_5_2_primitive_literals",
    "terse_2_2_3_attached_if_blocks",
    "terse_4_3_2_user_function_runtime",
    "tclite_command_subst",
    "portmap_bare",
];

#[derive(Debug, Deserialize)]
struct CorpusManifest {
    format: u64,
    case_count: usize,
    cases: Vec<String>,
}

struct TempProject {
    root: PathBuf,
}

impl TempProject {
    fn new(prefix: &str) -> Self {
        let nanos = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("system time should be after the Unix epoch")
            .as_nanos();
        let root = std::env::temp_dir().join(format!("{prefix}-{}-{nanos}", std::process::id()));
        if root.exists() {
            fs::remove_dir_all(&root).expect("remove stale generated-source temp project");
        }
        fs::create_dir_all(root.join("src")).expect("create generated-source temp project");
        Self { root }
    }

    fn path(&self) -> &Path {
        &self.root
    }
}

impl Drop for TempProject {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.root);
    }
}

fn corpus_dir() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/corpus")
}

fn load_corpus_manifest(dir: &Path) -> CorpusManifest {
    let path = dir.join("manifest.json");
    let text = fs::read_to_string(&path)
        .unwrap_or_else(|e| panic!("cannot read corpus manifest {}: {e}", path.display()));
    let manifest: CorpusManifest = serde_json::from_str(&text)
        .unwrap_or_else(|e| panic!("malformed corpus manifest {}: {e}", path.display()));

    assert_eq!(
        manifest.format,
        1,
        "unsupported corpus manifest format {} in {}",
        manifest.format,
        path.display()
    );
    assert_eq!(
        manifest.case_count,
        manifest.cases.len(),
        "corpus manifest case_count={} does not match cases.len()={}",
        manifest.case_count,
        manifest.cases.len()
    );
    assert!(
        manifest.case_count > 0,
        "corpus manifest must name at least one fixture"
    );

    let case_set: BTreeSet<&str> = manifest.cases.iter().map(String::as_str).collect();
    assert_eq!(
        case_set.len(),
        manifest.cases.len(),
        "corpus manifest contains duplicate case names"
    );
    manifest
}

fn run_generated_crate(prefix: &str, lib_rs: String) {
    let project = TempProject::new(prefix);
    let runtime_manifest = Path::new(env!("CARGO_MANIFEST_DIR"));
    fs::write(
        project.path().join("Cargo.toml"),
        format!(
            r#"[package]
name = "{prefix}"
version = "0.0.0"
edition = "2024"

[dependencies]
linkedspec-runtime = {{ path = "{}" }}
serde_json = "1"
"#,
            runtime_manifest.display()
        ),
    )
    .expect("write generated smoke Cargo.toml");

    fs::write(project.path().join("src/lib.rs"), lib_rs).expect("write generated smoke lib.rs");

    let output = Command::new("cargo")
        .arg("test")
        .arg("--offline")
        .arg("--quiet")
        .env("CARGO_TARGET_DIR", project.path().join("target"))
        .current_dir(project.path())
        .output()
        .expect("run generated smoke cargo test");

    assert!(
        output.status.success(),
        "generated smoke cargo test failed\nstatus: {}\nstdout:\n{}\nstderr:\n{}",
        output.status,
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    );
}

fn rust_module_name_for_case(case_name: &str) -> String {
    format!("corpus_{case_name}")
}

#[test]
fn emitted_rust_source_compiles_and_runs_family_plan_matrix() {
    struct Case {
        module: &'static str,
        spec: &'static str,
        input: &'static str,
        expected: serde_json::Value,
        expected_family: &'static str,
        expected_mode: RuleMode,
    }

    let cases = vec![
        Case {
            module: "default_case",
            spec: SIMPLE_SOURCE_EMITTER_SPEC,
            input: "hello one hello two",
            expected: json!([["one", "two"]]),
            expected_family: "GeneratedRuleFamily::Default",
            expected_mode: RuleMode::Default,
        },
        Case {
            module: "or_acode_case",
            spec: OR_ACODE_SOURCE_EMITTER_SPEC,
            input: "go",
            expected: json!(["or-acode:go"]),
            expected_family: "GeneratedRuleFamily::OrAcode",
            expected_mode: RuleMode::Or,
        },
        Case {
            module: "and_single_acode_case",
            spec: AND_SINGLE_ACODE_SOURCE_EMITTER_SPEC,
            input: "one",
            expected: json!(["and-single"]),
            expected_family: "GeneratedRuleFamily::AndSingleAcode",
            expected_mode: RuleMode::And,
        },
        Case {
            module: "and_acode_seq_case",
            spec: AND_ACODE_SEQ_SOURCE_EMITTER_SPEC,
            input: "a b",
            expected: json!(["and-seq"]),
            expected_family: "GeneratedRuleFamily::AndAcodeSeq",
            expected_mode: RuleMode::And,
        },
        Case {
            module: "and_bcode_case",
            spec: AND_BCODE_SOURCE_EMITTER_SPEC,
            input: "a b",
            expected: json!([["A", "B"]]),
            expected_family: "GeneratedRuleFamily::AndBcode",
            expected_mode: RuleMode::And,
        },
        Case {
            module: "or_bcode_case",
            spec: OR_BCODE_SOURCE_EMITTER_SPEC,
            input: "a b",
            expected: json!(["or-bcode:A"]),
            expected_family: "GeneratedRuleFamily::OrBcode",
            expected_mode: RuleMode::Or,
        },
        Case {
            module: "or_bcode_miss_case",
            spec: OR_BCODE_LX_SOURCE_EMITTER_SPEC,
            input: "c",
            expected: json!(["or-miss"]),
            expected_family: "GeneratedRuleFamily::OrBcode",
            expected_mode: RuleMode::Or,
        },
        Case {
            module: "rep_acode_case",
            spec: REP_ACODE_SOURCE_EMITTER_SPEC,
            input: "abab",
            expected: json!([["a", "b", "a"]]),
            expected_family: "GeneratedRuleFamily::RepAcode",
            expected_mode: RuleMode::OrBounded {
                min: 2,
                max: Some(3),
            },
        },
        Case {
            module: "rep_bcode_case",
            spec: REP_BCODE_SOURCE_EMITTER_SPEC,
            input: "abab",
            expected: json!([["A", "B", "A"]]),
            expected_family: "GeneratedRuleFamily::RepBcode",
            expected_mode: RuleMode::OrBounded {
                min: 2,
                max: Some(3),
            },
        },
        Case {
            module: "rep_and_acode_case",
            spec: REP_AND_ACODE_SOURCE_EMITTER_SPEC,
            input: "abab",
            expected: json!([[["a", "b"], ["a", "b"]]]),
            expected_family: "GeneratedRuleFamily::RepAndAcode",
            expected_mode: RuleMode::AndBounded {
                min: 2,
                max: Some(2),
            },
        },
        Case {
            module: "rep_and_bcode_case",
            spec: REP_AND_BCODE_SOURCE_EMITTER_SPEC,
            input: "abab",
            expected: json!([[["A", "B"], ["A", "B"]]]),
            expected_family: "GeneratedRuleFamily::RepAndBcode",
            expected_mode: RuleMode::AndBounded {
                min: 2,
                max: Some(2),
            },
        },
        Case {
            module: "rep_zero_progress_case",
            spec: REP_ZERO_PROGRESS_SOURCE_EMITTER_SPEC,
            input: "abc",
            expected: json!([["i"]]),
            expected_family: "GeneratedRuleFamily::RepAcode",
            expected_mode: RuleMode::OrPlus,
        },
        Case {
            module: "rep_recursion_guard_case",
            spec: REP_RECURSION_GUARD_SOURCE_EMITTER_SPEC,
            input: "abc",
            expected: json!(["guard:"]),
            expected_family: "GeneratedRuleFamily::RepAcode",
            expected_mode: RuleMode::OrPlus,
        },
    ];

    let expected_non_rep_families = BTreeSet::from([
        "GeneratedRuleFamily::Default",
        "GeneratedRuleFamily::OrAcode",
        "GeneratedRuleFamily::AndSingleAcode",
        "GeneratedRuleFamily::AndAcodeSeq",
        "GeneratedRuleFamily::AndBcode",
        "GeneratedRuleFamily::OrBcode",
    ]);
    let mut covered_non_rep_families = BTreeSet::new();
    let expected_rep_families = BTreeSet::from([
        "GeneratedRuleFamily::RepAcode",
        "GeneratedRuleFamily::RepBcode",
        "GeneratedRuleFamily::RepAndAcode",
        "GeneratedRuleFamily::RepAndBcode",
    ]);
    let mut covered_rep_families = BTreeSet::new();
    let mut generated_modules = String::new();
    let mut generated_tests = String::from("#[cfg(test)]\nmod generated_source_tests {\n");

    for case in &cases {
        let parsed = parse_spec(case.spec).expect("parse source-emitter smoke spec");
        validate(&parsed).expect("validate source-emitter smoke spec");
        let compiled = compile(&parsed).expect("compile source-emitter smoke spec");

        let interpreted = Engine::new(compiled.clone())
            .execute(case.input)
            .expect("interpreted smoke parser should execute");
        assert_eq!(interpreted, case.expected);

        let top = compiled
            .top_rule()
            .expect("compiled smoke spec has a top rule");
        assert_eq!(top.mode, case.expected_mode);

        let generated = emit_rust_source(&compiled).expect("emit generated Rust source");
        if expected_non_rep_families.contains(case.expected_family) {
            covered_non_rep_families.insert(case.expected_family);
        }
        if expected_rep_families.contains(case.expected_family) {
            covered_rep_families.insert(case.expected_family);
        }
        assert!(generated.contains("LINKEDSPEC_GENERATED_SOURCE_FORMAT"));
        assert!(generated.contains("COMPILED_SPEC_JSON"));
        assert!(generated.contains("GENERATED_RULES"));
        assert!(!generated.contains("Engine::new"));
        assert!(generated.contains(case.expected_family));
        assert_eq!(
            format!("{:?}", classify_generated_rule_family(top)),
            case.expected_family
                .strip_prefix("GeneratedRuleFamily::")
                .expect("family marker has enum prefix")
        );

        generated_modules.push_str("pub mod ");
        generated_modules.push_str(case.module);
        generated_modules.push_str(" {\n");
        generated_modules.push_str(&generated);
        generated_modules.push_str("}\n\n");

        let input_literal = serde_json::to_string(case.input).expect("encode generated test input");
        let expected_literal =
            serde_json::to_string(&case.expected).expect("encode generated test expectation");
        generated_tests.push_str("    #[test]\n    fn ");
        generated_tests.push_str(case.module);
        generated_tests.push_str("_runs() {\n        let actual = crate::");
        generated_tests.push_str(case.module);
        generated_tests.push_str("::parse(");
        generated_tests.push_str(&input_literal);
        generated_tests.push_str(").expect(\"generated parser should run\");\n        let expected: serde_json::Value = serde_json::from_str(");
        generated_tests.push_str(
            &serde_json::to_string(&expected_literal).expect("encode expected JSON literal"),
        );
        generated_tests.push_str(").expect(\"expected JSON should parse\");\n        assert_eq!(actual, expected);\n    }\n");
    }
    assert_eq!(
        covered_non_rep_families, expected_non_rep_families,
        "source-emitter matrix must retain every non-REP generated family while adding REP coverage"
    );
    assert_eq!(
        covered_rep_families, expected_rep_families,
        "source-emitter matrix must cover every REP generated family before corpus integration"
    );
    generated_tests.push_str("}\n");

    run_generated_crate(
        "linkedspec_generated_smoke",
        format!("{generated_modules}\n{generated_tests}"),
    );
}

#[test]
fn legacy_repetition_family_plan_marker_still_executes_directly() {
    let parsed =
        parse_spec(REP_AND_BCODE_SOURCE_EMITTER_SPEC).expect("parse legacy repetition smoke spec");
    validate(&parsed).expect("validate legacy repetition smoke spec");
    let compiled = compile(&parsed).expect("compile legacy repetition smoke spec");

    let labels: Vec<&str> = compiled
        .rules
        .iter()
        .map(|rule| rule.label.as_str())
        .collect();
    assert_eq!(labels.as_slice(), ["Top", "A", "B"]);
    assert_eq!(
        classify_generated_rule_family(compiled.top_rule().expect("top rule")),
        GeneratedRuleFamily::RepAndBcode
    );

    let compiled_spec_json =
        serde_json::to_string(&compiled).expect("serialize legacy repetition compiled spec");
    let legacy_generated_rules = [
        GeneratedRuleSpec {
            label: "Top",
            family: GeneratedRuleFamily::Repetition,
        },
        GeneratedRuleSpec {
            label: "A",
            family: GeneratedRuleFamily::AndSingleAcode,
        },
        GeneratedRuleSpec {
            label: "B",
            family: GeneratedRuleFamily::AndSingleAcode,
        },
    ];

    let actual = execute_generated_parser(&compiled_spec_json, &legacy_generated_rules, "abab")
        .expect("legacy repetition marker should execute through direct specialization");
    assert_eq!(actual, json!([[["A", "B"], ["A", "B"]]]));
}

#[test]
fn generated_rust_source_matches_manifest_backed_corpus_subset() {
    let dir = corpus_dir();
    assert!(
        dir.is_dir(),
        "corpus directory missing: {} (run `perl tools/gen_oracle_corpus.pl`)",
        dir.display()
    );

    let manifest = load_corpus_manifest(&dir);
    let manifest_cases: BTreeSet<&str> = manifest.cases.iter().map(String::as_str).collect();
    for case_name in GENERATED_SOURCE_CORPUS_SUBSET {
        assert!(
            manifest_cases.contains(case_name),
            "generated-source corpus subset case {case_name:?} is not listed in manifest.json"
        );
    }

    let mut generated_modules = String::new();
    let mut generated_tests = String::from("#[cfg(test)]\nmod generated_corpus_tests {\n");

    for case_name in GENERATED_SOURCE_CORPUS_SUBSET {
        let case_dir = dir.join(case_name);
        let read = |file: &str| -> String {
            fs::read_to_string(case_dir.join(file)).unwrap_or_else(|e| {
                panic!(
                    "cannot read generated-source corpus subset file {}/{}: {e}",
                    case_dir.display(),
                    file
                )
            })
        };
        let source = read("input.spec");
        let input = read("input.txt");
        let expected_reference: Value =
            serde_json::from_str(&read("expected.json")).unwrap_or_else(|e| {
                panic!(
                    "malformed expected.json for generated-source corpus subset case {case_name}: {e}"
                )
            });
        let expected_engine_output = json!([expected_reference]);

        let parsed = parse_spec_with_user_functions(&source).unwrap_or_else(|e| {
            panic!("parse failed for generated-source corpus subset case {case_name}: {e}")
        });
        validate(&parsed).unwrap_or_else(|e| {
            panic!("validate failed for generated-source corpus subset case {case_name}: {e}")
        });
        let compiled = compile(&parsed).unwrap_or_else(|e| {
            panic!("compile failed for generated-source corpus subset case {case_name}: {e}")
        });

        let interpreted = Engine::new(compiled.clone())
            .execute(&input)
            .unwrap_or_else(|e| {
                panic!(
                    "interpreted execution failed for generated-source corpus subset case {case_name}: {e}"
                )
            });
        assert_eq!(
            interpreted, expected_engine_output,
            "generated-source corpus subset case {case_name} must first satisfy the interpreter oracle"
        );

        let generated = emit_rust_source(&compiled).unwrap_or_else(|e| {
            panic!("emit failed for generated-source corpus subset case {case_name}: {e}")
        });
        assert!(generated.contains("GENERATED_RULES"));

        let module = rust_module_name_for_case(case_name);
        generated_modules.push_str("pub mod ");
        generated_modules.push_str(&module);
        generated_modules.push_str(" {\n");
        generated_modules.push_str(&generated);
        generated_modules.push_str("}\n\n");

        let input_literal =
            serde_json::to_string(&input).expect("encode generated corpus test input");
        let expected_literal = serde_json::to_string(&expected_engine_output)
            .expect("encode generated corpus expectation");
        generated_tests.push_str("    #[test]\n    fn ");
        generated_tests.push_str(&module);
        generated_tests.push_str("_matches_oracle() {\n        let actual = crate::");
        generated_tests.push_str(&module);
        generated_tests.push_str("::parse(");
        generated_tests.push_str(&input_literal);
        generated_tests.push_str(").expect(\"generated corpus parser should run\");\n        let expected: serde_json::Value = serde_json::from_str(");
        generated_tests.push_str(
            &serde_json::to_string(&expected_literal).expect("encode expected JSON literal"),
        );
        generated_tests.push_str(").expect(\"expected JSON should parse\");\n        assert_eq!(actual, expected);\n    }\n");
    }

    generated_tests.push_str("}\n");
    run_generated_crate(
        "linkedspec_generated_corpus_subset",
        format!("{generated_modules}\n{generated_tests}"),
    );
}
