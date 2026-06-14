//! Error types for LinkedSpec core operations.

use thiserror::Error;

/// Top-level error type for parsing, compilation, and validation.
#[derive(Error, Debug)]
pub enum LinkedSpecError {
    /// I/O error reading a .spec file.
    #[error("failed to read spec file: {0}")]
    Io(#[from] std::io::Error),

    /// Parser error — malformed .spec syntax.
    #[error("parse error at line {line}: {message}")]
    Parse { line: usize, message: String },

    /// Validation error — valid syntax but violates rules.
    #[error("validation error: {0}")]
    Validation(String),

    /// Compilation error — internal compiler failure.
    #[error("compilation error: {0}")]
    Compile(String),

    /// Runtime execution error.
    #[error("runtime error: {0}")]
    Runtime(String),

    /// JSON serialization error.
    #[error("JSON error: {0}")]
    Json(#[from] serde_json::Error),
}

/// Result type alias for LinkedSpec operations.
pub type Result<T> = std::result::Result<T, LinkedSpecError>;
