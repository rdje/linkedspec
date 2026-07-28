-- FUTURE-PARITY-BACKLOG.10.7.6.2 — immutable observed runtime projection.

local linkedspec = require("linkedspec")
local json = linkedspec.json
local observation = require("linkedspec.semantic_observation")
local semantic_index_module = require("linkedspec.semantic_index")
local sha256 = require("linkedspec.sha256")
local static_projection = require("linkedspec.semantic_static_projection")

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

local function check_same_json(actual, expected, label)
  local actual_json = json.encode(actual)
  local expected_json = json.encode(expected)
  if actual_json == expected_json then
    check(true, label)
    return
  end
  local offset = 1
  local shared_length = math.min(#actual_json, #expected_json)
  while offset <= shared_length and
      actual_json:sub(offset, offset) == expected_json:sub(offset, offset) do
    offset = offset + 1
  end
  local first = math.max(1, offset - 48)
  local last = offset + 96
  check(false, (label or "JSON values differ") .. " at byte " .. offset ..
    ": expected near " .. expected_json:sub(first, last) ..
    ", got " .. actual_json:sub(first, last))
end

local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local value = assert(handle:read("*a"))
  assert(handle:close())
  return value
end

local function compile(source)
  local parsed = linkedspec.parse_spec(source)
  linkedspec.validate_spec(parsed)
  return linkedspec.compile_spec(parsed)
end

local function capture_events(source, input)
  local events = {}
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(compile(source)),
    input,
    { semantic_observation_sink = function(event) events[#events + 1] = event end }
  )
  return result, events
end

local function plain_sequence(values)
  local result = {}
  for index, value in ipairs(values) do result[index] = value end
  return result
end

local function typed_request(value)
  local after_id = value.page.after_id
  if after_id == json.null then after_id = nil end
  return linkedspec.semantic_query_request(value.operation, {
    contract = value.contract,
    subjects = plain_sequence(value.subjects),
    record_kinds = plain_sequence(value.record_kinds),
    relation_kinds = plain_sequence(value.relation_kinds),
    direction = value.direction,
    page = { after_id = after_id, limit = value.page.limit },
    budget = {
      max_records = value.budget.max_records,
      max_relations = value.budget.max_relations,
      max_depth = value.budget.max_depth,
    },
    source = {
      detail = value.source.detail,
      include_content_digest = value.source.include_content_digest,
    },
  })
end

local function expected_snapshot(model, id)
  for _, snapshot in ipairs(model.snapshots) do
    if snapshot.id == id then
      local result = json.decode(json.encode(snapshot))
      result.id = nil
      result.fixture = nil
      return result
    end
  end
  error("missing semantic model snapshot " .. id, 0)
end

local function materialize_sources(projection)
  local result = json.decode(json.encode(projection))
  local source_refs = result.source_refs
  result.source_refs = nil
  for _, group in ipairs({ "records", "relations" }) do
    for _, item in ipairs(result[group]) do
      if type(item.source) == "string" then item.source = source_refs[item.source] end
    end
  end
  return result
end

local function query_case(contract, id)
  for _, value in ipairs(contract.query_cases) do
    if value.id == id then return value end
  end
  error("missing semantic query case " .. id, 0)
end

local function response_digest(response)
  return sha256.hex(json.encode(linkedspec.semantic_query_to_json(response)))
end

local function record_ids(response)
  local result = json.array()
  for index, value in ipairs(response.records) do result[index] = value.id end
  return result
end

local function relation_ids(response)
  local result = json.array()
  for index, value in ipairs(response.relations) do result[index] = value.id end
  return result
end

local function capture_derivation_error(index, events, label)
  local ok, value = pcall(function() return index:with_execution_observation(events) end)
  check_equal(ok, false, label .. " rejected")
  if ok then return nil end
  check_equal(value.stage, "execution_observation", label .. " stage")
  check_equal(value.code, "semantic_index_invalid_observation", label .. " code")
  check(type(value.message) == "string" and value.message ~= "", label .. " message")
  check_equal(getmetatable(value), "protected", label .. " protected error")
  return value
end

local runtime_source = read_file("capability_conformance/semantic_introspection/runtime.spec")
local runtime_input = read_file("capability_conformance/semantic_introspection/runtime.input")
local model = json.decode(read_file("capability_conformance/semantic_introspection_model.json"))
local contract = json.decode(read_file("capability_conformance/semantic_introspection_contract.json"))
local governed = query_case(contract, "runtime_events")
local governed_digest = "36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887"
local base_options = { logical_name = "runtime.spec", source_detail_ceiling = "text" }
local base = linkedspec.semantic_index(runtime_source, base_options)
local runtime_result, captured = capture_events(runtime_source, runtime_input)

check_same_json(runtime_result.value, json.array({ "A", "B" }), "captured runtime result")
check_equal(#captured, 3, "captured event count")
check_equal(base:semantic_snapshot().has_execution, false, "base snapshot remains static")
check_contains(tostring(base), "has_execution=false", "base display remains static")

local request = typed_request(governed.request)
local raw_request = json.decode(json.encode(governed.request))
local empty_runtime = base:query(request)
check_equal(#empty_runtime.records, 0, "base runtime query has no records")

local derived = base:with_execution_observation(captured)
check_equal(getmetatable(derived), "protected", "derived index metatable protected")
check_equal(next(derived), nil, "derived index state hidden")
check_equal(derived:semantic_snapshot().has_execution, true, "derived snapshot has execution")
check_contains(tostring(derived), "has_execution=true", "derived display reports execution")

local projection = semantic_index_module._static_projection_for_testing(derived)
check_same_json(materialize_sources(projection), materialize_sources(expected_snapshot(model, "runtime")),
  "complete governed runtime projection")
local typed = derived:query(request)
local neutral = derived:query_neutral(raw_request)
check_same_json(linkedspec.semantic_query_to_json(typed), linkedspec.semantic_query_to_json(neutral),
  "typed and raw-neutral runtime query identity")
check_same_json(record_ids(typed), governed.expected.record_ids, "runtime query record ids")
check_equal(response_digest(typed), governed_digest, "runtime typed response digest")
check_equal(response_digest(neutral), governed.expected.response_sha256,
  "runtime neutral response digest")

local relations = derived:query(linkedspec.semantic_query_request("relations", {
  subjects = { "execution:0" },
  relation_kinds = { "observed_as" },
  source = { detail = "identity" },
}))
check_same_json(relation_ids(relations), json.array({
  "relation:observed_as:execution:0:event:execution:0:0:0",
  "relation:observed_as:execution:0:event:execution:0:1:1",
  "relation:observed_as:execution:0:event:execution:0:2:2",
}), "observed relation ids")
check_same_json(relations.relations[1].evidence_ids, json.array({ "regex:rule:Top:0" }),
  "first slot evidence")
check_same_json(relations.relations[2].evidence_ids, json.array({ "regex:rule:Top:1" }),
  "second slot evidence")
check_same_json(relations.relations[3].evidence_ids, json.array({ "rule:Top" }),
  "result rule evidence")

local base_capabilities = base:capabilities()
local derived_capabilities = derived:capabilities()
check_equal(base_capabilities.records[1].facts.execution_observation, false,
  "base capabilities omit execution")
check_equal(derived_capabilities.records[1].facts.execution_observation, true,
  "derived capabilities report execution")

captured[1] = captured[3]
local detached_event = linkedspec.runtime_semantic_observation_event_to_json(captured[2])
detached_event.position = 999
local detached_response = linkedspec.semantic_query_to_json(typed)
detached_response.records[1].facts.status = "mutated"
projection.records[1].facts.definition_order[1] = "rule:Injected"
check_equal(response_digest(derived:query(request)), governed_digest,
  "caller event and projection mutation cannot alter derived index")
check_equal(base:semantic_snapshot().has_execution, false, "derivation cannot mutate base snapshot")
check_equal(#base:query(request).records, 0, "derivation cannot add base records")

local _, fresh_events = capture_events(runtime_source, runtime_input)
local repeated = base:with_execution_observation(fresh_events)
check_equal(response_digest(repeated:query(request)), governed_digest, "repeat derivation identity")
local interleaved_base = linkedspec.semantic_index(runtime_source, base_options)
local interleaved = interleaved_base:with_execution_observation(fresh_events)
check_equal(response_digest(interleaved:query(request)), governed_digest,
  "interleaved derivation identity")
check_equal(interleaved_base:semantic_snapshot().has_execution, false,
  "interleaved base remains static")

local NIL = {}
local function malformed_event(kind, overrides)
  local fields
  if kind == "slot" then
    fields = {
      contract_id = observation.CONTRACT_ID,
      event_kind = observation.REGEX_SLOT_SELECTED,
      rule_label = "Top",
      target_rule = "Top",
      regex_index = 0,
      position = 1,
    }
  else
    fields = {
      contract_id = observation.CONTRACT_ID,
      event_kind = observation.RULE_RESULT,
      rule_label = "Top",
      position = 2,
      input_identity =
        "input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece",
      status = "succeeded",
    }
  end
  for key, value in pairs(overrides or {}) do
    fields[key] = value == NIL and nil or value
  end
  return observation._event_for_testing(fields)
end

local function valid_events()
  return {
    malformed_event("slot"),
    malformed_event("slot", { regex_index = 1, position = 2 }),
    malformed_event("result"),
  }
end

local malformed = {
  { "not a table", "events" },
  { "object sequence", json.harray({ event = malformed_event("result") }) },
  { "host metatable", setmetatable(valid_events(), {}) },
  { "empty", {} },
  { "sparse", { [1] = malformed_event("slot"), [3] = malformed_event("result") } },
  { "zero key", { [0] = malformed_event("slot"), [1] = malformed_event("result") } },
  { "non-event", { malformed_event("slot"), "host", malformed_event("result") } },
  { "missing result", { malformed_event("slot") } },
  { "duplicate result", {
    malformed_event("slot"), malformed_event("result"), malformed_event("result"),
  } },
  { "reordered result", {
    malformed_event("slot"), malformed_event("result"), malformed_event("slot"),
  } },
  { "foreign contract", {
    malformed_event("slot", { contract_id = "future-contract" }), malformed_event("result"),
  } },
  { "missing contract", {
    malformed_event("slot", { contract_id = NIL }), malformed_event("result"),
  } },
  { "non-text contract", {
    malformed_event("slot", { contract_id = false }), malformed_event("result"),
  } },
  { "foreign kind", {
    malformed_event("slot", { event_kind = "future_event" }), malformed_event("result"),
  } },
  { "missing rule label", {
    malformed_event("slot", { rule_label = NIL }), malformed_event("result"),
  } },
  { "empty rule label", {
    malformed_event("slot", { rule_label = "" }), malformed_event("result"),
  } },
  { "invalid rule UTF-8", {
    malformed_event("slot", { rule_label = string.char(0xFF) }), malformed_event("result"),
  } },
  { "negative position", {
    malformed_event("slot", { position = -1 }), malformed_event("result"),
  } },
  { "fractional position", {
    malformed_event("slot", { position = 1.5 }), malformed_event("result"),
  } },
  { "infinite position", {
    malformed_event("slot", { position = math.huge }), malformed_event("result"),
  } },
  { "text position", {
    malformed_event("slot", { position = "1" }), malformed_event("result"),
  } },
  { "missing target", {
    malformed_event("slot", { target_rule = NIL }), malformed_event("result"),
  } },
  { "empty target", {
    malformed_event("slot", { target_rule = "" }), malformed_event("result"),
  } },
  { "invalid target UTF-8", {
    malformed_event("slot", { target_rule = string.char(0xFF) }), malformed_event("result"),
  } },
  { "numeric target", {
    malformed_event("slot", { target_rule = 3 }), malformed_event("result"),
  } },
  { "missing index", {
    malformed_event("slot", { regex_index = NIL }), malformed_event("result"),
  } },
  { "negative index", {
    malformed_event("slot", { regex_index = -1 }), malformed_event("result"),
  } },
  { "fractional index", {
    malformed_event("slot", { regex_index = 0.5 }), malformed_event("result"),
  } },
  { "text index", {
    malformed_event("slot", { regex_index = "0" }), malformed_event("result"),
  } },
  { "slot input identity", {
    malformed_event("slot", { input_identity = "input:sha256:" .. string.rep("0", 64) }),
    malformed_event("result"),
  } },
  { "slot status", {
    malformed_event("slot", { status = "succeeded" }), malformed_event("result"),
  } },
  { "result target", {
    malformed_event("slot"), malformed_event("result", { target_rule = "Top" }),
  } },
  { "result index", {
    malformed_event("slot"), malformed_event("result", { regex_index = 0 }),
  } },
  { "failed result", {
    malformed_event("slot"), malformed_event("result", { status = "failed" }),
  } },
  { "missing result status", {
    malformed_event("slot"), malformed_event("result", { status = NIL }),
  } },
  { "missing input identity", {
    malformed_event("slot"), malformed_event("result", { input_identity = NIL }),
  } },
  { "malformed input identity", {
    malformed_event("slot"), malformed_event("result", { input_identity = "input:sha256:xyz" }),
  } },
  { "uppercase input identity", {
    malformed_event("slot"), malformed_event("result", {
      input_identity = "input:sha256:" .. string.rep("A", 64),
    }),
  } },
  { "numeric input identity", {
    malformed_event("slot"), malformed_event("result", { input_identity = 3 }),
  } },
  { "foreign slot", {
    malformed_event("slot", { target_rule = "Missing" }), malformed_event("result"),
  } },
  { "foreign result rule", {
    malformed_event("slot"), malformed_event("result", { rule_label = "Missing" }),
  } },
}

check_equal(#malformed, 41, "malformed observation case count")
for _, case in ipairs(malformed) do capture_derivation_error(base, case[2], case[1]) end

local unrelated = linkedspec.semantic_index([[
Top::
 /a/ -> Top[0] { return("top") }

Other::
 /b/ -> Other[0] { return("other") }
]], { logical_name = "unrelated.spec", source_detail_ceiling = "text" })
local unrelated_error = capture_derivation_error(unrelated, {
  malformed_event("slot", { rule_label = "Top", target_rule = "Other" }),
  malformed_event("result"),
}, "unrelated selecting rule")
check_contains(unrelated_error.message, "does not select regex slot", "unrelated topology diagnostic")

capture_derivation_error(repeated, valid_events(), "already observed base")
local failed = linkedspec.semantic_index("Top:: Missing\n", {
  logical_name = "failed.spec",
  source_detail_ceiling = "span",
})
check_equal(failed:semantic_snapshot().state, "failed_compilation", "failed base state")
capture_derivation_error(failed, valid_events(), "failed base")

local materializations = 0
local original_materialize = static_projection.materialize
local original_hash = sha256.hex
static_projection.materialize = function(...)
  materializations = materializations + 1
  return original_materialize(...)
end
sha256.hex = function() error("unexpected derivation hash", 0) end
local authority_ok, authority_result = pcall(
  base.with_execution_observation,
  base,
  valid_events()
)
static_projection.materialize = original_materialize
sha256.hex = original_hash
check_equal(authority_ok, true, "derivation avoids hashing and retained authority")
check_equal(materializations, 1, "derivation materializes static projection exactly once")
check_equal(authority_result:semantic_snapshot().has_execution, true,
  "authority-trapped derivation succeeds")

check_equal(linkedspec.with_execution_observation, nil, "root has no detached derivation function")
check_equal(linkedspec.semantic_runtime_projection, nil, "root exposes no runtime projection")
check_equal(linkedspec._event_for_testing, nil, "root exposes no malformed-event constructor")

local implementation = read_file("lua/src/linkedspec/semantic_runtime_projection.lua")
for _, forbidden in ipairs({
  "parse_spec(",
  "validate_spec(",
  "compile_spec(",
  "runtime_parse(",
  "runtime_execute(",
  "semantic_observation_sink",
  'require("linkedspec.sha256")',
  'require("linkedspec.trace")',
  "io.",
  "os.",
  "loadfile",
  "dofile",
  "package.loadlib",
}) do
  check_equal(implementation:find(forbidden, 1, true), nil,
    "runtime projection forbids " .. forbidden)
end
local index_source = read_file("lua/src/linkedspec/semantic_index.lua")
local derivation_source = assert(index_source:match(
  "function INDEX_METHODS%.with_execution_observation.-\nend"
))
local _, materialize_count = derivation_source:gsub("materialize_static_projection", "")
check_equal(materialize_count, 1, "public derivation materializes exactly once")

if #failures == 0 then
  io.stdout:write("Lua immutable semantic runtime projection: ", assertions,
    " assertions passed\n")
else
  io.stderr:write("Lua immutable semantic runtime projection: ", #failures, " of ", assertions,
    " assertions failed\n")
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
