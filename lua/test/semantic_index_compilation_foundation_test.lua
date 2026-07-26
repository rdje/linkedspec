-- FUTURE-PARITY-BACKLOG.10.7.2.2 — staged compiled-or-failed foundation.

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

local function check_contains(actual, expected, label)
  check(tostring(actual):find(expected, 1, true) ~= nil, (label or "text differs") ..
    ": expected to contain " .. expected .. ", got " .. tostring(actual))
end

local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local value = assert(handle:read("*a"))
  assert(handle:close())
  return value
end

local linkedspec = require("linkedspec")
local json = linkedspec.json
local source_emitter = linkedspec.source_emitter

local function options(logical_name, source_detail_ceiling, entry_rule)
  return {
    logical_name = logical_name,
    source_detail_ceiling = source_detail_ceiling,
    entry_rule = entry_rule,
  }
end

local function check_same_json(actual, expected, label)
  check_equal(json.encode(actual), json.encode(expected), label)
end

local function capture_error(operation, label)
  local ok, value = pcall(operation)
  check_equal(ok, false, label .. " rejected")
  return ok and nil or value
end

local function check_opaque(value, kind, label)
  check_equal(tostring(value), kind, label .. " stable kind")
  check_equal(getmetatable(value), "protected", label .. " protected metatable")
  check_equal(next(value), nil, label .. " empty raw state")
  local count = 0
  for _ in pairs(value) do count = count + 1 end
  check_equal(count, 0, label .. " empty iteration")
  check_equal(pcall(function() value.leak = "/tmp/private.spec" end), false,
    label .. " write rejected")
  check_equal(pcall(function() setmetatable(value, {}) end), false,
    label .. " metatable replacement rejected")
end

local function plain_json(value, active)
  local value_type = type(value)
  if value == nil or value_type == "boolean" or value_type == "number" or value_type == "string" then
    return true
  end
  if value_type ~= "table" then return false end
  active = active or {}
  if active[value] then return false end
  active[value] = true
  for key, item in pairs(value) do
    if type(key) ~= "string" and type(key) ~= "number" then return false end
    if not plain_json(item, active) then return false end
  end
  active[value] = nil
  return true
end

local function collect_keys(value, found, active)
  found = found or {}
  active = active or {}
  if type(value) ~= "table" or active[value] then return found end
  active[value] = true
  for key, item in pairs(value) do
    if type(key) == "string" then found[key] = true end
    collect_keys(item, found, active)
  end
  active[value] = nil
  return found
end

local graph = read_file("capability_conformance/semantic_introspection/graph.spec")
local graph_index = linkedspec.semantic_index(graph, options("graph.spec", "text"))

local snapshot = graph_index:semantic_snapshot()
check_same_json(snapshot:to_json(), json.harray({
  id = "snapshot:0",
  state = "compiled",
  has_execution = false,
  source_detail_ceiling = "text",
  content_digest_available = true,
}), "graph snapshot")
check_equal(snapshot.id, "snapshot:0", "snapshot id")
check_equal(snapshot.state, "compiled", "snapshot state")
check_equal(snapshot.has_execution, false, "snapshot execution absence")

local authority = graph_index:compilation_authority()
check_same_json(authority:to_json(), json.harray({
  parsed = true,
  validated = true,
  compiled = true,
}), "graph compilation authority")
check_equal(graph_index:compilation_diagnostic(), nil, "graph diagnostic absence")

local entry = graph_index:entry_selection()
check_same_json(entry:to_json(), json.harray({
  label = "Top",
  basis = "first_authored_marker",
}), "graph entry selection")

local plan = graph_index:generated_plan_input()
check_same_json(plan:to_json(), json.harray({
  contract_id = "linkedspec-generated-source-v2",
  format_version = 2,
  source_identity = "graph.spec",
  rows = json.array({
    json.harray({ label = "Top", family = "and_acode_seq" }),
    json.harray({ label = "Child", family = "rep_acode" }),
  }),
}), "graph generated plan")

local detached_rows = plan.rows
detached_rows[1].label = "Mutated"
detached_rows[2] = nil
check_equal(graph_index:generated_plan_input().rows[1].label, "Top", "plan rows detached")
check_equal(#graph_index:generated_plan_input().rows, 2, "plan row count retained")
local detached_plan_json = plan:to_json()
detached_plan_json.source_identity = "/private/mutated.spec"
detached_plan_json.rows[1].family = "default"
check_equal(graph_index:generated_plan_input().source_identity, "graph.spec", "plan JSON identity detached")
check_equal(graph_index:generated_plan_input().rows[1].family, "and_acode_seq", "plan JSON rows detached")

check_equal(
  tostring(graph_index),
  "SemanticIndex(source_id=\"source:0\", snapshot_state=\"compiled\", " ..
    "source_detail_ceiling=\"text\", has_execution=false)",
  "compiled index string"
)
for _, forbidden in ipairs({ "graph.spec", "Top", "/tmp", "table:", "userdata:" }) do
  check_equal(tostring(graph_index):find(forbidden, 1, true), nil,
    "compiled index string redacts " .. forbidden)
end

local none = linkedspec.semantic_index(graph, options("graph-none.spec", "none"))
check_equal(none:semantic_snapshot().content_digest_available, false, "none snapshot digest absence")
local plan_ceiling = capture_error(function() return none:generated_plan_input() end, "none plan ceiling")
check_equal(plan_ceiling.stage, "apply_source_ceiling", "none plan ceiling stage")
check_equal(plan_ceiling.code, "semantic_source_detail_forbidden", "none plan ceiling code")

local explicit = linkedspec.semantic_index(graph, options("graph-explicit.spec", "identity", "Child"))
check_same_json(explicit:entry_selection():to_json(), json.harray({
  label = "Child",
  basis = "explicit_selector",
}), "explicit entry selection")
check_equal(explicit:generated_plan_input().source_identity, "graph-explicit.spec",
  "explicit plan identity")

local markerless = linkedspec.semantic_index(
  "First:\n /x/\n\nSecond:\n /y/\n",
  options("markerless.spec", "identity")
)
check_equal(markerless:entry_selection().label, "First", "markerless entry label")
check_equal(markerless:entry_selection().basis, "first_authored_rule", "markerless entry basis")

local calls = linkedspec.semantic_index(
  read_file("capability_conformance/semantic_introspection/calls_and_staging.spec"),
  options("calls_and_staging.spec", "identity")
)
check_equal(calls:semantic_snapshot().state, "compiled", "staged calls compile")
check_equal(calls:semantic_snapshot().has_execution, false, "staged calls do not execute")
check_equal(calls:generated_plan_input().rows[1].label, "Top", "staged calls first row")
check_equal(calls:generated_plan_input().rows[1].family, "default", "staged calls first family")
check_equal(calls:generated_plan_input().rows[2].label, "Done", "staged calls second row")
check_equal(calls:generated_plan_input().rows[2].family, "default", "staged calls second family")

local failed = linkedspec.semantic_index(
  read_file("capability_conformance/semantic_introspection/failed.spec"),
  options("failed.spec", "text")
)
check_equal(failed:semantic_snapshot().state, "failed_compilation", "native failure snapshot")
check_same_json(failed:compilation_authority():to_json(), json.harray({
  parsed = true,
  validated = false,
  compiled = false,
}), "native failure authority")
local diagnostic = failed:compilation_diagnostic()
check_same_json(diagnostic:to_json(), json.harray({
  code = "bare_edge_target_undefined",
  stage = "normalize_edges",
  message = "bare edge in rule 'Top' targets undefined rule 'Missing'",
  fields = json.harray({ rule_label = "Top", target = "Missing" }),
}), "native validation diagnostic")
check_equal(failed:entry_selection(), nil, "native failure entry absence")
check_equal(failed:generated_plan_input(), nil, "native failure plan absence")
local detached_fields = diagnostic.fields
detached_fields.target = "Mutated"
check_equal(failed:compilation_diagnostic().fields.target, "Missing", "diagnostic fields detached")
local detached_diagnostic_json = diagnostic:to_json()
detached_diagnostic_json.fields.target = "Mutated again"
check_equal(failed:compilation_diagnostic().fields.target, "Missing", "diagnostic JSON detached")

local parse_failure = linkedspec.semantic_index(
  "Top:::\n /x/\n",
  options("parse-failure.spec", "identity")
)
check_same_json(parse_failure:compilation_authority():to_json(), json.harray({
  parsed = false,
  validated = false,
  compiled = false,
}), "parse failure authority")
check_equal(parse_failure:compilation_diagnostic().code, "semantic_index_parse_failed",
  "parse fallback code")
check_equal(parse_failure:compilation_diagnostic().stage, "parse_source", "parse fallback stage")
check_equal(parse_failure:compilation_diagnostic().fields.line, 1, "parse fallback line")

local empty = linkedspec.semantic_index("", options("empty.spec", "identity"))
check_same_json(empty:compilation_diagnostic():to_json(), json.harray({
  code = "no_rules_defined",
  stage = "validate_spec",
  message = "spec does not define any rules",
  fields = json.harray(),
}), "empty native diagnostic")

local missing_entry = linkedspec.semantic_index(
  "Top::\n /x/\n",
  options("missing-entry.spec", "identity", "Missing")
)
check_same_json(missing_entry:compilation_authority():to_json(), json.harray({
  parsed = true,
  validated = true,
  compiled = false,
}), "missing entry authority")
check_same_json(missing_entry:compilation_diagnostic():to_json(), json.harray({
  code = "entry_rule_not_found",
  stage = "select_entry_rule",
  message = "entry rule 'Missing' is not defined",
  fields = json.harray({ entry_rule = "Missing" }),
}), "missing entry diagnostic")

local duplicate = linkedspec.semantic_index(
  "Top:\n /a/\nTop:\n /b/\n",
  options("duplicate.spec", "identity")
)
check_equal(duplicate:compilation_diagnostic().code, "semantic_index_validation_failed",
  "non-portable validation fallback code")
check_equal(duplicate:compilation_diagnostic().stage, "validate_source",
  "non-portable validation fallback stage")
check_equal(duplicate:compilation_diagnostic().message, "duplicate rule label 'Top'",
  "non-portable validation fallback message")

local compile_failure = linkedspec.semantic_index(
  "Top::\n /x/ E { return(array(items)) }\n", -- selector-rejection fixture
  options("compile-failure.spec", "identity")
)
check_equal(compile_failure:compilation_authority().validated, true, "compile fallback validated")
check_equal(compile_failure:compilation_authority().compiled, false, "compile fallback compiled absence")
check_equal(compile_failure:compilation_diagnostic().code, "semantic_index_compilation_failed",
  "compile fallback code")
check_equal(compile_failure:compilation_diagnostic().stage, "compile_source", "compile fallback stage")
check_contains(compile_failure:compilation_diagnostic().message, "aggregate_selector_removed",
  "compile fallback message")

local original_plan_builder = source_emitter.build_generated_rule_plan
source_emitter.build_generated_rule_plan = function()
  error(source_emitter.generated_source_error({
    stage = source_emitter.VALIDATE_GENERATED_PLAN_STAGE,
    code = source_emitter.GENERATED_PLAN_ROW_COUNT_MISMATCH_CODE,
    summary = "synthetic generated-plan failure",
    source_identity = "synthetic.spec",
  }), 0)
end
local plan_failure = linkedspec.semantic_index(graph, options("plan-failure.spec", "identity"))
source_emitter.build_generated_rule_plan = original_plan_builder
check_equal(plan_failure:compilation_diagnostic().code, "semantic_index_generated_plan_failed",
  "plan fallback code")
check_equal(plan_failure:compilation_diagnostic().stage, "build_generated_plan", "plan fallback stage")
check_equal(plan_failure:compilation_diagnostic().message, "synthetic generated-plan failure",
  "plan fallback message")

local sentinel = {}
source_emitter.build_generated_rule_plan = function() error(sentinel, 0) end
local sentinel_ok, sentinel_error = pcall(function()
  return linkedspec.semantic_index(graph, options("sentinel.spec", "identity"))
end)
source_emitter.build_generated_rule_plan = original_plan_builder
check_equal(sentinel_ok, false, "unrecognized plan sentinel rejected")
check_equal(sentinel_error, sentinel, "unrecognized plan sentinel identity")

local target = linkedspec.semantic_index(
  "Top::\n { fail(\"target must not run\") }\n",
  options("target.spec", "identity")
)
check_equal(target:semantic_snapshot().state, "compiled", "target source compiles without execution")
check_equal(target:semantic_snapshot().has_execution, false, "target execution remains absent")
check_equal(target:generated_plan_input().rows[1].family, "default", "target plan family")

local opaque_values = {
  { snapshot, "SemanticSnapshot", "snapshot" },
  { authority, "SemanticCompilationAuthority", "authority" },
  { diagnostic, "SemanticCompilationDiagnostic", "diagnostic" },
  { entry, "SemanticEntrySelection", "entry" },
  { plan, "SemanticGeneratedPlanInput", "plan" },
}
for _, case in ipairs(opaque_values) do check_opaque(case[1], case[2], case[3]) end

local public_json = {
  snapshot:to_json(),
  authority:to_json(),
  diagnostic:to_json(),
  entry:to_json(),
  plan:to_json(),
}
for index, value in ipairs(public_json) do check(plain_json(value), "public JSON plain " .. index) end
local forbidden_keys = {
  ast = true,
  body_ast = true,
  compiled_spec = true,
  definition_order = true,
  descriptor = true,
  path = true,
  rules_by_label = true,
  source = true,
  source_bytes = true,
  source_text = true,
}
local found_keys = collect_keys(public_json)
for key in pairs(forbidden_keys) do check_equal(found_keys[key], nil, "public JSON forbids " .. key) end
check_equal(graph_index.semantic_query, nil, "semantic query remains absent")
check_equal(graph_index.semantic_records, nil, "semantic records remain absent")

local implementation = read_file("lua/src/linkedspec/semantic_compilation_outcome.lua")
for token, expected in pairs({
  ["user_function_definition_parser.parse_spec_with_staged_user_function_definitions"] = 1,
  ["spec_validator.validate_spec"] = 1,
  ["compiled_spec.compile_spec"] = 1,
  ["compiled_spec.resolve_entry_rule"] = 1,
  ["source_emitter.build_generated_rule_plan"] = 1,
}) do
  local count = 0
  local position = 1
  while true do
    local found = implementation:find(token, position, true)
    if found == nil then break end
    count = count + 1
    position = found + #token
  end
  check_equal(count, expected, "single outcome call " .. token)
end
for _, forbidden in ipairs({
  "linkedspec.spec_loader",
  "runtime_parse(",
  "runtime_execute(",
  "execute_generated_parser",
  "diagnostic_sink",
  "semantic_observation",
  "to_descriptor_json",
}) do
  check_equal(implementation:find(forbidden, 1, true), nil, "outcome source forbids " .. forbidden)
end
check(implementation:find("authored_definitions = definitions", 1, true) ~= nil,
  "merged authored definitions retained")

if #failures > 0 then error(table.concat(failures, "\n"), 0) end
io.stdout:write("Lua semantic-index compilation foundation: ", assertions, " assertions passed\n")
