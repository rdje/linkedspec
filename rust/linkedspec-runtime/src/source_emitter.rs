//! Rust generated-source emitter and execution adapters.
//!
//! `RUST-PARITY.8.2` introduced the generated-source path. The emitted module
//! embeds a serialized `CompiledSpec` plus generated-family metadata; direct
//! generated execution now covers all non-repetition families and explicit
//! repetition subfamilies. Contract-v1 callers can attach source identity and
//! consume typed metadata/errors; the original string-returning API remains a
//! compatibility adapter.

use crate::engine::Engine;
use linkedspec_core::ast::RuleMode;
use linkedspec_core::trace::TraceConfig;
use linkedspec_core::types::{CompiledRule, CompiledSpec};
use serde::Serialize;
use std::fmt;

/// Backend-neutral generated-source contract implemented by this emitter.
pub const GENERATED_SOURCE_CONTRACT: &str = "linkedspec-generated-source-v1";
/// Version of the generated-source scaffold format.
pub const GENERATED_SOURCE_FORMAT: u32 = 1;

/// Stable stage in the generated-source pipeline.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum GeneratedSourceStage {
    EmitSource,
    CompileOrLoadGeneratedSource,
    ValidateGeneratedPlan,
    ExecuteGenerated,
}

/// Stable machine-readable generated-source failure code.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum GeneratedSourceCode {
    GeneratedSourceEmitFailed,
    GeneratedSourceCompileFailed,
    GeneratedPlanRowCountMismatch,
    GeneratedPlanLabelMismatch,
    GeneratedPlanFamilyMismatch,
    GeneratedPlanUnknownFamily,
    GeneratedExecutionFailed,
}

/// Serializable generated-source failure with portable source attribution.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct GeneratedSourceError {
    #[serde(rename = "type")]
    pub error_type: &'static str,
    pub stage: GeneratedSourceStage,
    pub code: GeneratedSourceCode,
    pub summary: String,
    pub source_identity: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub rule_label: Option<Box<str>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub handler_family: Option<Box<str>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub detail: Option<Box<str>>,
}

impl GeneratedSourceError {
    fn new(
        stage: GeneratedSourceStage,
        code: GeneratedSourceCode,
        summary: impl Into<String>,
        source_identity: impl Into<String>,
    ) -> Self {
        Self {
            error_type: "generated_source_error",
            stage,
            code,
            summary: summary.into(),
            source_identity: source_identity.into(),
            rule_label: None,
            handler_family: None,
            detail: None,
        }
    }

    fn with_rule_label(mut self, rule_label: impl Into<String>) -> Self {
        self.rule_label = Some(rule_label.into().into_boxed_str());
        self
    }

    fn with_handler_family(mut self, handler_family: impl Into<String>) -> Self {
        self.handler_family = Some(handler_family.into().into_boxed_str());
        self
    }

    fn with_detail(mut self, detail: impl Into<String>) -> Self {
        self.detail = Some(detail.into().into_boxed_str());
        self
    }

    /// Project a host compiler/loader failure into the portable error contract.
    pub fn compile_failed(source_identity: impl Into<String>, detail: impl Into<String>) -> Self {
        Self::new(
            GeneratedSourceStage::CompileOrLoadGeneratedSource,
            GeneratedSourceCode::GeneratedSourceCompileFailed,
            "Generated Rust source failed to compile or load",
            source_identity,
        )
        .with_detail(detail)
    }

    /// Convert the structured failure to its backend-neutral JSON object.
    pub fn to_json(&self) -> serde_json::Result<serde_json::Value> {
        serde_json::to_value(self)
    }
}

impl fmt::Display for GeneratedSourceError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        formatter.write_str(&self.summary)?;
        if let Some(detail) = &self.detail {
            write!(formatter, ": {detail}")?;
        }
        Ok(())
    }
}

impl std::error::Error for GeneratedSourceError {}

/// Public metadata embedded in and returned by generated Rust modules.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct GeneratedSourceMetadata {
    pub contract_id: &'static str,
    pub format_version: u32,
    pub source_identity: String,
}

impl GeneratedSourceMetadata {
    /// Build metadata for one generated module identity.
    pub fn new(source_identity: impl Into<String>) -> Self {
        Self {
            contract_id: GENERATED_SOURCE_CONTRACT,
            format_version: GENERATED_SOURCE_FORMAT,
            source_identity: source_identity.into(),
        }
    }
}

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
    emit_rust_source_v1(compiled, "<inline>").map_err(|error| error.to_string())
}

/// Emit a standalone Rust module with contract-v1 source identity and typed errors.
pub fn emit_rust_source_v1(
    compiled: &CompiledSpec,
    source_identity: &str,
) -> Result<String, GeneratedSourceError> {
    if source_identity.is_empty() {
        return Err(GeneratedSourceError::new(
            GeneratedSourceStage::EmitSource,
            GeneratedSourceCode::GeneratedSourceEmitFailed,
            "Generated Rust source identity must not be empty",
            source_identity,
        )
        .with_detail("source_identity is required"));
    }

    let spec_json = serde_json::to_string(compiled).map_err(|error| {
        GeneratedSourceError::new(
            GeneratedSourceStage::EmitSource,
            GeneratedSourceCode::GeneratedSourceEmitFailed,
            "Failed to serialize compiled spec for generated source",
            source_identity,
        )
        .with_detail(error.to_string())
    })?;
    let spec_literal = serde_json::to_string(&spec_json).map_err(|error| {
        GeneratedSourceError::new(
            GeneratedSourceStage::EmitSource,
            GeneratedSourceCode::GeneratedSourceEmitFailed,
            "Failed to encode compiled spec string literal",
            source_identity,
        )
        .with_detail(error.to_string())
    })?;
    let source_identity_literal = rust_string_literal(source_identity).map_err(|error| {
        GeneratedSourceError::new(
            GeneratedSourceStage::EmitSource,
            GeneratedSourceCode::GeneratedSourceEmitFailed,
            "Failed to encode generated source identity",
            source_identity,
        )
        .with_detail(error)
    })?;

    let mut source = String::new();
    source.push_str("//! Generated LinkedSpec parser module.\n");
    source.push_str("//! Contract id: linkedspec-generated-source-v1.\n");
    source.push_str("//! Source format: linkedspec-runtime source_emitter v1.\n");
    source.push_str("//! Source identity: LINKEDSPEC_GENERATED_SOURCE_IDENTITY.\n\n");
    source.push_str(
        "use linkedspec_runtime::source_emitter::{execute_generated_parser, execute_generated_parser_v1, execute_generated_parser_with_trace, execute_generated_parser_with_trace_v1, GeneratedRuleFamily, GeneratedRuleSpec, GeneratedSourceError, GeneratedSourceMetadata};\n",
    );
    source.push_str("use linkedspec_runtime::trace::TraceConfig;\n\n");
    source.push_str(&format!(
        "pub const LINKEDSPEC_GENERATED_SOURCE_CONTRACT: &str = {contract:?};\n",
        contract = GENERATED_SOURCE_CONTRACT,
    ));
    source.push_str(&format!(
        "pub const LINKEDSPEC_GENERATED_SOURCE_FORMAT: u32 = {GENERATED_SOURCE_FORMAT};\n"
    ));
    source.push_str("pub const LINKEDSPEC_GENERATED_SOURCE_IDENTITY: &str = ");
    source.push_str(&source_identity_literal);
    source.push_str(";\n");
    source.push_str("const COMPILED_SPEC_JSON: &str = ");
    source.push_str(&spec_literal);
    source.push_str(";\n\n");
    source.push_str("const GENERATED_RULES: &[GeneratedRuleSpec] = &[\n");
    for rule in &compiled.rules {
        let label_literal = rust_string_literal(&rule.label).map_err(|error| {
            GeneratedSourceError::new(
                GeneratedSourceStage::EmitSource,
                GeneratedSourceCode::GeneratedSourceEmitFailed,
                "Failed to encode generated rule label",
                source_identity,
            )
            .with_rule_label(&rule.label)
            .with_detail(error)
        })?;
        source.push_str("    GeneratedRuleSpec { label: ");
        source.push_str(&label_literal);
        source.push_str(", family: GeneratedRuleFamily::");
        source.push_str(classify_generated_rule_family(rule).variant_name());
        source.push_str(" },\n");
    }
    source.push_str("];\n\n");
    source.push_str(
        r#"pub fn metadata() -> GeneratedSourceMetadata {
    GeneratedSourceMetadata::new(LINKEDSPEC_GENERATED_SOURCE_IDENTITY)
}

pub fn execute(input: &str) -> Result<serde_json::Value, GeneratedSourceError> {
    execute_generated_parser_v1(
        COMPILED_SPEC_JSON,
        GENERATED_RULES,
        input,
        LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
    )
}

pub fn execute_with_trace(input: &str, trace_config: TraceConfig) -> Result<serde_json::Value, GeneratedSourceError> {
    execute_generated_parser_with_trace_v1(
        COMPILED_SPEC_JSON,
        GENERATED_RULES,
        input,
        trace_config,
        LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
    )
}

pub fn parse(input: &str) -> Result<serde_json::Value, String> {
    execute_generated_parser(COMPILED_SPEC_JSON, GENERATED_RULES, input)
}

pub fn parse_with_trace(input: &str, trace_config: TraceConfig) -> Result<serde_json::Value, String> {
    execute_generated_parser_with_trace(COMPILED_SPEC_JSON, GENERATED_RULES, input, trace_config)
}
"#,
    );
    Ok(source)
}

/// Execute generated Rust source with contract-v1 structured failures.
pub fn execute_generated_parser_v1(
    compiled_spec_json: &str,
    generated_rules: &[GeneratedRuleSpec],
    input: &str,
    source_identity: &str,
) -> Result<serde_json::Value, GeneratedSourceError> {
    let compiled: CompiledSpec = serde_json::from_str(compiled_spec_json).map_err(|error| {
        GeneratedSourceError::compile_failed(
            source_identity,
            format!("generated CompiledSpec JSON is invalid: {error}"),
        )
    })?;
    validate_generated_rule_plan_v1(&compiled, generated_rules, source_identity)?;
    let top_context = generated_top_context(&compiled);
    Engine::new(compiled)
        .execute_generated_with_plan(generated_rules, input)
        .map_err(|detail| generated_execution_error(source_identity, top_context, detail))
}

/// Execute generated Rust source with trace and contract-v1 structured failures.
pub fn execute_generated_parser_with_trace_v1(
    compiled_spec_json: &str,
    generated_rules: &[GeneratedRuleSpec],
    input: &str,
    trace_config: TraceConfig,
    source_identity: &str,
) -> Result<serde_json::Value, GeneratedSourceError> {
    let compiled: CompiledSpec = serde_json::from_str(compiled_spec_json).map_err(|error| {
        GeneratedSourceError::compile_failed(
            source_identity,
            format!("generated CompiledSpec JSON is invalid: {error}"),
        )
    })?;
    validate_generated_rule_plan_v1(&compiled, generated_rules, source_identity)?;
    let top_context = generated_top_context(&compiled);
    Engine::new(compiled)
        .execute_generated_with_plan_with_trace(generated_rules, input, trace_config)
        .map_err(|detail| generated_execution_error(source_identity, top_context, detail))
}

fn generated_top_context(compiled: &CompiledSpec) -> Option<(String, &'static str)> {
    compiled.top_rule().map(|rule| {
        (
            rule.label.clone(),
            classify_generated_rule_family(rule).variant_name(),
        )
    })
}

fn generated_execution_error(
    source_identity: &str,
    top_context: Option<(String, &'static str)>,
    detail: String,
) -> GeneratedSourceError {
    let mut error = GeneratedSourceError::new(
        GeneratedSourceStage::ExecuteGenerated,
        GeneratedSourceCode::GeneratedExecutionFailed,
        "Generated Rust parser execution failed",
        source_identity,
    )
    .with_detail(detail);
    if let Some((rule_label, handler_family)) = top_context {
        error = error
            .with_rule_label(rule_label)
            .with_handler_family(handler_family);
    }
    error
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

fn validate_generated_rule_plan_v1(
    compiled: &CompiledSpec,
    generated_rules: &[GeneratedRuleSpec],
    source_identity: &str,
) -> Result<(), GeneratedSourceError> {
    if compiled.rules.len() != generated_rules.len() {
        return Err(GeneratedSourceError::new(
            GeneratedSourceStage::ValidateGeneratedPlan,
            GeneratedSourceCode::GeneratedPlanRowCountMismatch,
            "Generated rule plan row count does not match compiled rules",
            source_identity,
        )
        .with_detail(format!(
            "expected={} actual={}",
            compiled.rules.len(),
            generated_rules.len()
        )));
    }

    for (compiled_rule, generated_rule) in compiled.rules.iter().zip(generated_rules.iter()) {
        if compiled_rule.label != generated_rule.label {
            return Err(GeneratedSourceError::new(
                GeneratedSourceStage::ValidateGeneratedPlan,
                GeneratedSourceCode::GeneratedPlanLabelMismatch,
                "Generated rule plan label does not match compiled rule",
                source_identity,
            )
            .with_rule_label(&compiled_rule.label)
            .with_detail(format!(
                "expected={} actual={}",
                compiled_rule.label, generated_rule.label
            )));
        }
        let expected = classify_generated_rule_family(compiled_rule);
        if !generated_rule_family_matches(expected, generated_rule.family) {
            return Err(GeneratedSourceError::new(
                GeneratedSourceStage::ValidateGeneratedPlan,
                GeneratedSourceCode::GeneratedPlanFamilyMismatch,
                "Generated rule plan family does not match compiled rule",
                source_identity,
            )
            .with_rule_label(&compiled_rule.label)
            .with_handler_family(generated_rule.family.variant_name())
            .with_detail(format!(
                "expected={expected:?} actual={:?}",
                generated_rule.family
            )));
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
