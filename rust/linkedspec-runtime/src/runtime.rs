//! Runtime context — variable store, accumulator, and match state.
//!
//! Provides the execution environment for a single rule invocation.
//! Declared variables are scoped to the rule. Accumulators hold child results.

use crate::{
    RuntimeDiagnosticOutputEvent, RuntimeDiagnosticOutputSink, RuntimeDiagnosticOutputSinkFailure,
    RuntimeSemanticObservationEvent, RuntimeSemanticObservationSink,
    source_location::{Position, SourceAuthority, SourceLocationContext, Span},
};
use linkedspec_core::trace::{TraceEmitter, TraceEventKind, TraceLevel, TraceResult, TraceScope};
use linkedspec_core::types::RuntimeValue;
use serde_json::{Value, json};
use std::sync::Arc;

const INPUT_SOURCE_ID: &str = "input";

/// Return the detached neutral catalog for every Rust source-boundary helper.
pub fn typed_source_projection_rows() -> Value {
    json!({
        "capture_mark": [
            ["capture_between", "span_text"],
            ["capture_from", "span_text"],
            ["capture_len_between", "span_length"],
            ["capture_len_from", "span_length"],
            ["capture_rest", "span_text"],
            ["capture_rest_from", "span_text"],
            ["capture_rest_len", "span_length"],
            ["capture_rest_len_from", "span_length"],
            ["capture_slice", "span_text"],
            ["capture_slice_col", "span_start_column"],
            ["capture_slice_len", "span_length"],
            ["capture_slice_line", "span_start_line"],
            ["capture_slice_pos", "span_start_offset"],
            ["capture_slice_until_cursor", "span_text"],
            ["capture_slice_until_cursor_len", "span_length"],
            ["capture_until_boundary", "span_text"],
            ["capture_take", "span_text"],
            ["capture_take_between", "span_text"],
            ["capture_take_between_len", "span_length"],
            ["capture_take_len", "span_length"],
            ["capture_take_len_from", "span_length"],
            ["capture_take_rest", "span_text"],
            ["capture_take_rest_from", "span_text"],
            ["capture_take_rest_len", "span_length"],
            ["capture_take_rest_len_from", "span_length"],
            ["capture_take_until_cursor", "span_text"],
            ["capture_take_until_cursor_from", "span_text"],
            ["capture_take_until_cursor_len", "span_length"],
            ["capture_take_until_cursor_len_from", "span_length"],
            ["capture_until_cursor_from", "span_text"],
            ["capture_until_cursor_len_from", "span_length"],
            ["mark_capture_slice", "capture_boundary_write_position"],
            ["mark_copy", "mark_write_position"],
            ["mark_exists", "mark_exists"],
            ["mark_here", "mark_write_position"],
            ["mark_input_end", "mark_write_position"],
            ["mark_input_start", "mark_write_position"],
            ["mark_pos", "mark_read_offset"],
            ["start_capture_slice", "capture_boundary_write_position"],
            ["start_capture_slice_from", "capture_boundary_write_position"],
            ["clear_mark", "mark_delete"],
            ["mark_col", "mark_read_column"],
            ["mark_entry_end", "mark_write_position"],
            ["mark_entry_start", "mark_write_position"],
            ["mark_line", "mark_read_line"],
            ["mark_match_end", "mark_write_position"],
            ["mark_match_start", "mark_write_position"]
        ],
        "entry_match": [
            ["entry_col", "span_start_column"],
            ["entry_end_col", "position_column"],
            ["entry_end_line", "position_line"],
            ["entry_end_pos", "position_offset"],
            ["entry_group", "capture_group_text"],
            ["entry_groups", "capture_group_list"],
            ["entry_has", "capture_group_exists"],
            ["entry_len", "span_length"],
            ["entry_line", "span_start_line"],
            ["entry_map", "capture_group_map"],
            ["entry_named", "capture_group_text"],
            ["entry_start_col", "span_start_column"],
            ["entry_start_line", "span_start_line"],
            ["entry_start_pos", "span_start_offset"],
            ["entry_text", "span_text"],
            ["match_col", "span_start_column"],
            ["match_end_col", "position_column"],
            ["match_end_line", "position_line"],
            ["match_end_pos", "position_offset"],
            ["match_group", "capture_group_text"],
            ["match_groups", "capture_group_list"],
            ["match_has", "capture_group_exists"],
            ["match_len", "span_length"],
            ["match_line", "span_start_line"],
            ["match_map", "capture_group_map"],
            ["match_named", "capture_group_text"],
            ["match_start_col", "span_start_column"],
            ["match_start_line", "span_start_line"],
            ["match_start_pos", "span_start_offset"],
            ["match_text", "span_text"]
        ],
        "input_cursor": [
            ["cursor_col", "position_column"],
            ["cursor_line", "position_line"],
            ["cursor_pos", "cursor_position"],
            ["cursor_rest", "span_text"],
            ["cursor_rest_len", "span_length"],
            ["input_end_col", "position_column"],
            ["input_end_line", "position_line"],
            ["input_end_pos", "position_offset"],
            ["input_len", "source_length"],
            ["input_slice", "source_slice_text"],
            ["input_text", "source_text"]
        ],
        "cursor_control": [
            ["restore_cursor", "cursor_state_write_compatibility"],
            ["rewind_entry_start", "cursor_state_write_compatibility"],
            ["rewind_match_start", "cursor_state_write_compatibility"],
            ["save_cursor", "cursor_checkpoint_compatibility"]
        ]
    })
}

/// Return the detached neutral alias-to-canonical helper catalog.
pub fn typed_source_compatibility_aliases() -> Value {
    json!([
        ["capture_from_rule_start", "capture_slice"],
        ["capture_len_from_rule_start", "capture_slice_len"],
        ["capture_rest_length", "capture_rest_len"],
        ["capture_slice_here", "start_capture_slice"],
        ["capture_slice_length", "capture_slice_len"],
        ["entry_named_map", "entry_map"],
        ["match_named_map", "match_map"]
    ])
}

fn runtime_value_from_json(value: Value) -> RuntimeValue {
    match value {
        Value::Null => RuntimeValue::Undef,
        Value::Bool(value) => RuntimeValue::Bool(value),
        Value::Number(value) => RuntimeValue::Number(value.as_f64().unwrap_or(0.0)),
        Value::String(value) => RuntimeValue::Scalar(value),
        Value::Array(values) => {
            RuntimeValue::Array(values.into_iter().map(runtime_value_from_json).collect())
        }
        Value::Object(values) => RuntimeValue::Hash(
            values
                .into_iter()
                .map(|(key, value)| (key, runtime_value_from_json(value)))
                .collect(),
        ),
    }
}

#[derive(Clone)]
struct RuntimeSourceAuthority(Arc<SourceAuthority>);

impl RuntimeSourceAuthority {
    fn new(input: &str) -> Self {
        let sources =
            std::collections::BTreeMap::from([(INPUT_SOURCE_ID.to_owned(), input.to_owned())]);
        Self(Arc::new(SourceAuthority::new(&sources)))
    }

    fn authority(&self) -> Arc<SourceAuthority> {
        Arc::clone(&self.0)
    }
}

impl std::fmt::Debug for RuntimeSourceAuthority {
    fn fmt(&self, formatter: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        formatter.write_str("RuntimeSourceAuthority(<opaque>)")
    }
}

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
    /// Opaque per-execution authority for immutable typed source projections.
    source_authority: RuntimeSourceAuthority,
    /// Internal authority binding for recognition transactions.
    recognition_transactions: crate::recognition_transaction::RecognitionRuntime,
    /// Active non-eager recognition scopes publish explicit child acceptance.
    recognition_scope_depth: usize,
    recognition_completions: Vec<(String, bool)>,
    /// Current match position in the input.
    pub pos: usize,
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
    /// Optional caller-owned diagnostic-output sink for this invocation.
    diagnostic_output_sink: Option<RuntimeDiagnosticOutputSink>,
    /// Exact caller failure retained while the interpreter unwinds.
    diagnostic_output_sink_failure: Option<RuntimeDiagnosticOutputSinkFailure>,
    /// Optional caller-owned typed semantic sink for this invocation.
    semantic_observation_sink: Option<RuntimeSemanticObservationSink>,
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
    /// Active dynamic codeblock-variable calls. The ordered names retain
    /// enough identity to reject direct and mutual cycles deterministically.
    codeblocks_active: Vec<String>,
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
    pub(crate) code: Option<&'static str>,
    pub(crate) helper_name: Option<String>,
    pub(crate) actual_arity: Option<usize>,
    pub(crate) expected_arity: Option<&'static str>,
    pub(crate) target_rule: Option<String>,
    pub(crate) regex_index: Option<usize>,
    pub(crate) expected_regex_index: Option<usize>,
    pub(crate) actual_regex_index: Option<usize>,
    pub(crate) callable_name: Option<String>,
    pub(crate) expected: Option<String>,
    pub(crate) got: Option<usize>,
    pub(crate) value_kind: Option<&'static str>,
    pub(crate) name: Option<String>,
    pub(crate) cycle: Option<Vec<String>>,
}

pub(crate) enum CallableCodeblockFailure {
    Arity {
        callable_name: String,
        expected: String,
        got: usize,
    },
    KeywordArguments {
        callable_name: String,
        got: usize,
    },
    ValueNotCallable {
        callable_name: String,
        value_kind: &'static str,
    },
    FinalArgumentNotCodeblock {
        callable_name: String,
        value_kind: &'static str,
    },
    Recursion {
        callable_name: String,
        cycle: Vec<String>,
    },
    UnknownHelper {
        name: String,
    },
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
        let source_authority = RuntimeSourceAuthority::new(input);
        Self {
            input: input.to_string(),
            recognition_transactions: crate::recognition_transaction::RecognitionRuntime::new(
                source_authority.authority(),
                INPUT_SOURCE_ID,
            ),
            recognition_scope_depth: 0,
            recognition_completions: Vec::new(),
            source_authority,
            pos: 0,
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
            diagnostic_output_sink: None,
            diagnostic_output_sink_failure: None,
            semantic_observation_sink: None,
            cursor_stack: Vec::new(),
            return_value: None,
            recursion_active: std::collections::HashSet::new(),
            user_functions_active: Vec::new(),
            codeblocks_active: Vec::new(),
            action_edge_call_results: Vec::new(),
            declaration_scopes: Vec::new(),
            declaration_scope_suppression_depth: 0,
            trace_events_enabled: false,
            trace_events: Vec::new(),
            diagnostic_top_rule: None,
            diagnostic_failure: None,
        }
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

    fn recognition_frame_state(
        &self,
        rule_label: &str,
    ) -> crate::recognition_transaction::RecognitionFrameState {
        let marks = self
            .marks
            .get(rule_label)
            .into_iter()
            .flat_map(|bucket| bucket.iter())
            .map(|(name, offset)| {
                (
                    name.clone(),
                    u64::try_from(*offset).expect("Rust cursor offset fits u64"),
                )
            })
            .collect();
        crate::recognition_transaction::RecognitionFrameState::new(
            u64::try_from(self.pos).expect("Rust cursor offset fits u64"),
            self.capture_start
                .map(|offset| u64::try_from(offset).expect("Rust boundary offset fits u64")),
            marks,
        )
    }

    fn apply_recognition_frame_state(
        &mut self,
        rule_label: &str,
        state: &crate::recognition_transaction::RecognitionFrameState,
    ) -> Result<(), String> {
        self.pos = usize::try_from(state.cursor())
            .map_err(|_| "recognition cursor does not fit this Rust target".to_owned())?;
        self.capture_start = state
            .boundary()
            .map(usize::try_from)
            .transpose()
            .map_err(|_| "recognition boundary does not fit this Rust target".to_owned())?;
        let marks = state
            .marks()
            .iter()
            .map(|(name, offset)| {
                usize::try_from(*offset)
                    .map(|offset| (name.clone(), offset))
                    .map_err(|_| "recognition mark does not fit this Rust target".to_owned())
            })
            .collect::<Result<std::collections::HashMap<_, _>, _>>()?;
        self.marks.insert(rule_label.to_owned(), marks);
        Ok(())
    }

    pub(crate) fn enter_recognition_invocation(&mut self, rule_label: &str) -> Result<(), String> {
        let prior_marks = self.marks.remove(rule_label);
        self.marks.insert(rule_label.to_owned(), Default::default());
        let state = self.recognition_frame_state(rule_label);
        let recognition = self.recognition_transactions.clone();
        match recognition.enter(rule_label, state, prior_marks.clone()) {
            Ok(()) => Ok(()),
            Err(error) => {
                if let Some(prior_marks) = prior_marks {
                    self.marks.insert(rule_label.to_owned(), prior_marks);
                } else {
                    self.marks.remove(rule_label);
                }
                Err(error.to_string())
            }
        }
    }

    pub(crate) fn leave_recognition_invocation(
        &mut self,
        rule_label: &str,
    ) -> Result<bool, String> {
        let state = self.recognition_frame_state(rule_label);
        let recognition = self.recognition_transactions.clone();
        let (exit, terminal) = recognition.leave(state);
        self.apply_recognition_frame_state(rule_label, &exit.state)?;
        if let Some(prior_marks) = exit.prior_marks {
            self.marks.insert(rule_label.to_owned(), prior_marks);
        } else {
            self.marks.remove(rule_label);
        }
        if self.recognition_scope_depth > 0 {
            self.recognition_completions
                .push((rule_label.to_owned(), exit.accepted));
        }
        terminal
            .map(|()| exit.accepted)
            .map_err(|error| error.to_string())
    }

    pub(crate) fn note_recognition_match(&mut self) {
        self.recognition_transactions.note_match();
    }

    pub(crate) fn begin_recognition_scope(&mut self) -> usize {
        self.recognition_scope_depth += 1;
        self.recognition_completions.len()
    }

    pub(crate) fn finish_recognition_scope(
        &mut self,
        completion_base: usize,
        expected_rule: &str,
    ) -> Result<bool, String> {
        self.recognition_scope_depth = self
            .recognition_scope_depth
            .checked_sub(1)
            .expect("recognition scope depth is balanced");
        let completions = self.recognition_completions.split_off(completion_base);
        let completion = completions
            .into_iter()
            .rev()
            .find(|(rule, _)| rule == expected_rule)
            .ok_or_else(|| {
                format!(
                    "recognition child '{expected_rule}' did not publish one invocation completion"
                )
            })?;
        Ok(completion.1)
    }

    pub(crate) fn cancel_recognition_scope(&mut self, completion_base: usize) {
        self.recognition_scope_depth = self
            .recognition_scope_depth
            .checked_sub(1)
            .expect("recognition scope depth is balanced");
        self.recognition_completions.truncate(completion_base);
    }

    pub(crate) fn recognition_result_is_match(&mut self, fallback: bool) -> bool {
        if self.recognition_scope_depth == 0 {
            return fallback;
        }
        self.recognition_completions
            .pop()
            .map(|(_, accepted)| accepted)
            .unwrap_or(fallback)
    }

    pub(crate) fn recognition_checkpoint(
        &mut self,
        rule_label: &str,
        slot: &str,
    ) -> Result<(), String> {
        let state = self.recognition_frame_state(rule_label);
        self.recognition_transactions
            .checkpoint(slot, state)
            .map_err(|error| error.to_string())
    }

    pub(crate) fn recognition_attempt(
        &mut self,
        rule_label: &str,
        slot: &str,
        matched: bool,
        payload: RuntimeValue,
    ) -> Result<bool, String> {
        let state = self.recognition_frame_state(rule_label);
        self.recognition_transactions
            .attempt(slot, matched, Some(payload.to_json()), state)
            .map_err(|error| error.to_string())
    }

    pub(crate) fn recognition_commit(
        &mut self,
        rule_label: &str,
        slot: &str,
    ) -> Result<RuntimeValue, String> {
        let state = self.recognition_frame_state(rule_label);
        self.recognition_transactions
            .commit(slot, state)
            .map(|payload| {
                payload
                    .map(runtime_value_from_json)
                    .unwrap_or(RuntimeValue::Undef)
            })
            .map_err(|error| error.to_string())
    }

    pub(crate) fn recognition_rollback(
        &mut self,
        rule_label: &str,
        slot: &str,
    ) -> Result<(), String> {
        let state = self.recognition_frame_state(rule_label);
        let recognition = self.recognition_transactions.clone();
        let restored = recognition
            .rollback(slot, state)
            .map_err(|error| error.to_string())?;
        self.apply_recognition_frame_state(rule_label, &restored)
    }

    pub(crate) fn typed_mark_set(
        &mut self,
        rule_label: &str,
        name: String,
        byte_offset: usize,
        projection: &str,
    ) -> bool {
        if !self.typed_position_is_valid_byte(byte_offset, rule_label, projection) {
            return false;
        }
        self.mark_set(rule_label, name, byte_offset);
        true
    }

    pub(crate) fn typed_mark_byte(
        &self,
        rule_label: &str,
        name: &str,
        projection: &str,
    ) -> Option<usize> {
        let byte_offset = self.mark_get(rule_label, name)?;
        self.typed_position_is_valid_byte(byte_offset, rule_label, projection)
            .then_some(byte_offset)
    }

    pub(crate) fn typed_mark_offset(
        &self,
        rule_label: &str,
        name: &str,
        projection: &str,
    ) -> Option<usize> {
        self.typed_position_offset_from_byte(
            self.mark_get(rule_label, name)?,
            rule_label,
            projection,
        )
    }

    pub(crate) fn typed_mark_line(
        &self,
        rule_label: &str,
        name: &str,
        projection: &str,
    ) -> Option<usize> {
        self.typed_position_line_from_byte(self.mark_get(rule_label, name)?, rule_label, projection)
    }

    pub(crate) fn typed_mark_column(
        &self,
        rule_label: &str,
        name: &str,
        projection: &str,
    ) -> Option<usize> {
        self.typed_position_column_from_byte(
            self.mark_get(rule_label, name)?,
            rule_label,
            projection,
        )
    }

    pub(crate) fn project_capture_group_text(value: Option<&String>) -> RuntimeValue {
        value
            .cloned()
            .map(RuntimeValue::Scalar)
            .unwrap_or(RuntimeValue::Undef)
    }

    pub(crate) fn project_capture_group_list(values: &[String]) -> RuntimeValue {
        RuntimeValue::Array(values.iter().cloned().map(RuntimeValue::Scalar).collect())
    }

    pub(crate) fn project_capture_group_map(
        values: &std::collections::HashMap<String, String>,
    ) -> RuntimeValue {
        let mut entries = values
            .iter()
            .map(|(key, value)| (key.clone(), RuntimeValue::Scalar(value.clone())))
            .collect::<Vec<_>>();
        entries.sort_by(|(left, _), (right, _)| left.cmp(right));
        RuntimeValue::Hash(entries)
    }

    pub(crate) fn project_capture_group_exists(exists: bool) -> RuntimeValue {
        RuntimeValue::Number(if exists { 1.0 } else { 0.0 })
    }

    pub(crate) fn set_diagnostic_top_rule(&mut self, label: impl Into<String>) {
        self.diagnostic_top_rule = Some(label.into());
    }

    pub(crate) fn diagnostic_top_rule(&self) -> Option<&str> {
        self.diagnostic_top_rule.as_deref()
    }

    pub(crate) fn is_effective_entry_rule(&self, label: &str) -> bool {
        self.diagnostic_top_rule() == Some(label)
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
                code: None,
                helper_name: None,
                actual_arity: None,
                expected_arity: None,
                target_rule: None,
                regex_index: None,
                expected_regex_index: None,
                actual_regex_index: None,
                callable_name: None,
                expected: None,
                got: None,
                value_kind: None,
                name: None,
                cycle: None,
            });
        }
    }

    pub(crate) fn capture_portable_diagnostic_failure(
        &mut self,
        stage: &'static str,
        code: &'static str,
        summary: &'static str,
        rule_label: Option<&str>,
    ) {
        if self.diagnostic_failure.is_none() {
            self.diagnostic_failure = Some(RuntimeFailureContext {
                stage,
                summary,
                rule_label: rule_label.map(str::to_string),
                code: Some(code),
                helper_name: None,
                actual_arity: None,
                expected_arity: None,
                target_rule: None,
                regex_index: None,
                expected_regex_index: None,
                actual_regex_index: None,
                callable_name: None,
                expected: None,
                got: None,
                value_kind: None,
                name: None,
                cycle: None,
            });
        }
    }

    pub(crate) fn capture_helper_arity_failure(
        &mut self,
        helper_name: &str,
        actual_arity: usize,
        expected_arity: &'static str,
        rule_label: &str,
    ) {
        if self.diagnostic_failure.is_none() {
            self.diagnostic_failure = Some(RuntimeFailureContext {
                stage: "helper_arity_mismatch",
                summary: "Rust runtime helper arity mismatch",
                rule_label: Some(rule_label.to_string()),
                code: Some("helper_arity_mismatch"),
                helper_name: Some(helper_name.to_string()),
                actual_arity: Some(actual_arity),
                expected_arity: Some(expected_arity),
                target_rule: None,
                regex_index: None,
                expected_regex_index: None,
                actual_regex_index: None,
                callable_name: None,
                expected: None,
                got: None,
                value_kind: None,
                name: None,
                cycle: None,
            });
        }
    }

    pub(crate) fn capture_callable_codeblock_failure(
        &mut self,
        rule_label: &str,
        failure: CallableCodeblockFailure,
    ) {
        if self.diagnostic_failure.is_none() {
            let (code, callable_name, expected, got, value_kind, name, cycle) = match failure {
                CallableCodeblockFailure::Arity {
                    callable_name,
                    expected,
                    got,
                } => (
                    "codeblock_arity_mismatch",
                    Some(callable_name),
                    Some(expected),
                    Some(got),
                    None,
                    None,
                    None,
                ),
                CallableCodeblockFailure::KeywordArguments { callable_name, got } => (
                    "codeblock_keyword_arguments_unsupported",
                    Some(callable_name),
                    Some("positional arguments".to_string()),
                    Some(got),
                    None,
                    None,
                    None,
                ),
                CallableCodeblockFailure::ValueNotCallable {
                    callable_name,
                    value_kind,
                } => (
                    "value_not_callable",
                    Some(callable_name),
                    None,
                    None,
                    Some(value_kind),
                    None,
                    None,
                ),
                CallableCodeblockFailure::FinalArgumentNotCodeblock {
                    callable_name,
                    value_kind,
                } => (
                    "final_argument_not_codeblock",
                    Some(callable_name),
                    None,
                    None,
                    Some(value_kind),
                    None,
                    None,
                ),
                CallableCodeblockFailure::Recursion {
                    callable_name,
                    cycle,
                } => (
                    "codeblock_recursion_unsupported",
                    Some(callable_name),
                    None,
                    None,
                    None,
                    None,
                    Some(cycle),
                ),
                CallableCodeblockFailure::UnknownHelper { name } => {
                    ("unknown_helper", None, None, None, None, Some(name), None)
                }
            };
            self.diagnostic_failure = Some(RuntimeFailureContext {
                stage: "callable_codeblock_invocation",
                summary: "Rust callable codeblock invocation failed",
                rule_label: Some(rule_label.to_string()),
                code: Some(code),
                helper_name: None,
                actual_arity: None,
                expected_arity: None,
                target_rule: None,
                regex_index: None,
                expected_regex_index: None,
                actual_regex_index: None,
                callable_name,
                expected,
                got,
                value_kind,
                name,
                cycle,
            });
        }
    }

    pub(crate) fn capture_regex_slot_identity_invalid(
        &mut self,
        rule_label: Option<&str>,
        target_rule: &str,
        regex_index: usize,
    ) {
        if self.diagnostic_failure.is_none() {
            self.diagnostic_failure = Some(RuntimeFailureContext {
                stage: "validate_compiled_rule",
                summary: "Rust compiled regex slot identity validation failed",
                rule_label: rule_label.map(str::to_string),
                code: Some("regex_slot_identity_invalid"),
                helper_name: None,
                actual_arity: None,
                expected_arity: None,
                target_rule: Some(target_rule.to_string()),
                regex_index: Some(regex_index),
                expected_regex_index: None,
                actual_regex_index: None,
                callable_name: None,
                expected: None,
                got: None,
                value_kind: None,
                name: None,
                cycle: None,
            });
        }
    }

    pub(crate) fn capture_ordered_regex_slot_identity_lost(
        &mut self,
        rule_label: &str,
        target_rule: &str,
        expected_regex_index: usize,
        actual_regex_index: usize,
    ) {
        if self.diagnostic_failure.is_none() {
            self.diagnostic_failure = Some(RuntimeFailureContext {
                stage: "execute_rule",
                summary: "Rust ordered regex slot identity invariant failed",
                rule_label: Some(rule_label.to_string()),
                code: Some("ordered_regex_slot_identity_lost"),
                helper_name: None,
                actual_arity: None,
                expected_arity: None,
                target_rule: Some(target_rule.to_string()),
                regex_index: None,
                expected_regex_index: Some(expected_regex_index),
                actual_regex_index: Some(actual_regex_index),
                callable_name: None,
                expected: None,
                got: None,
                value_kind: None,
                name: None,
                cycle: None,
            });
        }
    }

    pub(crate) fn diagnostic_failure(&self) -> Option<&RuntimeFailureContext> {
        self.diagnostic_failure.as_ref()
    }

    pub(crate) fn install_diagnostic_output_sink(
        &mut self,
        sink: Option<&RuntimeDiagnosticOutputSink>,
    ) {
        self.diagnostic_output_sink = sink.cloned();
    }

    pub(crate) fn emit_diagnostic_output(
        &mut self,
        event: RuntimeDiagnosticOutputEvent,
    ) -> Result<(), String> {
        let Some(sink) = self.diagnostic_output_sink.as_ref() else {
            return Ok(());
        };
        let result = sink.emit(event);
        match result {
            Ok(()) => Ok(()),
            Err(failure) => {
                self.diagnostic_output_sink_failure = Some(failure);
                Err("diagnostic output sink failed".to_string())
            }
        }
    }

    pub(crate) fn take_diagnostic_output_sink_failure(
        &mut self,
    ) -> Option<RuntimeDiagnosticOutputSinkFailure> {
        self.diagnostic_output_sink_failure.take()
    }

    pub(crate) fn install_semantic_observation_sink(
        &mut self,
        sink: Option<&RuntimeSemanticObservationSink>,
    ) {
        self.semantic_observation_sink = sink.cloned();
    }

    pub(crate) fn semantic_observation_enabled(&self) -> bool {
        self.semantic_observation_sink.is_some()
    }

    pub(crate) fn emit_regex_slot_selected(
        &self,
        rule_label: &str,
        target_rule: &str,
        regex_index: usize,
        position: usize,
    ) {
        let Some(sink) = self.semantic_observation_sink.as_ref() else {
            return;
        };
        sink.emit(RuntimeSemanticObservationEvent::regex_slot_selected(
            rule_label,
            target_rule,
            regex_index,
            position,
        ));
    }

    pub(crate) fn emit_rule_result(&self, rule_label: &str, position: usize) {
        let Some(sink) = self.semantic_observation_sink.as_ref() else {
            return;
        };
        sink.emit(RuntimeSemanticObservationEvent::rule_result(
            rule_label,
            position,
            &self.input,
        ));
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

    fn typed_source_context(rule_label: &str, projection: &str) -> SourceLocationContext {
        SourceLocationContext::new(
            format!("{rule_label}:{projection}"),
            "compatibility_projection",
        )
    }

    fn typed_position_from_byte(
        &self,
        byte_offset: usize,
        rule_label: &str,
        projection: &str,
    ) -> Option<Position> {
        self.source_authority
            .0
            .position_from_utf8_byte(
                INPUT_SOURCE_ID,
                u64::try_from(byte_offset).ok()?,
                &Self::typed_source_context(rule_label, projection),
            )
            .ok()
    }

    fn typed_position_from_scalar(
        &self,
        scalar_offset: usize,
        rule_label: &str,
        projection: &str,
    ) -> Option<Position> {
        self.source_authority
            .0
            .position(
                INPUT_SOURCE_ID,
                u64::try_from(scalar_offset).ok()?,
                &Self::typed_source_context(rule_label, projection),
            )
            .ok()
    }

    fn typed_span_from_bytes(
        &self,
        start_byte: usize,
        end_byte: usize,
        rule_label: &str,
        projection: &str,
    ) -> Option<Span> {
        let context = Self::typed_source_context(rule_label, projection);
        let start = self.typed_position_from_byte(start_byte, rule_label, projection)?;
        let end = self.typed_position_from_byte(end_byte, rule_label, projection)?;
        self.source_authority
            .0
            .direct_span(&start, &end, projection, &context)
            .ok()
    }

    fn typed_span_from_scalars(
        &self,
        start: usize,
        end: usize,
        rule_label: &str,
        projection: &str,
    ) -> Option<Span> {
        let context = Self::typed_source_context(rule_label, projection);
        let start = self.typed_position_from_scalar(start, rule_label, projection)?;
        let end = self.typed_position_from_scalar(end, rule_label, projection)?;
        self.source_authority
            .0
            .direct_span(&start, &end, projection, &context)
            .ok()
    }

    pub(crate) fn typed_position_is_valid_byte(
        &self,
        byte_offset: usize,
        rule_label: &str,
        projection: &str,
    ) -> bool {
        self.typed_position_from_byte(byte_offset, rule_label, projection)
            .is_some()
    }

    pub(crate) fn typed_position_offset_from_byte(
        &self,
        byte_offset: usize,
        rule_label: &str,
        projection: &str,
    ) -> Option<usize> {
        usize::try_from(
            self.typed_position_from_byte(byte_offset, rule_label, projection)?
                .offset(),
        )
        .ok()
    }

    pub(crate) fn typed_position_line_from_byte(
        &self,
        byte_offset: usize,
        rule_label: &str,
        projection: &str,
    ) -> Option<usize> {
        let position = self.typed_position_from_byte(byte_offset, rule_label, projection)?;
        usize::try_from(
            self.source_authority
                .0
                .coordinates(
                    &position,
                    &Self::typed_source_context(rule_label, projection),
                )
                .ok()?
                .line(),
        )
        .ok()
    }

    pub(crate) fn typed_position_column_from_byte(
        &self,
        byte_offset: usize,
        rule_label: &str,
        projection: &str,
    ) -> Option<usize> {
        let position = self.typed_position_from_byte(byte_offset, rule_label, projection)?;
        usize::try_from(
            self.source_authority
                .0
                .coordinates(
                    &position,
                    &Self::typed_source_context(rule_label, projection),
                )
                .ok()?
                .column(),
        )
        .ok()
    }

    pub(crate) fn typed_position_line_from_scalar_clamped(
        &self,
        scalar_offset: usize,
        rule_label: &str,
        projection: &str,
    ) -> Option<usize> {
        let source_length = usize::try_from(
            self.source_authority
                .0
                .source_scalar_length(INPUT_SOURCE_ID)?,
        )
        .ok()?;
        let position = self.typed_position_from_scalar(
            scalar_offset.min(source_length),
            rule_label,
            projection,
        )?;
        usize::try_from(
            self.source_authority
                .0
                .coordinates(
                    &position,
                    &Self::typed_source_context(rule_label, projection),
                )
                .ok()?
                .line(),
        )
        .ok()
    }

    pub(crate) fn typed_position_column_from_scalar_clamped(
        &self,
        scalar_offset: usize,
        rule_label: &str,
        projection: &str,
    ) -> Option<usize> {
        let source_length = usize::try_from(
            self.source_authority
                .0
                .source_scalar_length(INPUT_SOURCE_ID)?,
        )
        .ok()?;
        let position = self.typed_position_from_scalar(
            scalar_offset.min(source_length),
            rule_label,
            projection,
        )?;
        usize::try_from(
            self.source_authority
                .0
                .coordinates(
                    &position,
                    &Self::typed_source_context(rule_label, projection),
                )
                .ok()?
                .column(),
        )
        .ok()
    }

    pub(crate) fn typed_position_line_from_optional_scalar(
        &self,
        scalar_offset: Option<usize>,
        default_byte_offset: usize,
        rule_label: &str,
        projection: &str,
    ) -> Option<usize> {
        match scalar_offset {
            Some(offset) => {
                self.typed_position_line_from_scalar_clamped(offset, rule_label, projection)
            }
            None => self.typed_position_line_from_byte(default_byte_offset, rule_label, projection),
        }
    }

    pub(crate) fn typed_position_column_from_optional_scalar(
        &self,
        scalar_offset: Option<usize>,
        default_byte_offset: usize,
        rule_label: &str,
        projection: &str,
    ) -> Option<usize> {
        match scalar_offset {
            Some(offset) => {
                self.typed_position_column_from_scalar_clamped(offset, rule_label, projection)
            }
            None => {
                self.typed_position_column_from_byte(default_byte_offset, rule_label, projection)
            }
        }
    }

    pub(crate) fn typed_span_text_from_bytes(
        &self,
        start_byte: usize,
        end_byte: usize,
        rule_label: &str,
        projection: &str,
    ) -> Option<String> {
        let span = self.typed_span_from_bytes(start_byte, end_byte, rule_label, projection)?;
        self.source_authority
            .0
            .materialize(&span, &Self::typed_source_context(rule_label, projection))
            .ok()
    }

    pub(crate) fn typed_span_length_from_bytes(
        &self,
        start_byte: usize,
        end_byte: usize,
        rule_label: &str,
        projection: &str,
    ) -> Option<usize> {
        usize::try_from(
            self.typed_span_from_bytes(start_byte, end_byte, rule_label, projection)?
                .scalar_len(),
        )
        .ok()
    }

    pub(crate) fn typed_span_start_offset_from_bytes(
        &self,
        start_byte: usize,
        end_byte: usize,
        rule_label: &str,
        projection: &str,
    ) -> Option<usize> {
        usize::try_from(
            self.typed_span_from_bytes(start_byte, end_byte, rule_label, projection)?
                .start(),
        )
        .ok()
    }

    pub(crate) fn typed_span_start_line_from_bytes(
        &self,
        start_byte: usize,
        end_byte: usize,
        rule_label: &str,
        projection: &str,
    ) -> Option<usize> {
        self.typed_span_from_bytes(start_byte, end_byte, rule_label, projection)?;
        self.typed_position_line_from_byte(start_byte, rule_label, projection)
    }

    pub(crate) fn typed_span_start_column_from_bytes(
        &self,
        start_byte: usize,
        end_byte: usize,
        rule_label: &str,
        projection: &str,
    ) -> Option<usize> {
        self.typed_span_from_bytes(start_byte, end_byte, rule_label, projection)?;
        self.typed_position_column_from_byte(start_byte, rule_label, projection)
    }

    pub(crate) fn typed_source_text(&self, rule_label: &str, projection: &str) -> Option<String> {
        let end = usize::try_from(
            self.source_authority
                .0
                .source_scalar_length(INPUT_SOURCE_ID)?,
        )
        .ok()?;
        let span = self.typed_span_from_scalars(0, end, rule_label, projection)?;
        self.source_authority
            .0
            .materialize(&span, &Self::typed_source_context(rule_label, projection))
            .ok()
    }

    pub(crate) fn typed_source_length(&self) -> Option<usize> {
        usize::try_from(
            self.source_authority
                .0
                .source_scalar_length(INPUT_SOURCE_ID)?,
        )
        .ok()
    }

    pub(crate) fn typed_source_slice(
        &self,
        start: usize,
        width: usize,
        rule_label: &str,
        projection: &str,
    ) -> Option<String> {
        let source_length = self.typed_source_length()?;
        let start = start.min(source_length);
        let end = start.saturating_add(width).min(source_length);
        let span = self.typed_span_from_scalars(start, end, rule_label, projection)?;
        self.source_authority
            .0
            .materialize(&span, &Self::typed_source_context(rule_label, projection))
            .ok()
    }

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

    pub(crate) fn has_bare_binding(&self, name: &str) -> bool {
        self.bare_kinds.contains_key(name)
            || self.scalars.contains_key(name)
            || self.arrays.contains_key(name)
            || self.hashes.contains_key(name)
    }

    pub fn bare_kind(&self, name: &str) -> Option<RuntimeVarKind> {
        self.bare_kinds.get(name).copied()
    }

    pub(crate) fn binding_value_kind(value: &RuntimeValue) -> &'static str {
        match value {
            RuntimeValue::Array(_) => "array",
            RuntimeValue::Hash(_) => "harray",
            RuntimeValue::Codeblock(_) => "codeblock",
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

    pub(crate) fn enter_codeblock(&mut self, name: &str) -> Result<(), Vec<String>> {
        if let Some(index) = self
            .codeblocks_active
            .iter()
            .position(|active| active == name)
        {
            let mut cycle = self.codeblocks_active[index..].to_vec();
            cycle.push(name.to_string());
            return Err(cycle);
        }
        self.codeblocks_active.push(name.to_string());
        Ok(())
    }

    pub(crate) fn exit_codeblock(&mut self, name: &str) {
        if let Some(index) = self
            .codeblocks_active
            .iter()
            .rposition(|active| active == name)
        {
            self.codeblocks_active.remove(index);
        }
    }

    pub(crate) fn has_active_codeblock(&self) -> bool {
        !self.codeblocks_active.is_empty()
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

    pub(crate) fn typed_save_cursor(&mut self, rule_label: &str, projection: &str) -> bool {
        if !self.typed_position_is_valid_byte(self.pos, rule_label, projection) {
            return false;
        }
        self.save_cursor();
        true
    }

    pub(crate) fn typed_restore_cursor(&mut self, rule_label: &str, projection: &str) -> bool {
        let Some(saved) = self.cursor_stack.last().copied() else {
            return false;
        };
        if !self.typed_position_is_valid_byte(saved, rule_label, projection) {
            return false;
        }
        self.cursor_stack.pop();
        self.pos = saved;
        true
    }

    pub(crate) fn typed_rewind_match_start(&mut self, rule_label: &str, projection: &str) -> bool {
        if !self.typed_position_is_valid_byte(self.match_start_byte, rule_label, projection) {
            return false;
        }
        self.rewind_match_start();
        true
    }

    pub(crate) fn typed_rewind_entry_start(&mut self, rule_label: &str, projection: &str) -> bool {
        if !self.typed_position_is_valid_byte(self.entry_start_byte, rule_label, projection) {
            return false;
        }
        self.rewind_entry_start();
        true
    }

    // ── Accumulator ──

    pub fn push_accumulator(&mut self, value: RuntimeValue) {
        self.accumulator.push(value);
    }

    pub fn get_accumulator(&self) -> &[RuntimeValue] {
        &self.accumulator
    }
}
