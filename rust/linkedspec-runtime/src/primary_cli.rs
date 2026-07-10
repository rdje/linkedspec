//! Backend-neutral primary-command adapter for the Rust variant.
//!
//! This module owns process-boundary policy only: exact argument parsing, source
//! and input selection, strict UTF-8 file decoding, stable phase failures, and
//! result framing. `.spec` parsing, validation, compilation, and execution stay
//! in `linkedspec-core` and `linkedspec-runtime`.

use crate::engine::{Engine, ExecutionOptions};
use crate::spec_parser::parse_spec_with_user_functions;
use linkedspec_core::compiler::compile;
use linkedspec_core::types::ParseMode;
use linkedspec_core::validation::validate;
use std::ffi::OsString;
use std::fs;
use std::path::{Path, PathBuf};

const DISPLAY_COMMAND: &str = "linkedspec-rust";
const HELP_TEMPLATE: &str = include_str!("../../../cli_conformance/cases/help/stdout.txt");

/// Exact primary-command process result before it is written to OS channels.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct CommandOutput {
    pub stdout: Vec<u8>,
    pub stderr: Vec<u8>,
    pub exit_code: i32,
}

impl CommandOutput {
    fn success(stdout: Vec<u8>) -> Self {
        Self {
            stdout,
            stderr: Vec::new(),
            exit_code: 0,
        }
    }

    fn operational_failure(message: &str) -> Self {
        Self {
            stdout: Vec::new(),
            stderr: format!("linkedspec: {message}\n").into_bytes(),
            exit_code: 1,
        }
    }

    fn usage_failure(message: &str) -> Self {
        Self {
            stdout: Vec::new(),
            stderr: format!("linkedspec: {message}\n\n{}", help_text()).into_bytes(),
            exit_code: 2,
        }
    }
}

/// Parsed primary-command options. Fields remain private to keep the adapter's
/// boundary stable while later trace wiring reuses this exact parser.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
struct PrimaryCliOptions {
    spec: Option<String>,
    spec_file: Option<String>,
    inline_spec: Option<String>,
    input: Option<String>,
    input_file: Option<String>,
    top_rule: Option<String>,
    parse_mode: Option<String>,
    trace_level: Option<String>,
    trace_file: Option<String>,
    trace_mode: Option<String>,
    trace_reset: bool,
    trace_emoji: bool,
}

#[derive(Debug, Clone, PartialEq, Eq)]
enum ParseOutcome {
    Help,
    Options(Box<PrimaryCliOptions>),
}

#[derive(Debug, Clone, PartialEq, Eq)]
enum InputSelection {
    Literal(String),
    File(PathBuf),
}

#[derive(Debug, Clone, PartialEq, Eq)]
struct PreparedRequest {
    options: PrimaryCliOptions,
    spec_source: String,
    input: InputSelection,
}

/// Render exact shared help bytes for the Rust executable token.
pub fn help_text() -> String {
    HELP_TEMPLATE.replace("{{COMMAND}}", DISPLAY_COMMAND)
}

/// Run the Rust primary command using explicit process context.
///
/// `cwd` controls relative file resolution. `repo_root` supplies the shipped
/// `specs/` fallback used by `--spec NAME`, making the behavior directly testable
/// without changing process-global working directory.
pub fn run_with_context(arguments: Vec<OsString>, cwd: &Path, repo_root: &Path) -> CommandOutput {
    let arguments = match decode_arguments(arguments) {
        Ok(arguments) => arguments,
        Err(message) => return CommandOutput::usage_failure(message),
    };
    let options = match parse_arguments(arguments) {
        Ok(ParseOutcome::Help) => return CommandOutput::success(help_text().into_bytes()),
        Ok(ParseOutcome::Options(options)) => *options,
        Err(message) => return CommandOutput::usage_failure(&message),
    };

    let request = match prepare_request(options, cwd, repo_root) {
        Ok(request) => request,
        Err(()) => return CommandOutput::operational_failure("parser compilation failed"),
    };

    let spec = match parse_spec_with_user_functions(&request.spec_source) {
        Ok(spec) => spec,
        Err(_) => return CommandOutput::operational_failure("parser compilation failed"),
    };
    if validate(&spec).is_err() {
        return CommandOutput::operational_failure("parser compilation failed");
    }
    let compiled = match compile(&spec) {
        Ok(compiled) => compiled,
        Err(_) => return CommandOutput::operational_failure("parser compilation failed"),
    };

    let mut execution_options = ExecutionOptions::new();
    if let Some(top_rule) = request.options.top_rule.clone() {
        execution_options = execution_options.with_entry_rule(top_rule);
    }
    if let Some(ref parse_mode) = request.options.parse_mode {
        let mode = if parse_mode == "consume" {
            ParseMode::Consume
        } else {
            ParseMode::Seek
        };
        execution_options = execution_options.with_parse_mode(mode);
    }

    let input = match load_input(&request.input) {
        Ok(input) => input,
        Err(()) => return CommandOutput::operational_failure("input load failed"),
    };
    let result = match Engine::new(compiled).execute_value(&input, &execution_options) {
        Ok(result) => result,
        Err(_) => return CommandOutput::operational_failure("parser invocation failed"),
    };
    let mut stdout = match serde_json::to_vec(&result) {
        Ok(stdout) => stdout,
        Err(_) => return CommandOutput::operational_failure("parser invocation failed"),
    };
    stdout.push(b'\n');
    CommandOutput::success(stdout)
}

/// Run with the real process working directory and the repository root derived
/// from this crate's build location.
pub fn run(arguments: Vec<OsString>) -> CommandOutput {
    let cwd = std::env::current_dir().unwrap_or_else(|_| PathBuf::from("."));
    let repo_root = Path::new(env!("CARGO_MANIFEST_DIR")).join("../..");
    run_with_context(arguments, &cwd, &repo_root)
}

fn decode_arguments(arguments: Vec<OsString>) -> Result<Vec<String>, &'static str> {
    arguments
        .into_iter()
        .map(|argument| {
            argument
                .into_string()
                .map_err(|_| "arguments must be valid UTF-8")
        })
        .collect()
}

fn parse_arguments(arguments: Vec<String>) -> Result<ParseOutcome, String> {
    let mut options = PrimaryCliOptions::default();
    let mut help = false;
    let mut errors = Vec::new();
    let mut index = 0;

    while index < arguments.len() {
        let argument = &arguments[index];
        let (option, inline_value) = split_option(argument);
        match option {
            "--help" | "-h" => {
                if inline_value.is_some() {
                    errors.push(format!("{option} does not accept a value"));
                } else {
                    help = true;
                }
            }
            "--trace-reset" | "--trace-emoji" => {
                if inline_value.is_some() {
                    errors.push(format!("{option} does not accept a value"));
                } else if option == "--trace-reset" {
                    options.trace_reset = true;
                } else {
                    options.trace_emoji = true;
                }
            }
            "--spec" | "--spec-file" | "--inline-spec" | "--input" | "--input-file"
            | "--top-rule" | "--parse-mode" | "--trace" | "--trace-file" | "--trace-mode" => {
                let value = if let Some(value) = inline_value {
                    value.to_string()
                } else if index + 1 >= arguments.len() {
                    errors.push(format!("{option} requires a value"));
                    index += 1;
                    continue;
                } else {
                    index += 1;
                    arguments[index].clone()
                };
                set_value_option(&mut options, option, value);
            }
            _ if option.starts_with('-') => errors.push(format!("unknown option '{option}'")),
            _ => errors.push(format!("unexpected positional argument '{argument}'")),
        }
        index += 1;
    }

    if !errors.is_empty() {
        return Err(errors.join("; "));
    }
    if help {
        return Ok(ParseOutcome::Help);
    }

    if defined_count([&options.spec, &options.spec_file, &options.inline_spec]) != 1 {
        return Err(
            "choose exactly one source option: --spec, --spec-file, or --inline-spec".into(),
        );
    }
    if defined_count([&options.input, &options.input_file]) != 1 {
        return Err("choose exactly one input option: --input or --input-file".into());
    }
    if options
        .parse_mode
        .as_deref()
        .is_some_and(|mode| mode != "seek" && mode != "consume")
    {
        return Err("--parse-mode must be 'seek' or 'consume'".into());
    }
    if let Some(level) = options.trace_level.as_deref()
        && !valid_trace_level(level)
    {
        return Err(format!("--trace has an unsupported level '{level}'"));
    }
    if options
        .trace_mode
        .as_deref()
        .is_some_and(|mode| !matches!(mode, "stdout" | "route" | "mirror"))
    {
        return Err("--trace-mode must be 'stdout', 'route', or 'mirror'".into());
    }
    Ok(ParseOutcome::Options(Box::new(options)))
}

fn split_option(argument: &str) -> (&str, Option<&str>) {
    if argument.starts_with("--")
        && let Some((option, value)) = argument.split_once('=')
    {
        return (option, Some(value));
    }
    (argument, None)
}

fn set_value_option(options: &mut PrimaryCliOptions, option: &str, value: String) {
    match option {
        "--spec" => options.spec = Some(value),
        "--spec-file" => options.spec_file = Some(value),
        "--inline-spec" => options.inline_spec = Some(value),
        "--input" => options.input = Some(value),
        "--input-file" => options.input_file = Some(value),
        "--top-rule" => options.top_rule = Some(value),
        "--parse-mode" => options.parse_mode = Some(value),
        "--trace" => options.trace_level = Some(value),
        "--trace-file" => options.trace_file = Some(value),
        "--trace-mode" => options.trace_mode = Some(value),
        _ => unreachable!("value option was validated by caller"),
    }
}

fn defined_count<const N: usize>(values: [&Option<String>; N]) -> usize {
    values.into_iter().filter(|value| value.is_some()).count()
}

fn valid_trace_level(level: &str) -> bool {
    let numeric = level
        .strip_prefix('-')
        .unwrap_or(level)
        .bytes()
        .all(|byte| byte.is_ascii_digit());
    if !level.is_empty() && numeric {
        return true;
    }
    matches!(
        level.to_ascii_lowercase().as_str(),
        "none" | "quiet" | "low" | "medium" | "med" | "high" | "full" | "debug" | "verbose"
    )
}

fn prepare_request(
    options: PrimaryCliOptions,
    cwd: &Path,
    repo_root: &Path,
) -> Result<PreparedRequest, ()> {
    let spec_source = if let Some(ref name) = options.spec {
        let path = resolve_named_spec(name, cwd, repo_root).ok_or(())?;
        read_utf8_file(&path)?
    } else if let Some(ref path) = options.spec_file {
        read_utf8_file(&explicit_path(path, cwd))?
    } else {
        options.inline_spec.clone().unwrap_or_default()
    };
    let input = if let Some(ref path) = options.input_file {
        InputSelection::File(explicit_path(path, cwd))
    } else {
        InputSelection::Literal(options.input.clone().unwrap_or_default())
    };
    Ok(PreparedRequest {
        options,
        spec_source,
        input,
    })
}

fn explicit_path(path: &str, cwd: &Path) -> PathBuf {
    let path = Path::new(path);
    if path.is_absolute() {
        path.to_path_buf()
    } else {
        cwd.join(path)
    }
}

fn resolve_named_spec(name: &str, cwd: &Path, repo_root: &Path) -> Option<PathBuf> {
    let filename = if name.ends_with(".spec") {
        name.to_string()
    } else {
        format!("{name}.spec")
    };
    let candidates = [
        explicit_path(name, cwd),
        explicit_path(&filename, cwd),
        repo_root.join("specs").join(filename),
    ];
    candidates.into_iter().find(|candidate| candidate.is_file())
}

fn read_utf8_file(path: &Path) -> Result<String, ()> {
    let bytes = fs::read(path).map_err(|_| ())?;
    String::from_utf8(bytes).map_err(|_| ())
}

fn load_input(input: &InputSelection) -> Result<String, ()> {
    match input {
        InputSelection::Literal(input) => Ok(input.clone()),
        InputSelection::File(path) => read_utf8_file(path),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn strings(arguments: &[&str]) -> Vec<OsString> {
        arguments.iter().map(OsString::from).collect()
    }

    #[test]
    fn help_is_exact_shared_template_for_rust_token() {
        let output = run_with_context(strings(&["--help"]), Path::new("."), Path::new("."));
        assert_eq!(output.exit_code, 0);
        assert!(output.stderr.is_empty());
        assert_eq!(output.stdout, help_text().into_bytes());
        assert!(
            !output
                .stdout
                .windows(11)
                .any(|bytes| bytes == b"{{COMMAND}}")
        );
    }

    #[test]
    fn option_parser_is_case_sensitive_non_abbreviating_and_orders_errors() {
        let output = run_with_context(
            strings(&["one", "--UNKNOWN", "two"]),
            Path::new("."),
            Path::new("."),
        );
        assert_eq!(output.exit_code, 2);
        let stderr = String::from_utf8(output.stderr).unwrap();
        assert!(stderr.starts_with(
            "linkedspec: unexpected positional argument 'one'; unknown option '--UNKNOWN'; unexpected positional argument 'two'\n\nUsage:\n"
        ));
    }

    #[test]
    fn source_compilation_precedes_deferred_input_file_loading() {
        let output = run_with_context(
            strings(&[
                "--inline-spec",
                "not a spec",
                "--input-file",
                "also-missing.txt",
            ]),
            Path::new("."),
            Path::new("."),
        );
        assert_eq!(output.exit_code, 1);
        assert_eq!(output.stderr, b"linkedspec: parser compilation failed\n");
    }

    #[test]
    fn strict_utf8_input_failure_stays_in_input_phase() {
        let root = std::env::temp_dir().join(format!(
            "linkedspec-rust-primary-cli-{}-{}",
            std::process::id(),
            std::thread::current().name().unwrap_or("test")
        ));
        fs::create_dir_all(&root).unwrap();
        fs::write(root.join("input.bin"), [0xc3, 0x28]).unwrap();
        let output = run_with_context(
            strings(&[
                "--inline-spec",
                "Top::\n /x/\n",
                "--input-file",
                "input.bin",
            ]),
            &root,
            &root,
        );
        fs::remove_dir_all(&root).unwrap();
        assert_eq!(output.exit_code, 1);
        assert_eq!(output.stderr, b"linkedspec: input load failed\n");
    }
}
