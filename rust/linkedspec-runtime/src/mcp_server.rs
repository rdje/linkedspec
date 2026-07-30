//! In-process Rust MCP adapter over caller-owned immutable semantic indexes.

use crate::mcp_contract_runtime;
use crate::mcp_wire;
use crate::semantic_index::{SemanticIndex, SemanticSourceDetail};
use serde_json::{Value, json};
use sha2::{Digest, Sha256};
use std::collections::BTreeMap;
use std::io::{Read, Write};
use std::panic::{AssertUnwindSafe, catch_unwind};
use std::sync::Arc;
use std::time::Instant;
use thiserror::Error;

const AUTHORIZATION_MAXIMUM_BYTES: usize = 4_096;
const ENTROPY_BYTES: usize = 32;
const HANDLE_CHARACTERS: usize = 43;
const HANDLE_ATTEMPTS: usize = 16;
const DUMMY_AUTH_DIGEST: [u8; 32] = [0; 32];

/// Optional lower-only semantic query budgets for one registered handle.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct McpBudgetLimits {
    /// Maximum semantic records that one query may examine or return.
    pub max_records: u64,
    /// Maximum semantic relations that one query may examine or return.
    pub max_relations: u64,
    /// Maximum semantic traversal depth.
    pub max_depth: u64,
}

/// Optional deployment ceilings applied below one index's native capabilities.
#[derive(Debug, Clone, PartialEq, Eq, Default)]
pub struct McpDeploymentPolicy {
    /// Optional source-detail ceiling no higher than the registered index ceiling.
    pub source_detail_ceiling: Option<SemanticSourceDetail>,
    /// Optional positive page ceiling no higher than the registered index ceiling.
    pub page_max: Option<u64>,
    /// Optional component-wise budget ceilings no higher than the native maxima.
    pub budget_maxima: Option<McpBudgetLimits>,
}

/// Registration policy for one caller-owned semantic index.
#[derive(Debug, Clone, PartialEq, Eq, Default)]
pub struct McpRegistrationOptions {
    /// Optional absolute lifetime in monotonic milliseconds after registration.
    pub lifetime_ms: Option<u64>,
    /// Optional lowering-only deployment policy.
    pub policy: Option<McpDeploymentPolicy>,
}

/// Sanitized typed host-API failure; protocol failures are returned as JSON-RPC values.
#[derive(Debug, Clone, PartialEq, Eq, Error)]
#[error("{code}: {message}")]
pub struct McpServerError {
    /// Stable machine-readable host-API error code.
    pub code: &'static str,
    /// Fixed sanitized error message containing no host data.
    pub message: &'static str,
}

impl McpServerError {
    pub(crate) const fn new(code: &'static str, message: &'static str) -> Self {
        Self { code, message }
    }
}

#[derive(Clone)]
struct NativeLimits {
    source_detail_ceiling: SemanticSourceDetail,
    content_digest_available: bool,
    page_default: u64,
    page_max: u64,
    budget_defaults: McpBudgetLimits,
    budget_maxima: McpBudgetLimits,
}

#[derive(Clone)]
struct EffectivePolicy {
    limits: NativeLimits,
    project: bool,
    explicit: ExplicitPolicy,
}

#[derive(Clone, Copy, Default)]
struct ExplicitPolicy {
    source_detail: bool,
    content_digest: bool,
    page: bool,
    budget: bool,
}

struct RegistryEntry {
    index: Arc<SemanticIndex>,
    authorization_digest: [u8; 32],
    expires_ms: u64,
    policy: EffectivePolicy,
}

#[derive(Default)]
struct ActiveRequest {
    cancelled: bool,
    prepared: bool,
}

enum EntropySource {
    OperatingSystem,
    #[cfg(test)]
    Injected(Box<dyn FnMut() -> Result<[u8; ENTROPY_BYTES], ()>>),
}

enum ClockSource {
    Monotonic(Instant),
    #[cfg(test)]
    Injected(Box<dyn FnMut() -> Result<u64, ()>>),
}

/// Native Rust MCP server for caller-registered immutable semantic indexes.
pub struct McpServer {
    entries: BTreeMap<String, RegistryEntry>,
    active: BTreeMap<String, ActiveRequest>,
    stopped: bool,
    entropy: EntropySource,
    clock: ClockSource,
    maximum_handles: usize,
    handle_attempts: usize,
    default_lifetime_ms: u64,
    maximum_lifetime_ms: u64,
    #[cfg(test)]
    native_query_dispatches: usize,
}

impl McpServer {
    /// Construct a production server using operating-system entropy and monotonic time.
    pub fn new() -> Result<Self, McpServerError> {
        let contract = mcp_contract_runtime::contract().map_err(|_| contract_failure())?;
        let registry = contract
            .get("handle_registry")
            .and_then(Value::as_object)
            .ok_or_else(contract_failure)?;
        let maximum_handles = registry
            .get("default_maximum_live_handles")
            .and_then(Value::as_u64)
            .and_then(|value| usize::try_from(value).ok())
            .filter(|value| *value > 0)
            .ok_or_else(contract_failure)?;
        let default_lifetime_ms = registry
            .get("default_lifetime_ms")
            .and_then(Value::as_u64)
            .filter(|value| *value > 0)
            .ok_or_else(contract_failure)?;
        let maximum_lifetime_ms = registry
            .get("maximum_lifetime_ms")
            .and_then(Value::as_u64)
            .filter(|value| *value >= default_lifetime_ms)
            .ok_or_else(contract_failure)?;
        Ok(Self {
            entries: BTreeMap::new(),
            active: BTreeMap::new(),
            stopped: false,
            entropy: EntropySource::OperatingSystem,
            clock: ClockSource::Monotonic(Instant::now()),
            maximum_handles,
            handle_attempts: HANDLE_ATTEMPTS,
            default_lifetime_ms,
            maximum_lifetime_ms,
            #[cfg(test)]
            native_query_dispatches: 0,
        })
    }

    /// Register one existing native index and return a fresh opaque handle.
    pub fn register_index(
        &mut self,
        index: Arc<SemanticIndex>,
        authorization_context: &[u8],
        options: McpRegistrationOptions,
    ) -> Result<String, McpServerError> {
        if self.stopped {
            return Err(server_shutdown());
        }
        validate_authorization(authorization_context)?;
        let lifetime_ms = options.lifetime_ms.unwrap_or(self.default_lifetime_ms);
        if lifetime_ms == 0 || lifetime_ms > self.maximum_lifetime_ms {
            return Err(McpServerError::new(
                "linkedspec_mcp_invalid_registration",
                "Registration lifetime is outside the contract bounds.",
            ));
        }
        let now = self.now_ms()?;
        self.entries.retain(|_, entry| now < entry.expires_ms);
        if self.entries.len() >= self.maximum_handles {
            return Err(McpServerError::new(
                "linkedspec_mcp_registry_full",
                "The MCP handle registry is at capacity.",
            ));
        }
        let capabilities = catch_unwind(AssertUnwindSafe(|| index.capabilities()))
            .map_err(|_| invalid_index())
            .and_then(|response| serde_json::to_value(response).map_err(|_| invalid_index()))?;
        if !mcp_contract_runtime::validate_named("semanticQueryResponse", &capabilities) {
            return Err(invalid_index());
        }
        let native = native_limits(&capabilities)?;
        let policy = effective_policy(options.policy.as_ref(), &native)?;
        let expires_ms = now.checked_add(lifetime_ms).ok_or_else(clock_failure)?;
        let handle = self.unique_handle()?;
        self.entries.insert(
            handle.clone(),
            RegistryEntry {
                index,
                authorization_digest: authorization_digest(authorization_context),
                expires_ms,
                policy,
            },
        );
        Ok(handle)
    }

    /// Revoke a syntactically valid handle without disclosing its prior state.
    pub fn revoke_handle(&mut self, handle: &str) -> Result<(), McpServerError> {
        if !valid_handle(handle) {
            return Err(McpServerError::new(
                "linkedspec_mcp_invalid_handle",
                "MCP handle syntax is invalid.",
            ));
        }
        self.entries.remove(handle);
        Ok(())
    }

    /// Dispatch one already-decoded JSON request.
    ///
    /// Notifications return `Ok(None)`; requests return one JSON-RPC response.
    pub fn dispatch(
        &mut self,
        request: &Value,
        authorization_context: &[u8],
    ) -> Result<Option<Value>, McpServerError> {
        self.dispatch_with_preparation(request, authorization_context, false)
    }

    /// Run the strict modern MCP JSON-line protocol over borrowed caller streams.
    ///
    /// Normal operation is silent except for canonical protocol frames on
    /// `output`. When supplied, `log` receives only a fixed sanitized record on
    /// an unexpected read, write, or flush failure. EOF and every I/O failure
    /// shut the server down and release all registered indexes.
    pub fn serve_stdio<R: Read + ?Sized, W: Write + ?Sized>(
        &mut self,
        input: &mut R,
        output: &mut W,
        authorization_context: &[u8],
        log: Option<&mut dyn Write>,
    ) -> Result<(), McpServerError> {
        if self.stopped {
            return Err(server_shutdown());
        }
        validate_authorization(authorization_context)?;
        mcp_wire::serve(self, input, output, authorization_context, log)
    }

    pub(crate) fn dispatch_for_wire(
        &mut self,
        request: &Value,
        authorization_context: &[u8],
    ) -> Result<(Option<Value>, Option<String>), McpServerError> {
        let candidate = request
            .get("id")
            .filter(|value| valid_request_id(value))
            .and_then(|id| mcp_contract_runtime::canonical_json(id).ok());
        let was_active = candidate
            .as_ref()
            .is_some_and(|key| self.active.contains_key(key));
        let response = self.dispatch_with_preparation(request, authorization_context, true)?;
        let prepared = candidate.filter(|key| {
            !was_active && self.active.get(key).is_some_and(|active| active.prepared)
        });
        Ok((response, prepared))
    }

    pub(crate) fn wire_response_ready(&mut self, key: Option<&str>) -> bool {
        let Some(key) = key else {
            return true;
        };
        let Some(active) = self.active.get(key) else {
            return false;
        };
        if !active.prepared {
            return false;
        }
        if active.cancelled {
            self.active.remove(key);
            return false;
        }
        true
    }

    pub(crate) fn wire_response_emitted(&mut self, key: Option<&str>) {
        if let Some(key) = key {
            self.active.remove(key);
        }
    }

    fn dispatch_with_preparation(
        &mut self,
        request: &Value,
        authorization_context: &[u8],
        retain_prepared: bool,
    ) -> Result<Option<Value>, McpServerError> {
        validate_authorization(authorization_context)?;
        let request = request.clone();
        let id = request
            .get("id")
            .filter(|value| valid_request_id(value))
            .cloned();
        if self.stopped {
            return Ok(Some(protocol_error(id.as_ref(), "internal_error", None)));
        }
        let Some(object) = request.as_object() else {
            return Ok(Some(protocol_error(None, "invalid_request", None)));
        };
        if object.get("jsonrpc").and_then(Value::as_str) != Some("2.0")
            || object.get("method").and_then(Value::as_str).is_none()
        {
            return Ok(Some(protocol_error(None, "invalid_request", None)));
        }
        let method = object["method"].as_str().expect("checked above");
        if !object.contains_key("id") {
            if method == "notifications/cancelled"
                && mcp_contract_runtime::validate_named("cancelledNotification", &request)
                && let Some(request_id) = request.pointer("/params/requestId")
                && let Ok(key) = mcp_contract_runtime::canonical_json(request_id)
                && let Some(active) = self.active.get_mut(&key)
            {
                active.cancelled = true;
            }
            return Ok(None);
        }
        let Some(id) = id else {
            return Ok(Some(protocol_error(None, "invalid_request", None)));
        };
        if method == "initialize" {
            return Ok(Some(protocol_error(Some(&id), "legacy_initialize", None)));
        }
        if method == "notifications/cancelled" {
            return Ok(Some(protocol_error(Some(&id), "invalid_request", None)));
        }
        if !matches!(method, "server/discover" | "tools/list" | "tools/call") {
            return Ok(Some(protocol_error(Some(&id), "method_not_found", None)));
        }
        if let Some(version) = requested_protocol(&request)
            && version != mcp_contract_runtime::protocol_version().unwrap_or_default()
        {
            return Ok(Some(protocol_error(
                Some(&id),
                "unsupported_version",
                Some(version),
            )));
        }
        match method {
            "server/discover" => {
                if !mcp_contract_runtime::validate_named("discoverRequest", &request) {
                    return Ok(Some(protocol_error(Some(&id), "invalid_params", None)));
                }
                Ok(self.prepare_response(&id, retain_prepared, |_, id| {
                    mcp_contract_runtime::discover_response(id).map_err(|_| ())
                }))
            }
            "tools/list" => {
                if !mcp_contract_runtime::validate_named("toolsListRequest", &request) {
                    return Ok(Some(protocol_error(Some(&id), "invalid_params", None)));
                }
                Ok(self.prepare_response(&id, retain_prepared, |_, id| {
                    mcp_contract_runtime::tools_list_response(id).map_err(|_| ())
                }))
            }
            "tools/call" => {
                self.dispatch_tool_call(&request, &id, authorization_context, retain_prepared)
            }
            _ => unreachable!("method inventory checked above"),
        }
    }

    /// Idempotently clear all registered indexes and active request state.
    pub fn shutdown(&mut self) {
        self.stopped = true;
        self.entries.clear();
        self.active.clear();
    }

    fn dispatch_tool_call(
        &mut self,
        request: &Value,
        id: &Value,
        authorization_context: &[u8],
        retain_prepared: bool,
    ) -> Result<Option<Value>, McpServerError> {
        let name = request.pointer("/params/name").and_then(Value::as_str);
        let (definition, operation) = match name {
            Some("linkedspec_semantic_capabilities") => {
                ("capabilitiesCallRequest", ToolOperation::Capabilities)
            }
            Some("linkedspec_semantic_query") => ("semanticQueryCallRequest", ToolOperation::Query),
            _ => {
                return Ok(Some(protocol_error(Some(id), "invalid_params", None)));
            }
        };
        if !mcp_contract_runtime::validate_named(definition, request) {
            return Ok(Some(protocol_error(Some(id), "invalid_params", None)));
        }
        let authorization_digest = authorization_digest(authorization_context);
        let request = request.clone();
        Ok(
            self.prepare_response(id, retain_prepared, move |server, id| {
                server.build_tool_response(&request, id, operation, authorization_digest)
            }),
        )
    }

    fn build_tool_response(
        &mut self,
        request: &Value,
        id: &Value,
        operation: ToolOperation,
        authorization_digest: [u8; 32],
    ) -> Result<Value, ()> {
        let handle = request
            .pointer("/params/arguments/handle")
            .and_then(Value::as_str)
            .ok_or(())?;
        let Some((index, policy)) = self
            .authorized_entry(handle, authorization_digest)
            .map_err(|_| ())?
        else {
            return mcp_contract_runtime::tool_error_response(id, true).map_err(|_| ());
        };
        if operation == ToolOperation::Query {
            let query = request.pointer("/params/arguments/request").ok_or(())?;
            if !request_within_policy(query, &policy) {
                return mcp_contract_runtime::tool_error_response(id, false).map_err(|_| ());
            }
        }
        let payload = match operation {
            ToolOperation::Capabilities => {
                let response = index.capabilities();
                let response = serde_json::to_value(response).map_err(|_| ())?;
                project_capabilities(response, &policy).map_err(|_| ())?
            }
            ToolOperation::Query => {
                let query = request.pointer("/params/arguments/request").ok_or(())?;
                #[cfg(test)]
                {
                    self.native_query_dispatches += 1;
                }
                serde_json::to_value(index.query_neutral(query)).map_err(|_| ())?
            }
        };
        mcp_contract_runtime::tool_success_response(id, &payload).map_err(|_| ())
    }

    fn prepare_response<F>(
        &mut self,
        id: &Value,
        retain_prepared: bool,
        builder: F,
    ) -> Option<Value>
    where
        F: FnOnce(&mut Self, &Value) -> Result<Value, ()>,
    {
        let Ok(key) = mcp_contract_runtime::canonical_json(id) else {
            return Some(protocol_error(Some(id), "internal_error", None));
        };
        if self.active.contains_key(&key) {
            return Some(protocol_error(Some(id), "internal_error", None));
        }
        self.active.insert(key.clone(), ActiveRequest::default());
        let built = catch_unwind(AssertUnwindSafe(|| builder(self, id)));
        let cancelled = self.active.get(&key).is_some_and(|active| active.cancelled);
        if cancelled {
            self.active.remove(&key);
            return None;
        }
        let response = match built {
            Ok(Ok(response)) => Some(response),
            Ok(Err(())) | Err(_) => Some(protocol_error(Some(id), "internal_error", None)),
        };
        if retain_prepared {
            if let Some(active) = self.active.get_mut(&key) {
                active.prepared = true;
            }
        } else {
            self.active.remove(&key);
        }
        response
    }

    fn authorized_entry(
        &mut self,
        handle: &str,
        authorization_digest: [u8; 32],
    ) -> Result<Option<(Arc<SemanticIndex>, EffectivePolicy)>, McpServerError> {
        let expected = self
            .entries
            .get(handle)
            .map_or(DUMMY_AUTH_DIGEST, |entry| entry.authorization_digest);
        let authorized = fixed_digest_equal(&expected, &authorization_digest);
        let now = self.now_ms()?;
        if self
            .entries
            .get(handle)
            .is_some_and(|entry| now >= entry.expires_ms)
        {
            self.entries.remove(handle);
        }
        Ok(self
            .entries
            .get(handle)
            .and_then(|entry| authorized.then(|| (Arc::clone(&entry.index), entry.policy.clone()))))
    }

    fn unique_handle(&mut self) -> Result<String, McpServerError> {
        for _ in 0..self.handle_attempts {
            let bytes = self.entropy_bytes()?;
            let handle = encode_base64url(&bytes);
            if !valid_handle(&handle) {
                return Err(entropy_failure());
            }
            if !self.entries.contains_key(&handle) {
                return Ok(handle);
            }
        }
        Err(McpServerError::new(
            "linkedspec_mcp_entropy_failure",
            "A unique MCP handle could not be generated.",
        ))
    }

    fn entropy_bytes(&mut self) -> Result<[u8; ENTROPY_BYTES], McpServerError> {
        let mut bytes = [0_u8; ENTROPY_BYTES];
        match &mut self.entropy {
            EntropySource::OperatingSystem => {
                getrandom::fill(&mut bytes).map_err(|_| entropy_failure())?
            }
            #[cfg(test)]
            EntropySource::Injected(source) => bytes = source().map_err(|()| entropy_failure())?,
        }
        Ok(bytes)
    }

    fn now_ms(&mut self) -> Result<u64, McpServerError> {
        match &mut self.clock {
            ClockSource::Monotonic(origin) => {
                u64::try_from(origin.elapsed().as_millis()).map_err(|_| clock_failure())
            }
            #[cfg(test)]
            ClockSource::Injected(source) => source().map_err(|()| clock_failure()),
        }
    }

    #[cfg(test)]
    pub(crate) fn new_for_test(
        entropy: impl FnMut() -> Result<[u8; ENTROPY_BYTES], ()> + 'static,
        clock: impl FnMut() -> Result<u64, ()> + 'static,
        maximum_handles: usize,
        handle_attempts: usize,
    ) -> Self {
        assert!((1..=1024).contains(&maximum_handles));
        assert!((1..=HANDLE_ATTEMPTS).contains(&handle_attempts));
        Self {
            entries: BTreeMap::new(),
            active: BTreeMap::new(),
            stopped: false,
            entropy: EntropySource::Injected(Box::new(entropy)),
            clock: ClockSource::Injected(Box::new(clock)),
            maximum_handles,
            handle_attempts,
            default_lifetime_ms: 900_000,
            maximum_lifetime_ms: 86_400_000,
            native_query_dispatches: 0,
        }
    }
}

impl Drop for McpServer {
    fn drop(&mut self) {
        self.entries.clear();
        self.active.clear();
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum ToolOperation {
    Capabilities,
    Query,
}

fn requested_protocol(request: &Value) -> Option<&str> {
    request
        .pointer("/params/_meta/io.modelcontextprotocol~1protocolVersion")
        .and_then(Value::as_str)
}

fn validate_authorization(value: &[u8]) -> Result<(), McpServerError> {
    if value.is_empty() || value.len() > AUTHORIZATION_MAXIMUM_BYTES {
        return Err(McpServerError::new(
            "linkedspec_mcp_invalid_authorization",
            "Authorization context must be 1 through 4096 opaque bytes.",
        ));
    }
    Ok(())
}

fn valid_handle(value: &str) -> bool {
    value.len() == HANDLE_CHARACTERS
        && value
            .bytes()
            .all(|byte| byte.is_ascii_alphanumeric() || matches!(byte, b'_' | b'-'))
}

fn valid_request_id(value: &Value) -> bool {
    mcp_contract_runtime::validate_named("requestId", value)
}

fn authorization_digest(value: &[u8]) -> [u8; 32] {
    Sha256::digest(value).into()
}

fn fixed_digest_equal(left: &[u8; 32], right: &[u8; 32]) -> bool {
    let mut different = 0_u8;
    for index in 0..32 {
        different |= left[index] ^ right[index];
    }
    std::hint::black_box(different) == 0
}

fn encode_base64url(bytes: &[u8; ENTROPY_BYTES]) -> String {
    const ALPHABET: &[u8; 64] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
    let mut output = String::with_capacity(HANDLE_CHARACTERS);
    for chunk in bytes.chunks(3) {
        let first = chunk[0];
        let second = chunk.get(1).copied().unwrap_or(0);
        let third = chunk.get(2).copied().unwrap_or(0);
        output.push(char::from(ALPHABET[usize::from(first >> 2)]));
        output.push(char::from(
            ALPHABET[usize::from(((first & 0x03) << 4) | (second >> 4))],
        ));
        if chunk.len() > 1 {
            output.push(char::from(
                ALPHABET[usize::from(((second & 0x0f) << 2) | (third >> 6))],
            ));
        }
        if chunk.len() > 2 {
            output.push(char::from(ALPHABET[usize::from(third & 0x3f)]));
        }
    }
    output
}

fn native_limits(response: &Value) -> Result<NativeLimits, McpServerError> {
    let records = response
        .get("records")
        .and_then(Value::as_array)
        .ok_or_else(invalid_index)?;
    let mut capabilities = records
        .iter()
        .filter(|record| record.get("kind").and_then(Value::as_str) == Some("capabilities"));
    let record = capabilities.next().ok_or_else(invalid_index)?;
    if capabilities.next().is_some() {
        return Err(invalid_index());
    }
    let facts = record
        .get("facts")
        .and_then(Value::as_object)
        .ok_or_else(invalid_index)?;
    let snapshot = response
        .get("snapshot")
        .and_then(Value::as_object)
        .ok_or_else(invalid_index)?;
    let source_detail_ceiling = source_detail(
        facts
            .get("source_detail_ceiling")
            .and_then(Value::as_str)
            .ok_or_else(invalid_index)?,
    )
    .ok_or_else(invalid_index)?;
    source_detail(
        snapshot
            .get("source_detail_ceiling")
            .and_then(Value::as_str)
            .ok_or_else(invalid_index)?,
    )
    .ok_or_else(invalid_index)?;
    let page_default = positive_integer(facts.get("page_default")).ok_or_else(invalid_index)?;
    let page_max = positive_integer(facts.get("page_max")).ok_or_else(invalid_index)?;
    let budget_defaults = budget_limits(facts.get("budget_defaults")).ok_or_else(invalid_index)?;
    let budget_maxima = budget_limits(facts.get("budget_maxima")).ok_or_else(invalid_index)?;
    if page_default > page_max || !budget_within(&budget_defaults, &budget_maxima) {
        return Err(invalid_index());
    }
    Ok(NativeLimits {
        source_detail_ceiling,
        content_digest_available: snapshot
            .get("content_digest_available")
            .and_then(Value::as_bool)
            .ok_or_else(invalid_index)?,
        page_default,
        page_max,
        budget_defaults,
        budget_maxima,
    })
}

fn effective_policy(
    supplied: Option<&McpDeploymentPolicy>,
    native: &NativeLimits,
) -> Result<EffectivePolicy, McpServerError> {
    let mut limits = native.clone();
    let Some(supplied) = supplied else {
        return Ok(EffectivePolicy {
            limits,
            project: false,
            explicit: ExplicitPolicy::default(),
        });
    };
    let mut explicit = ExplicitPolicy::default();
    if let Some(detail) = supplied.source_detail_ceiling {
        if source_rank(detail) > source_rank(native.source_detail_ceiling) {
            return Err(invalid_policy(
                "MCP source-detail policy is invalid or elevating.",
            ));
        }
        limits.source_detail_ceiling = detail;
        if detail != SemanticSourceDetail::Text {
            limits.content_digest_available = false;
            explicit.content_digest = true;
        }
        explicit.source_detail = true;
    }
    if let Some(page_max) = supplied.page_max {
        if page_max == 0 || page_max > native.page_max {
            return Err(invalid_policy("MCP page policy is invalid or elevating."));
        }
        limits.page_max = page_max;
        limits.page_default = limits.page_default.min(page_max);
        explicit.page = true;
    }
    if let Some(budget) = supplied.budget_maxima {
        if !budget_within(&budget, &native.budget_maxima) {
            return Err(invalid_policy("MCP budget policy is invalid or elevating."));
        }
        limits.budget_maxima = budget;
        limits.budget_defaults = McpBudgetLimits {
            max_records: limits.budget_defaults.max_records.min(budget.max_records),
            max_relations: limits
                .budget_defaults
                .max_relations
                .min(budget.max_relations),
            max_depth: limits.budget_defaults.max_depth.min(budget.max_depth),
        };
        explicit.budget = true;
    }
    Ok(EffectivePolicy {
        limits,
        project: explicit.source_detail || explicit.page || explicit.budget,
        explicit,
    })
}

fn project_capabilities(
    mut response: Value,
    policy: &EffectivePolicy,
) -> Result<Value, McpServerError> {
    if !mcp_contract_runtime::validate_named("semanticQueryResponse", &response) {
        return Err(invalid_index());
    }
    if !policy.project {
        return Ok(response);
    }
    let records = response
        .get_mut("records")
        .and_then(Value::as_array_mut)
        .ok_or_else(invalid_index)?;
    let mut capabilities = records
        .iter_mut()
        .filter(|record| record.get("kind").and_then(Value::as_str) == Some("capabilities"));
    let record = capabilities.next().ok_or_else(invalid_index)?;
    if capabilities.next().is_some() {
        return Err(invalid_index());
    }
    let facts = record
        .get_mut("facts")
        .and_then(Value::as_object_mut)
        .ok_or_else(invalid_index)?;
    facts.insert(
        "source_detail_ceiling".to_string(),
        Value::String(source_detail_name(policy.limits.source_detail_ceiling).to_string()),
    );
    facts.insert("page_max".to_string(), json!(policy.limits.page_max));
    facts.insert(
        "page_default".to_string(),
        json!(policy.limits.page_default),
    );
    facts.insert(
        "budget_maxima".to_string(),
        budget_value(policy.limits.budget_maxima),
    );
    facts.insert(
        "budget_defaults".to_string(),
        budget_value(policy.limits.budget_defaults),
    );
    response["snapshot"]["source_detail_ceiling"] =
        Value::String(source_detail_name(policy.limits.source_detail_ceiling).to_string());
    response["snapshot"]["content_digest_available"] = Value::Bool(
        policy.limits.content_digest_available
            && policy.limits.source_detail_ceiling == SemanticSourceDetail::Text,
    );
    Ok(response)
}

fn request_within_policy(request: &Value, policy: &EffectivePolicy) -> bool {
    let Some(detail) = request
        .pointer("/source/detail")
        .and_then(Value::as_str)
        .and_then(source_detail)
    else {
        return false;
    };
    if policy.explicit.source_detail
        && source_rank(detail) > source_rank(policy.limits.source_detail_ceiling)
    {
        return false;
    }
    if request
        .pointer("/source/include_content_digest")
        .and_then(Value::as_bool)
        .unwrap_or(false)
        && policy.explicit.content_digest
        && (!policy.limits.content_digest_available
            || policy.limits.source_detail_ceiling != SemanticSourceDetail::Text)
    {
        return false;
    }
    if request
        .pointer("/page/limit")
        .and_then(Value::as_u64)
        .is_none_or(|limit| policy.explicit.page && limit > policy.limits.page_max)
    {
        return false;
    }
    let Some(budget) = budget_limits(request.get("budget")) else {
        return false;
    };
    !policy.explicit.budget || budget_within(&budget, &policy.limits.budget_maxima)
}

fn budget_limits(value: Option<&Value>) -> Option<McpBudgetLimits> {
    let value = value?.as_object()?;
    if value.len() != 3 {
        return None;
    }
    Some(McpBudgetLimits {
        max_records: value.get("max_records")?.as_u64()?,
        max_relations: value.get("max_relations")?.as_u64()?,
        max_depth: value.get("max_depth")?.as_u64()?,
    })
}

const fn budget_within(value: &McpBudgetLimits, maximum: &McpBudgetLimits) -> bool {
    value.max_records <= maximum.max_records
        && value.max_relations <= maximum.max_relations
        && value.max_depth <= maximum.max_depth
}

fn budget_value(value: McpBudgetLimits) -> Value {
    json!({
        "max_records": value.max_records,
        "max_relations": value.max_relations,
        "max_depth": value.max_depth,
    })
}

fn positive_integer(value: Option<&Value>) -> Option<u64> {
    value?.as_u64().filter(|value| *value > 0)
}

const fn source_detail(value: &str) -> Option<SemanticSourceDetail> {
    match value.as_bytes() {
        b"none" => Some(SemanticSourceDetail::None),
        b"identity" => Some(SemanticSourceDetail::Identity),
        b"span" => Some(SemanticSourceDetail::Span),
        b"text" => Some(SemanticSourceDetail::Text),
        _ => None,
    }
}

const fn source_rank(value: SemanticSourceDetail) -> u8 {
    match value {
        SemanticSourceDetail::None => 0,
        SemanticSourceDetail::Identity => 1,
        SemanticSourceDetail::Span => 2,
        SemanticSourceDetail::Text => 3,
    }
}

const fn source_detail_name(value: SemanticSourceDetail) -> &'static str {
    match value {
        SemanticSourceDetail::None => "none",
        SemanticSourceDetail::Identity => "identity",
        SemanticSourceDetail::Span => "span",
        SemanticSourceDetail::Text => "text",
    }
}

fn protocol_error(id: Option<&Value>, kind: &str, requested: Option<&str>) -> Value {
    mcp_contract_runtime::json_rpc_error(id, kind, requested).unwrap_or_else(|_| {
        json!({
            "jsonrpc": "2.0",
            "id": id.cloned().unwrap_or(Value::Null),
            "error": {"code": -32603, "message": "Internal error"},
        })
    })
}

const fn contract_failure() -> McpServerError {
    McpServerError::new(
        "linkedspec_mcp_contract_failure",
        "The generated MCP contract is unavailable.",
    )
}

const fn invalid_index() -> McpServerError {
    McpServerError::new(
        "linkedspec_mcp_invalid_index",
        "The semantic index did not provide valid capabilities.",
    )
}

const fn invalid_policy(message: &'static str) -> McpServerError {
    McpServerError::new("linkedspec_mcp_invalid_policy", message)
}

const fn server_shutdown() -> McpServerError {
    McpServerError::new(
        "linkedspec_mcp_server_shutdown",
        "The MCP server has shut down.",
    )
}

const fn entropy_failure() -> McpServerError {
    McpServerError::new(
        "linkedspec_mcp_entropy_failure",
        "Operating-system entropy is unavailable.",
    )
}

const fn clock_failure() -> McpServerError {
    McpServerError::new(
        "linkedspec_mcp_clock_failure",
        "Monotonic time is unavailable.",
    )
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::semantic_index::{SemanticIndexOptions, SemanticSourceDetail};
    use std::cell::Cell;
    use std::rc::Rc;

    const SOURCE: &str = "Top::AND\n  /(?<word>[A-Za-z]+)/ -> Word\nWord:OR\n  /[A-Za-z]+/\n";

    fn index_with_detail(detail: SemanticSourceDetail) -> Arc<SemanticIndex> {
        Arc::new(
            SemanticIndex::from_source(SOURCE, SemanticIndexOptions::new("mcp.spec", detail))
                .unwrap(),
        )
    }

    fn index() -> Arc<SemanticIndex> {
        index_with_detail(SemanticSourceDetail::Text)
    }

    fn server_with(bytes: [u8; 32], now: Rc<Cell<u64>>) -> McpServer {
        McpServer::new_for_test(move || Ok(bytes), move || Ok(now.get()), 4, HANDLE_ATTEMPTS)
    }

    fn with_handle(name: &str, handle: &str) -> Value {
        let mut request = mcp_contract_runtime::frame(name).unwrap().unwrap();
        request["params"]["arguments"]["handle"] = Value::String(handle.to_string());
        request
    }

    #[test]
    fn fixed_encoder_matches_known_vectors() {
        assert_eq!(
            encode_base64url(&[0; 32]),
            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
        );
        assert_eq!(
            encode_base64url(&[0xff; 32]),
            "__________________________________________8"
        );
        for value in [0_u8, 1, 127, 128, 255] {
            let encoded = encode_base64url(&[value; 32]);
            assert!(valid_handle(&encoded));
            assert_eq!(encoded.len(), HANDLE_CHARACTERS);
        }
    }

    #[test]
    fn registry_enforces_auth_expiry_revoke_capacity_collision_and_release() {
        let now = Rc::new(Cell::new(10));
        let mut server = server_with([1; 32], Rc::clone(&now));
        let first_index = index();
        let weak = Arc::downgrade(&first_index);
        let handle = server
            .register_index(
                Arc::clone(&first_index),
                b"authorized",
                McpRegistrationOptions {
                    lifetime_ms: Some(5),
                    policy: None,
                },
            )
            .unwrap();
        drop(first_index);
        assert!(weak.upgrade().is_some());
        assert!(
            server
                .authorized_entry(&handle, authorization_digest(b"wrong"))
                .unwrap()
                .is_none()
        );
        now.set(15);
        assert!(
            server
                .authorized_entry(&handle, authorization_digest(b"authorized"))
                .unwrap()
                .is_none()
        );
        assert!(weak.upgrade().is_none());

        let mut collision = server_with([2; 32], Rc::new(Cell::new(0)));
        collision.handle_attempts = 1;
        collision
            .register_index(index(), b"a", McpRegistrationOptions::default())
            .unwrap();
        assert_eq!(
            collision
                .register_index(index(), b"b", McpRegistrationOptions::default())
                .unwrap_err()
                .code,
            "linkedspec_mcp_entropy_failure"
        );
        collision
            .revoke_handle(&encode_base64url(&[2; 32]))
            .unwrap();
        collision
            .register_index(index(), b"b", McpRegistrationOptions::default())
            .unwrap();
        collision.maximum_handles = 1;
        assert_eq!(
            collision
                .register_index(index(), b"c", McpRegistrationOptions::default())
                .unwrap_err()
                .code,
            "linkedspec_mcp_registry_full"
        );
        collision.shutdown();
        collision.shutdown();
        assert!(collision.entries.is_empty());
    }

    #[test]
    fn entropy_clock_and_panic_failures_are_sanitized() {
        let mut entropy_failure = McpServer::new_for_test(|| Err(()), || Ok(0), 1, 1);
        assert_eq!(
            entropy_failure
                .register_index(index(), b"auth", McpRegistrationOptions::default())
                .unwrap_err()
                .code,
            "linkedspec_mcp_entropy_failure"
        );
        let mut clock_failure = McpServer::new_for_test(|| Ok([0; 32]), || Err(()), 1, 1);
        assert_eq!(
            clock_failure
                .register_index(index(), b"auth", McpRegistrationOptions::default())
                .unwrap_err()
                .code,
            "linkedspec_mcp_clock_failure"
        );

        let mut server = server_with([3; 32], Rc::new(Cell::new(0)));
        let response = server
            .prepare_response(&json!(9), false, |_, _| panic!("host secret"))
            .unwrap();
        assert_eq!(response["error"]["code"], -32603);
        assert!(!response.to_string().contains("host secret"));
    }

    #[test]
    fn every_lowering_policy_component_denies_before_a_native_result() {
        let mut server = server_with([4; 32], Rc::new(Cell::new(0)));
        let handle = server
            .register_index(
                index(),
                b"policy-principal",
                McpRegistrationOptions {
                    lifetime_ms: None,
                    policy: Some(McpDeploymentPolicy {
                        source_detail_ceiling: Some(SemanticSourceDetail::Identity),
                        page_max: Some(50),
                        budget_maxima: Some(McpBudgetLimits {
                            max_records: 100,
                            max_relations: 200,
                            max_depth: 2,
                        }),
                    }),
                },
            )
            .unwrap();
        let mut allowed = with_handle("query_call_request", &handle);
        allowed["params"]["arguments"]["request"]["page"]["limit"] = json!(50);
        allowed["params"]["arguments"]["request"]["budget"] = json!({
            "max_records": 100,
            "max_relations": 200,
            "max_depth": 2,
        });
        assert_eq!(
            server
                .dispatch(&allowed, b"policy-principal")
                .unwrap()
                .unwrap()["result"]["isError"],
            false
        );

        let mut denied = Vec::new();
        let mut source = allowed.clone();
        source["params"]["arguments"]["request"]["source"]["detail"] = json!("span");
        denied.push(source);
        let mut digest = allowed.clone();
        digest["params"]["arguments"]["request"]["source"]["include_content_digest"] = json!(true);
        denied.push(digest);
        let mut page = allowed.clone();
        page["params"]["arguments"]["request"]["page"]["limit"] = json!(51);
        denied.push(page);
        for (name, value) in [
            ("max_records", 101),
            ("max_relations", 201),
            ("max_depth", 3),
        ] {
            let mut budget = allowed.clone();
            budget["params"]["arguments"]["request"]["budget"][name] = json!(value);
            denied.push(budget);
        }
        let expected = mcp_contract_runtime::tool_error_response(&json!(8), false).unwrap();
        for request in denied {
            let before = server.native_query_dispatches;
            assert_eq!(
                server
                    .dispatch(&request, b"policy-principal")
                    .unwrap()
                    .unwrap(),
                expected
            );
            assert_eq!(server.native_query_dispatches, before);
        }
    }

    #[test]
    fn omitted_and_partial_overlays_preserve_native_portable_diagnostics() {
        let mut default_server = server_with([14; 32], Rc::new(Cell::new(0)));
        let default_handle = default_server
            .register_index(
                index_with_detail(SemanticSourceDetail::Identity),
                b"default-policy-principal",
                McpRegistrationOptions::default(),
            )
            .unwrap();
        let mut source_request = with_handle("query_call_request", &default_handle);
        source_request["params"]["arguments"]["request"]["source"]["detail"] = json!("span");
        let source_response = default_server
            .dispatch(&source_request, b"default-policy-principal")
            .unwrap()
            .unwrap();
        assert_eq!(
            source_response.pointer("/result/structuredContent/diagnostics/0/code"),
            Some(&json!("semantic_query_source_detail_forbidden"))
        );
        assert_eq!(default_server.native_query_dispatches, 1);

        let mut unsupported = with_handle("query_call_request", &default_handle);
        unsupported["params"]["arguments"]["request"]["contract"] =
            json!("linkedspec-semantic-query-v2");
        let unsupported_response = default_server
            .dispatch(&unsupported, b"default-policy-principal")
            .unwrap()
            .unwrap();
        assert_eq!(
            unsupported_response.pointer("/result/structuredContent/diagnostics/0/code"),
            Some(&json!("semantic_query_contract_unsupported"))
        );
        assert_eq!(default_server.native_query_dispatches, 2);

        let mut partial_server = server_with([15; 32], Rc::new(Cell::new(0)));
        let partial_handle = partial_server
            .register_index(
                index_with_detail(SemanticSourceDetail::Identity),
                b"partial-policy-principal",
                McpRegistrationOptions {
                    lifetime_ms: None,
                    policy: Some(McpDeploymentPolicy {
                        page_max: Some(50),
                        ..McpDeploymentPolicy::default()
                    }),
                },
            )
            .unwrap();
        let mut partial_request = with_handle("query_call_request", &partial_handle);
        partial_request["params"]["arguments"]["request"]["page"]["limit"] = json!(50);
        partial_request["params"]["arguments"]["request"]["source"]["detail"] = json!("span");
        let partial_response = partial_server
            .dispatch(&partial_request, b"partial-policy-principal")
            .unwrap()
            .unwrap();
        assert_eq!(
            partial_response.pointer("/result/structuredContent/diagnostics/0/code"),
            Some(&json!("semantic_query_source_detail_forbidden"))
        );
        assert_eq!(partial_server.native_query_dispatches, 1);
    }

    #[test]
    fn unavailable_states_capacity_pruning_and_cancellation_are_exact() {
        let expected = mcp_contract_runtime::tool_error_response(&json!(11), true).unwrap();
        let unknown_request = mcp_contract_runtime::frame("handle_unavailable_request")
            .unwrap()
            .unwrap();
        let mut unknown = server_with([5; 32], Rc::new(Cell::new(0)));
        assert_eq!(
            unknown
                .dispatch(&unknown_request, b"principal")
                .unwrap()
                .unwrap(),
            expected
        );

        let mut unauthorized = server_with([6; 32], Rc::new(Cell::new(0)));
        let unauthorized_handle = unauthorized
            .register_index(index(), b"principal", McpRegistrationOptions::default())
            .unwrap();
        assert_eq!(
            unauthorized
                .dispatch(
                    &with_handle("handle_unavailable_request", &unauthorized_handle),
                    b"wrong",
                )
                .unwrap()
                .unwrap(),
            expected
        );

        let expired_now = Rc::new(Cell::new(0));
        let mut expired = server_with([7; 32], Rc::clone(&expired_now));
        let expired_handle = expired
            .register_index(
                index(),
                b"principal",
                McpRegistrationOptions {
                    lifetime_ms: Some(1),
                    policy: None,
                },
            )
            .unwrap();
        expired_now.set(1);
        assert_eq!(
            expired
                .dispatch(
                    &with_handle("handle_unavailable_request", &expired_handle),
                    b"principal",
                )
                .unwrap()
                .unwrap(),
            expected
        );

        let entropy_counter = Rc::new(Cell::new(8_u8));
        let entropy_counter_for_source = Rc::clone(&entropy_counter);
        let capacity_now = Rc::new(Cell::new(0_u64));
        let capacity_now_for_source = Rc::clone(&capacity_now);
        let mut capacity = McpServer::new_for_test(
            move || {
                let value = entropy_counter_for_source.get();
                entropy_counter_for_source.set(value + 1);
                Ok([value; 32])
            },
            move || Ok(capacity_now_for_source.get()),
            1,
            HANDLE_ATTEMPTS,
        );
        capacity
            .register_index(
                index(),
                b"principal",
                McpRegistrationOptions {
                    lifetime_ms: Some(1),
                    policy: None,
                },
            )
            .unwrap();
        assert_eq!(
            capacity
                .register_index(index(), b"principal", McpRegistrationOptions::default())
                .unwrap_err()
                .code,
            "linkedspec_mcp_registry_full"
        );
        capacity_now.set(1);
        capacity
            .register_index(index(), b"principal", McpRegistrationOptions::default())
            .expect("expired entry is pruned before capacity refusal");

        let active_key = mcp_contract_runtime::canonical_json(&json!(13)).unwrap();
        capacity
            .active
            .insert(active_key.clone(), ActiveRequest::default());
        assert_eq!(
            capacity
                .dispatch(
                    &mcp_contract_runtime::frame("cancelled_notification")
                        .unwrap()
                        .unwrap(),
                    b"principal",
                )
                .unwrap(),
            None
        );
        assert!(capacity.active[&active_key].cancelled);
        capacity.active.remove(&active_key);
    }
}
