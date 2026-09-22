// ANCHOR: consumer
use linkedspec_runtime::RuntimeDiagnosticOutputExecutionError;
use linkedspec_runtime::engine::ExecutionOptions;
use linkedspec_runtime::spec_loader::{
    SpecLoadOptions, SpecPipelineError, SpecRequest, load_and_compile_spec,
};
use serde_json::json;
use std::error::Error;
use std::fmt;
use std::io::{self, Write};
use std::path::PathBuf;
use std::process::ExitCode;

const USAGE: &str = "usage: sexpr_file [--grammar PATH] [--] FILE [FILE ...]";

/// Retain the input identity alongside the library's original typed failure.
#[derive(Debug)]
struct DocumentParseError {
    input: String,
    source: RuntimeDiagnosticOutputExecutionError,
}

impl fmt::Display for DocumentParseError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(formatter, "{}: {}", self.input, self.source)
    }
}

impl Error for DocumentParseError {
    fn source(&self) -> Option<&(dyn Error + 'static)> {
        Some(&self.source)
    }
}

fn run() -> Result<(), Box<dyn Error>> {
    let mut arguments = std::env::args_os()
        .skip(1)
        .map(|argument| {
            argument
                .into_string()
                .map_err(|_| io::Error::new(io::ErrorKind::InvalidInput, "arguments must be UTF-8"))
        })
        .collect::<Result<Vec<_>, _>>()?
        .into_iter()
        .peekable();
    let explicit_grammar = if arguments.peek().map(String::as_str) == Some("--grammar") {
        arguments.next();
        Some(PathBuf::from(arguments.next().ok_or_else(|| {
            io::Error::new(io::ErrorKind::InvalidInput, USAGE)
        })?))
    } else {
        None
    };
    if arguments.peek().map(String::as_str) == Some("--") {
        arguments.next();
    }
    let files: Vec<String> = arguments.collect();
    if files.is_empty() {
        return Err(io::Error::new(io::ErrorKind::InvalidInput, USAGE).into());
    }
    let grammar = match explicit_grammar {
        Some(path) => path,
        None => std::env::current_exe()?
            .parent()
            .ok_or_else(|| {
                io::Error::new(
                    io::ErrorKind::InvalidData,
                    "executable has no parent directory",
                )
            })?
            .join("specs/SExprDocumentV1.spec"),
    };
    let grammar = grammar
        .to_str()
        .ok_or_else(|| io::Error::new(io::ErrorKind::InvalidInput, "grammar path must be UTF-8"))?;
    let loaded = load_and_compile_spec(
        &SpecRequest::path(grammar),
        &SpecLoadOptions::new(std::env::current_dir()?),
    )?;
    let engine = loaded.into_engine();
    let options = ExecutionOptions::new().with_entry_rule("Document");
    let mut output = io::stdout().lock();
    for path in files {
        // Read exact UTF-8; compile once, then execute each file independently.
        let input = std::fs::read_to_string(&path)
            .map_err(|error| io::Error::new(error.kind(), format!("{path}: {error}")))?;
        let document = engine
            .execute_value_with_diagnostic_output(&input, &options, None)
            .map_err(|source| DocumentParseError {
                input: path,
                source,
            })?;
        // The grammar already supplies the tagged document. No kind inference,
        // numeric conversion, escape decoding or head/tail adaptation is needed.
        serde_json::to_writer(&mut output, &document)?;
        writeln!(output)?;
    }
    Ok(())
}

fn report(error: &(dyn Error + 'static)) {
    let structured = if let Some(error) = error.downcast_ref::<SpecPipelineError>() {
        serde_json::to_value(error).ok()
    } else if let Some(error) = error.downcast_ref::<DocumentParseError>() {
        let cause = match &error.source {
            RuntimeDiagnosticOutputExecutionError::Exit(exit) => {
                Some(json!({"type": "runtime_exit_now", "status": exit.status}))
            }
            RuntimeDiagnosticOutputExecutionError::Runtime(runtime) => runtime.to_json().ok(),
            RuntimeDiagnosticOutputExecutionError::Sink(_) => None,
        };
        cause.map(
            |cause| json!({"type": "document_parse_error", "input": error.input, "cause": cause}),
        )
    } else {
        None
    };
    match structured {
        Some(value) => eprintln!("{value}"),
        None => eprintln!("sexpr_file: {error}"),
    }
}

fn main() -> ExitCode {
    match run() {
        Ok(()) => ExitCode::SUCCESS,
        Err(error) => {
            report(error.as_ref());
            ExitCode::FAILURE
        }
    }
}
// ANCHOR_END: consumer
