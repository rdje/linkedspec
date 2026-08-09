-- FUTURE-PARITY-BACKLOG.14.2.5.0.2 — dormant shared Lua typed source-location RED.
--
-- Ordinary Lua discovery is the explicit list in `tools/run_lua_local.sh`; that
-- list deliberately omits this pre-admission consumer. Run either mode through
-- repository-local project data from the repository root:
--
--   LINKEDSPEC_LUA_TYPED_SOURCE_RED_MODE=core \
--     bash tools/run_lua_project_data.sh puc lua/test/typed_source_location_contract_test.lua
--   LINKEDSPEC_LUA_TYPED_SOURCE_RED_MODE=core \
--     bash tools/run_lua_project_data.sh luajit lua/test/typed_source_location_contract_test.lua
--
--   LINKEDSPEC_LUA_TYPED_SOURCE_RED_MODE=projection \
--     bash tools/run_lua_project_data.sh puc lua/test/typed_source_location_contract_test.lua
--   LINKEDSPEC_LUA_TYPED_SOURCE_RED_MODE=projection \
--     bash tools/run_lua_project_data.sh luajit lua/test/typed_source_location_contract_test.lua
--
-- Core implementation makes `core` green. Projection implementation then
-- makes the independently nested `projection` mode green. Admission removes
-- this mode switch and adds the unchanged assertions to ordinary discovery.

local mode = os.getenv("LINKEDSPEC_LUA_TYPED_SOURCE_RED_MODE") or "core"
if mode ~= "core" and mode ~= "projection" then
  error(
    "LINKEDSPEC_LUA_TYPED_SOURCE_RED_MODE must be 'core' or 'projection', got '" ..
      tostring(mode) .. "'",
    0
  )
end

local json = require("linkedspec.json")

-- Core lookup is deliberately first. Convert only the ordinary absent-module
-- diagnostic to one stable RED boundary; propagate every other load failure.
local source_location_ok, source_location = pcall(require, "linkedspec.source_location")
if not source_location_ok then
  if tostring(source_location):match("module 'linkedspec%.source_location' not found") then
    error("Lua typed source RED: missing linkedspec.source_location", 0)
  end
  error(source_location, 0)
end

local linkedspec = require("linkedspec")

-- Projection lookup is strictly nested after the immutable core. Today both
-- modes stop at the missing module. Once the core lands, projection mode must
-- advance to these separately owned catalog APIs.
local typed_source_projection_rows
local typed_source_compatibility_aliases
if mode == "projection" then
  if type(linkedspec.typed_source_projection_rows) ~= "function" then
    error("Lua typed source RED: missing linkedspec.typed_source_projection_rows", 0)
  end
  if type(linkedspec.typed_source_compatibility_aliases) ~= "function" then
    error("Lua typed source RED: missing linkedspec.typed_source_compatibility_aliases", 0)
  end
  typed_source_projection_rows = linkedspec.typed_source_projection_rows
  typed_source_compatibility_aliases = linkedspec.typed_source_compatibility_aliases
end

local assertions = 0
local failures = {}

local function check(condition, label)
  assertions = assertions + 1
  if not condition then failures[#failures + 1] = label end
end

local function check_equal(actual, expected, label)
  check(
    actual == expected,
    (label or "values differ") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual)
  )
end

local function check_same_json(actual, expected, label)
  if actual == nil or expected == nil then
    check_equal(actual, expected, label)
    return
  end
  check_equal(json.encode(actual), json.encode(expected), label)
end

local function capture(operation)
  local ok, value = pcall(operation)
  return ok, value
end

local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local value = assert(handle:read("*a"))
  assert(handle:close())
  return value
end

local contract = json.decode(read_file("capability_conformance/typed_source_location_contract.json"))
local context = source_location.source_location_context({
  rule_role = "typed_source_fixture_rule",
  invocation_role = "typed_source_fixture_invocation",
})

local cursor_source = [[Top::
 /ab/ -> Done {
  after_match = cursor_pos()
  save_cursor()
  rewind_match_start()
  match_start = cursor_pos()
  restore_cursor()
  restored_match = cursor_pos()
  save_cursor()
  rewind_entry_start()
  entry_start = cursor_pos()
  restore_cursor()
  restored_entry = cursor_pos()
  return(hash(
   "after_match", after_match,
   "match_start", match_start,
   "restored_match", restored_match,
   "entry_start", entry_start,
   "restored_entry", restored_entry
  ))
 }

Done:
 /ab/
]]

local cursor_expected = json.harray({
  after_match = 2,
  entry_start = 0,
  match_start = 0,
  restored_entry = 2,
  restored_match = 2,
})

local alias_source = [[Top::OR{1,1}
 /(?<name>ab)/
 I { started = capture_slice_here() }
 E {
  return(array(
   started,
   capture_from_rule_start(),
   capture_len_from_rule_start(),
   capture_slice_length(),
   capture_rest_length(),
   entry_named_map(),
   match_named_map()
  ))
 }
]]

local alias_expected = json.array({
  json.null,
  "é🙂  ",
  4,
  4,
  6,
  json.harray({ name = "ab" }),
  json.harray({ name = "ab" }),
})

local function decoded_sources()
  local sources = json.harray()
  for _, fixture in ipairs(contract.sources) do sources[fixture.id] = fixture.decoded_text end
  return sources
end

local function position(authority, source_id, offset)
  return source_location.position(authority, {
    source_id = source_id,
    offset = offset,
    context = context,
  })
end

local function diagnostic_by_id(diagnostic_id)
  for _, diagnostic in ipairs(contract.diagnostics) do
    if diagnostic.id == diagnostic_id then return diagnostic end
  end
  error("missing typed source diagnostic fixture '" .. diagnostic_id .. "'", 0)
end

local function check_diagnostic(diagnostic_id, operation, expected_context)
  local ok, captured = capture(operation)
  check_equal(ok, false, diagnostic_id .. " rejects invalid value")
  if ok then return end

  check_equal(source_location.is_error(captured), true, diagnostic_id .. " error type")
  if not source_location.is_error(captured) then return end

  local diagnostic = diagnostic_by_id(diagnostic_id)
  local record = source_location.to_json(captured)
  check_equal(record.code, diagnostic.code, diagnostic_id .. " code")
  check_equal(record.phase, diagnostic.phase, diagnostic_id .. " phase")
  for _, field in ipairs(diagnostic.required_context) do
    check(record[field] ~= nil, diagnostic_id .. " required context " .. field)
  end
  for field, expected in pairs(expected_context) do
    check_equal(record[field], expected, diagnostic_id .. " context " .. field)
  end
  for _, forbidden in ipairs({
    "decoded_text",
    "source_text",
    "path",
    "match",
    "parser_state",
    "host_reference",
  }) do
    check_equal(record[forbidden], nil, diagnostic_id .. " private field " .. forbidden)
  end
end

local function compile_source(source)
  local parsed = linkedspec.parse_spec(source)
  linkedspec.validate_spec(parsed)
  return parsed, linkedspec.compile_spec(parsed)
end

local function check_carriers(source, input, identity, expected)
  local parsed, compiled = compile_source(source)
  local native = linkedspec.runtime_parse(linkedspec.runtime_engine(compiled), input).value

  local reconstructed_spec = linkedspec.spec_ast.from_json(
    "SpecFile",
    json.decode(json.encode(linkedspec.spec_ast.to_json(parsed)))
  )
  linkedspec.validate_spec(reconstructed_spec)
  local reconstructed = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(reconstructed_spec)),
    input
  ).value

  local generated = linkedspec.execute_generated_parser_v2(
    compiled,
    linkedspec.build_generated_rule_plan(compiled),
    input,
    identity
  )

  check_same_json(native, expected, identity .. " native")
  check_same_json(reconstructed, expected, identity .. " reconstructed")
  check_same_json(generated, expected, identity .. " generated plan")
end

check_equal(contract.contract_id, "linkedspec-typed-source-location-v1", "contract id")
check_equal(contract.expected_counts.sources, 3, "source fixture count")
check_equal(contract.expected_counts.position_conversions, 7, "position fixture count")
check_equal(contract.expected_counts.direct_spans, 6, "direct-span fixture count")
check_equal(contract.expected_counts.derived_text_cases, 3, "derived-text fixture count")
check_equal(source_location.node_type(context), "SourceLocationContext", "typed context")

do
  local sources = decoded_sources()
  local authority = source_location.source_authority({ sources = sources })
  check_equal(source_location.node_type(authority), "SourceAuthority", "typed source authority")

  local positions = {}
  local function fixture_position(source_id, offset)
    local key = source_id .. "\0" .. offset
    if positions[key] == nil then positions[key] = position(authority, source_id, offset) end
    return positions[key]
  end

  for _, fixture in ipairs(contract.position_conversions) do
    local value = fixture_position(fixture.source_id, fixture.offset)
    check_equal(source_location.node_type(value), "Position", fixture.id .. " type")
    check_same_json(
      source_location.to_json(value),
      json.harray({ source_id = fixture.source_id, offset = fixture.offset }),
      fixture.id .. " value"
    )
    check_same_json(
      source_location.coordinates(authority, value, { context = context }),
      json.harray({
        source_id = fixture.source_id,
        offset = fixture.offset,
        line = fixture.line,
        column = fixture.column,
        utf8_byte_offset = fixture.utf8_byte_offset,
      }),
      fixture.id .. " coordinates"
    )
  end

  local stable_position = fixture_position("unicode", 1)
  local detached_position = source_location.to_json(stable_position)
  detached_position.offset = 99
  check_equal(source_location.to_json(stable_position).offset, 1, "position record is detached")

  local spans = {}
  for _, fixture in ipairs(contract.direct_spans) do
    local span = source_location.direct_span(authority, {
      start = fixture_position(fixture.source_id, fixture.start),
      ["end"] = fixture_position(fixture.source_id, fixture["end"]),
      provenance = fixture.provenance,
      context = context,
    })
    spans[fixture.id] = span
    check_equal(source_location.node_type(span), "Span", fixture.id .. " type")
    check_same_json(
      source_location.to_json(span),
      json.harray({
        source_id = fixture.source_id,
        start = fixture.start,
        ["end"] = fixture["end"],
        provenance = fixture.provenance,
      }),
      fixture.id .. " value"
    )
    check_equal(
      source_location.materialize(authority, span, { context = context }),
      fixture.expected_text,
      fixture.id .. " materialized text"
    )
  end

  for _, fixture in ipairs(contract.derived_text_cases) do
    local ordered_spans = json.array()
    for index, span_id in ipairs(fixture.span_ids) do ordered_spans[index] = spans[span_id] end
    local derived = source_location.derived_text(authority, {
      policy = fixture.policy,
      spans = ordered_spans,
      context = context,
    })
    local expected_spans = json.array()
    for index, span in ipairs(ordered_spans) do expected_spans[index] = source_location.to_json(span) end
    check_equal(source_location.node_type(derived), "DerivedText", fixture.id .. " type")
    check_same_json(
      source_location.to_json(derived),
      json.harray({ policy = "concatenate_in_order", spans = expected_spans }),
      fixture.id .. " value"
    )
    check_equal(
      source_location.materialize(authority, derived, { context = context }),
      fixture.expected_text,
      fixture.id .. " materialized text"
    )
  end

  sources.unicode = "changed"
  local owned_span = source_location.direct_span(authority, {
    start = fixture_position("unicode", 0),
    ["end"] = fixture_position("unicode", 1),
    provenance = "input",
    context = context,
  })
  check_equal(
    source_location.materialize(authority, owned_span, { context = context }),
    "é",
    "authority snapshots decoded input"
  )

  check_diagnostic("source_mismatch", function()
    return source_location.direct_span(authority, {
      start = fixture_position("unicode", 0),
      ["end"] = fixture_position("ascii", 1),
      provenance = "input",
      context = context,
    })
  end, {
    rule_role = "typed_source_fixture_rule",
    invocation_role = "typed_source_fixture_invocation",
    source_id = "unicode",
    other_source_id = "ascii",
  })

  check_diagnostic("position_out_of_range", function()
    return position(authority, "unicode", 5)
  end, {
    rule_role = "typed_source_fixture_rule",
    invocation_role = "typed_source_fixture_invocation",
    source_id = "unicode",
    position_offset = 5,
    source_length = 4,
  })

  check_diagnostic("reversed_span", function()
    return source_location.direct_span(authority, {
      start = fixture_position("unicode", 2),
      ["end"] = fixture_position("unicode", 1),
      provenance = "capture",
      context = context,
    })
  end, {
    rule_role = "typed_source_fixture_rule",
    invocation_role = "typed_source_fixture_invocation",
    source_id = "unicode",
    start_offset = 2,
    end_offset = 1,
  })

  local foreign_authority = source_location.source_authority({
    sources = json.harray({ foreign = "foreign text" }),
  })
  local foreign_span = source_location.direct_span(foreign_authority, {
    start = position(foreign_authority, "foreign", 0),
    ["end"] = position(foreign_authority, "foreign", 1),
    provenance = "input",
    context = context,
  })
  check_diagnostic("invalid_derived_provenance", function()
    return source_location.derived_text(authority, {
      policy = "concatenate_in_order",
      spans = json.array({ foreign_span }),
      context = context,
    })
  end, {
    rule_role = "typed_source_fixture_rule",
    invocation_role = "typed_source_fixture_invocation",
    provenance_index = 0,
    source_id = "foreign",
  })
end

if mode == "projection" then
  local _, catalog_compiled = compile_source("Top::\n I { return(\"ok\") }\n")
  local catalog_engine = linkedspec.runtime_engine(catalog_compiled)
  local rows = typed_source_projection_rows(catalog_engine)
  check_same_json(rows, contract.helper_projections, "exact detached 92 projection rows")

  local names = {}
  local name_count = 0
  for _, family in ipairs(contract.helper_projection_schema.families) do
    for _, row in ipairs(rows[family]) do
      name_count = name_count + 1
      check_equal(names[row[1]], nil, row[1] .. " projection name is unique")
      names[row[1]] = true
    end
  end
  check_equal(name_count, 92, "projection row count")

  local aliases = typed_source_compatibility_aliases(catalog_engine)
  check_same_json(aliases, contract.compatibility_aliases, "exact detached seven compatibility aliases")
  check_equal(#aliases, 7, "compatibility alias count")

  rows.capture_mark[1][2] = "wrong"
  aliases[1][2] = "wrong"
  check_same_json(
    typed_source_projection_rows(catalog_engine),
    contract.helper_projections,
    "projection rows are detached"
  )
  check_same_json(
    typed_source_compatibility_aliases(catalog_engine),
    contract.compatibility_aliases,
    "compatibility aliases are detached"
  )

  local named_mark_contract = json.decode(
    read_file("capability_conformance/complete_named_mark_contract.json")
  )
  local fixture = named_mark_contract.fixture
  check_carriers(
    fixture.spec_source,
    fixture.input,
    "typed-source/complete-named-mark.spec",
    fixture.expected
  )
  check_carriers(
    cursor_source,
    "ab",
    "typed-source/cursor-control.spec",
    cursor_expected
  )
  check_carriers(
    alias_source,
    "é🙂  ab",
    "typed-source/compatibility-aliases.spec",
    alias_expected
  )
end

if #failures == 0 then
  io.stdout:write(
    "Lua dormant typed source-location ", mode, ": ", assertions, " assertions passed\n"
  )
else
  io.stderr:write(
    "Lua dormant typed source-location ", mode, ": ", #failures, " of ", assertions,
    " assertions failed\n"
  )
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
