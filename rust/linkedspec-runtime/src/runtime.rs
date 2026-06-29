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
    /// Entry match span as **byte** offsets into `input` (`[start, end)`).
    /// Exposed to the DSL as char offsets by `entry_start_pos`/`entry_end_pos`.
    pub entry_start_byte: usize,
    pub entry_end_byte: usize,
    /// Local match span as **byte** offsets into `input` (`[start, end)`).
    /// Exposed to the DSL as char offsets by `match_start_pos`/`match_end_pos`.
    pub match_start_byte: usize,
    pub match_end_byte: usize,
    /// Marks — named positions in the input (**byte** offsets).
    pub marks: std::collections::HashMap<String, usize>,
    /// Anonymous capture-slice start position.
    pub capture_start: Option<usize>,
    /// Exit flag — set by exit_now(status).
    pub exit_status: Option<i32>,
    /// BACKTRACK cursor save stack — BACKTRACK pushes, IBACKTRACK pops and restores.
    backtrack_stack: Vec<usize>,
    /// The current rule invocation's pending return value, set by `return(...)`.
    /// `execute_rule` clears it on entry and reads it on exit, so each rule
    /// invocation reports its own return value. This is the source of the
    /// child-return (`retv`) channel: a parent stores the child's return value
    /// into the `retv` scalar after dispatch (see `set_retv`).
    return_value: Option<RuntimeValue>,
    /// Active `(rule-label, input-position)` frames on the current recursion
    /// stack — the forward-progress / consume-before-recurse termination guard
    /// (TOP-RULE-AS-NORMAL.3.1; the Rust mirror of the Perl reference's
    /// `%__ls_recursion_active` cutoff in `SpecEntry::_build_runtime_handler`).
    /// A re-entry whose `(label, pos)` key is already active means the rule was
    /// re-entered without consuming any input since its enclosing entry — a
    /// non-progressing recursive cycle that would otherwise overflow the native
    /// stack — so `Engine::execute_rule` cuts that branch (returns `undef`).
    /// Inserted on entry and removed on exit (balanced), so the set is empty
    /// between top-level parses.
    recursion_active: std::collections::HashSet<(String, usize)>,
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
            entry_start_byte: 0,
            entry_end_byte: 0,
            match_start_byte: 0,
            match_end_byte: 0,
            marks: std::collections::HashMap::new(),
            capture_start: None,
            exit_status: None,
            backtrack_stack: Vec::new(),
            return_value: None,
            recursion_active: std::collections::HashSet::new(),
        }
    }

    // ── Position ──

    pub fn pos(&self) -> usize {
        self.pos
    }
    pub fn set_pos(&mut self, pos: usize) {
        self.pos = pos;
    }
    pub fn remaining(&self) -> &str {
        &self.input[self.pos..]
    }

    // ── Scalars ──

    pub fn declare_scalar(&mut self, name: &str) {
        self.scalars.insert(name.to_string(), RuntimeValue::Undef);
    }

    pub fn declare_scalar_with(&mut self, name: &str, value: RuntimeValue) {
        self.scalars.insert(name.to_string(), value);
    }

    pub fn get_scalar(&self, name: &str) -> RuntimeValue {
        self.scalars
            .get(name)
            .cloned()
            .unwrap_or(RuntimeValue::Undef)
    }

    pub fn set_scalar(&mut self, name: &str, value: RuntimeValue) {
        self.scalars.insert(name.to_string(), value);
    }

    // ── Arrays ──

    pub fn declare_array(&mut self, name: &str) {
        self.arrays.insert(name.to_string(), Vec::new());
    }

    pub fn push_value(&mut self, arr_name: &str, value: RuntimeValue) {
        self.arrays
            .entry(arr_name.to_string())
            .or_default()
            .push(value);
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

    // ── Child return value (retv) ──

    /// Set the `retv` scalar — the most recent child rule's return value.
    ///
    /// After a parent dispatches a child via an action edge (`-> Child`) or a
    /// blind-call edge (`=> Child`), the engine stores the child's return value
    /// here so the parent's attached code and its `LE`/`E` blocks can read it as
    /// `scalar(retv)` (Runtime Semantics §3.3 / §6.1). Before this was wired in,
    /// `scalar(retv)` resolved to undef for virtually every grammar.
    pub fn set_retv(&mut self, value: RuntimeValue) {
        self.scalars.insert("retv".to_string(), value);
    }

    // ── Per-invocation return value ──

    /// Record the current rule invocation's return value (set by `return(...)`).
    /// Later calls overwrite earlier ones, so the last lifecycle block to call
    /// `return(...)` wins (Runtime Semantics §5.4).
    pub fn set_return_value(&mut self, value: RuntimeValue) {
        self.return_value = Some(value);
    }

    /// Take (and clear) the current rule invocation's pending return value.
    /// `execute_rule` calls this on entry (to start each invocation with a clean
    /// channel) and on exit (to read this rule's own return value).
    pub fn take_return_value(&mut self) -> Option<RuntimeValue> {
        self.return_value.take()
    }

    /// Restore a previously-taken pending return value, keeping the return
    /// channel scoped per rule invocation across nested child dispatch.
    pub fn restore_return_value(&mut self, saved: Option<RuntimeValue>) {
        self.return_value = saved;
    }

    // ── Forward-progress recursion guard (TOP-RULE-AS-NORMAL.3.1) ──

    /// Enter the `(label, pos)` recursion frame for the forward-progress /
    /// consume-before-recurse termination guard. Returns `true` if the frame was
    /// newly added — the caller proceeds and must later call [`exit_recursion`]
    /// with the same `(label, pos)`. Returns `false` if `label` is already active
    /// at this exact input position — a non-progressing recursive re-entry the
    /// caller must cut (return `undef`) to terminate the cycle. Mirrors the Perl
    /// reference's `%__ls_recursion_active` keyed by `"$descr\0$label\0$pos"`.
    pub fn enter_recursion(&mut self, label: &str, pos: usize) -> bool {
        self.recursion_active.insert((label.to_string(), pos))
    }

    /// Leave the `(label, pos)` recursion frame entered by [`enter_recursion`].
    /// `pos` is the position captured at entry (the rule body mutates `self.pos`,
    /// so the caller records the entry position and passes it back here).
    pub fn exit_recursion(&mut self, label: &str, pos: usize) {
        self.recursion_active.remove(&(label.to_string(), pos));
    }

    // ── BACKTRACK cursor stack ──

    /// Save current position onto the backtrack stack (BACKTRACK marker).
    pub fn push_backtrack(&mut self) {
        self.backtrack_stack.push(self.pos);
    }

    /// Restore position from the backtrack stack (IBACKTRACK marker).
    /// Returns false if the stack was empty (no saved position).
    pub fn pop_backtrack(&mut self) -> bool {
        if let Some(saved) = self.backtrack_stack.pop() {
            self.pos = saved;
            true
        } else {
            false
        }
    }

    // ── Accumulator ──

    pub fn push_accumulator(&mut self, value: RuntimeValue) {
        self.accumulator.push(value);
    }

    pub fn get_accumulator(&self) -> &[RuntimeValue] {
        &self.accumulator
    }
}
