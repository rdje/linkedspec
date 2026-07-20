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

local function check_same_json(actual, expected, label)
  check_equal(json.encode(actual), json.encode(expected), label)
end

local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local value = assert(handle:read("*a"))
  assert(handle:close())
  return value
end

local function write_file(path, value)
  local handle = assert(io.open(path, "wb"))
  assert(handle:write(value))
  assert(handle:close())
end

local function capture(operation)
  local ok, value = pcall(operation)
  return ok, value
end

local function shell_quote(value)
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function command_succeeded(command)
  local first, _, third = os.execute(command)
  if type(first) == "number" then return first == 0 end
  return first == true and (third == nil or third == 0)
end

local function with_temp_directory(operation)
  local handle = assert(io.popen("mktemp -d /private/tmp/linkedspec-lua-cursor-descriptor.XXXXXX", "r"))
  local root = assert(handle:read("*l"))
  assert(handle:close())
  local ok, value = pcall(operation, root)
  local cleaned = command_succeeded("rm -rf " .. shell_quote(root))
  if not cleaned then error("unable to clean cursor-descriptor test directory", 0) end
  if not ok then error(value, 0) end
end

local function array_strings(values)
  local result = {}
  for index, value in ipairs(values) do result[index] = value end
  return result
end

local function sorted_keys(value)
  local result = {}
  for key in pairs(value) do result[#result + 1] = key end
  table.sort(result)
  return table.concat(result, ",")
end

local function sorted_values(values)
  local result = array_strings(values)
  table.sort(result)
  return table.concat(result, ",")
end

local function normalized_spec(source)
  local parsed = linkedspec.parse_spec(source)
  return linkedspec.spec_ast.from_json(
    "SpecFile",
    json.decode(json.encode(linkedspec.spec_ast.to_json(parsed)))
  )
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

local function expected_root_meta_keys(outward_contract)
  local result = {}
  for _, key in ipairs(outward_contract.required_meta_keys) do result[key] = true end
  local variants = outward_contract.meta_contract_variants
  for _, key in ipairs(variants.legacy_global_v0.required_keys) do result[key] = nil end
  for _, key in ipairs(variants.rule_local_cursor_v1.required_keys) do result[key] = true end
  result.entry_rule_contract = true
  result.regex_slot_identity_contract = true
  return sorted_keys(result)
end

local function validation_failure(spec)
  local ok, failure = capture(function() return linkedspec.compile_spec(spec) end)
  check_equal(ok, false, "expected descriptor validation failure")
  check_equal(linkedspec.is_spec_validation_error(failure), true, "portable validation type")
  return failure
end

local contract = json.decode(read_file("capability_conformance/rule_local_cursor_contract.json"))
local outward = json.decode(read_file("capability_conformance/outward_descriptor_contract.json"))
local descriptor_contract = contract.descriptor_contract
local descriptor_variant = outward.meta_contract_variants.rule_local_cursor_v1

check_equal(#contract.family_cases, 36, "family row count")
check_equal(
  linkedspec.RULE_LOCAL_CURSOR_CONTRACT_ID,
  contract.contract_id,
  "rule-local cursor contract id"
)
for _, row in ipairs(contract.family_cases) do
  local source = row.header .. "\n /x/\n"
  local parsed = linkedspec.parse_spec(source)
  local direct_compiled = linkedspec.compile_spec(parsed)
  local direct = linkedspec.to_descriptor_json(direct_compiled)
  local normalized = linkedspec.to_descriptor_json(linkedspec.compile_spec(normalized_spec(source)))

  check_same_json(normalized, direct, row.id .. " normalized descriptor")
  check_equal(sorted_keys(direct), sorted_values(outward.top_level_keys), row.id .. " root fields")
  check_equal(sorted_keys(direct.meta), expected_root_meta_keys(outward), row.id .. " root meta fields")
  check_equal(direct.meta.cursor_contract, descriptor_contract.meta.cursor_contract, row.id .. " cursor contract")
  check_equal(direct.meta.cursor_contract, descriptor_variant.cursor_contract, row.id .. " descriptor variant")
  check_equal(direct.meta.entry_rule_contract, linkedspec.ENTRY_RULE_CONTRACT_ID, row.id .. " entry contract")
  check_equal(
    direct.meta.regex_slot_identity_contract,
    linkedspec.REGEX_SLOT_IDENTITY_CONTRACT_ID,
    row.id .. " regex-slot identity contract"
  )
  for _, key in ipairs(descriptor_variant.forbidden_keys) do
    check_equal(direct.meta[key], nil, row.id .. " omits root " .. key)
  end

  local rule = parsed.rules[1]
  local projected = direct.spec.Top
  local meta = projected.meta
  check_equal(
    sorted_keys(meta),
    "cursor_policy,edge_ownership,family,is_top,label,line,mode,resolved_edges",
    row.id .. " rule meta fields"
  )
  check_equal(projected.handler.label, "Top", row.id .. " handler label")
  check_equal(meta.label, "Top", row.id .. " rule label")
  check_equal(meta.line, rule.header.line, row.id .. " source line")
  check_equal(meta.is_top, rule.header.is_top, row.id .. " authored top identity")
  check_equal(meta.family, row.family, row.id .. " family")
  check_equal(meta.cursor_policy, row.cursor_policy, row.id .. " cursor policy")
  check_equal(meta.edge_ownership, "none", row.id .. " edge ownership")
  check_equal(meta.resolved_edges ~= nil and #meta.resolved_edges or -1, 0, row.id .. " resolved edge count")
  check_equal(meta.mode.is_and, row.family == "and", row.id .. " mode identity")
  check_equal(meta.parse_mode, nil, row.id .. " omits rule parse mode")
  check_same_json(linkedspec.to_descriptor_json(direct_compiled:rule("Top")), projected, row.id .. " rule route")
end

local semantic_fields = sorted_values(descriptor_contract.resolved_edge_fields)
for _, row in ipairs(contract.edge_resolution_cases) do
  local expected = row.expected
  if expected ~= nil and expected.kind == "edge" then
    local source = edge_source(row.parent_family, { row.source }, array_strings(row.declared_rules))
    local direct = linkedspec.to_descriptor_json(linkedspec.compile_spec(linkedspec.parse_spec(source)))
    local normalized = linkedspec.to_descriptor_json(linkedspec.compile_spec(normalized_spec(source)))
    check_same_json(normalized, direct, row.id .. " normalized descriptor")

    local meta = direct.spec.Top.meta
    check_equal(meta.edge_ownership, expected.ownership, row.id .. " ownership")
    local resolved_edges = meta.resolved_edges or {}
    check_equal(meta.resolved_edges ~= nil and #resolved_edges or -1, #expected.targets, row.id .. " resolved row count")
    for index, target in ipairs(expected.targets) do
      local actual = resolved_edges[index]
      check(actual ~= nil, row.id .. " has semantic row " .. index)
      if actual ~= nil then
        check_equal(sorted_keys(actual), semantic_fields, row.id .. " semantic fields " .. index)
        check_equal(actual.ownership, expected.ownership, row.id .. " row ownership " .. index)
        check_equal(actual.target, target.label, row.id .. " target " .. index)
        local expected_index = json.null
        if expected.ownership == "action" then
          expected_index = target.index == json.null and 0 or target.index
        end
        check_same_json(actual.regex_index, expected_index, row.id .. " regex index " .. index)
        check_equal(actual.block, expected.has_block, row.id .. " block " .. index)
        check_same_json(actual.fluent, target.fluent, row.id .. " fluent " .. index)
        check_equal(actual.source_form, nil, row.id .. " omits source form " .. index)
      end
    end
  end
end

with_temp_directory(function(root)
  local source = [[
Top::AND
 /x/
 -> Top { return("hit") }
]]
  local direct_compiled = linkedspec.compile_spec(linkedspec.parse_spec(source))
  local direct = linkedspec.to_descriptor_json(direct_compiled)
  local direct_bytes = json.encode(direct)
  local normalized = linkedspec.to_descriptor_json(linkedspec.compile_spec(normalized_spec(source)))
  check_equal(json.encode(normalized), direct_bytes, "normalized descriptor bytes")

  local path = root .. "/descriptor.spec"
  write_file(path, source)
  local loaded = linkedspec.load_and_compile_spec(
    linkedspec.path_spec_request(path),
    linkedspec.spec_load_options({ cwd = root, search_roots = {} })
  )
  local loaded_descriptor = linkedspec.to_descriptor_json(loaded.compiled)
  check_equal(json.encode(loaded_descriptor), direct_bytes, "loaded descriptor bytes")
  check_equal(loaded_descriptor.spec.Top.meta.family, "and", "loaded family")
  check_equal(loaded_descriptor.spec.Top.meta.cursor_policy, "consume", "loaded policy")
  check_same_json(linkedspec.runtime_parse(loaded:create_engine(), "prefix x").value, json.null, "loaded consume")
  check_equal(linkedspec.runtime_parse(loaded:create_engine(), "x").value, "hit", "loaded execution")
end)

local diagnostic_rows = {}
for _, row in ipairs(contract.diagnostics) do diagnostic_rows[row.code] = row end
local invalid_rows = {}
for _, row in ipairs(contract.edge_resolution_cases) do
  if row.expected_error ~= nil then invalid_rows[#invalid_rows + 1] = row end
end
for _, row in ipairs(contract.rule_edge_set_cases) do
  if row.expected_error ~= nil then invalid_rows[#invalid_rows + 1] = row end
end
for _, row in ipairs(invalid_rows) do
  local sources = row.sources and array_strings(row.sources) or { row.source }
  local source = edge_source(row.parent_family, sources, array_strings(row.declared_rules))
  local failure = validation_failure(normalized_spec(source))
  local projected = linkedspec.spec_validation_error_to_json(failure)
  check_equal(failure.code, row.expected_error, row.id .. " diagnostic code")
  check_equal(failure.stage, diagnostic_rows[row.expected_error].stage, row.id .. " diagnostic stage")
  check_equal(sorted_keys(projected.fields), sorted_values(diagnostic_rows[row.expected_error].fields), row.id .. " fields")
end

if #failures == 0 then
  io.stdout:write("rule-local cursor descriptor: ", assertions, " assertions passed\n")
else
  io.stderr:write("rule-local cursor descriptor: ", #failures, " of ", assertions, " assertions failed\n")
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
