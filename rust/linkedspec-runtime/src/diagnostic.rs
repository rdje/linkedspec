//! Structured runtime diagnostics for native Rust embedding.

use serde::{Deserialize, Serialize};
use thiserror::Error;

/// Backend-neutral context attached to a native runtime failure.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct RuntimeDiagnostic {
    /// Neutral diagnostic `type` field (`runtime_parser` for engine failures).
    #[serde(rename = "type")]
    pub diagnostic_type: String,
    /// Stable failure stage within the runtime owner.
    pub stage: String,
    /// Stable portable failure code when the runtime contract defines one.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub code: Option<String>,
    /// Host-backend owner identity (`rust_runtime` when present).
    #[serde(skip_serializing_if = "Option::is_none")]
    pub owner_stage: Option<String>,
    /// Stable human-readable failure category.
    pub summary: String,
    /// Original runtime error message.
    pub detail: String,
    /// Optional logical spec name supplied by the embedding caller.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub spec_name: Option<String>,
    /// Optional resolved spec path supplied by the embedding caller.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub spec_path: Option<String>,
    /// Selected top or explicit entry rule, when available.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub top_rule: Option<String>,
    /// Explicit selector that failed before rule entry, when applicable.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub entry_rule: Option<String>,
    /// Deepest rule that observed the failure, when available.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub rule_label: Option<String>,
    /// Governed helper that rejected its authored arity, when applicable.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub helper_name: Option<String>,
    /// Authored helper arity, when applicable.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub actual_arity: Option<usize>,
    /// Portable expected-arity spelling, when applicable.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub expected_arity: Option<String>,
    /// Structural target rule for regex slot identity diagnostics.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub target_rule: Option<String>,
    /// Structural regex slot for compiled identity diagnostics.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub regex_index: Option<usize>,
    /// Required structural slot for ordered identity diagnostics.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub expected_regex_index: Option<usize>,
    /// Matcher-reported slot for ordered identity diagnostics.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub actual_regex_index: Option<usize>,
    /// Dynamic codeblock-variable identity, when applicable.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub callable_name: Option<String>,
    /// Neutral expected-value spelling for callable failures.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub expected: Option<String>,
    /// Neutral observed count for callable failures.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub got: Option<usize>,
    /// Neutral runtime value kind for a non-callable binding.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub value_kind: Option<String>,
    /// Unknown callable/helper name, when applicable.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub name: Option<String>,
    /// Ordered active callable cycle, including the closing identity.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub cycle: Option<Vec<String>>,
    /// Stable Rust runtime handler identity.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub handler_source_label: Option<String>,
}

impl RuntimeDiagnostic {
    /// Convert this diagnostic to its backend-neutral JSON object.
    pub fn to_json(&self) -> serde_json::Result<serde_json::Value> {
        serde_json::to_value(self)
    }
}

/// Native runtime error with its unchanged textual message and structured context.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, Error)]
#[error("{message}")]
pub struct RuntimeExecutionError {
    /// Original compatibility error message.
    pub message: String,
    /// Structured backend-neutral context for the same failure.
    pub diagnostic: Box<RuntimeDiagnostic>,
}

impl RuntimeExecutionError {
    pub(crate) fn new(message: String, diagnostic: RuntimeDiagnostic) -> Self {
        Self {
            message,
            diagnostic: Box::new(diagnostic),
        }
    }

    /// Return the compatibility error message.
    pub fn message(&self) -> &str {
        &self.message
    }

    /// Return the backend-neutral diagnostic record.
    pub fn diagnostic(&self) -> &RuntimeDiagnostic {
        self.diagnostic.as_ref()
    }

    /// Consume the structured error and recover the compatibility message.
    pub fn into_message(self) -> String {
        self.message
    }

    /// Convert the error and nested diagnostic to JSON.
    pub fn to_json(&self) -> serde_json::Result<serde_json::Value> {
        serde_json::to_value(self)
    }
}
