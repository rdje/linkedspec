//! Rust source emitter scaffold.
//!
//! `RUST-PARITY.8.2` introduced the generated-source path. The emitted module
//! embeds a serialized `CompiledSpec` plus generated-family metadata; direct
//! generated execution now covers all non-repetition families and explicit
//! repetition subfamilies.

use crate::engine::Engine;
use linkedspec_core::ast::RuleMode;
use linkedspec_core::trace::TraceConfig;
use linkedspec_core::types::{CompiledRule, CompiledSpec};

/// Version of the generated-source scaffold format.
pub const GENERATED_SOURCE_FORMAT: u32 = 1;

/// Generated handler families carried by emitted source.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum GeneratedRuleFamily {
    Default,
    OrAcode,
    AndSingleAcode,
    AndAcodeSeq,
    AndBcode,
    OrBcode,
    Repetition,
    RepAcode,
    RepBcode,
    RepAndAcode,
    RepAndBcode,
}

impl GeneratedRuleFamily {
    fn variant_name(self) -> &'static str {
        match self {
            Self::Default => "Default",
            Self::OrAcode => "OrAcode",
            Self::AndSingleAcode => "AndSingleAcode",
            Self::AndAcodeSeq => "AndAcodeSeq",
            Self::AndBcode => "AndBcode",
            Self::OrBcode => "OrBcode",
            Self::Repetition => "Repetition",
            Self::RepAcode => "RepAcode",
            Self::RepBcode => "RepBcode",
            Self::RepAndAcode => "RepAndAcode",
            Self::RepAndBcode => "RepAndBcode",
        }
    }
}

/// One generated rule-family table row.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct GeneratedRuleSpec {
    pub label: &'static str,
    pub family: GeneratedRuleFamily,
}

/// Emit a standalone Rust module for `compiled`.
///
/// The returned source expects dependencies on `linkedspec-runtime` and
/// `serde_json`. The generated entry point validates its family plan before
/// routing through generated-family execution.
pub fn emit_rust_source(compiled: &CompiledSpec) -> Result<String, String> {
    let spec_json = serde_json::to_string(compiled)
        .map_err(|e| format!("failed to serialize compiled spec for generated source: {e}"))?;
    let spec_literal = serde_json::to_string(&spec_json)
        .map_err(|e| format!("failed to encode compiled spec string literal: {e}"))?;

    let mut source = String::new();
    source.push_str("//! Generated LinkedSpec parser module.\n");
    source.push_str("//! Source format: linkedspec-runtime source_emitter v1.\n\n");
    source.push_str(
        "use linkedspec_runtime::source_emitter::{execute_generated_parser, execute_generated_parser_with_trace, GeneratedRuleFamily, GeneratedRuleSpec};\n",
    );
    source.push_str("use linkedspec_runtime::trace::TraceConfig;\n\n");
    source.push_str(&format!(
        "pub const LINKEDSPEC_GENERATED_SOURCE_FORMAT: u32 = {GENERATED_SOURCE_FORMAT};\n"
    ));
    source.push_str("const COMPILED_SPEC_JSON: &str = ");
    source.push_str(&spec_literal);
    source.push_str(";\n\n");
    source.push_str("const GENERATED_RULES: &[GeneratedRuleSpec] = &[\n");
    for rule in &compiled.rules {
        let label_literal = rust_string_literal(&rule.label)?;
        source.push_str("    GeneratedRuleSpec { label: ");
        source.push_str(&label_literal);
        source.push_str(", family: GeneratedRuleFamily::");
        source.push_str(classify_generated_rule_family(rule).variant_name());
        source.push_str(" },\n");
    }
    source.push_str("];\n\n");
    source.push_str(
        r#"pub fn parse(input: &str) -> Result<serde_json::Value, String> {
    execute_generated_parser(COMPILED_SPEC_JSON, GENERATED_RULES, input)
}

pub fn parse_with_trace(input: &str, trace_config: TraceConfig) -> Result<serde_json::Value, String> {
    execute_generated_parser_with_trace(COMPILED_SPEC_JSON, GENERATED_RULES, input, trace_config)
}
"#,
    );
    Ok(source)
}

/// Execute a generated parser module from its embedded compiled spec and family plan.
///
/// The plan is validated first. `RUST-PARITY.8.4` closes the generated-source
/// structural family matrix by routing non-REP and explicit REP subfamilies
/// through the generated-plan executor directly. Older v1 generated modules
/// that still carry the coarse `Repetition` marker remain accepted for REP
/// rules and are specialized at execution time.
pub fn execute_generated_parser(
    compiled_spec_json: &str,
    generated_rules: &[GeneratedRuleSpec],
    input: &str,
) -> Result<serde_json::Value, String> {
    let compiled: CompiledSpec = serde_json::from_str(compiled_spec_json)
        .map_err(|e| format!("generated CompiledSpec JSON is invalid: {e}"))?;
    validate_generated_rule_plan(&compiled, generated_rules)?;
    Engine::new(compiled).execute_generated_with_plan(generated_rules, input)
}

/// Execute a generated parser module with explicit trace configuration.
pub fn execute_generated_parser_with_trace(
    compiled_spec_json: &str,
    generated_rules: &[GeneratedRuleSpec],
    input: &str,
    trace_config: TraceConfig,
) -> Result<serde_json::Value, String> {
    let compiled: CompiledSpec = serde_json::from_str(compiled_spec_json)
        .map_err(|e| format!("generated CompiledSpec JSON is invalid: {e}"))?;
    validate_generated_rule_plan(&compiled, generated_rules)?;
    Engine::new(compiled).execute_generated_with_plan_with_trace(
        generated_rules,
        input,
        trace_config,
    )
}

/// Classify one compiled rule into the generated-source family plan.
pub fn classify_generated_rule_family(rule: &CompiledRule) -> GeneratedRuleFamily {
    if matches!(
        rule.mode,
        RuleMode::Plus
            | RuleMode::Star
            | RuleMode::Optional
            | RuleMode::OrPlus
            | RuleMode::OrBounded { .. }
            | RuleMode::AndPlus
            | RuleMode::AndBounded { .. }
    ) {
        if !rule.bcode_dispatch.is_empty() {
            return if rule.mode.is_and() {
                GeneratedRuleFamily::RepAndBcode
            } else {
                GeneratedRuleFamily::RepBcode
            };
        }
        return if rule.mode.is_and() {
            GeneratedRuleFamily::RepAndAcode
        } else {
            GeneratedRuleFamily::RepAcode
        };
    }

    if !rule.bcode_dispatch.is_empty() {
        return match rule.mode {
            RuleMode::Or => GeneratedRuleFamily::OrBcode,
            _ => GeneratedRuleFamily::AndBcode,
        };
    }

    match rule.mode {
        RuleMode::Default => GeneratedRuleFamily::Default,
        RuleMode::Or => GeneratedRuleFamily::OrAcode,
        RuleMode::Single => GeneratedRuleFamily::AndSingleAcode,
        RuleMode::And | RuleMode::Pipe => {
            if rule.regex_patterns.len() <= 1 && rule.acode_dispatch.len() <= 1 {
                GeneratedRuleFamily::AndSingleAcode
            } else {
                GeneratedRuleFamily::AndAcodeSeq
            }
        }
        RuleMode::Plus
        | RuleMode::Star
        | RuleMode::Optional
        | RuleMode::OrPlus
        | RuleMode::OrBounded { .. }
        | RuleMode::AndPlus
        | RuleMode::AndBounded { .. } => unreachable!("repetition modes return above"),
    }
}

fn validate_generated_rule_plan(
    compiled: &CompiledSpec,
    generated_rules: &[GeneratedRuleSpec],
) -> Result<(), String> {
    if compiled.rules.len() != generated_rules.len() {
        return Err(format!(
            "generated rule plan has {} rows but compiled spec has {} rules",
            generated_rules.len(),
            compiled.rules.len()
        ));
    }

    for (compiled_rule, generated_rule) in compiled.rules.iter().zip(generated_rules.iter()) {
        if compiled_rule.label != generated_rule.label {
            return Err(format!(
                "generated rule plan label mismatch: compiled '{}' vs generated '{}'",
                compiled_rule.label, generated_rule.label
            ));
        }
        let expected = classify_generated_rule_family(compiled_rule);
        if !generated_rule_family_matches(expected, generated_rule.family) {
            return Err(format!(
                "generated rule plan family mismatch for '{}': compiled {:?} vs generated {:?}",
                compiled_rule.label, expected, generated_rule.family
            ));
        }
    }

    Ok(())
}

fn generated_rule_family_matches(
    expected: GeneratedRuleFamily,
    generated: GeneratedRuleFamily,
) -> bool {
    expected == generated
        || (generated == GeneratedRuleFamily::Repetition
            && matches!(
                expected,
                GeneratedRuleFamily::RepAcode
                    | GeneratedRuleFamily::RepBcode
                    | GeneratedRuleFamily::RepAndAcode
                    | GeneratedRuleFamily::RepAndBcode
            ))
}

fn rust_string_literal(value: &str) -> Result<String, String> {
    serde_json::to_string(value).map_err(|e| format!("failed to encode Rust string literal: {e}"))
}
