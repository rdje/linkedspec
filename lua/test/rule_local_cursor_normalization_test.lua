local ast = require("linkedspec.spec_ast")
local compiled_spec = require("linkedspec.compiled_spec")
local json = require("linkedspec.json")
local spec_parser = require("linkedspec.spec_parser")
local spec_validator = require("linkedspec.spec_validator")

local linkedspec = {
  spec_ast = ast,
  json = json,
  parse_spec = spec_parser.parse_spec,
  validate_spec = spec_validator.validate_spec,
  is_spec_validation_error = spec_validator.is_validation_error,
  spec_validation_error_to_json = spec_validator.validation_error_to_json,
  compile_spec = compiled_spec.compile_spec,
}

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

local function check_same_json(actual, expected, label)
  check_equal(json.encode(actual), json.encode(expected), label)
end

local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local value = assert(handle:read("*a"))
  assert(handle:close())
  return value
end

local function capture(operation)
  local ok, value = pcall(operation)
  return ok, value
end

local function array_strings(values)
  local result = {}
  for index, value in ipairs(values) do result[index] = value end
  return result
end

local function sorted_keys(object)
  local result = {}
  for key in pairs(object) do result[#result + 1] = key end
  table.sort(result)
  return table.concat(result, ",")
end

local function sorted_values(values)
  local result = array_strings(values)
  table.sort(result)
  return table.concat(result, ",")
end

local function edge_source(parent_family, sources, declared_rules)
  local lines = { parent_family == "and" and "Top::AND" or "Top::" }
  for _, source in ipairs(sources) do lines[#lines + 1] = " " .. source end
  for _, label in ipairs(declared_rules) do
    lines[#lines + 1] = ""
    lines[#lines + 1] = label .. ":"
    lines[#lines + 1] = " /x/ /y/"
  end
  return table.concat(lines, "\n") .. "\n"
end

local function validation_failure(source)
  local ok, failure = capture(function()
    return linkedspec.validate_spec(linkedspec.parse_spec(source))
  end)
  check_equal(ok, false, "expected validation failure")
  check_equal(linkedspec.is_spec_validation_error(failure), true, "portable validation type")
  return failure
end

local contract = json.decode(read_file("capability_conformance/rule_local_cursor_contract.json"))
local diagnostics = {}
for _, row in ipairs(contract.diagnostics) do diagnostics[row.code] = row end

check_equal(#contract.family_cases, 36, "family row count")
check_equal(#contract.edge_resolution_cases, 18, "edge row count")
check_equal(#contract.rule_edge_set_cases, 6, "ownership-set row count")

for _, row in ipairs(contract.family_cases) do
  local parsed = linkedspec.parse_spec(row.header .. "\n /x/\n")
  local expected_and = row.family == "and"
  check_equal(ast.rule_mode_is_and(parsed.rules[1].header.mode), expected_and, row.id .. " AST family")
  local compiled = linkedspec.compile_spec(parsed, { validate_source = false }):rule("Top")
  check_equal(compiled.mode_metadata.is_and, expected_and, row.id .. " compiled family")
end
check_equal(ast.rule_mode_is_and(ast.rule_mode("Pipe")), false, "compact pipe is OR/default")
check_equal(ast.rule_mode_is_and(ast.rule_mode("Single")), true, "compact ampersand is AND")

for _, row in ipairs(contract.edge_resolution_cases) do
  local source = edge_source(row.parent_family, { row.source }, array_strings(row.declared_rules))
  if row.expected_error ~= nil then
    local failure = validation_failure(source)
    local expected_diagnostic = diagnostics[row.expected_error]
    local projected = linkedspec.spec_validation_error_to_json(failure)
    check_equal(failure.code, row.expected_error, row.id .. " diagnostic code")
    check_equal(failure.stage, expected_diagnostic.stage, row.id .. " diagnostic stage")
    check_equal(sorted_keys(projected.fields), sorted_values(expected_diagnostic.fields), row.id .. " fields")
    check_equal(projected.fields.rule_label, "Top", row.id .. " rule label")
    if projected.fields.target ~= nil then
      check_equal(
        projected.fields.target,
        row.expected_error == "bare_edge_target_undefined" and "Missing" or "Child",
        row.id .. " target"
      )
    end
    if projected.fields.regex_index ~= nil then
      check_equal(projected.fields.regex_index, 0, row.id .. " regex index")
    end
    if projected.fields.targets ~= nil then
      check_same_json(projected.fields.targets, row.declared_rules, row.id .. " targets")
    end
    check_same_json(json.decode(json.encode(projected)), projected, row.id .. " diagnostic JSON roundtrip")
  else
    local parsed = linkedspec.parse_spec(source)
    local valid, validation_error = capture(function() return linkedspec.validate_spec(parsed) end)
    check_equal(valid, true, row.id .. " validates: " .. tostring(validation_error))
    local expected = row.expected
    if valid then
      local first_kind = parsed.rules[1].body[1].kind
      if expected.kind == "lifecycle" then
        check_equal(ast.node_type(first_kind), "LifecycleMarkerBodyElementKind", row.id .. " lifecycle kind")
        check_equal(first_kind.marker, expected.name, row.id .. " lifecycle name")
      else
        if expected.source_form == "bare" then
          check_equal(ast.node_type(first_kind), "BareEdgeBodyElementKind", row.id .. " typed bare kind")
          check_equal(#first_kind.targets, #expected.targets, row.id .. " bare target count")
          check_equal(first_kind.code ~= nil, expected.has_block, row.id .. " bare block")
          local expected_fluent = expected.targets[1].fluent
          local actual_fluent = nil
          if #first_kind.fluent_chain > 0 then
            local call = first_kind.fluent_chain[1]
            actual_fluent = call.method .. (call.args == "" and "" or "(" .. call.args .. ")")
          end
          if expected_fluent == json.null then expected_fluent = nil end
          check_equal(actual_fluent, expected_fluent, row.id .. " bare fluent")
          for _, element in ipairs(parsed.rules[1].body) do
            check(ast.node_type(element.kind) ~= "RawBodyElementKind", row.id .. " no raw fallback")
          end
          local roundtrip = ast.from_json("SpecFile", json.decode(json.encode(ast.to_json(parsed))))
          check_same_json(ast.to_json(roundtrip), ast.to_json(parsed), row.id .. " AST JSON roundtrip")
        end

        local compiled = linkedspec.compile_spec(parsed):rule("Top")
        if expected.ownership == "action" then
          check_equal(#compiled.action_edges, #expected.targets, row.id .. " action count")
          check_equal(#compiled.blind_edges, 0, row.id .. " no blind edges")
          for index, target in ipairs(expected.targets) do
            local actual = compiled.action_edges[index].targets[1]
            check_equal(actual.label, target.label, row.id .. " action label " .. index)
            check_equal(actual.index, target.index == json.null and 0 or target.index, row.id .. " action index " .. index)
          end
        else
          check_equal(#compiled.blind_edges, #expected.targets, row.id .. " blind count")
          check_equal(#compiled.action_edges, 0, row.id .. " no action edges")
          for index, target in ipairs(expected.targets) do
            check_equal(compiled.blind_edges[index].target.label, target.label, row.id .. " blind label " .. index)
          end
        end
      end
    end
  end
end

for _, row in ipairs(contract.rule_edge_set_cases) do
  local source = edge_source(row.parent_family, array_strings(row.sources), array_strings(row.declared_rules))
  if row.expected_error ~= nil then
    local failure = validation_failure(source)
    local projected = linkedspec.spec_validation_error_to_json(failure)
    check_equal(failure.code, row.expected_error, row.id .. " code")
    check_equal(failure.stage, "validate_rule", row.id .. " stage")
    check_equal(sorted_keys(projected.fields), "ownerships,rule_label", row.id .. " fields")
    if projected.fields.ownerships ~= nil then
      check_same_json(projected.fields.ownerships, json.array({ "action", "blind" }), row.id .. " ownerships")
    end
  else
    local compiled_ok, compiled = capture(function()
      return linkedspec.compile_spec(linkedspec.parse_spec(source)):rule("Top")
    end)
    check_equal(compiled_ok, true, row.id .. " compiles: " .. tostring(compiled))
    if compiled_ok then
      if row.expected_ownership == "action" then
        check(#compiled.action_edges > 0, row.id .. " has action edges")
        check_equal(#compiled.blind_edges, 0, row.id .. " no blind edges")
      else
        check(#compiled.blind_edges > 0, row.id .. " has blind edges")
        check_equal(#compiled.action_edges, 0, row.id .. " no action edges")
      end
    end
  end
end

for _, source in ipairs({
  "Top::\n Child\n\nChild:\n /x/\n",
  "Top:: Child\n\nChild:\n /x/\n",
  "Top::AND\n Child {\n  return(child_result)\n }\n\nChild:\n /x/\n",
}) do
  local parsed = linkedspec.parse_spec(source)
  check_equal(ast.node_type(parsed.rules[1].body[1].kind), "BareEdgeBodyElementKind", "complete bare candidate")
end
local suffix = linkedspec.parse_spec("Top:: /x/ Child\n\nChild:\n /x/\n")
for _, element in ipairs(suffix.rules[1].body) do
  check(ast.node_type(element.kind) ~= "BareEdgeBodyElementKind", "bare candidate is physical-line scoped")
end

if #failures == 0 then
  io.stdout:write("rule-local cursor normalization: ", assertions, " assertions passed\n")
else
  io.stderr:write("rule-local cursor normalization: ", #failures, " of ", assertions, " assertions failed\n")
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
