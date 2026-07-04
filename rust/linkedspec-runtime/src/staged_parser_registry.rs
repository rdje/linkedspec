//! Minimal staged parse-job registry and dispatcher.
//!
//! The first supported registry provider is the neutral
//! `actionir-body.spec` / `action_block` identity used by top-level
//! user-function body parse jobs. The implementation is a built-in adapter over
//! the existing ActionIR body parser, but the observable phases and result
//! records follow the language-neutral staged parsing contract.

use linkedspec_core::expr::CodeBlock;
use linkedspec_core::trace::{TraceConfig, TraceEmitter, TraceLevel};
use serde_json::{Map, Value, json};

const ACTIONIR_BODY_SPEC_ID: &str = "actionir-body.spec";
const ACTIONIR_BODY_TOP_RULE: &str = "action_block";
const ACTIONIR_BODY_RESOLVED_SPEC_ID: &str = "builtin:actionir-body.spec";
const ACTIONIR_BODY_ADAPTER_SOURCE: &str = "linkedspec:staged-parser/actionir-body:v1";
const ACTIONIR_BODY_ADAPTER_DIGEST: &str =
    "sha256:87ca81d966bb41f7025d31e4bae426af101e2ec75ff2ac14e96517d97fbbf55c";
const SPEC_LANGUAGE_VERSION: &str = "spec-language-v1";
const HELPER_ACTION_CONTRACT_VERSION: &str = "actionir-v1";
const STAGED_PARSING_CONTRACT_VERSION: &str = "staged-parsing-v1";

#[derive(Debug, Clone)]
struct StagedParseJob {
    job_id: String,
    parent_ast_path: Vec<String>,
    node_kind: String,
    payload_kind: String,
    text: String,
    source_span: Value,
    span_start: usize,
    span_end: usize,
    parser_spec_id: String,
    top_rule: String,
    result_policy: String,
    result_field: String,
    failure_policy: String,
}

#[derive(Debug, Clone)]
struct ResolvedParser {
    parser_spec_id: String,
    resolved_spec_id: String,
    provider: String,
}

#[derive(Debug, Clone)]
struct LoadedParser {
    parser_spec_id: String,
    resolved_spec_id: String,
    source_kind: String,
    adapter_contract: String,
    content_digest: String,
    import_graph_fingerprint: String,
}

#[derive(Debug, Clone)]
struct CompiledParser {
    parser_spec_id: String,
    resolved_spec_id: String,
    top_rule: String,
    source_kind: String,
    capabilities: Vec<String>,
    cache_key: Value,
}

/// Execute one staged parse job and return only its stitched parse result.
pub fn execute_parse_job(job: &Value) -> Result<Value, String> {
    let results = execute_parse_jobs(std::slice::from_ref(job))?;
    results
        .into_iter()
        .next()
        .and_then(|record| record.get("result").cloned())
        .ok_or_else(|| "staged parse dispatch produced no result".to_string())
}

/// Execute one staged parse job with explicit trace configuration.
pub fn execute_parse_job_with_trace(
    job: &Value,
    trace_config: TraceConfig,
) -> Result<Value, String> {
    let mut trace =
        TraceEmitter::new(trace_config).map_err(|err| format!("trace setup failed: {err}"))?;
    execute_parse_job_with_trace_emitter(job, &mut trace)
}

/// Execute one staged parse job with a caller-owned trace emitter.
pub fn execute_parse_job_with_trace_emitter(
    job: &Value,
    trace: &mut TraceEmitter,
) -> Result<Value, String> {
    let results = execute_parse_jobs_with_trace_emitter(std::slice::from_ref(job), trace)?;
    results
        .into_iter()
        .next()
        .and_then(|record| record.get("result").cloned())
        .ok_or_else(|| "staged parse dispatch produced no result".to_string())
}

/// Execute parse jobs through the minimal deterministic registry queue.
pub fn execute_parse_jobs(jobs: &[Value]) -> Result<Vec<Value>, String> {
    let mut queue = jobs
        .iter()
        .map(normalize_job)
        .collect::<Result<Vec<_>, _>>()?;
    queue.sort_by(compare_jobs);

    let mut results = Vec::new();
    for (queue_index, job) in queue.iter().enumerate() {
        let resolved = resolve(job)?;
        let loaded = load(&resolved)?;
        let compiled = compile(&loaded, &job.top_rule, None)?;
        let result = execute(&compiled, job)?;
        results.push(parse_result_record(
            queue_index,
            job,
            &resolved,
            &compiled,
            result,
        ));
    }
    Ok(results)
}

/// Execute parse jobs through the registry queue with explicit trace configuration.
pub fn execute_parse_jobs_with_trace(
    jobs: &[Value],
    trace_config: TraceConfig,
) -> Result<Vec<Value>, String> {
    let mut trace =
        TraceEmitter::new(trace_config).map_err(|err| format!("trace setup failed: {err}"))?;
    execute_parse_jobs_with_trace_emitter(jobs, &mut trace)
}

/// Execute parse jobs through the registry queue with a caller-owned trace emitter.
pub fn execute_parse_jobs_with_trace_emitter(
    jobs: &[Value],
    trace: &mut TraceEmitter,
) -> Result<Vec<Value>, String> {
    let scope = trace
        .enter_scope(
            "rust_runtime:staged_parser_registry:execute_parse_jobs",
            format!("jobs={}", jobs.len()),
            TraceLevel::LOW,
        )
        .map_err(trace_write_failed)?;
    let result = execute_parse_jobs_with_events(jobs, trace);
    let exit_details = match &result {
        Ok(results) => format!("status=ok results={}", results.len()),
        Err(err) => format!("status=error error={err}"),
    };
    trace
        .exit_scope(scope, exit_details)
        .map_err(trace_write_failed)?;
    result
}

fn execute_parse_jobs_with_events(
    jobs: &[Value],
    trace: &mut TraceEmitter,
) -> Result<Vec<Value>, String> {
    let mut queue = Vec::new();
    for (input_index, job) in jobs.iter().enumerate() {
        match normalize_job(job) {
            Ok(normalized) => {
                trace.trace_decision(
                    "rust_runtime:staged_parser_registry:normalize_job",
                    true,
                    format!(
                        "input_index={input_index} job_id={} parser_spec_id={} top_rule={} payload_kind={}",
                        normalized.job_id,
                        normalized.parser_spec_id,
                        normalized.top_rule,
                        normalized.payload_kind
                    ),
                    TraceLevel::MEDIUM,
                );
                queue.push(normalized);
            }
            Err(err) => {
                trace.trace_decision(
                    "rust_runtime:staged_parser_registry:normalize_job",
                    false,
                    format!("input_index={input_index} error={err}"),
                    TraceLevel::MEDIUM,
                );
                return Err(err);
            }
        }
    }
    queue.sort_by(compare_jobs);
    trace.trace_decision(
        "rust_runtime:staged_parser_registry:queue_sorted",
        true,
        format!("jobs={}", queue.len()),
        TraceLevel::MEDIUM,
    );

    let mut results = Vec::new();
    for (queue_index, job) in queue.iter().enumerate() {
        let job_scope = trace
            .enter_scope(
                "rust_runtime:staged_parser_registry:job",
                format!(
                    "queue_index={queue_index} job_id={} parent_ast_path={} parser_spec_id={} top_rule={}",
                    job.job_id,
                    parent_ast_path_text(job),
                    job.parser_spec_id,
                    job.top_rule
                ),
                TraceLevel::MEDIUM,
            )
            .map_err(trace_write_failed)?;
        let job_result = execute_one_parse_job_with_events(queue_index, job, trace);
        let exit_details = match &job_result {
            Ok(record) => format!(
                "status=ok job_id={} result_kind={}",
                job.job_id,
                record
                    .get("result")
                    .and_then(|result| result.get("kind"))
                    .and_then(Value::as_str)
                    .unwrap_or("<unknown>")
            ),
            Err(err) => format!("status=error job_id={} error={err}", job.job_id),
        };
        trace
            .exit_scope(job_scope, exit_details)
            .map_err(trace_write_failed)?;
        results.push(job_result?);
    }
    Ok(results)
}

fn execute_one_parse_job_with_events(
    queue_index: usize,
    job: &StagedParseJob,
    trace: &mut TraceEmitter,
) -> Result<Value, String> {
    let resolved = match resolve(job) {
        Ok(resolved) => {
            trace.trace_decision(
                "rust_runtime:staged_parser_registry:resolve",
                true,
                format!(
                    "job_id={} resolved_spec_id={} provider={}",
                    job.job_id, resolved.resolved_spec_id, resolved.provider
                ),
                TraceLevel::MEDIUM,
            );
            resolved
        }
        Err(err) => {
            trace.trace_decision(
                "rust_runtime:staged_parser_registry:resolve",
                false,
                format!("job_id={} error={err}", job.job_id),
                TraceLevel::MEDIUM,
            );
            return Err(err);
        }
    };
    let loaded = match load(&resolved) {
        Ok(loaded) => {
            trace.trace_decision(
                "rust_runtime:staged_parser_registry:load",
                true,
                format!(
                    "job_id={} source_kind={} digest={}",
                    job.job_id, loaded.source_kind, loaded.content_digest
                ),
                TraceLevel::MEDIUM,
            );
            loaded
        }
        Err(err) => {
            trace.trace_decision(
                "rust_runtime:staged_parser_registry:load",
                false,
                format!("job_id={} error={err}", job.job_id),
                TraceLevel::MEDIUM,
            );
            return Err(err);
        }
    };
    let compiled = match compile(&loaded, &job.top_rule, None) {
        Ok(compiled) => {
            trace.trace_decision(
                "rust_runtime:staged_parser_registry:compile",
                true,
                format!(
                    "job_id={} resolved_spec_id={} top_rule={} capabilities={}",
                    job.job_id,
                    compiled.resolved_spec_id,
                    compiled.top_rule,
                    compiled.capabilities.join(",")
                ),
                TraceLevel::MEDIUM,
            );
            compiled
        }
        Err(err) => {
            trace.trace_decision(
                "rust_runtime:staged_parser_registry:compile",
                false,
                format!("job_id={} error={err}", job.job_id),
                TraceLevel::MEDIUM,
            );
            return Err(err);
        }
    };
    let result = match execute(&compiled, job) {
        Ok(result) => {
            trace.trace_decision(
                "rust_runtime:staged_parser_registry:execute",
                true,
                format!(
                    "job_id={} resolved_spec_id={} payload_bytes={}",
                    job.job_id,
                    compiled.resolved_spec_id,
                    job.text.len()
                ),
                TraceLevel::MEDIUM,
            );
            result
        }
        Err(err) => {
            trace.trace_decision(
                "rust_runtime:staged_parser_registry:execute",
                false,
                format!("job_id={} error={err}", job.job_id),
                TraceLevel::MEDIUM,
            );
            return Err(err);
        }
    };
    Ok(parse_result_record(
        queue_index,
        job,
        &resolved,
        &compiled,
        result,
    ))
}

fn parent_ast_path_text(job: &StagedParseJob) -> String {
    if job.parent_ast_path.is_empty() {
        "<unknown>".to_string()
    } else {
        job.parent_ast_path.join(".")
    }
}

fn trace_write_failed(err: impl std::fmt::Display) -> String {
    format!("trace write failed: {err}")
}

fn resolve(job: &StagedParseJob) -> Result<ResolvedParser, String> {
    if job.parser_spec_id != ACTIONIR_BODY_SPEC_ID {
        return Err(dispatch_error(
            "resolve",
            job,
            None,
            format!("unsupported parser spec id '{}'", job.parser_spec_id),
        ));
    }
    Ok(ResolvedParser {
        parser_spec_id: job.parser_spec_id.clone(),
        resolved_spec_id: ACTIONIR_BODY_RESOLVED_SPEC_ID.to_string(),
        provider: "builtin".to_string(),
    })
}

fn load(resolved: &ResolvedParser) -> Result<LoadedParser, String> {
    if resolved.resolved_spec_id != ACTIONIR_BODY_RESOLVED_SPEC_ID {
        let placeholder = placeholder_job(&resolved.parser_spec_id, ACTIONIR_BODY_TOP_RULE);
        return Err(dispatch_error(
            "load",
            &placeholder,
            Some(&resolved.resolved_spec_id),
            format!(
                "unsupported resolved spec id '{}'",
                resolved.resolved_spec_id
            ),
        ));
    }
    Ok(LoadedParser {
        parser_spec_id: resolved.parser_spec_id.clone(),
        resolved_spec_id: resolved.resolved_spec_id.clone(),
        source_kind: "builtin_adapter".to_string(),
        adapter_contract: ACTIONIR_BODY_ADAPTER_SOURCE.to_string(),
        content_digest: ACTIONIR_BODY_ADAPTER_DIGEST.to_string(),
        import_graph_fingerprint: "none".to_string(),
    })
}

fn compile(
    loaded: &LoadedParser,
    top_rule: &str,
    capability_set: Option<&[String]>,
) -> Result<CompiledParser, String> {
    let placeholder = placeholder_job(&loaded.parser_spec_id, top_rule);
    if loaded.resolved_spec_id != ACTIONIR_BODY_RESOLVED_SPEC_ID {
        return Err(dispatch_error(
            "compile",
            &placeholder,
            Some(&loaded.resolved_spec_id),
            format!("unsupported resolved spec id '{}'", loaded.resolved_spec_id),
        ));
    }
    if top_rule != ACTIONIR_BODY_TOP_RULE {
        return Err(dispatch_error(
            "compile",
            &placeholder,
            Some(&loaded.resolved_spec_id),
            format!("unsupported top rule '{top_rule}'"),
        ));
    }
    let capabilities = normalize_capability_set(capability_set);
    let cache_key = cache_key(loaded, top_rule, &capabilities);
    Ok(CompiledParser {
        parser_spec_id: loaded.parser_spec_id.clone(),
        resolved_spec_id: loaded.resolved_spec_id.clone(),
        top_rule: top_rule.to_string(),
        source_kind: loaded.source_kind.clone(),
        capabilities,
        cache_key,
    })
}

fn execute(compiled: &CompiledParser, job: &StagedParseJob) -> Result<Value, String> {
    if compiled.resolved_spec_id != ACTIONIR_BODY_RESOLVED_SPEC_ID
        || compiled.top_rule != ACTIONIR_BODY_TOP_RULE
    {
        return Err(dispatch_error(
            "execute",
            job,
            Some(&compiled.resolved_spec_id),
            "compiled parser identity is unsupported".to_string(),
        ));
    }
    let block = CodeBlock::parse(&job.text).map_err(|err| {
        dispatch_error(
            "execute",
            job,
            Some(&compiled.resolved_spec_id),
            format!("action block parse failed: {err}"),
        )
    })?;
    action_block_to_value(block).map_err(|err| {
        dispatch_error(
            "execute",
            job,
            Some(&compiled.resolved_spec_id),
            format!("action block serialization failed: {err}"),
        )
    })
}

fn parse_result_record(
    queue_index: usize,
    job: &StagedParseJob,
    resolved: &ResolvedParser,
    compiled: &CompiledParser,
    result: Value,
) -> Value {
    json!({
        "kind": "staged_parse_result",
        "version": 1,
        "stage_depth": 1,
        "queue_index": queue_index,
        "phases": ["resolve", "load", "compile", "execute"],
        "job_id": job.job_id.clone(),
        "parent_ast_path": job.parent_ast_path.clone(),
        "parser_spec_id": job.parser_spec_id.clone(),
        "resolved_spec_id": resolved.resolved_spec_id.clone(),
        "registry_provider": resolved.provider.clone(),
        "top_rule": job.top_rule.clone(),
        "node_kind": job.node_kind.clone(),
        "payload_kind": job.payload_kind.clone(),
        "source_span": job.source_span.clone(),
        "result_policy": job.result_policy.clone(),
        "result_field": job.result_field.clone(),
        "failure_policy": job.failure_policy.clone(),
        "cache_key": compiled.cache_key.clone(),
        "compiled_parser": {
            "kind": "staged_compiled_parser",
            "version": 1,
            "parser_spec_id": compiled.parser_spec_id.clone(),
            "resolved_spec_id": compiled.resolved_spec_id.clone(),
            "top_rule": compiled.top_rule.clone(),
            "source_kind": compiled.source_kind.clone(),
            "capabilities": compiled.capabilities.clone(),
        },
        "result": result,
    })
}

fn action_block_to_value(block: CodeBlock) -> Result<Value, serde_json::Error> {
    let mut value = serde_json::to_value(block)?;
    if let Value::Object(ref mut object) = value {
        object.insert(
            "kind".to_string(),
            Value::String("action_block".to_string()),
        );
        if let Some(Value::Array(statements)) = object.get_mut("statements") {
            for statement in statements {
                if let Value::Object(statement_object) = statement {
                    statement_object
                        .insert("kind".to_string(), Value::String("action_stmt".to_string()));
                    statement_object.insert("drops_value".to_string(), Value::Bool(true));
                }
            }
        }
    }
    Ok(value)
}

fn cache_key(loaded: &LoadedParser, top_rule: &str, capabilities: &[String]) -> Value {
    let capability_text = capabilities.join(",");
    let fingerprint = [
        loaded.resolved_spec_id.as_str(),
        loaded.content_digest.as_str(),
        loaded.import_graph_fingerprint.as_str(),
        top_rule,
        SPEC_LANGUAGE_VERSION,
        HELPER_ACTION_CONTRACT_VERSION,
        STAGED_PARSING_CONTRACT_VERSION,
        capability_text.as_str(),
    ]
    .join("|");
    json!({
        "kind": "staged_parser_cache_key",
        "version": 1,
        "normalized_spec_identity": loaded.resolved_spec_id.clone(),
        "content_digest": loaded.content_digest.clone(),
        "import_graph_fingerprint": loaded.import_graph_fingerprint.clone(),
        "top_rule": top_rule,
        "spec_language_version": SPEC_LANGUAGE_VERSION,
        "helper_action_contract_version": HELPER_ACTION_CONTRACT_VERSION,
        "staged_parsing_contract_version": STAGED_PARSING_CONTRACT_VERSION,
        "backend_capabilities": capabilities,
        "fingerprint": fingerprint,
        "source_kind": loaded.source_kind.clone(),
        "adapter_contract": loaded.adapter_contract.clone(),
    })
}

fn normalize_job(value: &Value) -> Result<StagedParseJob, String> {
    let object = value
        .as_object()
        .ok_or_else(|| "staged parse job must be a JSON object".to_string())?;
    assert_string_field(object, "kind", "parse_job")?;
    let job_id = string_field(object, "job_id")?.to_string();
    if job_id.is_empty() {
        return Err("staged parse job job_id must be non-empty".to_string());
    }
    let parent_ast_path = string_array_field(object, "parent_ast_path")?;
    let source_span = object
        .get("source_span")
        .cloned()
        .ok_or_else(|| "staged parse job is missing source_span".to_string())?;
    let source_span_object = source_span
        .as_object()
        .ok_or_else(|| "staged parse job source_span must be an object".to_string())?;
    let span_start = usize_field(source_span_object, "start")?;
    let span_end = usize_field(source_span_object, "end")?;
    let line_start = usize_field(source_span_object, "line_start")?;
    let line_end = usize_field(source_span_object, "line_end")?;
    if span_start > span_end || line_start == 0 || line_start > line_end {
        return Err("staged parse job source_span has invalid range".to_string());
    }

    Ok(StagedParseJob {
        job_id,
        parent_ast_path,
        node_kind: string_field(object, "node_kind")?.to_string(),
        payload_kind: string_field(object, "payload_kind")?.to_string(),
        text: string_field(object, "text")?.to_string(),
        source_span,
        span_start,
        span_end,
        parser_spec_id: string_field(object, "parser_spec_id")?.to_string(),
        top_rule: string_field(object, "top_rule")?.to_string(),
        result_policy: string_field(object, "result_policy")?.to_string(),
        result_field: string_field(object, "result_field")?.to_string(),
        failure_policy: string_field(object, "failure_policy")?.to_string(),
    })
}

fn compare_jobs(left: &StagedParseJob, right: &StagedParseJob) -> std::cmp::Ordering {
    left.parent_ast_path
        .cmp(&right.parent_ast_path)
        .then(left.span_start.cmp(&right.span_start))
        .then(left.span_end.cmp(&right.span_end))
        .then(left.job_id.cmp(&right.job_id))
}

fn normalize_capability_set(capability_set: Option<&[String]>) -> Vec<String> {
    let Some(capability_set) = capability_set else {
        return vec!["actionir_ast_v1".to_string()];
    };
    let mut capabilities = Vec::new();
    for capability in capability_set {
        if !capability.is_empty() && !capabilities.contains(capability) {
            capabilities.push(capability.clone());
        }
    }
    if capabilities.is_empty() {
        capabilities.push("actionir_ast_v1".to_string());
    }
    capabilities
}

fn placeholder_job(parser_spec_id: &str, top_rule: &str) -> StagedParseJob {
    StagedParseJob {
        job_id: "<unknown>".to_string(),
        parent_ast_path: Vec::new(),
        node_kind: "<unknown>".to_string(),
        payload_kind: "<unknown>".to_string(),
        text: String::new(),
        source_span: json!({"start": 0, "end": 0, "line_start": 1, "line_end": 1}),
        span_start: 0,
        span_end: 0,
        parser_spec_id: parser_spec_id.to_string(),
        top_rule: top_rule.to_string(),
        result_policy: "<unknown>".to_string(),
        result_field: "<unknown>".to_string(),
        failure_policy: "<unknown>".to_string(),
    }
}

fn dispatch_error(
    phase: &str,
    job: &StagedParseJob,
    resolved_spec_id: Option<&str>,
    detail: String,
) -> String {
    let parent_path = job.parent_ast_path.join(".");
    let span = format!("{}-{}", job.span_start, job.span_end);
    format!(
        "staged parse dispatch failed: phase={phase}; job_id={}; parent_ast_path={}; parser_spec_id={}; resolved_spec_id={}; top_rule={}; payload_kind={}; source_span={}; failure_policy={}; detail={detail}",
        job.job_id,
        if parent_path.is_empty() {
            "<unknown>"
        } else {
            &parent_path
        },
        job.parser_spec_id,
        resolved_spec_id.unwrap_or("<unresolved>"),
        job.top_rule,
        job.payload_kind,
        span,
        job.failure_policy,
    )
}

fn assert_string_field(
    object: &Map<String, Value>,
    field: &str,
    expected: &str,
) -> Result<(), String> {
    let actual = string_field(object, field)?;
    if actual == expected {
        Ok(())
    } else {
        Err(format!(
            "staged parse job expected {field}='{expected}', got '{actual}'"
        ))
    }
}

fn string_field<'a>(object: &'a Map<String, Value>, field: &str) -> Result<&'a str, String> {
    object
        .get(field)
        .and_then(Value::as_str)
        .ok_or_else(|| format!("staged parse job is missing string field '{field}'"))
}

fn string_array_field(object: &Map<String, Value>, field: &str) -> Result<Vec<String>, String> {
    let values = object
        .get(field)
        .and_then(Value::as_array)
        .ok_or_else(|| format!("staged parse job is missing array field '{field}'"))?;
    values
        .iter()
        .enumerate()
        .map(|(idx, value)| {
            value.as_str().map(str::to_string).ok_or_else(|| {
                format!("staged parse job field '{field}' item {idx} is not a string")
            })
        })
        .collect()
}

fn usize_field(object: &Map<String, Value>, field: &str) -> Result<usize, String> {
    let value = object
        .get(field)
        .ok_or_else(|| format!("staged parse job is missing numeric field '{field}'"))?;
    if let Some(n) = value.as_u64() {
        return usize::try_from(n)
            .map_err(|_| format!("staged parse job field '{field}' is too large"));
    }
    if let Some(n) = value.as_f64() {
        if n.is_finite() && n >= 0.0 && n.fract() == 0.0 {
            return Ok(n as usize);
        }
    }
    Err(format!(
        "staged parse job field '{field}' must be a non-negative integer"
    ))
}
