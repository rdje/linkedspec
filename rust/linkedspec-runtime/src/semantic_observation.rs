//! Invocation-local typed semantic observations for native Rust execution.

use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::cell::RefCell;
use std::fmt;
use std::fmt::Write;
use std::rc::Rc;

/// Versioned identity carried by every native semantic observation event.
pub const RUNTIME_SEMANTIC_OBSERVATION_CONTRACT: &str =
    "linkedspec-semantic-execution-observation-v1";

/// Closed event vocabulary captured by the v1 Rust runtime observer.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum RuntimeSemanticObservationEventKind {
    RegexSlotSelected,
    RuleResult,
}

/// One clone-safe native event delivered during normal parser execution.
///
/// Fields remain public so callers can persist the typed observation. The
/// semantic index validates the complete schema and topology before accepting
/// any caller-retained event sequence.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct RuntimeSemanticObservationEvent {
    /// Versioned schema identity for this event.
    pub contract_id: String,
    /// Closed semantic event kind.
    pub event_kind: RuntimeSemanticObservationEventKind,
    /// Rule executing at the observation seam.
    pub rule_label: String,
    /// Authored rule that owns a selected regex slot, for slot events only.
    pub target_rule: Option<String>,
    /// Zero-based regex slot index within `target_rule`, for slot events only.
    pub regex_index: Option<usize>,
    /// Unicode-scalar cursor position immediately after selection or completion.
    pub position: usize,
    /// SHA-256 identity of the exact UTF-8 input bytes, for result events only.
    pub input_identity: Option<String>,
    /// Stable completion status, for result events only.
    pub status: Option<String>,
}

impl RuntimeSemanticObservationEvent {
    pub(crate) fn regex_slot_selected(
        rule_label: &str,
        target_rule: &str,
        regex_index: usize,
        position: usize,
    ) -> Self {
        Self {
            contract_id: RUNTIME_SEMANTIC_OBSERVATION_CONTRACT.to_string(),
            event_kind: RuntimeSemanticObservationEventKind::RegexSlotSelected,
            rule_label: rule_label.to_string(),
            target_rule: Some(target_rule.to_string()),
            regex_index: Some(regex_index),
            position,
            input_identity: None,
            status: None,
        }
    }

    pub(crate) fn rule_result(rule_label: &str, position: usize, input: &str) -> Self {
        Self {
            contract_id: RUNTIME_SEMANTIC_OBSERVATION_CONTRACT.to_string(),
            event_kind: RuntimeSemanticObservationEventKind::RuleResult,
            rule_label: rule_label.to_string(),
            target_rule: None,
            regex_index: None,
            position,
            input_identity: Some(input_identity(input)),
            status: Some("succeeded".to_string()),
        }
    }
}

type SinkCallback = dyn FnMut(RuntimeSemanticObservationEvent);

/// Caller-owned handle installed into one execution through `ExecutionOptions`.
///
/// Clones share the same callback, which lets the caller retain one handle while
/// the invocation-local runtime context owns another. The callback is
/// deliberately infallible: a caller panic unwinds unchanged and is never
/// translated into a parser, trace, or diagnostic failure.
#[derive(Clone)]
pub struct RuntimeSemanticObservationSink {
    callback: Rc<RefCell<Box<SinkCallback>>>,
}

impl RuntimeSemanticObservationSink {
    /// Wrap a typed synchronous event callback.
    pub fn new<F>(callback: F) -> Self
    where
        F: FnMut(RuntimeSemanticObservationEvent) + 'static,
    {
        Self {
            callback: Rc::new(RefCell::new(Box::new(callback))),
        }
    }

    pub(crate) fn emit(&self, event: RuntimeSemanticObservationEvent) {
        (self.callback.borrow_mut())(event);
    }
}

impl fmt::Debug for RuntimeSemanticObservationSink {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        formatter
            .debug_struct("RuntimeSemanticObservationSink")
            .finish_non_exhaustive()
    }
}

impl PartialEq for RuntimeSemanticObservationSink {
    fn eq(&self, other: &Self) -> bool {
        Rc::ptr_eq(&self.callback, &other.callback)
    }
}

impl Eq for RuntimeSemanticObservationSink {}

fn input_identity(input: &str) -> String {
    let digest = Sha256::digest(input.as_bytes());
    let mut identity = String::with_capacity("input:sha256:".len() + digest.len() * 2);
    identity.push_str("input:sha256:");
    for byte in digest {
        write!(&mut identity, "{byte:02x}").expect("writing to String cannot fail");
    }
    identity
}
