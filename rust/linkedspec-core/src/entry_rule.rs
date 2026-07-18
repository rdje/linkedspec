//! Ordered entry-rule selection over immutable compiled source identity.
//!
//! A selected entry rule is per-execution state. The resolver therefore reads
//! authored rule order and `is_top` bits without rewriting either one.

use crate::error::PortableDiagnostic;
use crate::types::{CompiledRule, CompiledSpec};

/// Stable identity of the root/entry-rule selection contract.
pub const ENTRY_RULE_CONTRACT_ID: &str = "linkedspec-root-rule-selection-v1";

/// Stable code for a structurally invalid specification with no rules.
pub const NO_RULES_DEFINED_CODE: &str = "no_rules_defined";
/// Stable stage for structural rule-count validation.
pub const VALIDATE_SPEC_STAGE: &str = "validate_spec";
/// Stable code for an explicit selector that names no declared rule.
pub const ENTRY_RULE_NOT_FOUND_CODE: &str = "entry_rule_not_found";
/// Stable stage for explicit/default entry-rule resolution.
pub const SELECT_ENTRY_RULE_STAGE: &str = "select_entry_rule";

/// The precedence branch that selected one effective entry rule.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum EntryRuleSelectionBasis {
    /// A caller-supplied exact label won over authored defaults.
    ExplicitSelector,
    /// With no selector, the first authored `Rule::` won.
    FirstAuthoredMarker,
    /// With no selector or marker, the first authored rule won.
    FirstAuthoredRule,
}

impl EntryRuleSelectionBasis {
    /// Return the backend-neutral contract spelling for this branch.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::ExplicitSelector => "explicit_selector",
            Self::FirstAuthoredMarker => "first_authored_marker",
            Self::FirstAuthoredRule => "first_authored_rule",
        }
    }
}

impl std::fmt::Display for EntryRuleSelectionBasis {
    fn fmt(&self, formatter: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        formatter.write_str(self.as_str())
    }
}

/// One effective per-execution entry selected from immutable compiled state.
#[derive(Debug, Clone, Copy)]
pub struct EntryRuleSelection<'a> {
    /// The compiled rule entered first.
    pub rule: &'a CompiledRule,
    /// The precedence branch that selected `rule`.
    pub basis: EntryRuleSelectionBasis,
}

/// Build the portable structural diagnostic for an empty specification.
pub fn no_rules_defined_diagnostic() -> PortableDiagnostic {
    PortableDiagnostic::new(
        NO_RULES_DEFINED_CODE,
        VALIDATE_SPEC_STAGE,
        "no rules defined: at least one rule declaration is required",
    )
}

fn entry_rule_not_found_diagnostic(label: &str) -> PortableDiagnostic {
    PortableDiagnostic::new(
        ENTRY_RULE_NOT_FOUND_CODE,
        SELECT_ENTRY_RULE_STAGE,
        format!("entry rule '{label}' is not defined"),
    )
    .with_field("entry_rule", label.to_string())
}

impl CompiledSpec {
    /// Resolve the effective entry rule using explicit > marker > first-rule
    /// precedence.
    ///
    /// Structural emptiness wins over selector lookup. Selection only borrows
    /// compiled state, so definition order and every authored `is_top` bit stay
    /// unchanged.
    pub fn resolve_entry_rule(
        &self,
        explicit_selector: Option<&str>,
    ) -> Result<EntryRuleSelection<'_>, PortableDiagnostic> {
        if self.rules.is_empty() {
            return Err(no_rules_defined_diagnostic());
        }

        if let Some(label) = explicit_selector {
            let rule = self
                .find(label)
                .ok_or_else(|| entry_rule_not_found_diagnostic(label))?;
            return Ok(EntryRuleSelection {
                rule,
                basis: EntryRuleSelectionBasis::ExplicitSelector,
            });
        }

        if let Some(rule) = self.rules.iter().find(|rule| rule.is_top) {
            return Ok(EntryRuleSelection {
                rule,
                basis: EntryRuleSelectionBasis::FirstAuthoredMarker,
            });
        }

        Ok(EntryRuleSelection {
            rule: &self.rules[0],
            basis: EntryRuleSelectionBasis::FirstAuthoredRule,
        })
    }
}
