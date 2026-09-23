//! `.spec` file parser — reads grammar files into structured AST.
//!
//! Parses rule paragraphs: each starts with a rule header (`Label:` or `Label::`)
//! and continues until the next rule header at top-level block depth.
//!
//! Body elements are classified into: regex literals, action edges, blind-call
//! edges, lifecycle code blocks, split markers, fluent chains, and conditionals.
//! Code blocks (`{ ... }`) are properly captured as multi-line content.

use crate::ast::{
    BareEdgeTarget, BodyElement, BodyElementKind, EdgeTarget, FluentCall, RegexSelector, Rule,
    RuleHeader, RuleMode, SpecFile,
};
use crate::error::{LinkedSpecError, Result};
use crate::trace::{TraceConfig, TraceEmitter, TraceLevel};
use crate::unicode_rule_label::take_rule_label_prefix;
use rgx_core::Regex;

/// Parse a `.spec` source string into a `SpecFile` AST.
pub fn parse_spec(source: &str) -> Result<SpecFile> {
    // Retain CR in CRLF lines so block capture can reconstruct authored text.
    let lines: Vec<&str> = source.split_terminator('\n').collect();
    let len = lines.len();
    let mut rules: Vec<Rule> = Vec::new();
    let mut i = skip_blanks_and_comments(&lines, 0);

    while i < len {
        // Try to parse a rule header at the current line
        if let Some((header, next_i)) = parse_rule_header(&lines, i)? {
            let rest = header.rest.trim_start().to_string();
            let mut body_start_i = next_i;
            let mut inline_elements = Vec::new();

            // Parse same-line content (rest) as inline body elements. Do this
            // before collecting following lines so a block opened in the
            // header rest can consume its continuation lines as one element.
            if !rest.is_empty() {
                let mut inline_i = header.line.saturating_sub(1);
                if let Some(parsed_inline) = parse_inline_body(&rest, &lines, &mut inline_i) {
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

    Ok(SpecFile {
        functions: Vec::new(),
        source_id: "inline".to_string(),
        rules,
    })
}

/// Parse a `.spec` source string with explicit trace configuration.
pub fn parse_spec_with_trace(source: &str, trace_config: TraceConfig) -> Result<SpecFile> {
    let mut trace = TraceEmitter::new(trace_config)?;
    parse_spec_with_trace_emitter(source, &mut trace)
}

/// Parse with a caller-owned trace emitter.
pub fn parse_spec_with_trace_emitter(source: &str, trace: &mut TraceEmitter) -> Result<SpecFile> {
    let scope = trace.enter_scope(
        "rust_core:parse_spec",
        format!("bytes={} lines={}", source.len(), source.lines().count()),
        TraceLevel::LOW,
    )?;
    let result = parse_spec(source);
    let exit_details = match &result {
        Ok(spec) => {
            trace.trace_decision(
                "rust_core:parse_spec:result",
                true,
                format!(
                    "rules={} functions={}",
                    spec.rules.len(),
                    spec.functions.len()
                ),
                TraceLevel::MEDIUM,
            );
            format!("status=ok rules={}", spec.rules.len())
        }
        Err(err) => {
            trace.trace_decision(
                "rust_core:parse_spec:result",
                false,
                format!("error={err}"),
                TraceLevel::MEDIUM,
            );
            format!("status=error error={err}")
        }
    };
    trace.exit_scope(scope, exit_details)?;
    result
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
    let trimmed = line.trim_start();

    // The mode suffix stops at whitespace or `/`: consuming `/` here would swallow a
    // `/…/` regex written on the rule's header line (e.g. `name : /re/` or a
    // `/open/ /close/` bracket pair), `parse_mode_suffix` then falls to
    // `RuleMode::Default`, and the regex is silently dropped — the rule registers
    // 0 (or, for a pair, 1) regexes, so every `-> child[N]` dispatch edge never
    // fires (RUST-PARITY.7.5.1). Stopping the class at `/` lets a `/`-led regex
    // fall through to `rest`, where `parse_inline_body` registers it.
    // Every real mode suffix (AND, OR+, &, *, ?, AND{2,4}, …) is slash-free, so
    // this is identical to the old tokenization for all non-regex header content.
    if let Some(fields) = parse_rule_header_fields(trimmed) {
        let parsed_mode = parse_mode_suffix_strict(fields.mode);
        let (mode, rest) = match parsed_mode {
            Some(mode) => (mode, fields.rest.to_string()),
            // An unrecognized candidate belongs to the body. It may end inside
            // a quoted string in compact code, so never rebuild its whitespace.
            None => (RuleMode::Default, fields.after_colon.to_string()),
        };
        Ok(Some((
            RuleHeader {
                label: fields.label,
                is_top: fields.is_top,
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

struct RuleHeaderFields<'a> {
    label: String,
    is_top: bool,
    mode: &'a str,
    rest: &'a str,
    after_colon: &'a str,
}

/// Split one complete rule-header prefix using the pinned Unicode label class.
fn parse_rule_header_fields(trimmed: &str) -> Option<RuleHeaderFields<'_>> {
    let (label, after_label) = take_rule_label_prefix(trimmed)?;
    let after_label = after_label.trim_start_matches([' ', '\t']);
    let (is_top, after_colon) = if let Some(rest) = after_label.strip_prefix("::") {
        (true, rest)
    } else if let Some(rest) = after_label.strip_prefix(':') {
        (false, rest)
    } else {
        return None;
    };
    let after_colon = after_colon.trim_start_matches([' ', '\t']);
    let mode_end = after_colon
        .char_indices()
        .find_map(|(offset, character)| {
            (character.is_whitespace() || character == '/').then_some(offset)
        })
        .unwrap_or(after_colon.len());
    let mode = &after_colon[..mode_end];
    let rest = after_colon[mode_end..].trim_start_matches([' ', '\t']);
    Some(RuleHeaderFields {
        label: label.to_string(),
        is_top,
        mode,
        rest,
        after_colon,
    })
}

/// Parse a mode suffix only when the token is a recognized mode.
///
/// Header-rest content can start with ordinary body syntax (`-> Child`,
/// `I.return(...)`, `/regex/`, ...). The header scanner captures the first
/// non-space, non-slash token after `:`/`::`; unrecognized tokens must be
/// restored to the body rest instead of silently discarded as default mode.
fn parse_mode_suffix_strict(raw: &str) -> Option<RuleMode> {
    if raw.is_empty() {
        return Some(RuleMode::Default);
    }
    if let Some((base, min, max)) = parse_bounded(raw) {
        return match base {
            "AND" => Some(RuleMode::AndBounded { min, max }),
            "OR" => Some(RuleMode::OrBounded { min, max }),
            _ => None,
        };
    }
    Some(match raw {
        "AND" => RuleMode::And,
        "AND+" => RuleMode::AndPlus,
        "OR" => RuleMode::Or,
        "OR+" => RuleMode::OrPlus,
        "&" => RuleMode::Single,
        "|" => RuleMode::Pipe,
        "+" => RuleMode::Plus,
        "*" => RuleMode::Star,
        "?" => RuleMode::Optional,
        _ => return None,
    })
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
fn parse_inline_body(rest: &str, lines: &[&str], i: &mut usize) -> Option<Vec<BodyElement>> {
    let mut elements = Vec::new();
    let mut remaining = rest.trim_start().to_string();
    let mut remaining_origin_i = *i;

    while !remaining.is_empty() {
        let trimmed = remaining.trim_start().to_string();
        if trimmed.is_empty() || trimmed.starts_with('#') {
            break;
        }

        let before = trimmed.clone();
        let mut element_i = remaining_origin_i;
        let Some((element, remainder, _advanced)) = parse_single_element(
            &trimmed,
            lines,
            &mut element_i,
            remaining_origin_i + 1,
            elements.is_empty(),
        ) else {
            break;
        };
        // The remainder can start on a consumed block's closing line, while
        // the caller's cursor must stay beyond every fully consumed line.
        *i = (*i).max(element_i);
        remaining_origin_i = block_remainder_origin(remaining_origin_i, element_i, &remainder);
        elements.push(element);
        remaining = remainder;
        if remaining.trim_start() == before {
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
        if parse_rule_header_fields(trimmed).is_some() {
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

    // First, try to split the line by looking for the first recognized element,
    // consume it, then try again with the remainder. Multi-line blocks advance `i`.
    let mut remaining = line.trim_start().to_string();
    let mut remaining_origin_i = *i;
    let mut consumed_line = false;

    loop {
        let trimmed = remaining.trim_start().to_string();
        if trimmed.is_empty() || trimmed.starts_with('#') {
            break;
        }

        let mut element_i = remaining_origin_i;
        if let Some((element, rest, advanced)) = parse_single_element(
            &trimmed,
            lines,
            &mut element_i,
            remaining_origin_i + 1,
            elements.is_empty(),
        ) {
            *i = (*i).max(element_i);
            remaining_origin_i = block_remainder_origin(remaining_origin_i, element_i, &rest);
            elements.push(element);
            remaining = rest;
            if advanced {
                consumed_line = true;
            }
            if remaining.trim().is_empty() {
                break;
            }
        } else {
            // Preserve an unsupported suffix after lifecycle I so validation
            // can reject explicit and shorthand twins equivalently. Other Raw
            // compatibility carriers retain their established behavior.
            if matches!(
                elements.last().map(|element| &element.kind),
                Some(BodyElementKind::CodeBlock { lifecycle, .. }) if lifecycle == "I"
            ) {
                elements.push(BodyElement::new(
                    BodyElementKind::Raw {
                        text: trimmed.clone(),
                    },
                    &trimmed,
                    remaining_origin_i + 1,
                ));
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
    allow_bare_edge: bool,
) -> Option<(BodyElement, String, bool)> {
    // Regex patterns for classification (order matters!)
    let re_regex = Regex::compile(r"^/([^/\\]*(?:\\.[^/\\]*)*)/").unwrap();
    let re_lifecycle = Regex::compile(r"^(I|LS|LE|LX|E|EX|IT)\b").unwrap();
    let re_split = Regex::compile(
        r"^@[ \t]*(capture_slice|capture_from_here|move_pos|mark[ \t]*\([ \t]*\w+[ \t]*\))",
    )
    .unwrap();
    let re_conditional = Regex::compile(r"^-\?[ \t]+\w+").unwrap();
    let re_fluent = Regex::compile(r"^\.[ \t]*\w+").unwrap();

    // 1. Named regex declaration: `name HSPACE* = HSPACE* /pattern/`.
    // Retain invalid non-whitespace names too so validation can issue the
    // contract diagnostic with exact line/source evidence.
    if let Some((slot_id, pattern, match_end)) = parse_named_regex_declaration(trimmed) {
        let remainder = trimmed[match_end..].to_string();
        let elem = BodyElement::new(
            BodyElementKind::Regex {
                pattern,
                slot_id: Some(slot_id),
            },
            &trimmed[..match_end],
            line_num,
        );
        return Some((elem, remainder, false));
    }

    // 2. Anonymous regex literal: `/pattern/`
    if let Some(caps) = re_regex.captures(trimmed) {
        let full_match = caps.get(0).unwrap();
        let pattern = caps.get(1).unwrap().as_str().to_string();
        let remainder = trimmed[full_match.end()..].to_string();
        let elem = BodyElement::new(
            BodyElementKind::Regex {
                pattern,
                slot_id: None,
            },
            full_match.as_str(),
            line_num,
        );
        return Some((elem, remainder, false));
    }

    // 3. Action edge: `-> Target` or `-> Target1 | Target2` optionally with block
    if let Some((targets, match_end)) = parse_action_edge_prefix(trimmed) {
        let full_match = &trimmed[..match_end];
        let rest = trimmed[match_end..].trim_start().to_string();

        let saved_i = *i;
        if let Some((code, remainder)) = parse_attached_fluent_when_chain(lines, i, &rest) {
            let elem = BodyElement::new(
                BodyElementKind::ActionEdge {
                    targets,
                    code: Some(code),
                    fluent_chain: Vec::new(),
                },
                full_match,
                line_num,
            );
            let advanced = *i > saved_i;
            return Some((elem, remainder, advanced));
        } else if rest.starts_with('{') {
            // Block may span multiple lines — consume_block_from_rest advances `i`.
            let saved_i = *i;
            let block = consume_block_from_rest(lines, i, &rest)?;
            let elem = BodyElement::new(
                BodyElementKind::ActionEdge {
                    targets,
                    code: Some(block.code),
                    fluent_chain: Vec::new(),
                },
                full_match,
                line_num,
            );
            let advanced = *i > saved_i;
            return Some((elem, block.remainder, advanced));
        } else {
            let (fluent_chain, remainder) = parse_fluent_chain_with_remainder(&rest);
            let elem = BodyElement::new(
                BodyElementKind::ActionEdge {
                    targets,
                    code: None,
                    fluent_chain,
                },
                full_match,
                line_num,
            );
            return Some((elem, remainder, false));
        }
    }

    // 4. Blind-call edge: `=> Target` optionally with block
    if let Some((target, index, match_end)) = parse_blind_edge_prefix(trimmed) {
        let full_match = &trimmed[..match_end];
        let rest = trimmed[match_end..].trim_start().to_string();

        let (code, fluent_chain, advanced, remainder) = if rest.starts_with('{') {
            let saved_i = *i;
            let block = consume_block_from_rest(lines, i, &rest)?;
            (Some(block.code), Vec::new(), *i > saved_i, block.remainder)
        } else {
            let (chain, rem) = parse_fluent_chain_with_remainder(&rest);
            (None, chain, false, rem)
        };

        let elem = BodyElement::new(
            BodyElementKind::BlindEdge {
                target,
                index,
                code,
                fluent_chain,
            },
            full_match,
            line_num,
        );
        return Some((elem, remainder, advanced));
    }

    // 5. Lifecycle code block: `I { ... }`, `I.return(...)`, or bare marker
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
            let block = consume_block_from_rest(lines, i, &rest)?;
            let suffix = &trimmed[full_match.end()..];
            let brace_offset = suffix.find('{')?;
            let source = format!(
                "{}{}{}",
                full_match.as_str(),
                &suffix[..brace_offset],
                block.source
            );
            let elem = BodyElement::new(
                BodyElementKind::CodeBlock {
                    lifecycle: marker.clone(),
                    code: block.code,
                },
                &source,
                line_num,
            );
            let advanced = *i > saved_i;
            return Some((elem, block.remainder, advanced));
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

    // 6. Dedicated inter-match gap directive. The complete static eligibility
    // and duplicate checks run after whole-spec parsing.
    if let Some(remainder) = trimmed.strip_prefix("@capture_gaps")
        && remainder
            .chars()
            .next()
            .is_none_or(|character| character.is_whitespace() || character == '#')
    {
        let elem = BodyElement::new(
            BodyElementKind::CaptureGapsDirective {
                directive: "@capture_gaps".to_string(),
            },
            "@capture_gaps",
            line_num,
        );
        return Some((elem, remainder.to_string(), false));
    }

    // 7. Legacy split marker
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

    // 8. Conditional: `-? word`
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

    // 9. Fluent chain
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

    // 10. Standalone rule-item block: direct syntax sugar for lifecycle `I`.
    // The dormant PlainBlock variant remains readable for compatibility, but
    // source parsing no longer emits it.
    if trimmed.starts_with('{') {
        let saved_i = *i;
        let block = consume_block_from_rest(lines, i, trimmed)?;
        let elem = BodyElement::new(
            BodyElementKind::CodeBlock {
                lifecycle: "I".to_string(),
                code: block.code,
            },
            &block.source,
            line_num,
        );
        let advanced = *i > saved_i;
        return Some((elem, block.remainder, advanced));
    }

    // 11. Bare rule edge. It is deliberately admitted only for the first
    // physical-line element; `/regex/ Child` and `I Child` must not turn their
    // suffix into a line-level edge.
    if allow_bare_edge && let Some(parsed) = parse_bare_edge(trimmed, lines, i, line_num) {
        return Some(parsed);
    }

    // 12. Fallback: not a recognized element
    None
}

fn parse_named_regex_declaration(input: &str) -> Option<(String, String, usize)> {
    // Anonymous regex syntax has priority. In particular, `/=/ /next/` is two
    // ordinary regex declarations, not an invalid named declaration whose
    // supposed name is `/`.
    if input.starts_with('/') {
        return None;
    }
    let equals = input.find('=')?;
    let name = input[..equals].trim_end_matches([' ', '\t']);
    if name.is_empty() || name.chars().any(char::is_whitespace) {
        return None;
    }
    let regex_start = skip_horizontal_space(input, equals + 1);
    let regex = Regex::compile(r"^/([^/\\]*(?:\\.[^/\\]*)*)/").unwrap();
    let captures = regex.captures(input.get(regex_start..)?)?;
    let full_match = captures.get(0)?;
    let pattern = captures.get(1)?.as_str().to_string();
    Some((name.to_string(), pattern, regex_start + full_match.end()))
}

/// Parse one complete-line bare rule edge while retaining unresolved target
/// and suffix facts for whole-spec validation.
fn parse_bare_edge(
    trimmed: &str,
    lines: &[&str],
    i: &mut usize,
    line_num: usize,
) -> Option<(BodyElement, String, bool)> {
    let (targets, targets_end) = parse_bare_target_list_prefix(trimmed)?;

    let start_i = *i;
    let mut rest = trimmed[targets_end..].trim_start().to_string();
    let mut code = None;
    let mut fluent_chain = Vec::new();

    if rest.starts_with('.') {
        let (calls, remainder) = parse_fluent_chain_with_remainder(&rest);
        if calls.is_empty() {
            return None;
        }
        fluent_chain = calls;
        rest = remainder.trim_start().to_string();
    }

    if rest.starts_with('{') {
        let block = consume_block_from_rest(lines, i, &rest)?;
        code = Some(block.code);
        rest = block.remainder.trim_start().to_string();
    }

    if !rest.is_empty() && !rest.starts_with('#') {
        *i = start_i;
        return None;
    }

    let advanced = *i > start_i;
    let element = BodyElement::new(
        BodyElementKind::BareEdge {
            targets,
            code,
            fluent_chain,
        },
        trimmed,
        line_num,
    );
    Some((element, String::new(), advanced))
}

/// Parse the label group and shared optional index at the start of an action edge.
fn parse_action_edge_prefix(input: &str) -> Option<(Vec<EdgeTarget>, usize)> {
    let mut offset = input
        .strip_prefix("->")
        .map(|rest| input.len() - rest.len())?;
    offset = skip_horizontal_space(input, offset);
    let mut labels = Vec::new();
    loop {
        let (label, after_label) = take_rule_label_at(input, offset)?;
        labels.push(label.to_string());
        offset = after_label;

        let after_space = skip_horizontal_space(input, offset);
        if input[after_space..].starts_with('|') {
            let next_target = skip_horizontal_space(input, after_space + 1);
            if take_rule_label_at(input, next_target).is_some() {
                offset = next_target;
                continue;
            }
        }
        break;
    }

    // Preserve the established action syntax: `[N]` is adjacent to the final
    // label and applies to every target in the group.
    let (selector, match_end) = parse_selector_at(input, offset, false);
    let index = selector.compatibility_index();
    let targets = labels
        .into_iter()
        .map(|label| EdgeTarget {
            label,
            index,
            selector: selector.clone(),
        })
        .collect();
    Some((targets, match_end))
}

/// Parse the target and optional spaced index at the start of a blind edge.
fn parse_blind_edge_prefix(input: &str) -> Option<(String, Option<usize>, usize)> {
    let mut offset = input
        .strip_prefix("=>")
        .map(|rest| input.len() - rest.len())?;
    offset = skip_horizontal_space(input, offset);
    let (label, after_label) = take_rule_label_at(input, offset)?;
    let (index, match_end) = match parse_index_at(input, after_label, true) {
        Some((index, end)) => (Some(index), end),
        None => (None, after_label),
    };
    Some((label.to_string(), index, match_end))
}

/// Parse a grouped bare-edge target list, retaining each optional target index.
fn parse_bare_target_list_prefix(input: &str) -> Option<(Vec<BareEdgeTarget>, usize)> {
    let mut offset = 0;
    let mut targets = Vec::new();
    loop {
        let (label, after_label) = take_rule_label_at(input, offset)?;
        let (selector, after_target) = parse_selector_at(input, after_label, true);
        let index = match selector {
            RegexSelector::Numeric(index) => Some(index),
            _ => None,
        };
        targets.push(BareEdgeTarget {
            label: label.to_string(),
            index,
            selector,
        });
        offset = after_target;

        let after_space = skip_horizontal_space(input, offset);
        if input[after_space..].starts_with('|') {
            let next_target = skip_horizontal_space(input, after_space + 1);
            if take_rule_label_at(input, next_target).is_some() {
                offset = next_target;
                continue;
            }
        }
        break;
    }
    Some((targets, offset))
}

fn take_rule_label_at(input: &str, offset: usize) -> Option<(&str, usize)> {
    let (label, rest) = take_rule_label_prefix(input.get(offset..)?)?;
    Some((label, input.len() - rest.len()))
}

/// Parse `[N]` at `offset`; with `allow_space`, horizontal space may precede it.
fn parse_index_at(input: &str, offset: usize, allow_space: bool) -> Option<(usize, usize)> {
    let bracket = if allow_space {
        skip_horizontal_space(input, offset)
    } else {
        offset
    };
    input.get(bracket..)?.strip_prefix('[')?;
    let mut cursor = bracket + 1;
    cursor = skip_horizontal_space(input, cursor);
    let digits_start = cursor;
    while input.as_bytes().get(cursor).is_some_and(u8::is_ascii_digit) {
        cursor += 1;
    }
    if cursor == digits_start {
        return None;
    }
    let index = input[digits_start..cursor].parse().ok()?;
    cursor = skip_horizontal_space(input, cursor);
    input.get(cursor..)?.strip_prefix(']')?;
    let end = cursor + 1;
    Some((index, end))
}

/// Parse an optional unindexed/numeric/named selector while retaining malformed
/// bracket evidence for whole-spec diagnostics.
fn parse_selector_at(input: &str, offset: usize, allow_space: bool) -> (RegexSelector, usize) {
    let bracket = if allow_space {
        skip_horizontal_space(input, offset)
    } else {
        offset
    };
    if !input
        .get(bracket..)
        .is_some_and(|rest| rest.starts_with('['))
    {
        return (RegexSelector::Unindexed, offset);
    }

    let content_start = bracket + 1;
    if let Some(relative_close) = input[content_start..].find(']') {
        let close = content_start + relative_close;
        let authored = input[content_start..close].trim().to_string();
        let selector = if !authored.is_empty() && authored.bytes().all(|byte| byte.is_ascii_digit())
        {
            authored
                .parse::<usize>()
                .map(RegexSelector::Numeric)
                .unwrap_or_else(|_| RegexSelector::Invalid(authored.clone()))
        } else if crate::unicode_rule_label::is_rule_label(&authored) {
            RegexSelector::Named(authored)
        } else {
            RegexSelector::Invalid(authored)
        };
        return (selector, close + 1);
    }

    let mut end = content_start;
    for (relative, character) in input[content_start..].char_indices() {
        if character.is_whitespace() || matches!(character, '{' | '.' | '|') {
            break;
        }
        end = content_start + relative + character.len_utf8();
    }
    let authored = input[content_start..end].trim().to_string();
    (RegexSelector::Invalid(authored), end)
}

fn skip_horizontal_space(input: &str, mut offset: usize) -> usize {
    while matches!(input.as_bytes().get(offset), Some(b' ' | b'\t')) {
        offset += 1;
    }
    offset
}

struct ConsumedBlock {
    code: String,
    remainder: String,
    source: String,
}

/// Consume a `{ ... }` block that starts in `rest` and may continue on subsequent lines.
/// `i` is the CURRENT line index (the line containing the opening `{`).
/// Returns the interior with only its outer whitespace trimmed, the same-line
/// remainder, and exact block source. Interior line endings and spacing survive.
/// Advances `i` past any lines consumed.
fn consume_block_from_rest(lines: &[&str], i: &mut usize, rest: &str) -> Option<ConsumedBlock> {
    let start_brace = rest.find('{')?;
    let remainder = &rest[start_brace + 1..]; // everything after opening `{`
    let mut depth: i32 = 1;
    let mut source = rest[start_brace..].to_string();

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
        let after_block = remainder[remainder_scan.len()..].trim_start().to_string();
        source.truncate(1 + remainder_scan.len());
        return Some(ConsumedBlock {
            code: block_content,
            remainder: after_block,
            source,
        });
    }
    // Block continues past this line — include the remainder
    let mut content = remainder_scan.to_string();

    // Consume subsequent lines
    *i += 1; // advance to next line
    while *i < lines.len() && depth > 0 {
        let line = lines[*i];
        let line_scan = scan_line_for_braces_chars(line, &mut depth);
        source.push('\n');
        source.push_str(line_scan);
        if depth == 0 {
            // Closing brace found on this line
            let strip_close = if line_scan.ends_with('}') {
                &line_scan[..line_scan.len() - 1]
            } else {
                line_scan
            };
            content.push('\n');
            content.push_str(strip_close);
            *i += 1;
            let after_block = line[line_scan.len()..].trim_start().to_string();
            return Some(ConsumedBlock {
                code: content.trim().to_string(),
                remainder: after_block,
                source,
            });
        }
        // Include the whole line
        content.push('\n');
        content.push_str(line);
        *i += 1;
    }
    // Unclosed block (validator catches this)
    Some(ConsumedBlock {
        code: content.trim().to_string(),
        remainder: String::new(),
        source,
    })
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
    let when_block = consume_block_from_rest(lines, i, &remaining)?;
    let mut code = format!(
        "when({}) {{ {} }}",
        condition.trim(),
        when_block.code.trim()
    );
    remaining = when_block.remainder;
    let mut remaining_origin_i = block_remainder_origin(when_start_i, *i, &remaining);

    while let Some(after_keyword) = strip_optional_dot_keyword(&remaining, "otherwise") {
        let tail = after_keyword.trim_start();
        if !tail.starts_with('{') {
            break;
        }

        let block_origin_i = remaining_origin_i;
        let current_floor_i = *i;
        let mut block_i = block_origin_i;
        let otherwise_block = consume_block_from_rest(lines, &mut block_i, tail)?;
        code.push_str(" otherwise { ");
        code.push_str(otherwise_block.code.trim());
        code.push_str(" }");
        remaining = otherwise_block.remainder;
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
    let code = fluent_calls_to_statement_code(&calls)?;
    let advanced = *i > start_i;
    if advanced {
        // Match the braced-block cursor contract: point past consumed lines.
        *i += 1;
    }
    Some((code, remainder, advanced))
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
    let mut quote: Option<char> = None;
    let mut escaped = false;

    for (idx, ch) in text.char_indices() {
        if let Some(quote_ch) = quote {
            if escaped {
                escaped = false;
                continue;
            }
            if ch == '\\' {
                escaped = true;
                continue;
            }
            if ch == quote_ch {
                quote = None;
            }
            continue;
        }

        match ch {
            '"' | '\'' => quote = Some(ch),
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
    fn anonymous_equals_regex_keeps_priority_over_named_declaration() {
        let spec = parse_spec("Top: /=/ /next/").expect("parse anonymous equals regexes");
        let patterns = spec.rules[0]
            .body
            .iter()
            .filter_map(|element| match &element.kind {
                BodyElementKind::Regex { pattern, .. } => Some(pattern.as_str()),
                _ => None,
            })
            .collect::<Vec<_>>();
        assert_eq!(patterns, ["=", "next"]);
    }

    #[test]
    fn parse_zero_rule_envelope_for_structural_validation() {
        for source in ["", "\n# no rule declarations\n\n"] {
            let spec = parse_spec(source).unwrap();
            assert!(spec.functions.is_empty());
            assert!(spec.rules.is_empty());
        }
    }

    #[test]
    fn parse_still_rejects_non_rule_content_before_any_rule() {
        let error = parse_spec("not a rule\n").unwrap_err().to_string();
        assert!(error.contains("expected rule definition"), "{error}");
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
        let src = "Top::\n /a/ I {\n  set(results, [])\n}\n E { return(42) }";
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
        let src = "Top::\n /x/ I { set(results, []) }";
        let spec = parse_spec(src).unwrap();
        let iblock = spec.rules[0].body.iter().find(|e| {
            matches!(&e.kind, BodyElementKind::CodeBlock { lifecycle, .. } if lifecycle == "I")
        }).unwrap();
        match &iblock.kind {
            BodyElementKind::CodeBlock { code, .. } => {
                assert!(code.contains("set(results, [])"));
            }
            _ => panic!("expected CodeBlock"),
        }
    }

    #[test]
    fn parse_multiline_code_block() {
        let src = "Top::\n /a/ I {\n  set(results, [])\n  count = 0\n}";
        let spec = parse_spec(src).unwrap();
        match &spec.rules[0].body[1].kind {
            BodyElementKind::CodeBlock { code, lifecycle } => {
                assert_eq!(lifecycle, "I");
                assert!(code.contains("set(results, [])"));
                assert!(code.contains("count = 0"));
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
 -> Child[1] .return(array("?child:", copy(Child)))

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
                assert_eq!(fluent_chain[0].args, r#"array("?child:", copy(Child))"#);
            }
            _ => panic!("expected ActionEdge"),
        }
    }

    #[test]
    fn parse_header_rest_action_edge_with_fluent_chain() {
        let src = r#"Top:: -> Child .push

Child: /x/
"#;
        let spec = parse_spec(src).unwrap();
        let top = &spec.rules[0];
        assert_eq!(top.header.mode, RuleMode::Default);
        assert_eq!(top.header.rest, "-> Child .push");
        assert_eq!(top.body.len(), 1);

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
    }

    #[test]
    fn parse_header_rest_action_edge_allows_no_space_after_arrow() {
        let src = r#"Top::->Child.push

Child: /x/
"#;
        let spec = parse_spec(src).unwrap();
        let top = &spec.rules[0];
        assert_eq!(top.header.mode, RuleMode::Default);
        assert_eq!(top.header.rest, "->Child.push");
        assert_eq!(top.body.len(), 1);

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
 I.set(out, undef).set(out, "ok").return(out)
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
                assert_eq!(code, r#"set(out, undef); set(out, "ok"); return(out)"#);
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
  "type" : "function_definition_error",
  "source_text" : entry_text()
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
                    code.contains(r#""type" : "function_definition_error""#),
                    "{code:?}"
                );
                assert!(code.contains(r#""source_text" : entry_text()"#), "{code:?}");
            }
            _ => panic!("expected lifecycle CodeBlock"),
        }
        assert!(
            top.body
                .iter()
                .any(|element| matches!(&element.kind, BodyElementKind::Regex { pattern, .. } if pattern == "x")),
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
            BodyElementKind::Regex { pattern, .. } if pattern == "x"
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
            BodyElementKind::Regex { pattern, .. } if pattern == "x"
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
  set(out, undef)
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
            BodyElementKind::Regex { pattern, .. } if pattern == "x"
        ));
        match &top.body[1].kind {
            BodyElementKind::CodeBlock { lifecycle, code } => {
                assert_eq!(lifecycle, "I");
                assert!(code.contains("set(out, undef)"));
                assert!(code.contains(r#"set(out, "ok")"#));
            }
            _ => panic!("expected lifecycle CodeBlock"),
        }
        assert!(matches!(
            &top.body[2].kind,
            BodyElementKind::Regex { pattern, .. } if pattern == "y"
        ));
    }

    #[test]
    fn parse_nested_braces_in_code() {
        let src = "Top::\n /a/ I {\n  if(cond) {\n    push(arr, val)\n  }\n}";
        let spec = parse_spec(src).unwrap();
        match &spec.rules[0].body[1].kind {
            BodyElementKind::CodeBlock { code, .. } => {
                assert!(code.contains("if(cond)"));
                assert!(code.contains("push(arr, val)"));
            }
            _ => panic!("expected CodeBlock"),
        }
    }

    #[test]
    fn parse_code_blocks_ignore_braces_inside_strings() {
        let src = r#"Top::
 /a/ I { print("literal { brace"); print('literal } brace') }
 /b/ E { return("ok") }
"#;
        let spec = parse_spec(src).unwrap();
        match &spec.rules[0].body[1].kind {
            BodyElementKind::CodeBlock { code, .. } => {
                assert!(code.contains(r#"print("literal { brace")"#));
                assert!(code.contains(r#"print('literal } brace')"#));
                crate::expr::CodeBlock::parse(code).expect("code block with quoted braces parses");
            }
            _ => panic!("expected CodeBlock"),
        }
        assert!(matches!(
            &spec.rules[0].body[2].kind,
            BodyElementKind::Regex { pattern, .. } if pattern == "b"
        ));
    }

    #[test]
    fn parse_operators_try_debug_strings_with_braces() {
        let spec = parse_spec(include_str!("../../../specs/operators_try.spec")).unwrap();
        for (label, expected) in [
            ("group", r#"print("-> {start-group\n")"#),
            (
                "function_call",
                r#"print("-> (", entry_text(), ") {start-function_call\n")"#,
            ),
            ("string", r#"print("-> {start-string\n")"#),
        ] {
            let rule = spec
                .rules
                .iter()
                .find(|rule| rule.header.label == label)
                .unwrap_or_else(|| panic!("missing {label} rule"));
            let code = rule
                .body
                .iter()
                .find_map(|element| match &element.kind {
                    BodyElementKind::CodeBlock { lifecycle, code } if lifecycle == "I" => {
                        Some(code)
                    }
                    _ => None,
                })
                .unwrap_or_else(|| panic!("missing {label} I block"));
            assert_eq!(code, expected);
            crate::expr::CodeBlock::parse(code)
                .unwrap_or_else(|err| panic!("{label} I block failed to parse: {err}"));
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
    fn parse_blind_edge_allows_no_space_after_arrow() {
        let src = "Top::\n /a/ =>Child";
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
                BodyElementKind::Regex { pattern, .. } => Some(pattern.clone()),
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
