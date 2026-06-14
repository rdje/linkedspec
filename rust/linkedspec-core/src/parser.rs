//! .spec file parser — reads .spec files into AST.
//!
//! Reference: `docs/linkedspec-book/src/appendix/formal-grammar.md`

use crate::ast::{Rule, RuleHeader, RuleMode, SpecFile};
use crate::error::{LinkedSpecError, Result};
use regex::Regex;

/// Parse a .spec source string into a `SpecFile` AST.
pub fn parse_spec(source: &str) -> Result<SpecFile> {
    let lines: Vec<&str> = source.lines().collect();
    let mut rules = Vec::new();
    let mut i = 0;

    // Skip leading blank lines and comments
    i = skip_blanks_and_comments(&lines, i);

    while i < lines.len() {
        let line = lines[i];
        if line.trim().is_empty() || line.trim_start().starts_with('#') {
            i += 1;
            continue;
        }

        // Try to parse a rule header at top level
        if let Some((header, next_i)) = parse_rule_header(&lines, i)? {
            // Collect body elements until the next rule start or EOF
            let (body, next_i) = collect_body_elements(&lines, next_i);
            rules.push(Rule { header, body });
            i = next_i;
        } else {
            // Stray text before first rule
            if rules.is_empty() {
                return Err(LinkedSpecError::Parse {
                    line: i + 1,
                    message: format!(
                        "expected rule start (label: or label::), got: {}",
                        line.trim()
                    ),
                });
            }
            // Between rules: skip blank/comment lines
            i += 1;
        }
    }

    if rules.is_empty() {
        return Err(LinkedSpecError::Parse {
            line: 1,
            message: "no rule definitions found in spec".into(),
        });
    }

    Ok(SpecFile { rules })
}

/// Skip leading blank lines and comment lines. Returns the index of the first
/// non-blank, non-comment line.
fn skip_blanks_and_comments(lines: &[&str], start: usize) -> usize {
    for (i, line) in lines.iter().enumerate().skip(start) {
        let trimmed = line.trim();
        if !trimmed.is_empty() && !trimmed.starts_with('#') {
            return i;
        }
    }
    lines.len()
}

/// Try to parse a rule header from `lines[i]`. Returns `(header, next_index)` on success,
/// or `None` if this line is not a rule start.
///
/// Rule header pattern: `word` followed by `:` or `::`, optional mode suffix, optional rest.
fn parse_rule_header(lines: &[&str], i: usize) -> Result<Option<(RuleHeader, usize)>> {
    if i >= lines.len() {
        return Ok(None);
    }

    let line = lines[i];
    let trimmed = line.trim_start();

    // Rule header regex: label, colon type, optional mode, optional rest
    let header_re = Regex::new(r"^(\w+)[ \t]*(::|:)[ \t]*(\S*)[ \t]*(.*)")
        .map_err(|e| LinkedSpecError::Compile(format!("regex error: {e}")))?;

    if let Some(caps) = header_re.captures(trimmed) {
        let label = caps.get(1).unwrap().as_str().to_string();
        let colon = caps.get(2).unwrap().as_str();
        let mode_raw = caps.get(3).unwrap().as_str();
        let rest = caps.get(4).unwrap().as_str().to_string();

        let is_top = colon == "::";
        let mode = parse_mode_suffix(mode_raw);

        Ok(Some((
            RuleHeader {
                label,
                is_top,
                mode,
                rest,
            },
            i + 1,
        )))
    } else {
        Ok(None)
    }
}

/// Parse a rule mode suffix string into a `RuleMode` enum.
fn parse_mode_suffix(raw: &str) -> RuleMode {
    if raw.is_empty() {
        return RuleMode::Default;
    }

    // Try bounded forms first: AND{N,M}, OR{N,M}, etc.
    if let Some((base, min, max)) = parse_bounded_mode(raw) {
        return match base {
            "AND" => RuleMode::AndBounded { min, max },
            "OR" => RuleMode::OrBounded { min, max },
            _ => RuleMode::Default,
        };
    }

    // Exact matches for shorthand modes
    match raw {
        "AND" => RuleMode::And,
        "AND+" => RuleMode::AndPlus,
        "OR" => RuleMode::Or,
        "OR+" => RuleMode::OrPlus,
        "&" => RuleMode::Single,
        "|" => RuleMode::Pipe,
        "+" => RuleMode::Plus,
        "*" => RuleMode::Star,
        "?" => RuleMode::Optional,
        _ => RuleMode::Default, // Unknown mode → treat as default
    }
}

/// Parse bounded repetition forms: `AND{N}`, `AND{N,M}`, `AND{N,}`, `AND{,M}`,
/// `OR{N}`, `OR{N,M}`, `OR{N,}`, `OR{,M}`.
///
/// Returns `Some((base, min, max))` on success, or `None` if the string doesn't match.
fn parse_bounded_mode(raw: &str) -> Option<(&str, usize, Option<usize>)> {
    let bounded_re = Regex::new(r"^(AND|OR)\{(\d*)(?:,(\d*))?\}$").ok()?;
    let caps = bounded_re.captures(raw)?;

    let base = caps.get(1)?.as_str();
    let min_str = caps.get(2)?.as_str();
    let max_str = caps.get(3).map(|m| m.as_str());

    let min: usize = if min_str.is_empty() {
        0
    } else {
        min_str.parse().ok()?
    };

    let max: Option<usize> = match max_str {
        None => Some(min), // {N} means exactly N
        Some("") => None,  // {N,} means N or more
        Some(s) => {
            let m: usize = s.parse().ok()?;
            if m == 0 && min == 0 && max_str == Some("0") {
                None // {,0} is weird but treat as unbounded upper
            } else if m >= min {
                Some(m)
            } else {
                return None;
            }
        }
    };

    Some((base, min, max))
}

/// Collect body elements from `lines[start..]` until the next rule start or EOF.
///
/// Returns `(body_elements, next_index)`.
fn collect_body_elements(lines: &[&str], start: usize) -> (Vec<crate::ast::BodyElement>, usize) {
    use crate::ast::BodyElement;

    let mut body = Vec::new();
    let mut i = start;
    let mut block_depth: i32 = 0; // Track { } nest depth for block awareness

    // Regexes for body element recognition
    // Match a regex literal: /pattern/ with support for escaped \/ inside
    let re_regex = Regex::new(r"^/[^/\\]*(?:\\.[^/\\]*)*/").unwrap();
    let re_action_edge = Regex::new(r"^->[ \t]*(\w+)(?:\[(\d+)\])?").unwrap();
    let re_blind_edge = Regex::new(r"^=>[ \t]*(\w+)").unwrap();
    let re_split_marker = Regex::new(r"^@[ \t]*(capture_slice|capture_from_here|move_pos|mark[ \t]*\([ \t]*\w+[ \t]*\))").unwrap();
    let re_lifecycle = Regex::new(r"^(I|LS|LE|LX|E|EX|IT)\b").unwrap();
    let re_conditional = Regex::new(r"^-\?[ \t]+\w+\b").unwrap();
    let re_fluent = Regex::new(r"^\.[ \t]*\w+").unwrap();

    // Rule-header-like pattern — if we see this at depth 0, it's a new rule
    let header_re = Regex::new(r"^\w+[ \t]*(::|:)[ \t]*\S*").unwrap();

    while i < lines.len() {
        let line = lines[i];
        let trimmed = line.trim();

        // Track block depth for { and }
        let open_count: i32 = trimmed.matches('{').count() as i32;
        let close_count: i32 = trimmed.matches('}').count() as i32;
        block_depth = block_depth.saturating_add(open_count);
        block_depth = block_depth.saturating_sub(close_count);

        // At depth 0, check if this line starts a new rule
        if block_depth == 0 && trimmed.len() > 0 && !trimmed.starts_with('#') {
            if header_re.is_match(trimmed) {
                // This is a new rule header — stop collecting
                break;
            }
        }

        // Skip blank lines and comments
        if trimmed.is_empty() || trimmed.starts_with('#') {
            i += 1;
            continue;
        }

        // Try to classify the body element
        if let Some(caps) = re_regex.captures(trimmed) {
            body.push(BodyElement::Regex {
                value: caps.get(0).unwrap().as_str().to_string(),
            });
        } else if let Some(caps) = re_action_edge.captures(trimmed) {
            body.push(BodyElement::ActionEdge {
                target: caps.get(1).unwrap().as_str().to_string(),
                index: caps
                    .get(2)
                    .map(|m| m.as_str().parse().unwrap_or(0))
                    .unwrap_or(0),
            });
        } else if let Some(caps) = re_blind_edge.captures(trimmed) {
            body.push(BodyElement::BlindEdge {
                target: caps.get(1).unwrap().as_str().to_string(),
            });
        } else if re_split_marker.is_match(trimmed) {
            body.push(BodyElement::SplitMarker {
                marker: trimmed.to_string(),
            });
        } else if let Some(caps) = re_lifecycle.captures(trimmed) {
            body.push(BodyElement::LifecycleMarker {
                marker: caps.get(1).unwrap().as_str().to_string(),
            });
        } else if re_conditional.is_match(trimmed) {
            body.push(BodyElement::Conditional {
                text: trimmed.to_string(),
            });
        } else if re_fluent.is_match(trimmed) {
            body.push(BodyElement::FluentChain {
                code: trimmed.to_string(),
            });
        } else if trimmed.starts_with('{') || (block_depth > 0 && !trimmed.is_empty()) {
            // Code block content — either explicit { or content inside a block
            body.push(BodyElement::CodeBlock {
                lifecycle: None,
                code: trimmed.to_string(),
            });
        } else {
            // Catch-all for unrecognized content
            body.push(BodyElement::Raw(trimmed.to_string()));
        }

        i += 1;
    }

    (body, i)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_simple_spec() {
        let source = "TestRule::
 /hello/ -> Child {
 I { declare(array, results) }
 LE { push_value(array(results), scalar(retv)) }
 E { return(array_copy(array(results))) }
 }";
        let result = parse_spec(source).unwrap();
        assert_eq!(result.rules.len(), 1);
        assert_eq!(result.rules[0].header.label, "TestRule");
        assert!(result.rules[0].header.is_top);
        assert_eq!(result.rules[0].body.len(), 5); // regex, action edge, I block, LE block, E block
    }

    #[test]
    fn parse_multi_rule_spec() {
        let source = "# comment
Top::
 /a/ -> A

A:
 /x/ { return(42) }";
        let result = parse_spec(source).unwrap();
        assert_eq!(result.rules.len(), 2);
        assert_eq!(result.rules[0].header.label, "Top");
        assert!(result.rules[0].header.is_top);
        assert_eq!(result.rules[1].header.label, "A");
        assert!(!result.rules[1].header.is_top);
    }

    #[test]
    fn parse_mode_variants() {
        let specs = [
            ("R1:AND\n /x/", RuleMode::And),
            ("R2:OR+\n /x/", RuleMode::OrPlus),
            ("R3::*\n /x/", RuleMode::Star),
            ("R4:?\n /x/", RuleMode::Optional),
            ("R5::AND{2,4}\n /x/", RuleMode::AndBounded { min: 2, max: Some(4) }),
            ("R6:OR{3}\n /x/", RuleMode::OrBounded { min: 3, max: Some(3) }),
        ];
        for (spec, expected_mode) in specs {
            let result = parse_spec(spec).unwrap();
            assert_eq!(result.rules[0].header.mode, expected_mode, "failed for: {spec}");
        }
    }

    #[test]
    fn parse_rejects_stray_preamble() {
        let source = "This is not a rule\nTop::\n /x/";
        let err = parse_spec(source).unwrap_err();
        assert!(err.to_string().contains("expected rule start"));
    }

    #[test]
    fn parse_rejects_empty_spec() {
        let source = "# just a comment\n\n";
        let err = parse_spec(source).unwrap_err();
        assert!(err.to_string().contains("no rule definitions"));
    }

    #[test]
    fn parse_comment_and_blank_skipping() {
        let source = "# header comment\n\nTop::\n /x/";
        let result = parse_spec(source).unwrap();
        assert_eq!(result.rules.len(), 1);
    }

    #[test]
    fn parse_block_depth_aware() {
        // A label-like line inside { } should NOT start a new rule
        let source = "Top::
 /a/ -> Next {
 label:
 return(array(?Top:))
 }

Next::
 /b/ { return(array(?Next:)) }";
        let result = parse_spec(source).unwrap();
        assert_eq!(result.rules.len(), 2);
        assert_eq!(result.rules[0].header.label, "Top");
        assert_eq!(result.rules[1].header.label, "Next");
    }
}
