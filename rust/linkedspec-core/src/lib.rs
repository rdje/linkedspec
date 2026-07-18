//! LinkedSpec core — `.spec` parser, compiler, and expression types.
//!
//! This crate provides:
//! - AST types for `.spec` files
//! - A `.spec` parser that reads grammar files into structured AST
//! - A compiler that transforms AST into executable rule specifications
//! - Expression AST types and parser for lifecycle code
//! - Validation of parsed specifications
//!
//! The Perl reference implementation lives at `perl/LinkedSpec.pm`.
//! The Rust implementation is idiomatic Rust — it does NOT mimic Perl internals.

pub mod ast;
pub mod compiler;
pub mod descriptor;
pub mod entry_rule;
pub mod error;
pub mod expr;
pub mod parser;
pub mod trace;
pub mod types;
pub mod validation;

/// Crate version, matching the workspace version.
pub const VERSION: &str = env!("CARGO_PKG_VERSION");
