//! Validation passes for parsed .spec AST.
//! Will be populated in .2.3 (validation implementation).

use crate::ast::SpecFile;
use crate::error::Result;

/// Validate a parsed SpecFile AST.
///
/// Checks: duplicate rules, mixed edges, unclosed blocks, top-rule requirement.
/// Currently a placeholder — will be implemented in .2.3.
pub fn validate(spec: &SpecFile) -> Result<()> {
    let _ = spec;
    Ok(())
}
