//! Private recognition-invocation frames and linear transaction tokens.
//!
//! This authority is intentionally available only to the dormant transaction
//! contract. Authored lowering and runtime admission remain separately owned.

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
            generation,
            active: true,
            frame_state: state,
            active_token: None,
        }));
        self.invocation_stack.push(Rc::clone(&state));
        Ok(RecognitionInvocationFrame { state })
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
