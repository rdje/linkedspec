//! Runtime context — variable store, accumulator, and lifecycle state.
//! Will be populated in .4.2 (lifecycle executor).

/// Runtime context for a single rule invocation.
///
/// Holds declared variables, accumulator state, and input position.
/// Currently a placeholder — will be implemented in .4.2.
pub struct RuntimeContext {
    pub input: String,
    pub pos: usize,
}

impl RuntimeContext {
    /// Create a new runtime context for the given input.
    pub fn new(input: &str) -> Self {
        Self {
            input: input.to_string(),
            pos: 0,
        }
    }

    /// Get the current position.
    pub fn pos(&self) -> usize {
        self.pos
    }

    /// Set the current position.
    pub fn set_pos(&mut self, pos: usize) {
        self.pos = pos;
    }

    /// Get the remaining input from the current position.
    pub fn remaining(&self) -> &str {
        &self.input[self.pos..]
    }
}
