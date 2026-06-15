//! `.spec` file parser — reads grammar files into structured AST.
//!
//! Parses rule paragraphs: each starts with a rule header (`Word:` or `Word::`)
//! and continues until the next rule header at top-level block depth.
//!
//! Body elements are classified into: regex literals, action edges, blind-call
//! edges, lifecycle code blocks, split markers, fluent chains, and conditionals.
//! Code blocks (`{ ... }`) are properly captured as multi-line content.

use crate::ast::{
    BodyElement, BodyElementKind, EdgeTarget, FluentCall, Rule, RuleHeader, RuleMode, SpecFile,
};
use crate::error::{LinkedSpecError, Result};
use rgx_core::Regex;

/// Parse a `.spec` source string into a `SpecFile` AST.
pub fn parse_spec(source: &str) -> Result<SpecFile> {
    let lines: Vec<&str> = source.lines().collect();
    let len = lines.len();
    let mut rules: Vec<Rule> = Vec::new();
    let mut i = skip_blanks_and_comments(&lines, 0);

    while i < len {
        // Try to parse a rule header at the current line
        if let Some((header, next_i)) = parse_rule_header(&lines, i)? {
            let (body, next_i) = collect_body(&lines, next_i);
            rules.push(Rule { header, body });
            i = next_i;
        } else if rules.is_empty() {
            return Err(LinkedSpecError::Parse {
                line: i + 1,
                message: format!(
                    "expected rule definition to start with a rule label (Word: or Word::), got: {}",
                    lines[i].trim()
                ),
            });
        } else {
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

/// Skip blank lines and comment lines, return first non-skipped index.
fn skip_blanks_and_comments(lines: &[&str], mut i: usize) -> usize {
    while i < lines.len() {
        let trimmed = lines[i].trim();
        if trimmed.is_empty() || trimmed.starts_with('#') {
            i += 1;
        } else {
            break;
        }
    }
    i
}

// ── Rule header parsing ──

/// Try to parse a rule header from the line at index `i`.
/// Returns `(RuleHeader, next_line_index)` on success, `None` if not a header line.
fn parse_rule_header(lines: &[&str], i: usize) -> Result<Option<(RuleHeader, usize)>> {
    if i >= lines.len() {
        return Ok(None);
    }
    let line = lines[i];
    let trimmed = line.trim();

    let header_re = Regex::compile(r"^(\w+)[ \t]*(::|:)[ \t]*(\S*)[ \t]*(.*)")
        .map_err(|e| LinkedSpecError::Compile(format!("header regex: {e}")))?;

    if let Some(caps) = header_re.captures(trimmed) {
        let label = caps.get(1).unwrap().as_str().to_string();
        let colon = caps.get(2).unwrap().as_str();
        let mode_raw = caps.get(3).unwrap().as_str();
        let rest = caps.get(4).unwrap().as_str().to_string();
        let is_top = colon == "::";
        let mode = parse_mode_suffix(mode_raw);

        Ok(Some((RuleHeader { label, is_top, mode, rest, line: i + 1 }, i + 1)))
    } else {
        Ok(None)
    }
}

/// Parse the mode suffix string into a `RuleMode`.
fn parse_mode_suffix(raw: &str) -> RuleMode {
    if raw.is_empty() {
        return RuleMode::Default;
    }
    if let Some((base, min, max)) = parse_bounded(raw) {
        return match base {
            "AND" => RuleMode::AndBounded { min, max },
            "OR" => RuleMode::OrBounded { min, max },
            _ => RuleMode::Default,
        };
    }
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
        _ => RuleMode::Default,
    }
}

fn parse_bounded(raw: &str) -> Option<(&str, usize, Option<usize>)> {
    let re = Regex::compile(r"^(AND|OR)\{(\d*)(?:,(\d*))?\}$").ok()?;
    let caps = re.captures(raw)?;
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

// ── Body collection ──

/// Collect body elements from `start` until the next rule header at depth 0.
fn collect_body(lines: &[&str], start: usize) -> (Vec<BodyElement>, usize) {
    let mut body = Vec::new();
    let mut i = start;
    let len = lines.len();

    // Header regex for detecting next rule start
    let header_re = Regex::compile(r"^\w+[ \t]*(::|:)[ \t]*\S*").unwrap();

    while i < len {
        let trimmed = lines[i].trim();
        let line_num = i + 1;

        // Skip blank/comment lines
        if trimmed.is_empty() || trimmed.starts_with('#') {
            i += 1;
            continue;
        }

        // Stop if we hit a new rule header at top level
        if header_re.is_match(trimmed) {
            break;
        }

        // Try to parse body elements from this line. A single line may
        // contain multiple elements (e.g., `/x/ I { code }`).
        let mut elements = parse_body_elements(lines, &mut i);
        if elements.is_empty() {
            // Unrecognized — capture as raw (validator will catch issues)
            body.push(BodyElement::new(
                BodyElementKind::Raw { text: trimmed.to_string() },
                trimmed,
                line_num,
            ));
            i += 1;
        } else {
            body.append(&mut elements);
        }
    }
    (body, i)
}

/// Parse body elements starting at line `i`. A single line may contain multiple
/// elements (e.g., `/x/ I { code }`). Advances `i` past consumed lines.
fn parse_body_elements(lines: &[&str], i: &mut usize) -> Vec<BodyElement> {
    let mut elements = Vec::new();
    let line = lines[*i];
    let line_num = *i + 1;

    // First, try to split the line by looking for the first recognized element,
    // consume it, then try again with the remainder. Multi-line blocks advance `i`.
    let mut remaining = line.trim().to_string();
    let mut consumed_line = false;

    loop {
        let trimmed = remaining.trim().to_string();
        if trimmed.is_empty() || trimmed.starts_with('#') {
            break;
        }

        if let Some((element, rest, advanced)) = parse_single_element(&trimmed, lines, i, line_num) {
            elements.push(element);
            remaining = rest;
            if advanced {
                consumed_line = true;
            }
            if advanced && !consumed_line {
                // Multi-line block consumed — we're done with this line
                break;
            }
            if remaining.trim().is_empty() {
                break;
            }
        } else {
            // Can't parse — leave remaining as raw
            if !elements.is_empty() {
                // We already parsed something, so just skip the rest
            }
            break;
        }
    }

    // If we parsed elements but didn't advance `i` (all on one line), advance now
    if !elements.is_empty() && !consumed_line {
        *i += 1;
    } else if elements.is_empty() {
        // No elements parsed at all — don't advance (caller handles raw fallback)
    }

    elements
}

/// Try to parse a single body element from the start of `trimmed`.
/// Returns `(element, remaining_text, advanced_past_line)` on success.
fn parse_single_element(
    trimmed: &str,
    lines: &[&str],
    i: &mut usize,
    line_num: usize,
) -> Option<(BodyElement, String, bool)> {
    // Regex patterns for classification (order matters!)
    let re_regex = Regex::compile(r"^/([^/\\]*(?:\\.[^/\\]*)*)/").unwrap();
    let re_action = Regex::compile(r"^->[ \t]+(\w+(?:[ \t]*\|[ \t]*\w+)*)((?:\[(\d+)\])?)").unwrap();
    let re_blind = Regex::compile(r"^=>[ \t]+(\w+)").unwrap();
    let re_lifecycle = Regex::compile(r"^(I|LS|LE|LX|E|EX|IT)\b").unwrap();
    let re_split = Regex::compile(r"^@[ \t]*(capture_slice|capture_from_here|move_pos|mark[ \t]*\([ \t]*\w+[ \t]*\))").unwrap();
    let re_conditional = Regex::compile(r"^-\?[ \t]+\w+").unwrap();
    let re_fluent = Regex::compile(r"^\.[ \t]*\w+").unwrap();

    // 1. Regex literal: `/pattern/`
    if let Some(caps) = re_regex.captures(trimmed) {
        let full_match = caps.get(0).unwrap();
        let pattern = caps.get(1).unwrap().as_str().to_string();
        let remainder = trimmed[full_match.end()..].to_string();
        let elem = BodyElement::new(
            BodyElementKind::Regex { pattern },
            full_match.as_str(),
            line_num,
        );
        return Some((elem, remainder, false));
    }

    // 2. Action edge: `-> Target` or `-> Target1 | Target2` optionally with block
    if let Some(caps) = re_action.captures(trimmed) {
        let full_match = caps.get(0).unwrap();
        let targets_str = caps.get(1).unwrap().as_str();
        let index: usize = caps.get(3)
            .map(|m| m.as_str().parse().unwrap_or(0))
            .unwrap_or(0);

        let targets: Vec<EdgeTarget> = targets_str
            .split('|')
            .map(|t| t.trim())
            .filter(|t| !t.is_empty())
            .map(|label| EdgeTarget { label: label.to_string(), index })
            .collect();

        let rest = trimmed[full_match.end()..].trim_start().to_string();

        if rest.starts_with('{') {
            // Block may span multiple lines — consume_block_from_rest advances `i`.
            let saved_i = *i;
            let (code, remainder) = consume_block_from_rest(lines, i, &rest)?;
            let elem = BodyElement::new(
                BodyElementKind::ActionEdge { targets, code: Some(code) },
                full_match.as_str(),
                line_num,
            );
            let advanced = *i > saved_i;
            return Some((elem, remainder, advanced));
        } else {
            let elem = BodyElement::new(
                BodyElementKind::ActionEdge { targets, code: None },
                full_match.as_str(),
                line_num,
            );
            return Some((elem, rest, false));
        }
    }

    // 3. Blind-call edge: `=> Target` optionally with block
    if let Some(caps) = re_blind.captures(trimmed) {
        let full_match = caps.get(0).unwrap();
        let target = caps.get(1).unwrap().as_str().to_string();
        let rest = trimmed[full_match.end()..].trim_start().to_string();

        let (code, fluent_chain, advanced, remainder) = if rest.starts_with('{') {
            let saved_i = *i;
            let (c, rem) = consume_block_from_rest(lines, i, &rest)?;
            (Some(c), Vec::new(), *i > saved_i, rem)
        } else {
            let chain = parse_fluent_chain(&rest);
            (None, chain, false, rest)
        };

        let elem = BodyElement::new(
            BodyElementKind::BlindEdge { target, code, fluent_chain },
            full_match.as_str(),
            line_num,
        );
        return Some((elem, remainder, advanced));
    }

    // 4. Lifecycle code block: `I { ... }` or bare lifecycle marker
    if let Some(caps) = re_lifecycle.captures(trimmed) {
        let full_match = caps.get(0).unwrap();
        let marker = caps.get(1).unwrap().as_str().to_string();
        let rest = trimmed[full_match.end()..].trim_start().to_string();

        if rest.starts_with('{') {
            let saved_i = *i;
            let (code, remainder) = consume_block_from_rest(lines, i, &rest)?;
            let elem = BodyElement::new(
                BodyElementKind::CodeBlock { lifecycle: marker.clone(), code },
                &format!("{} {{ {} }}", marker, trimmed),
                line_num,
            );
            let advanced = *i > saved_i;
            return Some((elem, remainder, advanced));
        } else {
            // Bare lifecycle marker (no block)
            let elem = BodyElement::new(
                BodyElementKind::LifecycleMarker { marker },
                full_match.as_str(),
                line_num,
            );
            return Some((elem, rest, false));
        }
    }

    // 5. Split marker
    if let Some(caps) = re_split.captures(trimmed) {
        let full_match = caps.get(0).unwrap();
        let marker = full_match.as_str().to_string();
        let remainder = trimmed[full_match.end()..].to_string();
        let elem = BodyElement::new(
            BodyElementKind::SplitMarker { marker },
            full_match.as_str(),
            line_num,
        );
        return Some((elem, remainder, false));
    }

    // 6. Conditional: `-? word`
    if let Some(caps) = re_conditional.captures(trimmed) {
        let full_match = caps.get(0).unwrap();
        let word = full_match.as_str()[2..].trim().to_string();
        let remainder = trimmed[full_match.end()..].to_string();
        let elem = BodyElement::new(
            BodyElementKind::Conditional { word },
            full_match.as_str(),
            line_num,
        );
        return Some((elem, remainder, false));
    }

    // 7. Fluent chain
    if let Some(caps) = re_fluent.captures(trimmed) {
        let full_match = caps.get(0).unwrap();
        let calls = parse_fluent_chain(trimmed);
        let remainder = String::new(); // fluent chain consumes rest of line
        let elem = BodyElement::new(
            BodyElementKind::FluentChain { calls },
            full_match.as_str(),
            line_num,
        );
        return Some((elem, remainder, false));
    }

    // 8. Plain code block: `{ ... }`
    if trimmed.starts_with('{') {
        let saved_i = *i;
        let (code, remainder) = consume_block_from_rest(lines, i, trimmed)?;
        let elem = BodyElement::new(
            BodyElementKind::PlainBlock { code },
            trimmed,
            line_num,
        );
        let advanced = *i > saved_i;
        return Some((elem, remainder, advanced));
    }

    // 9. Fallback: not a recognized element
    None
}

/// Consume a `{ ... }` block that starts in `rest` and may continue on subsequent lines.
/// `i` is the CURRENT line index (the line containing the opening `{`).
/// Returns `(block_content, rest_after_block_on_same_line)`.
/// Advances `i` past any lines consumed.
fn consume_block_from_rest(lines: &[&str], i: &mut usize, rest: &str) -> Option<(String, String)> {
    let start_brace = rest.find('{')?;
    let remainder = &rest[start_brace + 1..]; // everything after opening `{`
    let mut depth: i32 = 1;
    let mut content = String::new();

    // Scan the remainder of the current line
    let remainder_scan = scan_line_for_braces_chars(remainder, &mut depth);
    if depth == 0 {
        // Block closes on the same line
        let block_content = if remainder_scan.ends_with('}') {
            remainder_scan[..remainder_scan.len()-1].trim().to_string()
        } else {
            remainder_scan.trim().to_string()
        };
        // Everything after the closing `}` on the same line
        let after_block = remainder[remainder_scan.len()..].trim().to_string();
        return Some((block_content, after_block));
    }
    // Block continues past this line — include the remainder
    if !remainder_scan.trim().is_empty() {
        content.push_str(remainder_scan.trim());
    }

    // Consume subsequent lines
    *i += 1; // advance to next line
    while *i < lines.len() && depth > 0 {
        let line = lines[*i];
        let line_scan = scan_line_for_braces_chars(line, &mut depth);
        if depth == 0 {
            // Closing brace found on this line
            let strip_close = if line_scan.ends_with('}') {
                &line_scan[..line_scan.len()-1]
            } else {
                line_scan
            };
            if !strip_close.trim().is_empty() {
                if !content.is_empty() { content.push('\n'); }
                content.push_str(strip_close.trim());
            }
            *i += 1;
            return Some((content.trim().to_string(), String::new()));
        }
        // Include the whole line
        if !content.is_empty() { content.push('\n'); }
        content.push_str(line.trim());
        *i += 1;
    }
    // Unclosed block (validator catches this)
    Some((content.trim().to_string(), String::new()))
}

/// Like scan_line_for_braces but works on &str slices (not just full lines).
fn scan_line_for_braces_chars<'a>(text: &'a str, depth: &mut i32) -> &'a str {
    for (idx, ch) in text.char_indices() {
        match ch {
            '{' => *depth += 1,
            '}' => {
                *depth -= 1;
                if *depth == 0 {
                    return &text[..=idx];
                }
            }
            _ => {}
        }
    }
    text
}

/// Parse a fluent chain like `.method(args).method2(more_args)` into FluentCall list.
fn parse_fluent_chain(text: &str) -> Vec<FluentCall> {
    let mut calls = Vec::new();
    let mut remaining = text.trim();

    while remaining.starts_with('.') {
        remaining = &remaining[1..]; // consume '.'
        // Find method name
        let name_end = remaining
            .find(|c: char| !c.is_alphanumeric() && c != '_')
            .unwrap_or(remaining.len());
        let method = remaining[..name_end].to_string();
        remaining = &remaining[name_end..];

        // Check for parenthesized args
        if remaining.starts_with('(') {
            let args = extract_paren_content(remaining);
            let close_idx = remaining.find(')').unwrap_or(remaining.len());
            remaining = &remaining[close_idx + 1..];
            calls.push(FluentCall { method, args: args.unwrap_or_default() });
        } else {
            calls.push(FluentCall { method, args: String::new() });
        }
    }
    calls
}

/// Extract content between `(` and matching `)`.
fn extract_paren_content(s: &str) -> Option<String> {
    if !s.starts_with('(') {
        return None;
    }
    let mut depth: i32 = 0;
    for (idx, ch) in s.char_indices() {
        match ch {
            '(' => depth += 1,
            ')' => {
                depth -= 1;
                if depth == 0 {
                    return Some(s[1..idx].to_string());
                }
            }
            _ => {}
        }
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_simple_top_rule() {
        let src = "DemoParser::\n /hello/";
        let spec = parse_spec(src).unwrap();
        assert_eq!(spec.rules.len(), 1);
        assert_eq!(spec.rules[0].header.label, "DemoParser");
        assert!(spec.rules[0].header.is_top);
    }

    #[test]
    fn parse_code_block() {
        let src = "Top::\n /a/ I {\n  declare(array, results)\n}\n E { return(42) }";
        let spec = parse_spec(src).unwrap();
        assert_eq!(spec.rules.len(), 1);
        let body = &spec.rules[0].body;
        // Should have: Regex, CodeBlock(I), CodeBlock(E)
        assert!(body.iter().any(|e| matches!(e.kind, BodyElementKind::Regex { .. })));
        assert!(body.iter().any(|e| matches!(&e.kind, BodyElementKind::CodeBlock { lifecycle, .. } if lifecycle == "I")));
        assert!(body.iter().any(|e| matches!(&e.kind, BodyElementKind::CodeBlock { lifecycle, .. } if lifecycle == "E")));
    }

    #[test]
    fn parse_lifecycle_block_content() {
        let src = "Top::\n /x/ I { declare(array, results) }";
        let spec = parse_spec(src).unwrap();
        let iblock = spec.rules[0].body.iter().find(|e| {
            matches!(&e.kind, BodyElementKind::CodeBlock { lifecycle, .. } if lifecycle == "I")
        }).unwrap();
        match &iblock.kind {
            BodyElementKind::CodeBlock { code, .. } => {
                assert!(code.contains("declare(array, results)"));
            }
            _ => panic!("expected CodeBlock"),
        }
    }

    #[test]
    fn parse_multiline_code_block() {
        let src = "Top::\n /a/ I {\n  declare(array, results)\n  declare(scalar, count=0)\n}";
        let spec = parse_spec(src).unwrap();
        match &spec.rules[0].body[1].kind {
            BodyElementKind::CodeBlock { code, lifecycle } => {
                assert_eq!(lifecycle, "I");
                assert!(code.contains("declare(array, results)"));
                assert!(code.contains("declare(scalar, count=0)"));
            }
            _ => panic!("expected CodeBlock"),
        }
    }

    #[test]
    fn parse_action_edge_with_block() {
        let src = "Top::\n /a/ -> Child {\n  return(42)\n}";
        let spec = parse_spec(src).unwrap();
        let edge = spec.rules[0].body.iter().find(|e| {
            matches!(&e.kind, BodyElementKind::ActionEdge { .. })
        }).unwrap();
        match &edge.kind {
            BodyElementKind::ActionEdge { targets, code } => {
                assert_eq!(targets[0].label, "Child");
                assert!(code.as_ref().unwrap().contains("return(42)"));
            }
            _ => panic!("expected ActionEdge"),
        }
    }

    #[test]
    fn parse_nested_braces_in_code() {
        let src = "Top::\n /a/ I {\n  if(cond) {\n    push_value(arr, val)\n  }\n}";
        let spec = parse_spec(src).unwrap();
        match &spec.rules[0].body[1].kind {
            BodyElementKind::CodeBlock { code, .. } => {
                assert!(code.contains("if(cond)"));
                assert!(code.contains("push_value(arr, val)"));
            }
            _ => panic!("expected CodeBlock"),
        }
    }

    #[test]
    fn parse_two_rules() {
        let src = "# comment\n\nTop::\n /a/ -> Child\n\nChild:\n /b/ E { return(42) }";
        let spec = parse_spec(src).unwrap();
        assert_eq!(spec.rules.len(), 2);
        assert_eq!(spec.rules[0].header.label, "Top");
        assert_eq!(spec.rules[1].header.label, "Child");
    }

    #[test]
    fn parse_all_mode_variants() {
        let modes = [
            ("R1:AND", RuleMode::And),
            ("R2:OR+", RuleMode::OrPlus),
            ("R3::*", RuleMode::Star),
            ("R4:?", RuleMode::Optional),
            ("R5:AND{2,4}", RuleMode::AndBounded { min: 2, max: Some(4) }),
            ("R6:OR{3}", RuleMode::OrBounded { min: 3, max: Some(3) }),
            ("R7:&", RuleMode::Single),
            ("R8:|", RuleMode::Pipe),
        ];
        for (src, expected) in &modes {
            let spec = parse_spec(&format!("{src}\n /x/")).unwrap();
            assert_eq!(spec.rules[0].header.mode, *expected, "failed for {src}");
        }
    }

    #[test]
    fn parse_blind_edge() {
        let src = "Top::\n /a/ => Child";
        let spec = parse_spec(src).unwrap();
        let edge = spec.rules[0].body.iter().find(|e| {
            matches!(&e.kind, BodyElementKind::BlindEdge { .. })
        }).unwrap();
        match &edge.kind {
            BodyElementKind::BlindEdge { target, .. } => assert_eq!(target, "Child"),
            _ => panic!("expected BlindEdge"),
        }
    }

    #[test]
    fn parse_split_marker() {
        let src = "Top::\n /a/ @capture_slice";
        let spec = parse_spec(src).unwrap();
        assert!(spec.rules[0].body.iter().any(|e| {
            matches!(&e.kind, BodyElementKind::SplitMarker { marker } if marker == "@capture_slice")
        }));
    }
}
