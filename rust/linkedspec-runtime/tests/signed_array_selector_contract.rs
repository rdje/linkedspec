//! TYPE-REFERENCE-BOOK.1.2.17.3 — native and generated signed-array target.

use linkedspec_core::ast::BodyElementKind;
use linkedspec_core::ast::SpecFile;
use linkedspec_core::compiler::compile;
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use linkedspec_runtime::engine::{Engine, ExecutionOptions};
use linkedspec_runtime::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GeneratedPlanRow, emit_rust_source_v2, execute_generated_parser_v2,
};
use linkedspec_runtime::spec_parser::parse_spec_with_user_functions;
use serde_json::{Value, json};
use sha2::{Digest, Sha256};
use std::fs;
use std::io::Read;
#[cfg(unix)]
use std::os::unix::fs::{MetadataExt, PermissionsExt};
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

const CASES: &str = include_str!(concat!(
    env!("CARGO_MANIFEST_DIR"),
    "/../../tests/signed-array-rust/cases.json"
));
const PLAN: &[GeneratedPlanRow] = &[GeneratedPlanRow {
    label: "Top",
    family: "default",
}];

fn cases() -> Vec<Value> {
    let fixture: Value = serde_json::from_str(CASES).expect("signed-selector fixture JSON");
    fixture["cases"]
        .as_array()
        .expect("case population")
        .iter()
        .filter(|case| {
            case["pointer_width"]
                .as_u64()
                .is_none_or(|width| width == usize::BITS as u64)
        })
        .cloned()
        .collect()
}

#[derive(serde::Deserialize)]
struct SignedDiagnosticIntegers {
    #[serde(default)]
    index: Option<i128>,
    #[serde(default)]
    resolved_index: Option<i128>,
}

fn normalized(result: Result<Value, String>) -> Value {
    match result {
        Ok(value) => json!({"ok": value}),
        Err(error) => {
            let projection = serde_json::from_str::<Value>(&error)
                .unwrap_or_else(|_| Value::String(error.clone()));
            json!({"error": projection, "raw_error": error})
        }
    }
}

fn matches_expected(actual: &Value, expected: &Value) -> bool {
    if expected.get("ok").is_some() {
        return actual == expected;
    }
    let Some(mut raw) = actual["raw_error"].as_str() else {
        return false;
    };
    if let Some(contexts) = expected.get("codeblock_contexts").and_then(Value::as_array) {
        for context in contexts {
            let prefix = format!("codeblock '{}': ", context.as_str().expect("context name"));
            let Some(inner) = raw.strip_prefix(&prefix) else {
                return false;
            };
            raw = inner;
        }
    }
    let Ok(projection) = serde_json::from_str::<Value>(raw) else {
        return false;
    };
    expected["error"]
        .as_object()
        .expect("typed error expectations")
        .iter()
        .all(|(key, value)| {
            if let Some(integer) = value.get("exact_integer").and_then(Value::as_str) {
                let Ok(fields) = serde_json::from_str::<SignedDiagnosticIntegers>(raw) else {
                    return false;
                };
                let observed = match key.as_str() {
                    "index" => fields.index,
                    "resolved_index" => fields.resolved_index,
                    _ => None,
                };
                return observed == Some(integer.parse::<i128>().expect("exact integer target"));
            }
            projection.get(key) == Some(value)
        })
}

fn observe(case: &Value, route: &str, actual: Value, failures: &mut Vec<String>) {
    println!(
        "SIGNED_ARRAY_OBSERVATION {}",
        json!({"id": case["id"], "route": route, "actual": actual,
            "expected": case["expected"]})
    );
    if !matches_expected(&actual, &case["expected"]) {
        failures.push(format!("{} / {route}: {actual}", case["id"]));
    }
}

#[test]
fn signed_array_native_and_reconstructed_carriers() {
    let mut failures = Vec::new();
    for case in cases() {
        let source = case["source"].as_str().unwrap();
        let input = case["input"].as_str().unwrap();
        let parsed = parse_spec_with_user_functions(source)
            .unwrap_or_else(|error| panic!("{} fixture syntax: {error}", case["id"]));
        validate(&parsed).expect("valid authored fixture");
        let reconstructed: SpecFile =
            serde_json::from_value(serde_json::to_value(&parsed).unwrap()).unwrap();
        validate(&reconstructed).expect("valid reconstructed fixture");
        let compiled = compile(&parsed).expect("compile authored fixture");
        let reconstructed_compiled: CompiledSpec =
            serde_json::from_value(serde_json::to_value(&compiled).unwrap()).unwrap();
        for (route, compiled) in [
            ("native", compiled),
            ("spec_json", compile(&reconstructed).unwrap()),
            ("compiled_json", reconstructed_compiled),
        ] {
            let actual =
                normalized(Engine::new(compiled).execute_value(input, &ExecutionOptions::new()));
            observe(&case, route, actual, &mut failures);
        }
    }
    assert!(
        failures.is_empty(),
        "signed-array mismatches:\n{}",
        failures.join("\n")
    );
}

#[test]
fn signed_array_generated_plan_carrier() {
    let mut failures = Vec::new();
    for case in cases() {
        let parsed = parse_spec_with_user_functions(case["source"].as_str().unwrap())
            .unwrap_or_else(|error| panic!("{} fixture syntax: {error}", case["id"]));
        validate(&parsed).expect("valid authored fixture");
        let compiled = compile(&parsed).expect("compile authored fixture");
        let serialized = serde_json::to_string(&compiled).unwrap();
        let result = execute_generated_parser_v2(
            &serialized,
            PLAN,
            case["input"].as_str().unwrap(),
            "signed-array-selector.spec",
            GENERATED_SOURCE_CONTRACT,
        )
        .map_err(|error| error.detail.as_deref().unwrap_or(error.summary).to_owned());
        observe(&case, "generated_plan", normalized(result), &mut failures);
    }
    assert!(
        failures.is_empty(),
        "signed-array mismatches:\n{}",
        failures.join("\n")
    );
}

#[test]
fn signed_diagnostic_typed_json_preserves_exact_integer_tokens() {
    let mut failures = Vec::new();
    for source in ["-4", "-9223372036854775805", "-18446744073709549565"] {
        let value: i128 = serde_json::from_str(source).expect("valid signed diagnostic integer");
        let encoded = serde_json::to_string(&value).expect("serialize signed diagnostic integer");
        let reconstructed: i128 =
            serde_json::from_str(&encoded).expect("decode diagnostic integer");
        assert_eq!(reconstructed, value);
        println!(
            "SIGNED_ARRAY_JSON_BOUNDARY {}",
            json!({"source": source, "encoded": encoded})
        );
        if encoded != source {
            failures.push(format!("{source} became {encoded}"));
        }
    }
    assert!(
        failures.is_empty(),
        "signed diagnostic JSON loss:\n{}",
        failures.join("\n")
    );
}

#[test]
fn signed_array_public_action_span_origin_is_trimmed_action_source() {
    let body = r#"tree={"é":[1]}; tree["é"][-2]=99; return(tree)"#;
    for padding in [" ", "     ", "\n   "] {
        let source = format!("Top: /x/\n I {{{padding}{body}{padding}}}\n");
        let parsed =
            parse_spec_with_user_functions(&source).expect("parse public span calibration");
        let code = parsed.rules[0]
            .body
            .iter()
            .find_map(|element| match &element.kind {
                BodyElementKind::CodeBlock { code, lifecycle } if lifecycle == "I" => Some(code),
                _ => None,
            })
            .expect("one init action");
        println!(
            "SIGNED_ARRAY_SPAN_ORIGIN {}",
            json!({"source": source, "action_source": code})
        );
        assert_eq!(code, body, "public parser trims outer action whitespace");
    }
    let character_start = body[..body.find("[-2]").unwrap() + 1].chars().count();
    assert_eq!(character_start, 26);
    assert_ne!(
        character_start,
        body.find("[-2]").unwrap() + 1,
        "Unicode scalar and byte offsets differ"
    );
}

struct EmittedWorkspace {
    root: PathBuf,
    cache: PathBuf,
    repository: PathBuf,
    package: String,
}

fn checked_child_directory(parent: &Path, name: &str, repository: &Path) -> PathBuf {
    let child = parent.join(name);
    match fs::create_dir(&child) {
        Ok(()) => {}
        Err(error) if error.kind() == std::io::ErrorKind::AlreadyExists => {}
        Err(error) => panic!("create owned emitted directory: {error}"),
    }
    let metadata = fs::symlink_metadata(&child).expect("owned emitted directory metadata");
    assert!(metadata.is_dir() && !metadata.file_type().is_symlink());
    assert!(!child.join(".git").exists(), "exclude other repositories");
    assert!(child.canonicalize().unwrap().starts_with(repository));
    #[cfg(unix)]
    assert_eq!(metadata.dev(), repository.metadata().unwrap().dev());
    child
}

impl EmittedWorkspace {
    fn new() -> Self {
        let cwd = std::env::current_dir().expect("current project directory");
        let repository = cwd
            .ancestors()
            .find(|path| {
                path.join("MEMORY_ARCHITECTURE.md").is_file()
                    && path.join("rust/linkedspec-runtime/Cargo.toml").is_file()
            })
            .expect("run through the repository Cargo wrapper")
            .canonicalize()
            .unwrap();
        let rust = repository.join("rust");
        let rust_metadata = fs::symlink_metadata(&rust).unwrap();
        assert!(rust_metadata.is_dir() && !rust_metadata.file_type().is_symlink());
        assert!(!rust.join(".git").exists());
        #[cfg(unix)]
        assert_eq!(rust_metadata.dev(), repository.metadata().unwrap().dev());
        let target = repository.join("rust/target");
        let metadata = fs::symlink_metadata(&target).expect("managed Rust target exists");
        assert!(metadata.is_dir() && !metadata.file_type().is_symlink());
        assert!(!target.join(".git").exists());
        #[cfg(unix)]
        assert_eq!(metadata.dev(), repository.metadata().unwrap().dev());
        let parent = checked_child_directory(&target, "test-workspaces", &repository);
        let cache = checked_child_directory(&target, "signed-array-emitted-cache", &repository);
        let nonce = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_nanos();
        let package = format!(
            "linkedspec_signed_array_emitted_{}_{}",
            std::process::id(),
            nonce
        );
        let root = parent.join(&package);
        fs::create_dir(&root).expect("exclusive emitted workspace");
        let project = Self {
            root,
            cache,
            repository,
            package,
        };
        fs::create_dir(project.root.join("src")).expect("emitted sources directory");
        project
    }
}

impl Drop for EmittedWorkspace {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.root);
    }
}

#[test]
fn signed_array_independently_compiled_emitted_source() {
    let cases = cases();
    let mut source = String::new();
    for (index, case) in cases.iter().enumerate() {
        let authored = case["source"].as_str().unwrap();
        assert!(authored.starts_with("Top:"));
        source.push_str(&authored.replacen("Top:", &format!("SignedCase{index}:"), 1));
        source.push('\n');
    }
    let parsed = parse_spec_with_user_functions(&source).expect("parse emitted case inventory");
    validate(&parsed).expect("validate emitted case inventory");
    let compiled = compile(&parsed).expect("compile emitted case inventory");
    println!("SIGNED_ARRAY_MERGED_SPEC {}", json!({"source": source}));
    let mut merged_failures = Vec::new();
    for (index, case) in cases.iter().enumerate() {
        let options = ExecutionOptions::new().with_entry_rule(format!("SignedCase{index}"));
        let actual =
            Engine::new(compiled.clone()).execute_value(case["input"].as_str().unwrap(), &options);
        observe(
            case,
            "merged_native",
            normalized(actual),
            &mut merged_failures,
        );
    }
    assert!(
        merged_failures.is_empty(),
        "merged fixture mismatch:\n{}",
        merged_failures.join("\n")
    );
    let emitted = emit_rust_source_v2(&compiled, "signed-array-emitted.spec").unwrap();
    let project = EmittedWorkspace::new();
    let manifest = format!(
        "[package]\nname = {:?}\nversion = \"0.0.0\"\nedition = \"2024\"\n\n[dependencies]\nlinkedspec-runtime = {{ path = \"../../../linkedspec-runtime\" }}\nserde_json = \"1\"\n\n[workspace]\n",
        project.package,
    );
    let mut harness = String::from(
        "\n#[cfg(test)]\nmod signed_emitted_cases {\n#[test]\nfn actual_entries() {\n",
    );
    for (index, case) in cases.iter().enumerate() {
        harness.push_str(&format!(
            "{{ let result = super::execute_with_options({:?}, &linkedspec_runtime::engine::ExecutionOptions::new().with_entry_rule({:?})); let row = match result {{ Ok(value) => serde_json::json!({{\"id\": {:?}, \"ok\": value}}), Err(error) => serde_json::json!({{\"id\": {:?}, \"raw_error\": error.detail.as_deref().unwrap_or(error.summary)}}) }}; println!(\"SIGNED_ARRAY_EMITTED_ROW {{}}\", row); }}\n",
            case["input"].as_str().unwrap(), format!("SignedCase{index}"),
            case["id"].as_str().unwrap(), case["id"].as_str().unwrap(),
        ));
    }
    harness.push_str("}\n}\n");
    let module = emitted + &harness;
    fs::write(project.root.join("Cargo.toml"), &manifest).unwrap();
    fs::write(project.root.join("src/lib.rs"), &module).unwrap();
    println!(
        "SIGNED_ARRAY_EMITTED_INPUTS {}",
        json!({"spec": source, "manifest": manifest, "module": module})
    );
    let build = Command::new("cargo")
        .args(["test", "--offline", "--no-run", "--message-format=json"])
        .env("CARGO_TARGET_DIR", &project.cache)
        .current_dir(&project.root)
        .output()
        .expect("compile actual emitted module");
    println!(
        "SIGNED_ARRAY_EMITTED_BUILD {}",
        json!({
            "status": build.status.code(), "stdout": String::from_utf8_lossy(&build.stdout),
            "stderr": String::from_utf8_lossy(&build.stderr),
            "lock": fs::read_to_string(project.root.join("Cargo.lock")).ok(),
        })
    );
    assert!(
        build.status.success(),
        "emitted build failed; inspect retained channels"
    );
    let artifacts = String::from_utf8(build.stdout)
        .unwrap()
        .lines()
        .map(|line| serde_json::from_str::<Value>(line).unwrap())
        .filter(|message| {
            message["reason"] == "compiler-artifact"
                && message["target"]["name"] == project.package
                && message["executable"].is_string()
        })
        .collect::<Vec<_>>();
    assert_eq!(artifacts.len(), 1);
    let executable = PathBuf::from(artifacts[0]["executable"].as_str().unwrap());
    let relative = executable.strip_prefix(&project.repository).unwrap();
    let mut file = fs::File::open(&executable).unwrap();
    let mut digest = Sha256::new();
    let mut buffer = [0u8; 65536];
    loop {
        let count = file.read(&mut buffer).unwrap();
        if count == 0 {
            break;
        }
        digest.update(&buffer[..count]);
    }
    let metadata = executable.metadata().unwrap();
    #[cfg(unix)]
    let mode = Some(metadata.permissions().mode() & 0o7777);
    #[cfg(not(unix))]
    let mode: Option<u32> = None;
    let sha256 = digest
        .finalize()
        .iter()
        .map(|byte| format!("{byte:02x}"))
        .collect::<String>();
    println!(
        "SIGNED_ARRAY_EMITTED_EXECUTABLE {}",
        json!({
            "path": relative.to_str().unwrap(), "sha256": sha256,
            "bytes": metadata.len(), "mode": mode,
        })
    );
    let run = Command::new(&executable)
        .arg("--nocapture")
        .output()
        .unwrap();
    println!(
        "SIGNED_ARRAY_EMITTED_RUN {}",
        json!({"status": run.status.code(),
        "stdout": String::from_utf8_lossy(&run.stdout), "stderr": String::from_utf8_lossy(&run.stderr)})
    );
    assert!(
        run.status.success(),
        "emitted execution failed; inspect retained channels"
    );
    let mut failures = Vec::new();
    let mut observed = std::collections::BTreeSet::new();
    for line in String::from_utf8(run.stdout).unwrap().lines() {
        if let Some((_, row)) = line.split_once("SIGNED_ARRAY_EMITTED_ROW ") {
            let row: Value = serde_json::from_str(row).unwrap();
            let id = row["id"].as_str().unwrap();
            assert!(observed.insert(id.to_owned()));
            let case = cases
                .iter()
                .find(|case| case["id"] == id)
                .expect("known emitted case");
            let actual = if let Some(value) = row.get("ok") {
                normalized(Ok(value.clone()))
            } else {
                normalized(Err(row["raw_error"].as_str().unwrap().to_owned()))
            };
            observe(case, "emitted", actual, &mut failures);
        }
    }
    assert_eq!(observed.len(), cases.len());
    assert!(
        failures.is_empty(),
        "emitted mismatches:\n{}",
        failures.join("\n")
    );
}
