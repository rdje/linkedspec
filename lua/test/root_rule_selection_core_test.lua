local linkedspec = require("linkedspec")
local json = linkedspec.json

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

local function optional_selector(value)
  if value == json.null then return nil end
  return value
end

local function compile_rows(rows)
  if #rows == 0 then
    return linkedspec.compile_spec(linkedspec.spec_ast.spec_file({ rules = {} }), {
      validate_source = false,
    })
  end
  local lines = {}
  for _, row in ipairs(rows) do
    lines[#lines + 1] = row.label .. (row.authored_is_top and "::" or ":")
    lines[#lines + 1] = " /x/"
    lines[#lines + 1] = ' I { return("' .. row.label .. '") }'
    lines[#lines + 1] = ""
  end
  return linkedspec.compile_spec(linkedspec.parse_spec(table.concat(lines, "\n")))
end

local contract = json.decode(read_file("capability_conformance/root_rule_selection_contract.json"))

check_equal(contract.contract_id, linkedspec.ENTRY_RULE_CONTRACT_ID, "root contract id")

for _, case_value in ipairs(contract.selection_cases) do
  local compiled = compile_rows(case_value.rules)
  local authored_before = {}
  for index, label in ipairs(compiled.compiled_rule_order) do
    authored_before[index] = label .. ":" .. tostring(compiled:rule(label).header.is_top)
  end
  local selection = linkedspec.resolve_entry_rule(compiled, optional_selector(case_value.explicit_selector))
  check_equal(selection.rule.label, case_value.expected_label, case_value.id .. " label")
  check_equal(
    linkedspec.entry_rule_selection_basis_name(selection.basis),
    case_value.expected_basis,
    case_value.id .. " basis"
  )
  local authored_after = {}
  for index, label in ipairs(compiled.compiled_rule_order) do
    authored_after[index] = label .. ":" .. tostring(compiled:rule(label).header.is_top)
  end
  check_equal(table.concat(authored_after, ","), table.concat(authored_before, ","), case_value.id .. " identity")
end

for _, case_value in ipairs(contract.failure_cases) do
  local compiled = compile_rows(case_value.rules)
  local selector = optional_selector(case_value.explicit_selector)
  local ok, selection_error = capture(function()
    return linkedspec.resolve_entry_rule(compiled, selector)
  end)
  check_equal(ok, false, case_value.id .. " rejected")
  check_equal(
    linkedspec.is_entry_rule_selection_error(selection_error),
    true,
    case_value.id .. " typed selection error"
  )
  check_equal(selection_error.code, case_value.expected_code, case_value.id .. " code")
  check_equal(selection_error.stage, case_value.expected_stage, case_value.id .. " stage")
  local expected_fields = json.harray()
  if case_value.expected_code == "entry_rule_not_found" then expected_fields.entry_rule = selector end
  check_same_json(
    linkedspec.entry_rule_selection_error_to_json(selection_error).fields,
    expected_fields,
    case_value.id .. " fields"
  )
end

do
  check_equal(#linkedspec.parse_spec("").rules, 0, "empty parser envelope")
  check_equal(#linkedspec.parse_spec("  \n# no rules\n\t").rules, 0, "comment-only parser envelope")
  local malformed_ok, malformed = capture(function() return linkedspec.parse_spec("not a rule") end)
  check_equal(malformed_ok, false, "non-rule preamble rejected")
  check_equal(linkedspec.is_spec_parse_error(malformed), true, "non-rule preamble parse type")
  check_equal(linkedspec.validate_spec(linkedspec.parse_spec("Only:\n /x/\n")), nil, "markerless source validates")

  for _, source in ipairs({ "", "# no rules\n" }) do
    local ok, validation_error = capture(function()
      return linkedspec.validate_spec(linkedspec.parse_spec(source))
    end)
    check_equal(ok, false, "zero-rule source rejected")
    check_equal(linkedspec.is_spec_validation_error(validation_error), true, "zero-rule validation type")
    check_equal(validation_error.code, "no_rules_defined", "zero-rule validation code")
    check_equal(validation_error.stage, "validate_spec", "zero-rule validation stage")
    check_equal(validation_error.message, "spec does not define any rules", "zero-rule validation message")
    check_same_json(
      linkedspec.spec_validation_error_to_json(validation_error),
      json.harray({
        code = "no_rules_defined",
        stage = "validate_spec",
        message = "spec does not define any rules",
        fields = json.harray(),
      }),
      "zero-rule validation JSON"
    )
  end
end

do
  local marked = linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Earlier:
 /x/
 I { return("earlier") }

Marked::
 /x/
 I { return("marked") }

Later::
 /x/
 I { return("later") }
]])))
  check_equal(linkedspec.runtime_parse(marked, "x").value, "marked", "native first marker")
  check_equal(
    linkedspec.runtime_parse(marked, "x", { top_rule = "Earlier" }).value,
    "earlier",
    "native explicit ordinary"
  )
  check_equal(
    linkedspec.runtime_parse(marked, "x", { top_rule = "Later" }).value,
    "later",
    "native explicit later marker"
  )

  local markerless = linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
First:
 /x/
 I { return("first") }

Second:
 /x/
 I { return("second") }
]])))
  check_equal(linkedspec.runtime_parse(markerless, "x").value, "first", "native first ordinary")
  check_equal(
    linkedspec.runtime_parse(markerless, "x", { top_rule = "Second" }).value,
    "second",
    "native explicit later ordinary"
  )

  local exits_if_entered = linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /x/
 I { exit_now(99) }
]])))
  local unknown_ok, unknown = capture(function()
    return linkedspec.runtime_parse(exits_if_entered, "x", { top_rule = "Missing" })
  end)
  check_equal(unknown_ok, false, "unknown native selector rejected")
  check_equal(linkedspec.is_runtime_interpreter_error(unknown), true, "unknown native selector type")
  check_equal(unknown.code, "entry_rule_not_found", "unknown native selector code")
  check_equal(unknown.entry_rule, "Missing", "unknown native selector identity")
  check_equal(unknown.diagnostic.code, "entry_rule_not_found", "unknown diagnostic code")
  check_equal(unknown.diagnostic.stage, "select_entry_rule", "unknown diagnostic stage")
  check_equal(unknown.diagnostic.top_rule, "Missing", "unknown diagnostic requested top")
  check_equal(unknown.diagnostic.entry_rule, "Missing", "unknown diagnostic entry rule")
  check_equal(unknown.diagnostic.rule_label, "Missing", "unknown diagnostic rule label")

  local empty = linkedspec.runtime_engine(compile_rows({}))
  local zero_ok, zero = capture(function()
    return linkedspec.runtime_parse(empty, "", { top_rule = "Missing" })
  end)
  check_equal(zero_ok, false, "zero-rule native selector rejected")
  check_equal(linkedspec.is_runtime_interpreter_error(zero), true, "zero-rule native selector type")
  check_equal(zero.code, "no_rules_defined", "zero-rule native selector code")
  check_equal(zero.entry_rule, nil, "zero-rule native selector identity")
  check_equal(zero.diagnostic.code, "no_rules_defined", "zero-rule diagnostic code")
  check_equal(zero.diagnostic.stage, "validate_spec", "zero-rule diagnostic stage")
  check_equal(zero.diagnostic.top_rule, nil, "zero-rule diagnostic top")
  check_equal(zero.diagnostic.entry_rule, nil, "zero-rule diagnostic entry rule")
end

do
  local compiled = compile_rows({
    { label = "Earlier", authored_is_top = false },
    { label = "Marked", authored_is_top = true },
    { label = "Later", authored_is_top = true },
  })
  local before = linkedspec.to_descriptor_json(compiled)
  check_equal(linkedspec.resolve_entry_rule(compiled, "Earlier").rule.label, "Earlier", "descriptor selection")
  check_equal(
    linkedspec.runtime_parse(linkedspec.runtime_engine(compiled), "x", { top_rule = "Earlier" }).value,
    "Earlier",
    "descriptor execution"
  )
  local after = linkedspec.to_descriptor_json(compiled)
  check_same_json(after, before, "descriptor immutable across selection")
  check_equal(after.meta.entry_rule_contract, linkedspec.ENTRY_RULE_CONTRACT_ID, "descriptor root contract")
  check_equal(table.concat(after.meta.definition_order, ","), "Earlier,Marked,Later", "descriptor definition order")
  check_equal(after.meta.entry_rule, nil, "descriptor omits dynamic entry rule")
  check_equal(after.meta.selected_entry_rule, nil, "descriptor omits selected entry rule")
  check_equal(after.spec.Earlier.meta.is_top, false, "descriptor ordinary identity")
  check_equal(after.spec.Marked.meta.is_top, true, "descriptor first marker identity")
  check_equal(after.spec.Later.meta.is_top, true, "descriptor later marker identity")

  local strict_sources = {
    explicit_selection_is_not_reference = "A:\n /a/\n\nB:\n /b/\n",
    marker_selection_is_not_reference = "Top::\n /x/ -> Child\n\nChild:\n /x/ -> Child\n",
    closed_reference_cycle_has_no_unused_rules = "A:\n /a/ -> B\n\nB:\n /b/ -> A\n",
  }
  for _, case_value in ipairs(contract.strict_cases) do
    local spec = linkedspec.parse_spec(strict_sources[case_value.id])
    if case_value.id == "explicit_selection_is_not_reference" then
      linkedspec.resolve_entry_rule(linkedspec.compile_spec(spec), optional_selector(case_value.explicit_selector))
    end
    local ok, validation_error = capture(function()
      return linkedspec.validate_spec(spec, { strict_syntax = true })
    end)
    if #case_value.expected_unused == 0 then
      check_equal(ok, true, case_value.id .. " strict accepted")
    else
      check_equal(ok, false, case_value.id .. " strict rejected")
      check_equal(linkedspec.is_spec_validation_error(validation_error), true, case_value.id .. " strict type")
      check_contains(
        validation_error.message,
        "unused rule(s) in strict mode: " .. table.concat(case_value.expected_unused, ", "),
        case_value.id .. " strict labels"
      )
    end
  end
end

do
  local primary = linkedspec.run_primary_cli({
    "--inline-spec",
    'First:\n /x/\n I { return("first") }\n\nSecond:\n /x/\n I { return("second") }\n',
    "--input",
    "x",
  })
  check_equal(primary.exit_code, 0, "markerless primary exit")
  check_equal(primary.stdout, '"first"\n', "markerless primary value")
  check_equal(primary.stderr, "", "markerless primary stderr")
end

if #failures == 0 then
  io.stdout:write("root-rule selection core: ", assertions, " assertions passed\n")
else
  io.stderr:write("root-rule selection core: ", #failures, " of ", assertions, " assertions failed\n")
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
