//! Runtime context — variable store, accumulator, and lifecycle state.
//!
//! Provides the execution environment for a single rule invocation.
//! Declared variables are scoped to the rule. Accumulators hold child results.

use serde_json::Value;

/// A runtime value — scalar, array, or hash.
#[derive(Debug, Clone)]
pub enum RuntimeValue {
    /// Undefined / missing.
    Undef,
    /// A scalar string value.
    Scalar(String),
    /// An array of values.
    Array(Vec<RuntimeValue>),
    /// A hash / object of key-value pairs.
    Hash(Vec<(String, RuntimeValue)>),
}

impl RuntimeValue {
    /// Convert a RuntimeValue to a serde_json::Value for output.
    pub fn to_json(&self) -> Value {
        match self {
            Self::Undef => Value::Null,
            Self::Scalar(s) => Value::String(s.clone()),
            Self::Array(arr) => Value::Array(arr.iter().map(|v| v.to_json()).collect()),
            Self::Hash(entries) => {
                let mut map = serde_json::Map::new();
                for (k, v) in entries {
                    map.insert(k.clone(), v.to_json());
                }
                Value::Object(map)
            }
        }
    }
}

/// Runtime context for a single rule invocation.
pub struct RuntimeContext {
    /// The full input text.
    pub input: String,
    /// Current match position.
    pub pos: usize,
    /// Declared scalar variables.
    scalars: std::collections::HashMap<String, String>,
    /// Declared array variables.
    arrays: std::collections::HashMap<String, Vec<RuntimeValue>>,
    /// Declared hash variables.
    hashes: std::collections::HashMap<String, Vec<(String, RuntimeValue)>>,
    /// The rule's accumulator (return value).
    pub accumulator: Vec<RuntimeValue>,
    /// Entry match groups from the last regex match.
    pub entry_groups: Vec<String>,
    /// Named entry match groups.
    pub entry_named: std::collections::HashMap<String, String>,
}

impl RuntimeContext {
    /// Create a new runtime context for the given input.
    pub fn new(input: &str) -> Self {
        Self {
            input: input.to_string(),
            pos: 0,
            scalars: std::collections::HashMap::new(),
            arrays: std::collections::HashMap::new(),
            hashes: std::collections::HashMap::new(),
            accumulator: Vec::new(),
            entry_groups: Vec::new(),
            entry_named: std::collections::HashMap::new(),
        }
    }

    /// Get the current match position.
    pub fn pos(&self) -> usize {
        self.pos
    }

    /// Set the current match position.
    pub fn set_pos(&mut self, pos: usize) {
        self.pos = pos;
    }

    /// Get the remaining input from the current position.
    pub fn remaining(&self) -> &str {
        &self.input[self.pos..]
    }

    // ── Variable store ──

    /// Declare a scalar variable.
    pub fn declare_scalar(&mut self, name: &str) {
        self.scalars.insert(name.to_string(), String::new());
    }

    /// Declare a scalar with an initial value.
    pub fn declare_scalar_with(&mut self, name: &str, value: &str) {
        self.scalars.insert(name.to_string(), value.to_string());
    }

    /// Declare an array variable.
    pub fn declare_array(&mut self, name: &str) {
        self.arrays.insert(name.to_string(), Vec::new());
    }

    /// Declare a hash variable.
    pub fn declare_hash(&mut self, name: &str) {
        self.hashes.insert(name.to_string(), Vec::new());
    }

    /// Get a scalar value (returns empty string for undeclared).
    pub fn get_scalar(&self, name: &str) -> &str {
        self.scalars.get(name).map(|s| s.as_str()).unwrap_or("")
    }

    /// Set a scalar value.
    pub fn set_scalar(&mut self, name: &str, value: &str) {
        self.scalars.insert(name.to_string(), value.to_string());
    }

    /// Push a value onto an accumulator array.
    pub fn push_value(&mut self, arr_name: &str, value: RuntimeValue) {
        self.arrays
            .entry(arr_name.to_string())
            .or_default()
            .push(value);
    }

    /// Get an array by name (empty if undeclared).
    pub fn get_array(&self, name: &str) -> &[RuntimeValue] {
        self.arrays
            .get(name)
            .map(|a| a.as_slice())
            .unwrap_or(&[])
    }

    /// Copy an array (shallow clone).
    pub fn array_copy(&self, name: &str) -> Vec<RuntimeValue> {
        self.get_array(name).to_vec()
    }

    /// Push a value onto the main accumulator.
    pub fn push_accumulator(&mut self, value: RuntimeValue) {
        self.accumulator.push(value);
    }

    /// Get the main accumulator contents.
    pub fn get_accumulator(&self) -> &[RuntimeValue] {
        &self.accumulator
    }
}
