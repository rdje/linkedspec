//! RUST-PARITY.8.2/.8.3.1-.8.3.5 — generated Rust-source compile/run proof.

use linkedspec_core::ast::RuleMode;
use linkedspec_core::compiler::compile;
use linkedspec_core::parser::parse_spec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::Engine;
use linkedspec_runtime::source_emitter::{classify_generated_rule_family, emit_rust_source};
use serde_json::json;
use std::collections::BTreeSet;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

const SIMPLE_SOURCE_EMITTER_SPEC: &str = r#"Top::
 I { declare(array, words) }
 /hello[ \t]+(\w+)/
 LE { push_value(array(words), match_group(0)) }
 E { return(array_copy(array(words))) }
"#;

const OR_ACODE_SOURCE_EMITTER_SPEC: &str = r#"Top::OR
 /go/ -> Done { return(concat("or-acode:", call(Done))) }

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
 I { declare(array, log) }
 => ChildA { push_value(array(log), :retv) }
 => ChildB { push_value(array(log), :retv) }
 E { return(array_copy(array(log))) }

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
 E { return(concat("or-bcode:", :retv)) }

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
        covered_non_rep_families.insert(case.expected_family);
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
        "source-emitter matrix must cover every non-REP generated family before REP work starts"
    );
    generated_tests.push_str("}\n");

    let project = TempProject::new("linkedspec-source-emitter");
    let runtime_manifest = Path::new(env!("CARGO_MANIFEST_DIR"));
    fs::write(
        project.path().join("Cargo.toml"),
        format!(
            r#"[package]
name = "linkedspec_generated_smoke"
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

    fs::write(
        project.path().join("src/lib.rs"),
        format!("{generated_modules}\n{generated_tests}"),
    )
    .expect("write generated smoke lib.rs");

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
