//! Compiler — transforms parsed AST into HandlerIR.
//! Will be populated in .3 (compiler implementation).

use crate::ast::SpecFile;
use crate::error::Result;
use crate::types::HandlerIR;

/// Compile a parsed SpecFile into a vector of HandlerIR nodes.
///
/// Each rule in the spec produces one HandlerIR node.
/// Currently a placeholder — will be implemented in .3.
pub fn compile(spec: &SpecFile) -> Result<Vec<HandlerIR>> {
    let _ = spec;
    Ok(vec![])
}
