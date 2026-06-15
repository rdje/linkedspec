//! Validation passes for parsed `.spec` AST.
//!
//! Checks performed:
//! 1. At least one top rule (`::`) exists
//! 2. No duplicate rule labels
//! 3. No rule mixes action (`->`) and blind-call (`=>`) edges
//! 4. All `{` blocks are balanced (no unclosed blocks)
//! 5. All edge targets reference existing rules
//! 6. Rule headers are not inside open blocks (handled by parser)

use crate::ast::{BodyElementKind, SpecFile};
use crate::error::{LinkedSpecError, Result};
use rgx_core::Regex;
use std::collections::HashSet;

/// Run all validation passes on a parsed spec.
pub fn validate(spec: &SpecFile) -> Result<()> {
    check_top_rule_exists(spec)?;
    check_duplicate_labels(spec)?;
    check_mixed_edges(spec)?;
    check_balanced_braces(spec)?;
    check_edge_targets(spec)?;
    check_regex_syntax(spec)?;
    Ok(())
}

/// At least one rule must use `::` (top rule marker).
fn check_top_rule_exists(spec: &SpecFile) -> Result<()> {
    if !spec.rules.iter().any(|r| r.header.is_top) {
        return Err(LinkedSpecError::Validation(
            "no top rule found: at least one rule must use '::' (double colon)".into(),
        ));
    }
    Ok(())
}

/// Rule labels must be unique.
fn check_duplicate_labels(spec: &SpecFile) -> Result<()> {
    let mut seen = HashSet::new();
    for rule in &spec.rules {
        if !seen.insert(&rule.header.label) {
            return Err(LinkedSpecError::Validation(format!(
                "duplicate rule label '{}'",
                rule.header.label
            )));
        }
    }
    Ok(())
}

/// A rule must not mix action edges (`->`) and blind-call edges (`=>`).
fn check_mixed_edges(spec: &SpecFile) -> Result<()> {
    for rule in &spec.rules {
        let has_action = rule
            .body
            .iter()
            .any(|e| matches!(e.kind, BodyElementKind::ActionEdge { .. }));
        let has_blind = rule
            .body
            .iter()
            .any(|e| matches!(e.kind, BodyElementKind::BlindEdge { .. }));
        if has_action && has_blind {
            return Err(LinkedSpecError::Validation(format!(
                "rule '{}' mixes action (->) and blind-call (=>) edges",
                rule.header.label
            )));
        }
    }
    Ok(())
}

/// Every opening `{` must have a matching closing `}` within the same rule.
/// Counts braces only in code block content (not the delimiters in source text).
fn check_balanced_braces(spec: &SpecFile) -> Result<()> {
    for rule in &spec.rules {
        let mut depth: i32 = 0;
        for element in &rule.body {
            match &element.kind {
                BodyElementKind::CodeBlock { code, .. } => {
                    for ch in code.chars() {
                        match ch {
                            '{' => depth += 1,
                            '}' => depth -= 1,
                            _ => {}
                        }
                    }
                }
                BodyElementKind::ActionEdge { code, .. } => {
                    if let Some(c) = code {
                        for ch in c.chars() {
                            match ch {
                                '{' => depth += 1,
                                '}' => depth -= 1,
                                _ => {}
                            }
                        }
                    }
                }
                BodyElementKind::BlindEdge { code, .. } => {
                    if let Some(c) = code {
                        for ch in c.chars() {
                            match ch {
                                '{' => depth += 1,
                                '}' => depth -= 1,
                                _ => {}
                            }
                        }
                    }
                }
                BodyElementKind::PlainBlock { code } => {
                    for ch in code.chars() {
                        match ch {
                            '{' => depth += 1,
                            '}' => depth -= 1,
                            _ => {}
                        }
                    }
                }
                _ => {}
            }
        }
        if depth != 0 {
            return Err(LinkedSpecError::Validation(format!(
                "rule '{}' has unbalanced braces: {} unmatched {}",
                rule.header.label,
                depth.abs(),
                if depth > 0 { "open" } else { "close" }
            )));
        }
    }
    Ok(())
}

/// Every edge target must reference an existing rule.
fn check_edge_targets(spec: &SpecFile) -> Result<()> {
    let labels: HashSet<&str> = spec.rules.iter().map(|r| r.header.label.as_str()).collect();
    for rule in &spec.rules {
        for element in &rule.body {
            let targets: Vec<&str> = match &element.kind {
                BodyElementKind::ActionEdge { targets, .. } => {
                    targets.iter().map(|t| t.label.as_str()).collect()
                }
                BodyElementKind::BlindEdge { target, .. } => vec![target.as_str()],
                _ => continue,
            };
            for t in targets {
                if !labels.contains(t) {
                    return Err(LinkedSpecError::Validation(format!(
                        "rule '{}' references undefined rule '{}'",
                        rule.header.label, t
                    )));
                }
            }
        }
    }
    Ok(())
}

/// Every regex literal must compile as a valid regex.
/// Regex patterns using look-around ((?=, (?!, (?<=, (?<!) are accepted but
/// flagged since Rust's `regex` crate does not support them.
fn check_regex_syntax(spec: &SpecFile) -> Result<()> {
    for rule in &spec.rules {
        for element in &rule.body {
            if let BodyElementKind::Regex { pattern } = &element.kind {
                // Check for look-around — Rust's regex crate doesn't support this
                let uses_lookaround = pattern.contains("(?<") || pattern.contains("(?=") || pattern.contains("(?!");

                if uses_lookaround {
                    // Accept as valid Perl regex syntax; cannot compile in Rust
                    eprintln!(
                        "note: rule '{}': regex pattern '/{}/' uses look-around — accepted (valid Perl regex, unverifiable in Rust regex crate)",
                        rule.header.label, pattern
                    );
                    continue;
                }

                Regex::compile(pattern).map_err(|e| {
                    LinkedSpecError::Validation(format!(
                        "rule '{}': invalid regex pattern '/{}/': {}",
                        rule.header.label, pattern, e
                    ))
                })?;
            }
        }
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::parser::parse_spec;

    #[test]
    fn validate_accepts_valid_spec() {
        let src = "Top::\n /a/ -> Child\n\nChild:\n /b/";
        let spec = parse_spec(src).unwrap();
        assert!(validate(&spec).is_ok());
    }

    #[test]
    fn validate_rejects_no_top_rule() {
        let src = "R:\n /a/";
        let spec = parse_spec(src).unwrap();
        assert!(validate(&spec).unwrap_err().to_string().contains("no top rule"));
    }

    #[test]
    fn validate_rejects_duplicate_labels() {
        let src = "Top::\n /a/\n\nTop:\n /b/";
        let spec = parse_spec(src).unwrap();
        assert!(validate(&spec).unwrap_err().to_string().contains("duplicate"));
    }

    #[test]
    fn validate_rejects_mixed_edges() {
        let src = "Top::\n /a/ -> A\n /b/ => B";
        let spec = parse_spec(src).unwrap();
        assert!(validate(&spec).unwrap_err().to_string().contains("mixes"));
    }

    #[test]
    fn validate_rejects_undefined_target() {
        let src = "Top::\n /a/ -> Ghost";
        let spec = parse_spec(src).unwrap();
        assert!(validate(&spec).unwrap_err().to_string().contains("undefined rule"));
    }

    #[test]
    fn validate_rejects_invalid_regex() {
        let src = "Top::\n /[invalid/";
        let spec = parse_spec(src).unwrap();
        assert!(validate(&spec).unwrap_err().to_string().contains("invalid regex"));
    }

    #[test]
    fn validate_from_parse() {
        let src = "Top::\n /a/ -> Child\n\nChild:\n /b/ E { return(42) }";
        let spec = parse_spec(src).unwrap();
        validate(&spec).unwrap();
    }
}
