// ANCHOR: consumer
use linkedspec_runtime::RuntimeExecutionError;
use linkedspec_runtime::engine::ExecutionOptions;
use linkedspec_runtime::spec_loader::{
    SpecLoadOptions, SpecPipelineError, SpecRequest, load_and_compile_spec,
};
use serde::Serialize;
use serde_json::Value;
use std::error::Error;
use std::io::{self, Write};
use std::path::PathBuf;
use std::process::ExitCode;

const USAGE: &str = "usage: lispish_file [--grammar PATH] [--] FILE [FILE ...]";
const MAX_ADAPTER_DEPTH: usize = 256;

// ANCHOR: adapter
/// Application values: Lispish does not retain symbol/string/number token kinds.
#[derive(Debug, PartialEq, Serialize)]
#[serde(untagged)]
enum SExpression {
    Atom(String),
    List(Vec<SExpression>),
}

fn invalid_data(message: &str) -> io::Error {
    io::Error::new(io::ErrorKind::InvalidData, message)
}

/// Convert the historical head/tail representation into ordinary nested lists.
/// This checks result shape; it cannot validate text the grammar already skipped.
fn decode_form(value: Value, depth: usize) -> io::Result<SExpression> {
    if depth >= MAX_ADAPTER_DEPTH {
        return Err(invalid_data(
            "result exceeds the adapter's 256-list depth limit",
        ));
    }
    let Value::Array(fields) = value else {
        return Err(invalid_data("Lispish returned no parenthesized form"));
    };
    let mut fields = fields.into_iter();
    let (head, tail) = match (fields.next(), fields.next(), fields.next()) {
        (Some(Value::Null), None, None) => return Ok(SExpression::List(Vec::new())),
        (Some(head), Some(tail), None) => (head, tail),
        _ => return Err(invalid_data("unexpected Lispish head/tail result shape")),
    };
    let tail = match tail {
        Value::Null => Vec::new(),
        Value::Array(items) => items,
        _ => return Err(invalid_data("Lispish tail must be an array or null")),
    };
    let mut items = Vec::with_capacity(tail.len() + 1);
    for item in std::iter::once(head).chain(tail) {
        items.push(match item {
            Value::String(text) => SExpression::Atom(text),
            Value::Array(_) => decode_form(item, depth + 1)?,
            _ => return Err(invalid_data("Lispish item must be text or a nested form")),
        });
    }
    Ok(SExpression::List(items))
}
// ANCHOR_END: adapter

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
            .ok_or_else(|| invalid_data("executable has no parent directory"))?
            .join("specs/Lispish.spec"),
    };
    let grammar = grammar
        .to_str()
        .ok_or_else(|| io::Error::new(io::ErrorKind::InvalidInput, "grammar path must be UTF-8"))?;
    let loaded = load_and_compile_spec(
        &SpecRequest::path(grammar),
        &SpecLoadOptions::new(std::env::current_dir()?),
    )?;
    let engine = loaded.into_engine();
    let options = ExecutionOptions::new();
    let mut output = io::stdout().lock();
    for path in files {
        // Read exact UTF-8 text. Each execution receives an independent input.
        let input = std::fs::read_to_string(&path)
            .map_err(|error| io::Error::new(error.kind(), format!("{path}: {error}")))?;
        let value = engine.execute_value_with_diagnostics(&input, &options)?;
        let form = decode_form(value, 0)
            .map_err(|error| io::Error::new(error.kind(), format!("{path}: {error}")))?;
        serde_json::to_writer(&mut output, &form)?;
        writeln!(output)?;
    }
    Ok(())
}

fn report(error: &(dyn Error + 'static)) {
    let structured = if let Some(error) = error.downcast_ref::<SpecPipelineError>() {
        Some(serde_json::to_value(error))
    } else {
        error
            .downcast_ref::<RuntimeExecutionError>()
            .map(RuntimeExecutionError::to_json)
    };
    match structured {
        Some(Ok(value)) => eprintln!("{value}"),
        _ => eprintln!("lispish_file: {error}"),
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

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn published_native_shapes_become_lists_without_changing_atoms() {
        for (raw, expected) in [
            (json!([null]), json!([])),
            (json!(["a", null]), json!(["a"])),
            (json!(["a", ["b", "c"]]), json!(["a", "b", "c"])),
            (
                json!(["a", [["b", ["c"]], "d"]]),
                json!(["a", ["b", "c"], "d"]),
            ),
            (json!([[null], null]), json!([[]])),
            (json!(["123", ["a\\\"b", ""]]), json!(["123", "a\\\"b", ""])),
        ] {
            assert_eq!(
                serde_json::to_value(decode_form(raw, 0).unwrap()).unwrap(),
                expected
            );
        }
    }

    #[test]
    fn absent_or_unexpected_results_are_rejected() {
        for raw in [
            json!(null),
            json!([]),
            json!([null, null]),
            json!([1, null]),
            json!(["a", "b"]),
            json!(["a", null, null]),
        ] {
            assert!(decode_form(raw, 0).is_err());
        }
    }

    #[test]
    fn adapter_depth_limit_is_explicit() {
        let mut raw = json!([null]);
        for _ in 1..MAX_ADAPTER_DEPTH {
            raw = json!([raw, null]);
        }
        assert!(decode_form(raw.clone(), 0).is_ok());
        assert!(decode_form(json!([raw, null]), 0).is_err());
    }
}
