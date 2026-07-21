//! LinkedSpec runtime — handler execution engine, helpers, and lifecycle interpreter.
//!
//! This crate provides:
//! - An interpreted runtime engine that executes compiled rule specifications
//! - A regex dispatch engine with seek/consume modes
//! - Helper function dispatch for lifecycle code execution
//! - Variable store (working variables and assignment with scoping)
//!
//! The Perl reference implementation lives at `perl/LinkedSpec.pm`.
//! The Rust implementation is idiomatic Rust — no code generation, no eval.

pub mod diagnostic;
pub mod diagnostic_output;
pub mod engine;
pub mod helpers;
pub mod primary_cli;
pub mod runtime;
pub mod semantic_index;
pub mod semantic_observation;
pub mod source_emitter;
pub mod spec_loader;
pub mod spec_parser;
pub mod staged_parser_registry;
pub mod unicode_case_mapping;

pub use diagnostic::{RuntimeDiagnostic, RuntimeExecutionError};
pub use diagnostic_output::{
    RuntimeDiagnosticOutputEvent, RuntimeDiagnosticOutputExecutionError,
    RuntimeDiagnosticOutputSink, RuntimeDiagnosticOutputSinkFailure, RuntimeExitNow,
};
pub use linkedspec_core::trace;
pub use semantic_observation::{
    RUNTIME_SEMANTIC_OBSERVATION_CONTRACT, RuntimeSemanticObservationEvent,
    RuntimeSemanticObservationEventKind, RuntimeSemanticObservationSink,
};

/// Crate version, matching the workspace version.
pub const VERSION: &str = env!("CARGO_PKG_VERSION");
