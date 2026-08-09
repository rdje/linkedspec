-- FUTURE-PARITY-BACKLOG.14.2.5.0.1 — shared Lua source-boundary alias parity.

local linkedspec = require("linkedspec")
local action_call_names = require("linkedspec.action_call_names")
local json = linkedspec.json

local assertions = 0
local failures = {}

local function check(condition, label)
  assertions = assertions + 1
  if not condition then failures[#failures + 1] = label end
end

local function check_equal(actual, expected, label)
  check(actual == expected, (label or "values differ") ..
    ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
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

local function write_file(path, value)
  local handle = assert(io.open(path, "wb"))
  assert(handle:write(value))
  assert(handle:close())
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
  local temp_root = assert(os.getenv("TMPDIR"), "TMPDIR is required")
  assert(temp_root ~= "", "TMPDIR must not be empty")
  local template = temp_root:gsub("/+$", "") .. "/linkedspec-lua-source-aliases.XXXXXX"
  local handle = assert(io.popen("mktemp -d " .. shell_quote(template), "r"))
  local root = assert(handle:read("*l"))
  assert(handle:close())
  local ok, value = pcall(operation, root)
  local cleaned = command_succeeded("rm -rf " .. shell_quote(root))
  if not cleaned then error("unable to clean source-alias test directory", 0) end
  if not ok then error(value, 0) end
  return value
end

local contract = json.decode(read_file("capability_conformance/typed_source_location_contract.json"))
local aliases = json.harray()
for _, row in ipairs(contract.compatibility_aliases) do aliases[row[1]] = row[2] end

local expected_aliases = json.harray({
  capture_from_rule_start = "capture_slice",
  capture_len_from_rule_start = "capture_slice_len",
  capture_rest_length = "capture_rest_len",
  capture_slice_here = "start_capture_slice",
  capture_slice_length = "capture_slice_len",
  entry_named_map = "entry_map",
  match_named_map = "match_map",
})

local input = "é🙂  ab"

local alias_normal_source = [[Top::OR{1,1}
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

local canonical_normal_source = [[Top::OR{1,1}
 /(?<name>ab)/
 I { started = start_capture_slice() }
 E {
   return(array(
     started,
     capture_slice(),
     capture_slice_len(),
     capture_slice_len(),
     capture_rest_len(),
     entry_map(),
     match_map()
   ))
 }
]]

local alias_reversed_source = [[Top::OR{1,1}
 /(?<name>ab)/
 E {
   started = capture_slice_here();
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

local canonical_reversed_source = [[Top::OR{1,1}
 /(?<name>ab)/
 E {
   started = start_capture_slice();
   return(array(
     started,
     capture_slice(),
     capture_slice_len(),
     capture_slice_len(),
     capture_rest_len(),
     entry_map(),
     match_map()
   ))
 }
]]

local normal_expected = json.array({
  json.null,
  "é🙂  ",
  4,
  4,
  6,
  json.harray({ name = "ab" }),
  json.harray({ name = "ab" }),
})

local reversed_expected = json.array({
  json.null,
  json.null,
  json.null,
  json.null,
  0,
  json.harray({ name = "ab" }),
  json.harray({ name = "ab" }),
})

local function compile_source(source)
  local parsed = linkedspec.parse_spec(source)
  linkedspec.validate_spec(parsed)
  return linkedspec.compile_spec(parsed)
end

local function execute(compiled)
  return linkedspec.runtime_parse(linkedspec.runtime_engine(compiled), input).value
end

local function check_runtime_value(operation, expected, label)
  local ok, value = capture(operation)
  check(ok, label .. (ok and "" or ": " .. tostring(value)))
  if ok then check_same_json(value, expected, label .. " value") end
  return ok and value or nil
end

local function check_runtime_carriers(source, identity, expected)
  local compiled = compile_source(source)
  local observed = {}

  observed.native = check_runtime_value(function()
    return execute(compiled)
  end, expected, identity .. " native")

  observed.reconstructed = check_runtime_value(function()
    local parsed = linkedspec.parse_spec(source)
    local reconstructed = linkedspec.spec_ast.from_json(
      "SpecFile",
      json.decode(json.encode(linkedspec.spec_ast.to_json(parsed)))
    )
    linkedspec.validate_spec(reconstructed)
    return execute(linkedspec.compile_spec(reconstructed))
  end, expected, identity .. " reconstructed")

  observed.loaded = check_runtime_value(function()
    return with_temp_directory(function(root)
      write_file(root .. "/fixture.spec", source)
      local loaded = linkedspec.load_and_compile_spec(
        linkedspec.path_spec_request("fixture.spec"),
        linkedspec.spec_load_options({ cwd = root, search_roots = {} })
      )
      return linkedspec.runtime_parse(loaded:create_engine(), input).value
    end)
  end, expected, identity .. " loaded")

  observed.generated = check_runtime_value(function()
    return linkedspec.execute_generated_parser_v2(
      compiled,
      linkedspec.build_generated_rule_plan(compiled),
      input,
      identity .. "-generated"
    )
  end, expected, identity .. " generated plan")

  observed.emitted = check_runtime_value(function()
    return with_temp_directory(function(root)
      local emitted_identity = identity .. "-emitted"
      local path = root .. "/generated_parser.lua"
      write_file(path, linkedspec.emit_lua_source_v2(compiled, emitted_identity))
      local generated = assert(loadfile(path))()
      check_equal(generated.metadata().source_identity, emitted_identity, identity .. " emitted identity")
      return generated.execute(input)
    end)
  end, expected, identity .. " emitted")

  return observed
end

check_same_json(aliases, expected_aliases, "neutral aliases are exact")
check_equal(action_call_names.count(), 246, "common current-name inventory stays fixed")

local canonical_count = 0
for _, family in ipairs(contract.helper_projection_schema.families) do
  for _, row in ipairs(contract.helper_projections[family]) do
    local name = row[1]
    canonical_count = canonical_count + 1
    check_equal(linkedspec.is_known_action_ir_call_name(name), true, name .. " canonical helper is known")
    check_equal(linkedspec.canonical_action_helper_name(name), name, name .. " stays canonical")
    local resolution = linkedspec.resolve_action_expression_contracts(
      linkedspec.parse_action_expression(name .. "()")
    )
    check_equal(resolution.ok, true, name .. " canonical helper resolves")
    check_equal(#resolution.contracts, 1, name .. " canonical contract count")
    if #resolution.contracts == 1 then
      check_equal(resolution.contracts[1].canonical_name, name, name .. " resolved canonical name")
    end
  end
end
check_equal(canonical_count, 92, "canonical helper inventory count")

for alias, canonical in pairs(expected_aliases) do
  check_equal(action_call_names.is_shared_inventory_name(alias), false, alias .. " stays outside current names")
  check_equal(linkedspec.is_known_action_ir_call_name(alias), true, alias .. " is known")
  check_equal(linkedspec.is_known_action_ir_call_name(canonical), true, canonical .. " is known")
  check_equal(linkedspec.canonical_action_helper_name(alias), canonical, alias .. " canonical name")

  for arity = 0, 1 do
    local argument = arity == 0 and "" or "1"
    local resolution = linkedspec.resolve_action_expression_contracts(
      linkedspec.parse_action_expression(alias .. "(" .. argument .. ")")
    )
    check_equal(resolution.ok, true, alias .. " arity " .. arity .. " resolves")
    check_equal(#resolution.contracts, 1, alias .. " arity " .. arity .. " contract count")
    if #resolution.contracts == 1 then
      local resolved = resolution.contracts[1]
      check_equal(resolved.source_name, alias, alias .. " source name")
      check_equal(resolved.canonical_name, canonical, alias .. " resolved canonical name")
      check_equal(resolved.positional_arg_count, arity, alias .. " authored arity")
      check_equal(linkedspec.action_contracts.canonicalized(resolved), true, alias .. " canonicalized")
    end
  end
end

local unknown_name = "invented_source_boundary_alias"
local unknown_ok, unknown = capture(function()
  return execute(compile_source("Top::\n /x/\n E { " .. unknown_name .. "() }\n"))
end)
check_equal(unknown_ok, false, "unrelated helper remains unsupported")
check_equal(linkedspec.is_runtime_interpreter_error(unknown), true, "unrelated helper error type")
if linkedspec.is_runtime_interpreter_error(unknown) then
  local detail = "unsupported runtime helper '" .. unknown_name .. "'"
  check_equal(unknown.message, detail, "unrelated helper message")
  check_equal(linkedspec.is_runtime_diagnostic(unknown.diagnostic), true, "unrelated helper diagnostic type")
  if linkedspec.is_runtime_diagnostic(unknown.diagnostic) then
    local diagnostic = linkedspec.interpreter.to_json(unknown.diagnostic)
    check_equal(diagnostic.stage, "runtime_execution", "unrelated helper diagnostic stage")
    check_equal(diagnostic.owner_stage, "lua_runtime", "unrelated helper diagnostic owner")
    check_equal(diagnostic.detail, detail, "unrelated helper diagnostic detail")
    check_equal(diagnostic.rule_label, "Top", "unrelated helper diagnostic rule")
    check_equal(diagnostic.top_rule, "Top", "unrelated helper diagnostic top rule")
  end
end

local alias_normal = check_runtime_carriers(
  alias_normal_source,
  "source-boundary/lua-alias-normal.spec",
  normal_expected
)
local canonical_normal = check_runtime_carriers(
  canonical_normal_source,
  "source-boundary/lua-canonical-normal.spec",
  normal_expected
)
local alias_reversed = check_runtime_carriers(
  alias_reversed_source,
  "source-boundary/lua-alias-reversed.spec",
  reversed_expected
)
local canonical_reversed = check_runtime_carriers(
  canonical_reversed_source,
  "source-boundary/lua-canonical-reversed.spec",
  reversed_expected
)

for _, carrier in ipairs({ "native", "reconstructed", "loaded", "generated", "emitted" }) do
  check_same_json(alias_normal[carrier], canonical_normal[carrier], carrier .. " normal alias/canonical equality")
  check_same_json(alias_reversed[carrier], canonical_reversed[carrier], carrier .. " reversed alias/canonical equality")
end

if #failures == 0 then
  io.stdout:write("Lua source-boundary compatibility aliases: ", assertions, " assertions passed\n")
else
  io.stderr:write("Lua source-boundary compatibility aliases: ", #failures, " of ", assertions,
    " assertions failed\n")
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
