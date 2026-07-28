-- FUTURE-PARITY-BACKLOG.10.7.4.1 — exact private typed call core.

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

local function options(logical_name)
  return {
    logical_name = logical_name,
    source_detail_ceiling = "text",
  }
end

local function detached(value)
  return json.decode(json.encode(value))
end

local function snapshot_by_id(model, snapshot_id)
  for _, snapshot in ipairs(model.snapshots) do
    if snapshot.id == snapshot_id then return snapshot end
  end
  error("missing semantic snapshot " .. snapshot_id, 0)
end

local function expected_core(model)
  local result = detached(snapshot_by_id(model, "calls"))
  result.id = nil
  result.fixture = nil
  local records = json.array()
  local retained = {}
  for _, item in ipairs(result.records) do
    if item.kind ~= "staged_artifact" and item.kind ~= "generated_artifact" then
      records[#records + 1] = item
      retained[item.id] = true
    end
  end
  local relations = json.array()
  for _, item in ipairs(result.relations) do
    if retained[item.from_id] and retained[item.to_id] then
      relations[#relations + 1] = item
    end
  end
  result.records = records
  result.relations = relations
  return result
end

local function core_subset(projection)
  local result = detached(projection)
  local records = json.array()
  local retained = {}
  for _, item in ipairs(result.records) do
    if item.kind ~= "staged_artifact" and item.kind ~= "generated_artifact" then
      records[#records + 1] = item
      retained[item.id] = true
    end
  end
  local relations = json.array()
  for _, item in ipairs(result.relations) do
    if retained[item.from_id] and retained[item.to_id] then
      relations[#relations + 1] = item
    end
  end
  result.records = records
  result.relations = relations
  return result
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

local function call_index(source, logical_name)
  return linkedspec.semantic_index(source, options(logical_name or "calls_and_staging.spec"))
end

local function projection_for(source, logical_name)
  return semantic_index_module._static_projection_for_testing(call_index(source, logical_name))
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

local function count_relations(projection, kind)
  local count = 0
  for _, item in ipairs(projection.relations) do
    if item.kind == kind then count = count + 1 end
  end
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

local fixture_root = "capability_conformance/semantic_introspection/"
local model = json.decode(read_file("capability_conformance/semantic_introspection_model.json"))
local source = read_file(fixture_root .. "calls_and_staging.spec")
local index = call_index(source)
local full_projection = semantic_index_module._static_projection_for_testing(index)
local projection = core_subset(full_projection)
local actual = materialize_sources(projection)
local expected = materialize_sources(expected_core(model))

check_equal(#projection.records, 18, "typed core record count")
check_equal(#projection.relations, 16, "typed core relation count")
check_equal(count_keys(projection.source_refs), 10, "typed core source-ref count")
check_equal(json.encode(actual), json.encode(expected), "typed core governed deep equality")
check_equal(#records_of_kind(projection, "staged_artifact"), 0, "staged records absent")
check_equal(#records_of_kind(projection, "generated_artifact"), 0, "generated records absent")
for _, kind in ipairs({ "consumes", "produces", "lowered_from", "staged_by", "generated_as" }) do
  check_equal(count_relations(projection, kind), 0, kind .. " relations absent")
end

local spec = record_by_id(projection, "spec:0")
check_equal(json.encode(spec.facts.definition_order), json.encode(json.array({
  "function:normalize",
  "rule:Top",
  "rule:Done",
})), "merged authored definition order")
check_equal(json.encode(spec.facts.compiled_rule_order),
  json.encode(json.array({ "rule:Top", "rule:Done" })), "compiled rule-only order")

local helpers = records_of_kind(projection, "helper")
check_equal(#helpers, 3, "narrow helper count")
check_equal(helpers[1].id, "helper:trim", "first helper id")
check_equal(helpers[2].id, "helper:match_text", "second helper id")
check_equal(helpers[3].id, "helper:return", "third helper id")

local calls = records_of_kind(projection, "call")
local expected_call_ids = {
  "call:function:normalize:0",
  "call:edge:rule:Top:0:0",
  "call:edge:rule:Top:0:1",
  "call:edge:rule:Top:0:2",
}
check_equal(#calls, #expected_call_ids, "typed call count")
for index, id in ipairs(expected_call_ids) do
  check_equal(calls[index].id, id, "typed call id " .. (index - 1))
  check_equal(calls[index].order, index - 1, "typed call global order " .. (index - 1))
end

local function_record = record_by_id(projection, "function:normalize")
check_equal(json.encode(function_record.facts.signature), json.encode(json.harray({
  parameters = json.array({ json.harray({ name = "value", kind = "value", required = true }) }),
  arity_min = 1,
  arity_max = 1,
  rest_parameter = json.null,
  final_codeblock = false,
})), "fixed function signature")
check_equal(json.encode(function_record.facts.parameter_kinds),
  json.encode(json.array({ "value" })), "fixed parameter kinds")
check_equal(function_record.facts.return_shape.kind, "string", "function return shape")

local normalize_call = record_by_id(projection, "call:edge:rule:Top:0:0")
check_equal(normalize_call.facts.resolution_kind, "user_function", "user-function resolution")
check_equal(normalize_call.facts.argument_shapes[1].kind, "string", "user-function argument shape")
check_equal(normalize_call.facts.return_shape.kind, "string", "user-function return shape")
check_equal(normalize_call.facts.target_shape.kind, "user_function", "user-function target shape")
check_equal(record_by_id(projection,
  "binding:edge:rule:Top:0:result:0").facts.value_shape.kind, "string", "binding shape")
check_equal(record_by_id(projection, "edge:rule:Top:0").facts.value_shape.kind,
  "string", "edge shape")
check_equal(record_by_id(projection, "rule:Top").facts.value_shape.kind,
  "string", "rule shape")

local relations = relation_ids(projection)
for _, id in ipairs({
  "relation:calls:call:edge:rule:Top:0:0:function:normalize:0",
  "relation:writes:call:edge:rule:Top:0:0:binding:edge:rule:Top:0:result:0:0",
  "relation:reads:call:edge:rule:Top:0:2:binding:edge:rule:Top:0:result:0:0",
}) do
  check(relations[id], "relation present " .. id)
end
check_equal(count_relations(projection, "explained_by"), 2, "call explanation relation count")

local unicode_source = [[Top::
 /x/ -> Done {
   result = normalize(match_text())
   return(result)
 }

fn normalize(value) { return(trim("é")) }

Done:
 /x/
]]
local unicode = projection_for(unicode_source, "unicode-calls.spec")
check_equal(json.encode(record_by_id(unicode, "spec:0").facts.definition_order),
  json.encode(json.array({ "rule:Top", "function:normalize", "rule:Done" })),
  "Unicode authored definition order")
local unicode_call = record_by_id(unicode, "call:function:normalize:0")
local unicode_source_ref = unicode.source_refs[unicode_call.source]
check_equal(unicode_source_ref.excerpt, 'trim("é")', "Unicode call excerpt")
check_equal(unicode_source_ref.span.end_byte - unicode_source_ref.span.start_byte,
  #'trim("é")', "Unicode call byte width")
check_equal(unicode_source_ref.span.end_column - unicode_source_ref.span.start_column,
  9, "Unicode call scalar width")
check(#'trim("é")' > 9, "Unicode byte and scalar widths differ")
check_equal(unicode.source_refs[record_by_id(unicode, "function:normalize").source].excerpt,
  'fn normalize(value) { return(trim("é")) }', "Unicode function excerpt")

local duplicate_source = [[fn normalize(value) { return(trim(value)) }

Top::
 /x/ -> Done {
   result = normalize(normalize(match_text()))
   return(result)
 }

Done:
 /x/
]]
local duplicate = projection_for(duplicate_source, "duplicate-calls.spec")
local duplicate_calls = records_of_kind(duplicate, "call")
local duplicate_names = { "trim", "normalize", "normalize", "match_text", "return" }
local duplicate_excerpts = {
  "trim(value)",
  "normalize(normalize(match_text()))",
  "normalize(match_text())",
  "match_text()",
  "return(result)",
}
check_equal(#duplicate_calls, #duplicate_names, "duplicate nested call count")
for index, item in ipairs(duplicate_calls) do
  check_equal(item.name, duplicate_names[index], "duplicate call name " .. (index - 1))
  check_equal(duplicate.source_refs[item.source].excerpt, duplicate_excerpts[index],
    "duplicate call excerpt " .. (index - 1))
  check_equal(item.order, index - 1, "duplicate call order " .. (index - 1))
end
check_equal(count_relations(duplicate, "calls"), 2, "duplicate user-function call relations")

local regex_source = [[fn normalize(value) {
 note = "trim(ghost())"
 pattern = /trim(fake())/i
 return(trim(value))
}

Top:
 /x/
]]
local regex_projection = projection_for(regex_source, "regex-call-text.spec")
local regex_call = record_by_id(regex_projection, "call:function:normalize:0")
check_equal(regex_call.name, "trim", "regex text cannot become a call")
check_equal(regex_projection.source_refs[regex_call.source].excerpt,
  "trim(value)", "regex text cannot steal call source")
for _, item in ipairs(regex_projection.records) do
  check(item.name ~= "fake", "regex fake call is absent")
  check(item.name ~= "ghost", "quoted ghost call is absent")
end

local variadic_source = [[fn gather(prefix, ...items) { return(items) }

Top::
 /x/ -> Done { return(gather("p", "a", "b")) }

Done:
 /x/
]]
local variadic = projection_for(variadic_source, "variadic-calls.spec")
local gather = record_by_id(variadic, "function:gather")
check_equal(gather.facts.signature.arity_min, 1, "variadic minimum")
check_equal(gather.facts.signature.arity_max, json.null, "variadic maximum")
check_equal(gather.facts.signature.rest_parameter, "items", "variadic rest parameter")
check_equal(gather.facts.signature.final_codeblock, false, "variadic final codeblock")
check_equal(gather.facts.return_shape.kind, "array", "variadic return shape")
check_equal(gather.facts.return_shape.element.kind, "unknown", "variadic element shape")
local gather_call = record_by_id(variadic, "call:edge:rule:Top:0:1")
check_equal(gather_call.name, "gather", "variadic call name")
check_equal(gather_call.facts.resolution_kind, "user_function", "variadic user resolution")
check_equal(#gather_call.facts.argument_shapes, 3, "variadic argument count")
for _, shape in ipairs(gather_call.facts.argument_shapes) do
  check_equal(shape.kind, "string", "variadic argument shape")
end
check_equal(gather_call.facts.return_shape.kind, "array", "variadic call shape")
check_equal(record_by_id(variadic, "edge:rule:Top:0").facts.value_shape.kind,
  "array", "variadic edge shape")

projection.records[1].facts.definition_order[1] = "rule:Injected"
projection.source_refs[record_by_id(projection, "call:function:normalize:0").source].excerpt =
  "/tmp/injected"
projection.relations[1].facts.injected = true
local second_projection = semantic_index_module._static_projection_for_testing(index)
check_equal(record_by_id(second_projection, "spec:0").facts.definition_order[1],
  "function:normalize", "record clone detached")
check_equal(second_projection.source_refs[
  record_by_id(second_projection, "call:function:normalize:0").source
].excerpt, "trim(value)", "source clone detached")
check_equal(second_projection.relations[1].facts.injected, nil, "relation clone detached")
check(projection ~= second_projection, "materializations are fresh roots")
check_equal(json.encode(detached(second_projection)), json.encode(second_projection),
  "projection JSON round-trip")
check(plain_and_host_free(second_projection), "projection contains only plain host-free values")
local encoded = json.encode(second_projection)
check(encoded:find("/" .. "Users/", 1, true) == nil, "projection excludes developer-home path")
check(encoded:find("/" .. "home/", 1, true) == nil, "projection excludes Unix-home path")
check(encoded:find("/" .. "tmp/", 1, true) == nil, "projection excludes temporary path")

check_equal(getmetatable(index), "protected", "index metatable protected")
check_equal(next(index), nil, "index raw state remains empty")
check_equal(index.static_projection, nil, "index exposes no static projection property")
check_equal(linkedspec._static_projection_for_testing, nil, "root exports no test materializer")
check_equal(linkedspec.semantic_static_projection, nil, "root exports no static projection")
check_equal(linkedspec.semantic_call_projection, nil, "root exports no call projection")
check_equal(linkedspec.semantic_calls, nil, "root exports no call accessor")

local implementation = read_file("lua/src/linkedspec/semantic_static_projection.lua")
for _, forbidden in ipairs({
  'require("linkedspec.spec_parser")',
  'require("linkedspec.compiled_spec")',
  'require("linkedspec.source_emitter")',
  'require("linkedspec.interpreter")',
  'require("linkedspec.matching")',
  "runtime_execute(",
  "execute_generated",
  "diagnostic_sink",
  "semantic_observation",
  "os.getenv",
  "io.open",
  "loadfile",
  "dofile",
  "os.clock",
  "math.random",
}) do
  check(implementation:find(forbidden, 1, true) == nil, "implementation excludes " .. forbidden)
end

if #failures > 0 then
  io.stderr:write("semantic typed call core failures:\n")
  for _, failure in ipairs(failures) do io.stderr:write("- " .. failure .. "\n") end
  os.exit(1)
end

print("semantic typed call core assertions: " .. assertions)
