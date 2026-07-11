use linkedspec_runtime::engine::ExecutionOptions;
use linkedspec_runtime::spec_loader::{
    SpecLoadOptions, SpecPipelineCode, SpecPipelineStage, SpecRequest, load_and_compile_spec,
    load_spec, resolve_spec, validate_spec_request,
};
use serde_json::Value;
use std::fs;
use std::path::{Path, PathBuf};
use std::time::{SystemTime, UNIX_EPOCH};

const CONTRACT: &str =
    include_str!("../../../capability_conformance/native_spec_resolution_contract.json");

const USER_FUNCTION_SPEC: &str = r#"fn label() {return("hit")}

Top::
 /x/
 E { return(label()) }
"#;

struct ScratchDirectory {
    path: PathBuf,
}

impl ScratchDirectory {
    fn new(label: &str) -> Self {
        let nanos = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("clock after Unix epoch")
            .as_nanos();
        let path = std::env::temp_dir().join(format!(
            "linkedspec-rust-spec-loader-{label}-{}-{nanos}",
            std::process::id()
        ));
        fs::create_dir_all(&path).expect("create scratch directory");
        Self { path }
    }
}

impl Drop for ScratchDirectory {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.path);
    }
}

fn contract() -> Value {
    serde_json::from_str(CONTRACT).expect("parse native resolution contract")
}

fn fixture_path(root: &Path, value: &str) -> PathBuf {
    value
        .split('/')
        .fold(root.to_path_buf(), |path, component| path.join(component))
}

fn write_entry(root: &Path, entry: &Value) {
    let path = fixture_path(root, entry["path"].as_str().expect("entry path"));
    let kind = entry["kind"].as_str().expect("entry kind");
    match kind {
        "file" => {
            fs::create_dir_all(path.parent().expect("entry parent")).expect("create entry parent");
            fs::write(path, b"fixture").expect("write fixture file");
        }
        // Resolution treats every existing non-file equivalently. A directory
        // is portable test material for both neutral non-file classifications.
        "directory" | "non_regular" => {
            fs::create_dir_all(path).expect("create non-file fixture");
        }
        other => panic!("unsupported fixture entry kind {other}"),
    }
}

fn bytes_from_hex(hex: &str) -> Vec<u8> {
    assert_eq!(hex.len() % 2, 0, "complete hex bytes");
    (0..hex.len())
        .step_by(2)
        .map(|index| u8::from_str_radix(&hex[index..index + 2], 16).expect("valid fixture hex"))
        .collect()
}

#[test]
fn consumes_all_neutral_name_validation_cases() {
    let manifest = contract();
    for case in manifest["name_validation_cases"]
        .as_array()
        .expect("name cases")
    {
        let id = case["id"].as_str().expect("case id");
        let request = SpecRequest::named(case["value"].as_str().expect("case value"));
        let result = validate_spec_request(&request);
        match case["expect"]["status"].as_str().expect("status") {
            "ok" => assert!(result.is_ok(), "{id}: {result:?}"),
            "error" => {
                let error = result.expect_err(id);
                assert_eq!(error.stage.as_str(), case["expect"]["stage"], "{id}");
                assert_eq!(error.code.as_str(), case["expect"]["code"], "{id}");
            }
            other => panic!("{id}: unsupported status {other}"),
        }
    }
}

#[test]
fn consumes_all_neutral_resolution_and_file_kind_cases() {
    let manifest = contract();
    for case in manifest["resolution_cases"]
        .as_array()
        .expect("resolution cases")
    {
        let id = case["id"].as_str().expect("case id");
        let scratch = ScratchDirectory::new(id);
        for entry in case["entries"].as_array().expect("entries") {
            write_entry(&scratch.path, entry);
        }
        let request_value = case["request"]["value"].as_str().expect("request value");
        let request = match case["request"]["kind"].as_str().expect("request kind") {
            "name" => SpecRequest::named(request_value),
            "path" => SpecRequest::path(request_value),
            other => panic!("{id}: unsupported request kind {other}"),
        };
        let cwd = fixture_path(&scratch.path, case["cwd"].as_str().expect("cwd"));
        fs::create_dir_all(&cwd).expect("create cwd");
        let roots = case["search_roots"]
            .as_array()
            .expect("search roots")
            .iter()
            .map(|root| fixture_path(&scratch.path, root.as_str().expect("search root")));
        let options = SpecLoadOptions::new(&cwd).with_search_roots(roots);
        let result = resolve_spec(&request, &options);
        match case["expect"]["status"].as_str().expect("status") {
            "ok" => {
                let resolved = result.unwrap_or_else(|error| panic!("{id}: {error:?}"));
                assert_eq!(
                    resolved.path(),
                    fixture_path(
                        &scratch.path,
                        case["expect"]["path"].as_str().expect("expected path")
                    ),
                    "{id}"
                );
                assert_eq!(
                    resolved.origin().contract_name(),
                    case["expect"]["origin"],
                    "{id}"
                );
            }
            "error" => {
                let error = result.expect_err(id);
                assert_eq!(error.stage.as_str(), case["expect"]["stage"], "{id}");
                assert_eq!(error.code.as_str(), case["expect"]["code"], "{id}");
                let expected_path = case["expect"]["resolved_path"].as_str().map(|path| {
                    fixture_path(&scratch.path, path)
                        .to_string_lossy()
                        .into_owned()
                });
                assert_eq!(error.resolved_path, expected_path, "{id}");
            }
            other => panic!("{id}: unsupported status {other}"),
        }
    }
}

#[test]
fn consumes_all_neutral_strict_utf8_cases() {
    let manifest = contract();
    for case in manifest["text_cases"].as_array().expect("text cases") {
        let id = case["id"].as_str().expect("case id");
        let scratch = ScratchDirectory::new(id);
        let spec_path = scratch.path.join("source.spec");
        fs::write(
            &spec_path,
            bytes_from_hex(case["bytes_hex"].as_str().expect("hex bytes")),
        )
        .expect("write text fixture");
        let request = SpecRequest::path("source.spec");
        let result = load_spec(&request, &SpecLoadOptions::new(&scratch.path));
        match case["expect"]["status"].as_str().expect("status") {
            "ok" => assert_eq!(
                result.expect(id).source_text(),
                case["expect"]["text"].as_str().expect("expected text"),
                "{id}"
            ),
            "error" => {
                let error = result.expect_err(id);
                assert_eq!(error.stage.as_str(), case["expect"]["stage"], "{id}");
                assert_eq!(error.code.as_str(), case["expect"]["code"], "{id}");
            }
            other => panic!("{id}: unsupported status {other}"),
        }
    }
}

#[test]
fn composes_full_source_parse_validation_compile_and_engine_identity() {
    let scratch = ScratchDirectory::new("pipeline-success");
    let specs = scratch.path.join("specs");
    fs::create_dir_all(&specs).expect("create specs root");
    let spec_path = specs.join("Demo.spec");
    fs::write(&spec_path, USER_FUNCTION_SPEC).expect("write full spec");

    let request = SpecRequest::named("Demo");
    let loaded = load_and_compile_spec(
        &request,
        &SpecLoadOptions::new(scratch.path.join("cwd")).with_search_root(&specs),
    )
    .expect("load and compile full source");
    assert_eq!(loaded.loaded().source_text(), USER_FUNCTION_SPEC);
    assert_eq!(loaded.loaded().resolved().path(), spec_path);
    assert_eq!(loaded.compiled().functions.len(), 1);
    let engine = loaded.into_engine();
    assert_eq!(engine.spec_name(), Some("Demo"));
    assert_eq!(engine.spec_path(), spec_path.to_str());
    assert_eq!(
        engine
            .execute_value("x", &ExecutionOptions::new())
            .expect("execute loaded engine"),
        Value::String("hit".to_string())
    );
}

#[test]
fn projects_parse_and_validation_failures_as_structured_json() {
    let scratch = ScratchDirectory::new("pipeline-errors");
    let parse_path = scratch.path.join("parse.spec");
    fs::write(&parse_path, "not a spec\n").expect("write parse failure");
    let parse_error = load_and_compile_spec(
        &SpecRequest::path("parse.spec"),
        &SpecLoadOptions::new(&scratch.path),
    )
    .expect_err("parse must fail");
    assert_eq!(parse_error.stage, SpecPipelineStage::ParseSpec);
    assert_eq!(parse_error.code, SpecPipelineCode::SpecParseFailed);

    let validation_path = scratch.path.join("validation.spec");
    fs::write(&validation_path, "Only:\n /x/\n").expect("write validation failure");
    let validation_error = load_and_compile_spec(
        &SpecRequest::path("validation.spec"),
        &SpecLoadOptions::new(&scratch.path),
    )
    .expect_err("validation must fail");
    assert_eq!(validation_error.stage, SpecPipelineStage::ValidateSpec);
    assert_eq!(
        validation_error.code,
        SpecPipelineCode::SpecValidationFailed
    );

    let missing = resolve_spec(
        &SpecRequest::named("Missing"),
        &SpecLoadOptions::new(&scratch.path),
    )
    .expect_err("missing spec must fail");
    assert_eq!(
        serde_json::to_value(missing).expect("serialize structured error"),
        serde_json::json!({
            "type": "spec_pipeline_error",
            "stage": "resolve_spec_path",
            "code": "spec_path_not_found",
            "summary": "Spec path not found",
            "request_kind": "name",
            "requested": "Missing"
        })
    );
}
