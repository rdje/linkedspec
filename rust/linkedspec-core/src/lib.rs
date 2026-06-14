//! LinkedSpec core — .spec parser, compiler, and HandlerIR types.
//!
//! This crate provides:
//! - Core types and AST definitions for `.spec` files
//! - A `.spec` parser that reads grammar files into structured AST
//! - A compiler that transforms parsed AST into HandlerIR
//! - HandlerIR node definitions (shared with the runtime crate)
//!
//! The Perl reference implementation lives at `perl/LinkedSpec.pm`.
//! Specification documents live under `docs/linkedspec-book/src/appendix/`.

pub mod ast;
pub mod compiler;
pub mod error;
pub mod parser;
pub mod types;
pub mod validation;

/// Crate version, matching the workspace version.
pub const VERSION: &str = env!("CARGO_PKG_VERSION");
