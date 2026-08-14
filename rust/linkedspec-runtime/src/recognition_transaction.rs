//! Private recognition-invocation frames and linear transaction tokens.
//!
//! The runtime and exact conformance consumer share this internal authority;
//! public documentation exposes only the portable authored transaction contract.

use crate::source_location::SourceAuthority;
use serde_json::{Map, Value, json};
use std::cell::RefCell;
use std::collections::BTreeMap;
use std::fmt;
use std::rc::{Rc, Weak};
use std::sync::Arc;
use std::sync::atomic::{AtomicU64, Ordering};

static NEXT_AUTHORITY_ID: AtomicU64 = AtomicU64::new(1);

/// Cursor, anonymous-boundary, and invocation-local named-mark state.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RecognitionFrameState {
    cursor: u64,
    boundary: Option<u64>,
    marks: BTreeMap<String, u64>,
}

impl RecognitionFrameState {
    /// Construct one owned frame-state value.
    pub fn new(cursor: u64, boundary: Option<u64>, marks: BTreeMap<String, u64>) -> Self {
        Self {
            cursor,
            boundary,
            marks,
        }
    }

    fn as_record(&self) -> Value {
        json!({
            "cursor": self.cursor,
            "boundary": self.boundary,
            "marks": self.marks,
        })
    }

    pub(crate) fn cursor(&self) -> u64 {
        self.cursor
    }

    pub(crate) fn boundary(&self) -> Option<u64> {
        self.boundary
    }

    pub(crate) fn marks(&self) -> &BTreeMap<String, u64> {
        &self.marks
    }
}

/// Detached observation of one live recognition frame.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RecognitionFrameSnapshot {
    source: Box<str>,
    rule: Box<str>,
    invocation: u64,
    generation: u64,
    state: RecognitionFrameState,
}

impl RecognitionFrameSnapshot {
    /// Return the opaque, authority-local invocation generation.
    pub fn invocation(&self) -> u64 {
        self.invocation
    }

    /// Return the opaque named-mark table generation.
    pub fn generation(&self) -> u64 {
        self.generation
    }

    /// Return only cursor, anonymous-boundary, and named-mark state.
    pub fn state_record(&self) -> Value {
        self.state.as_record()
    }

    pub(crate) fn state(&self) -> RecognitionFrameState {
        self.state.clone()
    }

    /// Return a detached neutral record.
    pub fn as_record(&self) -> Value {
        json!({
            "source": self.source.as_ref(),
            "rule": self.rule.as_ref(),
            "invocation": self.invocation,
            "generation": self.generation,
            "cursor": self.state.cursor,
            "boundary": self.state.boundary,
            "marks": self.state.marks,
        })
    }
}

/// Portable private recognition-transaction diagnostic.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RecognitionTransactionError {
    record: Value,
}

impl RecognitionTransactionError {
    fn new(code: &'static str, fields: impl IntoIterator<Item = (&'static str, Value)>) -> Self {
        let mut record = Map::new();
        record.insert("code".to_owned(), Value::String(code.to_owned()));
        for (name, value) in fields {
            record.insert(name.to_owned(), value);
        }
        Self {
            record: Value::Object(record),
        }
    }

    /// Return a detached machine-readable error record.
    pub fn as_record(&self) -> Value {
        self.record.clone()
    }
}

impl fmt::Display for RecognitionTransactionError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        let code = self.record["code"]
            .as_str()
            .unwrap_or("recognition_transaction_error");
        write!(formatter, "LINKEDSPEC_RECOGNITION_TRANSACTION_ERROR:{code}")
    }
}

impl std::error::Error for RecognitionTransactionError {}

/// Opaque invocation and named-mark generation handle.
pub struct RecognitionInvocationFrame {
    state: Rc<RefCell<InvocationState>>,
}

/// Opaque, exactly-once recognition-transaction handle.
pub struct RecognitionTransactionToken {
    state: Rc<RefCell<TransactionState>>,
}

struct InvocationState {
    authority_id: u64,
    source_authority: Arc<SourceAuthority>,
    source_identity: Box<str>,
    rule: Box<str>,
    origin: Box<str>,
    invocation: u64,
    parent_invocation: Option<u64>,
    generation: u64,
    active: bool,
    frame_state: RecognitionFrameState,
    active_token: Option<Weak<RefCell<TransactionState>>>,
}

#[derive(Clone, Copy, PartialEq, Eq)]
enum TransactionStatus {
    ActiveUnattempted,
    ActiveStagedMatch,
    ActiveStagedMiss,
    Invalidated,
}

struct TransactionState {
    authority_id: u64,
    source_authority: Arc<SourceAuthority>,
    source_identity: Box<str>,
    rule: Box<str>,
    origin: Box<str>,
    invocation: u64,
    generation: u64,
    _transaction: u64,
    status: TransactionStatus,
    attempt_count: u64,
    matched: bool,
    payload_present: bool,
    payload: Option<Value>,
    snapshot: RecognitionFrameState,
    frame: Weak<RefCell<InvocationState>>,
}

/// Authority for private invocation frames, mark generations, and linear tokens.
pub struct RecognitionTransactionAuthority {
    authority_id: u64,
    source_authority: Arc<SourceAuthority>,
    source_identity: Box<str>,
    next_invocation: u64,
    next_generation: u64,
    next_transaction: u64,
    invocation_stack: Vec<Rc<RefCell<InvocationState>>>,
}

/// Parse-local lineage for one entered or pre-entry-rejected invocation.
#[derive(Debug, Clone, PartialEq, Eq)]
pub(crate) struct RecognitionInvocationIdentity {
    pub(crate) rule_label: String,
    pub(crate) invocation_id: u64,
    pub(crate) parent_invocation_id: Option<u64>,
}

impl RecognitionTransactionAuthority {
    /// Construct an independent transaction authority over one source authority.
    pub fn new(source_authority: Arc<SourceAuthority>, source_identity: &str) -> Self {
        let authority_id = NEXT_AUTHORITY_ID
            .fetch_update(Ordering::Relaxed, Ordering::Relaxed, |current| {
                current.checked_add(1)
            })
            .expect("recognition transaction authority identity space exhausted");
        Self {
            authority_id,
            source_authority,
            source_identity: source_identity.to_owned().into_boxed_str(),
            next_invocation: 1,
            next_generation: 1,
            next_transaction: 1,
            invocation_stack: Vec::new(),
        }
    }

    /// Enter one independent rule invocation and allocate fresh opaque generations.
    pub fn enter_invocation(
        &mut self,
        rule: &str,
        origin: &str,
        state: RecognitionFrameState,
    ) -> Result<RecognitionInvocationFrame, RecognitionTransactionError> {
        let parent_invocation = self
            .invocation_stack
            .last()
            .map(|parent| parent.borrow().invocation);
        let invocation = take_generation(
            &mut self.next_invocation,
            "recognition invocation identity space exhausted",
        );
        let generation = take_generation(
            &mut self.next_generation,
            "recognition mark generation space exhausted",
        );
        let state = Rc::new(RefCell::new(InvocationState {
            authority_id: self.authority_id,
            source_authority: Arc::clone(&self.source_authority),
            source_identity: self.source_identity.clone(),
            rule: rule.to_owned().into_boxed_str(),
            origin: origin.to_owned().into_boxed_str(),
            invocation,
            parent_invocation,
            generation,
            active: true,
            frame_state: state,
            active_token: None,
        }));
        self.invocation_stack.push(Rc::clone(&state));
        Ok(RecognitionInvocationFrame { state })
    }

    /// Return detached lineage for one live invocation frame.
    pub(crate) fn invocation_identity(
        &self,
        frame: &RecognitionInvocationFrame,
    ) -> Result<RecognitionInvocationIdentity, RecognitionTransactionError> {
        let frame = self.frame_for_authority(frame)?;
        let frame = frame.borrow();
        Ok(RecognitionInvocationIdentity {
            rule_label: frame.rule.to_string(),
            invocation_id: frame.invocation,
            parent_invocation_id: frame.parent_invocation,
        })
    }

    /// Reserve lineage for a recursion attempt rejected before frame entry.
    pub(crate) fn reserve_rejected_invocation(
        &mut self,
        rule: &str,
    ) -> RecognitionInvocationIdentity {
        let parent_invocation_id = self
            .invocation_stack
            .last()
            .map(|parent| parent.borrow().invocation);
        RecognitionInvocationIdentity {
            rule_label: rule.to_owned(),
            invocation_id: take_generation(
                &mut self.next_invocation,
                "recognition invocation identity space exhausted",
            ),
            parent_invocation_id,
        }
    }

    /// Leave the most recently entered invocation.
    pub fn leave_invocation(
        &mut self,
        frame: &RecognitionInvocationFrame,
    ) -> Result<(), RecognitionTransactionError> {
        let frame_state = self.frame_for_authority(frame)?;
        let is_stack_top = self
            .invocation_stack
            .last()
            .is_some_and(|candidate| Rc::ptr_eq(candidate, &frame_state));
        if !is_stack_top {
            let current = frame_state.borrow();
            let expected_invocation = self
                .invocation_stack
                .last()
                .map_or(current.invocation, |candidate| {
                    candidate.borrow().invocation
                });
            return Err(RecognitionTransactionError::new(
                "recognition_cross_invocation",
                [
                    ("rule", json!(current.rule.as_ref())),
                    ("origin", json!(current.origin.as_ref())),
                    ("expected_invocation", json!(expected_invocation)),
                    ("actual_invocation", json!(current.invocation)),
                ],
            ));
        }

        let active_token = frame_state
            .borrow()
            .active_token
            .as_ref()
            .and_then(Weak::upgrade);
        if let Some(token) = active_token.filter(token_is_active) {
            let (rule, origin) = {
                let token = token.borrow();
                (token.rule.clone(), token.origin.clone())
            };
            restore_and_invalidate(&token);
            self.invocation_stack.pop();
            frame_state.borrow_mut().active = false;
            return Err(RecognitionTransactionError::new(
                "recognition_terminal_required",
                [
                    ("rule", json!(rule.as_ref())),
                    ("origin", json!(origin.as_ref())),
                ],
            ));
        }

        self.invocation_stack.pop();
        frame_state.borrow_mut().active = false;
        Ok(())
    }

    /// Snapshot one live frame into a detached neutral value.
    pub fn frame_snapshot(
        &self,
        frame: &RecognitionInvocationFrame,
    ) -> Result<RecognitionFrameSnapshot, RecognitionTransactionError> {
        let frame = self.frame_for_authority(frame)?;
        let frame = frame.borrow();
        Ok(RecognitionFrameSnapshot {
            source: frame.source_identity.clone(),
            rule: frame.rule.clone(),
            invocation: frame.invocation,
            generation: frame.generation,
            state: frame.frame_state.clone(),
        })
    }

    /// Replace the live frame state from its owning runtime registers.
    pub(crate) fn set_frame_state(
        &mut self,
        frame: &RecognitionInvocationFrame,
        state: RecognitionFrameState,
    ) -> Result<(), RecognitionTransactionError> {
        let frame = self.frame_for_authority(frame)?;
        frame.borrow_mut().frame_state = state;
        Ok(())
    }

    /// Write one invocation-local named mark.
    pub fn write_mark(
        &mut self,
        frame: &RecognitionInvocationFrame,
        name: &str,
        offset: u64,
    ) -> Result<u64, RecognitionTransactionError> {
        let frame = self.frame_for_authority(frame)?;
        frame
            .borrow_mut()
            .frame_state
            .marks
            .insert(name.to_owned(), offset);
        Ok(offset)
    }

    /// Read one invocation-local named mark.
    pub fn read_mark(
        &self,
        frame: &RecognitionInvocationFrame,
        name: &str,
    ) -> Result<Option<u64>, RecognitionTransactionError> {
        let frame = self.frame_for_authority(frame)?;
        let result = frame.borrow().frame_state.marks.get(name).copied();
        Ok(result)
    }

    /// Create one linear transaction token over the current frame state.
    pub fn checkpoint(
        &mut self,
        frame: &RecognitionInvocationFrame,
        origin: &str,
    ) -> Result<RecognitionTransactionToken, RecognitionTransactionError> {
        let frame_state = self.frame_for_authority(frame)?;
        for stacked_frame in &self.invocation_stack {
            let active_token = stacked_frame
                .borrow()
                .active_token
                .as_ref()
                .and_then(Weak::upgrade);
            if let Some(active_token) = active_token.filter(token_is_active) {
                restore_and_invalidate(&active_token);
                let frame = frame_state.borrow();
                return Err(RecognitionTransactionError::new(
                    "recognition_nesting_forbidden",
                    [
                        ("rule", json!(frame.rule.as_ref())),
                        ("origin", json!(origin)),
                    ],
                ));
            }
        }

        let transaction = take_generation(
            &mut self.next_transaction,
            "recognition transaction identity space exhausted",
        );
        let token_state = Rc::new(RefCell::new({
            let frame = frame_state.borrow();
            TransactionState {
                authority_id: self.authority_id,
                source_authority: Arc::clone(&self.source_authority),
                source_identity: self.source_identity.clone(),
                rule: frame.rule.clone(),
                origin: origin.to_owned().into_boxed_str(),
                invocation: frame.invocation,
                generation: frame.generation,
                _transaction: transaction,
                status: TransactionStatus::ActiveUnattempted,
                attempt_count: 0,
                matched: false,
                payload_present: false,
                payload: None,
                snapshot: frame.frame_state.clone(),
                frame: Rc::downgrade(&frame_state),
            }
        }));
        frame_state.borrow_mut().active_token = Some(Rc::downgrade(&token_state));
        Ok(RecognitionTransactionToken { state: token_state })
    }

    /// Perform the token's one allowed attempt and stage its resulting frame state.
    pub fn attempt(
        &mut self,
        frame: &RecognitionInvocationFrame,
        token: &RecognitionTransactionToken,
        matched: bool,
        payload: Option<Value>,
        state: RecognitionFrameState,
    ) -> Result<bool, RecognitionTransactionError> {
        let frame_state = self.frame_for_authority(frame)?;
        let token_state = self.token_for_operation(&frame_state, token, "attempt")?;

        let (status, attempt_count, rule, origin) = {
            let token = token_state.borrow();
            (
                token.status,
                token.attempt_count,
                token.rule.clone(),
                token.origin.clone(),
            )
        };
        if status != TransactionStatus::ActiveUnattempted {
            let count = attempt_count
                .checked_add(1)
                .expect("recognition attempt count space exhausted");
            restore_and_invalidate(&token_state);
            return Err(RecognitionTransactionError::new(
                "recognition_attempt_count",
                [
                    ("rule", json!(rule.as_ref())),
                    ("origin", json!(origin.as_ref())),
                    ("count", json!(count)),
                ],
            ));
        }

        frame_state.borrow_mut().frame_state = state;
        let mut token = token_state.borrow_mut();
        token.attempt_count = 1;
        token.matched = matched;
        token.payload_present = matched && payload.is_some();
        token.payload = if matched { payload } else { None };
        token.status = if matched {
            TransactionStatus::ActiveStagedMatch
        } else {
            TransactionStatus::ActiveStagedMiss
        };
        Ok(matched)
    }

    /// Invalidate one attempted token and retain its staged frame state.
    pub fn commit(
        &mut self,
        frame: &RecognitionInvocationFrame,
        token: &RecognitionTransactionToken,
    ) -> Result<Option<Value>, RecognitionTransactionError> {
        let frame_state = self.frame_for_authority(frame)?;
        let token_state = self.token_for_operation(&frame_state, token, "commit")?;
        self.require_attempted(&token_state)?;
        let payload = {
            let token = token_state.borrow();
            if token.matched && token.payload_present {
                token.payload.clone()
            } else {
                None
            }
        };
        invalidate(&token_state);
        Ok(payload)
    }

    /// Restore one attempted token's snapshot, then invalidate it.
    pub fn rollback(
        &mut self,
        frame: &RecognitionInvocationFrame,
        token: &RecognitionTransactionToken,
    ) -> Result<(), RecognitionTransactionError> {
        let frame_state = self.frame_for_authority(frame)?;
        let token_state = self.token_for_operation(&frame_state, token, "rollback")?;
        self.require_attempted(&token_state)?;
        restore_and_invalidate(&token_state);
        Ok(())
    }

    /// Reject any attempt to make a token escape its authored linear slot.
    pub fn reject_escape(
        &mut self,
        frame: &RecognitionInvocationFrame,
        token: &RecognitionTransactionToken,
        escape: &str,
    ) -> Result<(), RecognitionTransactionError> {
        let frame_state = self.frame_for_authority(frame)?;
        let token_state = self.token_for_operation(&frame_state, token, "escape")?;
        let (rule, origin) = {
            let token = token_state.borrow();
            (token.rule.clone(), token.origin.clone())
        };
        restore_and_invalidate(&token_state);
        Err(RecognitionTransactionError::new(
            "recognition_token_escape",
            [
                ("rule", json!(rule.as_ref())),
                ("origin", json!(origin.as_ref())),
                ("escape", json!(escape)),
            ],
        ))
    }

    fn frame_for_authority(
        &self,
        frame: &RecognitionInvocationFrame,
    ) -> Result<Rc<RefCell<InvocationState>>, RecognitionTransactionError> {
        let frame_state = Rc::clone(&frame.state);
        let frame = frame_state.borrow();
        if frame.authority_id != self.authority_id || !frame.active {
            return Err(RecognitionTransactionError::new(
                "recognition_mark_generation_invalid",
                [
                    ("rule", json!(frame.rule.as_ref())),
                    ("origin", json!(frame.origin.as_ref())),
                    ("generation", json!(frame.generation)),
                ],
            ));
        }
        drop(frame);
        Ok(frame_state)
    }

    fn token_for_operation(
        &self,
        frame_state: &Rc<RefCell<InvocationState>>,
        token: &RecognitionTransactionToken,
        operation: &'static str,
    ) -> Result<Rc<RefCell<TransactionState>>, RecognitionTransactionError> {
        let token_state = Rc::clone(&token.state);
        let (frame_authority, frame_source, frame_source_identity, frame_rule, frame_origin) = {
            let frame = frame_state.borrow();
            (
                frame.authority_id,
                Arc::clone(&frame.source_authority),
                frame.source_identity.clone(),
                frame.rule.clone(),
                frame.origin.clone(),
            )
        };
        let (
            token_authority,
            token_source,
            token_source_identity,
            token_rule,
            token_origin,
            token_invocation,
            token_generation,
            token_status,
        ) = {
            let token = token_state.borrow();
            (
                token.authority_id,
                Arc::clone(&token.source_authority),
                token.source_identity.clone(),
                token.rule.clone(),
                token.origin.clone(),
                token.invocation,
                token.generation,
                token.status,
            )
        };

        if !Arc::ptr_eq(&frame_source, &token_source) {
            restore_and_invalidate(&token_state);
            return Err(RecognitionTransactionError::new(
                "recognition_cross_source",
                [
                    ("rule", json!(frame_rule.as_ref())),
                    ("origin", json!(frame_origin.as_ref())),
                    ("expected_source", json!(frame_source_identity.as_ref())),
                    ("actual_source", json!(token_source_identity.as_ref())),
                ],
            ));
        }

        let frame_invocation = frame_state.borrow().invocation;
        if token_authority != frame_authority || token_invocation != frame_invocation {
            restore_and_invalidate(&token_state);
            return Err(RecognitionTransactionError::new(
                "recognition_cross_invocation",
                [
                    ("rule", json!(frame_rule.as_ref())),
                    ("origin", json!(frame_origin.as_ref())),
                    ("expected_invocation", json!(frame_invocation)),
                    ("actual_invocation", json!(token_invocation)),
                ],
            ));
        }

        let (frame_active, frame_generation) = {
            let frame = frame_state.borrow();
            (frame.active, frame.generation)
        };
        if !frame_active || token_generation != frame_generation {
            restore_and_invalidate(&token_state);
            return Err(RecognitionTransactionError::new(
                "recognition_mark_generation_invalid",
                [
                    ("rule", json!(frame_rule.as_ref())),
                    ("origin", json!(frame_origin.as_ref())),
                    ("generation", json!(token_generation)),
                ],
            ));
        }

        if token_status == TransactionStatus::Invalidated {
            return Err(RecognitionTransactionError::new(
                "recognition_token_reused",
                [
                    ("rule", json!(token_rule.as_ref())),
                    ("origin", json!(token_origin.as_ref())),
                    ("operation", json!(operation)),
                ],
            ));
        }
        Ok(token_state)
    }

    fn require_attempted(
        &self,
        token_state: &Rc<RefCell<TransactionState>>,
    ) -> Result<(), RecognitionTransactionError> {
        let (status, count, rule, origin) = {
            let token = token_state.borrow();
            (
                token.status,
                token.attempt_count,
                token.rule.clone(),
                token.origin.clone(),
            )
        };
        if matches!(
            status,
            TransactionStatus::ActiveStagedMatch | TransactionStatus::ActiveStagedMiss
        ) {
            return Ok(());
        }
        restore_and_invalidate(token_state);
        Err(RecognitionTransactionError::new(
            "recognition_attempt_count",
            [
                ("rule", json!(rule.as_ref())),
                ("origin", json!(origin.as_ref())),
                ("count", json!(count)),
            ],
        ))
    }
}

const ALLOWED_EFFECTS: &[&str] = &[
    "pure_value",
    "source_read",
    "structured_control",
    "rule_recognition",
    "transaction_state",
    "cursor_advance",
    "capture_boundary_write",
    "invocation_mark_write",
    "staged_return",
];

const REJECTED_EFFECTS: &[&str] = &[
    "binding_write",
    "aggregate_write",
    "ast_or_object_write",
    "compatibility_cursor_control",
    "output",
    "authored_diagnostic",
    "exit_or_unbounded_control",
    "dynamic_callable",
    "parser_registry_or_staged_dispatch",
    "external_or_host",
    "unknown_or_raw",
];

/// Classify one neutral recognition-effect graph by recursive fixed point.
pub fn classify_recognition_effects(graph: &Value) -> Result<(), RecognitionTransactionError> {
    let entry = graph
        .get("entry")
        .and_then(Value::as_str)
        .unwrap_or("<entry>");
    let rules = graph
        .get("rules")
        .and_then(Value::as_object)
        .ok_or_else(|| effect_error("recognition_unknown_effect", entry, "unknown_or_raw"))?;
    let mut effects = BTreeMap::<String, std::collections::BTreeSet<String>>::new();
    let mut calls = BTreeMap::<String, Vec<String>>::new();

    for (rule, row) in rules {
        let base = row
            .get("base")
            .and_then(Value::as_array)
            .ok_or_else(|| effect_error("recognition_unknown_effect", rule, "unknown_or_raw"))?;
        let mut rule_effects = std::collections::BTreeSet::new();
        for effect in base {
            let effect = effect.as_str().unwrap_or("unknown_or_raw");
            if !ALLOWED_EFFECTS.contains(&effect) && !REJECTED_EFFECTS.contains(&effect) {
                return Err(effect_error("recognition_unknown_effect", rule, effect));
            }
            rule_effects.insert(effect.to_owned());
        }
        let callees = row
            .get("calls")
            .and_then(Value::as_array)
            .ok_or_else(|| effect_error("recognition_unknown_effect", rule, "unknown_or_raw"))?
            .iter()
            .map(|callee| callee.as_str().unwrap_or("<dynamic>").to_owned())
            .collect();
        effects.insert(rule.clone(), rule_effects);
        calls.insert(rule.clone(), callees);
    }

    let mut changed = true;
    while changed {
        changed = false;
        for (rule, callees) in &calls {
            let mut inherited = std::collections::BTreeSet::new();
            for callee in callees {
                match effects.get(callee) {
                    Some(callee_effects) => inherited.extend(callee_effects.iter().cloned()),
                    None => {
                        inherited.insert("unknown_or_raw".to_owned());
                    }
                }
            }
            let target = effects
                .get_mut(rule)
                .expect("effect rows and call rows share keys");
            let before = target.len();
            target.extend(inherited);
            changed |= target.len() != before;
        }
    }

    let entry_effects = effects
        .get(entry)
        .ok_or_else(|| effect_error("recognition_unknown_effect", entry, "unknown_or_raw"))?;
    if let Some(effect) = entry_effects
        .iter()
        .find(|effect| REJECTED_EFFECTS.contains(&effect.as_str()))
    {
        let code = if effect == "unknown_or_raw" {
            "recognition_unknown_effect"
        } else {
            "recognition_effect_forbidden"
        };
        return Err(effect_error(code, entry, effect));
    }
    Ok(())
}

fn effect_error(code: &'static str, rule: &str, effect: &str) -> RecognitionTransactionError {
    RecognitionTransactionError::new(
        code,
        [
            ("rule", json!(rule)),
            ("origin", json!(format!("{rule}:recognize_once"))),
            ("effect", json!(effect)),
        ],
    )
}

/// Enforce cursor-only progress for accepted repetition and recursive edges.
pub fn validate_recognition_progress(fixture: &Value) -> Result<(), RecognitionTransactionError> {
    let context = fixture
        .get("context")
        .and_then(Value::as_str)
        .unwrap_or("unknown");
    let start = fixture.get("start").and_then(Value::as_u64).unwrap_or(0);
    let end = fixture.get("end").and_then(Value::as_u64).unwrap_or(0);
    if end > start || context == "one_shot" {
        return Ok(());
    }

    let rule = fixture
        .get("id")
        .and_then(Value::as_str)
        .unwrap_or("<rule>");
    let code = if context == "accepted_repetition_iteration" {
        "recognition_zero_progress_repetition"
    } else {
        "recognition_zero_progress_recursive_cycle"
    };
    let mut fields = vec![
        ("rule", json!(rule)),
        ("origin", json!(format!("{rule}:recognize_once"))),
    ];
    if code == "recognition_zero_progress_recursive_cycle" {
        fields.push(("cycle", json!(context)));
    }
    fields.push(("start_offset", json!(start)));
    fields.push(("end_offset", json!(end)));
    Err(RecognitionTransactionError::new(code, fields))
}

#[derive(Clone)]
pub(crate) struct RecognitionRuntime {
    state: Rc<RefCell<RecognitionRuntimeState>>,
}

impl fmt::Debug for RecognitionRuntime {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        formatter.write_str("RecognitionRuntime(<opaque>)")
    }
}

struct RecognitionRuntimeState {
    authority: RecognitionTransactionAuthority,
    frames: Vec<RecognitionLiveFrame>,
}

/// Detached structural identity carried from one selected action edge into the
/// target invocation. The owner id prevents a nested or unrelated invocation
/// from observing a stale parent edge.
#[derive(Debug, Clone, PartialEq, Eq)]
pub(crate) struct GapEntrySlot {
    pub(crate) owner_invocation_id: u64,
    pub(crate) target_rule: String,
    pub(crate) regex_index: usize,
    pub(crate) slot_id: Option<String>,
    pub(crate) selector_kind: String,
    pub(crate) authored_selector: Option<Value>,
}

/// Byte-rooted private candidate. Runtime projection converts these boundaries
/// through the parse-local `SourceAuthority`, so authored values expose decoded
/// Unicode-scalar offsets rather than host byte offsets.
#[derive(Debug, Clone, PartialEq, Eq)]
pub(crate) struct GapContext {
    pub(crate) source_id: String,
    pub(crate) rule_label: String,
    pub(crate) invocation_id: u64,
    pub(crate) edge_ordinal: u64,
    pub(crate) kind: &'static str,
    pub(crate) start_byte: u64,
    pub(crate) end_byte: u64,
}

#[derive(Debug, Clone, PartialEq, Eq)]
struct GapMutableState {
    committed_gap_cursor: u64,
    accepted_edge_count: u64,
    current_gap: Option<GapContext>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
struct GapInvocationState {
    source_id: String,
    invocation_id: u64,
    mutable: GapMutableState,
}

/// Private typed diagnostic for a gap read outside a live candidate or tail.
#[derive(Debug, Clone, PartialEq, Eq)]
pub(crate) struct InterMatchGapError {
    record: Value,
}

impl InterMatchGapError {
    fn unavailable(
        rule_label: &str,
        source_id: &str,
        invocation_id: u64,
        phase: &str,
        accessor: &str,
    ) -> Self {
        Self {
            record: json!({
                "code": "gap_capture_context_unavailable",
                "rule_label": rule_label,
                "source_id": source_id,
                "invocation_id": invocation_id,
                "phase": phase,
                "accessor": accessor,
            }),
        }
    }

    pub(crate) fn as_record(&self) -> Value {
        self.record.clone()
    }
}

impl fmt::Display for InterMatchGapError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        let code = self
            .as_record()
            .get("code")
            .and_then(Value::as_str)
            .unwrap_or("inter_match_gap_error")
            .to_owned();
        write!(formatter, "LINKEDSPEC_INTER_MATCH_GAP_ERROR:{code}")
    }
}

impl std::error::Error for InterMatchGapError {}

#[derive(Debug, Clone, PartialEq, Eq)]
pub(crate) struct GapCursorRegressionError {
    record: Value,
}

impl GapCursorRegressionError {
    fn new(rule: &str, source_id: &str, selected_end: u64, cursor: u64) -> Self {
        Self {
            record: json!({
                "code": "source_location_cursor_regression",
                "phase": "advance",
                "rule_role": rule,
                "invocation_role": "gap_owner",
                "source_id": source_id,
                "start_offset": selected_end,
                "end_offset": cursor,
                "originating_edge_or_job": format!("{rule}:capture_gaps_commit"),
            }),
        }
    }

    pub(crate) fn as_record(&self) -> Value {
        self.record.clone()
    }
}

impl fmt::Display for GapCursorRegressionError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        let code = self
            .as_record()
            .get("code")
            .and_then(Value::as_str)
            .unwrap_or("source_location_error")
            .to_owned();
        write!(formatter, "LINKEDSPEC_SOURCE_LOCATION_ERROR:{code}")
    }
}

impl std::error::Error for GapCursorRegressionError {}

struct RecognitionLiveFrame {
    rule: String,
    frame: RecognitionInvocationFrame,
    tokens: BTreeMap<String, RecognitionLiveToken>,
    accepted: bool,
    identity: RecognitionInvocationIdentity,
    entry_cursor: u64,
    selected_match: Option<(u64, u64)>,
    prior_marks: Option<std::collections::HashMap<String, usize>>,
    gap: Option<GapInvocationState>,
    gap_phase: String,
    entry_slot: Option<GapEntrySlot>,
}

struct RecognitionLiveToken {
    token: RecognitionTransactionToken,
    snapshot: RecognitionFrameState,
    gap_snapshot: Option<GapMutableState>,
}

pub(crate) struct RecognitionInvocationExit {
    pub(crate) state: RecognitionFrameState,
    pub(crate) accepted: bool,
    pub(crate) identity: RecognitionInvocationIdentity,
    pub(crate) entry_cursor: u64,
    pub(crate) selected_match: Option<(u64, u64)>,
    pub(crate) prior_marks: Option<std::collections::HashMap<String, usize>>,
}

impl RecognitionRuntime {
    pub(crate) fn new(source_authority: Arc<SourceAuthority>, source_identity: &str) -> Self {
        Self {
            state: Rc::new(RefCell::new(RecognitionRuntimeState {
                authority: RecognitionTransactionAuthority::new(source_authority, source_identity),
                frames: Vec::new(),
            })),
        }
    }

    pub(crate) fn enter(
        &self,
        rule: &str,
        state: RecognitionFrameState,
        prior_marks: Option<std::collections::HashMap<String, usize>>,
        capture_gaps: bool,
        entry_slot: Option<GapEntrySlot>,
    ) -> Result<(), RecognitionTransactionError> {
        let mut runtime = self.state.borrow_mut();
        let entry_cursor = state.cursor();
        let frame =
            runtime
                .authority
                .enter_invocation(rule, &format!("{rule}:handler_entry"), state)?;
        let identity = runtime.authority.invocation_identity(&frame)?;
        let entry_slot = entry_slot.filter(|slot| {
            runtime.frames.last().is_some_and(|parent| {
                parent.identity.invocation_id == slot.owner_invocation_id
                    && parent
                        .gap
                        .as_ref()
                        .and_then(|gap| gap.mutable.current_gap.as_ref())
                        .is_some()
                    && slot.target_rule == rule
            })
        });
        let gap = capture_gaps.then(|| GapInvocationState {
            source_id: runtime.authority.source_identity.to_string(),
            invocation_id: identity.invocation_id,
            mutable: GapMutableState {
                committed_gap_cursor: entry_cursor,
                accepted_edge_count: 0,
                current_gap: None,
            },
        });
        runtime.frames.push(RecognitionLiveFrame {
            rule: rule.to_owned(),
            frame,
            tokens: BTreeMap::new(),
            accepted: false,
            identity,
            entry_cursor,
            selected_match: None,
            prior_marks,
            gap,
            gap_phase: "I".to_owned(),
            entry_slot,
        });
        Ok(())
    }

    pub(crate) fn note_match(&self, start: u64, end: u64) {
        if let Some(frame) = self.state.borrow_mut().frames.last_mut() {
            frame.accepted = true;
            frame.selected_match = Some((start, end));
        }
    }

    pub(crate) fn reserve_rejected_invocation(&self, rule: &str) -> RecognitionInvocationIdentity {
        self.state
            .borrow_mut()
            .authority
            .reserve_rejected_invocation(rule)
    }

    pub(crate) fn checkpoint(
        &self,
        slot: &str,
        actual: RecognitionFrameState,
    ) -> Result<(), RecognitionTransactionError> {
        let mut runtime = self.state.borrow_mut();
        let RecognitionRuntimeState { authority, frames } = &mut *runtime;
        let frame = frames.last_mut().expect("recognition invocation is active");
        authority.set_frame_state(&frame.frame, actual.clone())?;
        let token = authority.checkpoint(&frame.frame, &format!("{}:{slot}", frame.rule))?;
        let gap_snapshot = frame.gap.as_ref().map(|gap| gap.mutable.clone());
        frame.tokens.insert(
            slot.to_owned(),
            RecognitionLiveToken {
                token,
                snapshot: actual,
                gap_snapshot,
            },
        );
        Ok(())
    }

    pub(crate) fn attempt(
        &self,
        slot: &str,
        matched: bool,
        payload: Option<Value>,
        actual: RecognitionFrameState,
    ) -> Result<bool, RecognitionTransactionError> {
        let mut runtime = self.state.borrow_mut();
        let RecognitionRuntimeState { authority, frames } = &mut *runtime;
        let frame = frames.last_mut().expect("recognition invocation is active");
        let token = frame.tokens.get(slot).ok_or_else(|| {
            RecognitionTransactionError::new(
                "recognition_token_expected",
                [
                    ("rule", json!(frame.rule)),
                    ("origin", json!(format!("{}:recognize_once", frame.rule))),
                ],
            )
        })?;
        authority.attempt(&frame.frame, &token.token, matched, payload, actual)
    }

    pub(crate) fn commit(
        &self,
        slot: &str,
        actual: RecognitionFrameState,
    ) -> Result<Option<Value>, RecognitionTransactionError> {
        let mut runtime = self.state.borrow_mut();
        let RecognitionRuntimeState { authority, frames } = &mut *runtime;
        let frame = frames.last_mut().expect("recognition invocation is active");
        authority.set_frame_state(&frame.frame, actual)?;
        let token = frame.tokens.remove(slot).ok_or_else(|| {
            RecognitionTransactionError::new(
                "recognition_token_expected",
                [
                    ("rule", json!(frame.rule)),
                    (
                        "origin",
                        json!(format!("{}:recognition_commit", frame.rule)),
                    ),
                ],
            )
        })?;
        authority.commit(&frame.frame, &token.token)
    }

    pub(crate) fn rollback(
        &self,
        slot: &str,
        actual: RecognitionFrameState,
    ) -> Result<RecognitionFrameState, RecognitionTransactionError> {
        let mut runtime = self.state.borrow_mut();
        let RecognitionRuntimeState { authority, frames } = &mut *runtime;
        let frame = frames.last_mut().expect("recognition invocation is active");
        authority.set_frame_state(&frame.frame, actual)?;
        let token = frame.tokens.remove(slot).ok_or_else(|| {
            RecognitionTransactionError::new(
                "recognition_token_expected",
                [
                    ("rule", json!(frame.rule)),
                    (
                        "origin",
                        json!(format!("{}:recognition_rollback", frame.rule)),
                    ),
                ],
            )
        })?;
        authority.rollback(&frame.frame, &token.token)?;
        if let (Some(gap), Some(snapshot)) = (&mut frame.gap, token.gap_snapshot) {
            gap.mutable = snapshot;
        }
        authority
            .frame_snapshot(&frame.frame)
            .map(|snapshot| snapshot.state())
    }

    pub(crate) fn leave(
        &self,
        actual: RecognitionFrameState,
    ) -> (
        RecognitionInvocationExit,
        Result<(), RecognitionTransactionError>,
    ) {
        let mut runtime = self.state.borrow_mut();
        let RecognitionRuntimeState { authority, frames } = &mut *runtime;
        let mut frame = frames.pop().expect("recognition invocation is active");
        let sync_result = authority.set_frame_state(&frame.frame, actual.clone());
        let restored = frame
            .tokens
            .values()
            .next()
            .map(|token| token.snapshot.clone())
            .unwrap_or(actual);
        let result = match sync_result {
            Ok(()) => authority.leave_invocation(&frame.frame),
            Err(error) => {
                let _ = authority.leave_invocation(&frame.frame);
                Err(error)
            }
        };
        let exit = RecognitionInvocationExit {
            state: restored,
            accepted: frame.accepted,
            identity: frame.identity,
            entry_cursor: frame.entry_cursor,
            selected_match: frame.selected_match,
            prior_marks: frame.prior_marks.take(),
        };
        (exit, result)
    }

    pub(crate) fn set_gap_phase(&self, phase: &str) {
        if let Some(frame) = self.state.borrow_mut().frames.last_mut() {
            frame.gap_phase = phase.to_owned();
        }
    }

    pub(crate) fn install_gap_candidate(&self, match_start: u64) {
        let mut runtime = self.state.borrow_mut();
        let Some(frame) = runtime.frames.last_mut() else {
            return;
        };
        let Some(gap) = frame.gap.as_mut() else {
            return;
        };
        let kind = if gap.mutable.accepted_edge_count == 0 {
            "prefix"
        } else {
            "interstitial"
        };
        gap.mutable.current_gap = Some(GapContext {
            source_id: gap.source_id.clone(),
            rule_label: frame.rule.clone(),
            invocation_id: gap.invocation_id,
            edge_ordinal: gap.mutable.accepted_edge_count,
            kind,
            start_byte: gap.mutable.committed_gap_cursor,
            end_byte: match_start,
        });
        frame.gap_phase = "selection".to_owned();
    }

    pub(crate) fn commit_gap_candidate(&self, cursor: u64) -> Result<(), GapCursorRegressionError> {
        let mut runtime = self.state.borrow_mut();
        let Some(frame) = runtime.frames.last_mut() else {
            return Ok(());
        };
        let Some(gap) = frame.gap.as_mut() else {
            return Ok(());
        };
        let Some(current) = gap.mutable.current_gap.as_ref() else {
            return Ok(());
        };
        let selected_end = frame
            .selected_match
            .map(|(_, end)| end)
            .unwrap_or(current.end_byte);
        if cursor < selected_end {
            return Err(GapCursorRegressionError::new(
                &frame.rule,
                &current.source_id,
                selected_end,
                cursor,
            ));
        }
        gap.mutable.committed_gap_cursor = cursor;
        gap.mutable.accepted_edge_count += 1;
        gap.mutable.current_gap = None;
        frame.gap_phase = "post_commit".to_owned();
        Ok(())
    }

    pub(crate) fn install_gap_tail(&self, input_end: u64, phase: &str) {
        let mut runtime = self.state.borrow_mut();
        let Some(frame) = runtime.frames.last_mut() else {
            return;
        };
        let Some(gap) = frame.gap.as_mut() else {
            return;
        };
        gap.mutable.current_gap = Some(GapContext {
            source_id: gap.source_id.clone(),
            rule_label: frame.rule.clone(),
            invocation_id: gap.invocation_id,
            edge_ordinal: gap.mutable.accepted_edge_count,
            kind: "tail",
            start_byte: gap.mutable.committed_gap_cursor,
            end_byte: input_end,
        });
        frame.gap_phase = phase.to_owned();
    }

    pub(crate) fn current_gap(&self, accessor: &str) -> Result<GapContext, InterMatchGapError> {
        let runtime = self.state.borrow();
        let frame = runtime
            .frames
            .last()
            .expect("gap accessor requires an active recognition invocation");
        if let Some(current) = frame
            .gap
            .as_ref()
            .and_then(|gap| gap.mutable.current_gap.as_ref())
        {
            return Ok(current.clone());
        }
        let (source_id, invocation_id) = frame
            .gap
            .as_ref()
            .map(|gap| (gap.source_id.as_str(), gap.invocation_id))
            .unwrap_or_else(|| {
                (
                    runtime.authority.source_identity.as_ref(),
                    frame.identity.invocation_id,
                )
            });
        Err(InterMatchGapError::unavailable(
            &frame.rule,
            source_id,
            invocation_id,
            &frame.gap_phase,
            accessor,
        ))
    }

    pub(crate) fn entry_slot(&self) -> Option<GapEntrySlot> {
        self.state
            .borrow()
            .frames
            .last()
            .and_then(|frame| frame.entry_slot.clone())
    }

    pub(crate) fn gap_entry_slot(
        &self,
        target_rule: &str,
        regex_index: usize,
        slot_id: Option<&str>,
        selector_kind: &str,
        authored_selector: Option<Value>,
    ) -> Option<GapEntrySlot> {
        let runtime = self.state.borrow();
        let frame = runtime.frames.last()?;
        frame.gap.as_ref()?.mutable.current_gap.as_ref()?;
        Some(GapEntrySlot {
            owner_invocation_id: frame.identity.invocation_id,
            target_rule: target_rule.to_owned(),
            regex_index,
            slot_id: slot_id.map(str::to_owned),
            selector_kind: selector_kind.to_owned(),
            authored_selector,
        })
    }
}

impl Drop for RecognitionTransactionAuthority {
    fn drop(&mut self) {
        for frame in &self.invocation_stack {
            let active_token = frame.borrow().active_token.as_ref().and_then(Weak::upgrade);
            if let Some(token) = active_token.filter(token_is_active) {
                restore_and_invalidate(&token);
            }
            frame.borrow_mut().active = false;
        }
    }
}

impl Drop for RecognitionTransactionToken {
    fn drop(&mut self) {
        if token_is_active(&self.state) {
            restore_and_invalidate(&self.state);
        }
    }
}

fn token_is_active(token: &Rc<RefCell<TransactionState>>) -> bool {
    token.borrow().status != TransactionStatus::Invalidated
}

fn restore_and_invalidate(token: &Rc<RefCell<TransactionState>>) {
    let (status, frame, snapshot) = {
        let token = token.borrow();
        (token.status, token.frame.upgrade(), token.snapshot.clone())
    };
    if status == TransactionStatus::Invalidated {
        return;
    }
    if let Some(frame) = frame {
        let mut frame = frame.borrow_mut();
        if frame.active {
            frame.frame_state = snapshot;
        }
        frame.active_token = None;
    }
    let mut token = token.borrow_mut();
    token.status = TransactionStatus::Invalidated;
    token.payload_present = false;
    token.payload = None;
}

fn invalidate(token: &Rc<RefCell<TransactionState>>) {
    let (status, frame) = {
        let token = token.borrow();
        (token.status, token.frame.upgrade())
    };
    if status == TransactionStatus::Invalidated {
        return;
    }
    if let Some(frame) = frame {
        frame.borrow_mut().active_token = None;
    }
    let mut token = token.borrow_mut();
    token.status = TransactionStatus::Invalidated;
    token.payload_present = false;
    token.payload = None;
}

fn take_generation(next: &mut u64, exhaustion_message: &'static str) -> u64 {
    let current = *next;
    *next = current.checked_add(1).expect(exhaustion_message);
    current
}

#[cfg(test)]
mod gap_tests {
    use super::*;

    fn runtime(input: &str) -> RecognitionRuntime {
        let sources = BTreeMap::from([("input".to_owned(), input.to_owned())]);
        RecognitionRuntime::new(Arc::new(SourceAuthority::new(&sources)), "input")
    }

    fn state(cursor: u64) -> RecognitionFrameState {
        RecognitionFrameState::new(cursor, None, BTreeMap::new())
    }

    #[test]
    fn unavailable_gap_error_retains_every_private_context_field() {
        let runtime = runtime("H");
        runtime
            .enter("Top", state(0), None, false, None)
            .expect("enter ordinary invocation");
        let error = runtime
            .current_gap("gap_text")
            .expect_err("ordinary invocation has no gap candidate");
        assert_eq!(
            error.as_record(),
            json!({
                "code":"gap_capture_context_unavailable",
                "rule_label":"Top",
                "source_id":"input",
                "invocation_id":1,
                "phase":"I",
                "accessor":"gap_text",
            }),
        );
    }

    #[test]
    fn checkpoint_rollback_restores_only_the_private_mutable_gap_snapshot() {
        let runtime = runtime("aH!");
        runtime
            .enter("Top", state(0), None, true, None)
            .expect("enter gap invocation");
        runtime.note_match(1, 2);
        runtime.install_gap_candidate(1);
        runtime
            .checkpoint("tx", state(2))
            .expect("checkpoint gap candidate");
        runtime
            .attempt("tx", true, Some(json!(false)), state(3))
            .expect("stage recognition attempt");
        runtime
            .commit_gap_candidate(3)
            .expect("advance private gap state before rollback");
        assert!(runtime.current_gap("gap_text").is_err());
        let restored = runtime
            .rollback("tx", state(3))
            .expect("rollback recognition and gap snapshot");
        assert_eq!(
            restored.as_record(),
            json!({"cursor":2,"boundary":null,"marks":{}})
        );
        let gap = runtime
            .current_gap("gap_text")
            .expect("candidate restored by rollback");
        assert_eq!(gap.kind, "prefix");
        assert_eq!((gap.start_byte, gap.end_byte, gap.edge_ordinal), (0, 1, 0));
    }

    #[test]
    fn gap_cursor_regression_is_a_typed_source_error() {
        let runtime = runtime("aH");
        runtime
            .enter("Top", state(0), None, true, None)
            .expect("enter gap invocation");
        runtime.note_match(1, 2);
        runtime.install_gap_candidate(1);
        let error = runtime
            .commit_gap_candidate(1)
            .expect_err("cursor before selected match end must reject");
        assert_eq!(
            error.as_record(),
            json!({
                "code":"source_location_cursor_regression",
                "phase":"advance",
                "rule_role":"Top",
                "invocation_role":"gap_owner",
                "source_id":"input",
                "start_offset":2,
                "end_offset":1,
                "originating_edge_or_job":"Top:capture_gaps_commit",
            }),
        );
    }
}
