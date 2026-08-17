//! Private authority for synchronous child parsing over one bounded source span.
//!
//! This module owns no authored syntax, ActionIR node, engine carrier, generated
//! format, or rollout decision. A host seeds already-compiled callbacks, starts
//! one invocation over caller-owned decoded sources, and may then dispatch only
//! by immutable logical identity.

use crate::source_location::{SourceAuthority, SourceLocationContext};
use serde_json::{Map, Value, json};
use std::collections::{BTreeMap, BTreeSet};
use std::fmt;
use std::panic::{AssertUnwindSafe, catch_unwind};
use std::sync::Arc;
use std::sync::atomic::{AtomicBool, Ordering};

const EFFECT: &str = "parser_registry_or_staged_dispatch";
const LIVE_RESULT_FIELD_TOKENS: &[&str] = &[
    "authority",
    "handle",
    "parser",
    "registry",
    "transaction",
    "cancellation",
    "path",
    "source_text",
    "host",
];

/// One validated diagnostic-detail ceiling.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum ProgressiveSourceDetail {
    /// Reveal no source identity or coordinates in child diagnostics.
    None,
    /// Reveal source identity only.
    Identity,
    /// Reveal identity and spans.
    Span,
    /// Reveal identity, spans, and bounded source text.
    Text,
}

impl ProgressiveSourceDetail {
    /// Parse the neutral source-detail spelling.
    pub fn parse(value: &str) -> Result<Self, ProgressiveConfigurationError> {
        match value {
            "none" => Ok(Self::None),
            "identity" => Ok(Self::Identity),
            "span" => Ok(Self::Span),
            "text" => Ok(Self::Text),
            _ => Err(ProgressiveConfigurationError::new(format!(
                "invalid progressive source detail {value:?}"
            ))),
        }
    }

    /// Return the neutral source-detail spelling.
    pub const fn as_str(self) -> &'static str {
        match self {
            Self::None => "none",
            Self::Identity => "identity",
            Self::Span => "span",
            Self::Text => "text",
        }
    }
}

/// Capability, policy, and resource ceilings carried by one authority.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ProgressiveCeilings {
    source_detail: ProgressiveSourceDetail,
    policy_modes: Box<[String]>,
    max_steps: u64,
    max_result_nodes: u64,
    max_diagnostic_bytes: u64,
}

impl ProgressiveCeilings {
    /// Validate and own one complete ceiling record.
    pub fn new(
        source_detail: ProgressiveSourceDetail,
        policy_modes: Vec<String>,
        max_steps: u64,
        max_result_nodes: u64,
        max_diagnostic_bytes: u64,
    ) -> Result<Self, ProgressiveConfigurationError> {
        let policy_modes = validated_nonempty_strings(policy_modes, "policy modes")?;
        if max_steps == 0 || max_result_nodes == 0 || max_diagnostic_bytes == 0 {
            return Err(ProgressiveConfigurationError::new(
                "progressive numeric ceilings must be positive",
            ));
        }
        Ok(Self {
            source_detail,
            policy_modes,
            max_steps,
            max_result_nodes,
            max_diagnostic_bytes,
        })
    }

    /// Return the source-detail ceiling.
    pub const fn source_detail(&self) -> ProgressiveSourceDetail {
        self.source_detail
    }
}

/// Exact result channel for one already-compiled child parser.
pub type ProgressiveChildResult = Result<Value, String>;

/// Immutable already-compiled child-parser callback.
pub type ProgressiveCompiledAuthority = Arc<
    dyn for<'registry> Fn(
            &ProgressiveDispatchRequest,
            &mut ProgressiveInvocation<'registry>,
        ) -> ProgressiveChildResult
        + Send
        + Sync,
>;

/// One host-seeded immutable registry entry.
#[derive(Clone)]
pub struct ProgressiveRegistryEntry {
    parser_id: Box<str>,
    compiled_authority: ProgressiveCompiledAuthority,
    fingerprint: Box<str>,
    allowed_top_rules: Box<[String]>,
    capabilities: Box<[String]>,
    ceilings: ProgressiveCeilings,
}

impl ProgressiveRegistryEntry {
    /// Validate and deeply own one already-compiled parser entry.
    pub fn new(
        parser_id: impl Into<String>,
        compiled_authority: ProgressiveCompiledAuthority,
        fingerprint: impl Into<String>,
        allowed_top_rules: Vec<String>,
        capabilities: Vec<String>,
        ceilings: ProgressiveCeilings,
    ) -> Result<Self, ProgressiveConfigurationError> {
        let parser_id = parser_id.into();
        if !valid_parser_id(&parser_id) {
            return Err(ProgressiveConfigurationError::new(format!(
                "invalid progressive parser identity {parser_id:?}"
            )));
        }
        let fingerprint = fingerprint.into();
        if !valid_fingerprint(&fingerprint) {
            return Err(ProgressiveConfigurationError::new(format!(
                "invalid progressive fingerprint for {parser_id:?}"
            )));
        }
        let allowed_top_rules =
            validated_nonempty_strings(allowed_top_rules, "allowed progressive top rules")?;
        if allowed_top_rules.iter().any(|rule| !valid_top_rule(rule)) {
            return Err(ProgressiveConfigurationError::new(format!(
                "invalid allowed top rule for {parser_id:?}"
            )));
        }
        let capabilities = validated_nonempty_strings(capabilities, "progressive capabilities")?;
        Ok(Self {
            parser_id: parser_id.into_boxed_str(),
            compiled_authority,
            fingerprint: fingerprint.into_boxed_str(),
            allowed_top_rules,
            capabilities,
            ceilings,
        })
    }
}

/// Immutable logical registry over already-compiled parsers.
pub struct ProgressiveRegistry {
    entries: BTreeMap<Box<str>, ProgressiveRegistryEntry>,
}

impl ProgressiveRegistry {
    /// Validate and deeply own a nonempty, duplicate-free registry.
    pub fn new(
        entries: Vec<ProgressiveRegistryEntry>,
    ) -> Result<Self, ProgressiveConfigurationError> {
        if entries.is_empty() {
            return Err(ProgressiveConfigurationError::new(
                "progressive registry must be nonempty",
            ));
        }
        let mut entry_by_id = BTreeMap::new();
        for entry in entries {
            let parser_id = entry.parser_id.clone();
            if entry_by_id.insert(parser_id.clone(), entry).is_some() {
                return Err(ProgressiveConfigurationError::new(format!(
                    "duplicate progressive parser identity {parser_id:?}"
                )));
            }
        }
        Ok(Self {
            entries: entry_by_id,
        })
    }

    /// Reject runtime registry mutation.
    pub fn register(&self, parser_id: &str) -> Result<(), ProgressiveDispatchError> {
        Err(ProgressiveDispatchError::new(
            "progressive_registry_mutation_forbidden",
            [
                ("origin", json!("registry:register")),
                ("parser_id", json!(parser_id)),
            ],
        ))
    }

    /// Reject path or provider loading during execution.
    pub fn load(&self, parser_id: &str) -> Result<(), ProgressiveDispatchError> {
        Err(ProgressiveDispatchError::new(
            "progressive_implicit_load_forbidden",
            [
                ("origin", json!("registry:load")),
                ("parser_id", json!(parser_id)),
            ],
        ))
    }

    /// Start one invocation with fresh, caller-owned source and limit authority.
    pub fn start_invocation(
        &self,
        config: ProgressiveInvocationConfig,
    ) -> Result<ProgressiveInvocation<'_>, ProgressiveConfigurationError> {
        ProgressiveInvocation::new(self, config)
    }
}

/// Identity-bearing cancellation authority shared by parent and children.
#[derive(Clone)]
pub struct ProgressiveCancellationToken {
    cancelled: Arc<AtomicBool>,
}

impl ProgressiveCancellationToken {
    /// Create one fresh, uncancelled authority.
    pub fn new() -> Self {
        Self {
            cancelled: Arc::new(AtomicBool::new(false)),
        }
    }

    /// Cancel this authority and every child sharing it.
    pub fn cancel(&self) {
        self.cancelled.store(true, Ordering::Release);
    }

    fn is_cancelled(&self) -> bool {
        self.cancelled.load(Ordering::Acquire)
    }

    fn same_authority(&self, other: &Self) -> bool {
        Arc::ptr_eq(&self.cancelled, &other.cancelled)
    }
}

impl Default for ProgressiveCancellationToken {
    fn default() -> Self {
        Self::new()
    }
}

/// Caller-owned monotonic clock used only at dispatch safe points.
#[derive(Clone)]
pub struct ProgressiveClock {
    now: Arc<dyn Fn() -> u64 + Send + Sync>,
}

impl ProgressiveClock {
    /// Wrap one monotonic tick provider.
    pub fn new(now: impl Fn() -> u64 + Send + Sync + 'static) -> Self {
        Self { now: Arc::new(now) }
    }

    fn now(&self) -> u64 {
        (self.now)()
    }
}

/// One active parser/top/source/global-span chain row.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ProgressiveChainFrame {
    parser_id: Box<str>,
    top_rule: Box<str>,
    source_id: Box<str>,
    start: u64,
    end: u64,
}

impl ProgressiveChainFrame {
    /// Construct one chain row; invocation construction validates its source span.
    pub fn new(
        parser_id: impl Into<String>,
        top_rule: impl Into<String>,
        source_id: impl Into<String>,
        start: u64,
        end: u64,
    ) -> Result<Self, ProgressiveConfigurationError> {
        let parser_id = parser_id.into();
        let top_rule = top_rule.into();
        let source_id = source_id.into();
        if !valid_parser_id(&parser_id) || !valid_top_rule(&top_rule) || source_id.is_empty() {
            return Err(ProgressiveConfigurationError::new(
                "invalid progressive active-chain identity",
            ));
        }
        Ok(Self {
            parser_id: parser_id.into_boxed_str(),
            top_rule: top_rule.into_boxed_str(),
            source_id: source_id.into_boxed_str(),
            start,
            end,
        })
    }
}

/// Complete fresh-invocation authority supplied by the host.
pub struct ProgressiveInvocationConfig {
    /// Decoded source snapshots keyed by opaque source identity.
    pub sources: BTreeMap<String, String>,
    /// The only source identity this invocation may dispatch.
    pub source_id: String,
    /// Shared cancellation authority.
    pub cancellation_token: ProgressiveCancellationToken,
    /// Shared monotonic clock.
    pub clock: ProgressiveClock,
    /// Exclusive deadline tick.
    pub deadline_tick: u64,
    /// Shared remaining step budget.
    pub remaining_steps: u64,
    /// Maximum active progressive depth.
    pub max_depth: usize,
    /// Maximum total progressive calls.
    pub max_calls: u64,
    /// Existing active chain when composing an already-running authority.
    pub active_chain: Vec<ProgressiveChainFrame>,
    /// Existing total call count when composing an already-running authority.
    pub total_calls: u64,
}

/// One runtime dispatch request before static ActionIR carriers exist.
pub struct ProgressiveDispatchArguments {
    /// Diagnostic origin.
    pub origin: String,
    /// Dynamic defensive representation of the required literal parser id.
    pub parser_id: Value,
    /// Dynamic defensive representation of the required literal top rule.
    pub top_rule: Value,
    /// Exact four-field direct span record.
    pub span: Value,
    /// Caller capability grants.
    pub caller_capabilities: Vec<String>,
    /// Capabilities required by this call.
    pub required_capabilities: Vec<String>,
    /// Caller policy and resource ceilings.
    pub caller_ceilings: ProgressiveCeilings,
    /// Minimum diagnostic source detail required by the call.
    pub required_source_detail: ProgressiveSourceDetail,
    /// The exact shared child cancellation authority.
    pub child_token: ProgressiveCancellationToken,
    /// Step cost charged before child execution.
    pub cost: u64,
    /// Whether the caller is inside an uncommitted recognition transaction.
    pub transaction_active: bool,
}

/// Exact narrowed authority delivered to the child.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ProgressiveEffectiveAuthority {
    capabilities: Box<[String]>,
    source_detail: ProgressiveSourceDetail,
    policy_modes: Box<[String]>,
    max_steps: u64,
    max_result_nodes: u64,
    max_diagnostic_bytes: u64,
}

impl ProgressiveEffectiveAuthority {
    /// Return one detached neutral record.
    pub fn as_record(&self) -> Value {
        json!({
            "capabilities": self.capabilities,
            "source_detail": self.source_detail.as_str(),
            "policy_modes": self.policy_modes,
            "max_steps": self.max_steps,
            "max_result_nodes": self.max_result_nodes,
            "max_diagnostic_bytes": self.max_diagnostic_bytes,
        })
    }
}

/// Child request containing no path, loader, compiler, or parent parser state.
pub struct ProgressiveDispatchRequest {
    parser_id: Box<str>,
    top_rule: Box<str>,
    fingerprint: Box<str>,
    source_view: ProgressiveSourceView,
    effective: ProgressiveEffectiveAuthority,
    cancellation_token: ProgressiveCancellationToken,
    deadline_tick: u64,
    remaining_steps: u64,
}

impl ProgressiveDispatchRequest {
    /// Return the logical parser identity.
    pub fn parser_id(&self) -> &str {
        &self.parser_id
    }

    /// Return the selected allowed top rule.
    pub fn top_rule(&self) -> &str {
        &self.top_rule
    }

    /// Return the immutable compiled-content fingerprint.
    pub fn fingerprint(&self) -> &str {
        &self.fingerprint
    }

    /// Borrow the callback-scoped source view.
    pub fn source_view(&self) -> &ProgressiveSourceView {
        &self.source_view
    }

    /// Borrow the exact narrowed authority.
    pub fn effective(&self) -> &ProgressiveEffectiveAuthority {
        &self.effective
    }

    /// Return the shared cancellation authority.
    pub fn cancellation_token(&self) -> ProgressiveCancellationToken {
        self.cancellation_token.clone()
    }

    /// Return the inherited deadline.
    pub const fn deadline_tick(&self) -> u64 {
        self.deadline_tick
    }

    /// Return the child-visible remaining shared budget.
    pub const fn remaining_steps(&self) -> u64 {
        self.remaining_steps
    }
}

/// One bounded callback-scoped source view.
#[derive(Clone)]
pub struct ProgressiveSourceView {
    state: Arc<ProgressiveSourceViewState>,
}

struct ProgressiveSourceViewState {
    active: AtomicBool,
    authority: Arc<SourceAuthority>,
    source_id: Box<str>,
    text: Box<str>,
    start: u64,
    end: u64,
    provenance: Box<str>,
    origin: Box<str>,
    diagnostic_ceiling: u64,
}

impl ProgressiveSourceView {
    /// Return only the bounded decoded child text.
    pub fn text(&self) -> Result<String, ProgressiveSourceViewError> {
        self.ensure_active()?;
        Ok(self.state.text.to_string())
    }

    /// Return the original source identity.
    pub fn source_id(&self) -> Result<String, ProgressiveSourceViewError> {
        self.ensure_active()?;
        Ok(self.state.source_id.to_string())
    }

    /// Return the provenance carried by the caller's direct span.
    pub fn provenance(&self) -> Result<String, ProgressiveSourceViewError> {
        self.ensure_active()?;
        Ok(self.state.provenance.to_string())
    }

    /// Rebase one local Unicode-scalar boundary into the original source.
    pub fn local_to_global(&self, offset: u64) -> Result<u64, ProgressiveSourceViewError> {
        self.ensure_local_offset(offset)?;
        Ok(self.state.start + offset)
    }

    /// Return one detached globally rebased typed-position record.
    pub fn rebase_position(&self, offset: u64) -> Result<Value, ProgressiveSourceViewError> {
        let global = self.local_to_global(offset)?;
        let context = self.location_context();
        self.state
            .authority
            .position(&self.state.source_id, global, &context)
            .map(|position| position.as_record())
            .map_err(|error| ProgressiveSourceViewError::Internal(error.to_string()))
    }

    /// Validate and globally rebase one local exact span record.
    pub fn rebase_span(&self, span: &Value) -> Result<Value, ProgressiveSourceViewError> {
        self.ensure_active()?;
        let span =
            parse_span(span, &self.state.origin).map_err(ProgressiveSourceViewError::Dispatch)?;
        if span.source_id != self.state.source_id.as_ref() {
            return Err(ProgressiveSourceViewError::Dispatch(
                progressive_source_mismatch(
                    &self.state.origin,
                    &self.state.source_id,
                    &span.source_id,
                ),
            ));
        }
        self.ensure_local_offset(span.start)?;
        self.ensure_local_offset(span.end)?;
        if span.start > span.end {
            return Err(ProgressiveSourceViewError::Dispatch(
                progressive_reversed_span(
                    &self.state.origin,
                    &span.source_id,
                    span.start,
                    span.end,
                ),
            ));
        }
        let context = self.location_context();
        let start = self
            .state
            .authority
            .position(&span.source_id, self.state.start + span.start, &context)
            .map_err(|error| ProgressiveSourceViewError::Internal(error.to_string()))?;
        let end = self
            .state
            .authority
            .position(&span.source_id, self.state.start + span.end, &context)
            .map_err(|error| ProgressiveSourceViewError::Internal(error.to_string()))?;
        self.state
            .authority
            .direct_span(&start, &end, &span.provenance, &context)
            .map(|value| value.as_record())
            .map_err(|error| ProgressiveSourceViewError::Internal(error.to_string()))
    }

    /// Rebase local offset/span fields and retain only detached diagnostic data.
    pub fn rebase_diagnostic(
        &self,
        diagnostic: &Value,
    ) -> Result<Value, ProgressiveSourceViewError> {
        self.ensure_active()?;
        let object = diagnostic.as_object().ok_or_else(|| {
            ProgressiveSourceViewError::Internal("diagnostic must be an object".to_owned())
        })?;
        let mut copy = Map::new();
        for (key, value) in object {
            if key == "span" && value.is_object() {
                copy.insert(key.clone(), self.rebase_span(value)?);
            } else if offset_field(key) {
                if let Some(offset) = value.as_u64() {
                    copy.insert(key.clone(), json!(self.local_to_global(offset)?));
                } else {
                    copy.insert(key.clone(), value.clone());
                }
            } else {
                copy.insert(key.clone(), value.clone());
            }
        }
        copy.insert("source_id".to_owned(), json!(self.state.source_id.as_ref()));
        let value = Value::Object(copy);
        let byte_len = serde_json::to_vec(&value)
            .map_err(|error| ProgressiveSourceViewError::Internal(error.to_string()))?
            .len();
        if u64::try_from(byte_len).unwrap_or(u64::MAX) > self.state.diagnostic_ceiling {
            return Err(ProgressiveSourceViewError::Internal(
                "rebased diagnostic exceeds its effective byte ceiling".to_owned(),
            ));
        }
        Ok(value)
    }

    fn ensure_active(&self) -> Result<(), ProgressiveSourceViewError> {
        if self.state.active.load(Ordering::Acquire) {
            Ok(())
        } else {
            Err(ProgressiveSourceViewError::Expired)
        }
    }

    fn ensure_local_offset(&self, offset: u64) -> Result<(), ProgressiveSourceViewError> {
        self.ensure_active()?;
        let length = self.state.end - self.state.start;
        if offset <= length {
            return Ok(());
        }
        Err(ProgressiveSourceViewError::Dispatch(
            progressive_out_of_bounds(
                &self.state.origin,
                &self.state.source_id,
                offset,
                offset,
                length,
            ),
        ))
    }

    fn location_context(&self) -> SourceLocationContext {
        SourceLocationContext::new("progressive_child", self.state.origin.to_string())
    }

    fn invalidate(&self) {
        self.state.active.store(false, Ordering::Release);
    }
}

/// Failure from using a transient source view.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ProgressiveSourceViewError {
    /// The callback retained the view beyond child execution.
    Expired,
    /// One portable dispatch diagnostic rejected local data.
    Dispatch(ProgressiveDispatchError),
    /// One private invariant failed.
    Internal(String),
}

impl fmt::Display for ProgressiveSourceViewError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Expired => write!(
                formatter,
                "progressive source view is outside child execution"
            ),
            Self::Dispatch(error) => write!(formatter, "{error}"),
            Self::Internal(message) => write!(formatter, "{message}"),
        }
    }
}

impl std::error::Error for ProgressiveSourceViewError {}

/// One shared invocation authority. It contains no parent parser registers.
pub struct ProgressiveInvocation<'registry> {
    registry: &'registry ProgressiveRegistry,
    source_authority: Arc<SourceAuthority>,
    source_id: Box<str>,
    cancellation_token: ProgressiveCancellationToken,
    clock: ProgressiveClock,
    deadline_tick: u64,
    remaining_steps: u64,
    max_depth: usize,
    max_calls: u64,
    total_calls: u64,
    active_chain: Vec<ProgressiveChainFrame>,
}

impl<'registry> ProgressiveInvocation<'registry> {
    fn new(
        registry: &'registry ProgressiveRegistry,
        config: ProgressiveInvocationConfig,
    ) -> Result<Self, ProgressiveConfigurationError> {
        if config.sources.is_empty() || config.source_id.is_empty() {
            return Err(ProgressiveConfigurationError::new(
                "progressive invocation requires decoded sources and one source id",
            ));
        }
        if !config.sources.contains_key(&config.source_id) {
            return Err(ProgressiveConfigurationError::new(format!(
                "progressive invocation source {:?} is unavailable",
                config.source_id
            )));
        }
        if config.max_depth == 0 || config.max_calls == 0 {
            return Err(ProgressiveConfigurationError::new(
                "progressive depth and call limits must be positive",
            ));
        }
        let source_authority = Arc::new(SourceAuthority::new(&config.sources));
        for frame in &config.active_chain {
            let Some(length) = source_authority.source_scalar_length(&frame.source_id) else {
                return Err(ProgressiveConfigurationError::new(
                    "progressive active-chain source is unavailable",
                ));
            };
            if frame.start > frame.end || frame.end > length {
                return Err(ProgressiveConfigurationError::new(
                    "progressive active-chain span is invalid",
                ));
            }
        }
        Ok(Self {
            registry,
            source_authority,
            source_id: config.source_id.into_boxed_str(),
            cancellation_token: config.cancellation_token,
            clock: config.clock,
            deadline_tick: config.deadline_tick,
            remaining_steps: config.remaining_steps,
            max_depth: config.max_depth,
            max_calls: config.max_calls,
            total_calls: config.total_calls,
            active_chain: config.active_chain,
        })
    }

    /// Execute one synchronous isolated child dispatch.
    pub fn dispatch(
        &mut self,
        arguments: ProgressiveDispatchArguments,
    ) -> Result<Value, ProgressiveDispatchError> {
        let origin = if arguments.origin.is_empty() {
            "dispatch_span"
        } else {
            arguments.origin.as_str()
        };
        let parser_id = literal_string(
            &arguments.parser_id,
            origin,
            "progressive_parser_identity_literal_required",
        )?;
        if !valid_parser_id(parser_id) {
            return Err(ProgressiveDispatchError::new(
                "progressive_parser_identity_invalid",
                [("origin", json!(origin)), ("parser_id", json!(parser_id))],
            ));
        }
        let top_rule = literal_string(
            &arguments.top_rule,
            origin,
            "progressive_top_rule_literal_required",
        )?;
        if !valid_top_rule(top_rule) {
            return Err(ProgressiveDispatchError::new(
                "progressive_top_rule_invalid",
                [("origin", json!(origin)), ("top_rule", json!(top_rule))],
            ));
        }
        if !arguments.span.is_object() {
            return Err(ProgressiveDispatchError::new(
                "progressive_span_binding_required",
                [
                    ("origin", json!(origin)),
                    ("operand", diagnostic_operand(&arguments.span)),
                ],
            ));
        }
        let span = parse_span(&arguments.span, origin)?;
        if span.source_id != self.source_id.as_ref() {
            return Err(progressive_source_mismatch(
                origin,
                &self.source_id,
                &span.source_id,
            ));
        }
        let source_length = self
            .source_authority
            .source_scalar_length(&span.source_id)
            .unwrap_or(0);
        if span.end > source_length {
            return Err(progressive_out_of_bounds(
                origin,
                &span.source_id,
                span.start,
                span.end,
                source_length,
            ));
        }
        if span.start > span.end {
            return Err(progressive_reversed_span(
                origin,
                &span.source_id,
                span.start,
                span.end,
            ));
        }
        if arguments.transaction_active {
            return Err(ProgressiveDispatchError::new(
                "progressive_transaction_forbidden",
                [("origin", json!(origin)), ("effect", json!(EFFECT))],
            ));
        }

        let entry = self
            .registry
            .entries
            .get(parser_id)
            .cloned()
            .ok_or_else(|| {
                ProgressiveDispatchError::new(
                    "progressive_registry_missing",
                    [("origin", json!(origin)), ("parser_id", json!(parser_id))],
                )
            })?;
        if !entry.allowed_top_rules.iter().any(|rule| rule == top_rule) {
            return Err(ProgressiveDispatchError::new(
                "progressive_top_rule_forbidden",
                [
                    ("origin", json!(origin)),
                    ("parser_id", json!(parser_id)),
                    ("top_rule", json!(top_rule)),
                ],
            ));
        }
        let effective = effective_authority(&entry, &arguments, origin)?;
        self.check_chain(parser_id, top_rule, &span, origin)?;
        self.check_safe_point(
            &arguments.child_token,
            parser_id,
            arguments.cost,
            effective.max_steps,
            origin,
        )?;

        self.total_calls += 1;
        self.remaining_steps -= arguments.cost;
        let context = SourceLocationContext::new("progressive_parent", origin);
        let start = self
            .source_authority
            .position(&span.source_id, span.start, &context)
            .expect("validated progressive start");
        let end = self
            .source_authority
            .position(&span.source_id, span.end, &context)
            .expect("validated progressive end");
        let typed_span = self
            .source_authority
            .direct_span(&start, &end, &span.provenance, &context)
            .expect("validated progressive span");
        let text = self
            .source_authority
            .materialize(&typed_span, &context)
            .expect("validated progressive source materialization");
        let source_view = ProgressiveSourceView {
            state: Arc::new(ProgressiveSourceViewState {
                active: AtomicBool::new(true),
                authority: Arc::clone(&self.source_authority),
                source_id: span.source_id.clone().into_boxed_str(),
                text: text.into_boxed_str(),
                start: span.start,
                end: span.end,
                provenance: span.provenance.clone().into_boxed_str(),
                origin: origin.to_owned().into_boxed_str(),
                diagnostic_ceiling: effective.max_diagnostic_bytes,
            }),
        };
        self.active_chain.push(ProgressiveChainFrame {
            parser_id: parser_id.to_owned().into_boxed_str(),
            top_rule: top_rule.to_owned().into_boxed_str(),
            source_id: span.source_id.clone().into_boxed_str(),
            start: span.start,
            end: span.end,
        });
        let child_remaining = self
            .remaining_steps
            .min(effective.max_steps.saturating_sub(arguments.cost));
        let request = ProgressiveDispatchRequest {
            parser_id: entry.parser_id.clone(),
            top_rule: top_rule.to_owned().into_boxed_str(),
            fingerprint: entry.fingerprint.clone(),
            source_view: source_view.clone(),
            effective: effective.clone(),
            cancellation_token: self.cancellation_token.clone(),
            deadline_tick: self.deadline_tick,
            remaining_steps: child_remaining,
        };
        let callback = Arc::clone(&entry.compiled_authority);
        let child = catch_unwind(AssertUnwindSafe(|| callback(&request, self)));
        self.active_chain.pop();
        source_view.invalidate();

        let child_result = match child {
            Ok(Ok(value)) if !value.is_null() => value,
            Ok(Ok(_)) => {
                return Err(progressive_child_failed(
                    origin,
                    parser_id,
                    top_rule,
                    &span,
                    "<null child result>",
                    effective.max_diagnostic_bytes,
                ));
            }
            Ok(Err(error)) => {
                return Err(progressive_child_failed(
                    origin,
                    parser_id,
                    top_rule,
                    &span,
                    &error,
                    effective.max_diagnostic_bytes,
                ));
            }
            Err(payload) => {
                let message = payload
                    .downcast_ref::<&str>()
                    .copied()
                    .or_else(|| payload.downcast_ref::<String>().map(String::as_str))
                    .unwrap_or("<child panic>");
                return Err(progressive_child_failed(
                    origin,
                    parser_id,
                    top_rule,
                    &span,
                    message,
                    effective.max_diagnostic_bytes,
                ));
            }
        };
        self.check_cancel_deadline(parser_id, origin)?;
        let mut nodes = 0;
        detach_result(
            child_result,
            parser_id,
            origin,
            "<result>",
            &mut nodes,
            effective.max_result_nodes,
        )
    }

    /// Return the shared remaining step budget.
    pub const fn remaining_steps(&self) -> u64 {
        self.remaining_steps
    }

    /// Return the shared total progressive call count.
    pub const fn total_calls(&self) -> u64 {
        self.total_calls
    }

    fn check_safe_point(
        &self,
        child_token: &ProgressiveCancellationToken,
        parser_id: &str,
        cost: u64,
        effective_max_steps: u64,
        origin: &str,
    ) -> Result<(), ProgressiveDispatchError> {
        if !self.cancellation_token.same_authority(child_token) {
            return Err(ProgressiveDispatchError::new(
                "progressive_cancellation_authority_mismatch",
                [("origin", json!(origin)), ("parser_id", json!(parser_id))],
            ));
        }
        self.check_cancel_deadline(parser_id, origin)?;
        if self.remaining_steps == 0 || cost > self.remaining_steps || cost > effective_max_steps {
            return Err(ProgressiveDispatchError::new(
                "progressive_budget_exhausted",
                [
                    ("origin", json!(origin)),
                    ("parser_id", json!(parser_id)),
                    (
                        "remaining",
                        json!(self.remaining_steps.min(effective_max_steps)),
                    ),
                ],
            ));
        }
        Ok(())
    }

    fn check_cancel_deadline(
        &self,
        parser_id: &str,
        origin: &str,
    ) -> Result<(), ProgressiveDispatchError> {
        if self.cancellation_token.is_cancelled() {
            return Err(ProgressiveDispatchError::new(
                "progressive_cancelled",
                [("origin", json!(origin)), ("parser_id", json!(parser_id))],
            ));
        }
        if self.clock.now() >= self.deadline_tick {
            return Err(ProgressiveDispatchError::new(
                "progressive_deadline_exceeded",
                [
                    ("origin", json!(origin)),
                    ("parser_id", json!(parser_id)),
                    ("deadline", json!(self.deadline_tick)),
                ],
            ));
        }
        Ok(())
    }

    fn check_chain(
        &self,
        parser_id: &str,
        top_rule: &str,
        span: &NeutralSpan,
        origin: &str,
    ) -> Result<(), ProgressiveDispatchError> {
        if self.active_chain.len() >= self.max_depth {
            return Err(ProgressiveDispatchError::new(
                "progressive_depth_exceeded",
                [
                    ("origin", json!(origin)),
                    ("depth", json!(self.active_chain.len())),
                    ("maximum", json!(self.max_depth)),
                ],
            ));
        }
        if self.total_calls >= self.max_calls {
            return Err(ProgressiveDispatchError::new(
                "progressive_call_limit_exceeded",
                [
                    ("origin", json!(origin)),
                    ("calls", json!(self.total_calls)),
                    ("maximum", json!(self.max_calls)),
                ],
            ));
        }
        for active in &self.active_chain {
            if active.parser_id.as_ref() != parser_id
                || active.top_rule.as_ref() != top_rule
                || active.source_id.as_ref() != span.source_id
            {
                continue;
            }
            let contained =
                active.start <= span.start && span.start <= span.end && span.end <= active.end;
            let smaller = span.end - span.start < active.end - active.start;
            if contained && smaller {
                continue;
            }
            return Err(ProgressiveDispatchError::new(
                "progressive_cycle_non_decreasing",
                [
                    ("origin", json!(origin)),
                    ("parser_id", json!(parser_id)),
                    ("top_rule", json!(top_rule)),
                    ("source_id", json!(span.source_id)),
                    ("span", json!(format!("{}:{}", span.start, span.end))),
                    (
                        "active_span",
                        json!(format!("{}:{}", active.start, active.end)),
                    ),
                ],
            ));
        }
        Ok(())
    }
}

/// Portable progressive-dispatch diagnostic.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ProgressiveDispatchError {
    record: Value,
}

impl ProgressiveDispatchError {
    fn new<const N: usize>(code: &'static str, fields: [(&'static str, Value); N]) -> Self {
        let mut record = Map::new();
        record.insert("code".to_owned(), json!(code));
        for (name, value) in fields {
            record.insert(name.to_owned(), value);
        }
        Self {
            record: Value::Object(record),
        }
    }

    /// Return the portable diagnostic code.
    pub fn code(&self) -> &str {
        self.record["code"]
            .as_str()
            .unwrap_or("progressive_internal_error")
    }

    /// Return a detached machine-readable diagnostic record.
    pub fn as_record(&self) -> Value {
        self.record.clone()
    }
}

impl fmt::Display for ProgressiveDispatchError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            formatter,
            "LINKEDSPEC_PROGRESSIVE_SPAN_DISPATCH_ERROR:{}",
            self.code()
        )
    }
}

impl std::error::Error for ProgressiveDispatchError {}

/// Invalid host-side authority construction.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ProgressiveConfigurationError {
    message: String,
}

impl ProgressiveConfigurationError {
    fn new(message: impl Into<String>) -> Self {
        Self {
            message: message.into(),
        }
    }
}

impl fmt::Display for ProgressiveConfigurationError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            formatter,
            "progressive authority configuration: {}",
            self.message
        )
    }
}

impl std::error::Error for ProgressiveConfigurationError {}

#[derive(Clone)]
struct NeutralSpan {
    source_id: String,
    start: u64,
    end: u64,
    provenance: String,
}

fn parse_span(value: &Value, origin: &str) -> Result<NeutralSpan, ProgressiveDispatchError> {
    let Some(object) = value.as_object() else {
        return Err(ProgressiveDispatchError::new(
            "progressive_span_binding_required",
            [
                ("origin", json!(origin)),
                ("operand", diagnostic_operand(value)),
            ],
        ));
    };
    let expected = ["end", "provenance", "source_id", "start"];
    let fields = object.keys().map(String::as_str).collect::<Vec<_>>();
    let values = (
        object.get("source_id").and_then(Value::as_str),
        object.get("start").and_then(Value::as_u64),
        object.get("end").and_then(Value::as_u64),
        object.get("provenance").and_then(Value::as_str),
    );
    let (Some(source_id), Some(start), Some(end), Some(provenance)) = values else {
        return Err(ProgressiveDispatchError::new(
            "progressive_span_shape_invalid",
            [
                ("origin", json!(origin)),
                ("fields", json!(fields.join(","))),
            ],
        ));
    };
    if fields != expected || source_id.is_empty() || provenance.is_empty() {
        return Err(ProgressiveDispatchError::new(
            "progressive_span_shape_invalid",
            [
                ("origin", json!(origin)),
                ("fields", json!(fields.join(","))),
            ],
        ));
    }
    Ok(NeutralSpan {
        source_id: source_id.to_owned(),
        start,
        end,
        provenance: provenance.to_owned(),
    })
}

fn effective_authority(
    entry: &ProgressiveRegistryEntry,
    arguments: &ProgressiveDispatchArguments,
    origin: &str,
) -> Result<ProgressiveEffectiveAuthority, ProgressiveDispatchError> {
    let caller = arguments
        .caller_capabilities
        .iter()
        .map(String::as_str)
        .collect::<BTreeSet<_>>();
    let entry_capabilities = entry
        .capabilities
        .iter()
        .map(String::as_str)
        .collect::<BTreeSet<_>>();
    let capabilities = caller
        .intersection(&entry_capabilities)
        .map(|value| (*value).to_owned())
        .collect::<Vec<_>>();
    let effective_capabilities = capabilities
        .iter()
        .map(String::as_str)
        .collect::<BTreeSet<_>>();
    for required in &arguments.required_capabilities {
        if !effective_capabilities.contains(required.as_str()) {
            return Err(ProgressiveDispatchError::new(
                "progressive_capability_denied",
                [
                    ("origin", json!(origin)),
                    ("parser_id", json!(entry.parser_id.as_ref())),
                    ("capability", json!(required)),
                ],
            ));
        }
    }
    let entry_policy = entry
        .ceilings
        .policy_modes
        .iter()
        .map(String::as_str)
        .collect::<BTreeSet<_>>();
    let policy_modes = arguments
        .caller_ceilings
        .policy_modes
        .iter()
        .filter(|mode| entry_policy.contains(mode.as_str()))
        .cloned()
        .collect::<Vec<_>>();
    if policy_modes.is_empty() {
        return Err(ProgressiveDispatchError::new(
            "progressive_policy_denied",
            [
                ("origin", json!(origin)),
                ("parser_id", json!(entry.parser_id.as_ref())),
                (
                    "policy",
                    json!(arguments.caller_ceilings.policy_modes.join(",")),
                ),
            ],
        ));
    }
    let source_detail = arguments
        .caller_ceilings
        .source_detail
        .min(entry.ceilings.source_detail);
    if source_detail < arguments.required_source_detail {
        return Err(ProgressiveDispatchError::new(
            "progressive_source_detail_denied",
            [
                ("origin", json!(origin)),
                ("required", json!(arguments.required_source_detail.as_str())),
                ("effective", json!(source_detail.as_str())),
            ],
        ));
    }
    Ok(ProgressiveEffectiveAuthority {
        capabilities: capabilities.into_boxed_slice(),
        source_detail,
        policy_modes: policy_modes.into_boxed_slice(),
        max_steps: arguments
            .caller_ceilings
            .max_steps
            .min(entry.ceilings.max_steps),
        max_result_nodes: arguments
            .caller_ceilings
            .max_result_nodes
            .min(entry.ceilings.max_result_nodes),
        max_diagnostic_bytes: arguments
            .caller_ceilings
            .max_diagnostic_bytes
            .min(entry.ceilings.max_diagnostic_bytes),
    })
}

fn detach_result(
    value: Value,
    parser_id: &str,
    origin: &str,
    path: &str,
    nodes: &mut u64,
    maximum: u64,
) -> Result<Value, ProgressiveDispatchError> {
    *nodes += 1;
    if *nodes > maximum {
        return Err(result_not_detached(origin, parser_id, path));
    }
    match value {
        Value::Array(values) => values
            .into_iter()
            .enumerate()
            .map(|(index, value)| {
                detach_result(
                    value,
                    parser_id,
                    origin,
                    &format!("{path}/{index}"),
                    nodes,
                    maximum,
                )
            })
            .collect::<Result<Vec<_>, _>>()
            .map(Value::Array),
        Value::Object(values) => {
            let mut copy = Map::new();
            for (key, value) in values {
                let lower = key.to_ascii_lowercase();
                if LIVE_RESULT_FIELD_TOKENS
                    .iter()
                    .any(|token| lower.contains(token))
                {
                    return Err(result_not_detached(
                        origin,
                        parser_id,
                        &format!("{path}/{key}"),
                    ));
                }
                copy.insert(
                    key.clone(),
                    detach_result(
                        value,
                        parser_id,
                        origin,
                        &format!("{path}/{key}"),
                        nodes,
                        maximum,
                    )?,
                );
            }
            Ok(Value::Object(copy))
        }
        scalar => Ok(scalar),
    }
}

fn literal_string<'value>(
    value: &'value Value,
    origin: &str,
    code: &'static str,
) -> Result<&'value str, ProgressiveDispatchError> {
    value
        .as_str()
        .filter(|value| !value.is_empty())
        .ok_or_else(|| {
            ProgressiveDispatchError::new(
                code,
                [
                    ("origin", json!(origin)),
                    ("operand", diagnostic_operand(value)),
                ],
            )
        })
}

fn diagnostic_operand(value: &Value) -> Value {
    match value {
        Value::Null => json!("<missing>"),
        Value::String(value) => json!(value),
        Value::Bool(value) => json!(value.to_string()),
        Value::Number(value) => json!(value.to_string()),
        Value::Array(_) | Value::Object(_) => json!("<aggregate>"),
    }
}

fn progressive_source_mismatch(
    origin: &str,
    expected: &str,
    actual: &str,
) -> ProgressiveDispatchError {
    ProgressiveDispatchError::new(
        "progressive_span_source_mismatch",
        [
            ("origin", json!(origin)),
            ("expected_source_id", json!(expected)),
            ("actual_source_id", json!(actual)),
        ],
    )
}

fn progressive_out_of_bounds(
    origin: &str,
    source_id: &str,
    start: u64,
    end: u64,
    source_length: u64,
) -> ProgressiveDispatchError {
    ProgressiveDispatchError::new(
        "progressive_span_out_of_bounds",
        [
            ("origin", json!(origin)),
            ("source_id", json!(source_id)),
            ("start", json!(start)),
            ("end", json!(end)),
            ("source_length", json!(source_length)),
        ],
    )
}

fn progressive_reversed_span(
    origin: &str,
    source_id: &str,
    start: u64,
    end: u64,
) -> ProgressiveDispatchError {
    ProgressiveDispatchError::new(
        "progressive_span_reversed",
        [
            ("origin", json!(origin)),
            ("source_id", json!(source_id)),
            ("start", json!(start)),
            ("end", json!(end)),
        ],
    )
}

fn progressive_child_failed(
    origin: &str,
    parser_id: &str,
    top_rule: &str,
    span: &NeutralSpan,
    diagnostic: &str,
    byte_ceiling: u64,
) -> ProgressiveDispatchError {
    let mut diagnostic = truncate_utf8_bytes(diagnostic, byte_ceiling);
    if diagnostic.is_empty() {
        diagnostic = "?".to_owned();
    }
    ProgressiveDispatchError::new(
        "progressive_child_failed",
        [
            ("origin", json!(origin)),
            ("parser_id", json!(parser_id)),
            ("top_rule", json!(top_rule)),
            ("source_id", json!(span.source_id)),
            ("span", json!(format!("{}:{}", span.start, span.end))),
            ("child_diagnostic", json!(diagnostic)),
        ],
    )
}

fn truncate_utf8_bytes(value: &str, maximum: u64) -> String {
    let maximum = usize::try_from(maximum).unwrap_or(usize::MAX);
    if value.len() <= maximum {
        return value.to_owned();
    }
    let boundary = value
        .char_indices()
        .map(|(index, character)| index + character.len_utf8())
        .take_while(|end| *end <= maximum)
        .last()
        .unwrap_or(0);
    value[..boundary].to_owned()
}

fn result_not_detached(origin: &str, parser_id: &str, field: &str) -> ProgressiveDispatchError {
    ProgressiveDispatchError::new(
        "progressive_result_not_detached",
        [
            ("origin", json!(origin)),
            ("parser_id", json!(parser_id)),
            ("field", json!(field)),
        ],
    )
}

fn validated_nonempty_strings(
    values: Vec<String>,
    context: &str,
) -> Result<Box<[String]>, ProgressiveConfigurationError> {
    if values.is_empty() || values.iter().any(String::is_empty) {
        return Err(ProgressiveConfigurationError::new(format!(
            "{context} must be nonempty strings"
        )));
    }
    let unique = values.iter().collect::<BTreeSet<_>>();
    if unique.len() != values.len() {
        return Err(ProgressiveConfigurationError::new(format!(
            "{context} must be duplicate-free"
        )));
    }
    Ok(values.into_boxed_slice())
}

fn valid_parser_id(value: &str) -> bool {
    let mut characters = value.chars();
    if !characters
        .next()
        .is_some_and(|value| value.is_ascii_lowercase())
    {
        return false;
    }
    let mut after_separator = false;
    for character in characters {
        if matches!(character, '.' | '_' | ':' | '-') {
            if after_separator {
                return false;
            }
            after_separator = true;
        } else if character.is_ascii_lowercase() || character.is_ascii_digit() {
            after_separator = false;
        } else {
            return false;
        }
    }
    !after_separator
}

fn valid_top_rule(value: &str) -> bool {
    let mut characters = value.chars();
    if !characters
        .next()
        .is_some_and(|value| value == '_' || value.is_ascii_alphabetic())
    {
        return false;
    }
    characters.all(|value| value == '_' || value.is_ascii_alphanumeric())
}

fn valid_fingerprint(value: &str) -> bool {
    value.strip_prefix("sha256:").is_some_and(|digest| {
        digest.len() == 64
            && digest
                .bytes()
                .all(|byte| byte.is_ascii_hexdigit() && !byte.is_ascii_uppercase())
    })
}

fn offset_field(key: &str) -> bool {
    matches!(key, "offset" | "start" | "end")
        || key.ends_with("_offset")
        || key.ends_with("_start")
        || key.ends_with("_end")
}
