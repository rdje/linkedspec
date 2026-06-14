//! .spec file parser — reads .spec files into AST.
//! Will be populated in .2 (parser implementation).

use crate::ast::SpecFile;
use crate::error::Result;

/// Parse a .spec source string into a `SpecFile` AST.
///
/// This is the main entry point for parsing .spec files.
/// Currently a placeholder — will be implemented in .2.
pub fn parse_spec(source: &str) -> Result<SpecFile> {
    let _ = source;
    Ok(SpecFile { rules: vec![] })
}
