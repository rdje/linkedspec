-- FUTURE-PARITY-BACKLOG.10.7.3.2.1 — remaining private static targets.

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

local function detached(value)
  return json.decode(json.encode(value))
end

local function snapshot_by_id(model, snapshot_id)
  for _, snapshot in ipairs(model.snapshots) do
    if snapshot.id == snapshot_id then return snapshot end
  end
  error("missing semantic snapshot " .. snapshot_id, 0)
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
      if type(item.source) == "string" then item.source = detached(source_refs[item.source]) end
    end
  end
  return result
end

local function runtime_static_expected(model)
  local result = expected_snapshot(model, "runtime")
  local records = json.array()
  local retained = {}
  for _, item in ipairs(result.records) do
    if item.kind ~= "execution" and item.kind ~= "event" then
      records[#records + 1] = item
      retained[item.id] = true
    end
  end
  local relations = json.array()
  for _, item in ipairs(result.relations) do
    if retained[item.from_id] and retained[item.to_id] then relations[#relations + 1] = item end
  end
  result.records = records
  result.relations = relations
  result.snapshot.has_execution = false
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

local function count_relations(projection, kind)
  local count = 0
  for _, item in ipairs(projection.relations) do
    if item.kind == kind then count = count + 1 end
  end
  return count
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

local model = json.decode(read_file("capability_conformance/semantic_introspection_model.json"))
local fixture_root = "capability_conformance/semantic_introspection/"

for _, case in ipairs({
  { "privacy", "text", "text", true },
  { "privacy_limited", "identity", "identity", false },
}) do
  local index = linkedspec.semantic_index(
    read_file(fixture_root .. "privacy.spec"),
    options("privacy.spec", case[2])
  )
  local raw = semantic_index_module._static_projection_for_testing(index)
  local actual = materialize_sources(raw)
  local expected = materialize_sources(expected_snapshot(model, case[1]))
  check_equal(json.encode(actual), json.encode(expected), case[1] .. " deep equality")
  check_equal(#actual.records, 4, case[1] .. " record count")
  check_equal(#actual.relations, 3, case[1] .. " relation count")
  check_equal(actual.snapshot.source_detail_ceiling, case[3], case[1] .. " ceiling")
  check_equal(actual.snapshot.content_digest_available, case[4], case[1] .. " digest policy")
  check_equal(count_keys(raw.source_refs), 2, case[1] .. " private source retention")

  local rule = record_by_id(actual, "rule:T%C3%B6p")
  local slot = record_by_id(actual, "regex:rule:T%C3%B6p:0")
  check_equal(rule.name, "Töp", case[1] .. " Unicode rule name")
  check_equal(rule.source.span.start_byte, 0, case[1] .. " rule start byte")
  check_equal(rule.source.span.end_byte, 6, case[1] .. " rule end byte")
  check_equal(rule.source.excerpt, "Töp::", case[1] .. " rule excerpt")
  check_equal(slot.facts.pattern, "é", case[1] .. " Unicode regex pattern")
  check_equal(slot.source.span.start_column, 2, case[1] .. " slot start column")
  check_equal(slot.source.span.end_column, 5, case[1] .. " slot end column")
end

local runtime_index = linkedspec.semantic_index(
  read_file(fixture_root .. "runtime.spec"),
  options("runtime.spec", "text")
)
local runtime = materialize_sources(
  semantic_index_module._static_projection_for_testing(runtime_index)
)
local runtime_expected = materialize_sources(runtime_static_expected(model))
check_equal(json.encode(runtime), json.encode(runtime_expected), "runtime-static deep equality")
check_equal(#runtime.records, 7, "runtime-static record count")
check_equal(#runtime.relations, 8, "runtime-static relation count")
check_equal(runtime.snapshot.has_execution, false, "runtime-static execution absence")
check_equal(#records_of_kind(runtime, "execution"), 0, "runtime-static execution records absent")
check_equal(#records_of_kind(runtime, "event"), 0, "runtime-static event records absent")
check_equal(count_relations(runtime, "observed_as"), 0, "runtime-static observations absent")
check_equal(count_relations(runtime, "dispatches_to"), 0, "runtime-static self dispatch absent")
check_equal(count_relations(runtime, "selects_regex"), 2, "runtime-static slot selections")
local runtime_rule = record_by_id(runtime, "rule:Top")
check_equal(runtime_rule.facts.is_repetition, true, "runtime repetition")
check_equal(runtime_rule.facts.rep_min, 2, "runtime repetition minimum")
check_equal(runtime_rule.facts.rep_max, 2, "runtime repetition maximum")
check_equal(record_by_id(runtime, "regex:rule:Top:0").facts.pattern, "a", "runtime first slot")
check_equal(record_by_id(runtime, "regex:rule:Top:1").facts.pattern, "b", "runtime second slot")

local failed_index = linkedspec.semantic_index(
  read_file(fixture_root .. "failed.spec"),
  options("failed.spec", "span")
)
local native_failure = failed_index:compilation_diagnostic():to_json()
check_equal(native_failure.code, "bare_edge_target_undefined", "native failure code preserved")
check_equal(native_failure.stage, "normalize_edges", "native failure stage preserved")
check_equal(
  native_failure.message,
  "bare edge in rule 'Top' targets undefined rule 'Missing'",
  "native failure message preserved"
)
check_equal(native_failure.fields.rule_label, "Top", "native failure rule field")
check_equal(native_failure.fields.target, "Missing", "native failure target field")

local failed_raw = semantic_index_module._static_projection_for_testing(failed_index)
local failed = materialize_sources(failed_raw)
local failed_expected = materialize_sources(expected_snapshot(model, "failed"))
check_equal(json.encode(failed), json.encode(failed_expected), "failed projection deep equality")
check_equal(#failed.records, 6, "failed record count")
check_equal(#failed.relations, 4, "failed relation count")
check_equal(failed.snapshot.state, "failed_compilation", "failed snapshot state")
check_equal(failed.snapshot.source_detail_ceiling, "span", "failed snapshot ceiling")
check_equal(failed.snapshot.content_digest_available, false, "failed snapshot digest policy")
local diagnostic = record_by_id(failed, "diagnostic:compile:0")
check_equal(diagnostic.facts.code, "unknown_rule_reference", "portable failure code")
check_equal(diagnostic.facts.stage, "compile", "portable failure stage")
check_equal(diagnostic.facts.fields.rule_id, "rule:Top", "portable failure rule id")
check_equal(diagnostic.facts.fields.missing_rule_id, "rule:Missing", "portable missing rule id")
check_equal(diagnostic.source.excerpt, "Missing", "portable failure excerpt")
check_equal(diagnostic.source.span.start_byte, 6, "portable failure start byte")
check_equal(diagnostic.source.span.end_byte, 13, "portable failure end byte")
check_equal(record_by_id(failed, "rule:Top").facts.edge_ownership, "action", "failed rule edge")
check_equal(count_relations(failed, "diagnoses"), 1, "failed diagnostic relation")
check_equal(count_relations(failed, "explained_by"), 1, "failed explanation relation")

local repeated_index = linkedspec.semantic_index(
  "Top::\n /x/\n E { return(\"first\") }\n E { return([\"second\"]) }\n",
  options("repeated-lifecycle.spec", "text")
)
local repeated = materialize_sources(
  semantic_index_module._static_projection_for_testing(repeated_index)
)
local lifecycles = records_of_kind(repeated, "lifecycle")
check_equal(#lifecycles, 2, "repeated lifecycle count")
check_equal(lifecycles[1].id, "lifecycle:rule:Top:E:0", "first lifecycle id")
check_equal(lifecycles[2].id, "lifecycle:rule:Top:E:1", "second lifecycle id")
check_equal(lifecycles[1].order, 0, "first lifecycle order")
check_equal(lifecycles[2].order, 1, "second lifecycle order")
check_equal(lifecycles[1].facts.value_shape.kind, "string", "first lifecycle shape")
check_equal(lifecycles[2].facts.value_shape.kind, "array", "second lifecycle shape")
check_equal(lifecycles[1].source.excerpt, 'E { return("first") }', "first lifecycle source")
check_equal(lifecycles[2].source.excerpt, 'E { return(["second"]) }', "second lifecycle source")
check_equal(lifecycles[1].source.span.start_line, 3, "first lifecycle line")
check_equal(lifecycles[2].source.span.start_line, 4, "second lifecycle line")

for _, index in ipairs({
  linkedspec.semantic_index(read_file(fixture_root .. "privacy.spec"), options("privacy.spec", "text")),
  linkedspec.semantic_index(read_file(fixture_root .. "privacy.spec"), options("privacy.spec", "identity")),
  failed_index,
  runtime_index,
}) do
  local projection = semantic_index_module._static_projection_for_testing(index)
  check(plain_and_host_free(projection), "projection contains only plain host-free values")
  check_equal(json.encode(detached(projection)), json.encode(projection), "projection JSON round-trip")
  local encoded = json.encode(projection)
  check(encoded:find("/" .. "Users/", 1, true) == nil, "projection excludes developer-home path")
  check(encoded:find("/" .. "home/", 1, true) == nil, "projection excludes Unix-home path")
  check(encoded:find("/" .. "tmp/", 1, true) == nil, "projection excludes temporary path")
end

failed_raw.records[4].facts.fields.missing_rule_id = "rule:Injected"
local failed_again = semantic_index_module._static_projection_for_testing(failed_index)
check_equal(
  record_by_id(failed_again, "diagnostic:compile:0").facts.fields.missing_rule_id,
  "rule:Missing",
  "failed projection clone detached"
)
check(failed_raw ~= failed_again, "projection materializations are fresh roots")

local parse_failure = linkedspec.semantic_index(
  "Top:::\n /x/\n",
  options("parse-failure.spec", "identity")
)
local parse_projection = semantic_index_module._static_projection_for_testing(parse_failure)
check_equal(#parse_projection.records, 3, "parse-failure record count")
check_equal(#parse_projection.relations, 2, "parse-failure relation count")
check_equal(
  record_by_id(parse_projection, "diagnostic:compile:0").facts.code,
  "semantic_index_parse_failed",
  "parse-failure fallback code"
)

local missing_entry = linkedspec.semantic_index(
  "Top::\n /x/\n",
  options("missing-entry.spec", "identity", "Missing")
)
local missing_projection = semantic_index_module._static_projection_for_testing(missing_entry)
check_equal(#missing_projection.records, 4, "missing-entry record count")
check_equal(#missing_projection.relations, 2, "missing-entry relation count")
check_equal(
  record_by_id(missing_projection, "diagnostic:compile:0").facts.code,
  "entry_rule_not_found",
  "missing-entry fallback code"
)

check_equal(next(failed_index), nil, "index raw state remains empty")
check_equal(getmetatable(failed_index), "protected", "index metatable protected")
local immutable_ok = pcall(function() failed_index.injected = true end)
check_equal(immutable_ok, false, "index mutation rejected")
check_equal(linkedspec._static_projection_for_testing, nil, "root exports no test materializer")
check_equal(linkedspec.semantic_static_projection, nil, "root exports no static projection")
check_equal(linkedspec.semantic_records, nil, "root exports no semantic records")
check_equal(linkedspec.semantic_query, nil, "root exports no semantic query")

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
  io.stderr:write("semantic static remaining failures:\n")
  for _, failure in ipairs(failures) do io.stderr:write("- " .. failure .. "\n") end
  os.exit(1)
end

print("semantic static remaining assertions: " .. assertions)
