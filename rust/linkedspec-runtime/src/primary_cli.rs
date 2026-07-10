//! Backend-neutral primary-command adapter for the Rust variant.
//!
//! This module owns process-boundary policy only: exact argument parsing, source
//! and input selection, strict UTF-8 file decoding, stable phase failures,
//! canonical portable trace projection, and result framing. `.spec` parsing,
//! validation, compilation, execution, and rich native tracing stay in
//! `linkedspec-core` and `linkedspec-runtime`.

use crate::engine::{Engine, ExecutionOptions};
use crate::spec_parser::parse_spec_with_user_functions;
use linkedspec_core::compiler::compile;
use linkedspec_core::types::ParseMode;
use linkedspec_core::validation::validate;
use std::ffi::OsString;
use std::fs;
use std::fs::OpenOptions;
use std::io::Write;
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
        Self::operational_failure_with_stdout(message, Vec::new())
    }

    fn operational_failure_with_stdout(message: &str, stdout: Vec<u8>) -> Self {
        Self {
            stdout,
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

/// Parsed primary-command options. Fields remain private because this adapter,
/// rather than the language runtime, owns the portable process boundary.
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

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum CanonicalTraceMode {
    Stdout,
    Route,
    Mirror,
}

#[derive(Debug)]
struct CanonicalTrace {
    level: i64,
    file: Option<PathBuf>,
    mode: CanonicalTraceMode,
    emoji: bool,
    stdout: Vec<u8>,
}

impl CanonicalTrace {
    fn new(options: &PrimaryCliOptions, cwd: &Path) -> Result<Self, ()> {
        let file = options
            .trace_file
            .as_deref()
            .filter(|path| !path.is_empty())
            .map(|path| explicit_path(path, cwd));
        let mode = match options.trace_mode.as_deref() {
            Some("route") => CanonicalTraceMode::Route,
            Some("mirror") => CanonicalTraceMode::Mirror,
            Some("stdout") => CanonicalTraceMode::Stdout,
            None if file.is_some() => CanonicalTraceMode::Route,
            None => CanonicalTraceMode::Stdout,
            Some(_) => unreachable!("trace mode was validated by the argument parser"),
        };
        if options.trace_reset
            && let Some(path) = &file
        {
            fs::File::create(path).map_err(|_| ())?;
        }
        Ok(Self {
            level: trace_level_number(options.trace_level.as_deref()),
            file,
            mode,
            emoji: options.trace_emoji,
            stdout: Vec::new(),
        })
    }

    fn emit(&mut self, threshold: i64, level_name: &str, event: &str) -> Result<(), ()> {
        if self.level < threshold {
            return Ok(());
        }
        let emoji = if self.emoji {
            format!("{} ", trace_emoji_prefix(threshold))
        } else {
            String::new()
        };
        let line = format!("[linkedspec][{level_name}] {emoji}{event}\n").into_bytes();
        if matches!(
            self.mode,
            CanonicalTraceMode::Stdout | CanonicalTraceMode::Mirror
        ) {
            self.stdout.extend_from_slice(&line);
        }
        if matches!(
            self.mode,
            CanonicalTraceMode::Route | CanonicalTraceMode::Mirror
        ) && let Some(path) = &self.file
        {
            let mut file = OpenOptions::new()
                .create(true)
                .append(true)
                .open(path)
                .map_err(|_| ())?;
            file.write_all(&line).map_err(|_| ())?;
            file.flush().map_err(|_| ())?;
        }
        Ok(())
    }

    fn take_stdout(&mut self) -> Vec<u8> {
        std::mem::take(&mut self.stdout)
    }
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

    run_prepared_options(options, cwd, repo_root)
}

fn run_prepared_options(options: PrimaryCliOptions, cwd: &Path, repo_root: &Path) -> CommandOutput {
    let mut trace = match CanonicalTrace::new(&options, cwd) {
        Ok(trace) => trace,
        Err(()) => return CommandOutput::operational_failure("parser compilation failed"),
    };
    let source_kind = if options.spec.is_some() {
        "named"
    } else if options.spec_file.is_some() {
        "file"
    } else {
        "inline"
    };
    let input_kind = if options.input_file.is_some() {
        "file"
    } else {
        "literal"
    };
    let source_argument = options
        .spec
        .as_deref()
        .or(options.spec_file.as_deref())
        .or(options.inline_spec.as_deref())
        .unwrap_or_default();
    let input_argument = options
        .input_file
        .as_deref()
        .or(options.input.as_deref())
        .unwrap_or_default();
    let top_rule = options
        .top_rule
        .as_deref()
        .map(trace_field)
        .unwrap_or_else(|| "<default>".into());
    let parse_mode = options.parse_mode.as_deref().unwrap_or("seek");

    if let Err(output) = emit_trace(&mut trace, 100, "low", "compile:start") {
        return output;
    }
    if let Err(output) = emit_trace(
        &mut trace,
        200,
        "medium",
        &format!(
            "request source={source_kind} input={input_kind} top_rule={top_rule} parse_mode={parse_mode}"
        ),
    ) {
        return output;
    }
    if let Err(output) = emit_trace(
        &mut trace,
        300,
        "high",
        &format!(
            "arguments source_bytes={} input_bytes={}",
            source_argument.len(),
            input_argument.len()
        ),
    ) {
        return output;
    }
    if let Err(output) = emit_trace(&mut trace, 500, "debug", "protocol version=1") {
        return output;
    }

    let request = match prepare_request(options, cwd, repo_root) {
        Ok(request) => request,
        Err(()) => return phase_failure(&mut trace, "compile:error", "parser compilation failed"),
    };

    let spec = match parse_spec_with_user_functions(&request.spec_source) {
        Ok(spec) => spec,
        Err(_) => return phase_failure(&mut trace, "compile:error", "parser compilation failed"),
    };
    if validate(&spec).is_err() {
        return phase_failure(&mut trace, "compile:error", "parser compilation failed");
    }
    let compiled = match compile(&spec) {
        Ok(compiled) => compiled,
        Err(_) => return phase_failure(&mut trace, "compile:error", "parser compilation failed"),
    };
    if let Err(output) = emit_trace(&mut trace, 100, "low", "compile:ok") {
        return output;
    }

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

    if let Err(output) = emit_trace(&mut trace, 100, "low", "input:start") {
        return output;
    }
    let input = match load_input(&request.input) {
        Ok(input) => input,
        Err(()) => return phase_failure(&mut trace, "input:error", "input load failed"),
    };
    if let Err(output) = emit_trace(
        &mut trace,
        300,
        "high",
        &format!("input bytes={}", input.len()),
    ) {
        return output;
    }
    if let Err(output) = emit_trace(&mut trace, 100, "low", "input:ok") {
        return output;
    }
    if let Err(output) = emit_trace(&mut trace, 100, "low", "invoke:start") {
        return output;
    }
    let result = match Engine::new(compiled).execute_value(&input, &execution_options) {
        Ok(result) => result,
        Err(_) => return phase_failure(&mut trace, "invoke:error", "parser invocation failed"),
    };
    if let Err(output) = emit_trace(&mut trace, 100, "low", "invoke:ok") {
        return output;
    }
    let json = match serde_json::to_vec(&result) {
        Ok(stdout) => stdout,
        Err(_) => return phase_failure(&mut trace, "invoke:error", "parser invocation failed"),
    };
    if let Err(output) = emit_trace(
        &mut trace,
        400,
        "full",
        &format!("result json_bytes={}", json.len()),
    ) {
        return output;
    }
    let mut stdout = trace.take_stdout();
    stdout.extend_from_slice(&json);
    stdout.push(b'\n');
    CommandOutput::success(stdout)
}

fn emit_trace(
    trace: &mut CanonicalTrace,
    threshold: i64,
    level_name: &str,
    event: &str,
) -> Result<(), CommandOutput> {
    trace.emit(threshold, level_name, event).map_err(|()| {
        CommandOutput::operational_failure_with_stdout(
            "parser compilation failed",
            trace.take_stdout(),
        )
    })
}

fn phase_failure(
    trace: &mut CanonicalTrace,
    event: &str,
    operational_message: &str,
) -> CommandOutput {
    let message = if trace.emit(100, "low", event).is_ok() {
        operational_message
    } else {
        "parser compilation failed"
    };
    CommandOutput::operational_failure_with_stdout(message, trace.take_stdout())
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
    if numeric_trace_level(level) {
        return true;
    }
    matches!(
        level.to_ascii_lowercase().as_str(),
        "none" | "quiet" | "low" | "medium" | "med" | "high" | "full" | "debug" | "verbose"
    )
}

fn numeric_trace_level(level: &str) -> bool {
    let digits = level.strip_prefix('-').unwrap_or(level);
    !digits.is_empty() && digits.bytes().all(|byte| byte.is_ascii_digit())
}

fn trace_level_number(level: Option<&str>) -> i64 {
    let Some(level) = level else {
        return 0;
    };
    if numeric_trace_level(level) {
        return level.parse::<i64>().unwrap_or_else(|_| {
            if level.starts_with('-') {
                i64::MIN
            } else {
                i64::MAX
            }
        });
    }
    match level.to_ascii_lowercase().as_str() {
        "none" | "quiet" => 0,
        "low" => 100,
        "medium" | "med" => 200,
        "high" => 300,
        "full" => 400,
        "debug" | "verbose" => 500,
        _ => unreachable!("trace level was validated by the argument parser"),
    }
}

fn trace_emoji_prefix(level: i64) -> &'static str {
    match level {
        100 => "ℹ️",
        200 => "🔎",
        300 => "🧭",
        400 => "🐞",
        _ => "🔥",
    }
}

fn trace_field(value: &str) -> String {
    let mut escaped = String::new();
    for byte in value.as_bytes() {
        if byte.is_ascii_alphanumeric() || matches!(byte, b'_' | b'.' | b':' | b'-') {
            escaped.push(char::from(*byte));
        } else {
            use std::fmt::Write as _;
            write!(&mut escaped, "%{byte:02X}").expect("writing to a String cannot fail");
        }
    }
    escaped
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
    fn trace_level_syntax_and_field_escaping_are_protocol_exact() {
        assert!(!valid_trace_level("-"));
        assert_eq!(trace_level_number(Some("med")), 200);
        assert_eq!(trace_level_number(Some("250")), 250);
        assert_eq!(trace_level_number(Some("999999999999999999999")), i64::MAX);
        assert_eq!(trace_field("Top\nré"), "Top%0Ar%C3%A9");
    }

    #[test]
    fn trace_file_setup_failure_is_a_compile_phase_failure() {
        let output = run_with_context(
            strings(&[
                "--inline-spec",
                "Top::\n /x/\n",
                "--input",
                "x",
                "--trace",
                "low",
                "--trace-file",
                ".",
                "--trace-reset",
            ]),
            Path::new("."),
            Path::new("."),
        );
        assert_eq!(output.exit_code, 1);
        assert!(output.stdout.is_empty());
        assert_eq!(output.stderr, b"linkedspec: parser compilation failed\n");
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
