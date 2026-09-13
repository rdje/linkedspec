use linkedspec_runtime::engine::ExecutionOptions;
use linkedspec_runtime::spec_loader::{SpecLoadOptions, SpecRequest, load_and_compile_spec};
use std::error::Error;
use std::io;
use std::process::ExitCode;

fn run() -> Result<(), Box<dyn Error>> {
    let mut arguments = std::env::args_os().skip(1);
    let grammar = arguments.next().ok_or_else(|| {
        io::Error::new(
            io::ErrorKind::InvalidInput,
            "usage: consumer GRAMMAR INPUT [INPUT ...]",
        )
    })?;
    let grammar = grammar
        .into_string()
        .map_err(|_| io::Error::new(io::ErrorKind::InvalidInput, "grammar path must be UTF-8"))?;
    let inputs: Vec<String> = arguments
        .map(|argument| {
            argument
                .into_string()
                .map_err(|_| io::Error::new(io::ErrorKind::InvalidInput, "input must be UTF-8"))
        })
        .collect::<Result<_, _>>()?;
    if inputs.is_empty() {
        return Err(
            io::Error::new(io::ErrorKind::InvalidInput, "provide at least one input").into(),
        );
    }

    // Resolve the caller's path explicitly, then compile once for this batch.
    let loaded = load_and_compile_spec(
        &SpecRequest::path(grammar),
        &SpecLoadOptions::new(std::env::current_dir()?),
    )?;
    let engine = loaded.into_engine();
    let options = ExecutionOptions::new();
    for input in inputs {
        let value = engine.execute_value_with_diagnostics(&input, &options)?;
        println!("{value}");
    }
    Ok(())
}

fn main() -> ExitCode {
    match run() {
        Ok(()) => ExitCode::SUCCESS,
        Err(error) => {
            eprintln!("consumer: {error}");
            ExitCode::FAILURE
        }
    }
}
