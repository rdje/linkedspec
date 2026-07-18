//! Rust generated-source emitter and execution adapters.
//!
//! `RUST-PARITY.8.2` introduced the generated-source path. The emitted module
//! embeds a serialized `CompiledSpec` plus generated-family metadata; direct
//! generated execution now covers all non-repetition families and explicit
//! repetition subfamilies. Contract-v2 callers can attach source identity and
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
use serde::Serialize;
use std::fmt;

/// Backend-neutral generated-source contract implemented by this emitter.
pub const GENERATED_SOURCE_CONTRACT: &str = "linkedspec-generated-source-v2";
/// Version of the generated-source scaffold format.
pub const GENERATED_SOURCE_FORMAT: u32 = 2;

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
    GeneratedSourceContractVersionMismatch,
    GeneratedExecutionFailed,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
struct GeneratedSourceContractMismatch {
    expected_contract: Box<str>,
    actual_contract: Box<str>,
}

/// Serializable generated-source failure with portable source attribution.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct GeneratedSourceError {
    #[serde(rename = "type")]
    pub error_type: &'static str,
    pub stage: GeneratedSourceStage,
    pub code: GeneratedSourceCode,
    pub summary: &'static str,
    pub source_identity: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub rule_label: Option<Box<str>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub handler_family: Option<Box<str>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub detail: Option<Box<str>>,
    #[serde(flatten, skip_serializing_if = "Option::is_none")]
    contract_mismatch: Option<Box<GeneratedSourceContractMismatch>>,
}

impl GeneratedSourceError {
    fn new(
        stage: GeneratedSourceStage,
        code: GeneratedSourceCode,
        summary: &'static str,
        source_identity: impl Into<String>,
    ) -> Self {
        Self {
            error_type: "generated_source_error",
            stage,
            code,
            summary,
            source_identity: source_identity.into(),
            rule_label: None,
            handler_family: None,
            detail: None,
            contract_mismatch: None,
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

    fn with_contracts(
        mut self,
        expected_contract: impl Into<String>,
        actual_contract: impl Into<String>,
    ) -> Self {
        self.contract_mismatch = Some(Box::new(GeneratedSourceContractMismatch {
            expected_contract: expected_contract.into().into_boxed_str(),
            actual_contract: actual_contract.into().into_boxed_str(),
        }));
        self
    }

    /// Return the active contract expected by a version-mismatch failure.
    pub fn expected_contract(&self) -> Option<&str> {
        self.contract_mismatch
            .as_deref()
            .map(|mismatch| mismatch.expected_contract.as_ref())
    }

    /// Return the artifact contract supplied to a version-mismatch failure.
    pub fn actual_contract(&self) -> Option<&str> {
        self.contract_mismatch
            .as_deref()
            .map(|mismatch| mismatch.actual_contract.as_ref())
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
        formatter.write_str(self.summary)?;
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
    /// Contract-v2 emission, plan, or ordinary generated execution failure.
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
    RepAcode,
    RepBcode,
    RepAndAcode,
    RepAndBcode,
}

impl GeneratedRuleFamily {
    /// Return the exact backend-neutral family name.
    pub fn contract_name(self) -> &'static str {
        match self {
            Self::Default => "default",
            Self::OrAcode => "or_acode",
            Self::AndSingleAcode => "and_single_acode",
            Self::AndAcodeSeq => "and_acode_seq",
            Self::AndBcode => "and_bcode",
            Self::OrBcode => "or_bcode",
            Self::RepAcode => "rep_acode",
            Self::RepBcode => "rep_bcode",
            Self::RepAndAcode => "rep_and_acode",
            Self::RepAndBcode => "rep_and_bcode",
        }
    }

    /// Derive the generated cursor policy from the validated family row.
    pub fn cursor_policy(self) -> linkedspec_core::types::ParseMode {
        use linkedspec_core::types::ParseMode;
        match self {
            Self::Default | Self::OrAcode | Self::OrBcode | Self::RepAcode | Self::RepBcode => {
                ParseMode::Seek
            }
            Self::AndSingleAcode
            | Self::AndAcodeSeq
            | Self::AndBcode
            | Self::RepAndAcode
            | Self::RepAndBcode => ParseMode::Consume,
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

/// One backend-neutral generated-plan row exposed by contract-v2 modules.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
pub struct GeneratedPlanRow {
    pub label: &'static str,
    pub family: &'static str,
}

/// Emit a standalone Rust module for `compiled`.
///
/// The returned source expects dependencies on `linkedspec-runtime` and
/// `serde_json`. The generated entry point validates its family plan before
/// routing through generated-family execution.
pub fn emit_rust_source(compiled: &CompiledSpec) -> Result<String, String> {
    emit_rust_source_v2(compiled, "<inline>").map_err(|error| error.to_string())
}

/// Emit a standalone Rust module with contract-v2 source identity and typed errors.
pub fn emit_rust_source_v2(
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
    source.push_str("//! Contract id: linkedspec-generated-source-v2.\n");
    source.push_str("//! Source format: linkedspec-runtime source_emitter v2.\n");
    source.push_str("//! Source identity: LINKEDSPEC_GENERATED_SOURCE_IDENTITY.\n\n");
    source.push_str(
        "use linkedspec_runtime::source_emitter::{execute_generated_parser, execute_generated_parser_v2, execute_generated_parser_with_diagnostic_output, execute_generated_parser_with_diagnostic_output_v2, execute_generated_parser_with_trace, execute_generated_parser_with_trace_and_diagnostic_output, execute_generated_parser_with_trace_and_diagnostic_output_v2, execute_generated_parser_with_trace_v2, validate_generated_parser_plan_v2, GeneratedDiagnosticOutputExecutionError, GeneratedPlanRow, GeneratedSourceError, GeneratedSourceMetadata};\n",
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
        neutral_plan_rows.push_str("    GeneratedPlanRow { label: ");
        neutral_plan_rows.push_str(&label_literal);
        neutral_plan_rows.push_str(", family: \"");
        neutral_plan_rows.push_str(classify_generated_rule_family(rule).contract_name());
        neutral_plan_rows.push_str("\" },\n");
    }
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
    validate_plan_for_contract(actual, LINKEDSPEC_GENERATED_SOURCE_CONTRACT)
}

pub fn validate_plan_for_contract(
    actual: &[GeneratedPlanRow],
    actual_contract: &str,
) -> Result<(), GeneratedSourceError> {
    validate_generated_parser_plan_v2(
        COMPILED_SPEC_JSON,
        actual,
        LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
        actual_contract,
    )
}

pub fn execute(input: &str) -> Result<serde_json::Value, GeneratedSourceError> {
    execute_generated_parser_v2(
        COMPILED_SPEC_JSON,
        GENERATED_PLAN,
        input,
        LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
        LINKEDSPEC_GENERATED_SOURCE_CONTRACT,
    )
}

pub fn execute_with_diagnostic_output(
    input: &str,
    sink: Option<&RuntimeDiagnosticOutputSink>,
) -> Result<serde_json::Value, GeneratedDiagnosticOutputExecutionError> {
    execute_generated_parser_with_diagnostic_output_v2(
        COMPILED_SPEC_JSON,
        GENERATED_PLAN,
        input,
        LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
        LINKEDSPEC_GENERATED_SOURCE_CONTRACT,
        sink,
    )
}

pub fn execute_with_trace(input: &str, trace_config: TraceConfig) -> Result<serde_json::Value, GeneratedSourceError> {
    execute_generated_parser_with_trace_v2(
        COMPILED_SPEC_JSON,
        GENERATED_PLAN,
        input,
        trace_config,
        LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
        LINKEDSPEC_GENERATED_SOURCE_CONTRACT,
    )
}

pub fn execute_with_trace_and_diagnostic_output(
    input: &str,
    trace_config: TraceConfig,
    sink: Option<&RuntimeDiagnosticOutputSink>,
) -> Result<serde_json::Value, GeneratedDiagnosticOutputExecutionError> {
    execute_generated_parser_with_trace_and_diagnostic_output_v2(
        COMPILED_SPEC_JSON,
        GENERATED_PLAN,
        input,
        trace_config,
        LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
        LINKEDSPEC_GENERATED_SOURCE_CONTRACT,
        sink,
    )
}

pub fn parse(input: &str) -> Result<serde_json::Value, String> {
    execute_generated_parser(COMPILED_SPEC_JSON, GENERATED_PLAN, input)
}

pub fn parse_with_diagnostic_output(
    input: &str,
    sink: Option<&RuntimeDiagnosticOutputSink>,
) -> Result<serde_json::Value, GeneratedDiagnosticOutputExecutionError> {
    execute_generated_parser_with_diagnostic_output(
        COMPILED_SPEC_JSON,
        GENERATED_PLAN,
        input,
        sink,
    )
}

pub fn parse_with_trace(input: &str, trace_config: TraceConfig) -> Result<serde_json::Value, String> {
    execute_generated_parser_with_trace(COMPILED_SPEC_JSON, GENERATED_PLAN, input, trace_config)
}

pub fn parse_with_trace_and_diagnostic_output(
    input: &str,
    trace_config: TraceConfig,
    sink: Option<&RuntimeDiagnosticOutputSink>,
) -> Result<serde_json::Value, GeneratedDiagnosticOutputExecutionError> {
    execute_generated_parser_with_trace_and_diagnostic_output(
        COMPILED_SPEC_JSON,
        GENERATED_PLAN,
        input,
        trace_config,
        sink,
    )
}
"#,
    );
    Ok(source)
}

/// Execute generated Rust source with the direct top-rule value and v2 failures.
pub fn execute_generated_parser_v2(
    compiled_spec_json: &str,
    generated_plan: &[GeneratedPlanRow],
    input: &str,
    source_identity: &str,
    actual_contract: &str,
) -> Result<serde_json::Value, GeneratedSourceError> {
    validate_generated_source_contract_v2(actual_contract, source_identity)?;
    let compiled = decode_generated_compiled_spec_v2(compiled_spec_json, source_identity)?;
    let generated_rules =
        validate_generated_rule_plan_v2(&compiled, generated_plan, source_identity)?;
    let top_context = generated_top_context(&compiled);
    Engine::new(compiled)
        .execute_generated_value_with_plan(&generated_rules, input)
        .map_err(|detail| generated_execution_error(source_identity, top_context, detail))
}

/// Execute generated Rust source with direct value and caller-owned diagnostics.
pub fn execute_generated_parser_with_diagnostic_output_v2(
    compiled_spec_json: &str,
    generated_plan: &[GeneratedPlanRow],
    input: &str,
    source_identity: &str,
    actual_contract: &str,
    sink: Option<&RuntimeDiagnosticOutputSink>,
) -> Result<serde_json::Value, GeneratedDiagnosticOutputExecutionError> {
    validate_generated_source_contract_v2(actual_contract, source_identity)
        .map_err(GeneratedDiagnosticOutputExecutionError::GeneratedSource)?;
    let compiled = decode_generated_compiled_spec_v2(compiled_spec_json, source_identity)
        .map_err(GeneratedDiagnosticOutputExecutionError::GeneratedSource)?;
    let generated_rules =
        validate_generated_rule_plan_v2(&compiled, generated_plan, source_identity)
            .map_err(GeneratedDiagnosticOutputExecutionError::GeneratedSource)?;
    let top_context = generated_top_context(&compiled);
    Engine::new(compiled)
        .execute_generated_value_with_plan_with_diagnostic_output(&generated_rules, input, sink)
        .map_err(|error| generated_diagnostic_execution_error(source_identity, top_context, error))
}

/// Execute generated Rust source with direct value, portable trace roles, and v2 failures.
pub fn execute_generated_parser_with_trace_v2(
    compiled_spec_json: &str,
    generated_plan: &[GeneratedPlanRow],
    input: &str,
    trace_config: TraceConfig,
    source_identity: &str,
    actual_contract: &str,
) -> Result<serde_json::Value, GeneratedSourceError> {
    validate_generated_source_contract_v2(actual_contract, source_identity)?;
    let compiled = decode_generated_compiled_spec_v2(compiled_spec_json, source_identity)?;
    let generated_rules =
        validate_generated_rule_plan_v2(&compiled, generated_plan, source_identity)?;
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
pub fn execute_generated_parser_with_trace_and_diagnostic_output_v2(
    compiled_spec_json: &str,
    generated_plan: &[GeneratedPlanRow],
    input: &str,
    trace_config: TraceConfig,
    source_identity: &str,
    actual_contract: &str,
    sink: Option<&RuntimeDiagnosticOutputSink>,
) -> Result<serde_json::Value, GeneratedDiagnosticOutputExecutionError> {
    validate_generated_source_contract_v2(actual_contract, source_identity)
        .map_err(GeneratedDiagnosticOutputExecutionError::GeneratedSource)?;
    let compiled = decode_generated_compiled_spec_v2(compiled_spec_json, source_identity)
        .map_err(GeneratedDiagnosticOutputExecutionError::GeneratedSource)?;
    let generated_rules =
        validate_generated_rule_plan_v2(&compiled, generated_plan, source_identity)
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

/// Validate an exposed contract-v2 plan against its embedded compiled specification.
pub fn validate_generated_parser_plan_v2(
    compiled_spec_json: &str,
    generated_plan: &[GeneratedPlanRow],
    source_identity: &str,
    actual_contract: &str,
) -> Result<(), GeneratedSourceError> {
    validate_generated_source_contract_v2(actual_contract, source_identity)?;
    let compiled = decode_generated_compiled_spec_v2(compiled_spec_json, source_identity)?;
    validate_generated_rule_plan_v2(&compiled, generated_plan, source_identity).map(|_| ())
}

fn validate_generated_source_contract_v2(
    actual_contract: &str,
    source_identity: &str,
) -> Result<(), GeneratedSourceError> {
    if actual_contract == GENERATED_SOURCE_CONTRACT {
        return Ok(());
    }
    Err(GeneratedSourceError::new(
        GeneratedSourceStage::ValidateGeneratedPlan,
        GeneratedSourceCode::GeneratedSourceContractVersionMismatch,
        "Generated source contract does not match the active validator",
        source_identity,
    )
    .with_contracts(GENERATED_SOURCE_CONTRACT, actual_contract)
    .with_detail("regenerate the generated artifact from its .spec source"))
}

fn decode_generated_compiled_spec_v2(
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
            classify_generated_rule_family(rule).contract_name(),
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
/// The v2 plan is validated first. `RUST-PARITY.8.4` closes the generated-source
/// structural family matrix by routing non-REP and explicit REP subfamilies
/// through the generated-plan executor directly.
pub fn execute_generated_parser(
    compiled_spec_json: &str,
    generated_plan: &[GeneratedPlanRow],
    input: &str,
) -> Result<serde_json::Value, String> {
    let compiled = decode_generated_compiled_spec_v2(compiled_spec_json, "<inline>")
        .map_err(|error| error.to_string())?;
    let generated_rules = validate_generated_rule_plan_v2(&compiled, generated_plan, "<inline>")
        .map_err(|error| error.to_string())?;
    Engine::new(compiled).execute_generated_with_plan(&generated_rules, input)
}

/// Execute a compatibility generated parser with caller-owned diagnostics.
pub fn execute_generated_parser_with_diagnostic_output(
    compiled_spec_json: &str,
    generated_plan: &[GeneratedPlanRow],
    input: &str,
    sink: Option<&RuntimeDiagnosticOutputSink>,
) -> Result<serde_json::Value, GeneratedDiagnosticOutputExecutionError> {
    let compiled =
        decode_generated_compiled_spec_v2(compiled_spec_json, "<inline>").map_err(|error| {
            GeneratedDiagnosticOutputExecutionError::Compatibility(error.to_string())
        })?;
    let generated_rules = validate_generated_rule_plan_v2(&compiled, generated_plan, "<inline>")
        .map_err(|error| {
            GeneratedDiagnosticOutputExecutionError::Compatibility(error.to_string())
        })?;
    Engine::new(compiled)
        .execute_generated_with_plan_with_diagnostic_output(&generated_rules, input, sink)
        .map_err(compatibility_diagnostic_execution_error)
}

/// Execute a generated parser module with explicit trace configuration.
pub fn execute_generated_parser_with_trace(
    compiled_spec_json: &str,
    generated_plan: &[GeneratedPlanRow],
    input: &str,
    trace_config: TraceConfig,
) -> Result<serde_json::Value, String> {
    let compiled = decode_generated_compiled_spec_v2(compiled_spec_json, "<inline>")
        .map_err(|error| error.to_string())?;
    let generated_rules = validate_generated_rule_plan_v2(&compiled, generated_plan, "<inline>")
        .map_err(|error| error.to_string())?;
    Engine::new(compiled).execute_generated_with_plan_with_trace(
        &generated_rules,
        input,
        trace_config,
    )
}

/// Execute a traced compatibility generated parser with caller diagnostics.
pub fn execute_generated_parser_with_trace_and_diagnostic_output(
    compiled_spec_json: &str,
    generated_plan: &[GeneratedPlanRow],
    input: &str,
    trace_config: TraceConfig,
    sink: Option<&RuntimeDiagnosticOutputSink>,
) -> Result<serde_json::Value, GeneratedDiagnosticOutputExecutionError> {
    let compiled =
        decode_generated_compiled_spec_v2(compiled_spec_json, "<inline>").map_err(|error| {
            GeneratedDiagnosticOutputExecutionError::Compatibility(error.to_string())
        })?;
    let generated_rules = validate_generated_rule_plan_v2(&compiled, generated_plan, "<inline>")
        .map_err(|error| {
            GeneratedDiagnosticOutputExecutionError::Compatibility(error.to_string())
        })?;
    Engine::new(compiled)
        .execute_generated_with_plan_with_trace_and_diagnostic_output(
            &generated_rules,
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
    // `RuleMode::Default` executes as a repeated choice, so the core
    // `is_repetition()` predicate intentionally includes it. Generated-source
    // classification is narrower: the neutral v2 table reserves `default`
    // for that authored form and uses `rep_*` only for explicit repetition
    // suffixes.
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
        return if rule.mode.is_and() {
            GeneratedRuleFamily::AndBcode
        } else {
            GeneratedRuleFamily::OrBcode
        };
    }

    match rule.mode {
        RuleMode::Default => GeneratedRuleFamily::Default,
        RuleMode::Or | RuleMode::Pipe => GeneratedRuleFamily::OrAcode,
        RuleMode::Single => GeneratedRuleFamily::AndSingleAcode,
        RuleMode::And => {
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

fn validate_generated_rule_plan_v2(
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
                expected.contract_name(),
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

fn rust_string_literal(value: &str) -> Result<String, String> {
    serde_json::to_string(value).map_err(|e| format!("failed to encode Rust string literal: {e}"))
}
