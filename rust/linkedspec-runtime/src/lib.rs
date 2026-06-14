//! LinkedSpec runtime — handler execution engine, helpers, and lifecycle interpreter.
//!
//! This crate provides:
//! - A runtime engine that executes compiled HandlerIR nodes
//! - Helper function implementations (100+ helpers across 10 families)
//! - Lifecycle execution (I/LS/LE/E/EX/IT/LX)
//! - Variable store (declare/assign with scoping)
//! - Regex engine integration
//!
//! The Perl reference implementation lives at `perl/LinkedSpec.pm`.
//! Specification documents live under `docs/linkedspec-book/src/appendix/`.

pub mod engine;
pub mod helpers;
pub mod runtime;

/// Crate version, matching the workspace version.
pub const VERSION: &str = env!("CARGO_PKG_VERSION");
