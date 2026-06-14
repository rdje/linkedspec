//! LinkedSpec runtime — handler execution engine, helpers, and lifecycle interpreter.
//!
//! This crate provides:
//! - An interpreted runtime engine that executes compiled rule specifications
//! - A regex dispatch engine with seek/consume modes
//! - Helper function dispatch for lifecycle code execution
//! - Variable store (declare/assign with scoping)
//!
//! The Perl reference implementation lives at `perl/LinkedSpec.pm`.
//! The Rust implementation is idiomatic Rust — no code generation, no eval.

pub mod engine;
pub mod helpers;
pub mod runtime;

/// Crate version, matching the workspace version.
pub const VERSION: &str = env!("CARGO_PKG_VERSION");
