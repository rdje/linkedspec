//! Rust generated-source emitter and execution adapters.
//!
//! `RUST-PARITY.8.2` introduced the generated-source path. The emitted module
//! embeds a serialized `CompiledSpec` plus generated-family metadata; direct
//! generated execution now covers all non-repetition families and explicit
//! repetition subfamilies. Contract-v1 callers can attach source identity and
//! consume typed metadata/errors; the original string-returning API remains a
//! compatibility adapter.

use crate::engine::Engine;
use crate::{
    RuntimeDiagnosticOutputExecutionError, RuntimeDiagnosticOutputSink,
    RuntimeDiagnosticOutputSinkFailure, RuntimeExitNow,
};
use linkedspec_core::ast::RuleMode;
use linkedspec_core::compiler::validate_no_removed_aggregate_selectors;
use linkedspec_core::trace::TraceConfig;
use linkedspec_core::types::{CompiledRule, CompiledSpec};
use serde::{Serialize, ser::SerializeStruct};
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

/// Typed outcome for generated execution with diagnostic-output delivery.
///
/// The generated-source layer retains its portable source-attributed failures,
/// while caller sink failures and `exit_now` remain distinct native outcomes.
#[derive(Debug, Clone)]
pub enum GeneratedDiagnosticOutputExecutionError {
    /// Contract-v1 emission, plan, or ordinary generated execution failure.
    GeneratedSource(GeneratedSourceError),
    /// Compatibility generated-parser failure retaining its prior text.
    Compatibility(String),
    /// The exact error payload returned by the caller's sink.
    Sink(RuntimeDiagnosticOutputSinkFailure),
    /// Immediate parser control requested by `exit_now(status)`.
    Exit(RuntimeExitNow),
}

impl fmt::Display for GeneratedDiagnosticOutputExecutionError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::GeneratedSource(error) => error.fmt(formatter),
            Self::Compatibility(error) => formatter.write_str(error),
            Self::Sink(error) => error.fmt(formatter),
            Self::Exit(error) => error.fmt(formatter),
        }
    }
}

impl std::error::Error for GeneratedDiagnosticOutputExecutionError {
    fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
        match self {
            Self::GeneratedSource(error) => Some(error),
            Self::Compatibility(_) => None,
            Self::Sink(error) => Some(error.as_ref()),
            Self::Exit(error) => Some(error),
        }
    }
}

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

    /// Return the exact backend-neutral family name, or `None` for the legacy marker.
    pub fn contract_name(self) -> Option<&'static str> {
        match self {
            Self::Default => Some("default"),
            Self::OrAcode => Some("or_acode"),
            Self::AndSingleAcode => Some("and_single_acode"),
            Self::AndAcodeSeq => Some("and_acode_seq"),
            Self::AndBcode => Some("and_bcode"),
            Self::OrBcode => Some("or_bcode"),
            Self::RepAcode => Some("rep_acode"),
            Self::RepBcode => Some("rep_bcode"),
            Self::RepAndAcode => Some("rep_and_acode"),
            Self::RepAndBcode => Some("rep_and_bcode"),
            Self::Repetition => None,
        }
    }

    fn from_contract_name(name: &str) -> Option<Self> {
        match name {
            "default" => Some(Self::Default),
            "or_acode" => Some(Self::OrAcode),
            "and_single_acode" => Some(Self::AndSingleAcode),
            "and_acode_seq" => Some(Self::AndAcodeSeq),
            "and_bcode" => Some(Self::AndBcode),
            "or_bcode" => Some(Self::OrBcode),
            "rep_acode" => Some(Self::RepAcode),
            "rep_bcode" => Some(Self::RepBcode),
            "rep_and_acode" => Some(Self::RepAndAcode),
            "rep_and_bcode" => Some(Self::RepAndBcode),
            _ => None,
        }
    }
}

/// One generated rule-family table row.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct GeneratedRuleSpec {
    pub label: &'static str,
    pub family: GeneratedRuleFamily,
}

/// One backend-neutral generated-plan row exposed by contract-v1 modules.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
pub struct GeneratedPlanRow {
    pub label: &'static str,
    pub family: &'static str,
}

/// Contract-v1 wire adapter for the compiled rule shape that existed before
/// live rule-local cursor execution removed the mutable `parse_mode` field.
///
/// Fresh in-memory and ordinary serialized `CompiledSpec` values no longer
/// carry that field. Generated-source v1 remains byte-structural-compatible
/// until its separately owned v2 migration.
struct GeneratedCompiledRuleV1<'a>(&'a CompiledRule);

impl Serialize for GeneratedCompiledRuleV1<'_> {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        let rule = self.0;
        let mut state = serializer.serialize_struct("CompiledRule", 17)?;
        state.serialize_field("label", &rule.label)?;
        state.serialize_field("is_top", &rule.is_top)?;
        state.serialize_field("parse_mode", &rule.legacy_artifact_parse_mode())?;
        state.serialize_field("mode", &rule.mode)?;
        state.serialize_field("regex_patterns", &rule.regex_patterns)?;
        state.serialize_field("dependency_refs", &rule.dependency_refs)?;
        state.serialize_field("acode_dispatch", &rule.acode_dispatch)?;
        state.serialize_field("bcode_dispatch", &rule.bcode_dispatch)?;
        state.serialize_field("preamble", &rule.preamble)?;
        state.serialize_field("lxcode", &rule.lxcode)?;
        state.serialize_field("lscode", &rule.lscode)?;
        state.serialize_field("lecode", &rule.lecode)?;
        state.serialize_field("ecode", &rule.ecode)?;
        state.serialize_field("excode", &rule.excode)?;
        state.serialize_field("itcode", &rule.itcode)?;
        state.serialize_field("rep_min", &rule.rep_min)?;
        state.serialize_field("rep_max", &rule.rep_max)?;
        state.end()
    }
}

struct GeneratedCompiledSpecV1<'a>(&'a CompiledSpec);

impl Serialize for GeneratedCompiledSpecV1<'_> {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        let mut state = serializer.serialize_struct("CompiledSpec", 2)?;
        state.serialize_field("functions", &self.0.functions)?;
        let rules = self
            .0
            .rules
            .iter()
            .map(GeneratedCompiledRuleV1)
            .collect::<Vec<_>>();
        state.serialize_field("rules", &rules)?;
        state.end()
    }
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

    validate_no_removed_aggregate_selectors(compiled).map_err(|error| {
        GeneratedSourceError::new(
            GeneratedSourceStage::EmitSource,
            GeneratedSourceCode::GeneratedSourceEmitFailed,
            "Failed to emit generated Rust source from invalid compiled spec",
            source_identity,
        )
        .with_detail(error.to_string())
    })?;

    let spec_json = serde_json::to_string(&GeneratedCompiledSpecV1(compiled)).map_err(|error| {
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
        "use linkedspec_runtime::source_emitter::{execute_generated_parser, execute_generated_parser_v1, execute_generated_parser_with_diagnostic_output, execute_generated_parser_with_diagnostic_output_v1, execute_generated_parser_with_trace, execute_generated_parser_with_trace_and_diagnostic_output, execute_generated_parser_with_trace_and_diagnostic_output_v1, execute_generated_parser_with_trace_v1, validate_generated_parser_plan_v1, GeneratedDiagnosticOutputExecutionError, GeneratedPlanRow, GeneratedRuleFamily, GeneratedRuleSpec, GeneratedSourceError, GeneratedSourceMetadata};\n",
    );
    source.push_str("use linkedspec_runtime::RuntimeDiagnosticOutputSink;\n");
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
    let mut neutral_plan_rows = String::new();
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
        neutral_plan_rows.push_str("    GeneratedPlanRow { label: ");
        neutral_plan_rows.push_str(&label_literal);
        neutral_plan_rows.push_str(", family: \"");
        neutral_plan_rows.push_str(
            classify_generated_rule_family(rule)
                .contract_name()
                .expect("classified generated rule must have a contract-v1 family"),
        );
        neutral_plan_rows.push_str("\" },\n");
    }
    source.push_str("];\n\n");
    source.push_str("const GENERATED_PLAN: &[GeneratedPlanRow] = &[\n");
    source.push_str(&neutral_plan_rows);
    source.push_str("];\n\n");
    source.push_str(
        r#"pub fn metadata() -> GeneratedSourceMetadata {
    GeneratedSourceMetadata::new(LINKEDSPEC_GENERATED_SOURCE_IDENTITY)
}

pub fn plan() -> &'static [GeneratedPlanRow] {
    GENERATED_PLAN
}

pub fn validate_plan(actual: &[GeneratedPlanRow]) -> Result<(), GeneratedSourceError> {
    validate_generated_parser_plan_v1(
        COMPILED_SPEC_JSON,
        actual,
        LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
    )
}

pub fn execute(input: &str) -> Result<serde_json::Value, GeneratedSourceError> {
    execute_generated_parser_v1(
        COMPILED_SPEC_JSON,
        GENERATED_PLAN,
        input,
        LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
    )
}

pub fn execute_with_diagnostic_output(
    input: &str,
    sink: Option<&RuntimeDiagnosticOutputSink>,
) -> Result<serde_json::Value, GeneratedDiagnosticOutputExecutionError> {
    execute_generated_parser_with_diagnostic_output_v1(
        COMPILED_SPEC_JSON,
        GENERATED_PLAN,
        input,
        LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
        sink,
    )
}

pub fn execute_with_trace(input: &str, trace_config: TraceConfig) -> Result<serde_json::Value, GeneratedSourceError> {
    execute_generated_parser_with_trace_v1(
        COMPILED_SPEC_JSON,
        GENERATED_PLAN,
        input,
        trace_config,
        LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
    )
}

pub fn execute_with_trace_and_diagnostic_output(
    input: &str,
    trace_config: TraceConfig,
    sink: Option<&RuntimeDiagnosticOutputSink>,
) -> Result<serde_json::Value, GeneratedDiagnosticOutputExecutionError> {
    execute_generated_parser_with_trace_and_diagnostic_output_v1(
        COMPILED_SPEC_JSON,
        GENERATED_PLAN,
        input,
        trace_config,
        LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
        sink,
    )
}

pub fn parse(input: &str) -> Result<serde_json::Value, String> {
    execute_generated_parser(COMPILED_SPEC_JSON, GENERATED_RULES, input)
}

pub fn parse_with_diagnostic_output(
    input: &str,
    sink: Option<&RuntimeDiagnosticOutputSink>,
) -> Result<serde_json::Value, GeneratedDiagnosticOutputExecutionError> {
    execute_generated_parser_with_diagnostic_output(
        COMPILED_SPEC_JSON,
        GENERATED_RULES,
        input,
        sink,
    )
}

pub fn parse_with_trace(input: &str, trace_config: TraceConfig) -> Result<serde_json::Value, String> {
    execute_generated_parser_with_trace(COMPILED_SPEC_JSON, GENERATED_RULES, input, trace_config)
}

pub fn parse_with_trace_and_diagnostic_output(
    input: &str,
    trace_config: TraceConfig,
    sink: Option<&RuntimeDiagnosticOutputSink>,
) -> Result<serde_json::Value, GeneratedDiagnosticOutputExecutionError> {
    execute_generated_parser_with_trace_and_diagnostic_output(
        COMPILED_SPEC_JSON,
        GENERATED_RULES,
        input,
        trace_config,
        sink,
    )
}
"#,
    );
    Ok(source)
}

/// Execute generated Rust source with the direct top-rule value and v1 failures.
pub fn execute_generated_parser_v1(
    compiled_spec_json: &str,
    generated_plan: &[GeneratedPlanRow],
    input: &str,
    source_identity: &str,
) -> Result<serde_json::Value, GeneratedSourceError> {
    let compiled = decode_generated_compiled_spec_v1(compiled_spec_json, source_identity)?;
    let generated_rules =
        validate_generated_rule_plan_v1(&compiled, generated_plan, source_identity)?;
    let top_context = generated_top_context(&compiled);
    Engine::new(compiled)
        .execute_generated_value_with_plan(&generated_rules, input)
        .map_err(|detail| generated_execution_error(source_identity, top_context, detail))
}

/// Execute generated Rust source with direct value and caller-owned diagnostics.
pub fn execute_generated_parser_with_diagnostic_output_v1(
    compiled_spec_json: &str,
    generated_plan: &[GeneratedPlanRow],
    input: &str,
    source_identity: &str,
    sink: Option<&RuntimeDiagnosticOutputSink>,
) -> Result<serde_json::Value, GeneratedDiagnosticOutputExecutionError> {
    let compiled = decode_generated_compiled_spec_v1(compiled_spec_json, source_identity)
        .map_err(GeneratedDiagnosticOutputExecutionError::GeneratedSource)?;
    let generated_rules =
        validate_generated_rule_plan_v1(&compiled, generated_plan, source_identity)
            .map_err(GeneratedDiagnosticOutputExecutionError::GeneratedSource)?;
    let top_context = generated_top_context(&compiled);
    Engine::new(compiled)
        .execute_generated_value_with_plan_with_diagnostic_output(&generated_rules, input, sink)
        .map_err(|error| generated_diagnostic_execution_error(source_identity, top_context, error))
}

/// Execute generated Rust source with direct value, portable trace roles, and v1 failures.
pub fn execute_generated_parser_with_trace_v1(
    compiled_spec_json: &str,
    generated_plan: &[GeneratedPlanRow],
    input: &str,
    trace_config: TraceConfig,
    source_identity: &str,
) -> Result<serde_json::Value, GeneratedSourceError> {
    let compiled = decode_generated_compiled_spec_v1(compiled_spec_json, source_identity)?;
    let generated_rules =
        validate_generated_rule_plan_v1(&compiled, generated_plan, source_identity)?;
    let top_context = generated_top_context(&compiled);
    Engine::new(compiled)
        .execute_generated_with_plan_with_trace_roles(
            &generated_rules,
            input,
            trace_config,
            source_identity,
        )
        .map_err(|detail| generated_execution_error(source_identity, top_context, detail))
}

/// Execute generated Rust source with portable trace roles and caller diagnostics.
pub fn execute_generated_parser_with_trace_and_diagnostic_output_v1(
    compiled_spec_json: &str,
    generated_plan: &[GeneratedPlanRow],
    input: &str,
    trace_config: TraceConfig,
    source_identity: &str,
    sink: Option<&RuntimeDiagnosticOutputSink>,
) -> Result<serde_json::Value, GeneratedDiagnosticOutputExecutionError> {
    let compiled = decode_generated_compiled_spec_v1(compiled_spec_json, source_identity)
        .map_err(GeneratedDiagnosticOutputExecutionError::GeneratedSource)?;
    let generated_rules =
        validate_generated_rule_plan_v1(&compiled, generated_plan, source_identity)
            .map_err(GeneratedDiagnosticOutputExecutionError::GeneratedSource)?;
    let top_context = generated_top_context(&compiled);
    Engine::new(compiled)
        .execute_generated_value_with_plan_with_trace_roles_and_diagnostic_output(
            &generated_rules,
            input,
            trace_config,
            source_identity,
            sink,
        )
        .map_err(|error| generated_diagnostic_execution_error(source_identity, top_context, error))
}

/// Validate an exposed contract-v1 plan against its embedded compiled specification.
pub fn validate_generated_parser_plan_v1(
    compiled_spec_json: &str,
    generated_plan: &[GeneratedPlanRow],
    source_identity: &str,
) -> Result<(), GeneratedSourceError> {
    let compiled = decode_generated_compiled_spec_v1(compiled_spec_json, source_identity)?;
    validate_generated_rule_plan_v1(&compiled, generated_plan, source_identity).map(|_| ())
}

fn decode_generated_compiled_spec_v1(
    compiled_spec_json: &str,
    source_identity: &str,
) -> Result<CompiledSpec, GeneratedSourceError> {
    let compiled: CompiledSpec = serde_json::from_str(compiled_spec_json).map_err(|error| {
        GeneratedSourceError::compile_failed(
            source_identity,
            format!("generated CompiledSpec JSON is invalid: {error}"),
        )
    })?;
    validate_no_removed_aggregate_selectors(&compiled).map_err(|error| {
        GeneratedSourceError::compile_failed(source_identity, error.to_string())
    })?;
    Ok(compiled)
}

fn generated_top_context(compiled: &CompiledSpec) -> Option<(String, &'static str)> {
    compiled.top_rule().map(|rule| {
        (
            rule.label.clone(),
            classify_generated_rule_family(rule)
                .contract_name()
                .expect("classified generated rule must have a contract-v1 family"),
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

fn generated_diagnostic_execution_error(
    source_identity: &str,
    top_context: Option<(String, &'static str)>,
    error: RuntimeDiagnosticOutputExecutionError,
) -> GeneratedDiagnosticOutputExecutionError {
    match error {
        RuntimeDiagnosticOutputExecutionError::Runtime(error) => {
            GeneratedDiagnosticOutputExecutionError::GeneratedSource(generated_execution_error(
                source_identity,
                top_context,
                error.message,
            ))
        }
        RuntimeDiagnosticOutputExecutionError::Sink(error) => {
            GeneratedDiagnosticOutputExecutionError::Sink(error)
        }
        RuntimeDiagnosticOutputExecutionError::Exit(error) => {
            GeneratedDiagnosticOutputExecutionError::Exit(error)
        }
    }
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
    validate_no_removed_aggregate_selectors(&compiled).map_err(|error| error.to_string())?;
    validate_generated_rule_plan(&compiled, generated_rules)?;
    Engine::new(compiled).execute_generated_with_plan(generated_rules, input)
}

/// Execute a compatibility generated parser with caller-owned diagnostics.
pub fn execute_generated_parser_with_diagnostic_output(
    compiled_spec_json: &str,
    generated_rules: &[GeneratedRuleSpec],
    input: &str,
    sink: Option<&RuntimeDiagnosticOutputSink>,
) -> Result<serde_json::Value, GeneratedDiagnosticOutputExecutionError> {
    let compiled: CompiledSpec = serde_json::from_str(compiled_spec_json).map_err(|error| {
        GeneratedDiagnosticOutputExecutionError::Compatibility(format!(
            "generated CompiledSpec JSON is invalid: {error}"
        ))
    })?;
    validate_no_removed_aggregate_selectors(&compiled).map_err(|error| {
        GeneratedDiagnosticOutputExecutionError::Compatibility(error.to_string())
    })?;
    validate_generated_rule_plan(&compiled, generated_rules)
        .map_err(GeneratedDiagnosticOutputExecutionError::Compatibility)?;
    Engine::new(compiled)
        .execute_generated_with_plan_with_diagnostic_output(generated_rules, input, sink)
        .map_err(compatibility_diagnostic_execution_error)
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
    validate_no_removed_aggregate_selectors(&compiled).map_err(|error| error.to_string())?;
    validate_generated_rule_plan(&compiled, generated_rules)?;
    Engine::new(compiled).execute_generated_with_plan_with_trace(
        generated_rules,
        input,
        trace_config,
    )
}

/// Execute a traced compatibility generated parser with caller diagnostics.
pub fn execute_generated_parser_with_trace_and_diagnostic_output(
    compiled_spec_json: &str,
    generated_rules: &[GeneratedRuleSpec],
    input: &str,
    trace_config: TraceConfig,
    sink: Option<&RuntimeDiagnosticOutputSink>,
) -> Result<serde_json::Value, GeneratedDiagnosticOutputExecutionError> {
    let compiled: CompiledSpec = serde_json::from_str(compiled_spec_json).map_err(|error| {
        GeneratedDiagnosticOutputExecutionError::Compatibility(format!(
            "generated CompiledSpec JSON is invalid: {error}"
        ))
    })?;
    validate_no_removed_aggregate_selectors(&compiled).map_err(|error| {
        GeneratedDiagnosticOutputExecutionError::Compatibility(error.to_string())
    })?;
    validate_generated_rule_plan(&compiled, generated_rules)
        .map_err(GeneratedDiagnosticOutputExecutionError::Compatibility)?;
    Engine::new(compiled)
        .execute_generated_with_plan_with_trace_and_diagnostic_output(
            generated_rules,
            input,
            trace_config,
            sink,
        )
        .map_err(compatibility_diagnostic_execution_error)
}

fn compatibility_diagnostic_execution_error(
    error: RuntimeDiagnosticOutputExecutionError,
) -> GeneratedDiagnosticOutputExecutionError {
    match error {
        RuntimeDiagnosticOutputExecutionError::Runtime(error) => {
            GeneratedDiagnosticOutputExecutionError::Compatibility(error.message)
        }
        RuntimeDiagnosticOutputExecutionError::Sink(error) => {
            GeneratedDiagnosticOutputExecutionError::Sink(error)
        }
        RuntimeDiagnosticOutputExecutionError::Exit(error) => {
            GeneratedDiagnosticOutputExecutionError::Exit(error)
        }
    }
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
            return if rule.mode.uses_legacy_and_interpretation() {
                GeneratedRuleFamily::RepAndBcode
            } else {
                GeneratedRuleFamily::RepBcode
            };
        }
        return if rule.mode.uses_legacy_and_interpretation() {
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
    generated_plan: &[GeneratedPlanRow],
    source_identity: &str,
) -> Result<Vec<GeneratedRuleSpec>, GeneratedSourceError> {
    if compiled.rules.len() != generated_plan.len() {
        return Err(GeneratedSourceError::new(
            GeneratedSourceStage::ValidateGeneratedPlan,
            GeneratedSourceCode::GeneratedPlanRowCountMismatch,
            "Generated rule plan row count does not match compiled rules",
            source_identity,
        )
        .with_detail(format!(
            "expected={} actual={}",
            compiled.rules.len(),
            generated_plan.len()
        )));
    }

    let mut typed_plan = Vec::with_capacity(generated_plan.len());
    for (row_index, (compiled_rule, generated_row)) in
        compiled.rules.iter().zip(generated_plan.iter()).enumerate()
    {
        if compiled_rule.label != generated_row.label {
            return Err(GeneratedSourceError::new(
                GeneratedSourceStage::ValidateGeneratedPlan,
                GeneratedSourceCode::GeneratedPlanLabelMismatch,
                "Generated rule plan label does not match compiled rule",
                source_identity,
            )
            .with_rule_label(&compiled_rule.label)
            .with_detail(format!(
                "row={row_index} expected={} actual={}",
                compiled_rule.label, generated_row.label
            )));
        }

        let Some(actual_family) = GeneratedRuleFamily::from_contract_name(generated_row.family)
        else {
            return Err(GeneratedSourceError::new(
                GeneratedSourceStage::ValidateGeneratedPlan,
                GeneratedSourceCode::GeneratedPlanUnknownFamily,
                "Generated rule plan contains an unknown family",
                source_identity,
            )
            .with_rule_label(&compiled_rule.label)
            .with_handler_family(generated_row.family)
            .with_detail(format!("row={row_index}")));
        };

        let expected = classify_generated_rule_family(compiled_rule);
        if expected != actual_family {
            return Err(GeneratedSourceError::new(
                GeneratedSourceStage::ValidateGeneratedPlan,
                GeneratedSourceCode::GeneratedPlanFamilyMismatch,
                "Generated rule plan family does not match compiled rule",
                source_identity,
            )
            .with_rule_label(&compiled_rule.label)
            .with_handler_family(generated_row.family)
            .with_detail(format!(
                "row={row_index} expected={} actual={}",
                expected
                    .contract_name()
                    .expect("classified generated rule must have a contract-v1 family"),
                generated_row.family
            )));
        }
        typed_plan.push(GeneratedRuleSpec {
            label: generated_row.label,
            family: actual_family,
        });
    }

    Ok(typed_plan)
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
