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
            let rest = header.rest.trim().to_string();
            let mut body_start_i = next_i;
            let mut inline_elements = Vec::new();

            // Parse same-line content (rest) as inline body elements. Do this
            // before collecting following lines so a block opened in the
            // header rest can consume its continuation lines as one element.
            if !rest.is_empty() {
                let mut inline_i = header.line.saturating_sub(1);
                if let Some(parsed_inline) =
                    parse_inline_body(&rest, header.line, &lines, &mut inline_i)
                {
                    inline_elements = parsed_inline;
                    body_start_i = body_start_i.max(inline_i);
                }
            }

            let (mut body, next_i) = collect_body(&lines, body_start_i);
            if !inline_elements.is_empty() {
                inline_elements.extend(body);
                body = inline_elements;
            }
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

    Ok(SpecFile {
        functions: Vec::new(),
        rules,
    })
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

    // Group 3 (the mode suffix) is `[^\s/]*`, NOT `\S*`: a greedy `\S*` swallows a
    // `/…/` regex written on the rule's header line (e.g. `name : /re/` or a
    // `/open/ /close/` bracket pair), `parse_mode_suffix` then falls to
    // `RuleMode::Default`, and the regex is silently dropped — the rule registers
    // 0 (or, for a pair, 1) regexes, so every `-> child[N]` dispatch edge never
    // fires (RUST-PARITY.7.5.1). Stopping the class at `/` lets a `/`-led regex
    // fall through to group 4 (`rest`), where `parse_inline_body` registers it.
    // Every real mode suffix (AND, OR+, &, *, ?, AND{2,4}, …) is slash-free, so
    // this is identical to `\S*` for all non-regex header content.
    let header_re = Regex::compile(r"^(\w+)[ \t]*(::|:)[ \t]*([^\s/]*)[ \t]*(.*)")
        .map_err(|e| LinkedSpecError::Compile(format!("header regex: {e}")))?;

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
                line: i + 1,
            },
            i + 1,
        )))
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
    let min: usize = if min_str.is_empty() {
        0
    } else {
        min_str.parse().ok()?
    };
    let max: Option<usize> = match max_str {
        None => Some(min),
        Some("") => None,
        Some(s) => {
            let m: usize = s.parse().ok()?;
            if m >= min {
                Some(m)
            } else {
                return None;
            }
        }
    };
    Some((base, min, max))
}

// ── Body collection ──

/// Collect body elements from `start` until the next rule header at depth 0.
/// Parse header-rest content as body elements.
///
/// Header-rest elements use the same parser as ordinary body lines so compact
/// and multiline authoring stay structurally equivalent.
fn parse_inline_body(
    rest: &str,
    line_num: usize,
    lines: &[&str],
    i: &mut usize,
) -> Option<Vec<BodyElement>> {
    let mut elements = Vec::new();
    let mut remaining = rest.trim().to_string();

    while !remaining.is_empty() {
        let trimmed = remaining.trim().to_string();
        if trimmed.is_empty() || trimmed.starts_with('#') {
            break;
        }

        let before = trimmed.clone();
        let Some((element, remainder, _advanced)) =
            parse_single_element(&trimmed, lines, i, line_num)
        else {
            break;
        };
        elements.push(element);
        remaining = remainder;
        if remaining.trim() == before {
            break;
        }
    }

    if elements.is_empty() {
        None
    } else {
        Some(elements)
    }
}

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

        // Stop if we hit a new rule header. Top-level user functions are stripped
        // by the runtime-level spec-defined parser before this core rule parser
        // sees the source.
        if header_re.is_match(trimmed) {
            break;
        }

        // Try to parse body elements from this line. A single line may
        // contain multiple elements (e.g., `/x/ I { code }`).
        let mut elements = parse_body_elements(lines, &mut i);
        collect_action_edge_fluent_continuation_lines(lines, &mut i, &mut elements);
        if elements.is_empty() {
            // Unrecognized — capture as raw (validator will catch issues)
            body.push(BodyElement::new(
                BodyElementKind::Raw {
                    text: trimmed.to_string(),
                },
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

fn collect_action_edge_fluent_continuation_lines(
    lines: &[&str],
    i: &mut usize,
    elements: &mut [BodyElement],
) {
    let Some(BodyElement {
        kind: BodyElementKind::ActionEdge { fluent_chain, .. },
        ..
    }) = elements.last_mut()
    else {
        return;
    };

    while *i < lines.len() {
        let trimmed = lines[*i].trim();
        if trimmed.is_empty() || trimmed.starts_with('#') || !trimmed.starts_with('.') {
            break;
        }

        let (calls, remainder) = parse_fluent_chain_with_remainder(trimmed);
        let remainder = remainder.trim();
        if calls.is_empty() || (!remainder.is_empty() && !remainder.starts_with('#')) {
            break;
        }

        fluent_chain.extend(calls);
        *i += 1;
    }
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

        if let Some((element, rest, advanced)) = parse_single_element(&trimmed, lines, i, line_num)
        {
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
    let re_action =
        Regex::compile(r"^->[ \t]+(\w+(?:[ \t]*\|[ \t]*\w+)*)((?:\[(\d+)\])?)").unwrap();
    let re_blind = Regex::compile(r"^=>[ \t]+(\w+)").unwrap();
    let re_lifecycle = Regex::compile(r"^(I|LS|LE|LX|E|EX|IT)\b").unwrap();
    let re_split = Regex::compile(
        r"^@[ \t]*(capture_slice|capture_from_here|move_pos|mark[ \t]*\([ \t]*\w+[ \t]*\))",
    )
    .unwrap();
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
        let index: usize = caps
            .get(3)
            .map(|m| m.as_str().parse().unwrap_or(0))
            .unwrap_or(0);

        let targets: Vec<EdgeTarget> = targets_str
            .split('|')
            .map(|t| t.trim())
            .filter(|t| !t.is_empty())
            .map(|label| EdgeTarget {
                label: label.to_string(),
                index,
            })
            .collect();

        let rest = trimmed[full_match.end()..].trim_start().to_string();

        let saved_i = *i;
        if let Some((code, remainder)) = parse_attached_fluent_when_chain(lines, i, &rest) {
            let elem = BodyElement::new(
                BodyElementKind::ActionEdge {
                    targets,
                    code: Some(code),
                    fluent_chain: Vec::new(),
                },
                full_match.as_str(),
                line_num,
            );
            let advanced = *i > saved_i;
            return Some((elem, remainder, advanced));
        } else if rest.starts_with('{') {
            // Block may span multiple lines — consume_block_from_rest advances `i`.
            let saved_i = *i;
            let (code, remainder) = consume_block_from_rest(lines, i, &rest)?;
            let elem = BodyElement::new(
                BodyElementKind::ActionEdge {
                    targets,
                    code: Some(code),
                    fluent_chain: Vec::new(),
                },
                full_match.as_str(),
                line_num,
            );
            let advanced = *i > saved_i;
            return Some((elem, remainder, advanced));
        } else {
            let (fluent_chain, remainder) = parse_fluent_chain_with_remainder(&rest);
            let elem = BodyElement::new(
                BodyElementKind::ActionEdge {
                    targets,
                    code: None,
                    fluent_chain,
                },
                full_match.as_str(),
                line_num,
            );
            return Some((elem, remainder, false));
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
            let (chain, rem) = parse_fluent_chain_with_remainder(&rest);
            (None, chain, false, rem)
        };

        let elem = BodyElement::new(
            BodyElementKind::BlindEdge {
                target,
                code,
                fluent_chain,
            },
            full_match.as_str(),
            line_num,
        );
        return Some((elem, remainder, advanced));
    }

    // 4. Lifecycle code block: `I { ... }`, `I.return(...)`, or bare marker
    if let Some(caps) = re_lifecycle.captures(trimmed) {
        let full_match = caps.get(0).unwrap();
        let marker = caps.get(1).unwrap().as_str().to_string();
        let rest = trimmed[full_match.end()..].trim_start().to_string();

        let saved_i = *i;
        if let Some((code, remainder)) = parse_attached_fluent_when_chain(lines, i, &rest) {
            let elem = BodyElement::new(
                BodyElementKind::CodeBlock {
                    lifecycle: marker.clone(),
                    code,
                },
                full_match.as_str(),
                line_num,
            );
            let advanced = *i > saved_i;
            return Some((elem, remainder, advanced));
        } else if rest.starts_with('{') {
            let saved_i = *i;
            let (code, remainder) = consume_block_from_rest(lines, i, &rest)?;
            let elem = BodyElement::new(
                BodyElementKind::CodeBlock {
                    lifecycle: marker.clone(),
                    code,
                },
                &format!("{} {{ {} }}", marker, trimmed),
                line_num,
            );
            let advanced = *i > saved_i;
            return Some((elem, remainder, advanced));
        } else if let Some((code, remainder, advanced)) =
            parse_lifecycle_fluent_chain_statement_code(lines, i, &rest)
        {
            let elem = BodyElement::new(
                BodyElementKind::CodeBlock {
                    lifecycle: marker.clone(),
                    code,
                },
                full_match.as_str(),
                line_num,
            );
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
        let elem = BodyElement::new(BodyElementKind::PlainBlock { code }, trimmed, line_num);
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
            remainder_scan[..remainder_scan.len() - 1]
                .trim()
                .to_string()
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
                &line_scan[..line_scan.len() - 1]
            } else {
                line_scan
            };
            if !strip_close.trim().is_empty() {
                if !content.is_empty() {
                    content.push('\n');
                }
                content.push_str(strip_close.trim());
            }
            *i += 1;
            let after_block = line[line_scan.len()..].trim().to_string();
            return Some((content.trim().to_string(), after_block));
        }
        // Include the whole line
        if !content.is_empty() {
            content.push('\n');
        }
        content.push_str(line.trim());
        *i += 1;
    }
    // Unclosed block (validator catches this)
    Some((content.trim().to_string(), String::new()))
}

/// Parse attached fluent branch syntax after a receiver-like body element:
/// `.when(cond) { ... }.otherwise { ... }`.
///
/// The runtime already executes attached conditional blocks through CodeBlock's
/// statement-control model, so the body parser normalizes receiver-fluent
/// branch payloads into the equivalent attached code string and attaches that
/// string to the action edge or lifecycle marker that preceded the chain.
fn parse_attached_fluent_when_chain(
    lines: &[&str],
    i: &mut usize,
    rest: &str,
) -> Option<(String, String)> {
    let mut remaining = strip_required_dot_keyword(rest, "when")?
        .trim_start()
        .to_string();
    if !remaining.starts_with('(') {
        return None;
    }

    let (condition, close_idx) = extract_paren_content_with_end(&remaining)?;
    remaining = remaining[close_idx + 1..].trim_start().to_string();
    if !remaining.starts_with('{') {
        return None;
    }

    let when_start_i = *i;
    let (when_body, remainder) = consume_block_from_rest(lines, i, &remaining)?;
    let mut code = format!("when({}) {{ {} }}", condition.trim(), when_body.trim());
    remaining = remainder;
    let mut remaining_origin_i = block_remainder_origin(when_start_i, *i, &remaining);

    while let Some(after_keyword) = strip_optional_dot_keyword(&remaining, "otherwise") {
        let tail = after_keyword.trim_start();
        if !tail.starts_with('{') {
            break;
        }

        let block_origin_i = remaining_origin_i;
        let current_floor_i = *i;
        let mut block_i = block_origin_i;
        let (otherwise_body, remainder) = consume_block_from_rest(lines, &mut block_i, tail)?;
        code.push_str(" otherwise { ");
        code.push_str(otherwise_body.trim());
        code.push_str(" }");
        remaining = remainder;
        *i = block_i.max(current_floor_i);
        remaining_origin_i = if remaining.trim().is_empty() {
            *i
        } else {
            block_remainder_origin(block_origin_i, block_i, &remaining)
        };
    }

    Some((code, remaining.trim_start().to_string()))
}

fn block_remainder_origin(start_i: usize, end_i: usize, remainder: &str) -> usize {
    if !remainder.trim().is_empty() && end_i > start_i {
        end_i.saturating_sub(1)
    } else {
        end_i
    }
}

fn strip_required_dot_keyword<'a>(text: &'a str, keyword: &str) -> Option<&'a str> {
    let trimmed = text.trim_start();
    let after_dot = trimmed.strip_prefix('.')?.trim_start();
    strip_keyword(after_dot, keyword)
}

fn strip_optional_dot_keyword<'a>(text: &'a str, keyword: &str) -> Option<&'a str> {
    let trimmed = text.trim_start();
    let candidate = trimmed
        .strip_prefix('.')
        .map(str::trim_start)
        .unwrap_or(trimmed);
    strip_keyword(candidate, keyword)
}

fn strip_keyword<'a>(text: &'a str, keyword: &str) -> Option<&'a str> {
    let trimmed = text.trim_start();
    let after = trimmed.strip_prefix(keyword)?;
    if after
        .chars()
        .next()
        .is_some_and(|ch| ch.is_alphanumeric() || ch == '_')
    {
        return None;
    }
    Some(after)
}

fn parse_lifecycle_fluent_chain_statement_code(
    lines: &[&str],
    i: &mut usize,
    rest: &str,
) -> Option<(String, String, bool)> {
    let start_i = *i;
    let mut text = rest.trim_start().to_string();
    if !text.starts_with('.') {
        return None;
    }

    while !compact_fluent_chain_parentheses_are_complete(&text) {
        if *i + 1 >= lines.len() {
            return None;
        }
        *i += 1;
        text.push('\n');
        text.push_str(lines[*i].trim());
    }

    let (calls, remainder) = parse_fluent_chain_with_remainder(&text);
    fluent_calls_to_statement_code(&calls).map(|code| (code, remainder, *i > start_i))
}

fn fluent_calls_to_statement_code(calls: &[FluentCall]) -> Option<String> {
    if calls.is_empty() || calls.iter().any(|call| call.method.trim().is_empty()) {
        return None;
    }

    let statements = calls
        .iter()
        .map(|call| format!("{}({})", call.method.trim(), call.args.trim()))
        .collect::<Vec<_>>()
        .join("; ");
    Some(statements)
}

fn compact_fluent_chain_parentheses_are_complete(text: &str) -> bool {
    let bytes = text.as_bytes();
    let mut pos = skip_ascii_ws(bytes, 0);
    if bytes.get(pos) != Some(&b'.') {
        return true;
    }

    while pos < bytes.len() {
        pos = skip_ascii_ws(bytes, pos);
        if bytes.get(pos) != Some(&b'.') {
            return true;
        }
        pos += 1;
        pos = skip_ascii_ws(bytes, pos);
        let method_start = pos;
        while bytes
            .get(pos)
            .is_some_and(|ch| ch.is_ascii_alphanumeric() || *ch == b'_')
        {
            pos += 1;
        }
        if pos == method_start {
            return true;
        }

        pos = skip_ascii_ws(bytes, pos);
        if bytes.get(pos) != Some(&b'(') {
            return true;
        }
        pos += 1;
        let mut depth = 1usize;
        while pos < bytes.len() {
            match bytes[pos] {
                b'"' | b'\'' => {
                    let Some(next) = skip_delimited_literal_bytes(bytes, pos, bytes[pos]) else {
                        return false;
                    };
                    pos = next;
                }
                b'/' => {
                    if let Some(next) = skip_regex_literal_bytes(bytes, pos) {
                        pos = next;
                    } else {
                        pos += 1;
                    }
                }
                b'(' => {
                    depth += 1;
                    pos += 1;
                }
                b')' => {
                    depth -= 1;
                    pos += 1;
                    if depth == 0 {
                        break;
                    }
                }
                _ => pos += 1,
            }
        }
        if depth != 0 {
            return false;
        }

        pos = skip_ascii_ws(bytes, pos);
        if bytes.get(pos) != Some(&b'.') {
            return true;
        }
    }

    true
}

fn skip_ascii_ws(bytes: &[u8], mut pos: usize) -> usize {
    while bytes.get(pos).is_some_and(|ch| ch.is_ascii_whitespace()) {
        pos += 1;
    }
    pos
}

fn skip_delimited_literal_bytes(bytes: &[u8], start: usize, delimiter: u8) -> Option<usize> {
    let mut pos = start + 1;
    while pos < bytes.len() {
        if bytes[pos] == b'\\' {
            pos += 2;
            continue;
        }
        if bytes[pos] == delimiter {
            return Some(pos + 1);
        }
        pos += 1;
    }
    None
}

fn skip_regex_literal_bytes(bytes: &[u8], start: usize) -> Option<usize> {
    let mut pos = start + 1;
    while pos < bytes.len() {
        if bytes[pos] == b'\\' {
            pos += 2;
            continue;
        }
        if bytes[pos] == b'/' {
            pos += 1;
            while bytes.get(pos).is_some_and(|ch| ch.is_ascii_alphabetic()) {
                pos += 1;
            }
            return Some(pos);
        }
        pos += 1;
    }
    None
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
    parse_fluent_chain_with_remainder(text).0
}

/// Parse a fluent chain and return the unconsumed suffix after the chain.
fn parse_fluent_chain_with_remainder(text: &str) -> (Vec<FluentCall>, String) {
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
            if let Some((args, close_idx)) = extract_paren_content_with_end(remaining) {
                remaining = remaining[close_idx + 1..].trim_start();
                calls.push(FluentCall { method, args });
            } else {
                calls.push(FluentCall {
                    method,
                    args: String::new(),
                });
                remaining = "";
            }
        } else {
            calls.push(FluentCall {
                method,
                args: String::new(),
            });
        }
    }
    (calls, remaining.to_string())
}

/// Extract content between `(` and matching `)`, returning the close index too.
fn extract_paren_content_with_end(s: &str) -> Option<(String, usize)> {
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
                    return Some((s[1..idx].to_string(), idx));
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
        assert!(spec.functions.is_empty());
        assert_eq!(spec.rules.len(), 1);
        assert_eq!(spec.rules[0].header.label, "DemoParser");
        assert!(spec.rules[0].header.is_top);
    }

    #[test]
    fn core_parser_does_not_parse_user_function_definitions_before_rules() {
        let src = r#"fn normalize(value) {
 return(trim(value))
}

Top::
 /x/
"#;
        let err = parse_spec(src).unwrap_err().to_string();
        assert!(
            err.contains("expected rule definition"),
            "core rule parser must not own top-level function DSL syntax: {err}"
        );
    }

    #[test]
    fn core_parser_leaves_functions_empty_for_rule_only_sources() {
        let src = r#"Top::
 -> Done

Done:
 /x/
"#;
        let spec = parse_spec(src).unwrap();
        assert!(spec.functions.is_empty());
        assert_eq!(spec.rules.len(), 2);
        assert_eq!(spec.rules[0].header.label, "Top");
        assert_eq!(spec.rules[1].header.label, "Done");
    }

    #[test]
    fn parse_code_block() {
        let src = "Top::\n /a/ I {\n  declare(array, results)\n}\n E { return(42) }";
        let spec = parse_spec(src).unwrap();
        assert_eq!(spec.rules.len(), 1);
        let body = &spec.rules[0].body;
        // Should have: Regex, CodeBlock(I), CodeBlock(E)
        assert!(
            body.iter()
                .any(|e| matches!(e.kind, BodyElementKind::Regex { .. }))
        );
        assert!(body.iter().any(
            |e| matches!(&e.kind, BodyElementKind::CodeBlock { lifecycle, .. } if lifecycle == "I")
        ));
        assert!(body.iter().any(
            |e| matches!(&e.kind, BodyElementKind::CodeBlock { lifecycle, .. } if lifecycle == "E")
        ));
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
        let edge = spec.rules[0]
            .body
            .iter()
            .find(|e| matches!(&e.kind, BodyElementKind::ActionEdge { .. }))
            .unwrap();
        match &edge.kind {
            BodyElementKind::ActionEdge {
                targets,
                code,
                fluent_chain,
            } => {
                assert_eq!(targets[0].label, "Child");
                assert!(code.as_ref().unwrap().contains("return(42)"));
                assert!(fluent_chain.is_empty());
            }
            _ => panic!("expected ActionEdge"),
        }
    }

    #[test]
    fn parse_action_edge_with_fluent_chain() {
        let src = r#"Top::
 -> Child .push
 -> Child[1] .return(array("?child:", array_copy(array(Child))))

Child: /x/ /y/
"#;
        let spec = parse_spec(src).unwrap();
        let top = &spec.rules[0];
        assert_eq!(
            top.body.len(),
            2,
            "fluent chains are consumed by action edges"
        );

        match &top.body[0].kind {
            BodyElementKind::ActionEdge {
                targets,
                code,
                fluent_chain,
            } => {
                assert_eq!(targets[0].label, "Child");
                assert_eq!(targets[0].index, 0);
                assert!(code.is_none());
                assert_eq!(fluent_chain.len(), 1);
                assert_eq!(fluent_chain[0].method, "push");
                assert_eq!(fluent_chain[0].args, "");
            }
            _ => panic!("expected ActionEdge"),
        }

        match &top.body[1].kind {
            BodyElementKind::ActionEdge {
                targets,
                code,
                fluent_chain,
            } => {
                assert_eq!(targets[0].label, "Child");
                assert_eq!(targets[0].index, 1);
                assert!(code.is_none());
                assert_eq!(fluent_chain.len(), 1);
                assert_eq!(fluent_chain[0].method, "return");
                assert_eq!(
                    fluent_chain[0].args,
                    r#"array("?child:", array_copy(array(Child)))"#
                );
            }
            _ => panic!("expected ActionEdge"),
        }
    }

    #[test]
    fn parse_action_edge_multiline_fluent_flow_chain() {
        let src = r#"Top::
 -> item
  .if(scalar(on))
    .push(item, out)
  .else()
    .return_undef()
  .endif()

item: /x/
"#;
        let spec = parse_spec(src).unwrap();
        let top = &spec.rules[0];
        assert_eq!(
            top.body.len(),
            1,
            "multiline fluent continuations are consumed by the action edge"
        );

        match &top.body[0].kind {
            BodyElementKind::ActionEdge { fluent_chain, .. } => {
                let methods = fluent_chain
                    .iter()
                    .map(|call| (call.method.as_str(), call.args.as_str()))
                    .collect::<Vec<_>>();
                assert_eq!(
                    methods,
                    vec![
                        ("if", "scalar(on)"),
                        ("push", "item, out"),
                        ("else", ""),
                        ("return_undef", ""),
                        ("endif", ""),
                    ]
                );
            }
            _ => panic!("expected ActionEdge"),
        }
    }

    #[test]
    fn parse_action_edge_attached_fluent_when_otherwise_block() {
        let src = r#"Top::
 -> Done.when(false) {
    return("bad")
 }.otherwise {
    return("fallback")
 }

Done:
 /x/
"#;
        let spec = parse_spec(src).unwrap();
        let top = &spec.rules[0];
        assert_eq!(
            top.body.len(),
            1,
            "attached fluent branch payload is consumed by the action edge"
        );

        match &top.body[0].kind {
            BodyElementKind::ActionEdge {
                targets,
                code,
                fluent_chain,
            } => {
                assert_eq!(targets[0].label, "Done");
                assert!(fluent_chain.is_empty());
                let code = code.as_ref().expect("attached code");
                assert!(code.contains("when(false)"), "{code:?}");
                assert!(code.contains(r#"return("bad")"#), "{code:?}");
                assert!(code.contains("otherwise"), "{code:?}");
                assert!(code.contains(r#"return("fallback")"#), "{code:?}");
            }
            _ => panic!("expected ActionEdge"),
        }
    }

    #[test]
    fn parse_lifecycle_attached_fluent_when_otherwise_block() {
        let src = r#"Top::
 I.when(false) { set(out, "bad") } otherwise { set(out, "fallback") } E { return(out) }
 /x/
"#;
        let spec = parse_spec(src).unwrap();
        let top = &spec.rules[0];
        let iblock = top.body.iter().find(|element| {
            matches!(&element.kind, BodyElementKind::CodeBlock { lifecycle, .. } if lifecycle == "I")
        }).expect("I block");

        match &iblock.kind {
            BodyElementKind::CodeBlock { code, .. } => {
                assert!(code.contains("when(false)"));
                assert!(code.contains(r#"set(out, "bad")"#));
                assert!(code.contains("otherwise"));
                assert!(code.contains(r#"set(out, "fallback")"#));
            }
            _ => panic!("expected lifecycle CodeBlock"),
        }
        assert!(
            top.body
                .iter()
                .all(|element| !matches!(element.kind, BodyElementKind::FluentChain { .. })),
            "lifecycle fluent branch payload must not survive as a standalone chain"
        );
    }

    #[test]
    fn parse_lifecycle_compact_fluent_chain_as_code_block() {
        let src = r#"Top::
 I.declare(scalar, out).set(out, "ok").return(out)
 /x/
"#;
        let spec = parse_spec(src).unwrap();
        let top = &spec.rules[0];
        let iblock = top
            .body
            .iter()
            .find(|element| {
                matches!(&element.kind, BodyElementKind::CodeBlock { lifecycle, .. } if lifecycle == "I")
            })
            .expect("I block");

        match &iblock.kind {
            BodyElementKind::CodeBlock { code, .. } => {
                assert_eq!(code, r#"declare(scalar, out); set(out, "ok"); return(out)"#);
            }
            _ => panic!("expected lifecycle CodeBlock"),
        }
        assert!(
            top.body
                .iter()
                .all(|element| !matches!(element.kind, BodyElementKind::FluentChain { .. })),
            "compact lifecycle fluent chain must not survive as a standalone chain"
        );
    }

    #[test]
    fn parse_lifecycle_compact_fluent_chain_multiline_args_as_code_block() {
        let src = r#"Top::
 I.return({
  "type" => "function_definition_error",
  "source_text" => entry_text()
 })
 /x/
"#;
        let spec = parse_spec(src).unwrap();
        let top = &spec.rules[0];
        let iblock = top
            .body
            .iter()
            .find(|element| {
                matches!(&element.kind, BodyElementKind::CodeBlock { lifecycle, .. } if lifecycle == "I")
            })
            .expect("I block");

        match &iblock.kind {
            BodyElementKind::CodeBlock { code, .. } => {
                assert!(code.starts_with("return({"), "{code:?}");
                assert!(
                    code.contains(r#""type" => "function_definition_error""#),
                    "{code:?}"
                );
                assert!(
                    code.contains(r#""source_text" => entry_text()"#),
                    "{code:?}"
                );
            }
            _ => panic!("expected lifecycle CodeBlock"),
        }
        assert!(
            top.body
                .iter()
                .any(|element| matches!(&element.kind, BodyElementKind::Regex { pattern } if pattern == "x")),
            "regex after multiline compact lifecycle chain was not parsed"
        );
    }

    #[test]
    fn parse_inline_lifecycle_compact_fluent_chain_as_code_block() {
        let src = r#"Top:: /x/ I.return("from_header") E.return("from_e")
"#;
        let spec = parse_spec(src).unwrap();
        let top = &spec.rules[0];

        assert!(matches!(
            &top.body[0].kind,
            BodyElementKind::Regex { pattern } if pattern == "x"
        ));
        assert!(matches!(
            &top.body[1].kind,
            BodyElementKind::CodeBlock { lifecycle, code }
                if lifecycle == "I" && code == r#"return("from_header")"#
        ));
        assert!(matches!(
            &top.body[2].kind,
            BodyElementKind::CodeBlock { lifecycle, code }
                if lifecycle == "E" && code == r#"return("from_e")"#
        ));
        assert!(
            top.body
                .iter()
                .all(|element| !matches!(element.kind, BodyElementKind::FluentChain { .. })),
            "inline lifecycle fluent chains must not survive as standalone chains"
        );
    }

    #[test]
    fn parse_header_rest_lifecycle_block_after_regex_as_code_block() {
        let src = r#"Top:: /x/ I { return(entry_text()) } E { return("done") }
"#;
        let spec = parse_spec(src).unwrap();
        let top = &spec.rules[0];

        assert_eq!(top.body.len(), 3);
        assert!(matches!(
            &top.body[0].kind,
            BodyElementKind::Regex { pattern } if pattern == "x"
        ));
        assert!(matches!(
            &top.body[1].kind,
            BodyElementKind::CodeBlock { lifecycle, code }
                if lifecycle == "I" && code == "return(entry_text())"
        ));
        assert!(matches!(
            &top.body[2].kind,
            BodyElementKind::CodeBlock { lifecycle, code }
                if lifecycle == "E" && code == r#"return("done")"#
        ));
    }

    #[test]
    fn parse_header_rest_multiline_lifecycle_block_before_body_line() {
        let src = r#"Top:: /x/ I {
  declare(scalar, out)
  set(out, "ok")
}
/y/
"#;
        let spec = parse_spec(src).unwrap();
        let top = &spec.rules[0];

        assert_eq!(
            top.body.len(),
            3,
            "header-rest multiline block must consume its continuation before normal body collection"
        );
        assert!(matches!(
            &top.body[0].kind,
            BodyElementKind::Regex { pattern } if pattern == "x"
        ));
        match &top.body[1].kind {
            BodyElementKind::CodeBlock { lifecycle, code } => {
                assert_eq!(lifecycle, "I");
                assert!(code.contains("declare(scalar, out)"));
                assert!(code.contains(r#"set(out, "ok")"#));
            }
            _ => panic!("expected lifecycle CodeBlock"),
        }
        assert!(matches!(
            &top.body[2].kind,
            BodyElementKind::Regex { pattern } if pattern == "y"
        ));
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
            (
                "R5:AND{2,4}",
                RuleMode::AndBounded {
                    min: 2,
                    max: Some(4),
                },
            ),
            (
                "R6:OR{3}",
                RuleMode::OrBounded {
                    min: 3,
                    max: Some(3),
                },
            ),
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
        let edge = spec.rules[0]
            .body
            .iter()
            .find(|e| matches!(&e.kind, BodyElementKind::BlindEdge { .. }))
            .unwrap();
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

    // ── RUST-PARITY.7.5.1 — header-line regex is no longer swallowed ──

    /// Helper: collect the regex patterns a rule registered, in body order.
    fn regex_patterns_of(rule: &Rule) -> Vec<String> {
        rule.body
            .iter()
            .filter_map(|e| match &e.kind {
                BodyElementKind::Regex { pattern } => Some(pattern.clone()),
                _ => None,
            })
            .collect()
    }

    #[test]
    fn header_line_single_regex_is_registered() {
        // `name : /re/` on the header line must register the regex (not drop it).
        // Before .7.5.1 the mode-suffix group `\S*` swallowed `/;/`, leaving the
        // rule with 0 regexes so every dispatch edge to it never fired.
        let spec = parse_spec("Top::\n -> semi\n\nsemi : /;/").unwrap();
        let semi = spec
            .rules
            .iter()
            .find(|r| r.header.label == "semi")
            .unwrap();
        assert_eq!(
            regex_patterns_of(semi),
            vec![";".to_string()],
            "header-line single regex must be registered"
        );
    }

    #[test]
    fn header_line_bracket_pair_registers_open_then_close() {
        // `name : /open/ /close/` must register BOTH regexes in order (open=0,
        // close=1) so the recursive `-> name[1]` close edge resolves. Before
        // .7.5.1 group 3 ate the open delimiter, leaving only the close.
        let spec = parse_spec("Top::\n -> bracket\n\nbracket : /\\(/ /\\)/").unwrap();
        let bracket = spec
            .rules
            .iter()
            .find(|r| r.header.label == "bracket")
            .unwrap();
        assert_eq!(
            regex_patterns_of(bracket),
            vec!["\\(".to_string(), "\\)".to_string()],
            "bracket-pair header must register open then close"
        );
    }

    #[test]
    fn header_line_mode_suffix_still_parsed_without_regex() {
        // The narrowed group 3 is slash-free, so a real mode suffix on the header
        // line is unchanged (regression guard for the fix's scope).
        let spec = parse_spec("Top:AND\n /x/").unwrap();
        assert_eq!(spec.rules[0].header.mode, RuleMode::And);
    }
}
