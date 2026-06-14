//! Runtime engine — executes compiled handlers.
//! Will be populated in .4 (runtime implementation).

use linkedspec_core::types::HandlerIR;

/// The runtime engine executes a compiled HandlerIR node against input text.
///
/// Currently a placeholder — will be implemented in .4.
pub struct Engine;

impl Engine {
    /// Create a new engine.
    pub fn new() -> Self {
        Self
    }

    /// Execute a handler against the given input.
    ///
    /// Returns the parse result as a JSON value, or an error.
    pub fn execute(
        &self,
        handler: &HandlerIR,
        input: &str,
    ) -> Result<serde_json::Value, String> {
        let _ = (handler, input);
        Ok(serde_json::Value::Null)
    }
}

impl Default for Engine {
    fn default() -> Self {
        Self::new()
    }
}
