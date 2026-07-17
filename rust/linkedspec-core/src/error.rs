//! Error types for LinkedSpec core operations.

use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;
use thiserror::Error;

/// A portable validation/normalization diagnostic with stable identity and
/// contract-declared fields.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct PortableDiagnostic {
    /// Stable machine-readable diagnostic identity.
    pub code: String,
    /// Stable pipeline stage that rejected the input.
    pub stage: String,
    /// Human-readable failure detail.
    pub message: String,
    /// Contract-declared machine-readable context, sorted by field name.
    pub fields: BTreeMap<String, serde_json::Value>,
}

impl PortableDiagnostic {
    /// Create a diagnostic with no context fields.
    pub fn new(code: &str, stage: &str, message: impl Into<String>) -> Self {
        Self {
            code: code.to_string(),
            stage: stage.to_string(),
            message: message.into(),
            fields: BTreeMap::new(),
        }
    }

    /// Add or replace one machine-readable context field.
    pub fn with_field(mut self, name: &str, value: impl Into<serde_json::Value>) -> Self {
        self.fields.insert(name.to_string(), value.into());
        self
    }

    /// Return one machine-readable context field by name.
    pub fn field(&self, name: &str) -> Option<&serde_json::Value> {
        self.fields.get(name)
    }
}

impl std::fmt::Display for PortableDiagnostic {
    fn fmt(&self, formatter: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            formatter,
            "{} at {}: {}",
            self.code, self.stage, self.message
        )?;
        for (name, value) in &self.fields {
            write!(formatter, "; {name}={value}")?;
        }
        Ok(())
    }
}

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

    /// Portable validation or normalization failure.
    #[error("validation error: {0}")]
    Diagnostic(PortableDiagnostic),

    /// Compilation error — internal compiler failure.
    #[error("compilation error: {0}")]
    Compile(String),

    /// Runtime execution error.
    #[error("runtime error: {0}")]
    Runtime(String),

    /// Trace configuration or sink error.
    #[error("trace error: {0}")]
    Trace(#[from] crate::trace::TraceError),

    /// JSON serialization error.
    #[error("JSON error: {0}")]
    Json(#[from] serde_json::Error),
}

impl LinkedSpecError {
    /// Return the portable diagnostic payload when this error has one.
    pub fn diagnostic(&self) -> Option<&PortableDiagnostic> {
        match self {
            Self::Diagnostic(diagnostic) => Some(diagnostic),
            _ => None,
        }
    }
}

/// Result type alias for LinkedSpec operations.
pub type Result<T> = std::result::Result<T, LinkedSpecError>;
