//! Opaque source/outcome authority and normalized semantic projection.
//!
//! `FUTURE-PARITY-BACKLOG.10.4.1` copies one caller-supplied source, builds exact
//! strict-UTF-8 byte/scalar coordinates, and retains compiled-or-failed authority.
//! `.10.4.2` lowers the static rule graph or failed outcome, and `.10.4.3` composes
//! typed calls, bindings, staged artifacts, and generated-plan provenance. The
//! clone-safe `linkedspec-semantic-model-v1` projection remains crate-private until
//! a later leaf adds the ceiling-enforcing query surface. Construction never
//! executes the target spec.

mod call_projection;
mod query;
mod static_projection;

pub use query::{
    SemanticQuery, SemanticQueryBudget, SemanticQueryCost, SemanticQueryDiagnostic,
    SemanticQueryDirection, SemanticQueryOperation, SemanticQueryPage, SemanticQueryPageState,
    SemanticQueryRecord, SemanticQueryRelation, SemanticQueryResponse, SemanticQuerySource,
    SemanticQuerySourceReference,
};

use crate::source_emitter::{
    GENERATED_SOURCE_CONTRACT, GENERATED_SOURCE_FORMAT, classify_generated_rule_family,
};
use crate::spec_parser::parse_spec_with_user_functions;
use linkedspec_core::ast::SpecFile;
use linkedspec_core::compiler::compile;
use linkedspec_core::error::{LinkedSpecError, PortableDiagnostic};
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::unicode_rule_label::is_rule_label;
use linkedspec_core::validation::validate;
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::collections::BTreeMap;
use std::fmt::Write;
use thiserror::Error;

const SNAPSHOT_ID: &str = "snapshot:0";
const SOURCE_ID: &str = "source:0";

/// Maximum source detail that a future semantic query may reveal.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum SemanticSourceDetail {
    None,
    Identity,
    Span,
    Text,
}

/// Required caller-owned construction policy for one semantic snapshot.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SemanticIndexOptions {
    logical_name: String,
    source_detail_ceiling: SemanticSourceDetail,
    entry_rule: Option<String>,
}

impl SemanticIndexOptions {
    /// Construct policy from a logical public identity and source ceiling.
    pub fn new(
        logical_name: impl Into<String>,
        source_detail_ceiling: SemanticSourceDetail,
    ) -> Self {
        Self {
            logical_name: logical_name.into(),
            source_detail_ceiling,
            entry_rule: None,
        }
    }

    /// Select one exact entry rule for this immutable snapshot.
    pub fn with_entry_rule(mut self, entry_rule: impl Into<String>) -> Self {
        self.entry_rule = Some(entry_rule.into());
        self
    }

    pub fn logical_name(&self) -> &str {
        &self.logical_name
    }

    pub const fn source_detail_ceiling(&self) -> SemanticSourceDetail {
        self.source_detail_ceiling
    }

    pub fn entry_rule(&self) -> Option<&str> {
        self.entry_rule.as_deref()
    }
}

/// Stable typed constructor/source-map failure before a snapshot can exist.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Error)]
#[error("{code} at {stage}: {message}")]
pub struct SemanticIndexError {
    pub stage: String,
    pub code: String,
    pub message: String,
    pub fields: BTreeMap<String, serde_json::Value>,
}

impl SemanticIndexError {
    fn new(stage: &str, code: &str, message: impl Into<String>) -> Self {
        Self {
            stage: stage.to_string(),
            code: code.to_string(),
            message: message.into(),
            fields: BTreeMap::new(),
        }
    }

    fn with_field(mut self, name: &str, value: impl Into<serde_json::Value>) -> Self {
        self.fields.insert(name.to_string(), value.into());
        self
    }
}

/// Immutable snapshot compilation state exposed without compiler objects.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum SemanticSnapshotState {
    Compiled,
    FailedCompilation,
}

/// Clone-safe foundation metadata; this is not a semantic query response.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct SemanticSnapshot {
    pub id: String,
    pub state: SemanticSnapshotState,
    pub has_execution: bool,
    pub source_detail_ceiling: SemanticSourceDetail,
    pub content_digest_available: bool,
}

/// Caller-registered source identity with no implicit filesystem path.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct SemanticSourceIdentity {
    pub source_id: String,
    pub logical_name: String,
    pub byte_length: usize,
    pub scalar_length: usize,
    pub content_digest: Option<String>,
}

/// Exact zero-based byte / one-based line-and-scalar-column span.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct SemanticSourceSpan {
    pub start_byte: usize,
    pub end_byte: usize,
    pub start_line: usize,
    pub start_column: usize,
    pub end_line: usize,
    pub end_column: usize,
}

/// Effective entry selection retained as plain identity rather than a rule borrow.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct SemanticEntrySelection {
    pub label: String,
    pub basis: String,
}

/// One owned generated-source-v2 plan row derived from shared family authority.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct SemanticGeneratedPlanRow {
    pub label: String,
    pub family: String,
}

/// Stable generated-plan input retained around compiled state.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct SemanticGeneratedPlanInput {
    pub contract_id: String,
    pub format_version: u32,
    pub source_identity: String,
    pub rows: Vec<SemanticGeneratedPlanRow>,
}

#[derive(Clone)]
struct SemanticSourceMap {
    byte_at_scalar: Vec<usize>,
    line_at_scalar: Vec<usize>,
    column_at_scalar: Vec<usize>,
}

impl SemanticSourceMap {
    fn new(source: &str) -> Self {
        let scalar_count = source.chars().count();
        let mut byte_at_scalar = Vec::with_capacity(scalar_count + 1);
        let mut line_at_scalar = Vec::with_capacity(scalar_count + 1);
        let mut column_at_scalar = Vec::with_capacity(scalar_count + 1);
        let (mut line, mut column) = (1, 1);
        byte_at_scalar.push(0);
        line_at_scalar.push(line);
        column_at_scalar.push(column);
        for (byte, character) in source.char_indices() {
            if character == '\n' {
                line += 1;
                column = 1;
            } else {
                column += 1;
            }
            byte_at_scalar.push(byte + character.len_utf8());
            line_at_scalar.push(line);
            column_at_scalar.push(column);
        }
        Self {
            byte_at_scalar,
            line_at_scalar,
            column_at_scalar,
        }
    }

    fn scalar_length(&self) -> usize {
        self.byte_at_scalar.len() - 1
    }

    fn span_for_scalar_range(
        &self,
        start: usize,
        end: usize,
    ) -> Result<SemanticSourceSpan, SemanticIndexError> {
        if start > end || end > self.scalar_length() {
            return Err(SemanticIndexError::new(
                "map_source",
                "semantic_source_range_invalid",
                "Source scalar range is outside the captured source",
            )
            .with_field("start_scalar", start)
            .with_field("end_scalar", end));
        }
        Ok(self.span_for_scalar_boundaries(start, end))
    }

    fn span_for_byte_range(
        &self,
        start: usize,
        end: usize,
    ) -> Result<SemanticSourceSpan, SemanticIndexError> {
        if start > end || end > *self.byte_at_scalar.last().expect("source map has EOF") {
            return Err(SemanticIndexError::new(
                "map_source",
                "semantic_source_range_invalid",
                "Source byte range is outside the captured source",
            )
            .with_field("start_byte", start)
            .with_field("end_byte", end));
        }
        let start_scalar = self.byte_at_scalar.binary_search(&start).map_err(|_| {
            SemanticIndexError::new(
                "map_source",
                "semantic_source_boundary_invalid",
                "Source byte range starts inside a UTF-8 scalar",
            )
            .with_field("start_byte", start)
        })?;
        let end_scalar = self.byte_at_scalar.binary_search(&end).map_err(|_| {
            SemanticIndexError::new(
                "map_source",
                "semantic_source_boundary_invalid",
                "Source byte range ends inside a UTF-8 scalar",
            )
            .with_field("end_byte", end)
        })?;
        Ok(self.span_for_scalar_boundaries(start_scalar, end_scalar))
    }

    fn span_for_scalar_boundaries(&self, start: usize, end: usize) -> SemanticSourceSpan {
        SemanticSourceSpan {
            start_byte: self.byte_at_scalar[start],
            end_byte: self.byte_at_scalar[end],
            start_line: self.line_at_scalar[start],
            start_column: self.column_at_scalar[start],
            end_line: self.line_at_scalar[end],
            end_column: self.column_at_scalar[end],
        }
    }
}

/// Opaque immutable source, parsed state, and compiled-or-failed authority.
#[derive(Clone)]
pub struct SemanticIndex {
    source_text: String,
    source_bytes: Vec<u8>,
    source_map: SemanticSourceMap,
    logical_name: String,
    source_detail_ceiling: SemanticSourceDetail,
    content_digest: String,
    parsed: Option<SpecFile>,
    validated: bool,
    compiled: Option<CompiledSpec>,
    compilation_diagnostic: Option<PortableDiagnostic>,
    entry_selection: Option<SemanticEntrySelection>,
    generated_plan: Option<SemanticGeneratedPlanInput>,
    // `.10.4.2` retains this for later crate-internal query composition; until
    // `.10.4.4`, only the focused in-module conformance tests consume the clone.
    #[cfg_attr(not(test), allow(dead_code))]
    static_projection: static_projection::SemanticStaticProjection,
}

impl std::fmt::Debug for SemanticIndex {
    fn fmt(&self, formatter: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        formatter
            .debug_struct("SemanticIndex")
            .field("snapshot", &self.snapshot())
            .field("source_id", &SOURCE_ID)
            .field(
                "logical_name",
                &if self.source_detail_ceiling >= SemanticSourceDetail::Identity {
                    self.logical_name.as_str()
                } else {
                    "<redacted>"
                },
            )
            .field("parsed", &self.parsed.is_some())
            .field("validated", &self.validated)
            .field("compiled", &self.compiled.is_some())
            .finish_non_exhaustive()
    }
}

impl SemanticIndex {
    /// Construct from already decoded Unicode text. The source is copied.
    pub fn from_source(
        source: &str,
        options: SemanticIndexOptions,
    ) -> Result<Self, SemanticIndexError> {
        validate_options(&options)?;
        Self::build(source.to_string(), source.as_bytes().to_vec(), options)
    }

    /// Strictly decode and copy UTF-8 bytes before any language parsing.
    pub fn from_utf8(
        source: &[u8],
        options: SemanticIndexOptions,
    ) -> Result<Self, SemanticIndexError> {
        validate_options(&options)?;
        let source_text = std::str::from_utf8(source).map_err(|error| {
            SemanticIndexError::new(
                "decode_source",
                "semantic_index_invalid_utf8",
                "Semantic index source is not valid UTF-8",
            )
            .with_field("valid_up_to", error.valid_up_to())
        })?;
        Self::build(source_text.to_string(), source.to_vec(), options)
    }

    fn build(
        source_text: String,
        source_bytes: Vec<u8>,
        options: SemanticIndexOptions,
    ) -> Result<Self, SemanticIndexError> {
        debug_assert_eq!(source_text.as_bytes(), source_bytes);
        let source_map = SemanticSourceMap::new(&source_text);
        let content_digest = sha256_identity(&source_bytes);
        let mut parsed = None;
        let mut validated = false;
        let mut compiled = None;
        let mut compilation_diagnostic = None;
        let mut entry_selection = None;
        let mut generated_plan = None;

        match parse_spec_with_user_functions(&source_text) {
            Err(message) => {
                compilation_diagnostic = Some(PortableDiagnostic::new(
                    "semantic_index_parse_failed",
                    "parse_source",
                    message,
                ));
            }
            Ok(spec) => {
                parsed = Some(spec.clone());
                match validate(&spec) {
                    Err(error) => {
                        compilation_diagnostic = Some(portable_failure(
                            error,
                            "semantic_index_validation_failed",
                            "validate_source",
                        ));
                    }
                    Ok(()) => {
                        validated = true;
                        match compile(&spec) {
                            Err(error) => {
                                compilation_diagnostic = Some(portable_failure(
                                    error,
                                    "semantic_index_compilation_failed",
                                    "compile_source",
                                ));
                            }
                            Ok(candidate) => {
                                match candidate.resolve_entry_rule(options.entry_rule.as_deref()) {
                                    Err(diagnostic) => {
                                        compilation_diagnostic = Some(diagnostic);
                                    }
                                    Ok(selection) => {
                                        entry_selection = Some(SemanticEntrySelection {
                                            label: selection.rule.label.clone(),
                                            basis: selection.basis.as_str().to_string(),
                                        });
                                        generated_plan = Some(SemanticGeneratedPlanInput {
                                            contract_id: GENERATED_SOURCE_CONTRACT.to_string(),
                                            format_version: GENERATED_SOURCE_FORMAT,
                                            source_identity: options.logical_name.clone(),
                                            rows: candidate
                                                .rules
                                                .iter()
                                                .map(|rule| SemanticGeneratedPlanRow {
                                                    label: rule.label.clone(),
                                                    family: classify_generated_rule_family(rule)
                                                        .contract_name()
                                                        .to_string(),
                                                })
                                                .collect(),
                                        });
                                        compiled = Some(candidate);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        let snapshot = SemanticSnapshot {
            id: SNAPSHOT_ID.to_string(),
            state: if compiled.is_some() {
                SemanticSnapshotState::Compiled
            } else {
                SemanticSnapshotState::FailedCompilation
            },
            has_execution: false,
            source_detail_ceiling: options.source_detail_ceiling,
            content_digest_available: options.source_detail_ceiling == SemanticSourceDetail::Text,
        };
        let static_projection = static_projection::build(static_projection::BuildInput {
            source_text: &source_text,
            source_map: &source_map,
            logical_name: &options.logical_name,
            content_digest: &content_digest,
            snapshot,
            parsed: parsed.as_ref(),
            compiled: compiled.as_ref(),
            diagnostic: compilation_diagnostic.as_ref(),
            entry_selection: entry_selection.as_ref(),
            generated_plan: generated_plan.as_ref(),
        })?;

        Ok(Self {
            source_text,
            source_bytes,
            source_map,
            logical_name: options.logical_name,
            source_detail_ceiling: options.source_detail_ceiling,
            content_digest,
            parsed,
            validated,
            compiled,
            compilation_diagnostic,
            entry_selection,
            generated_plan,
            static_projection,
        })
    }

    /// Return clone-safe foundation metadata without semantic records.
    pub fn snapshot(&self) -> SemanticSnapshot {
        SemanticSnapshot {
            id: SNAPSHOT_ID.to_string(),
            state: if self.compiled.is_some() {
                SemanticSnapshotState::Compiled
            } else {
                SemanticSnapshotState::FailedCompilation
            },
            has_execution: false,
            source_detail_ceiling: self.source_detail_ceiling,
            content_digest_available: self.source_detail_ceiling == SemanticSourceDetail::Text,
        }
    }

    /// Return copied caller identity and exact source sizes without a host path.
    pub fn source_identity(&self) -> Result<SemanticSourceIdentity, SemanticIndexError> {
        self.require_source_detail(SemanticSourceDetail::Identity)?;
        Ok(SemanticSourceIdentity {
            source_id: SOURCE_ID.to_string(),
            logical_name: self.logical_name.clone(),
            byte_length: self.source_bytes.len(),
            scalar_length: self.source_map.scalar_length(),
            content_digest: (self.source_detail_ceiling == SemanticSourceDetail::Text)
                .then(|| self.content_digest.clone()),
        })
    }

    /// Return whether each private compiler authority was retained.
    pub fn parsed_authority_present(&self) -> bool {
        self.parsed.is_some()
    }

    pub fn validated_authority_present(&self) -> bool {
        self.validated
    }

    pub fn compiled_authority_present(&self) -> bool {
        self.compiled.is_some()
    }

    /// Return a clone of the raw portable compiler failure, if construction failed.
    pub fn compilation_diagnostic(&self) -> Option<PortableDiagnostic> {
        self.compilation_diagnostic.clone()
    }

    /// Return the resolved entry identity without borrowing compiled state.
    pub fn entry_selection(&self) -> Option<SemanticEntrySelection> {
        self.entry_selection.clone()
    }

    /// Return the shared generated-v2 plan input without compiled host state.
    pub fn generated_plan(&self) -> Result<Option<SemanticGeneratedPlanInput>, SemanticIndexError> {
        self.require_source_detail(SemanticSourceDetail::Identity)?;
        Ok(self.generated_plan.clone())
    }

    /// Return a fresh crate-private normalized static projection.
    ///
    /// This deliberately is not a public pre-query escape hatch: source filtering
    /// and capabilities/query are owned by later leaves. Keeping the clone seam
    /// here lets those evaluators consume only plain normalized data, never AST or
    /// compiled host state.
    #[cfg_attr(not(test), allow(dead_code))]
    pub(crate) fn static_projection(&self) -> static_projection::SemanticStaticProjection {
        self.static_projection.clone()
    }

    /// Return the canonical semantic-query-v1 capabilities response.
    pub fn capabilities(&self) -> SemanticQueryResponse {
        query::evaluate(
            &self.static_projection(),
            &SemanticQuery::capabilities_value(),
        )
    }

    /// Evaluate one typed immutable semantic query over a cloned projection.
    pub fn query(&self, request: &SemanticQuery) -> SemanticQueryResponse {
        let request = serde_json::to_value(request).expect("SemanticQuery always serializes");
        query::evaluate(&self.static_projection(), &request)
    }

    /// Evaluate the exact neutral JSON request, including portable validation errors.
    ///
    /// This transport-facing seam exists so malformed neutral requests receive the
    /// same response envelope as every other backend. It does not deserialize or
    /// expose compiler state.
    pub fn query_neutral(&self, request: &serde_json::Value) -> SemanticQueryResponse {
        query::evaluate(&self.static_projection(), request)
    }

    /// Map an exact byte range when the caller permitted span detail.
    pub fn source_span_for_bytes(
        &self,
        start: usize,
        end: usize,
    ) -> Result<SemanticSourceSpan, SemanticIndexError> {
        self.require_source_detail(SemanticSourceDetail::Span)?;
        self.source_map.span_for_byte_range(start, end)
    }

    /// Map an exact Unicode-scalar range when the caller permitted span detail.
    pub fn source_span_for_scalars(
        &self,
        start: usize,
        end: usize,
    ) -> Result<SemanticSourceSpan, SemanticIndexError> {
        self.require_source_detail(SemanticSourceDetail::Span)?;
        self.source_map.span_for_scalar_range(start, end)
    }

    /// Return exact decoded source text when the caller permitted text detail.
    pub fn source_excerpt_for_bytes(
        &self,
        start: usize,
        end: usize,
    ) -> Result<String, SemanticIndexError> {
        self.require_source_detail(SemanticSourceDetail::Text)?;
        let span = self.source_map.span_for_byte_range(start, end)?;
        Ok(self.source_text[span.start_byte..span.end_byte].to_string())
    }

    /// Locate one exact decoded occurrence after an exact byte boundary.
    pub fn locate_exact(
        &self,
        needle: &str,
        after_byte: usize,
    ) -> Result<Option<SemanticSourceSpan>, SemanticIndexError> {
        self.require_source_detail(SemanticSourceDetail::Span)?;
        if needle.is_empty() {
            return Err(SemanticIndexError::new(
                "map_source",
                "semantic_source_needle_invalid",
                "Source lookup needle must not be empty",
            ));
        }
        self.source_map
            .span_for_byte_range(after_byte, after_byte)?;
        let Some(relative) = self.source_text[after_byte..].find(needle) else {
            return Ok(None);
        };
        let start = after_byte + relative;
        let end = start + needle.len();
        self.source_map.span_for_byte_range(start, end).map(Some)
    }

    fn require_source_detail(
        &self,
        required: SemanticSourceDetail,
    ) -> Result<(), SemanticIndexError> {
        if self.source_detail_ceiling < required {
            return Err(SemanticIndexError::new(
                "apply_source_ceiling",
                "semantic_source_detail_forbidden",
                "Requested source detail exceeds the semantic index ceiling",
            )
            .with_field("ceiling", source_detail_name(self.source_detail_ceiling))
            .with_field("required", source_detail_name(required)));
        }
        Ok(())
    }
}

fn validate_options(options: &SemanticIndexOptions) -> Result<(), SemanticIndexError> {
    if options.logical_name.is_empty() || options.logical_name.chars().any(char::is_control) {
        return Err(SemanticIndexError::new(
            "validate_options",
            "semantic_index_invalid_option",
            "Semantic index logical name must be nonempty and contain no control characters",
        )
        .with_field("option", "logical_name"));
    }
    if let Some(entry_rule) = &options.entry_rule
        && !is_rule_label(entry_rule)
    {
        return Err(SemanticIndexError::new(
            "validate_options",
            "semantic_index_invalid_option",
            "Semantic index entry rule must be a valid rule label",
        )
        .with_field("option", "entry_rule"));
    }
    Ok(())
}

fn portable_failure(
    error: LinkedSpecError,
    fallback_code: &str,
    fallback_stage: &str,
) -> PortableDiagnostic {
    match error {
        LinkedSpecError::Diagnostic(diagnostic) => diagnostic,
        LinkedSpecError::Parse { line, message } => {
            PortableDiagnostic::new(fallback_code, fallback_stage, message).with_field("line", line)
        }
        other => PortableDiagnostic::new(fallback_code, fallback_stage, other.to_string()),
    }
}

fn sha256_identity(source: &[u8]) -> String {
    let digest = Sha256::digest(source);
    let mut identity = String::with_capacity(7 + digest.len() * 2);
    identity.push_str("sha256:");
    for byte in digest {
        write!(&mut identity, "{byte:02x}").expect("writing to String cannot fail");
    }
    identity
}

const fn source_detail_name(detail: SemanticSourceDetail) -> &'static str {
    match detail {
        SemanticSourceDetail::None => "none",
        SemanticSourceDetail::Identity => "identity",
        SemanticSourceDetail::Span => "span",
        SemanticSourceDetail::Text => "text",
    }
}
