//! Caller-owned diagnostic-output events for native Rust execution.

use crate::RuntimeExecutionError;
use serde::{Deserialize, Serialize};
use std::cell::RefCell;
use std::error::Error;
use std::fmt;
use std::rc::Rc;

/// One parser-authored diagnostic-output event.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct RuntimeDiagnosticOutputEvent {
    /// Canonical helper name (`print`, `say`, or `print_each`).
    pub helper_name: String,
    /// Rule whose action invoked the helper.
    pub rule_label: String,
    /// Exact Unicode message text for this call or item.
    pub message: String,
}

/// An unchanged error value returned by a caller's diagnostic-output sink.
pub type RuntimeDiagnosticOutputSinkFailure = Rc<dyn Error + 'static>;

type SinkCallback =
    dyn FnMut(RuntimeDiagnosticOutputEvent) -> Result<(), RuntimeDiagnosticOutputSinkFailure>;

/// Caller-owned handle installed for one native execution.
///
/// Cloning the handle retains the same callback. The engine clones it only into
/// the invocation-local runtime context, so installing a sink never mutates the
/// compiled specification or another parse.
#[derive(Clone)]
pub struct RuntimeDiagnosticOutputSink {
    callback: Rc<RefCell<Box<SinkCallback>>>,
}

impl RuntimeDiagnosticOutputSink {
    /// Wrap a fallible typed-event callback in a caller-owned sink handle.
    pub fn new<F, E>(mut callback: F) -> Self
    where
        F: FnMut(RuntimeDiagnosticOutputEvent) -> Result<(), E> + 'static,
        E: Error + 'static,
    {
        let callback = move |event| {
            callback(event).map_err(|error| Rc::new(error) as Rc<dyn std::error::Error + 'static>)
        };
        Self {
            callback: Rc::new(RefCell::new(Box::new(callback))),
        }
    }

    pub(crate) fn emit(
        &self,
        event: RuntimeDiagnosticOutputEvent,
    ) -> Result<(), RuntimeDiagnosticOutputSinkFailure> {
        (self.callback.borrow_mut())(event)
    }
}

impl fmt::Debug for RuntimeDiagnosticOutputSink {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        formatter
            .debug_struct("RuntimeDiagnosticOutputSink")
            .finish_non_exhaustive()
    }
}

/// Typed immediate control outcome raised by `exit_now(status)`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub struct RuntimeExitNow {
    /// Requested process-independent exit status.
    pub status: i32,
}

impl fmt::Display for RuntimeExitNow {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(formatter, "exit_now({})", self.status)
    }
}

impl Error for RuntimeExitNow {}

/// Result error for native execution with diagnostic-output delivery enabled.
#[derive(Debug, Clone)]
pub enum RuntimeDiagnosticOutputExecutionError {
    /// Ordinary runtime failure with the existing structured diagnostic.
    Runtime(RuntimeExecutionError),
    /// The exact error payload returned synchronously by the caller's sink.
    Sink(RuntimeDiagnosticOutputSinkFailure),
    /// Immediate parser control requested by `exit_now(status)`.
    Exit(RuntimeExitNow),
}

impl fmt::Display for RuntimeDiagnosticOutputExecutionError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Runtime(error) => error.fmt(formatter),
            Self::Sink(error) => error.fmt(formatter),
            Self::Exit(exit) => exit.fmt(formatter),
        }
    }
}

impl Error for RuntimeDiagnosticOutputExecutionError {
    fn source(&self) -> Option<&(dyn Error + 'static)> {
        match self {
            Self::Runtime(error) => Some(error),
            Self::Sink(error) => Some(error.as_ref()),
            Self::Exit(exit) => Some(exit),
        }
    }
}
