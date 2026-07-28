-- FUTURE-PARITY-BACKLOG.10.7.4.2 — exact staged and generated provenance.

local assertions = 0
local failures = {}

local function check(condition, label)
  assertions = assertions + 1
  if not condition then failures[#failures + 1] = label or "assertion failed" end
end

local function check_equal(actual, expected, label)
  check(actual == expected, (label or "values differ") ..
    ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
end

local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local value = assert(handle:read("*a"))
  assert(handle:close())
  return value
end

local linkedspec = require("linkedspec")
local json = linkedspec.json
local semantic_index_module = require("linkedspec.semantic_index")
local outcome_builder = require("linkedspec.semantic_compilation_outcome")
local projector = require("linkedspec.semantic_static_projection")
local spec_ast = require("linkedspec.spec_ast")

local fixture_root = "capability_conformance/semantic_introspection/"
local source = read_file(fixture_root .. "calls_and_staging.spec")
local model = json.decode(read_file("capability_conformance/semantic_introspection_model.json"))

local function detached(value)
  return json.decode(json.encode(value))
end

local function expected_complete()
  for _, snapshot in ipairs(model.snapshots) do
    if snapshot.id == "calls" then
      local result = detached(snapshot)
      result.id = nil
      result.fixture = nil
      return result
    end
  end
  error("missing calls semantic snapshot", 0)
end

local function materialize_sources(projection)
  local result = detached(projection)
  local source_refs = result.source_refs
  result.source_refs = nil
  for _, group in ipairs({ "records", "relations" }) do
    for _, item in ipairs(result[group]) do
      if type(item.source) == "string" then item.source = detached(source_refs[item.source]) end
    end
  end
  return result
end

local function record_by_id(projection, id)
  for _, item in ipairs(projection.records) do
    if item.id == id then return item end
  end
  error("missing semantic record " .. id, 0)
end

local function records_of_kind(projection, kind)
  local result = {}
  for _, item in ipairs(projection.records) do
    if item.kind == kind then result[#result + 1] = item end
  end
  return result
end

local function relation_ids(projection)
  local result = {}
  for _, item in ipairs(projection.relations) do result[item.id] = true end
  return result
end

local function count_keys(value)
  local count = 0
  for _ in pairs(value) do count = count + 1 end
  return count
end

local function plain_and_host_free(value)
  if value == json.null then return true end
  local kind = json.kind(value)
  if kind == "string" or kind == "number" or kind == "boolean" then return true end
  if kind ~= "array" and kind ~= "harray" then return false end
  local forbidden = {
    host_path = true,
    file_path = true,
    source_text = true,
    source_bytes = true,
    body_source = true,
    body_payload = true,
    body_parse_job = true,
    body_ast = true,
    ast = true,
    action_ir = true,
    descriptor = true,
    compiled_regex = true,
    generated_source = true,
    loader = true,
    executor = true,
    trace = true,
    diagnostic_sink = true,
    runtime_observer = true,
  }
  for key, item in pairs(value) do
    if kind == "harray" and (type(key) ~= "string" or forbidden[key]) then return false end
    if not plain_and_host_free(item) then return false end
  end
  return true
end

local function capture_error(callback)
  local ok, result = pcall(callback)
  if ok then return nil end
  return result
end

local function semantic_fail(stage, code, message, fields)
  error({ stage = stage, code = code, message = message, fields = fields }, 0)
end

local function shallow_copy(value)
  local result = {}
  for key, item in pairs(value) do result[key] = item end
  return result
end

local function entry_with(entry, changes)
  local definition = shallow_copy(entry.definition)
  for key, value in pairs(changes) do definition[key] = value end
  return { index = entry.index, definition = definition }
end

local function clone_job(job, changes)
  local options = {
    version = job.version,
    job_id = job.job_id,
    parent_ast_path = job.parent_ast_path,
    node_kind = job.node_kind,
    payload_kind = job.payload_kind,
    function_name = job.function_name,
    params = job.params,
    arity = job.arity,
    signature = job.signature,
    parameter_kinds = job.parameter_kinds,
    text = job.text,
    source_span = job.source_span,
    parser_spec_id = job.parser_spec_id,
    top_rule = job.top_rule,
    result_policy = job.result_policy,
    result_field = job.result_field,
    failure_policy = job.failure_policy,
    diagnostic_owner = job.diagnostic_owner,
  }
  for key, value in pairs(changes) do options[key] = value end
  return spec_ast.staged_parse_job(options)
end

local function clone_plan(plan)
  local rows = {}
  for index, row in ipairs(plan.rows) do
    rows[index] = { label = row.label, family = row.family }
  end
  return {
    contract_id = plan.contract_id,
    format_version = plan.format_version,
    source_identity = plan.source_identity,
    rows = rows,
  }
end

local options = {
  logical_name = "calls_and_staging.spec",
  source_detail_ceiling = "text",
}
local index = linkedspec.semantic_index(source, options)
local projection = semantic_index_module._static_projection_for_testing(index)

check_equal(#projection.records, 22, "complete record count")
check_equal(#projection.relations, 25, "complete relation count")
check_equal(count_keys(projection.source_refs), 10, "complete source-ref count")
check_equal(json.encode(materialize_sources(projection)),
  json.encode(materialize_sources(expected_complete())), "complete governed deep equality")

local staged = records_of_kind(projection, "staged_artifact")
check_equal(#staged, 3, "staged artifact count")
local expected_staged_ids = {
  "staged:payload:function:normalize:0",
  "staged:parse_job:function:normalize:1",
  "staged:result:function:normalize:2",
}
local expected_kinds = { "payload", "parse_job", "result" }
local expected_nodes = { "action_source", "action_program", "action_program" }
local expected_shapes = { "string", "unknown", "unknown" }
local function_source = record_by_id(projection, "function:normalize").source
for index_in_group, item in ipairs(staged) do
  check_equal(item.id, expected_staged_ids[index_in_group], "staged artifact id")
  check_equal(item.facts.artifact_kind, expected_kinds[index_in_group], "staged artifact kind")
  check_equal(item.facts.node_kind, expected_nodes[index_in_group], "staged node kind")
  check_equal(item.facts.value_shape.kind, expected_shapes[index_in_group], "staged value shape")
  check_equal(item.facts.status, "succeeded", "staged status")
  check_equal(item.facts.parent_path[1], "function:normalize", "staged neutral parent")
  check_equal(item.source, function_source, "staged function source")
end
check_equal(projection.source_refs[function_source].excerpt,
  "fn normalize(value) { return(trim(value)) }", "staged source excerpt")

local generated = record_by_id(projection, "generated:handler_plan:0")
check_equal(generated.kind, "generated_artifact", "generated record kind")
check_equal(generated.source, json.null, "generated source absent")
check_equal(generated.facts.artifact_kind, "handler_plan", "generated artifact kind")
check_equal(generated.facts.contract_id, "linkedspec-generated-source-v2", "generated contract")
check_equal(generated.facts.format_version, 2, "generated format")
check_equal(generated.facts.plan_family, "default", "selected plan family")

local relations = relation_ids(projection)
for _, id in ipairs({
  "relation:contains:function:normalize:staged:payload:function:normalize:0:0",
  "relation:contains:function:normalize:staged:parse_job:function:normalize:1:1",
  "relation:contains:function:normalize:staged:result:function:normalize:2:2",
  "relation:lowered_from:staged:payload:function:normalize:0:source:0:0",
  "relation:consumes:staged:parse_job:function:normalize:1:staged:payload:function:normalize:0:0",
  "relation:produces:staged:parse_job:function:normalize:1:staged:result:function:normalize:2:0",
  "relation:lowered_from:staged:result:function:normalize:2:staged:payload:function:normalize:0:0",
  "relation:staged_by:staged:result:function:normalize:2:staged:parse_job:function:normalize:1:0",
  "relation:generated_as:spec:0:generated:handler_plan:0:0",
}) do
  check(relations[id], "staged/generated relation present " .. id)
end

local outcome = outcome_builder.build(source, options)
local entry = outcome.compiled.function_registry.entries[1]
check(projector._validate_staged_authority_for_testing(entry, semantic_fail),
  "accepted staged authority validates")

local bad_payload = detached(entry.definition.body_payload)
bad_payload.kind = "wrong_payload"
local payload_error = capture_error(function()
  projector._validate_staged_authority_for_testing(
    entry_with(entry, { body_payload = bad_payload }), semantic_fail
  )
end)
check(type(payload_error) == "table", "corrupt payload rejects")
check_equal(payload_error and payload_error.stage, "project_call_semantics", "payload error stage")
check_equal(payload_error and payload_error.code,
  "semantic_call_correlation_failed", "payload error code")
check_equal(payload_error and payload_error.message,
  "Native staged function metadata does not match its typed owner", "payload error message")

local bad_job = clone_job(entry.definition.body_parse_job, { top_rule = "wrong_top_rule" })
local job_error = capture_error(function()
  projector._validate_staged_authority_for_testing(
    entry_with(entry, { body_parse_job = bad_job }), semantic_fail
  )
end)
check(type(job_error) == "table", "corrupt parse job rejects")
check_equal(job_error and job_error.code,
  "semantic_call_correlation_failed", "parse-job error code")
check_equal(job_error and job_error.message,
  "Native staged function metadata does not match its typed owner", "parse-job error message")

local result_error = capture_error(function()
  projector._validate_staged_authority_for_testing(
    entry_with(entry, { body_ast = false }), semantic_fail
  )
end)
check(type(result_error) == "table", "missing staged result rejects")
check_equal(result_error and result_error.message,
  "Compiled function has no complete staged authority", "missing-result error message")

local selected_row = projector._validate_generated_plan_for_testing(
  options.logical_name,
  outcome.compiled,
  outcome.entry,
  outcome.generated_plan,
  semantic_fail
)
check_equal(selected_row.label, "Top", "selected retained plan label")
check_equal(selected_row.family, "default", "selected retained plan family")

local plan_mutations = {
  {
    name = "contract",
    mutate = function(plan) plan.contract_id = "wrong-contract" end,
  },
  {
    name = "format",
    mutate = function(plan) plan.format_version = 1 end,
  },
  {
    name = "identity",
    mutate = function(plan) plan.source_identity = "wrong.spec" end,
  },
  {
    name = "order",
    mutate = function(plan) plan.rows[1], plan.rows[2] = plan.rows[2], plan.rows[1] end,
  },
  {
    name = "duplicate label",
    mutate = function(plan) plan.rows[2].label = plan.rows[1].label end,
  },
  {
    name = "empty family",
    mutate = function(plan) plan.rows[1].family = "" end,
  },
}
for _, mutation in ipairs(plan_mutations) do
  local plan = clone_plan(outcome.generated_plan)
  mutation.mutate(plan)
  local plan_error = capture_error(function()
    projector._validate_generated_plan_for_testing(
      options.logical_name, outcome.compiled, outcome.entry, plan, semantic_fail
    )
  end)
  check(type(plan_error) == "table", mutation.name .. " plan rejects")
  check_equal(plan_error and plan_error.message,
    "Retained generated plan does not match compiled semantic authority",
    mutation.name .. " plan error message")
end

local selection_error = capture_error(function()
  projector._validate_generated_plan_for_testing(
    options.logical_name,
    outcome.compiled,
    { label = "Missing", basis = "explicit_selector" },
    outcome.generated_plan,
    semantic_fail
  )
end)
check(type(selection_error) == "table", "missing selection rejects")
check_equal(selection_error and selection_error.message,
  "Generated plan has no unique selected entry row", "selection error message")
check_equal(selection_error and selection_error.fields.selected_rows, 0, "selection row count")

record_by_id(projection, expected_staged_ids[1]).facts.status = "injected"
generated.facts.plan_family = "injected"
local second = semantic_index_module._static_projection_for_testing(index)
check_equal(record_by_id(second, expected_staged_ids[1]).facts.status,
  "succeeded", "staged clone detached")
check_equal(record_by_id(second, "generated:handler_plan:0").facts.plan_family,
  "default", "generated clone detached")
check(second ~= projection, "complete materializations are fresh roots")
check_equal(json.encode(detached(second)), json.encode(second), "complete JSON round-trip")
check(plain_and_host_free(second), "complete projection is plain and host-free")
local encoded = json.encode(second)
check(encoded:find("/" .. "Users/", 1, true) == nil, "complete projection excludes developer path")
check(encoded:find("/" .. "home/", 1, true) == nil, "complete projection excludes home path")
check(encoded:find("/" .. "tmp/", 1, true) == nil, "complete projection excludes temp path")
check_equal(linkedspec.semantic_staged_artifacts, nil, "root exports no staged accessor")
check_equal(linkedspec.semantic_generated_artifacts, nil, "root exports no generated accessor")
check_equal(linkedspec._validate_staged_authority_for_testing, nil, "root exports no staged probe")
check_equal(linkedspec._validate_generated_plan_for_testing, nil, "root exports no plan probe")

local implementation = read_file("lua/src/linkedspec/semantic_static_projection.lua")
for _, forbidden in ipairs({
  'require("linkedspec.source_emitter")',
  'require("linkedspec.compiled_spec")',
  'require("linkedspec.interpreter")',
  "build_generated_rule_plan(",
  "emit_generated_source",
  "execute_generated",
  "runtime_execute(",
  "LINKEDSPEC_TRACE_LEVEL",
  "diagnostic_sink",
  "semantic_observation",
  "generated_source =",
  "loadfile",
  "dofile",
  "os.getenv",
  "os.clock",
  "math.random",
}) do
  check(implementation:find(forbidden, 1, true) == nil,
    "implementation excludes " .. forbidden)
end

if #failures > 0 then
  io.stderr:write("semantic staged/generated call failures:\n")
  for _, failure in ipairs(failures) do io.stderr:write("- " .. failure .. "\n") end
  os.exit(1)
end

print("semantic staged/generated call assertions: " .. assertions)
