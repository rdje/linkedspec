//! Private caller-frozen authority for one-depth staged-AST enrichment.
//!
//! The caller supplies an immutable registry snapshot whose entries already contain
//! compiled opaque callbacks. Dispatch performs no loading, compilation, provider
//! query, filesystem access, or registry mutation. This module intentionally owns
//! only one complete marker depth; recursive breadth-first scheduling and shared
//! cross-depth resource authority belong to the next task-tree leaf.

use serde_json::{Map, Value, json};
use sha2::{Digest, Sha256};
use std::cmp::Ordering;
use std::collections::{BTreeMap, BTreeSet};
use std::fmt::{self, Write as _};
use std::panic::{AssertUnwindSafe, catch_unwind};
use std::sync::{Arc, Mutex};

const ERROR_PREFIX: &str = "LINKEDSPEC_STAGED_AST_ENRICHMENT_ERROR:";
const MARKER_KIND: &str = "STAGED_PARSE_JOB_MARKER";
const SIDECAR_KIND: &str = "staged_parse_job_v2";
const LIVE_RESULT_KEYS: &[&str] = &[
    "parser",
    "parser_handle",
    "registry",
    "source_authority",
    "frame",
    "transaction",
    "cancellation",
    "callback",
    "host",
    "path",
    "live_handle",
];
const SOURCE_DETAILS: &[&str] = &["none", "identity", "span", "text"];

/// One detached staged-enrichment failure.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct StagedAstEnrichmentError {
    record: Value,
}

impl StagedAstEnrichmentError {
    fn new(
        code: &str,
        phase: &str,
        fields: impl IntoIterator<Item = (&'static str, Value)>,
    ) -> Self {
        let mut record = Map::new();
        record.insert("code".to_owned(), json!(code));
        record.insert("phase".to_owned(), json!(phase));
        for (name, value) in fields {
            record.insert(name.to_owned(), value);
        }
        Self {
            record: Value::Object(record),
        }
    }

    fn snapshot(component: &str) -> Self {
        Self::new(
            "staged_registry_snapshot_invalid",
            "prepare",
            [("snapshot_component", json!(component))],
        )
    }

    /// Return a detached machine-readable diagnostic record.
    pub fn as_record(&self) -> Value {
        self.record.clone()
    }
}

impl fmt::Display for StagedAstEnrichmentError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            formatter,
            "{ERROR_PREFIX}{}",
            self.record["code"]
                .as_str()
                .unwrap_or("staged_ast_enrichment_error")
        )
    }
}

impl std::error::Error for StagedAstEnrichmentError {}

/// Fresh parser-local state supplied to exactly one opaque child callback.
#[derive(Debug, Clone, Default, PartialEq)]
pub struct StagedRuntimeContext {
    cursor: u64,
    marks: BTreeMap<String, Value>,
    captures: BTreeMap<String, Value>,
    variables: BTreeMap<String, Value>,
}

impl StagedRuntimeContext {
    /// Return a detached snapshot of the parser-local state.
    pub fn as_record(&self) -> Value {
        json!({
            "cursor": self.cursor,
            "marks": self.marks,
            "captures": self.captures,
            "variables": self.variables,
        })
    }

    /// Mutate the callback-local cursor. It cannot affect a sibling or parent parse.
    pub fn set_cursor(&mut self, cursor: u64) {
        self.cursor = cursor;
    }

    /// Access callback-local marks.
    pub fn marks_mut(&mut self) -> &mut BTreeMap<String, Value> {
        &mut self.marks
    }

    /// Access callback-local captures.
    pub fn captures_mut(&mut self) -> &mut BTreeMap<String, Value> {
        &mut self.captures
    }

    /// Access callback-local variables.
    pub fn variables_mut(&mut self) -> &mut BTreeMap<String, Value> {
        &mut self.variables
    }
}

type Callback =
    dyn Fn(&Value, &mut StagedRuntimeContext) -> Result<Value, Value> + Send + Sync + 'static;

/// One already-compiled opaque child parser callback.
#[derive(Clone)]
pub struct CompiledStagedAuthority(Arc<Callback>);

impl CompiledStagedAuthority {
    /// Wrap one caller-owned compiled callback without serializing it into logical data.
    pub fn new<F>(callback: F) -> Self
    where
        F: Fn(&Value, &mut StagedRuntimeContext) -> Result<Value, Value> + Send + Sync + 'static,
    {
        Self(Arc::new(callback))
    }

    fn execute(&self, request: &Value, context: &mut StagedRuntimeContext) -> Result<Value, Value> {
        (self.0)(request, context)
    }
}

#[derive(Clone)]
struct DirectCandidate {
    declaring_spec_id: String,
    authored_id: String,
    resolved_spec_id: String,
}

#[derive(Clone)]
struct Candidate {
    authored_id: String,
    resolved_spec_id: String,
}

#[derive(Clone)]
struct OrderedCandidates {
    identity: String,
    order: u64,
    candidates: Vec<Candidate>,
}

#[derive(Clone)]
struct RegistryEntry {
    compiled_authority: CompiledStagedAuthority,
    content_digest: String,
    import_graph_fingerprint: String,
    default_top_rule: String,
    allowed_top_rules: BTreeSet<String>,
    spec_language_version: u64,
    helper_contract_version: String,
    staged_contract_version: u64,
    capabilities: BTreeSet<String>,
    policy_modes: BTreeSet<String>,
    ceilings: Ceilings,
}

#[derive(Debug, Clone, PartialEq, Eq)]
struct Ceilings {
    source_detail: String,
    max_steps: u64,
    max_result_nodes: u64,
    max_diagnostic_bytes: u64,
}

#[derive(Clone)]
struct CachedPlan {
    compiled_authority: CompiledStagedAuthority,
    resolved_spec_id: String,
    top_rule: String,
    effective_capabilities: Vec<String>,
}

#[derive(Default)]
struct PlanCache {
    entries: BTreeMap<String, CachedPlan>,
    hits: u64,
    misses: u64,
}

/// Detached cache counters for one frozen registry instance.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct StagedCacheStats {
    /// Immutable logical registry snapshot identity.
    pub snapshot_id: String,
    /// Number of compiled-plan entries cached in this authority instance.
    pub entries: usize,
    /// Number of compiled-plan cache hits.
    pub hits: u64,
    /// Number of compiled-plan cache misses.
    pub misses: u64,
}

impl StagedCacheStats {
    /// Return the neutral cache-statistics shape.
    pub fn as_record(&self) -> Value {
        json!({
            "snapshot_id": self.snapshot_id,
            "entries": self.entries,
            "hits": self.hits,
            "misses": self.misses,
        })
    }
}

/// Immutable caller-prepared registry plus its run-local compiled-plan cache.
pub struct FrozenStagedRegistry {
    aliases: Vec<DirectCandidate>,
    declaring_relative: Vec<DirectCandidate>,
    search_roots: Vec<OrderedCandidates>,
    providers: Vec<OrderedCandidates>,
    entries: BTreeMap<String, RegistryEntry>,
    snapshot_id: String,
    cache: Mutex<PlanCache>,
}

impl FrozenStagedRegistry {
    /// Freeze the neutral logical snapshot and bind every opaque authority name to an
    /// already-compiled callback. No callback or ambient loader enters logical data.
    pub fn from_value(
        snapshot: &Value,
        mut compiled: BTreeMap<String, CompiledStagedAuthority>,
    ) -> Result<Self, StagedAstEnrichmentError> {
        let object = snapshot
            .as_object()
            .ok_or_else(|| StagedAstEnrichmentError::snapshot("shape"))?;
        if object.get("immutable").and_then(Value::as_bool) != Some(true)
            || object
                .get("prepared_before_authored_execution")
                .and_then(Value::as_bool)
                != Some(true)
            || object
                .get("filesystem_access_during_dispatch")
                .and_then(Value::as_bool)
                != Some(false)
        {
            return Err(StagedAstEnrichmentError::snapshot("authority_boundary"));
        }

        let entry_rows = required_array(object, "entries")?;
        if entry_rows.is_empty() {
            return Err(StagedAstEnrichmentError::snapshot("entries"));
        }
        let mut entries = BTreeMap::new();
        for row in entry_rows {
            let row = row
                .as_object()
                .ok_or_else(|| StagedAstEnrichmentError::snapshot("entries"))?;
            let resolved_spec_id = required_string(row, "resolved_spec_id")?;
            if !valid_parser_identity(&resolved_spec_id) || entries.contains_key(&resolved_spec_id)
            {
                return Err(StagedAstEnrichmentError::snapshot("resolved_spec_id"));
            }
            let authority_name = required_string(row, "compiled_authority")?;
            let compiled_authority = compiled
                .remove(&authority_name)
                .ok_or_else(|| StagedAstEnrichmentError::snapshot("compiled_authority"))?;
            let content_digest = required_digest(row, "content_digest")?;
            let import_graph_fingerprint = required_digest(row, "import_graph_fingerprint")?;
            let default_top_rule = required_top_rule(row, "default_top_rule")?;
            let allowed_top_rules = string_set(row.get("allowed_top_rules"), "allowed_top_rules")?;
            if !allowed_top_rules.contains(&default_top_rule) {
                return Err(StagedAstEnrichmentError::snapshot("default_top_rule"));
            }
            let spec_language_version = positive_integer(row, "spec_language_version")?;
            let helper_contract_version = required_string(row, "helper_contract_version")?;
            let staged_contract_version = positive_integer(row, "staged_contract_version")?;
            let capabilities = string_set(row.get("capabilities"), "capabilities")?;
            let policy_modes = string_set(row.get("policy_modes"), "policy_modes")?;
            let ceilings = ceilings_from_value(
                row.get("ceilings")
                    .ok_or_else(|| StagedAstEnrichmentError::snapshot("ceilings"))?,
            )?;
            entries.insert(
                resolved_spec_id.clone(),
                RegistryEntry {
                    compiled_authority,
                    content_digest,
                    import_graph_fingerprint,
                    default_top_rule,
                    allowed_top_rules,
                    spec_language_version,
                    helper_contract_version,
                    staged_contract_version,
                    capabilities,
                    policy_modes,
                    ceilings,
                },
            );
        }

        let aliases = direct_candidates(required_array(object, "aliases")?, &entries, "aliases")?;
        let declaring_relative = direct_candidates(
            required_array(object, "declaring_relative")?,
            &entries,
            "declaring_relative",
        )?;
        let search_roots = ordered_candidates(
            required_array(object, "search_roots")?,
            &entries,
            "root_id",
            "search_roots",
        )?;
        let providers = ordered_candidates(
            required_array(object, "providers")?,
            &entries,
            "provider_id",
            "providers",
        )?;

        let mut logical = snapshot.clone();
        for entry in logical["entries"]
            .as_array_mut()
            .ok_or_else(|| StagedAstEnrichmentError::snapshot("entries"))?
        {
            entry["compiled_authority"] = json!("opaque:compiled:callback");
        }
        let snapshot_id = format!("registry-snapshot:{}", digest(&logical));
        Ok(Self {
            aliases,
            declaring_relative,
            search_roots,
            providers,
            entries,
            snapshot_id,
            cache: Mutex::new(PlanCache::default()),
        })
    }

    /// Select one parser only from caller-frozen candidate outcomes.
    pub fn resolve_pre_registered(
        &self,
        declaring_spec_id: &str,
        parser_spec_id: &str,
        job_id: &str,
    ) -> Result<String, StagedAstEnrichmentError> {
        if !valid_parser_identity(parser_spec_id) {
            return Err(StagedAstEnrichmentError::new(
                "staged_parser_identity_invalid",
                "resolve",
                [
                    ("origin", json!("post_ast")),
                    ("parser_spec_id", json!(parser_spec_id)),
                ],
            ));
        }
        let aliases = direct_matches(&self.aliases, declaring_spec_id, parser_spec_id);
        let relative = direct_matches(&self.declaring_relative, declaring_spec_id, parser_spec_id);
        if !aliases.is_empty() && !relative.is_empty() {
            return Err(StagedAstEnrichmentError::new(
                "staged_registry_collision",
                "resolve",
                [
                    ("job_id", json!(job_id)),
                    ("parser_spec_id", json!(parser_spec_id)),
                    ("aliases", json!(aliases)),
                    ("relative_candidates", json!(relative)),
                ],
            ));
        }
        if aliases.len() > 1 || relative.len() > 1 {
            let (priority, candidates) = if aliases.len() > 1 {
                ("alias", aliases)
            } else {
                ("declaring_relative", relative)
            };
            return Err(StagedAstEnrichmentError::new(
                "staged_registry_ambiguous",
                "resolve",
                [
                    ("job_id", json!(job_id)),
                    ("parser_spec_id", json!(parser_spec_id)),
                    ("priority", json!(priority)),
                    ("candidates", json!(candidates)),
                ],
            ));
        }
        if let Some(resolved) = aliases.first().or_else(|| relative.first()) {
            return Ok(resolved.clone());
        }
        for group in self.search_roots.iter().chain(self.providers.iter()) {
            let matches = group
                .candidates
                .iter()
                .filter(|candidate| candidate.authored_id == parser_spec_id)
                .map(|candidate| candidate.resolved_spec_id.clone())
                .collect::<Vec<_>>();
            if matches.len() > 1 {
                return Err(StagedAstEnrichmentError::new(
                    "staged_registry_ambiguous",
                    "resolve",
                    [
                        ("job_id", json!(job_id)),
                        ("parser_spec_id", json!(parser_spec_id)),
                        ("priority", json!(group.identity)),
                        ("candidates", json!(matches)),
                    ],
                ));
            }
            if let Some(resolved) = matches.first() {
                return Ok(resolved.clone());
            }
        }
        Err(StagedAstEnrichmentError::new(
            "staged_registry_missing",
            "resolve",
            [
                ("job_id", json!(job_id)),
                ("parser_spec_id", json!(parser_spec_id)),
                ("declaring_spec_id", json!(declaring_spec_id)),
            ],
        ))
    }

    /// Evaluate one neutral authority case against this frozen registry.
    pub fn evaluate_authority_case(
        &self,
        case: &Value,
        job_id: &str,
    ) -> Result<Value, StagedAstEnrichmentError> {
        let object = case
            .as_object()
            .ok_or_else(|| StagedAstEnrichmentError::snapshot("authority_case"))?;
        let entry_id = required_string(object, "entry_id")?;
        let top_rule = required_top_rule(object, "top_rule")?;
        let requirements = AuthorityRequirements {
            caller_capabilities: string_set(
                object.get("caller_capabilities"),
                "caller_capabilities",
            )?,
            required_capabilities: string_set(
                object.get("required_capabilities"),
                "required_capabilities",
            )?,
            caller_policy_modes: string_set(
                object.get("caller_policy_modes"),
                "caller_policy_modes",
            )?,
            required_policy_modes: string_set(
                object.get("required_policy_modes"),
                "required_policy_modes",
            )?,
            caller_ceilings: ceilings_from_value(
                object
                    .get("caller_ceilings")
                    .ok_or_else(|| StagedAstEnrichmentError::snapshot("caller_ceilings"))?,
            )?,
            required_source_detail: required_string(object, "required_source_detail")?,
            required_versions: versions_from_value(
                object
                    .get("required_versions")
                    .ok_or_else(|| StagedAstEnrichmentError::snapshot("required_versions"))?,
            )?,
        };
        self.effective_authority(&entry_id, &top_rule, job_id, &requirements)
    }

    /// Return cache statistics without exposing cached callbacks.
    pub fn cache_stats(&self) -> StagedCacheStats {
        let cache = self.cache.lock().expect("staged plan-cache mutex poisoned");
        StagedCacheStats {
            snapshot_id: self.snapshot_id.clone(),
            entries: cache.entries.len(),
            hits: cache.hits,
            misses: cache.misses,
        }
    }

    fn effective_authority(
        &self,
        entry_id: &str,
        top_rule: &str,
        job_id: &str,
        required: &AuthorityRequirements,
    ) -> Result<Value, StagedAstEnrichmentError> {
        let entry = self.entries.get(entry_id).ok_or_else(|| {
            StagedAstEnrichmentError::new(
                "staged_registry_missing",
                "resolve",
                [
                    ("job_id", json!(job_id)),
                    ("parser_spec_id", json!(entry_id)),
                    ("declaring_spec_id", json!("<prepared-snapshot>")),
                ],
            )
        })?;
        for (name, required_version, actual) in [
            (
                "spec_language_version",
                Value::from(required.required_versions.spec_language_version),
                Value::from(entry.spec_language_version),
            ),
            (
                "helper_contract_version",
                Value::from(required.required_versions.helper_contract_version.clone()),
                Value::from(entry.helper_contract_version.clone()),
            ),
            (
                "staged_contract_version",
                Value::from(required.required_versions.staged_contract_version),
                Value::from(entry.staged_contract_version),
            ),
        ] {
            if required_version != actual {
                return Err(StagedAstEnrichmentError::new(
                    "staged_version_mismatch",
                    "compile",
                    [
                        ("job_id", json!(job_id)),
                        ("resolved_spec_id", json!(entry_id)),
                        ("version_kind", json!(name)),
                        ("required", required_version),
                        ("actual", actual),
                    ],
                ));
            }
        }
        if !entry.allowed_top_rules.contains(top_rule) {
            return Err(StagedAstEnrichmentError::new(
                "staged_top_rule_forbidden",
                "compile",
                [
                    ("job_id", json!(job_id)),
                    ("resolved_spec_id", json!(entry_id)),
                    ("top_rule", json!(top_rule)),
                ],
            ));
        }

        let capabilities = required
            .caller_capabilities
            .intersection(&entry.capabilities)
            .cloned()
            .collect::<Vec<_>>();
        let effective_capabilities = capabilities.iter().cloned().collect::<BTreeSet<_>>();
        for capability in &required.required_capabilities {
            if !effective_capabilities.contains(capability) {
                return Err(StagedAstEnrichmentError::new(
                    "staged_capability_denied",
                    "compile",
                    [
                        ("job_id", json!(job_id)),
                        ("resolved_spec_id", json!(entry_id)),
                        ("capability", json!(capability)),
                    ],
                ));
            }
        }

        let policy_modes = required
            .caller_policy_modes
            .intersection(&entry.policy_modes)
            .cloned()
            .collect::<Vec<_>>();
        let effective_modes = policy_modes.iter().cloned().collect::<BTreeSet<_>>();
        for policy in &required.required_policy_modes {
            if !effective_modes.contains(policy) {
                return Err(StagedAstEnrichmentError::new(
                    "staged_policy_denied",
                    "compile",
                    [
                        ("job_id", json!(job_id)),
                        ("resolved_spec_id", json!(entry_id)),
                        ("policy", json!(policy)),
                    ],
                ));
            }
        }

        let source_rank = source_detail_rank(&required.caller_ceilings.source_detail)?
            .min(source_detail_rank(&entry.ceilings.source_detail)?);
        let source_detail = SOURCE_DETAILS[source_rank];
        let required_rank = source_detail_rank(&required.required_source_detail)?;
        if source_rank < required_rank {
            return Err(StagedAstEnrichmentError::new(
                "staged_source_detail_denied",
                "compile",
                [
                    ("job_id", json!(job_id)),
                    ("resolved_spec_id", json!(entry_id)),
                    ("required", json!(required.required_source_detail)),
                    ("effective", json!(source_detail)),
                ],
            ));
        }
        Ok(json!({
            "capabilities": capabilities,
            "policy_modes": policy_modes,
            "source_detail": source_detail,
            "max_steps": required.caller_ceilings.max_steps.min(entry.ceilings.max_steps),
            "max_result_nodes": required.caller_ceilings.max_result_nodes.min(entry.ceilings.max_result_nodes),
            "max_diagnostic_bytes": required.caller_ceilings.max_diagnostic_bytes.min(entry.ceilings.max_diagnostic_bytes),
        }))
    }

    fn cached_plan(&self, plan: &PreparedPlan) -> CachedPlan {
        let mut cache = self.cache.lock().expect("staged plan-cache mutex poisoned");
        if let Some(cached) = cache.entries.get(&plan.cache_key).cloned() {
            cache.hits += 1;
            return cached;
        }
        let entry = self
            .entries
            .get(&plan.resolved_spec_id)
            .expect("prepared registry entry remains frozen");
        let cached = CachedPlan {
            compiled_authority: entry.compiled_authority.clone(),
            resolved_spec_id: plan.resolved_spec_id.clone(),
            top_rule: plan.top_rule.clone(),
            effective_capabilities: value_strings(&plan.effective["capabilities"]),
        };
        cache.entries.insert(plan.cache_key.clone(), cached.clone());
        cache.misses += 1;
        cached
    }
}

#[derive(Debug, Clone)]
struct Versions {
    spec_language_version: u64,
    helper_contract_version: String,
    staged_contract_version: u64,
}

#[derive(Debug, Clone)]
struct AuthorityRequirements {
    caller_capabilities: BTreeSet<String>,
    required_capabilities: BTreeSet<String>,
    caller_policy_modes: BTreeSet<String>,
    required_policy_modes: BTreeSet<String>,
    caller_ceilings: Ceilings,
    required_source_detail: String,
    required_versions: Versions,
}

#[derive(Debug, Clone)]
struct EnrichmentOptions {
    declaring_spec_id: String,
    caller_capabilities: BTreeSet<String>,
    caller_policy_modes: BTreeSet<String>,
    caller_ceilings: Ceilings,
    required_source_detail: String,
    required_versions: Versions,
}

impl EnrichmentOptions {
    fn from_value(value: &Value) -> Result<Self, StagedAstEnrichmentError> {
        let object = value
            .as_object()
            .ok_or_else(|| StagedAstEnrichmentError::snapshot("enrichment_options"))?;
        let declaring_spec_id = required_string(object, "declaring_spec_id")?;
        if !valid_parser_identity(&declaring_spec_id) {
            return Err(StagedAstEnrichmentError::snapshot("declaring_spec_id"));
        }
        let required_source_detail = required_string(object, "required_source_detail")?;
        source_detail_rank(&required_source_detail)?;
        Ok(Self {
            declaring_spec_id,
            caller_capabilities: string_set(
                object.get("caller_capabilities"),
                "caller_capabilities",
            )?,
            caller_policy_modes: string_set(
                object.get("caller_policy_modes"),
                "caller_policy_modes",
            )?,
            caller_ceilings: ceilings_from_value(
                object
                    .get("caller_ceilings")
                    .ok_or_else(|| StagedAstEnrichmentError::snapshot("caller_ceilings"))?,
            )?,
            required_source_detail,
            required_versions: versions_from_value(
                object
                    .get("required_versions")
                    .ok_or_else(|| StagedAstEnrichmentError::snapshot("required_versions"))?,
            )?,
        })
    }
}

#[derive(Clone)]
struct DiscoveredMarker {
    path: Vec<Value>,
    marker: Value,
}

#[derive(Clone)]
struct PreparedPlan {
    path: Vec<Value>,
    marker: Value,
    sidecar: Value,
    resolved_spec_id: String,
    top_rule: String,
    cache_key: String,
    effective: Value,
    provenance_order: Vec<OrderComponent>,
}

#[derive(Debug, Clone, Eq, PartialEq)]
enum OrderComponent {
    String(String),
    Integer(u64),
}

impl Ord for OrderComponent {
    fn cmp(&self, other: &Self) -> Ordering {
        match (self, other) {
            (Self::String(left), Self::String(right)) => left.cmp(right),
            (Self::Integer(left), Self::Integer(right)) => left.cmp(right),
            (Self::String(_), Self::Integer(_)) => Ordering::Less,
            (Self::Integer(_), Self::String(_)) => Ordering::Greater,
        }
    }
}

impl PartialOrd for OrderComponent {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

/// One detached current-depth enrichment result.
#[derive(Debug, Clone, PartialEq)]
pub struct StagedEnrichmentOutcome {
    /// Detached AST copy after all successful/continuing stitches.
    pub ast: Value,
    /// Prepared and settled scheduler sidecars in deterministic execution order.
    pub sidecars: Vec<Value>,
    /// Portable retained diagnostics for continuing failure policies.
    pub diagnostics: Vec<Value>,
    /// Cache statistics after this invocation.
    pub cache: StagedCacheStats,
}

/// Execute one complete marker depth through one frozen registry.
pub fn enrich_current_depth(
    registry: &FrozenStagedRegistry,
    ast: &Value,
    options: &Value,
) -> Result<StagedEnrichmentOutcome, StagedAstEnrichmentError> {
    let options = EnrichmentOptions::from_value(options)?;
    let mut working = ast.clone();
    let mut discovered = Vec::new();
    discover_current_depth(&working, &mut Vec::new(), &mut discovered);
    let mut plans = discovered
        .into_iter()
        .map(|row| prepare_plan(registry, row, &options))
        .collect::<Result<Vec<_>, _>>()?;
    plans.sort_by(compare_plans);
    for plan in &plans {
        validate_stitch_target(&working, plan)?;
    }

    let mut diagnostics = Vec::new();
    for plan in &mut plans {
        validate_stitch_target(&working, plan)?;
        let cached = registry.cached_plan(plan);
        debug_assert_eq!(cached.resolved_spec_id, plan.resolved_spec_id);
        debug_assert_eq!(cached.top_rule, plan.top_rule);
        debug_assert_eq!(
            cached.effective_capabilities,
            value_strings(&plan.effective["capabilities"])
        );
        let mut context = StagedRuntimeContext::default();
        let request = child_request(plan);
        match catch_unwind(AssertUnwindSafe(|| {
            cached.compiled_authority.execute(&request, &mut context)
        })) {
            Ok(Ok(result)) => match detach_result(
                &result,
                plan.effective["max_result_nodes"].as_u64().unwrap_or(0),
                &plan.sidecar,
            ) {
                Ok(result) => {
                    stitch_value(&mut working, plan, result)?;
                    plan.sidecar["state"] = json!("succeeded");
                }
                Err(diagnostic) => {
                    settle_failure(&mut working, plan, diagnostic, &mut diagnostics)?
                }
            },
            Ok(Err(child)) => {
                let diagnostic = child_failure_diagnostic(&plan.sidecar, &child);
                settle_failure(&mut working, plan, diagnostic, &mut diagnostics)?;
            }
            Err(_) => {
                let diagnostic = child_failure_diagnostic(
                    &plan.sidecar,
                    &json!({"code": "staged_child_exception"}),
                );
                settle_failure(&mut working, plan, diagnostic, &mut diagnostics)?;
            }
        }
    }
    Ok(StagedEnrichmentOutcome {
        ast: working,
        sidecars: plans.into_iter().map(|plan| plan.sidecar).collect(),
        diagnostics,
        cache: registry.cache_stats(),
    })
}

/// Construct the deterministic v2 job identity from the exact neutral fields.
pub fn staged_job_identity(fields: &Value) -> Result<String, StagedAstEnrichmentError> {
    let object = fields
        .as_object()
        .ok_or_else(|| StagedAstEnrichmentError::snapshot("job_identity"))?;
    let exact = [
        "declaring_spec_id",
        "parent_ast_path",
        "node_kind",
        "payload_kind",
        "parser_spec_id",
        "top_rule",
        "provenance",
    ];
    if object.len() != exact.len() || !exact.iter().all(|field| object.contains_key(*field)) {
        return Err(StagedAstEnrichmentError::snapshot("job_identity"));
    }
    let identity = json!({
        "contract_version": 2,
        "declaring_spec_id": object["declaring_spec_id"],
        "parent_ast_path": object["parent_ast_path"],
        "node_kind": object["node_kind"],
        "payload_kind": object["payload_kind"],
        "parser_spec_id": object["parser_spec_id"],
        "top_rule": object["top_rule"],
        "provenance": object["provenance"],
    });
    Ok(format!("parse_job:v2:{}", digest(&identity)))
}

/// Construct the normalized immutable compiled-plan cache identity.
pub fn staged_cache_identity(fields: &Value) -> Result<String, StagedAstEnrichmentError> {
    let object = fields
        .as_object()
        .ok_or_else(|| cache_identity_error(fields, "<shape>"))?;
    let exact = [
        "normalized_spec_id",
        "content_digest",
        "import_graph_fingerprint",
        "top_rule",
        "spec_language_version",
        "helper_contract_version",
        "staged_contract_version",
        "backend_capabilities",
    ];
    if object.len() != exact.len() || !exact.iter().all(|field| object.contains_key(*field)) {
        return Err(cache_identity_error(fields, "<shape>"));
    }
    let identity = object["normalized_spec_id"].as_str().unwrap_or_default();
    if !valid_parser_identity(identity) {
        return Err(cache_identity_error(fields, "normalized_spec_id"));
    }
    for field in ["content_digest", "import_graph_fingerprint"] {
        if !object[field].as_str().is_some_and(valid_digest) {
            return Err(cache_identity_error(fields, field));
        }
    }
    if !object["top_rule"].as_str().is_some_and(valid_top_rule) {
        return Err(cache_identity_error(fields, "top_rule"));
    }
    for field in ["spec_language_version", "staged_contract_version"] {
        if object[field].as_u64().is_none_or(|value| value == 0) {
            return Err(cache_identity_error(fields, field));
        }
    }
    if object["helper_contract_version"]
        .as_str()
        .is_none_or(str::is_empty)
    {
        return Err(cache_identity_error(fields, "helper_contract_version"));
    }
    let capabilities = string_set(object.get("backend_capabilities"), "backend_capabilities")
        .map_err(|_| cache_identity_error(fields, "backend_capabilities"))?;
    let mut normalized = fields.clone();
    normalized["backend_capabilities"] = json!(capabilities.into_iter().collect::<Vec<_>>());
    Ok(digest(&normalized))
}

/// Order a neutral inventory of jobs known to belong to one complete current depth.
/// Mixed depths reject here because breadth-first recurrence belongs to the next leaf.
pub fn staged_current_depth_order(jobs: &Value) -> Result<Vec<String>, StagedAstEnrichmentError> {
    let jobs = jobs
        .as_array()
        .ok_or_else(|| StagedAstEnrichmentError::snapshot("current_depth_jobs"))?;
    let mut rows = jobs
        .iter()
        .map(|job| {
            let object = job
                .as_object()
                .ok_or_else(|| StagedAstEnrichmentError::snapshot("current_depth_job"))?;
            let job_id = required_string(object, "job_id")?;
            let stage_depth = positive_integer(object, "stage_depth")?;
            let path = required_array(object, "parent_ast_path")?;
            let provenance = required_array(object, "provenance_order")?;
            Ok((
                stage_depth,
                path_order_checked(path)?,
                order_components(provenance)?,
                job_id,
            ))
        })
        .collect::<Result<Vec<_>, _>>()?;
    if rows
        .first()
        .is_some_and(|first| rows.iter().any(|row| row.0 != first.0))
    {
        return Err(StagedAstEnrichmentError::snapshot(
            "mixed_stage_depth_requires_recursive_scheduler",
        ));
    }
    rows.sort_by(|left, right| {
        left.1
            .cmp(&right.1)
            .then_with(|| left.2.cmp(&right.2))
            .then_with(|| left.3.cmp(&right.3))
    });
    Ok(rows.into_iter().map(|row| row.3).collect())
}

fn prepare_plan(
    registry: &FrozenStagedRegistry,
    discovered: DiscoveredMarker,
    options: &EnrichmentOptions,
) -> Result<PreparedPlan, StagedAstEnrichmentError> {
    let sidecar = marker_sidecar(&discovered.marker)?;
    let parser_spec_id = sidecar["parser_spec_id"]
        .as_str()
        .ok_or_else(|| marker_error("staged_parser_identity_invalid", &sidecar))?;
    let provisional_top = sidecar["top_rule"]
        .as_str()
        .unwrap_or("<unresolved-default>");
    let provisional_fields = job_fields(
        &options.declaring_spec_id,
        &discovered.path,
        &sidecar,
        provisional_top,
    )?;
    let provisional_job_id = staged_job_identity(&provisional_fields)?;
    let resolved_spec_id = registry.resolve_pre_registered(
        &options.declaring_spec_id,
        parser_spec_id,
        &provisional_job_id,
    )?;
    let entry = registry
        .entries
        .get(&resolved_spec_id)
        .expect("resolved frozen entry exists");
    let top_rule = sidecar["top_rule"]
        .as_str()
        .unwrap_or(&entry.default_top_rule)
        .to_owned();
    let fields = job_fields(
        &options.declaring_spec_id,
        &discovered.path,
        &sidecar,
        &top_rule,
    )?;
    let job_id = staged_job_identity(&fields)?;
    let mut required_policy_modes = BTreeSet::new();
    required_policy_modes.insert(required_sidecar_string(&sidecar, "result_policy")?);
    required_policy_modes.insert(required_sidecar_string(&sidecar, "failure_policy")?);
    let requirements = AuthorityRequirements {
        caller_capabilities: options.caller_capabilities.clone(),
        required_capabilities: string_set(
            sidecar.get("required_capabilities"),
            "required_capabilities",
        )?,
        caller_policy_modes: options.caller_policy_modes.clone(),
        required_policy_modes,
        caller_ceilings: options.caller_ceilings.clone(),
        required_source_detail: options.required_source_detail.clone(),
        required_versions: options.required_versions.clone(),
    };
    let effective =
        registry.effective_authority(&resolved_spec_id, &top_rule, &job_id, &requirements)?;
    let cache_fields = json!({
        "normalized_spec_id": resolved_spec_id,
        "content_digest": entry.content_digest,
        "import_graph_fingerprint": entry.import_graph_fingerprint,
        "top_rule": top_rule,
        "spec_language_version": entry.spec_language_version,
        "helper_contract_version": entry.helper_contract_version,
        "staged_contract_version": entry.staged_contract_version,
        "backend_capabilities": effective["capabilities"],
    });
    let cache_key = staged_cache_identity(&cache_fields)?;
    let mut scheduler_sidecar = sidecar;
    scheduler_sidecar["state"] = json!("prepared");
    scheduler_sidecar["declaring_spec_id"] = json!(options.declaring_spec_id);
    scheduler_sidecar["parent_ast_path"] = json!(discovered.path);
    scheduler_sidecar["resolved_spec_id"] = json!(resolved_spec_id);
    scheduler_sidecar["top_rule"] = json!(top_rule);
    scheduler_sidecar["job_id"] = json!(job_id);
    scheduler_sidecar["cache_key"] = json!(cache_key);
    scheduler_sidecar["stage_depth"] = json!(1);
    scheduler_sidecar["stage_chain"] = json!([]);
    scheduler_sidecar["effective"] = effective.clone();
    let provenance_order = provenance_order(&scheduler_sidecar["provenance"])?;
    Ok(PreparedPlan {
        path: discovered.path,
        marker: discovered.marker,
        sidecar: scheduler_sidecar,
        resolved_spec_id,
        top_rule,
        cache_key,
        effective,
        provenance_order,
    })
}

fn child_request(plan: &PreparedPlan) -> Value {
    let sidecar = &plan.sidecar;
    json!({
        "stage_depth": 1,
        "stage_chain": [],
        "job_id": sidecar["job_id"],
        "parent_ast_path": sidecar["parent_ast_path"],
        "node_kind": sidecar["node_kind"],
        "payload_kind": sidecar["payload_kind"],
        "parser_spec_id": sidecar["parser_spec_id"],
        "resolved_spec_id": sidecar["resolved_spec_id"],
        "top_rule": sidecar["top_rule"],
        "text": sidecar["text"],
        "source_provenance": sidecar["provenance"],
        "result_policy": sidecar["result_policy"],
        "failure_policy": sidecar["failure_policy"],
        "effective": sidecar["effective"],
    })
}

fn settle_failure(
    working: &mut Value,
    plan: &mut PreparedPlan,
    diagnostic: Value,
    diagnostics: &mut Vec<Value>,
) -> Result<(), StagedAstEnrichmentError> {
    diagnostics.push(diagnostic.clone());
    plan.sidecar["diagnostic"] = diagnostic.clone();
    match plan.sidecar["failure_policy"].as_str() {
        Some("fail") => Err(StagedAstEnrichmentError { record: diagnostic }),
        Some("keep_text") => {
            materialize_marker_text(working, plan)?;
            plan.sidecar["state"] = json!("failed_keep_text");
            Ok(())
        }
        Some("diagnostic_node") => {
            stitch_value(
                working,
                plan,
                json!({
                    "kind": "staged_parse_diagnostic",
                    "diagnostic": diagnostic,
                }),
            )?;
            plan.sidecar["state"] = json!("failed_diagnostic_node");
            Ok(())
        }
        _ => Err(marker_error("staged_failure_policy_invalid", &plan.sidecar)),
    }
}

fn child_failure_diagnostic(sidecar: &Value, child: &Value) -> Value {
    let portable = detach_plain(child, 256, false)
        .ok()
        .map(|(value, _)| value)
        .filter(Value::is_object)
        .unwrap_or_else(|| json!({"code": "staged_child_exception"}));
    json!({
        "code": "staged_child_failed",
        "phase": "execute",
        "stage_chain": sidecar["stage_chain"],
        "job_id": sidecar["job_id"],
        "parent_ast_path": sidecar["parent_ast_path"],
        "node_kind": sidecar["node_kind"],
        "payload_kind": sidecar["payload_kind"],
        "parser_spec_id": sidecar["parser_spec_id"],
        "resolved_spec_id": sidecar["resolved_spec_id"],
        "top_rule": sidecar["top_rule"],
        "cache_key": sidecar["cache_key"],
        "source_provenance": sidecar["provenance"],
        "result_policy": sidecar["result_policy"],
        "failure_policy": sidecar["failure_policy"],
        "child_diagnostic": portable,
    })
}

fn detach_result(value: &Value, maximum: u64, sidecar: &Value) -> Result<Value, Value> {
    match detach_plain(value, maximum, true) {
        Ok((detached, _)) => Ok(detached),
        Err((nodes, reason)) if reason == "node_limit" => Err(json!({
            "code": "staged_result_node_limit_exceeded",
            "phase": "execute",
            "stage_chain": sidecar["stage_chain"],
            "job_id": sidecar["job_id"],
            "nodes": nodes,
            "maximum": maximum,
        })),
        Err((_nodes, reason)) => Err(json!({
            "code": "staged_result_not_detached",
            "phase": "execute",
            "stage_chain": sidecar["stage_chain"],
            "job_id": sidecar["job_id"],
            "field": reason,
        })),
    }
}

fn detach_plain(
    value: &Value,
    maximum: u64,
    allow_markers: bool,
) -> Result<(Value, u64), (u64, String)> {
    fn walk(
        value: &Value,
        maximum: u64,
        allow_markers: bool,
        nodes: &mut u64,
    ) -> Result<Value, String> {
        *nodes += 1;
        if *nodes > maximum {
            return Err("node_limit".to_owned());
        }
        if allow_markers && is_marker(value) {
            return Ok(value.clone());
        }
        match value {
            Value::Array(values) => values
                .iter()
                .map(|child| walk(child, maximum, allow_markers, nodes))
                .collect::<Result<Vec<_>, _>>()
                .map(Value::Array),
            Value::Object(object) => {
                for key in object.keys() {
                    if key == "$ref" || LIVE_RESULT_KEYS.contains(&key.as_str()) {
                        return Err(key.clone());
                    }
                }
                object
                    .iter()
                    .map(|(key, child)| {
                        walk(child, maximum, allow_markers, nodes).map(|owned| (key.clone(), owned))
                    })
                    .collect::<Result<Map<_, _>, _>>()
                    .map(Value::Object)
            }
            _ => Ok(value.clone()),
        }
    }
    let mut nodes = 0;
    match walk(value, maximum, allow_markers, &mut nodes) {
        Ok(detached) => Ok((detached, nodes)),
        Err(reason) => Err((nodes, reason)),
    }
}

fn validate_stitch_target(
    ast: &Value,
    plan: &PreparedPlan,
) -> Result<(), StagedAstEnrichmentError> {
    let (parent, component, actual) = locate_slot(ast, &plan.path).ok_or_else(|| {
        stitch_error(
            plan,
            "staged_stitch_target_missing",
            [("into", json!("<path>"))],
        )
    })?;
    if actual != &plan.marker || !is_marker(actual) {
        return Err(stitch_error(
            plan,
            "staged_marker_mismatch",
            [("actual_marker", marker_diagnostic(actual))],
        ));
    }
    let result_policy = plan.sidecar["result_policy"].as_str().unwrap_or_default();
    if result_policy == "replace_marker" {
        return Ok(());
    }
    let Some(into) = plan.sidecar["into"]
        .as_str()
        .filter(|value| !value.is_empty())
    else {
        return Err(stitch_error(
            plan,
            "staged_stitch_target_missing",
            [("into", json!("<missing>"))],
        ));
    };
    let Some(parent) = parent.as_object() else {
        return Err(stitch_error(
            plan,
            "staged_stitch_target_missing",
            [("into", json!(into))],
        ));
    };
    match result_policy {
        "replace_field" if !parent.contains_key(into) => Err(stitch_error(
            plan,
            "staged_stitch_target_missing",
            [("into", json!(into))],
        )),
        "sibling_field" if parent.contains_key(into) => Err(stitch_error(
            plan,
            "staged_stitch_target_collision",
            [("into", json!(into))],
        )),
        "append_child" if !parent.get(into).is_some_and(Value::is_array) => Err(stitch_error(
            plan,
            "staged_append_target_invalid",
            [("into", json!(into))],
        )),
        "replace_field" | "sibling_field" | "append_child" => {
            let _ = component;
            Ok(())
        }
        _ => Err(marker_error("staged_result_policy_invalid", &plan.sidecar)),
    }
}

fn stitch_value(
    ast: &mut Value,
    plan: &PreparedPlan,
    result: Value,
) -> Result<(), StagedAstEnrichmentError> {
    validate_stitch_target(ast, plan)?;
    let result_policy = plan.sidecar["result_policy"]
        .as_str()
        .unwrap_or_default()
        .to_owned();
    let text = plan.sidecar["text"].clone();
    let into = plan.sidecar["into"].as_str().map(str::to_owned);
    let (parent, component, _) = locate_slot_mut(ast, &plan.path).ok_or_else(|| {
        stitch_error(
            plan,
            "staged_stitch_target_missing",
            [("into", json!("<path>"))],
        )
    })?;
    if result_policy == "replace_marker" {
        set_component(parent, &component, result)
            .ok_or_else(|| stitch_error(plan, "staged_marker_mismatch", []))?;
        return Ok(());
    }
    set_component(parent, &component, text)
        .ok_or_else(|| stitch_error(plan, "staged_marker_mismatch", []))?;
    let parent = parent
        .as_object_mut()
        .expect("non-marker policy parent validated as object");
    let into = into.expect("non-marker result target validated");
    match result_policy.as_str() {
        "replace_field" | "sibling_field" => {
            parent.insert(into, result);
        }
        "append_child" => parent
            .get_mut(&into)
            .and_then(Value::as_array_mut)
            .expect("append target validated as array")
            .push(result),
        _ => unreachable!("result policy validated before stitch"),
    }
    Ok(())
}

fn materialize_marker_text(
    ast: &mut Value,
    plan: &PreparedPlan,
) -> Result<(), StagedAstEnrichmentError> {
    validate_stitch_target(ast, plan)?;
    let (parent, component, _) = locate_slot_mut(ast, &plan.path).ok_or_else(|| {
        stitch_error(
            plan,
            "staged_marker_mismatch",
            [("actual_marker", json!("<missing>"))],
        )
    })?;
    set_component(parent, &component, plan.sidecar["text"].clone())
        .ok_or_else(|| stitch_error(plan, "staged_marker_mismatch", []))
}

fn discover_current_depth(value: &Value, path: &mut Vec<Value>, found: &mut Vec<DiscoveredMarker>) {
    if is_marker(value) {
        found.push(DiscoveredMarker {
            path: path.clone(),
            marker: value.clone(),
        });
        return;
    }
    match value {
        Value::Object(object) => {
            for (key, child) in object {
                path.push(json!(key));
                discover_current_depth(child, path, found);
                path.pop();
            }
        }
        Value::Array(values) => {
            for (index, child) in values.iter().enumerate() {
                path.push(json!(index));
                discover_current_depth(child, path, found);
                path.pop();
            }
        }
        _ => {}
    }
}

fn compare_plans(left: &PreparedPlan, right: &PreparedPlan) -> Ordering {
    path_order(&left.path)
        .cmp(&path_order(&right.path))
        .then_with(|| left.provenance_order.cmp(&right.provenance_order))
        .then_with(|| {
            left.sidecar["job_id"]
                .as_str()
                .cmp(&right.sidecar["job_id"].as_str())
        })
}

fn path_order(path: &[Value]) -> Vec<OrderComponent> {
    path.iter()
        .map(|component| {
            component.as_u64().map_or_else(
                || OrderComponent::String(component.as_str().unwrap_or_default().to_owned()),
                OrderComponent::Integer,
            )
        })
        .collect()
}

fn path_order_checked(path: &[Value]) -> Result<Vec<OrderComponent>, StagedAstEnrichmentError> {
    order_components(path)
}

fn order_components(values: &[Value]) -> Result<Vec<OrderComponent>, StagedAstEnrichmentError> {
    values
        .iter()
        .map(|component| {
            if let Some(value) = component.as_u64() {
                Ok(OrderComponent::Integer(value))
            } else if let Some(value) = component.as_str() {
                Ok(OrderComponent::String(value.to_owned()))
            } else {
                Err(StagedAstEnrichmentError::snapshot("typed_order_component"))
            }
        })
        .collect()
}

fn provenance_order(value: &Value) -> Result<Vec<OrderComponent>, StagedAstEnrichmentError> {
    let segments = if value["kind"] == "direct_span" {
        vec![value]
    } else {
        value["segments"]
            .as_array()
            .ok_or_else(|| StagedAstEnrichmentError::snapshot("provenance"))?
            .iter()
            .collect()
    };
    let mut order = Vec::new();
    for segment in segments {
        order.push(OrderComponent::String(
            segment["source_id"].as_str().unwrap_or_default().to_owned(),
        ));
        order.push(OrderComponent::Integer(
            segment["start"].as_u64().unwrap_or_default(),
        ));
        order.push(OrderComponent::Integer(
            segment["end"].as_u64().unwrap_or_default(),
        ));
        order.push(OrderComponent::String(
            segment["provenance"]
                .as_str()
                .unwrap_or_default()
                .to_owned(),
        ));
    }
    Ok(order)
}

fn marker_sidecar(marker: &Value) -> Result<Value, StagedAstEnrichmentError> {
    if !is_marker(marker) {
        return Err(StagedAstEnrichmentError::snapshot("marker"));
    }
    let sidecar = marker[SIDECAR_KIND].clone();
    if sidecar["kind"] != SIDECAR_KIND || sidecar["version"] != 2 || sidecar["state"] != "declared"
    {
        return Err(StagedAstEnrichmentError::snapshot("sidecar"));
    }
    Ok(sidecar)
}

fn is_marker(value: &Value) -> bool {
    value["kind"] == MARKER_KIND
        && value["version"] == 2
        && value["sidecar_kind"] == SIDECAR_KIND
        && value.get(SIDECAR_KIND).is_some_and(Value::is_object)
}

fn job_fields(
    declaring_spec_id: &str,
    path: &[Value],
    sidecar: &Value,
    top_rule: &str,
) -> Result<Value, StagedAstEnrichmentError> {
    for field in ["node_kind", "payload_kind", "parser_spec_id"] {
        required_sidecar_string(sidecar, field)?;
    }
    if !valid_top_rule(top_rule) && top_rule != "<unresolved-default>" {
        return Err(marker_error("staged_top_rule_invalid", sidecar));
    }
    Ok(json!({
        "declaring_spec_id": declaring_spec_id,
        "parent_ast_path": path,
        "node_kind": sidecar["node_kind"],
        "payload_kind": sidecar["payload_kind"],
        "parser_spec_id": sidecar["parser_spec_id"],
        "top_rule": top_rule,
        "provenance": sidecar["provenance"],
    }))
}

fn required_sidecar_string(
    sidecar: &Value,
    field: &str,
) -> Result<String, StagedAstEnrichmentError> {
    sidecar[field]
        .as_str()
        .filter(|value| !value.is_empty())
        .map(str::to_owned)
        .ok_or_else(|| StagedAstEnrichmentError::snapshot(field))
}

fn marker_error(code: &str, sidecar: &Value) -> StagedAstEnrichmentError {
    StagedAstEnrichmentError::new(
        code,
        "prepare",
        [(
            "origin",
            sidecar.get("origin").cloned().unwrap_or(json!("<runtime>")),
        )],
    )
}

fn stitch_error<const N: usize>(
    plan: &PreparedPlan,
    code: &str,
    extra: [(&'static str, Value); N],
) -> StagedAstEnrichmentError {
    let mut fields = vec![
        ("stage_chain", plan.sidecar["stage_chain"].clone()),
        ("job_id", plan.sidecar["job_id"].clone()),
        ("parent_ast_path", json!(plan.path)),
    ];
    fields.extend(extra);
    StagedAstEnrichmentError::new(code, "stitch", fields)
}

fn marker_diagnostic(value: &Value) -> Value {
    if is_marker(value) {
        value.clone()
    } else if value.is_null() {
        json!("<missing>")
    } else if value.is_array() || value.is_object() {
        json!("<reference>")
    } else {
        value.clone()
    }
}

fn locate_slot<'a>(root: &'a Value, path: &[Value]) -> Option<(&'a Value, Value, &'a Value)> {
    let (component, parents) = path.split_last()?;
    let mut parent = root;
    for part in parents {
        parent = get_component(parent, part)?;
    }
    let actual = get_component(parent, component)?;
    Some((parent, component.clone(), actual))
}

fn locate_slot_mut<'a>(
    root: &'a mut Value,
    path: &[Value],
) -> Option<(&'a mut Value, Value, Value)> {
    let (component, parents) = path.split_last()?;
    let mut parent = root;
    for part in parents {
        parent = get_component_mut(parent, part)?;
    }
    let actual = get_component(parent, component)?.clone();
    Some((parent, component.clone(), actual))
}

fn get_component<'a>(value: &'a Value, component: &Value) -> Option<&'a Value> {
    match value {
        Value::Object(object) => object.get(component.as_str()?),
        Value::Array(values) => values.get(usize::try_from(component.as_u64()?).ok()?),
        _ => None,
    }
}

fn get_component_mut<'a>(value: &'a mut Value, component: &Value) -> Option<&'a mut Value> {
    match value {
        Value::Object(object) => object.get_mut(component.as_str()?),
        Value::Array(values) => values.get_mut(usize::try_from(component.as_u64()?).ok()?),
        _ => None,
    }
}

fn set_component(parent: &mut Value, component: &Value, replacement: Value) -> Option<()> {
    match parent {
        Value::Object(object) => {
            *object.get_mut(component.as_str()?)? = replacement;
            Some(())
        }
        Value::Array(values) => {
            *values.get_mut(usize::try_from(component.as_u64()?).ok()?)? = replacement;
            Some(())
        }
        _ => None,
    }
}

fn cache_identity_error(fields: &Value, component: &str) -> StagedAstEnrichmentError {
    StagedAstEnrichmentError::new(
        "staged_cache_identity_invalid",
        "compile",
        [
            ("job_id", json!("<unassigned>")),
            (
                "resolved_spec_id",
                fields
                    .get("normalized_spec_id")
                    .cloned()
                    .unwrap_or(json!("<missing>")),
            ),
            ("cache_component", json!(component)),
        ],
    )
}

fn direct_matches(
    candidates: &[DirectCandidate],
    declaring_spec_id: &str,
    authored_id: &str,
) -> Vec<String> {
    candidates
        .iter()
        .filter(|candidate| {
            candidate.declaring_spec_id == declaring_spec_id && candidate.authored_id == authored_id
        })
        .map(|candidate| candidate.resolved_spec_id.clone())
        .collect()
}

fn direct_candidates(
    rows: &[Value],
    entries: &BTreeMap<String, RegistryEntry>,
    component: &str,
) -> Result<Vec<DirectCandidate>, StagedAstEnrichmentError> {
    rows.iter()
        .map(|row| {
            let row = row
                .as_object()
                .ok_or_else(|| StagedAstEnrichmentError::snapshot(component))?;
            let declaring_spec_id = required_string(row, "declaring_spec_id")?;
            let authored_id = required_string(row, "authored_id")?;
            let resolved_spec_id = required_string(row, "resolved_spec_id")?;
            if !valid_parser_identity(&declaring_spec_id)
                || !valid_parser_identity(&authored_id)
                || !entries.contains_key(&resolved_spec_id)
            {
                return Err(StagedAstEnrichmentError::snapshot(component));
            }
            Ok(DirectCandidate {
                declaring_spec_id,
                authored_id,
                resolved_spec_id,
            })
        })
        .collect()
}

fn ordered_candidates(
    rows: &[Value],
    entries: &BTreeMap<String, RegistryEntry>,
    identity_field: &str,
    component: &str,
) -> Result<Vec<OrderedCandidates>, StagedAstEnrichmentError> {
    let mut groups = rows
        .iter()
        .map(|row| {
            let row = row
                .as_object()
                .ok_or_else(|| StagedAstEnrichmentError::snapshot(component))?;
            let identity = required_string(row, identity_field)?;
            let order = positive_integer(row, "order")?;
            let candidates = required_array(row, "candidates")?
                .iter()
                .map(|candidate| {
                    let candidate = candidate
                        .as_object()
                        .ok_or_else(|| StagedAstEnrichmentError::snapshot(component))?;
                    let authored_id = required_string(candidate, "authored_id")?;
                    let resolved_spec_id = required_string(candidate, "resolved_spec_id")?;
                    if !valid_parser_identity(&authored_id)
                        || !entries.contains_key(&resolved_spec_id)
                    {
                        return Err(StagedAstEnrichmentError::snapshot(component));
                    }
                    Ok(Candidate {
                        authored_id,
                        resolved_spec_id,
                    })
                })
                .collect::<Result<Vec<_>, _>>()?;
            Ok(OrderedCandidates {
                identity,
                order,
                candidates,
            })
        })
        .collect::<Result<Vec<_>, _>>()?;
    groups.sort_by_key(|group| group.order);
    if groups.windows(2).any(|pair| pair[0].order == pair[1].order) {
        return Err(StagedAstEnrichmentError::snapshot(component));
    }
    Ok(groups)
}

fn required_array<'a>(
    object: &'a Map<String, Value>,
    field: &str,
) -> Result<&'a [Value], StagedAstEnrichmentError> {
    object
        .get(field)
        .and_then(Value::as_array)
        .map(Vec::as_slice)
        .ok_or_else(|| StagedAstEnrichmentError::snapshot(field))
}

fn required_string(
    object: &Map<String, Value>,
    field: &str,
) -> Result<String, StagedAstEnrichmentError> {
    object
        .get(field)
        .and_then(Value::as_str)
        .filter(|value| !value.is_empty())
        .map(str::to_owned)
        .ok_or_else(|| StagedAstEnrichmentError::snapshot(field))
}

fn required_top_rule(
    object: &Map<String, Value>,
    field: &str,
) -> Result<String, StagedAstEnrichmentError> {
    let top = required_string(object, field)?;
    valid_top_rule(&top)
        .then_some(top)
        .ok_or_else(|| StagedAstEnrichmentError::snapshot(field))
}

fn required_digest(
    object: &Map<String, Value>,
    field: &str,
) -> Result<String, StagedAstEnrichmentError> {
    let digest = required_string(object, field)?;
    valid_digest(&digest)
        .then_some(digest)
        .ok_or_else(|| StagedAstEnrichmentError::snapshot(field))
}

fn positive_integer(
    object: &Map<String, Value>,
    field: &str,
) -> Result<u64, StagedAstEnrichmentError> {
    object
        .get(field)
        .and_then(Value::as_u64)
        .filter(|value| *value > 0)
        .ok_or_else(|| StagedAstEnrichmentError::snapshot(field))
}

fn string_set(
    value: Option<&Value>,
    component: &str,
) -> Result<BTreeSet<String>, StagedAstEnrichmentError> {
    let values = value
        .and_then(Value::as_array)
        .ok_or_else(|| StagedAstEnrichmentError::snapshot(component))?;
    let mut normalized = BTreeSet::new();
    for value in values {
        let value = value
            .as_str()
            .filter(|value| !value.is_empty())
            .ok_or_else(|| StagedAstEnrichmentError::snapshot(component))?;
        normalized.insert(value.to_owned());
    }
    Ok(normalized)
}

fn value_strings(value: &Value) -> Vec<String> {
    value
        .as_array()
        .into_iter()
        .flatten()
        .filter_map(Value::as_str)
        .map(str::to_owned)
        .collect()
}

fn ceilings_from_value(value: &Value) -> Result<Ceilings, StagedAstEnrichmentError> {
    let object = value
        .as_object()
        .ok_or_else(|| StagedAstEnrichmentError::snapshot("ceilings"))?;
    let source_detail = required_string(object, "source_detail")?;
    source_detail_rank(&source_detail)?;
    Ok(Ceilings {
        source_detail,
        max_steps: positive_integer(object, "max_steps")?,
        max_result_nodes: positive_integer(object, "max_result_nodes")?,
        max_diagnostic_bytes: positive_integer(object, "max_diagnostic_bytes")?,
    })
}

fn versions_from_value(value: &Value) -> Result<Versions, StagedAstEnrichmentError> {
    let object = value
        .as_object()
        .ok_or_else(|| StagedAstEnrichmentError::snapshot("versions"))?;
    Ok(Versions {
        spec_language_version: positive_integer(object, "spec_language_version")?,
        helper_contract_version: required_string(object, "helper_contract_version")?,
        staged_contract_version: positive_integer(object, "staged_contract_version")?,
    })
}

fn source_detail_rank(value: &str) -> Result<usize, StagedAstEnrichmentError> {
    SOURCE_DETAILS
        .iter()
        .position(|candidate| *candidate == value)
        .ok_or_else(|| StagedAstEnrichmentError::snapshot("source_detail"))
}

fn valid_parser_identity(value: &str) -> bool {
    if value.is_empty() || value.starts_with('/') || value.contains("..") {
        return false;
    }
    let mut segment_start = true;
    for character in value.chars() {
        if matches!(character, '.' | '_' | ':' | '/' | '-') {
            if segment_start {
                return false;
            }
            segment_start = true;
        } else if character.is_ascii_lowercase() || (!segment_start && character.is_ascii_digit()) {
            segment_start = false;
        } else {
            return false;
        }
    }
    !segment_start
}

fn valid_top_rule(value: &str) -> bool {
    let mut chars = value.chars();
    chars
        .next()
        .is_some_and(|character| character == '_' || character.is_ascii_alphabetic())
        && chars.all(|character| character == '_' || character.is_ascii_alphanumeric())
}

fn valid_digest(value: &str) -> bool {
    value.strip_prefix("sha256:").is_some_and(|digest| {
        digest.len() == 64
            && digest
                .bytes()
                .all(|byte| byte.is_ascii_digit() || (b'a'..=b'f').contains(&byte))
    })
}

fn digest(value: &Value) -> String {
    let canonical = canonical_json(value);
    let bytes = Sha256::digest(canonical.as_bytes());
    let mut hex = String::with_capacity(64);
    for byte in bytes {
        write!(&mut hex, "{byte:02x}").expect("writing to String cannot fail");
    }
    format!("sha256:{hex}")
}

fn canonical_json(value: &Value) -> String {
    match value {
        Value::Null => "null".to_owned(),
        Value::Bool(value) => value.to_string(),
        Value::Number(value) => value.to_string(),
        Value::String(value) => serde_json::to_string(value).expect("JSON string serialization"),
        Value::Array(values) => format!(
            "[{}]",
            values
                .iter()
                .map(canonical_json)
                .collect::<Vec<_>>()
                .join(",")
        ),
        Value::Object(object) => {
            let mut fields = object.iter().collect::<Vec<_>>();
            fields.sort_by_key(|(key, _)| *key);
            let body = fields
                .into_iter()
                .map(|(key, value)| {
                    format!(
                        "{}:{}",
                        serde_json::to_string(key).expect("JSON key serialization"),
                        canonical_json(value)
                    )
                })
                .collect::<Vec<_>>()
                .join(",");
            format!("{{{body}}}")
        }
    }
}
