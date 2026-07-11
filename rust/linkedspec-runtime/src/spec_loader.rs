//! Native file-oriented `.spec` resolution, loading, and compilation.
//!
//! This module implements ADR 0026 independently of the primary CLI. Callers
//! choose a portable logical name or one exact host path, provide cwd and
//! ordered search roots, and receive source identity plus a backend-native
//! compiled spec or a structured pipeline error.

use crate::engine::Engine;
use crate::spec_parser::parse_spec_with_user_functions;
use linkedspec_core::compiler::compile;
use linkedspec_core::types::CompiledSpec;
use linkedspec_core::validation::validate;
use serde::Serialize;
use std::collections::HashSet;
use std::fs;
use std::path::{Path, PathBuf};
use thiserror::Error;

/// The caller's file-selection intent.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum SpecRequestKind {
    /// Resolve a portable logical spec identity through cwd and ordered roots.
    Name,
    /// Open one absolute or cwd-relative host path exactly.
    Path,
}

impl SpecRequestKind {
    /// Stable backend-neutral spelling used by diagnostics and fixtures.
    pub const fn as_str(self) -> &'static str {
        match self {
            Self::Name => "name",
            Self::Path => "path",
        }
    }
}

/// A named or exact-path request for one `.spec` file.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SpecRequest {
    kind: SpecRequestKind,
    requested: String,
}

impl SpecRequest {
    /// Construct a portable named-spec request.
    pub fn named(name: impl Into<String>) -> Self {
        Self {
            kind: SpecRequestKind::Name,
            requested: name.into(),
        }
    }

    /// Construct an exact host-path request.
    pub fn path(path: impl Into<String>) -> Self {
        Self {
            kind: SpecRequestKind::Path,
            requested: path.into(),
        }
    }

    /// Return whether this is a name or exact-path request.
    pub const fn kind(&self) -> SpecRequestKind {
        self.kind
    }

    /// Return the caller-supplied identity unchanged.
    pub fn requested(&self) -> &str {
        &self.requested
    }
}

/// Filesystem context for deterministic resolution.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SpecLoadOptions {
    cwd: PathBuf,
    search_roots: Vec<PathBuf>,
}

impl SpecLoadOptions {
    /// Create options with no implicit search roots.
    pub fn new(cwd: impl Into<PathBuf>) -> Self {
        Self {
            cwd: cwd.into(),
            search_roots: Vec::new(),
        }
    }

    /// Append one direct search root after all roots already declared.
    pub fn with_search_root(mut self, root: impl Into<PathBuf>) -> Self {
        self.search_roots.push(root.into());
        self
    }

    /// Append direct search roots in iterator order.
    pub fn with_search_roots<I, P>(mut self, roots: I) -> Self
    where
        I: IntoIterator<Item = P>,
        P: Into<PathBuf>,
    {
        self.search_roots.extend(roots.into_iter().map(Into::into));
        self
    }

    /// Return the cwd used for relative candidates.
    pub fn cwd(&self) -> &Path {
        &self.cwd
    }

    /// Return direct search roots in declared order.
    pub fn search_roots(&self) -> &[PathBuf] {
        &self.search_roots
    }
}

/// Stable stage in the native file pipeline.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum SpecPipelineStage {
    ValidateSpecName,
    ValidateSpecPath,
    ResolveSpecPath,
    LoadSpecContent,
    DecodeSpecContent,
    ParseSpec,
    ValidateSpec,
    CompileSpec,
}

impl SpecPipelineStage {
    pub const fn as_str(self) -> &'static str {
        match self {
            Self::ValidateSpecName => "validate_spec_name",
            Self::ValidateSpecPath => "validate_spec_path",
            Self::ResolveSpecPath => "resolve_spec_path",
            Self::LoadSpecContent => "load_spec_content",
            Self::DecodeSpecContent => "decode_spec_content",
            Self::ParseSpec => "parse_spec",
            Self::ValidateSpec => "validate_spec",
            Self::CompileSpec => "compile_spec",
        }
    }
}

/// Stable machine-readable cause in the native file pipeline.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum SpecPipelineCode {
    InvalidSpecName,
    InvalidSpecPath,
    SpecPathNotFound,
    SpecPathNotFile,
    SpecReadFailed,
    InvalidUtf8,
    SpecParseFailed,
    SpecValidationFailed,
    SpecCompileFailed,
}

impl SpecPipelineCode {
    pub const fn as_str(self) -> &'static str {
        match self {
            Self::InvalidSpecName => "invalid_spec_name",
            Self::InvalidSpecPath => "invalid_spec_path",
            Self::SpecPathNotFound => "spec_path_not_found",
            Self::SpecPathNotFile => "spec_path_not_file",
            Self::SpecReadFailed => "spec_read_failed",
            Self::InvalidUtf8 => "invalid_utf8",
            Self::SpecParseFailed => "spec_parse_failed",
            Self::SpecValidationFailed => "spec_validation_failed",
            Self::SpecCompileFailed => "spec_compile_failed",
        }
    }
}

/// Structured, serializable native file-pipeline failure.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Error)]
#[error("{summary}")]
pub struct SpecPipelineError {
    #[serde(rename = "type")]
    pub error_type: &'static str,
    pub stage: SpecPipelineStage,
    pub code: SpecPipelineCode,
    pub summary: String,
    pub request_kind: SpecRequestKind,
    pub requested: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub resolved_path: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub detail: Option<String>,
}

impl SpecPipelineError {
    fn new(
        request: &SpecRequest,
        stage: SpecPipelineStage,
        code: SpecPipelineCode,
        summary: impl Into<String>,
    ) -> Self {
        Self {
            error_type: "spec_pipeline_error",
            stage,
            code,
            summary: summary.into(),
            request_kind: request.kind,
            requested: request.requested.clone(),
            resolved_path: None,
            detail: None,
        }
    }

    fn with_resolved_path(mut self, path: String) -> Self {
        self.resolved_path = Some(path);
        self
    }

    fn with_detail(mut self, detail: impl Into<String>) -> Self {
        self.detail = Some(detail.into());
        self
    }
}

/// Why a candidate won, exposed for direct fixture verification.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SpecCandidateOrigin {
    CwdExact,
    CwdSpecSuffix,
    SearchRoot { index: usize },
    PathExact,
}

impl SpecCandidateOrigin {
    /// Stable spelling used by the executable neutral fixture.
    pub fn contract_name(self) -> String {
        match self {
            Self::CwdExact => "cwd_exact".to_string(),
            Self::CwdSpecSuffix => "cwd_spec_suffix".to_string(),
            Self::SearchRoot { index } => format!("search_root:{index}"),
            Self::PathExact => "path_exact".to_string(),
        }
    }
}

/// Deterministically resolved request before file reading.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ResolvedSpec {
    request: SpecRequest,
    path: PathBuf,
    origin: SpecCandidateOrigin,
}

impl ResolvedSpec {
    pub fn request(&self) -> &SpecRequest {
        &self.request
    }

    pub fn path(&self) -> &Path {
        &self.path
    }

    pub const fn origin(&self) -> SpecCandidateOrigin {
        self.origin
    }
}

/// Strictly decoded file plus its source identity.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct LoadedSpec {
    resolved: ResolvedSpec,
    source_text: String,
}

impl LoadedSpec {
    pub fn resolved(&self) -> &ResolvedSpec {
        &self.resolved
    }

    pub fn source_text(&self) -> &str {
        &self.source_text
    }
}

/// Fully composed native result: identity, exact source, and compiled state.
#[derive(Debug, Clone)]
pub struct LoadedCompiledSpec {
    loaded: LoadedSpec,
    compiled: CompiledSpec,
}

impl LoadedCompiledSpec {
    pub fn loaded(&self) -> &LoadedSpec {
        &self.loaded
    }

    pub fn compiled(&self) -> &CompiledSpec {
        &self.compiled
    }

    pub fn into_compiled(self) -> CompiledSpec {
        self.compiled
    }

    /// Build a runtime engine with the resolved file identity attached.
    pub fn into_engine(self) -> Engine {
        let requested_name = (self.loaded.resolved.request.kind == SpecRequestKind::Name)
            .then(|| self.loaded.resolved.request.requested.clone());
        let resolved_path = self
            .loaded
            .resolved
            .path
            .to_str()
            .expect("resolved portable paths are validated before loading")
            .to_string();
        let mut engine = Engine::new(self.compiled).with_spec_path(resolved_path);
        if let Some(name) = requested_name {
            engine = engine.with_spec_name(name);
        }
        engine
    }
}

/// Validate request syntax without touching the filesystem.
pub fn validate_spec_request(request: &SpecRequest) -> Result<(), SpecPipelineError> {
    match request.kind {
        SpecRequestKind::Name => validate_name(request),
        SpecRequestKind::Path => validate_path(request),
    }
}

/// Resolve one request using only cwd and explicit roots.
pub fn resolve_spec(
    request: &SpecRequest,
    options: &SpecLoadOptions,
) -> Result<ResolvedSpec, SpecPipelineError> {
    validate_spec_request(request)?;
    let candidates = candidates(request, options);
    let mut first_non_regular = None;

    for (path, origin) in candidates {
        match fs::metadata(&path) {
            Ok(metadata) if metadata.is_file() => {
                portable_path_text(request, &path)?;
                return Ok(ResolvedSpec {
                    request: request.clone(),
                    path,
                    origin,
                });
            }
            Ok(_) => {
                if first_non_regular.is_none() {
                    first_non_regular = Some(path);
                }
            }
            Err(error) if error.kind() == std::io::ErrorKind::NotFound => {}
            Err(error) => {
                let path_text = portable_path_text(request, &path)?;
                return Err(SpecPipelineError::new(
                    request,
                    SpecPipelineStage::ResolveSpecPath,
                    SpecPipelineCode::SpecReadFailed,
                    "Unable to inspect spec path",
                )
                .with_resolved_path(path_text)
                .with_detail(error.to_string()));
            }
        }
    }

    if let Some(path) = first_non_regular {
        let path_text = portable_path_text(request, &path)?;
        return Err(SpecPipelineError::new(
            request,
            SpecPipelineStage::ResolveSpecPath,
            SpecPipelineCode::SpecPathNotFile,
            "Spec path is not a file",
        )
        .with_resolved_path(path_text));
    }

    Err(SpecPipelineError::new(
        request,
        SpecPipelineStage::ResolveSpecPath,
        SpecPipelineCode::SpecPathNotFound,
        "Spec path not found",
    ))
}

/// Resolve, read as bytes, and strictly decode one UTF-8 spec file.
pub fn load_spec(
    request: &SpecRequest,
    options: &SpecLoadOptions,
) -> Result<LoadedSpec, SpecPipelineError> {
    let resolved = resolve_spec(request, options)?;
    let resolved_path = portable_path_text(request, &resolved.path)?;
    let bytes = fs::read(&resolved.path).map_err(|error| {
        SpecPipelineError::new(
            request,
            SpecPipelineStage::LoadSpecContent,
            SpecPipelineCode::SpecReadFailed,
            "Unable to read spec file",
        )
        .with_resolved_path(resolved_path.clone())
        .with_detail(error.to_string())
    })?;
    let source_text = String::from_utf8(bytes).map_err(|error| {
        SpecPipelineError::new(
            request,
            SpecPipelineStage::DecodeSpecContent,
            SpecPipelineCode::InvalidUtf8,
            "Spec file is not valid UTF-8",
        )
        .with_resolved_path(resolved_path)
        .with_detail(error.to_string())
    })?;
    Ok(LoadedSpec {
        resolved,
        source_text,
    })
}

/// Resolve, strictly load, parse full source, validate, and compile in process.
pub fn load_and_compile_spec(
    request: &SpecRequest,
    options: &SpecLoadOptions,
) -> Result<LoadedCompiledSpec, SpecPipelineError> {
    let loaded = load_spec(request, options)?;
    let path_text = portable_path_text(request, loaded.resolved.path())?;
    let parsed = parse_spec_with_user_functions(loaded.source_text()).map_err(|detail| {
        SpecPipelineError::new(
            request,
            SpecPipelineStage::ParseSpec,
            SpecPipelineCode::SpecParseFailed,
            "Unable to parse spec",
        )
        .with_resolved_path(path_text.clone())
        .with_detail(detail)
    })?;
    validate(&parsed).map_err(|error| {
        SpecPipelineError::new(
            request,
            SpecPipelineStage::ValidateSpec,
            SpecPipelineCode::SpecValidationFailed,
            "Spec validation failed",
        )
        .with_resolved_path(path_text.clone())
        .with_detail(error.to_string())
    })?;
    let compiled = compile(&parsed).map_err(|error| {
        SpecPipelineError::new(
            request,
            SpecPipelineStage::CompileSpec,
            SpecPipelineCode::SpecCompileFailed,
            "Spec compilation failed",
        )
        .with_resolved_path(path_text)
        .with_detail(error.to_string())
    })?;
    Ok(LoadedCompiledSpec { loaded, compiled })
}

fn validate_name(request: &SpecRequest) -> Result<(), SpecPipelineError> {
    let name = request.requested();
    let has_surrounding_whitespace = name.chars().next().is_some_and(char::is_whitespace)
        || name.chars().next_back().is_some_and(char::is_whitespace);
    let has_windows_absolute_prefix = {
        let bytes = name.as_bytes();
        bytes.len() >= 3 && bytes[0].is_ascii_alphabetic() && bytes[1] == b':' && bytes[2] == b'/'
    };
    let invalid_component = name
        .split('/')
        .any(|component| component.is_empty() || component == "." || component == "..");
    let invalid = name.is_empty()
        || name.chars().all(char::is_whitespace)
        || has_surrounding_whitespace
        || name.chars().any(char::is_control)
        || name.starts_with('/')
        || name.contains('\\')
        || has_windows_absolute_prefix
        || invalid_component;
    if invalid {
        return Err(SpecPipelineError::new(
            request,
            SpecPipelineStage::ValidateSpecName,
            SpecPipelineCode::InvalidSpecName,
            "Invalid spec name",
        ));
    }
    Ok(())
}

fn validate_path(request: &SpecRequest) -> Result<(), SpecPipelineError> {
    if request.requested().is_empty() || request.requested().contains('\0') {
        return Err(SpecPipelineError::new(
            request,
            SpecPipelineStage::ValidateSpecPath,
            SpecPipelineCode::InvalidSpecPath,
            "Invalid spec path",
        ));
    }
    Ok(())
}

fn candidates(
    request: &SpecRequest,
    options: &SpecLoadOptions,
) -> Vec<(PathBuf, SpecCandidateOrigin)> {
    let mut raw = Vec::new();
    match request.kind {
        SpecRequestKind::Path => {
            let path = Path::new(request.requested());
            raw.push((
                if path.is_absolute() {
                    path.to_path_buf()
                } else {
                    options.cwd.join(path)
                },
                SpecCandidateOrigin::PathExact,
            ));
        }
        SpecRequestKind::Name => {
            let filename = if request.requested().ends_with(".spec") {
                request.requested().to_string()
            } else {
                format!("{}.spec", request.requested())
            };
            raw.push((
                options.cwd.join(request.requested()),
                SpecCandidateOrigin::CwdExact,
            ));
            raw.push((
                options.cwd.join(&filename),
                SpecCandidateOrigin::CwdSpecSuffix,
            ));
            raw.extend(
                options
                    .search_roots
                    .iter()
                    .enumerate()
                    .map(|(index, root)| {
                        (
                            root.join(&filename),
                            SpecCandidateOrigin::SearchRoot { index },
                        )
                    }),
            );
        }
    }
    let mut seen = HashSet::new();
    raw.into_iter()
        .filter(|(path, _)| seen.insert(path.clone()))
        .collect()
}

fn portable_path_text(request: &SpecRequest, path: &Path) -> Result<String, SpecPipelineError> {
    path.to_str().map(str::to_string).ok_or_else(|| {
        SpecPipelineError::new(
            request,
            SpecPipelineStage::ValidateSpecPath,
            SpecPipelineCode::InvalidSpecPath,
            "Spec path is not Unicode text",
        )
    })
}
