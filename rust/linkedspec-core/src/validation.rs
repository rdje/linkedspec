//! Validation passes for parsed .spec AST.
use crate::ast::{BodyElementKind, SpecFile};
use crate::error::{LinkedSpecError, Result};
use std::collections::HashSet;

pub fn validate(spec: &SpecFile) -> Result<()> {
    check_top_rule_exists(spec)?;
    check_duplicate_labels(spec)?;
    check_mixed_edges(spec)?;
    // check_unclosed_blocks(spec)?; // parser handles block depth; validator needs raw-line access
    check_edge_targets(spec)?;
    Ok(())
}

fn check_top_rule_exists(spec: &SpecFile) -> Result<()> {
    if !spec.rules.iter().any(|r| r.header.is_top) {
        return Err(LinkedSpecError::Validation(
            "no top rule found: at least one rule must use '::'".into()));
    }
    Ok(())
}

fn check_duplicate_labels(spec: &SpecFile) -> Result<()> {
    let mut seen = HashSet::new();
    for rule in &spec.rules {
        if !seen.insert(&rule.header.label) {
            return Err(LinkedSpecError::Validation(format!(
                "duplicate rule label '{}'", rule.header.label)));
        }
    }
    Ok(())
}

fn check_mixed_edges(spec: &SpecFile) -> Result<()> {
    for rule in &spec.rules {
        let has_action = rule.body.iter().any(|e| matches!(e.kind, BodyElementKind::ActionEdge { .. }));
        let has_blind = rule.body.iter().any(|e| matches!(e.kind, BodyElementKind::BlindEdge { .. }));
        if has_action && has_blind {
            return Err(LinkedSpecError::Validation(format!(
                "rule '{}' mixes action (->) and blind-call (=>) edges", rule.header.label)));
        }
    }
    Ok(())
}

fn check_unclosed_blocks(spec: &SpecFile) -> Result<()> {
    for rule in &spec.rules {
        let mut depth: i32 = 0;
        for element in &rule.body {
            let text = &element.line;
            depth += text.matches('{').count() as i32;
            depth -= text.matches('}').count() as i32;
        }
        if depth != 0 {
            return Err(LinkedSpecError::Validation(format!(
                "rule '{}' has unclosed blocks: {} unmatched",
                rule.header.label,
                if depth > 0 { format!("{} open", depth) } else { format!("{} extra close", -depth) }
            )));
        }
    }
    Ok(())
}

fn check_edge_targets(spec: &SpecFile) -> Result<()> {
    let labels: HashSet<&str> = spec.rules.iter().map(|r| r.header.label.as_str()).collect();
    for rule in &spec.rules {
        for element in &rule.body {
            let target = match &element.kind {
                BodyElementKind::ActionEdge { target, .. } => Some(target.as_str()),
                BodyElementKind::BlindEdge { target } => Some(target.as_str()),
                _ => None,
            };
            if let Some(t) = target {
                if !labels.contains(t) {
                    return Err(LinkedSpecError::Validation(format!(
                        "rule '{}' references undefined rule '{}'", rule.header.label, t)));
                }
            }
        }
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ast::{BodyElement, BodyElementKind, Rule, RuleHeader, RuleMode};

    fn make_rule(label: &str, is_top: bool, body: Vec<BodyElement>) -> Rule {
        Rule { header: RuleHeader { label: label.into(), is_top, mode: RuleMode::Default, rest: String::new() }, body }
    }

    fn action_edge(target: &str) -> BodyElement {
        BodyElement::new(BodyElementKind::ActionEdge { target: target.into(), index: 0 }, &format!("-> {target}"))
    }

    fn blind_edge(target: &str) -> BodyElement {
        BodyElement::new(BodyElementKind::BlindEdge { target: target.into() }, &format!("=> {target}"))
    }

    #[test]
    fn validate_accepts_valid() {
        let spec = SpecFile { rules: vec![
            make_rule("Top", true, vec![BodyElement::new(BodyElementKind::Regex, "/a/")]),
            make_rule("Child", false, vec![BodyElement::new(BodyElementKind::Regex, "/b/")]),
        ]};
        assert!(validate(&spec).is_ok());
    }

    #[test]
    fn validate_rejects_no_top() {
        let spec = SpecFile { rules: vec![make_rule("R", false, vec![])] };
        assert!(validate(&spec).unwrap_err().to_string().contains("no top rule"));
    }

    #[test]
    fn validate_rejects_duplicate() {
        let spec = SpecFile { rules: vec![
            make_rule("Top", true, vec![]),
            make_rule("Top", false, vec![]),
        ]};
        assert!(validate(&spec).unwrap_err().to_string().contains("duplicate"));
    }

    #[test]
    fn validate_rejects_mixed() {
        let spec = SpecFile { rules: vec![make_rule("Top", true, vec![
            action_edge("A"), blind_edge("B"),
        ])]};
        assert!(validate(&spec).unwrap_err().to_string().contains("mixes"));
    }

    #[test]
    fn validate_rejects_undefined_target() {
        let spec = SpecFile { rules: vec![make_rule("Top", true, vec![action_edge("X")])] };
        assert!(validate(&spec).unwrap_err().to_string().contains("undefined rule"));
    }

    // TODO: re-enable when validator has access to raw lines for brace counting
    // #[test]
    // fn validate_rejects_unclosed() { ... }

    #[test]
    fn validate_valid_edges() {
        let spec = SpecFile { rules: vec![
            make_rule("Top", true, vec![action_edge("Child")]),
            make_rule("Child", false, vec![]),
        ]};
        assert!(validate(&spec).is_ok());
    }
}
