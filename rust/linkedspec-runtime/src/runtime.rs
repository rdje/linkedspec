//! Runtime context — variable store, accumulator, and match state.
//!
//! Provides the execution environment for a single rule invocation.
//! Declared variables are scoped to the rule. Accumulators hold child results.

use linkedspec_core::types::RuntimeValue;

/// Runtime context for a single rule invocation.
#[derive(Debug, Clone)]
pub struct RuntimeContext {
    /// The full input text being parsed.
    pub input: String,
    /// Current match position in the input.
    pub pos: usize,
    /// Declared scalar variables.
    scalars: std::collections::HashMap<String, RuntimeValue>,
    /// Declared array variables (accumulators).
    arrays: std::collections::HashMap<String, Vec<RuntimeValue>>,
    /// Declared hash variables.
    hashes: std::collections::HashMap<String, Vec<(String, RuntimeValue)>>,
    /// The rule's main accumulator (return value).
    pub accumulator: Vec<RuntimeValue>,
    /// Entry match groups from the last regex match (group 0 = full match).
    pub entry_groups: Vec<String>,
    /// Named entry match groups.
    pub entry_named: std::collections::HashMap<String, String>,
    /// Local match groups (nested/child match).
    pub match_groups: Vec<String>,
    /// Named local match groups.
    pub match_named: std::collections::HashMap<String, String>,
    /// Marks — named positions in the input.
    pub marks: std::collections::HashMap<String, usize>,
    /// Anonymous capture-slice start position.
    pub capture_start: Option<usize>,
    /// Exit flag — set by exit_now(status).
    pub exit_status: Option<i32>,
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
            match_groups: Vec::new(),
            match_named: std::collections::HashMap::new(),
            marks: std::collections::HashMap::new(),
            capture_start: None,
            exit_status: None,
        }
    }

    // ── Position ──

    pub fn pos(&self) -> usize { self.pos }
    pub fn set_pos(&mut self, pos: usize) { self.pos = pos; }
    pub fn remaining(&self) -> &str { &self.input[self.pos..] }

    // ── Scalars ──

    pub fn declare_scalar(&mut self, name: &str) {
        self.scalars.insert(name.to_string(), RuntimeValue::Undef);
    }

    pub fn declare_scalar_with(&mut self, name: &str, value: RuntimeValue) {
        self.scalars.insert(name.to_string(), value);
    }

    pub fn get_scalar(&self, name: &str) -> RuntimeValue {
        self.scalars.get(name).cloned().unwrap_or(RuntimeValue::Undef)
    }

    pub fn set_scalar(&mut self, name: &str, value: RuntimeValue) {
        self.scalars.insert(name.to_string(), value);
    }

    // ── Arrays ──

    pub fn declare_array(&mut self, name: &str) {
        self.arrays.insert(name.to_string(), Vec::new());
    }

    pub fn push_value(&mut self, arr_name: &str, value: RuntimeValue) {
        self.arrays.entry(arr_name.to_string()).or_default().push(value);
    }

    pub fn get_array(&self, name: &str) -> Vec<RuntimeValue> {
        self.arrays.get(name).cloned().unwrap_or_default()
    }

    pub fn array_copy(&self, name: &str) -> Vec<RuntimeValue> {
        self.get_array(name)
    }

    // ── Hashes ──

    pub fn declare_hash(&mut self, name: &str) {
        self.hashes.insert(name.to_string(), Vec::new());
    }

    pub fn get_hash(&self, name: &str) -> Vec<(String, RuntimeValue)> {
        self.hashes.get(name).cloned().unwrap_or_default()
    }

    pub fn set_hash_entry(&mut self, hash_name: &str, key: &str, value: RuntimeValue) {
        let entries = self.hashes.entry(hash_name.to_string()).or_default();
        if let Some(existing) = entries.iter_mut().find(|(k, _)| k == key) {
            existing.1 = value;
        } else {
            entries.push((key.to_string(), value));
        }
    }

    pub fn hash_copy(&self, name: &str) -> Vec<(String, RuntimeValue)> {
        self.get_hash(name)
    }

    // ── Accumulator ──

    pub fn push_accumulator(&mut self, value: RuntimeValue) {
        self.accumulator.push(value);
    }

    pub fn get_accumulator(&self) -> &[RuntimeValue] {
        &self.accumulator
    }
}
