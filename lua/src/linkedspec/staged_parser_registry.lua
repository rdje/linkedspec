local action_ast = require("linkedspec.action_ast")
local action_parser = require("linkedspec.action_parser")
local function_shell = require("linkedspec.user_function_definition_shell")
local json = require("linkedspec.json")
local spec_ast = require("linkedspec.spec_ast")
local user_function_registry = require("linkedspec.user_function_registry")

local M = {}

M.ACTION_IR_BODY_SPEC_ID = "actionir-body.spec"
M.ACTION_IR_BODY_TOP_RULE = "action_block"
M.ACTION_IR_BODY_RESOLVED_SPEC_ID = "builtin:actionir-body.spec"
M.ACTION_IR_BODY_ADAPTER_DIGEST =
  "sha256:87ca81d966bb41f7025d31e4bae426af101e2ec75ff2ac14e96517d97fbbf55c"

local ACTION_IR_BODY_ADAPTER_SOURCE = "linkedspec:staged-parser/actionir-body:v1"
local SPEC_LANGUAGE_VERSION = "spec-language-v1"
local HELPER_ACTION_CONTRACT_VERSION = "actionir-v1"
local STAGED_PARSING_CONTRACT_VERSION = "staged-parsing-v1"
local DEFAULT_CAPABILITIES = { "actionir_ast_v1" }

local ERROR_MT = {
  __tostring = function(value)
    return "StagedParserRegistryException: " .. value.message
  end,
}
local RESULT_MT = { __staged_parser_registry_type = "StagedParseResult" }
local DISPATCH_MT = { __staged_parser_registry_type = "StagedFunctionBodyDispatchResult" }

local function fail(message)
  error(setmetatable({ message = message }, ERROR_MT), 0)
end

function M.is_staged_parser_registry_error(value)
  return getmetatable(value) == ERROR_MT
end

function M.node_type(value)
  if type(value) ~= "table" then
    return nil
  end
  local metatable = getmetatable(value)
  return metatable and metatable.__staged_parser_registry_type or nil
end

local function clone_json(value)
  return json.decode(json.encode(value))
end

local function copy_string_list(values)
  local result = {}
  for index, value in ipairs(values) do
    result[index] = value
  end
  return result
end

local function validate_dense_list(values, context)
  if type(values) ~= "table" then
    fail(context .. " must be a dense list")
  end
  local count = 0
  local max_index = 0
  for key in pairs(values) do
    if type(key) ~= "number" or key % 1 ~= 0 or key < 1 then
      fail(context .. " must use one-based integer indexes")
    end
    count = count + 1
    if key > max_index then
      max_index = key
    end
  end
  if count ~= max_index then
    fail(context .. " must not be sparse")
  end
  return values
end

local function normalize_job(job)
  if spec_ast.node_type(job) ~= "StagedParseJob" then
    fail("staged parse jobs must contain only StagedParseJob values")
  end
  local ok, normalized = pcall(function()
    return spec_ast.from_json("StagedParseJob", spec_ast.to_json(job))
  end)
  if not ok then
    fail("invalid staged parse job: " .. tostring(normalized))
  end
  if normalized.job_id == "" then
    fail("staged parse job job_id must be non-empty")
  end
  local span = normalized.source_span
  if span.start < 0 or span["end"] < 0 or span.start > span["end"] or
      span.line_start <= 0 or span.line_end <= 0 or
      span.line_start > span.line_end then
    fail("staged parse job source_span has invalid range")
  end
  return normalized
end

local function compare_string_lists(left, right)
  local shared = math.min(#left, #right)
  for index = 1, shared do
    if left[index] < right[index] then
      return -1
    elseif left[index] > right[index] then
      return 1
    end
  end
  if #left < #right then
    return -1
  elseif #left > #right then
    return 1
  end
  return 0
end

local function job_less(left, right)
  local left_job = left.job
  local right_job = right.job
  local path_order = compare_string_lists(left_job.parent_ast_path, right_job.parent_ast_path)
  if path_order ~= 0 then
    return path_order < 0
  elseif left_job.source_span.start ~= right_job.source_span.start then
    return left_job.source_span.start < right_job.source_span.start
  elseif left_job.source_span["end"] ~= right_job.source_span["end"] then
    return left_job.source_span["end"] < right_job.source_span["end"]
  elseif left_job.job_id ~= right_job.job_id then
    return left_job.job_id < right_job.job_id
  end
  return left.input_index < right.input_index
end

local function dispatch_error(phase, job, detail, resolved_spec_id)
  local resolved = resolved_spec_id and (" resolved_spec_id=" .. resolved_spec_id) or ""
  return "staged parse dispatch failed: phase=" .. phase ..
    " job_id=" .. job.job_id ..
    " parent_ast_path=" .. table.concat(job.parent_ast_path, ".") ..
    " parser_spec_id=" .. job.parser_spec_id .. resolved ..
    " top_rule=" .. job.top_rule ..
    " source_span=" .. job.source_span.start .. "-" .. job.source_span["end"] ..
    " failure_policy=" .. job.failure_policy ..
    " detail=" .. detail
end

local function resolve_parser(job)
  if job.parser_spec_id ~= M.ACTION_IR_BODY_SPEC_ID then
    fail(dispatch_error(
      "resolve",
      job,
      "unsupported parser spec id '" .. job.parser_spec_id .. "'"
    ))
  end
  return {
    parser_spec_id = M.ACTION_IR_BODY_SPEC_ID,
    resolved_spec_id = M.ACTION_IR_BODY_RESOLVED_SPEC_ID,
    provider = "builtin",
  }
end

local function load_parser(resolved)
  if resolved.resolved_spec_id ~= M.ACTION_IR_BODY_RESOLVED_SPEC_ID then
    fail("unsupported resolved spec id '" .. resolved.resolved_spec_id .. "'")
  end
  return {
    parser_spec_id = resolved.parser_spec_id,
    resolved_spec_id = resolved.resolved_spec_id,
    source_kind = "builtin_adapter",
    adapter_contract = ACTION_IR_BODY_ADAPTER_SOURCE,
    content_digest = M.ACTION_IR_BODY_ADAPTER_DIGEST,
    import_graph_fingerprint = "none",
  }
end

local function cache_key(loaded, top_rule, capabilities)
  local fingerprint = table.concat({
    loaded.resolved_spec_id,
    loaded.content_digest,
    loaded.import_graph_fingerprint,
    top_rule,
    SPEC_LANGUAGE_VERSION,
    HELPER_ACTION_CONTRACT_VERSION,
    STAGED_PARSING_CONTRACT_VERSION,
    table.concat(capabilities, ","),
  }, "|")
  return json.harray({
    kind = "staged_parser_cache_key",
    version = 1,
    normalized_spec_identity = loaded.resolved_spec_id,
    content_digest = loaded.content_digest,
    import_graph_fingerprint = loaded.import_graph_fingerprint,
    top_rule = top_rule,
    spec_language_version = SPEC_LANGUAGE_VERSION,
    helper_action_contract_version = HELPER_ACTION_CONTRACT_VERSION,
    staged_parsing_contract_version = STAGED_PARSING_CONTRACT_VERSION,
    backend_capabilities = json.array(copy_string_list(capabilities)),
    fingerprint = fingerprint,
    source_kind = loaded.source_kind,
    adapter_contract = loaded.adapter_contract,
  })
end

local function compile_parser(loaded, job)
  if loaded.resolved_spec_id ~= M.ACTION_IR_BODY_RESOLVED_SPEC_ID then
    fail(dispatch_error(
      "compile",
      job,
      "unsupported resolved spec id '" .. loaded.resolved_spec_id .. "'",
      loaded.resolved_spec_id
    ))
  elseif job.top_rule ~= M.ACTION_IR_BODY_TOP_RULE then
    fail(dispatch_error(
      "compile",
      job,
      "unsupported top rule '" .. job.top_rule .. "'",
      loaded.resolved_spec_id
    ))
  end
  local capabilities = copy_string_list(DEFAULT_CAPABILITIES)
  return {
    parser_spec_id = loaded.parser_spec_id,
    resolved_spec_id = loaded.resolved_spec_id,
    top_rule = job.top_rule,
    source_kind = loaded.source_kind,
    capabilities = capabilities,
    cache_key = cache_key(loaded, job.top_rule, capabilities),
  }
end

local function compiled_parser_json(compiled)
  return json.harray({
    kind = "staged_compiled_parser",
    version = 1,
    parser_spec_id = compiled.parser_spec_id,
    resolved_spec_id = compiled.resolved_spec_id,
    top_rule = compiled.top_rule,
    source_kind = compiled.source_kind,
    capabilities = json.array(copy_string_list(compiled.capabilities)),
  })
end

local function execute_parser(compiled, job)
  if compiled.resolved_spec_id ~= M.ACTION_IR_BODY_RESOLVED_SPEC_ID or
      compiled.top_rule ~= M.ACTION_IR_BODY_TOP_RULE then
    fail(dispatch_error(
      "execute",
      job,
      "compiled parser identity is unsupported",
      compiled.resolved_spec_id
    ))
  end
  local ok, result = pcall(action_parser.parse_action_block, job.text)
  if not ok then
    fail(dispatch_error(
      "execute",
      job,
      "action block parse failed: " .. tostring(result),
      compiled.resolved_spec_id
    ))
  end
  return action_ast.to_json(result)
end

local function parse_result(queue_index, job, resolved, compiled, result)
  return setmetatable({
    queue_index = queue_index,
    job = job,
    resolved_spec_id = resolved.resolved_spec_id,
    registry_provider = resolved.provider,
    cache_key = compiled.cache_key,
    compiled_parser = compiled_parser_json(compiled),
    result = result,
  }, RESULT_MT)
end

function M.execute_staged_parse_jobs(jobs)
  validate_dense_list(jobs, "staged parse jobs")
  local queue = {}
  for index, job in ipairs(jobs) do
    queue[index] = { input_index = index, job = normalize_job(job) }
  end
  table.sort(queue, job_less)

  local results = {}
  for index, queued in ipairs(queue) do
    local job = queued.job
    local resolved = resolve_parser(job)
    local loaded = load_parser(resolved)
    local compiled = compile_parser(loaded, job)
    results[index] = parse_result(
      index - 1,
      job,
      resolved,
      compiled,
      execute_parser(compiled, job)
    )
  end
  return results
end

function M.execute_staged_parse_job(job)
  local results = M.execute_staged_parse_jobs({ job })
  if #results == 0 then
    fail("staged parse dispatch produced no result")
  end
  return results[1].result
end

local function string_lists_equal(left, right)
  if left == nil or #left ~= #right then
    return false
  end
  for index = 1, #left do
    if left[index] ~= right[index] then
      return false
    end
  end
  return true
end

local function validate_function_body_job(definition, index, job)
  normalize_job(job)
  local expected_path = { "functions", tostring(index), "body_source" }
  if not string_lists_equal(job.parent_ast_path, expected_path) then
    fail(
      "function " .. definition.name .. " body_parse_job parent_ast_path must target " ..
      "functions." .. index .. ".body_source"
    )
  elseif job.node_kind ~= "function_definition" then
    fail("function " .. definition.name .. " body_parse_job node_kind must be 'function_definition'")
  elseif job.payload_kind ~= "function_body" then
    fail("function " .. definition.name .. " body_parse_job payload_kind must be 'function_body'")
  elseif job.function_name ~= nil and job.function_name ~= definition.name then
    fail("function " .. definition.name .. " body_parse_job function_name does not match")
  elseif job.params ~= nil and not string_lists_equal(job.params, definition.params) then
    fail("function " .. definition.name .. " body_parse_job params do not match")
  elseif job.arity ~= nil and job.arity ~= definition.arity then
    fail("function " .. definition.name .. " body_parse_job arity does not match")
  elseif job.text ~= definition.body_source then
    fail("function " .. definition.name .. " body_parse_job text does not match body_source")
  elseif job.parser_spec_id ~= M.ACTION_IR_BODY_SPEC_ID then
    fail(
      "function " .. definition.name .. " body_parse_job parser_spec_id must be '" ..
      M.ACTION_IR_BODY_SPEC_ID .. "'"
    )
  elseif job.top_rule ~= M.ACTION_IR_BODY_TOP_RULE then
    fail(
      "function " .. definition.name .. " body_parse_job top_rule must be '" ..
      M.ACTION_IR_BODY_TOP_RULE .. "'"
    )
  elseif job.result_policy ~= "replace_field" then
    fail("function " .. definition.name .. " body_parse_job result_policy must be 'replace_field'")
  elseif job.result_field ~= "body_ast" then
    fail("function " .. definition.name .. " body_parse_job result_field must be 'body_ast'")
  elseif job.failure_policy ~= "fail" then
    fail("function " .. definition.name .. " body_parse_job failure_policy must be 'fail'")
  end
end

local function function_index(job)
  local path = job.parent_ast_path
  if #path ~= 3 or path[1] ~= "functions" or path[3] ~= "body_source" then
    fail("staged parse result parent_ast_path must target functions[*].body_source")
  end
  local index = tonumber(path[2])
  if index == nil or index % 1 ~= 0 or index < 0 then
    fail(
      "staged parse result parent_ast_path has non-numeric function index '" ..
      tostring(path[2]) .. "'"
    )
  end
  return index
end

function M.dispatch_function_body_parse_jobs(spec)
  if spec_ast.node_type(spec) ~= "SpecFile" then
    fail("dispatch_function_body_parse_jobs expects SpecFile")
  end
  local jobs = {}
  local seen_job_ids = {}
  for lua_index, definition in ipairs(spec.functions) do
    local job = definition.body_parse_job
    if job ~= nil then
      validate_function_body_job(definition, lua_index - 1, job)
      if seen_job_ids[job.job_id] then
        fail("duplicate staged function-body job_id '" .. job.job_id .. "'")
      end
      seen_job_ids[job.job_id] = true
      jobs[#jobs + 1] = job
    end
  end

  local results = M.execute_staged_parse_jobs(jobs)
  local stitched = spec
  local seen_indexes = {}
  for _, result in ipairs(results) do
    local index = function_index(result.job)
    if seen_indexes[index] then
      fail("duplicate staged function-body result for functions." .. index .. ".body_source")
    end
    seen_indexes[index] = true
    stitched = user_function_registry.stitch_function_body_ast(
      stitched,
      result.job.job_id,
      result.result
    )
  end
  return setmetatable({ spec = stitched, results = results }, DISPATCH_MT)
end

function M.stitch_function_body_parse_jobs(spec)
  return M.dispatch_function_body_parse_jobs(spec).spec
end

function M.parse_spec_with_staged_user_function_definition_asts(source, definition_nodes)
  local spec = function_shell.parse_spec_with_asts(source, definition_nodes)
  return M.stitch_function_body_parse_jobs(spec)
end

local function result_to_json(value)
  return json.harray({
    kind = "staged_parse_result",
    version = 1,
    stage_depth = 1,
    queue_index = value.queue_index,
    phases = json.array({ "resolve", "load", "compile", "execute" }),
    job_id = value.job.job_id,
    parent_ast_path = json.array(copy_string_list(value.job.parent_ast_path)),
    parser_spec_id = value.job.parser_spec_id,
    resolved_spec_id = value.resolved_spec_id,
    registry_provider = value.registry_provider,
    top_rule = value.job.top_rule,
    node_kind = value.job.node_kind,
    payload_kind = value.job.payload_kind,
    source_span = spec_ast.to_json(value.job.source_span),
    result_policy = value.job.result_policy,
    result_field = value.job.result_field,
    failure_policy = value.job.failure_policy,
    cache_key = clone_json(value.cache_key),
    compiled_parser = clone_json(value.compiled_parser),
    result = clone_json(value.result),
  })
end

function M.to_json(value)
  local node_type = M.node_type(value)
  if node_type == "StagedParseResult" then
    return result_to_json(value)
  elseif node_type == "StagedFunctionBodyDispatchResult" then
    local results = json.array()
    for index, result in ipairs(value.results) do
      results[index] = result_to_json(result)
    end
    return json.harray({
      kind = "staged_function_body_dispatch",
      spec = spec_ast.to_json(value.spec),
      results = results,
    })
  end
  fail("to_json expects a staged parse result or function-body dispatch result")
end

return M
