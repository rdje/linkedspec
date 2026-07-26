-- FUTURE-PARITY-BACKLOG.10.7.3.1 — private immutable static graph projection.

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

local function options(logical_name, source_detail_ceiling, entry_rule)
  return {
    logical_name = logical_name,
    source_detail_ceiling = source_detail_ceiling,
    entry_rule = entry_rule,
  }
end

local function snapshot_by_id(model, snapshot_id)
  for _, snapshot in ipairs(model.snapshots) do
    if snapshot.id == snapshot_id then return snapshot end
  end
  error("missing semantic snapshot " .. snapshot_id, 0)
end

local function detached(value)
  return json.decode(json.encode(value))
end

local function expected_snapshot(model, snapshot_id)
  local result = detached(snapshot_by_id(model, snapshot_id))
  result.id = nil
  result.fixture = nil
  return result
end

local function materialize_sources(projection)
  local result = detached(projection)
  local source_refs = result.source_refs
  result.source_refs = nil
  for _, group in ipairs({ "records", "relations" }) do
    for _, item in ipairs(result[group]) do
      if type(item.source) == "string" then
        item.source = detached(source_refs[item.source])
      end
    end
  end
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
    source_text = true,
    source_bytes = true,
    ast = true,
    action_ir = true,
    descriptor = true,
    compiled_regex = true,
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

local function records_of_kind(projection, kind)
  local result = {}
  for _, item in ipairs(projection.records) do
    if item.kind == kind then result[#result + 1] = item end
  end
  return result
end

local model = json.decode(read_file("capability_conformance/semantic_introspection_model.json"))
local graph_source = read_file("capability_conformance/semantic_introspection/graph.spec")
local graph_index = linkedspec.semantic_index(graph_source, options("graph.spec", "text"))
local projection = semantic_index_module._static_projection_for_testing(graph_index)
local expected = expected_snapshot(model, "graph")

check_equal(#projection.records, 12, "graph record count")
check_equal(#projection.relations, 14, "graph relation count")
check_equal(count_keys(projection.source_refs), 7, "graph source-reference count")
check_equal(
  json.encode(materialize_sources(projection)),
  json.encode(materialize_sources(expected)),
  "graph projection deep equality"
)
check_equal(json.encode(detached(projection)), json.encode(projection), "projection JSON round-trip")
check(plain_and_host_free(projection), "projection contains only plain portable values")

check_equal(projection.snapshot.id, "snapshot:0", "snapshot id")
check_equal(projection.snapshot.state, "compiled", "snapshot state")
check_equal(projection.snapshot.has_execution, false, "snapshot execution absence")
check_equal(projection.snapshot.source_detail_ceiling, "text", "snapshot construction ceiling")
check_equal(projection.snapshot.content_digest_available, true, "snapshot digest availability")

local rules = records_of_kind(projection, "rule")
local slots = records_of_kind(projection, "regex_slot")
local edges = records_of_kind(projection, "edge")
local lifecycles = records_of_kind(projection, "lifecycle")
check_equal(#rules, 2, "graph rule count")
check_equal(#slots, 2, "graph slot count excludes Top parent matchers")
check_equal(slots[1].id, "regex:rule:Child:0", "first duplicate slot id")
check_equal(slots[2].id, "regex:rule:Child:1", "second duplicate slot id")
check_equal(slots[1].facts.pattern, "a", "first duplicate pattern")
check_equal(slots[2].facts.pattern, "a", "second duplicate pattern")
check_equal(#edges, 2, "graph edge count")
check_equal(edges[1].facts.source_form, "indexed", "first edge source form")
check_equal(edges[2].facts.source_form, "indexed", "second edge source form")
check_equal(edges[1].facts.value_shape.kind, "string", "first edge return shape")
check_equal(edges[2].facts.value_shape.kind, "string", "second edge return shape")
check_equal(#lifecycles, 1, "graph lifecycle count")
check_equal(lifecycles[1].id, "lifecycle:rule:Top:E:0", "lifecycle occurrence id")
check_equal(lifecycles[1].facts.value_shape.kind, "array", "lifecycle return shape")
check_equal(lifecycles[1].facts.value_shape.element.kind, "string", "lifecycle element shape")

local edge_source = projection.source_refs["source_ref:edge:rule:Top:0"]
check_equal(edge_source.excerpt, '/a/ -> Child[0] { return("first") }', "complete edge excerpt")
check_equal(edge_source.span.start_byte, 10, "edge source start byte")
check_equal(edge_source.span.end_byte, 45, "edge source end byte")
check_equal(edge_source.span.start_line, 2, "edge source start line")
check_equal(edge_source.span.start_column, 2, "edge source start column")
check_equal(edge_source.span.end_column, 37, "edge source end column")
check_equal(
  edge_source.content_digest,
  "sha256:28505ba8524900f55e11452988acc6b7d35dccbccc1c0cb6194c8cda80a0cbcf",
  "edge source digest"
)

local relation_counts = {}
for _, relation in ipairs(projection.relations) do
  relation_counts[relation.kind] = (relation_counts[relation.kind] or 0) + 1
end
check_equal(relation_counts.declares, 2, "declares relation count")
check_equal(relation_counts.contains, 6, "contains relation count")
check_equal(relation_counts.dispatches_to, 2, "dispatch relation count")
check_equal(relation_counts.selects_regex, 2, "slot-selection relation count")
check_equal(relation_counts.explained_by, 2, "entry explanation relation count")

projection.records[1].facts.definition_order[1] = "rule:Injected"
projection.source_refs["source_ref:rule:Top"].logical_name = "/tmp/private.spec"
projection.relations[1].facts.injected = true
local second_projection = semantic_index_module._static_projection_for_testing(graph_index)
check_equal(second_projection.records[1].facts.definition_order[1], "rule:Top", "record clone detached")
check_equal(
  second_projection.source_refs["source_ref:rule:Top"].logical_name,
  "graph.spec",
  "source clone detached"
)
check_equal(second_projection.relations[1].facts.injected, nil, "relation clone detached")
check(projection ~= second_projection, "materializations are fresh roots")

check_equal(getmetatable(graph_index), "protected", "index metatable protected")
check_equal(next(graph_index), nil, "index raw state remains empty")
check_equal(graph_index.static_projection, nil, "index exposes no static projection property")
check_equal(linkedspec._static_projection_for_testing, nil, "root exports no test materializer")
check_equal(linkedspec.semantic_static_projection, nil, "root exports no static graph accessor")
check_equal(linkedspec.semantic_records, nil, "root exports no semantic record accessor")

local default_index = linkedspec.semantic_index(
  "Top::\n /x/\n",
  options("default.spec", "text")
)
local default_projection = semantic_index_module._static_projection_for_testing(default_index)
local default_rule = records_of_kind(default_projection, "rule")[1]
check_equal(default_rule.facts.is_repetition, false, "Default neutral repetition")
check_equal(default_rule.facts.rep_min, json.null, "Default neutral minimum")
check_equal(default_rule.facts.rep_max, json.null, "Default neutral maximum")

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
}) do
  check(implementation:find(forbidden, 1, true) == nil, "implementation excludes " .. forbidden)
end

if #failures > 0 then
  io.stderr:write("semantic static graph failures:\n")
  for _, failure in ipairs(failures) do io.stderr:write("- " .. failure .. "\n") end
  os.exit(1)
end

print("semantic static graph assertions: " .. assertions)
