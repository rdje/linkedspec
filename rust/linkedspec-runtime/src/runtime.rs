//! Runtime context — variable store, accumulator, and match state.
//!
//! Provides the execution environment for a single rule invocation.
//! Declared variables are scoped to the rule. Accumulators hold child results.

use linkedspec_core::trace::{TraceEmitter, TraceEventKind, TraceLevel, TraceResult, TraceScope};
use linkedspec_core::types::{ParseMode, RuntimeValue};

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
pub enum RuntimeVarKind {
    Scalar,
    Array,
    Hash,
}

/// Runtime context for a single rule invocation.
#[derive(Debug, Clone)]
pub struct RuntimeContext {
    /// The full input text being parsed.
    pub input: String,
    /// Current match position in the input.
    pub pos: usize,
    /// Optional per-execution override for every rule's compiled parse mode.
    parse_mode_override: Option<ParseMode>,
    /// Declared scalar variables.
    scalars: std::collections::HashMap<String, RuntimeValue>,
    /// Declared array variables (accumulators).
    arrays: std::collections::HashMap<String, Vec<RuntimeValue>>,
    /// Declared hash variables.
    hashes: std::collections::HashMap<String, Vec<(String, RuntimeValue)>>,
    /// Remembered bare identifier kind after declaration or assignment.
    bare_kinds: std::collections::HashMap<String, RuntimeVarKind>,
    /// Descriptor-tag scalars that must stay bare-readable even when a same-name
    /// aggregate accumulator is mutated through a type-implying helper.
    descriptor_scalar_bare_reads: std::collections::HashSet<String>,
    /// The rule's main accumulator (return value).
    pub accumulator: Vec<RuntimeValue>,
    /// Entry capture groups (group 0 = first participating capture).
    pub entry_groups: Vec<String>,
    /// Named entry match groups.
    pub entry_named: std::collections::HashMap<String, String>,
    /// Whether an entry match exists, distinct from a present zero-width match.
    pub entry_match_present: bool,
    /// Local capture groups (group 0 = first participating capture).
    pub match_groups: Vec<String>,
    /// Named local match groups.
    pub match_named: std::collections::HashMap<String, String>,
    /// Whether a local match exists, distinct from a present zero-width match.
    pub match_present: bool,
    /// Entry match span as **byte** offsets into `input` (`[start, end)`).
    /// Exposed to the DSL as char offsets by `entry_start_pos`/`entry_end_pos`.
    pub entry_start_byte: usize,
    pub entry_end_byte: usize,
    /// Local match span as **byte** offsets into `input` (`[start, end)`).
    /// Exposed to the DSL as char offsets by `match_start_pos`/`match_end_pos`.
    pub match_start_byte: usize,
    pub match_end_byte: usize,
    /// Marks — rule label → named position (**byte** offset) in the input.
    ///
    /// Perl stores marks in `$info->{marks}{$rule_label}{$mark_name}`. Keeping
    /// the rule bucket explicit prevents a child rule from observing or
    /// replacing an identically named parent checkpoint.
    pub marks: std::collections::HashMap<String, std::collections::HashMap<String, usize>>,
    /// Anonymous capture-slice start position.
    pub capture_start: Option<usize>,
    /// Exit flag — set by exit_now(status).
    pub exit_status: Option<i32>,
    /// Explicit cursor save stack used by save_cursor()/restore_cursor().
    cursor_stack: Vec<usize>,
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
    /// Active user-function call stack. User functions are pure MVP value
    /// helpers; recursion is unsupported and must diagnose instead of recursing.
    user_functions_active: Vec<String>,
    /// Scoped child return overrides for action-edge blocks. Perl lowers
    /// `call(child)` inside `-> child { ... }` to the already-dispatched edge
    /// match; this stack lets Rust expose that same value without re-searching.
    action_edge_call_results: Vec<(String, RuntimeValue)>,
    /// Rule-local variable frames. Explicit local initializers shadow any
    /// existing binding for the duration of the current rule invocation, while
    /// ordinary assignment/mutation keeps the existing shared Rust working-variable
    /// behavior.
    declaration_scopes: Vec<RuntimeDeclarationScope>,
    /// User functions already replace the whole variable store with their own
    /// local store, so their declarations must not be recorded in an enclosing
    /// rule frame.
    declaration_scope_suppression_depth: usize,
    /// Runtime trace events captured during execution and replayed through the
    /// caller-owned trace sink after the parse result is known.
    trace_events_enabled: bool,
    trace_events: Vec<RuntimeTraceEvent>,
    /// Selected top/entry rule for diagnostic attribution.
    diagnostic_top_rule: Option<String>,
    /// Deepest failure context captured before its rule frame unwinds.
    diagnostic_failure: Option<RuntimeFailureContext>,
}

type RuntimeDeclarationScope = std::collections::HashMap<String, RuntimeVariableSnapshot>;

#[derive(Debug, Clone)]
struct RuntimeVariableSnapshot {
    scalar: Option<RuntimeValue>,
    array: Option<Vec<RuntimeValue>>,
    hash: Option<Vec<(String, RuntimeValue)>>,
    bare_kind: Option<RuntimeVarKind>,
    descriptor_scalar_bare_read: bool,
}

#[derive(Debug, Clone)]
struct RuntimeTraceEvent {
    kind: TraceEventKind,
    topic: String,
    details: String,
    level: TraceLevel,
}

#[derive(Debug, Clone)]
pub(crate) struct RuntimeFailureContext {
    pub(crate) stage: &'static str,
    pub(crate) summary: &'static str,
    pub(crate) rule_label: Option<String>,
}

#[derive(Debug, Clone)]
pub(crate) struct RuntimeScopedVariableBinding {
    name: String,
    snapshot: RuntimeVariableSnapshot,
}

/// Saved scalar/array/hash variable stores.
///
/// User-defined functions run with fresh local stores, then the caller's stores
/// are restored after the function returns. Parser state, marks, input cursor,
/// accumulator, and the rule return channel intentionally stay outside this
/// snapshot.
#[derive(Debug, Clone)]
pub(crate) struct RuntimeVariableStores {
    scalars: std::collections::HashMap<String, RuntimeValue>,
    arrays: std::collections::HashMap<String, Vec<RuntimeValue>>,
    hashes: std::collections::HashMap<String, Vec<(String, RuntimeValue)>>,
    bare_kinds: std::collections::HashMap<String, RuntimeVarKind>,
    descriptor_scalar_bare_reads: std::collections::HashSet<String>,
}

impl RuntimeContext {
    /// Create a new runtime context for the given input.
    pub fn new(input: &str) -> Self {
        Self {
            input: input.to_string(),
            pos: 0,
            parse_mode_override: None,
            scalars: std::collections::HashMap::new(),
            arrays: std::collections::HashMap::new(),
            hashes: std::collections::HashMap::new(),
            bare_kinds: std::collections::HashMap::new(),
            descriptor_scalar_bare_reads: std::collections::HashSet::new(),
            accumulator: Vec::new(),
            entry_groups: Vec::new(),
            entry_named: std::collections::HashMap::new(),
            entry_match_present: false,
            match_groups: Vec::new(),
            match_named: std::collections::HashMap::new(),
            match_present: false,
            entry_start_byte: 0,
            entry_end_byte: 0,
            match_start_byte: 0,
            match_end_byte: 0,
            marks: std::collections::HashMap::new(),
            capture_start: None,
            exit_status: None,
            cursor_stack: Vec::new(),
            return_value: None,
            recursion_active: std::collections::HashSet::new(),
            user_functions_active: Vec::new(),
            action_edge_call_results: Vec::new(),
            declaration_scopes: Vec::new(),
            declaration_scope_suppression_depth: 0,
            trace_events_enabled: false,
            trace_events: Vec::new(),
            diagnostic_top_rule: None,
            diagnostic_failure: None,
        }
    }

    /// Create a runtime context with an optional global parse-mode override.
    pub fn with_parse_mode(input: &str, parse_mode: Option<ParseMode>) -> Self {
        let mut context = Self::new(input);
        context.parse_mode_override = parse_mode;
        context
    }

    /// Return the per-execution override or the rule's compiled fallback mode.
    pub fn effective_parse_mode(&self, fallback: ParseMode) -> ParseMode {
        self.parse_mode_override.unwrap_or(fallback)
    }

    pub(crate) fn mark_get(&self, rule_label: &str, name: &str) -> Option<usize> {
        self.marks
            .get(rule_label)
            .and_then(|bucket| bucket.get(name))
            .copied()
    }

    pub(crate) fn mark_set(&mut self, rule_label: &str, name: String, position: usize) {
        self.marks
            .entry(rule_label.to_string())
            .or_default()
            .insert(name, position);
    }

    pub(crate) fn mark_remove(&mut self, rule_label: &str, name: &str) {
        if let Some(bucket) = self.marks.get_mut(rule_label) {
            bucket.remove(name);
        }
    }

    pub(crate) fn mark_exists(&self, rule_label: &str, name: &str) -> bool {
        self.marks
            .get(rule_label)
            .is_some_and(|bucket| bucket.contains_key(name))
    }

    pub(crate) fn set_diagnostic_top_rule(&mut self, label: impl Into<String>) {
        self.diagnostic_top_rule = Some(label.into());
    }

    pub(crate) fn diagnostic_top_rule(&self) -> Option<&str> {
        self.diagnostic_top_rule.as_deref()
    }

    pub(crate) fn capture_diagnostic_failure(
        &mut self,
        stage: &'static str,
        summary: &'static str,
        rule_label: Option<&str>,
    ) {
        if self.diagnostic_failure.is_none() {
            self.diagnostic_failure = Some(RuntimeFailureContext {
                stage,
                summary,
                rule_label: rule_label.map(str::to_string),
            });
        }
    }

    pub(crate) fn diagnostic_failure(&self) -> Option<&RuntimeFailureContext> {
        self.diagnostic_failure.as_ref()
    }

    // ── Runtime trace recording ──

    pub(crate) fn enable_trace_events(&mut self) {
        self.trace_events_enabled = true;
    }

    pub(crate) fn trace_enter(
        &mut self,
        topic: impl Into<String>,
        details: impl Into<String>,
        level: TraceLevel,
    ) {
        if !self.trace_events_enabled {
            return;
        }
        self.record_trace_event(TraceEventKind::Enter, topic, details, level);
    }

    pub(crate) fn trace_exit(
        &mut self,
        topic: impl Into<String>,
        details: impl Into<String>,
        level: TraceLevel,
    ) {
        if !self.trace_events_enabled {
            return;
        }
        self.record_trace_event(TraceEventKind::Exit, topic, details, level);
    }

    pub(crate) fn trace_decision(
        &mut self,
        decision_name: impl Into<String>,
        taken: bool,
        reason: impl Into<String>,
        level: TraceLevel,
    ) -> bool {
        if !self.trace_events_enabled {
            return taken;
        }
        let details = format!(
            "taken={} reason={}",
            if taken { 1 } else { 0 },
            reason.into()
        );
        self.record_trace_event(TraceEventKind::Decision, decision_name, details, level);
        taken
    }

    pub(crate) fn trace_mark(
        &mut self,
        topic: impl Into<String>,
        details: impl Into<String>,
        level: TraceLevel,
    ) {
        if !self.trace_events_enabled {
            return;
        }
        self.record_trace_event(TraceEventKind::Mark, topic, details, level);
    }

    pub(crate) fn replay_trace_events(&mut self, trace: &mut TraceEmitter) -> TraceResult<()> {
        let mut scopes: Vec<TraceScope> = Vec::new();
        for event in self.trace_events.drain(..) {
            match event.kind {
                TraceEventKind::Enter => {
                    scopes.push(trace.enter_scope(event.topic, event.details, event.level)?);
                }
                TraceEventKind::Exit => {
                    if let Some(scope) = scopes.pop() {
                        trace.exit_scope(scope, event.details)?;
                    } else {
                        trace.emit_event(
                            TraceEventKind::Exit,
                            event.topic,
                            event.details,
                            event.level,
                        )?;
                    }
                }
                kind => {
                    trace.emit_event(kind, event.topic, event.details, event.level)?;
                }
            }
        }
        Ok(())
    }

    fn record_trace_event(
        &mut self,
        kind: TraceEventKind,
        topic: impl Into<String>,
        details: impl Into<String>,
        level: TraceLevel,
    ) {
        if !self.trace_events_enabled {
            return;
        }
        self.trace_events.push(RuntimeTraceEvent {
            kind,
            topic: topic.into(),
            details: details.into(),
            level,
        });
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
        self.record_declaration(name);
        self.bare_kinds
            .insert(name.to_string(), RuntimeVarKind::Scalar);
        self.scalars.insert(name.to_string(), RuntimeValue::Undef);
    }

    pub fn declare_scalar_with(&mut self, name: &str, value: RuntimeValue) {
        self.record_declaration(name);
        self.bare_kinds
            .insert(name.to_string(), RuntimeVarKind::Scalar);
        self.scalars.insert(name.to_string(), value);
    }

    pub fn get_scalar(&self, name: &str) -> RuntimeValue {
        self.scalars
            .get(name)
            .cloned()
            .unwrap_or(RuntimeValue::Undef)
    }

    pub fn set_scalar(&mut self, name: &str, value: RuntimeValue) {
        self.bare_kinds
            .insert(name.to_string(), RuntimeVarKind::Scalar);
        self.scalars.insert(name.to_string(), value);
    }

    pub(crate) fn enter_scoped_scalar_binding(
        &mut self,
        name: &str,
        value: RuntimeValue,
    ) -> RuntimeScopedVariableBinding {
        let snapshot = self.snapshot_variable(name);
        self.bare_kinds
            .insert(name.to_string(), RuntimeVarKind::Scalar);
        self.scalars.insert(name.to_string(), value);
        self.arrays.remove(name);
        self.hashes.remove(name);
        self.descriptor_scalar_bare_reads.remove(name);
        RuntimeScopedVariableBinding {
            name: name.to_string(),
            snapshot,
        }
    }

    pub(crate) fn exit_scoped_variable_binding(&mut self, binding: RuntimeScopedVariableBinding) {
        self.restore_variable_snapshot(&binding.name, binding.snapshot);
    }

    pub fn get_bare_value(&self, name: &str) -> RuntimeValue {
        if self.descriptor_scalar_bare_reads.contains(name) {
            return self.get_scalar(name);
        }
        match self.bare_kinds.get(name).copied() {
            Some(RuntimeVarKind::Array) => RuntimeValue::Array(self.get_array(name)),
            Some(RuntimeVarKind::Hash) => RuntimeValue::Hash(self.get_hash(name)),
            Some(RuntimeVarKind::Scalar) | None => self.get_scalar(name),
        }
    }

    pub fn bare_kind(&self, name: &str) -> Option<RuntimeVarKind> {
        self.bare_kinds.get(name).copied()
    }

    fn binding_value_kind(value: &RuntimeValue) -> &'static str {
        match value {
            RuntimeValue::Array(_) => "array",
            RuntimeValue::Hash(_) => "harray",
            RuntimeValue::Undef
            | RuntimeValue::Scalar(_)
            | RuntimeValue::Number(_)
            | RuntimeValue::Bool(_) => "scalar",
        }
    }

    fn binding_kind_mismatch(name: &str, expected_kind: &str, actual: &RuntimeValue) -> String {
        format!(
            "binding_kind_mismatch identifier={name} expected_kind={expected_kind} actual_kind={}",
            Self::binding_value_kind(actual)
        )
    }

    fn bare_array_for_mutation(
        &self,
        name: &str,
    ) -> Result<(Option<RuntimeVarKind>, Vec<RuntimeValue>), String> {
        let kind = self.bare_kind(name);
        let value = self.get_bare_value(name);
        match (kind, value) {
            (None, RuntimeValue::Undef) => Ok((None, Vec::new())),
            (Some(RuntimeVarKind::Array), RuntimeValue::Array(values)) => Ok((kind, values)),
            (Some(RuntimeVarKind::Scalar), RuntimeValue::Array(values)) => Ok((kind, values)),
            (_, actual) => Err(Self::binding_kind_mismatch(name, "array", &actual)),
        }
    }

    fn store_bare_array(
        &mut self,
        name: &str,
        prior_kind: Option<RuntimeVarKind>,
        values: Vec<RuntimeValue>,
    ) -> RuntimeValue {
        let updated = RuntimeValue::Array(values.clone());
        if matches!(prior_kind, Some(RuntimeVarKind::Array)) {
            self.set_array(name, values);
        } else {
            self.set_scalar(name, updated.clone());
        }
        updated
    }

    pub(crate) fn replace_bare_array(
        &mut self,
        name: &str,
        values: Vec<RuntimeValue>,
    ) -> Result<RuntimeValue, String> {
        let (prior_kind, _) = self.bare_array_for_mutation(name)?;
        Ok(self.store_bare_array(name, prior_kind, values))
    }

    pub(crate) fn push_bare_array_value(
        &mut self,
        name: &str,
        value: RuntimeValue,
    ) -> Result<RuntimeValue, String> {
        let (prior_kind, mut values) = self.bare_array_for_mutation(name)?;
        values.push(value);
        Ok(self.store_bare_array(name, prior_kind, values))
    }

    pub(crate) fn push_front_bare_array_value(
        &mut self,
        name: &str,
        value: RuntimeValue,
    ) -> Result<RuntimeValue, String> {
        let (prior_kind, mut values) = self.bare_array_for_mutation(name)?;
        values.insert(0, value);
        Ok(self.store_bare_array(name, prior_kind, values))
    }

    pub(crate) fn pop_back_bare_array_value(&mut self, name: &str) -> Result<RuntimeValue, String> {
        let (prior_kind, mut values) = self.bare_array_for_mutation(name)?;
        let _ = values.pop();
        Ok(self.store_bare_array(name, prior_kind, values))
    }

    pub(crate) fn pop_front_bare_array_value(
        &mut self,
        name: &str,
    ) -> Result<RuntimeValue, String> {
        let (prior_kind, mut values) = self.bare_array_for_mutation(name)?;
        if !values.is_empty() {
            values.remove(0);
        }
        Ok(self.store_bare_array(name, prior_kind, values))
    }

    pub(crate) fn set_bare_hash_entry(
        &mut self,
        name: &str,
        key: String,
        value: RuntimeValue,
    ) -> Result<RuntimeValue, String> {
        let kind = self.bare_kind(name);
        let current = self.get_bare_value(name);
        let mut entries = match (kind, current) {
            (None, RuntimeValue::Undef) => Vec::new(),
            (Some(RuntimeVarKind::Hash), RuntimeValue::Hash(values))
            | (Some(RuntimeVarKind::Scalar), RuntimeValue::Hash(values)) => values,
            (_, actual) => {
                return Err(Self::binding_kind_mismatch(name, "harray", &actual));
            }
        };
        if let Some((_, existing)) = entries.iter_mut().find(|(candidate, _)| candidate == &key) {
            *existing = value;
        } else {
            entries.push((key, value));
        }
        let updated = RuntimeValue::Hash(entries.clone());
        if matches!(kind, Some(RuntimeVarKind::Hash)) {
            self.set_hash(name, entries);
        } else {
            self.set_scalar(name, updated.clone());
        }
        Ok(updated)
    }

    pub(crate) fn descriptor_scalar_bare_read(&self, name: &str) -> bool {
        self.descriptor_scalar_bare_reads.contains(name)
    }

    // ── Arrays ──

    pub fn declare_array(&mut self, name: &str) {
        self.record_declaration(name);
        self.bare_kinds
            .insert(name.to_string(), RuntimeVarKind::Array);
        self.arrays.insert(name.to_string(), Vec::new());
    }

    pub fn set_array(&mut self, name: &str, values: Vec<RuntimeValue>) {
        self.bare_kinds
            .insert(name.to_string(), RuntimeVarKind::Array);
        self.arrays.insert(name.to_string(), values);
    }

    pub fn push_array_value(&mut self, arr_name: &str, value: RuntimeValue) {
        self.bare_kinds
            .insert(arr_name.to_string(), RuntimeVarKind::Array);
        self.arrays
            .entry(arr_name.to_string())
            .or_default()
            .push(value);
    }

    pub fn push_front_value(&mut self, arr_name: &str, value: RuntimeValue) {
        self.bare_kinds
            .insert(arr_name.to_string(), RuntimeVarKind::Array);
        self.arrays
            .entry(arr_name.to_string())
            .or_default()
            .insert(0, value);
    }

    pub fn pop_back_value(&mut self, arr_name: &str) -> RuntimeValue {
        self.bare_kinds
            .insert(arr_name.to_string(), RuntimeVarKind::Array);
        self.arrays
            .entry(arr_name.to_string())
            .or_default()
            .pop()
            .unwrap_or(RuntimeValue::Undef)
    }

    pub fn pop_front_value(&mut self, arr_name: &str) -> RuntimeValue {
        self.bare_kinds
            .insert(arr_name.to_string(), RuntimeVarKind::Array);
        let values = self.arrays.entry(arr_name.to_string()).or_default();
        if values.is_empty() {
            RuntimeValue::Undef
        } else {
            values.remove(0)
        }
    }

    pub fn get_array(&self, name: &str) -> Vec<RuntimeValue> {
        self.arrays.get(name).cloned().unwrap_or_default()
    }

    pub fn array_snapshot(&self, name: &str) -> Vec<RuntimeValue> {
        self.get_array(name)
    }

    // ── Hashes ──

    pub fn declare_hash(&mut self, name: &str) {
        self.record_declaration(name);
        self.bare_kinds
            .insert(name.to_string(), RuntimeVarKind::Hash);
        self.hashes.insert(name.to_string(), Vec::new());
    }

    pub fn set_hash(&mut self, name: &str, values: Vec<(String, RuntimeValue)>) {
        self.bare_kinds
            .insert(name.to_string(), RuntimeVarKind::Hash);
        self.hashes.insert(name.to_string(), values);
    }

    pub fn get_hash(&self, name: &str) -> Vec<(String, RuntimeValue)> {
        self.hashes.get(name).cloned().unwrap_or_default()
    }

    pub fn set_hash_entry(&mut self, hash_name: &str, key: &str, value: RuntimeValue) {
        self.bare_kinds
            .insert(hash_name.to_string(), RuntimeVarKind::Hash);
        let entries = self.hashes.entry(hash_name.to_string()).or_default();
        if let Some(existing) = entries.iter_mut().find(|(k, _)| k == key) {
            existing.1 = value;
        } else {
            entries.push((key.to_string(), value));
        }
    }

    pub fn hash_snapshot(&self, name: &str) -> Vec<(String, RuntimeValue)> {
        self.get_hash(name)
    }

    // ── User-function local variables ──

    pub(crate) fn take_variable_stores(&mut self) -> RuntimeVariableStores {
        RuntimeVariableStores {
            scalars: std::mem::take(&mut self.scalars),
            arrays: std::mem::take(&mut self.arrays),
            hashes: std::mem::take(&mut self.hashes),
            bare_kinds: std::mem::take(&mut self.bare_kinds),
            descriptor_scalar_bare_reads: std::mem::take(&mut self.descriptor_scalar_bare_reads),
        }
    }

    pub(crate) fn restore_variable_stores(&mut self, stores: RuntimeVariableStores) {
        self.scalars = stores.scalars;
        self.arrays = stores.arrays;
        self.hashes = stores.hashes;
        self.bare_kinds = stores.bare_kinds;
        self.descriptor_scalar_bare_reads = stores.descriptor_scalar_bare_reads;
    }

    pub(crate) fn enter_rule_variable_scope(&mut self) {
        self.declaration_scopes
            .push(std::collections::HashMap::new());
    }

    pub(crate) fn exit_rule_variable_scope(&mut self) {
        let Some(scope) = self.declaration_scopes.pop() else {
            return;
        };
        for (name, snapshot) in scope {
            match snapshot.scalar {
                Some(value) => {
                    self.scalars.insert(name.clone(), value);
                }
                None => {
                    self.scalars.remove(&name);
                }
            }
            match snapshot.array {
                Some(value) => {
                    self.arrays.insert(name.clone(), value);
                }
                None => {
                    self.arrays.remove(&name);
                }
            }
            match snapshot.hash {
                Some(value) => {
                    self.hashes.insert(name.clone(), value);
                }
                None => {
                    self.hashes.remove(&name);
                }
            }
            match snapshot.bare_kind {
                Some(value) => {
                    self.bare_kinds.insert(name.clone(), value);
                }
                None => {
                    self.bare_kinds.remove(&name);
                }
            }
            if snapshot.descriptor_scalar_bare_read {
                self.descriptor_scalar_bare_reads.insert(name);
            } else {
                self.descriptor_scalar_bare_reads.remove(&name);
            }
        }
    }

    pub(crate) fn suspend_rule_declaration_tracking(&mut self) {
        self.declaration_scope_suppression_depth += 1;
    }

    pub(crate) fn resume_rule_declaration_tracking(&mut self) {
        self.declaration_scope_suppression_depth =
            self.declaration_scope_suppression_depth.saturating_sub(1);
    }

    pub(crate) fn record_rule_local_binding(&mut self, name: &str) {
        self.record_declaration(name);
    }

    fn snapshot_variable(&self, name: &str) -> RuntimeVariableSnapshot {
        RuntimeVariableSnapshot {
            scalar: self.scalars.get(name).cloned(),
            array: self.arrays.get(name).cloned(),
            hash: self.hashes.get(name).cloned(),
            bare_kind: self.bare_kinds.get(name).copied(),
            descriptor_scalar_bare_read: self.descriptor_scalar_bare_reads.contains(name),
        }
    }

    fn restore_variable_snapshot(&mut self, name: &str, snapshot: RuntimeVariableSnapshot) {
        match snapshot.scalar {
            Some(value) => {
                self.scalars.insert(name.to_string(), value);
            }
            None => {
                self.scalars.remove(name);
            }
        }
        match snapshot.array {
            Some(value) => {
                self.arrays.insert(name.to_string(), value);
            }
            None => {
                self.arrays.remove(name);
            }
        }
        match snapshot.hash {
            Some(value) => {
                self.hashes.insert(name.to_string(), value);
            }
            None => {
                self.hashes.remove(name);
            }
        }
        match snapshot.bare_kind {
            Some(value) => {
                self.bare_kinds.insert(name.to_string(), value);
            }
            None => {
                self.bare_kinds.remove(name);
            }
        }
        if snapshot.descriptor_scalar_bare_read {
            self.descriptor_scalar_bare_reads.insert(name.to_string());
        } else {
            self.descriptor_scalar_bare_reads.remove(name);
        }
    }

    fn record_declaration(&mut self, name: &str) {
        if self.declaration_scope_suppression_depth > 0 {
            return;
        }
        let Some(scope) = self.declaration_scopes.last_mut() else {
            return;
        };
        scope
            .entry(name.to_string())
            .or_insert_with(|| RuntimeVariableSnapshot {
                scalar: self.scalars.get(name).cloned(),
                array: self.arrays.get(name).cloned(),
                hash: self.hashes.get(name).cloned(),
                bare_kind: self.bare_kinds.get(name).copied(),
                descriptor_scalar_bare_read: self.descriptor_scalar_bare_reads.contains(name),
            });
    }

    pub(crate) fn enter_user_function(&mut self, name: &str) -> bool {
        if self
            .user_functions_active
            .iter()
            .any(|active| active == name)
        {
            return false;
        }
        self.user_functions_active.push(name.to_string());
        true
    }

    pub(crate) fn exit_user_function(&mut self, name: &str) {
        if let Some(index) = self
            .user_functions_active
            .iter()
            .rposition(|active| active == name)
        {
            self.user_functions_active.remove(index);
        }
    }

    // ── Child return value (retv) ──

    /// Set the `retv` scalar — the most recent child rule's return value.
    ///
    /// After a parent dispatches a child via an action edge (`-> Child`) or a
    /// blind-call edge (`=> Child`), the engine stores the child's return value
    /// here so the parent's attached code and its `LE`/`E` blocks can read it through
    /// the scalar-slot shorthand (Runtime Semantics §3.3 / §6.1). Before this was wired
    /// in, `retv` resolved to undef for virtually every grammar.
    pub fn set_retv(&mut self, value: RuntimeValue) {
        self.bind_descriptor_scalar_bare_read(&value);
        self.bare_kinds
            .insert("retv".to_string(), RuntimeVarKind::Scalar);
        self.scalars.insert("retv".to_string(), value);
    }

    fn bind_descriptor_scalar_bare_read(&mut self, value: &RuntimeValue) {
        let Some(name) = Self::descriptor_scalar_name(value) else {
            return;
        };
        if matches!(self.bare_kinds.get(name), Some(RuntimeVarKind::Scalar))
            && !matches!(self.get_scalar(name), RuntimeValue::Undef)
        {
            return;
        }
        self.scalars.insert(name.to_string(), value.clone());
        self.descriptor_scalar_bare_reads.insert(name.to_string());
    }

    fn descriptor_scalar_name(value: &RuntimeValue) -> Option<&str> {
        let RuntimeValue::Array(values) = value else {
            return None;
        };
        let Some(RuntimeValue::Scalar(name)) = values.first() else {
            return None;
        };
        if Self::is_identifier(name) {
            Some(name)
        } else {
            None
        }
    }

    fn is_identifier(name: &str) -> bool {
        let mut chars = name.chars();
        let Some(first) = chars.next() else {
            return false;
        };
        (first == '_' || first.is_ascii_alphabetic())
            && chars.all(|ch| ch == '_' || ch.is_ascii_alphanumeric())
    }

    pub fn push_action_edge_call_result(&mut self, label: &str, value: RuntimeValue) {
        self.action_edge_call_results
            .push((label.to_string(), value));
    }

    pub fn pop_action_edge_call_result(&mut self) {
        self.action_edge_call_results.pop();
    }

    pub fn action_edge_call_result(&self, label: &str) -> Option<RuntimeValue> {
        self.action_edge_call_results
            .iter()
            .rev()
            .find(|(active_label, _)| active_label == label)
            .map(|(_, value)| value.clone())
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

    // ── Explicit cursor controls ──

    /// Save current position onto the explicit cursor stack.
    pub fn save_cursor(&mut self) {
        self.cursor_stack.push(self.pos);
    }

    /// Restore position from the explicit cursor stack.
    /// Returns false if the stack was empty (no saved position).
    pub fn restore_cursor(&mut self) -> bool {
        if let Some(saved) = self.cursor_stack.pop() {
            self.pos = saved;
            true
        } else {
            false
        }
    }

    /// Rewind the live cursor to the current local-match start.
    pub fn rewind_match_start(&mut self) {
        self.pos = self.match_start_byte;
    }

    /// Rewind the live cursor to the entry/initial-match start for this context.
    pub fn rewind_entry_start(&mut self) {
        self.pos = self.entry_start_byte;
    }

    // ── Accumulator ──

    pub fn push_accumulator(&mut self, value: RuntimeValue) {
        self.accumulator.push(value);
    }

    pub fn get_accumulator(&self) -> &[RuntimeValue] {
        &self.accumulator
    }
}
