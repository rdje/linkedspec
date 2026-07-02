//! Validation passes for parsed `.spec` AST.
//!
//! Checks performed (every mode):
//! 1. At least one top rule (`::`) exists
//! 2. No duplicate rule labels
//! 3. User-function names are unique and do not collide with rule labels,
//!    lifecycle markers, reserved runtime symbols, or built-in helper/control names
//! 4. User-function parameters are valid, unique, and not reserved runtime symbols
//! 5. No rule mixes action (`->`) and blind-call (`=>`) edges
//! 6. All `{` blocks are balanced (no unclosed blocks)
//! 7. All edge targets reference existing rules
//! 8. Rule headers are not inside open blocks (handled by parser)
//!
//! Strict mode (`validate_with_options(spec, strict_syntax = true)`) promotes the
//! Perl reference's *reference warnings* to hard errors:
//! 9. No unused rules — every defined rule must be referenced by some edge (the
//!    top rule is NOT exempt, matching `Validation.pm`'s strict_syntax check).
//!
//! Note: undefined references are a hard error here in *every* mode (check 5),
//! which is stricter than the Perl reference's default (it warns, and only
//! `strict_syntax` makes them fatal). Strict mode keeps them fatal too, so the
//! observable addition of strict mode in this backend is the unused-rule check;
//! the Perl ordering (undefined reported before unused) is preserved because
//! check 5 runs before the strict check.

use crate::ast::{BodyElementKind, SpecFile};
use crate::error::{LinkedSpecError, Result};
use rgx_core::Regex;
use std::collections::HashSet;

/// Run all (non-strict) validation passes on a parsed spec.
pub fn validate(spec: &SpecFile) -> Result<()> {
    validate_with_options(spec, false)
}

/// Run validation passes, optionally in strict mode.
///
/// `strict_syntax` mirrors the Perl reference's `validate_dsl_syntax(...,
/// strict_syntax => 1)`: the reference warnings (undefined references, unused
/// rules) become hard errors. Undefined references are already fatal here in
/// every mode (`check_edge_targets`, which runs first — matching the reference's
/// "undefined before unused" order), so strict mode's observable addition is the
/// unused-rule rejection.
pub fn validate_with_options(spec: &SpecFile, strict_syntax: bool) -> Result<()> {
    check_top_rule_exists(spec)?;
    check_duplicate_labels(spec)?;
    check_duplicate_function_names(spec)?;
    check_function_registry(spec)?;
    check_mixed_edges(spec)?;
    check_balanced_braces(spec)?;
    check_edge_targets(spec)?;
    check_regex_syntax(spec)?;
    if strict_syntax {
        check_unused_rules(spec)?;
    }
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

fn check_duplicate_function_names(spec: &SpecFile) -> Result<()> {
    let mut seen = HashSet::new();
    for function in &spec.functions {
        if !seen.insert(function.name.as_str()) {
            return Err(LinkedSpecError::Validation(format!(
                "duplicate user function definition '{}'",
                function.name
            )));
        }
    }
    Ok(())
}

fn check_function_registry(spec: &SpecFile) -> Result<()> {
    let rule_labels: HashSet<&str> = spec.rules.iter().map(|r| r.header.label.as_str()).collect();

    for function in &spec.functions {
        let name = function.name.as_str();
        if !is_identifier(name) {
            return Err(LinkedSpecError::Validation(format!(
                "invalid user function name '{}'",
                function.name
            )));
        }
        if rule_labels.contains(name) {
            return Err(LinkedSpecError::Validation(format!(
                "user function '{}' collides with rule label '{}'",
                function.name, function.name
            )));
        }
        if is_reserved_runtime_symbol(name) {
            return Err(LinkedSpecError::Validation(format!(
                "user function '{}' uses a reserved runtime symbol",
                function.name
            )));
        }
        if is_lifecycle_marker_name(name) {
            return Err(LinkedSpecError::Validation(format!(
                "user function '{}' collides with lifecycle marker '{}'",
                function.name, function.name
            )));
        }
        if is_function_keyword(name) || is_known_actionir_call_name(name) {
            return Err(LinkedSpecError::Validation(format!(
                "user function '{}' collides with built-in helper/control name '{}'",
                function.name, function.name
            )));
        }

        let mut seen_params = HashSet::new();
        for param in &function.params {
            if !is_identifier(param) {
                return Err(LinkedSpecError::Validation(format!(
                    "user function '{}' has invalid parameter '{}'",
                    function.name, param
                )));
            }
            if !seen_params.insert(param.as_str()) {
                return Err(LinkedSpecError::Validation(format!(
                    "duplicate parameter '{}' in function '{}'",
                    param, function.name
                )));
            }
            if is_reserved_runtime_symbol(param)
                || is_lifecycle_marker_name(param)
                || is_function_keyword(param)
            {
                return Err(LinkedSpecError::Validation(format!(
                    "user function '{}' parameter '{}' is reserved",
                    function.name, param
                )));
            }
        }
    }
    Ok(())
}

fn is_identifier(value: &str) -> bool {
    let mut chars = value.chars();
    let Some(first) = chars.next() else {
        return false;
    };
    (first.is_ascii_alphabetic() || first == '_')
        && chars.all(|ch| ch.is_ascii_alphanumeric() || ch == '_')
}

fn is_function_keyword(name: &str) -> bool {
    matches!(name, "fn" | "return")
}

fn is_lifecycle_marker_name(name: &str) -> bool {
    matches!(name, "I" | "LS" | "LE" | "E" | "EX" | "IT" | "LX")
}

fn is_reserved_runtime_symbol(name: &str) -> bool {
    matches!(
        name,
        "STRING"
            | "descr"
            | "minfo"
            | "LSPOS"
            | "LEPOS"
            | "LMATCH"
            | "LSMATCH"
            | "IMATCH"
            | "IMATCH_LIST"
            | "LMATCH_LIST"
            | "IMATCH_HASH"
            | "LMATCH_HASH"
            | "SELF"
            | "this"
            | "ctx"
            | "runtime_ctx"
    )
}

fn is_known_actionir_call_name(name: &str) -> bool {
    is_numeric_word_alias_name(name)
        || matches!(
            name,
            "array"
                | "array_copy"
                | "assign"
                | "BACKTRACK"
                | "call"
                | "capture_between"
                | "capture_from"
                | "capture_len_between"
                | "capture_len_from"
                | "capture_rest"
                | "capture_rest_from"
                | "capture_rest_len"
                | "capture_rest_len_from"
                | "capture_slice"
                | "capture_slice_len"
                | "capture_slice_line"
                | "capture_slice_pos"
                | "capture_slice_until_cursor"
                | "capture_slice_until_cursor_len"
                | "capture_take"
                | "capture_take_len"
                | "capture_take_len_from"
                | "capture_take_rest"
                | "capture_take_rest_from"
                | "capture_take_rest_len"
                | "capture_take_rest_len_from"
                | "capture_take_until_cursor"
                | "capture_take_until_cursor_from"
                | "capture_take_until_cursor_len"
                | "capture_take_until_cursor_len_from"
                | "capture_until_cursor_from"
                | "capture_until_cursor_len_from"
                | "case"
                | "cat"
                | "coalesce"
                | "coalesce_nonempty"
                | "concat"
                | "concat_arrays"
                | "contains"
                | "contains_substr"
                | "copy"
                | "count"
                | "count_keys"
                | "cursor_col"
                | "cursor_line"
                | "cursor_pos"
                | "cursor_rest"
                | "cursor_rest_len"
                | "declare"
                | "default"
                | "drop_back"
                | "drop_front"
                | "drop_keys"
                | "else"
                | "elseif"
                | "endcase"
                | "endif"
                | "ends_with"
                | "endswitch"
                | "entry_col"
                | "entry_end_pos"
                | "entry_group"
                | "entry_groups"
                | "entry_has"
                | "entry_len"
                | "entry_line"
                | "entry_map"
                | "entry_named"
                | "entry_named_map"
                | "entry_start_line"
                | "entry_start_pos"
                | "entry_text"
                | "exit_now"
                | "filter_match"
                | "filter_nonempty"
                | "first"
                | "flat"
                | "flat_array"
                | "flat_hash"
                | "has_key"
                | "hash"
                | "hash_copy"
                | "IBACKTRACK"
                | "if"
                | "index_of"
                | "input_end_col"
                | "input_end_line"
                | "input_end_pos"
                | "input_len"
                | "input_slice"
                | "input_text"
                | "is_defined"
                | "is_empty"
                | "is_nonempty"
                | "is_undefined"
                | "join_values"
                | "last"
                | "length"
                | "lowercase"
                | "lowercase_each"
                | "mark_copy"
                | "mark_exists"
                | "mark_here"
                | "mark_input_end"
                | "mark_input_start"
                | "mark_pos"
                | "match_col"
                | "match_end_pos"
                | "match_group"
                | "match_groups"
                | "match_has"
                | "match_len"
                | "match_line"
                | "match_map"
                | "match_named"
                | "match_named_map"
                | "match_start_pos"
                | "match_text"
                | "matches"
                | "merge_hash"
                | "next"
                | "num_abs"
                | "num_add"
                | "num_avg"
                | "num_ceil"
                | "num_clamp"
                | "num_div"
                | "num_eq"
                | "num_floor"
                | "num_ge"
                | "num_gt"
                | "num_le"
                | "num_lt"
                | "num_max"
                | "num_median"
                | "num_min"
                | "num_mod"
                | "num_mul"
                | "num_ne"
                | "num_range"
                | "num_round"
                | "num_sub"
                | "num_sum"
                | "otherwise"
                | "pick_keys"
                | "print"
                | "print_each"
                | "push"
                | "push_nonempty"
                | "push_value"
                | "rename_key"
                | "replace_substr"
                | "return"
                | "return_undef"
                | "reversed"
                | "rm_prefix"
                | "rm_suffix"
                | "say"
                | "scalar"
                | "set"
                | "set_key"
                | "slice"
                | "sorted"
                | "sorted_keys"
                | "sorted_values"
                | "split"
                | "split_each"
                | "start_capture_slice"
                | "starts_with"
                | "str_eq"
                | "str_ge"
                | "str_gt"
                | "str_le"
                | "str_lt"
                | "str_ne"
                | "substr"
                | "switch"
                | "take"
                | "take_last"
                | "trim"
                | "trim_each"
                | "uniq"
                | "uppercase"
                | "uppercase_each"
                | "when"
                | "while"
        )
}

fn is_numeric_word_alias_name(name: &str) -> bool {
    matches!(
        name,
        "abs"
            | "add"
            | "avg"
            | "ceil"
            | "clamp"
            | "div"
            | "eq"
            | "floor"
            | "ge"
            | "gt"
            | "le"
            | "lt"
            | "max"
            | "median"
            | "min"
            | "mod"
            | "mul"
            | "ne"
            | "range"
            | "round"
            | "sub"
            | "sum"
    )
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
/// rgx (via PGEN) supports the full PCRE2 syntax surface including look-around,
/// backreferences, and subroutine calls — no patterns need to be skipped.
fn check_regex_syntax(spec: &SpecFile) -> Result<()> {
    for rule in &spec.rules {
        for element in &rule.body {
            if let BodyElementKind::Regex { pattern } = &element.kind {
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

/// Strict-mode reference check: every defined rule must be referenced by some
/// edge (`->` / `=>`). Mirrors the Perl reference `Validation.pm` strict_syntax
/// unused-rule warning promoted to an error (`@unused = defined − used`). The top
/// rule is **not** exempt — an unreferenced top rule is reported (parity confirmed
/// against the reference). Rule labels are unique by this point
/// (`check_duplicate_labels`), and definition order is preserved in the message.
fn check_unused_rules(spec: &SpecFile) -> Result<()> {
    let mut used: HashSet<&str> = HashSet::new();
    for rule in &spec.rules {
        for element in &rule.body {
            match &element.kind {
                BodyElementKind::ActionEdge { targets, .. } => {
                    for t in targets {
                        used.insert(t.label.as_str());
                    }
                }
                BodyElementKind::BlindEdge { target, .. } => {
                    used.insert(target.as_str());
                }
                _ => {}
            }
        }
    }
    let unused: Vec<&str> = spec
        .rules
        .iter()
        .map(|r| r.header.label.as_str())
        .filter(|label| !used.contains(label))
        .collect();
    if !unused.is_empty() {
        return Err(LinkedSpecError::Validation(format!(
            "unused rule(s) in strict mode: {}",
            unused.join(", ")
        )));
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ast::{FunctionDefinition, SourceSpan};
    use crate::parser::parse_spec;

    fn spec_with_user_functions(functions: Vec<FunctionDefinition>, rules_src: &str) -> SpecFile {
        let mut spec = parse_spec(rules_src).unwrap();
        spec.functions = functions;
        spec
    }

    fn user_function(name: &str, params: &[&str]) -> FunctionDefinition {
        FunctionDefinition {
            name: name.to_string(),
            params: params.iter().map(|param| param.to_string()).collect(),
            arity: params.len(),
            body_source: "return(value)".to_string(),
            body_payload: None,
            body_parse_job: None,
            source: format!("fn {name}({}) {{ return(value) }}", params.join(", ")),
            source_span: SourceSpan {
                line_start: 1,
                line_end: 1,
            },
            body_span: SourceSpan {
                line_start: 1,
                line_end: 1,
            },
        }
    }

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
        assert!(
            validate(&spec)
                .unwrap_err()
                .to_string()
                .contains("no top rule")
        );
    }

    #[test]
    fn validate_rejects_duplicate_labels() {
        let src = "Top::\n /a/\n\nTop:\n /b/";
        let spec = parse_spec(src).unwrap();
        assert!(
            validate(&spec)
                .unwrap_err()
                .to_string()
                .contains("duplicate")
        );
    }

    #[test]
    fn validate_accepts_user_function_registry() {
        let spec = spec_with_user_functions(
            vec![user_function("normalize", &["value"])],
            "Top::\n /x/\n",
        );
        validate(&spec).unwrap();
    }

    #[test]
    fn validate_rejects_duplicate_user_function_names() {
        let spec = spec_with_user_functions(
            vec![
                user_function("normalize", &["value"]),
                user_function("normalize", &["other"]),
            ],
            "Top::\n /x/\n",
        );
        assert!(
            validate(&spec)
                .unwrap_err()
                .to_string()
                .contains("duplicate user function")
        );
    }

    #[test]
    fn validate_rejects_user_function_rule_label_collision() {
        let spec =
            spec_with_user_functions(vec![user_function("Top", &["value"])], "Top::\n /x/\n");
        assert!(
            validate(&spec)
                .unwrap_err()
                .to_string()
                .contains("collides with rule label")
        );
    }

    #[test]
    fn validate_rejects_user_function_builtin_collision() {
        let spec =
            spec_with_user_functions(vec![user_function("trim", &["value"])], "Top::\n /x/\n");
        assert!(
            validate(&spec)
                .unwrap_err()
                .to_string()
                .contains("built-in helper")
        );
    }

    #[test]
    fn validate_rejects_user_function_numeric_alias_collisions() {
        for name in [
            "add", "sub", "mul", "div", "mod", "abs", "floor", "ceil", "round", "min", "max",
            "clamp", "sum", "avg", "median", "range",
        ] {
            let spec =
                spec_with_user_functions(vec![user_function(name, &["value"])], "Top::\n /x/\n");
            assert!(
                validate(&spec)
                    .unwrap_err()
                    .to_string()
                    .contains("built-in helper"),
                "expected numeric alias {name} to be rejected"
            );
        }
    }

    #[test]
    fn validate_rejects_user_function_duplicate_parameter() {
        let spec = spec_with_user_functions(
            vec![user_function("normalize", &["value", "value"])],
            "Top::\n /x/\n",
        );
        assert!(
            validate(&spec)
                .unwrap_err()
                .to_string()
                .contains("duplicate parameter")
        );
    }

    #[test]
    fn validate_rejects_user_function_reserved_parameter() {
        let spec =
            spec_with_user_functions(vec![user_function("normalize", &["ctx"])], "Top::\n /x/\n");
        assert!(
            validate(&spec)
                .unwrap_err()
                .to_string()
                .contains("parameter 'ctx' is reserved")
        );
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
        assert!(
            validate(&spec)
                .unwrap_err()
                .to_string()
                .contains("undefined rule")
        );
    }

    #[test]
    fn validate_rejects_invalid_regex() {
        let src = "Top::\n /[invalid/";
        let spec = parse_spec(src).unwrap();
        assert!(
            validate(&spec)
                .unwrap_err()
                .to_string()
                .contains("invalid regex")
        );
    }

    #[test]
    fn validate_from_parse() {
        let src = "Top::\n /a/ -> Child\n\nChild:\n /b/ E { return(42) }";
        let spec = parse_spec(src).unwrap();
        validate(&spec).unwrap();
    }

    // ── RUST-PARITY.6: strict_syntax validation mode ──
    // Parity with the Perl reference `Validation.pm validate_dsl_syntax(...,
    // strict_syntax => 1)`: reference warnings (undefined, then unused) become
    // hard errors. Verified empirically against the reference (an unreferenced
    // top rule IS flagged as unused; undefined is reported first).

    #[test]
    fn validate_strict_rejects_unreferenced_top_rule() {
        // Top references Child, but Top itself is referenced by nothing → "unused"
        // under strict mode (the top rule is not exempt — matches the reference).
        let src = "Top::\n /a/ -> Child\n\nChild:\n /b/";
        let spec = parse_spec(src).unwrap();
        let err = validate_with_options(&spec, true).unwrap_err().to_string();
        assert!(
            err.contains("unused"),
            "expected unused-rule error, got: {err}"
        );
        assert!(
            err.contains("Top"),
            "expected 'Top' in the error, got: {err}"
        );
    }

    #[test]
    fn validate_nonstrict_allows_unreferenced_rules() {
        // The same spec passes in the default (non-strict) mode — unused rules are
        // only a warning in the reference, and this backend has no warning channel.
        let src = "Top::\n /a/ -> Child\n\nChild:\n /b/";
        let spec = parse_spec(src).unwrap();
        validate(&spec).unwrap();
        validate_with_options(&spec, false).unwrap();
    }

    #[test]
    fn validate_strict_still_rejects_undefined_reference() {
        // Undefined references stay fatal in strict mode (reported before unused).
        let src = "Top::\n /a/ -> Ghost";
        let spec = parse_spec(src).unwrap();
        let err = validate_with_options(&spec, true).unwrap_err().to_string();
        assert!(
            err.contains("undefined rule"),
            "expected undefined-rule error, got: {err}"
        );
    }

    #[test]
    fn validate_strict_accepts_fully_referenced_spec() {
        // Every defined rule is referenced (the top references itself) → no unused
        // rule, so strict mode passes.
        let src = "Top::\n /a/ -> Top";
        let spec = parse_spec(src).unwrap();
        validate_with_options(&spec, true).unwrap();
    }
}
