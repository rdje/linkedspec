//! .spec file parser — reads .spec files into AST.
//!
//! Reference: `docs/linkedspec-book/src/appendix/formal-grammar.md`

use crate::ast::{BodyElement, BodyElementKind, Rule, RuleHeader, RuleMode, SpecFile};
use crate::error::{LinkedSpecError, Result};
use regex::Regex;

/// Parse a .spec source string into a `SpecFile` AST.
pub fn parse_spec(source: &str) -> Result<SpecFile> {
    let lines: Vec<&str> = source.lines().collect();
    let mut rules = Vec::new();
    let mut i = 0;
    i = skip_blanks_and_comments(&lines, i);

    while i < lines.len() {
        let line = lines[i];
        if line.trim().is_empty() || line.trim_start().starts_with('#') {
            i += 1;
            continue;
        }
        if let Some((header, next_i)) = parse_rule_header(&lines, i)? {
            let (body, next_i) = collect_body_elements(&lines, next_i);
            rules.push(Rule { header, body });
            i = next_i;
        } else {
            if rules.is_empty() {
                return Err(LinkedSpecError::Parse {
                    line: i + 1,
                    message: format!("expected rule start, got: {}", line.trim()),
                });
            }
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

fn skip_blanks_and_comments(lines: &[&str], start: usize) -> usize {
    for (i, line) in lines.iter().enumerate().skip(start) {
        let trimmed = line.trim();
        if !trimmed.is_empty() && !trimmed.starts_with('#') {
            return i;
        }
    }
    lines.len()
}

fn parse_rule_header(lines: &[&str], i: usize) -> Result<Option<(RuleHeader, usize)>> {
    if i >= lines.len() {
        return Ok(None);
    }
    let line = lines[i];
    let trimmed = line.trim_start();
    let header_re = Regex::new(r"^(\w+)[ \t]*(::|:)[ \t]*(\S*)[ \t]*(.*)")
        .map_err(|e| LinkedSpecError::Compile(format!("regex error: {e}")))?;
    if let Some(caps) = header_re.captures(trimmed) {
        let label = caps.get(1).unwrap().as_str().to_string();
        let colon = caps.get(2).unwrap().as_str();
        let mode_raw = caps.get(3).unwrap().as_str();
        let rest = caps.get(4).unwrap().as_str().to_string();
        let is_top = colon == "::";
        let mode = parse_mode_suffix(mode_raw);
        Ok(Some((RuleHeader { label, is_top, mode, rest }, i + 1)))
    } else {
        Ok(None)
    }
}

fn parse_mode_suffix(raw: &str) -> RuleMode {
    if raw.is_empty() { return RuleMode::Default; }
    if let Some((base, min, max)) = parse_bounded_mode(raw) {
        return match base {
            "AND" => RuleMode::AndBounded { min, max },
            "OR" => RuleMode::OrBounded { min, max },
            _ => RuleMode::Default,
        };
    }
    match raw {
        "AND" => RuleMode::And, "AND+" => RuleMode::AndPlus,
        "OR" => RuleMode::Or, "OR+" => RuleMode::OrPlus,
        "&" => RuleMode::Single, "|" => RuleMode::Pipe,
        "+" => RuleMode::Plus, "*" => RuleMode::Star, "?" => RuleMode::Optional,
        _ => RuleMode::Default,
    }
}

fn parse_bounded_mode(raw: &str) -> Option<(&str, usize, Option<usize>)> {
    let bounded_re = Regex::new(r"^(AND|OR)\{(\d*)(?:,(\d*))?\}$").ok()?;
    let caps = bounded_re.captures(raw)?;
    let base = caps.get(1)?.as_str();
    let min_str = caps.get(2)?.as_str();
    let max_str = caps.get(3).map(|m| m.as_str());
    let min: usize = if min_str.is_empty() { 0 } else { min_str.parse().ok()? };
    let max: Option<usize> = match max_str {
        None => Some(min),
        Some("") => None,
        Some(s) => {
            let m: usize = s.parse().ok()?;
            if m >= min { Some(m) } else { return None; }
        }
    };
    Some((base, min, max))
}

fn collect_body_elements(lines: &[&str], start: usize) -> (Vec<BodyElement>, usize) {
    let mut body = Vec::new();
    let mut i = start;
    let mut block_depth: i32 = 0;

    let re_regex = Regex::new(r"^/[^/\\]*(?:\\.[^/\\]*)*/").unwrap();
    let re_action_edge = Regex::new(r"^->[ \t]*(\w+)(?:\[(\d+)\])?").unwrap();
    let re_blind_edge = Regex::new(r"^=>[ \t]*(\w+)").unwrap();
    let re_split = Regex::new(r"^@[ \t]*(capture_slice|capture_from_here|move_pos|mark[ \t]*\([ \t]*\w+[ \t]*\))").unwrap();
    let re_lifecycle = Regex::new(r"^(I|LS|LE|LX|E|EX|IT)\b").unwrap();
    let re_conditional = Regex::new(r"^-\?[ \t]+\w+\b").unwrap();
    let re_fluent = Regex::new(r"^\.[ \t]*\w+").unwrap();
    let header_re = Regex::new(r"^\w+[ \t]*(::|:)[ \t]*\S*").unwrap();

    while i < lines.len() {
        let line = lines[i];
        let trimmed = line.trim();
        let open_count: i32 = trimmed.matches('{').count() as i32;
        let close_count: i32 = trimmed.matches('}').count() as i32;
        block_depth = (block_depth + open_count - close_count).max(0);

        if block_depth == 0 && !trimmed.is_empty() && !trimmed.starts_with('#') {
            if header_re.is_match(trimmed) {
                break;
            }
        }

        if trimmed.is_empty() || trimmed.starts_with('#') {
            i += 1; continue;
        }

        let element = if let Some(caps) = re_regex.captures(trimmed) {
            BodyElement::new(
                BodyElementKind::Regex,
                caps.get(0).unwrap().as_str(),
            )
        } else if let Some(caps) = re_action_edge.captures(trimmed) {
            BodyElement::new(
                BodyElementKind::ActionEdge {
                    target: caps.get(1).unwrap().as_str().to_string(),
                    index: caps.get(2).map(|m| m.as_str().parse().unwrap_or(0)).unwrap_or(0),
                },
                trimmed,
            )
        } else if let Some(caps) = re_blind_edge.captures(trimmed) {
            BodyElement::new(
                BodyElementKind::BlindEdge { target: caps.get(1).unwrap().as_str().to_string() },
                trimmed,
            )
        } else if re_split.is_match(trimmed) {
            BodyElement::new(BodyElementKind::SplitMarker, trimmed)
        } else if let Some(caps) = re_lifecycle.captures(trimmed) {
            BodyElement::new(
                BodyElementKind::LifecycleMarker { marker: caps.get(1).unwrap().as_str().to_string() },
                trimmed,
            )
        } else if re_conditional.is_match(trimmed) {
            BodyElement::new(BodyElementKind::Conditional, trimmed)
        } else if re_fluent.is_match(trimmed) {
            BodyElement::new(BodyElementKind::FluentChain, trimmed)
        } else {
            BodyElement::new(BodyElementKind::Raw, trimmed)
        };

        body.push(element);
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
        assert!(result.rules[0].body.len() >= 5); // at least regex + edge + lifecycle blocks
    }

    #[test]
    fn parse_multi_rule_spec() {
        let source = "# comment\nTop::\n /a/ -> A\n\nA:\n /x/ { return(42) }";
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
