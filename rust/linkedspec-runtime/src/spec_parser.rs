//! Runtime-level `.spec` parser entrypoint.
//!
//! `linkedspec-core::parser::parse_spec` deliberately parses rule paragraphs
//! only. Top-level user-function definitions are parsed here by executing the
//! language-neutral `specs/user_function_definition.spec` parser and consuming
//! its returned AST.

use crate::engine::Engine;
use crate::staged_parser_registry;
use linkedspec_core::ast::{FunctionDefinition, SourceSpan, SpecFile};
use linkedspec_core::compiler::{compile, compile_with_trace_emitter};
use linkedspec_core::parser::{parse_spec, parse_spec_with_trace_emitter};
use linkedspec_core::trace::{TraceConfig, TraceEmitter, TraceLevel};
use linkedspec_core::validation::{validate, validate_with_trace_emitter};
use serde_json::{Map, Value};

const USER_FUNCTION_DEFINITION_SPEC: &str =
    include_str!("../../../specs/user_function_definition.spec");

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
struct AstSpan {
    start: usize,
    end: usize,
    line_start: usize,
    line_end: usize,
}

/// Parse a full LinkedSpec source string, including top-level user-function
/// definitions, without hand-parsing that DSL in Rust.
pub fn parse_spec_with_user_functions(source: &str) -> Result<SpecFile, String> {
    let nodes = parse_user_function_definition_asts(source)?;
    let (functions, spans) = function_definitions_from_nodes(&nodes, source, None)?;

    let stripped = strip_function_definition_spans(source, &spans)?;
    let mut spec = parse_spec(&stripped)
        .map_err(|err| format!("rule parse after function extraction failed: {err}"))?;
    spec.functions = functions;
    Ok(spec)
}

/// Parse a full LinkedSpec source string with explicit trace configuration.
pub fn parse_spec_with_user_functions_with_trace(
    source: &str,
    trace_config: TraceConfig,
) -> Result<SpecFile, String> {
    let mut trace =
        TraceEmitter::new(trace_config).map_err(|err| format!("trace setup failed: {err}"))?;
    parse_spec_with_user_functions_with_trace_emitter(source, &mut trace)
}

/// Parse a full LinkedSpec source string with a caller-owned trace emitter.
pub fn parse_spec_with_user_functions_with_trace_emitter(
    source: &str,
    trace: &mut TraceEmitter,
) -> Result<SpecFile, String> {
    let scope = trace
        .enter_scope(
            "rust_runtime:parse_spec_with_user_functions",
            format!("bytes={} lines={}", source.len(), source.lines().count()),
            TraceLevel::LOW,
        )
        .map_err(trace_write_failed)?;
    let result = (|| {
        let nodes = parse_user_function_definition_asts_with_trace_emitter(source, trace)?;
        trace.trace_decision(
            "rust_runtime:parse_spec_with_user_functions:user_definition_nodes",
            true,
            format!("nodes={}", nodes.len()),
            TraceLevel::MEDIUM,
        );
        let (functions, spans) = function_definitions_from_nodes(&nodes, source, Some(trace))?;
        trace.trace_decision(
            "rust_runtime:parse_spec_with_user_functions:functions_projected",
            true,
            format!("functions={} spans={}", functions.len(), spans.len()),
            TraceLevel::MEDIUM,
        );

        let stripped = strip_function_definition_spans(source, &spans)?;
        trace.trace_decision(
            "rust_runtime:parse_spec_with_user_functions:strip_function_definitions",
            true,
            format!(
                "source_bytes={} stripped_bytes={}",
                source.len(),
                stripped.len()
            ),
            TraceLevel::MEDIUM,
        );
        let mut spec = parse_spec_with_trace_emitter(&stripped, trace)
            .map_err(|err| format!("rule parse after function extraction failed: {err}"))?;
        spec.functions = functions;
        Ok(spec)
    })();
    let exit_details = match &result {
        Ok(spec) => format!(
            "status=ok rules={} functions={}",
            spec.rules.len(),
            spec.functions.len()
        ),
        Err(err) => format!("status=error error={err}"),
    };
    trace
        .exit_scope(scope, exit_details)
        .map_err(trace_write_failed)?;
    result
}

fn function_definitions_from_nodes(
    nodes: &[Value],
    source: &str,
    mut trace: Option<&mut TraceEmitter>,
) -> Result<(Vec<FunctionDefinition>, Vec<AstSpan>), String> {
    let mut functions = Vec::new();
    let mut spans = Vec::new();

    for (idx, node) in nodes.iter().enumerate() {
        let object = as_object(node, &format!("definition node {idx}"))?;
        match string_field(object, "type", "definition node")? {
            "function_definition" => {
                let (function, source_span) =
                    function_from_ast(object, source, idx, trace.as_deref_mut())?;
                spans.push(source_span);
                functions.push(function);
            }
            "function_definition_error" => {
                return Err(function_error_message(object, idx));
            }
            other => {
                return Err(format!(
                    "user_function_definition.spec returned unsupported node type '{other}' at index {idx}"
                ));
            }
        }
    }

    Ok((functions, spans))
}

/// Return the raw AST nodes produced by `specs/user_function_definition.spec`.
/// This is public for tests and for backend parity probes that need to validate
/// the spec parser contract directly.
pub fn parse_user_function_definition_asts(source: &str) -> Result<Vec<Value>, String> {
    let parser_spec = parse_spec(USER_FUNCTION_DEFINITION_SPEC)
        .map_err(|err| format!("failed to parse user_function_definition.spec: {err}"))?;
    validate(&parser_spec)
        .map_err(|err| format!("failed to validate user_function_definition.spec: {err}"))?;
    let compiled = compile(&parser_spec)
        .map_err(|err| format!("failed to compile user_function_definition.spec: {err}"))?;
    let output = Engine::new(compiled)
        .execute(source)
        .map_err(|err| format!("user_function_definition.spec execution failed: {err}"))?;
    definition_nodes_from_output(&output)
}

/// Return raw user-function AST nodes with explicit trace configuration.
pub fn parse_user_function_definition_asts_with_trace(
    source: &str,
    trace_config: TraceConfig,
) -> Result<Vec<Value>, String> {
    let mut trace =
        TraceEmitter::new(trace_config).map_err(|err| format!("trace setup failed: {err}"))?;
    parse_user_function_definition_asts_with_trace_emitter(source, &mut trace)
}

/// Return raw user-function AST nodes with a caller-owned trace emitter.
pub fn parse_user_function_definition_asts_with_trace_emitter(
    source: &str,
    trace: &mut TraceEmitter,
) -> Result<Vec<Value>, String> {
    let scope = trace
        .enter_scope(
            "rust_runtime:parse_user_function_definition_asts",
            format!("bytes={} lines={}", source.len(), source.lines().count()),
            TraceLevel::LOW,
        )
        .map_err(trace_write_failed)?;
    let result = (|| {
        let parser_spec = match parse_spec_with_trace_emitter(USER_FUNCTION_DEFINITION_SPEC, trace)
        {
            Ok(parser_spec) => {
                trace.trace_decision(
                    "rust_runtime:parse_user_function_definition_asts:parse_parser_spec",
                    true,
                    format!("rules={}", parser_spec.rules.len()),
                    TraceLevel::MEDIUM,
                );
                parser_spec
            }
            Err(err) => {
                trace.trace_decision(
                    "rust_runtime:parse_user_function_definition_asts:parse_parser_spec",
                    false,
                    format!("error={err}"),
                    TraceLevel::MEDIUM,
                );
                return Err(format!(
                    "failed to parse user_function_definition.spec: {err}"
                ));
            }
        };
        if let Err(err) = validate_with_trace_emitter(&parser_spec, trace) {
            trace.trace_decision(
                "rust_runtime:parse_user_function_definition_asts:validate_parser_spec",
                false,
                format!("error={err}"),
                TraceLevel::MEDIUM,
            );
            return Err(format!(
                "failed to validate user_function_definition.spec: {err}"
            ));
        }
        trace.trace_decision(
            "rust_runtime:parse_user_function_definition_asts:validate_parser_spec",
            true,
            "pass",
            TraceLevel::MEDIUM,
        );

        let compiled = match compile_with_trace_emitter(&parser_spec, trace) {
            Ok(compiled) => {
                trace.trace_decision(
                    "rust_runtime:parse_user_function_definition_asts:compile_parser_spec",
                    true,
                    format!("rules={}", compiled.rules.len()),
                    TraceLevel::MEDIUM,
                );
                compiled
            }
            Err(err) => {
                trace.trace_decision(
                    "rust_runtime:parse_user_function_definition_asts:compile_parser_spec",
                    false,
                    format!("error={err}"),
                    TraceLevel::MEDIUM,
                );
                return Err(format!(
                    "failed to compile user_function_definition.spec: {err}"
                ));
            }
        };
        let output = match Engine::new(compiled).execute_with_trace_emitter(source, trace) {
            Ok(output) => {
                trace.trace_decision(
                    "rust_runtime:parse_user_function_definition_asts:execute_parser_spec",
                    true,
                    "output=ok",
                    TraceLevel::MEDIUM,
                );
                output
            }
            Err(err) => {
                trace.trace_decision(
                    "rust_runtime:parse_user_function_definition_asts:execute_parser_spec",
                    false,
                    format!("error={err}"),
                    TraceLevel::MEDIUM,
                );
                return Err(format!(
                    "user_function_definition.spec execution failed: {err}"
                ));
            }
        };
        let nodes = definition_nodes_from_output(&output)?;
        trace.trace_decision(
            "rust_runtime:parse_user_function_definition_asts:definition_nodes",
            true,
            format!("nodes={}", nodes.len()),
            TraceLevel::MEDIUM,
        );
        Ok(nodes)
    })();
    let exit_details = match &result {
        Ok(nodes) => format!("status=ok nodes={}", nodes.len()),
        Err(err) => format!("status=error error={err}"),
    };
    trace
        .exit_scope(scope, exit_details)
        .map_err(trace_write_failed)?;
    result
}

fn function_from_ast(
    object: &Map<String, Value>,
    full_source: &str,
    idx: usize,
    trace: Option<&mut TraceEmitter>,
) -> Result<(FunctionDefinition, AstSpan), String> {
    assert_string_field(object, "kind", "user_function_definition", idx)?;
    usize_field(object, "version", idx)?;

    let name = string_field(object, "name", "function_definition")?.to_string();
    if !is_identifier(&name) {
        return Err(format!(
            "function_definition node {idx} has invalid name '{name}'"
        ));
    }

    let params = string_array_field(object, "params", idx)?;
    for param in &params {
        if !is_identifier(param) {
            return Err(format!(
                "function_definition node {idx} has invalid parameter '{param}'"
            ));
        }
    }

    let arity = usize_field(object, "arity", idx)?;
    if arity != params.len() {
        return Err(format!(
            "function_definition node {idx} arity {arity} does not match {} params",
            params.len()
        ));
    }

    let source_text = string_field(object, "source_text", "function_definition")?.to_string();
    let source_span = span_field(object, "source_span", idx)?;
    validate_span_text(full_source, source_span, &source_text, "source_text", idx)?;

    let body_source = string_field(object, "body_source", "function_definition")?.to_string();
    let body_span = span_field(object, "body_span", idx)?;
    validate_span_text(full_source, body_span, &body_source, "body_source", idx)?;
    if !(source_span.start <= body_span.start
        && body_span.start <= body_span.end
        && body_span.end <= source_span.end)
    {
        return Err(format!(
            "function_definition node {idx} body span is outside source span"
        ));
    }

    let mut body_payload = object
        .get("body_payload")
        .cloned()
        .ok_or_else(|| format!("function_definition node {idx} is missing body_payload"))?;
    validate_body_payload(
        &body_payload,
        &name,
        &params,
        arity,
        &body_source,
        body_span,
        idx,
    )?;
    normalize_parent_ast_path(&mut body_payload, idx, "body_payload")?;

    let mut body_parse_job = object
        .get("body_parse_job")
        .cloned()
        .ok_or_else(|| format!("function_definition node {idx} is missing body_parse_job"))?;
    validate_body_parse_job(
        &body_parse_job,
        &name,
        &params,
        arity,
        &body_source,
        body_span,
        idx,
    )?;
    normalize_body_parse_job(&mut body_parse_job, idx, body_span)?;
    let body_ast = if let Some(trace) = trace {
        staged_parser_registry::execute_parse_job_with_trace_emitter(&body_parse_job, trace)
    } else {
        staged_parser_registry::execute_parse_job(&body_parse_job)
    }
    .map_err(|err| {
        format!("function_definition node {idx} body_parse_job dispatch failed: {err}")
    })?;

    Ok((
        FunctionDefinition {
            name,
            params,
            arity,
            body_source,
            body_payload: Some(body_payload),
            body_parse_job: Some(body_parse_job),
            body_ast: Some(body_ast),
            source: source_text,
            source_span: SourceSpan {
                line_start: source_span.line_start,
                line_end: source_span.line_end,
            },
            body_span: SourceSpan {
                line_start: body_span.line_start,
                line_end: body_span.line_end,
            },
        },
        source_span,
    ))
}

fn trace_write_failed(err: impl std::fmt::Display) -> String {
    format!("trace write failed: {err}")
}

fn definition_nodes_from_output(output: &Value) -> Result<Vec<Value>, String> {
    match output {
        Value::Null => Ok(Vec::new()),
        Value::Array(items) if items.is_empty() => Ok(Vec::new()),
        Value::Array(items) if items.iter().all(Value::is_object) => Ok(items.clone()),
        Value::Array(items) if items.len() == 1 => definition_nodes_from_output(&items[0]),
        Value::Array(items) if items.iter().all(Value::is_array) => {
            let mut nodes = Vec::new();
            for item in items {
                nodes.extend(definition_nodes_from_output(item)?);
            }
            Ok(nodes)
        }
        other => Err(format!(
            "user_function_definition.spec returned unsupported output shape: {other}"
        )),
    }
}

fn strip_function_definition_spans(source: &str, spans: &[AstSpan]) -> Result<String, String> {
    if spans.is_empty() {
        return Ok(source.to_string());
    }

    let char_len = source.chars().count();
    let mut sorted = spans.to_vec();
    sorted.sort_by_key(|span| span.start);
    let mut previous_end = 0;
    for span in &sorted {
        if span.start > span.end || span.end > char_len {
            return Err(format!(
                "function definition span {}..{} is outside source length {char_len}",
                span.start, span.end
            ));
        }
        if span.start < previous_end {
            return Err(format!(
                "function definition spans overlap at {}..{}",
                span.start, span.end
            ));
        }
        previous_end = span.end;
    }

    let mut out = String::with_capacity(source.len());
    let mut span_idx = 0;
    for (char_idx, ch) in source.chars().enumerate() {
        while span_idx < sorted.len() && char_idx >= sorted[span_idx].end {
            span_idx += 1;
        }
        let inside_span = span_idx < sorted.len()
            && char_idx >= sorted[span_idx].start
            && char_idx < sorted[span_idx].end;
        if inside_span && ch != '\n' && ch != '\r' {
            out.push(' ');
        } else {
            out.push(ch);
        }
    }
    Ok(out)
}

fn validate_body_payload(
    payload: &Value,
    name: &str,
    params: &[String],
    arity: usize,
    body_source: &str,
    body_span: AstSpan,
    idx: usize,
) -> Result<(), String> {
    let object = as_object(
        payload,
        &format!("function_definition node {idx} body_payload"),
    )?;
    assert_string_field(object, "kind", "staged_payload", idx)?;
    assert_string_field(object, "node_kind", "function_definition", idx)?;
    assert_string_field(object, "payload_kind", "function_body", idx)?;
    validate_function_body_parent_path(object, "body_payload", idx)?;
    if string_field(object, "function_name", "body_payload")? != name {
        return Err(format!(
            "function_definition node {idx} body_payload function_name does not match name"
        ));
    }
    if string_array_field(object, "params", idx)? != params {
        return Err(format!(
            "function_definition node {idx} body_payload params do not match params"
        ));
    }
    if usize_field(object, "arity", idx)? != arity {
        return Err(format!(
            "function_definition node {idx} body_payload arity does not match arity"
        ));
    }
    if string_field(object, "text", "body_payload")? != body_source {
        return Err(format!(
            "function_definition node {idx} body_payload text does not match body_source"
        ));
    }
    let payload_span = span_field(object, "source_span", idx)?;
    if payload_span != body_span {
        return Err(format!(
            "function_definition node {idx} body_payload source_span does not match body_span"
        ));
    }
    Ok(())
}

fn validate_body_parse_job(
    job: &Value,
    name: &str,
    params: &[String],
    arity: usize,
    body_source: &str,
    body_span: AstSpan,
    idx: usize,
) -> Result<(), String> {
    let object = as_object(
        job,
        &format!("function_definition node {idx} body_parse_job"),
    )?;
    assert_string_field(object, "kind", "parse_job", idx)?;
    assert_string_field(object, "node_kind", "function_definition", idx)?;
    assert_string_field(object, "payload_kind", "function_body", idx)?;
    validate_function_body_parent_path(object, "body_parse_job", idx)?;
    if string_field(object, "job_id", "body_parse_job")?.is_empty() {
        return Err(format!(
            "function_definition node {idx} body_parse_job job_id must be non-empty"
        ));
    }
    if string_field(object, "function_name", "body_parse_job")? != name {
        return Err(format!(
            "function_definition node {idx} body_parse_job function_name does not match name"
        ));
    }
    if string_array_field(object, "params", idx)? != params {
        return Err(format!(
            "function_definition node {idx} body_parse_job params do not match params"
        ));
    }
    if usize_field(object, "arity", idx)? != arity {
        return Err(format!(
            "function_definition node {idx} body_parse_job arity does not match arity"
        ));
    }
    if string_field(object, "text", "body_parse_job")? != body_source {
        return Err(format!(
            "function_definition node {idx} body_parse_job text does not match body_source"
        ));
    }
    let job_span = span_field(object, "source_span", idx)?;
    if job_span != body_span {
        return Err(format!(
            "function_definition node {idx} body_parse_job source_span does not match body_span"
        ));
    }
    if string_field(object, "parser_spec_id", "body_parse_job")? != "actionir-body.spec" {
        return Err(format!(
            "function_definition node {idx} body_parse_job parser_spec_id must be actionir-body.spec"
        ));
    }
    if string_field(object, "top_rule", "body_parse_job")? != "action_block" {
        return Err(format!(
            "function_definition node {idx} body_parse_job top_rule must be action_block"
        ));
    }
    if string_field(object, "result_policy", "body_parse_job")? != "replace_field" {
        return Err(format!(
            "function_definition node {idx} body_parse_job result_policy must be replace_field"
        ));
    }
    if string_field(object, "result_field", "body_parse_job")? != "body_ast" {
        return Err(format!(
            "function_definition node {idx} body_parse_job result_field must be body_ast"
        ));
    }
    if string_field(object, "failure_policy", "body_parse_job")? != "fail" {
        return Err(format!(
            "function_definition node {idx} body_parse_job failure_policy must be fail"
        ));
    }
    if string_field(object, "diagnostic_owner", "body_parse_job")? != "function_body" {
        return Err(format!(
            "function_definition node {idx} body_parse_job diagnostic_owner must be function_body"
        ));
    }
    Ok(())
}

fn validate_function_body_parent_path(
    object: &Map<String, Value>,
    context: &str,
    idx: usize,
) -> Result<(), String> {
    let path = string_array_field(object, "parent_ast_path", idx)?;
    if path.len() != 3 || path[0] != "functions" || path[2] != "body_source" {
        return Err(format!(
            "function_definition node {idx} {context} parent_ast_path must target functions[*].body_source"
        ));
    }
    Ok(())
}

fn normalize_parent_ast_path(value: &mut Value, idx: usize, context: &str) -> Result<(), String> {
    let object = value
        .as_object_mut()
        .ok_or_else(|| format!("function_definition node {idx} {context} must be a JSON object"))?;
    object.insert(
        "parent_ast_path".to_string(),
        Value::Array(vec![
            Value::String("functions".to_string()),
            Value::String(idx.to_string()),
            Value::String("body_source".to_string()),
        ]),
    );
    Ok(())
}

fn normalize_body_parse_job(job: &mut Value, idx: usize, body_span: AstSpan) -> Result<(), String> {
    normalize_parent_ast_path(job, idx, "body_parse_job")?;
    let object = job.as_object_mut().ok_or_else(|| {
        format!("function_definition node {idx} body_parse_job must be a JSON object")
    })?;
    object.insert(
        "job_id".to_string(),
        Value::String(body_parse_job_id(idx, body_span)),
    );
    Ok(())
}

fn body_parse_job_id(idx: usize, body_span: AstSpan) -> String {
    format!(
        "parse_job:function_body:functions.{idx}.body_source:actionir-body.spec:action_block:{}-{}",
        body_span.start, body_span.end
    )
}

fn validate_span_text(
    source: &str,
    span: AstSpan,
    expected: &str,
    field: &str,
    idx: usize,
) -> Result<(), String> {
    let actual = char_slice(source, span.start, span.end).ok_or_else(|| {
        format!(
            "function_definition node {idx} {field} span {}..{} is outside source",
            span.start, span.end
        )
    })?;
    if actual != expected {
        return Err(format!(
            "function_definition node {idx} {field} does not match its source span"
        ));
    }
    Ok(())
}

fn char_slice(source: &str, start: usize, end: usize) -> Option<String> {
    if start > end {
        return None;
    }
    let mut out = String::new();
    for (idx, ch) in source.chars().enumerate() {
        if idx >= end {
            break;
        }
        if idx >= start {
            out.push(ch);
        }
    }
    if end <= source.chars().count() {
        Some(out)
    } else {
        None
    }
}

fn span_field(object: &Map<String, Value>, field: &str, idx: usize) -> Result<AstSpan, String> {
    let span = as_object(
        object
            .get(field)
            .ok_or_else(|| format!("function_definition node {idx} is missing {field}"))?,
        &format!("function_definition node {idx} {field}"),
    )?;
    let start = usize_field(span, "start", idx)?;
    let end = usize_field(span, "end", idx)?;
    let line_start = usize_field(span, "line_start", idx)?;
    let line_end = usize_field(span, "line_end", idx)?;
    if line_start == 0 || line_end == 0 || line_start > line_end {
        return Err(format!(
            "function_definition node {idx} {field} has invalid line span {line_start}..{line_end}"
        ));
    }
    if start > end {
        return Err(format!(
            "function_definition node {idx} {field} has invalid character span {start}..{end}"
        ));
    }
    Ok(AstSpan {
        start,
        end,
        line_start,
        line_end,
    })
}

fn as_object<'a>(value: &'a Value, context: &str) -> Result<&'a Map<String, Value>, String> {
    value
        .as_object()
        .ok_or_else(|| format!("{context} must be a JSON object"))
}

fn string_field<'a>(
    object: &'a Map<String, Value>,
    field: &str,
    context: &str,
) -> Result<&'a str, String> {
    object
        .get(field)
        .and_then(Value::as_str)
        .ok_or_else(|| format!("{context} is missing string field '{field}'"))
}

fn assert_string_field(
    object: &Map<String, Value>,
    field: &str,
    expected: &str,
    idx: usize,
) -> Result<(), String> {
    let actual = string_field(object, field, "function_definition")?;
    if actual != expected {
        return Err(format!(
            "function_definition node {idx} expected {field}='{expected}', got '{actual}'"
        ));
    }
    Ok(())
}

fn string_array_field(
    object: &Map<String, Value>,
    field: &str,
    idx: usize,
) -> Result<Vec<String>, String> {
    let values = object.get(field).and_then(Value::as_array).ok_or_else(|| {
        format!("function_definition node {idx} is missing array field '{field}'")
    })?;
    values
        .iter()
        .enumerate()
        .map(|(item_idx, value)| {
            value.as_str().map(str::to_string).ok_or_else(|| {
                format!(
                    "function_definition node {idx} field '{field}' item {item_idx} is not a string"
                )
            })
        })
        .collect()
}

fn usize_field(object: &Map<String, Value>, field: &str, idx: usize) -> Result<usize, String> {
    let value = object.get(field).ok_or_else(|| {
        format!("function_definition node {idx} is missing numeric field '{field}'")
    })?;
    if let Some(n) = value.as_u64() {
        return usize::try_from(n)
            .map_err(|_| format!("function_definition node {idx} field '{field}' is too large"));
    }
    if let Some(n) = value.as_f64() {
        if n.is_finite() && n >= 0.0 && n.fract() == 0.0 {
            return Ok(n as usize);
        }
    }
    Err(format!(
        "function_definition node {idx} field '{field}' must be a non-negative integer"
    ))
}

fn function_error_message(object: &Map<String, Value>, idx: usize) -> String {
    let message = string_field(object, "message", "function_definition_error")
        .unwrap_or("invalid user function definition");
    let line = object
        .get("source_span")
        .and_then(Value::as_object)
        .and_then(|span| span.get("line_start"))
        .and_then(Value::as_u64)
        .unwrap_or(0);
    if line > 0 {
        format!("user function definition parse error at line {line}: {message}")
    } else {
        format!("user function definition parse error at node {idx}: {message}")
    }
}

fn is_identifier(value: &str) -> bool {
    let mut chars = value.chars();
    let Some(first) = chars.next() else {
        return false;
    };
    (first.is_ascii_alphabetic() || first == '_')
        && chars.all(|ch| ch.is_ascii_alphanumeric() || ch == '_')
}
