local json = require("linkedspec.json")
local compiled_spec = require("linkedspec.compiled_spec")
local interpreter = require("linkedspec.interpreter")
local spec_parser = require("linkedspec.spec_parser")
local spec_validator = require("linkedspec.spec_validator")
local staged_parser_registry = require("linkedspec.staged_parser_registry")
local trace = require("linkedspec.trace")
local user_function_definition_parser = require("linkedspec.user_function_definition_parser")

local M = {}

local FIXTURE_RESULT_MT = { __corpus_type = "CorpusFixtureExecutionResult" }
local EXECUTION_RESULT_MT = { __corpus_type = "CorpusExecutionResult" }

local function fail(message)
  error(message, 0)
end

local function join_path(root, child)
  if root:sub(-1) == "/" then
    return root .. child
  end
  return root .. "/" .. child
end

function M.node_type(value)
  if type(value) ~= "table" then return nil end
  local metatable = getmetatable(value)
  return metatable and metatable.__corpus_type or nil
end

function M.is_corpus_fixture_execution_result(value)
  return getmetatable(value) == FIXTURE_RESULT_MT
end

function M.is_corpus_execution_result(value)
  return getmetatable(value) == EXECUTION_RESULT_MT
end

local function require_fixture_result(value)
  if not M.is_corpus_fixture_execution_result(value) then
    fail("expected CorpusFixtureExecutionResult")
  end
  return value
end

local function require_execution_result(value)
  if not M.is_corpus_execution_result(value) then
    fail("expected CorpusExecutionResult")
  end
  return value
end

local function copy_list(values)
  local result = {}
  for index, value in ipairs(values) do result[index] = value end
  return result
end

local function copy_json(value)
  return json.decode(json.encode(value))
end

local function copy_runtime_value(value, active)
  if type(value) ~= "table" or value == json.null then return value end
  active = active or {}
  if active[value] ~= nil then return active[value] end
  local kind = json.kind(value)
  local result
  if kind == "array" then
    result = json.array()
  elseif kind == "harray" then
    result = json.harray()
  else
    result = setmetatable({}, getmetatable(value))
  end
  active[value] = result
  for key, item in pairs(value) do
    rawset(result, copy_runtime_value(key, active), copy_runtime_value(item, active))
  end
  return result
end

local function format_json(value)
  local ok, encoded = pcall(json.encode, value)
  if ok then return encoded end
  return "<non-JSON runtime value: " .. tostring(encoded) .. ">"
end

local function json_equal(left, right)
  if left == right then return true end
  local left_kind = json.kind(left)
  local right_kind = json.kind(right)
  if left_kind ~= right_kind then return false end
  if left_kind == "array" then
    if #left ~= #right then return false end
    for index = 1, #left do
      if not json_equal(left[index], right[index]) then return false end
    end
    return true
  end
  if left_kind == "harray" then
    local left_count = 0
    local right_count = 0
    for key, value in pairs(left) do
      left_count = left_count + 1
      if right[key] == nil or not json_equal(value, right[key]) then return false end
    end
    for _ in pairs(right) do right_count = right_count + 1 end
    return left_count == right_count
  end
  return false
end

local function trace_lines(emitter)
  if emitter == nil then return {} end
  return trace.trace_lines(emitter)
end

local function fixture_result(fixture, fields)
  return setmetatable({
    name = fixture.name,
    expected_json = copy_json(fixture.expected_json),
    actual_value = fields.actual_value,
    actual_output = fields.actual_output,
    matched = fields.matched,
    cursor_code_unit = fields.cursor_code_unit,
    cursor_char_offset = fields.cursor_char_offset,
    trace_lines = copy_list(fields.trace_lines or {}),
    diagnostic = fields.diagnostic,
    failure_stage = fields.failure_stage,
    failure = fields.failure,
  }, FIXTURE_RESULT_MT)
end

function M.corpus_fixture_passed(result)
  return require_fixture_result(result).failure == nil
end

function M.corpus_failures(result)
  result = require_execution_result(result)
  local failures = {}
  for _, fixture in ipairs(result.results) do
    if not M.corpus_fixture_passed(fixture) then failures[#failures + 1] = fixture end
  end
  return failures
end

function M.corpus_execution_passed(result)
  return #M.corpus_failures(result) == 0
end

function M.corpus_passed_count(result)
  result = require_execution_result(result)
  local count = 0
  for _, fixture in ipairs(result.results) do
    if M.corpus_fixture_passed(fixture) then count = count + 1 end
  end
  return count
end

function M.corpus_fixture_result(result, name)
  result = require_execution_result(result)
  if type(name) ~= "string" or name == "" then
    fail("executed corpus fixture name must be a non-empty string")
  end
  for _, fixture in ipairs(result.results) do
    if fixture.name == name then return fixture end
  end
  fail("executed corpus fixture not found: " .. name)
end

local function read_utf8_file(path, label)
  local handle = io.open(path, "rb")
  if not handle then
    fail("required " .. label .. " file missing: " .. path)
  end
  local bytes = handle:read("*a")
  handle:close()
  local valid, invalid_position = json.validate_utf8(bytes)
  if not valid then
    fail(label .. " is not valid UTF-8 at byte " .. invalid_position .. ": " .. path)
  end
  return bytes
end

local function shell_quote(value)
  if value:find("\0", 1, true) then
    fail("corpus path contains a NUL byte")
  end
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function directory_exists(path)
  local command = "if [ -d " .. shell_quote(path) .. " ]; then printf 'yes'; fi"
  local handle = io.popen(command, "r")
  if not handle then
    return false
  end
  local output = handle:read("*a")
  local closed = handle:close()
  return closed ~= nil and closed ~= false and output == "yes"
end

local function directory_names(root)
  local command = "find " .. shell_quote(root) .. " -mindepth 1 -maxdepth 1 -type d -print0"
  local handle = io.popen(command, "r")
  if not handle then
    fail("unable to inspect corpus fixture directories: " .. root)
  end
  local output = handle:read("*a")
  local closed = handle:close()
  if closed == nil or closed == false then
    fail("unable to inspect corpus fixture directories: " .. root)
  end

  local names = {}
  local start = 1
  while start <= #output do
    local ending = output:find("\0", start, true)
    if not ending then
      fail("fixture directory inventory was not NUL-delimited")
    end
    local path = output:sub(start, ending - 1)
    local name = path:match("([^/]+)$")
    if not name then
      fail("invalid fixture directory path: " .. path)
    end
    names[#names + 1] = name
    start = ending + 1
  end
  table.sort(names)
  return names
end

local function required_integer(object, key, manifest_path)
  local value = object[key]
  if type(value) ~= "number" or value % 1 ~= 0 then
    fail("malformed corpus manifest " .. manifest_path .. ": field " .. key .. " must be an integer")
  end
  return value
end

local function required_string_array(object, key, manifest_path)
  local value = object[key]
  if json.kind(value) ~= "array" then
    fail("malformed corpus manifest " .. manifest_path .. ": field " .. key .. " must be an array")
  end
  for _, item in ipairs(value) do
    if type(item) ~= "string" then
      fail("malformed corpus manifest " .. manifest_path .. ": field " .. key .. " must contain only strings")
    end
  end
  return value
end

local function load_manifest(root)
  local manifest_path = join_path(root, "manifest.json")
  local source = read_utf8_file(manifest_path, "corpus manifest")
  local ok, decoded = pcall(json.decode, source)
  if not ok then
    fail("malformed corpus manifest " .. manifest_path .. ": " .. tostring(decoded))
  end
  if json.kind(decoded) ~= "harray" then
    fail("malformed corpus manifest " .. manifest_path .. ": top-level value must be an object")
  end

  local format = required_integer(decoded, "format", manifest_path)
  if format ~= 1 then
    fail("unsupported corpus manifest format " .. format .. " in " .. manifest_path)
  end
  local case_count = required_integer(decoded, "case_count", manifest_path)
  local cases = required_string_array(decoded, "cases", manifest_path)
  if case_count ~= #cases then
    fail("corpus manifest case_count=" .. case_count .. " does not match cases.len()=" .. #cases)
  end
  if case_count <= 0 then
    fail("corpus manifest must name at least one fixture")
  end

  local seen = {}
  for _, name in ipairs(cases) do
    if not name:match("^[A-Za-z0-9][A-Za-z0-9_.-]*$") then
      fail("invalid corpus manifest case name: " .. name)
    end
    if seen[name] then
      fail("corpus manifest contains duplicate case names")
    end
    seen[name] = true
  end

  return {
    format = format,
    case_count = case_count,
    cases = cases,
  }
end

local function assert_manifest_matches_directories(root, manifest)
  local actual_names = directory_names(root)
  local expected = {}
  local actual = {}
  for _, name in ipairs(manifest.cases) do
    expected[name] = true
  end
  for _, name in ipairs(actual_names) do
    actual[name] = true
  end

  local missing = {}
  local extra = {}
  for _, name in ipairs(manifest.cases) do
    if not actual[name] then
      missing[#missing + 1] = name
    end
  end
  for _, name in ipairs(actual_names) do
    if not expected[name] then
      extra[#extra + 1] = name
    end
  end
  if #missing > 0 or #extra > 0 then
    fail(
      "oracle corpus manifest drift\n" ..
      "missing fixture dirs: [" .. table.concat(missing, ", ") .. "]\n" ..
      "extra fixture dirs: [" .. table.concat(extra, ", ") .. "]\n" ..
      "regenerate with `perl tools/gen_oracle_corpus.pl` and stage the manifest plus fixture dirs"
    )
  end
end

local function load_fixture(root, case_name)
  local case_root = join_path(root, case_name)
  local spec_source = read_utf8_file(join_path(case_root, "input.spec"), "input.spec")
  local input_text = read_utf8_file(join_path(case_root, "input.txt"), "input.txt")
  local expected_source = read_utf8_file(join_path(case_root, "expected.json"), "expected.json")
  local ok, expected_json = pcall(json.decode, expected_source)
  if not ok then
    fail("malformed expected.json for corpus case " .. case_name .. ": " .. tostring(expected_json))
  end
  return {
    name = case_name,
    spec_source = spec_source,
    input_text = input_text,
    expected_json = expected_json,
  }
end

function M.load_corpus_fixtures(root)
  if type(root) ~= "string" or root == "" then
    fail("corpus path must be a non-empty string")
  end
  if not directory_exists(root) then
    fail("corpus directory missing: " .. root)
  end
  local manifest = load_manifest(root)
  assert_manifest_matches_directories(root, manifest)
  local fixtures = {}
  for index, case_name in ipairs(manifest.cases) do
    fixtures[index] = load_fixture(root, case_name)
  end
  return {
    root = root,
    manifest = manifest,
    fixtures = fixtures,
  }
end

local function dense_string_list(value, label)
  if value == nil then return {} end
  if type(value) ~= "table" then fail(label .. " must be a table") end
  local result = {}
  for index, item in ipairs(value) do
    if type(item) ~= "string" or item == "" then
      fail(label .. " must contain only non-empty strings")
    end
    result[index] = item
  end
  for key in pairs(value) do
    if type(key) ~= "number" or key % 1 ~= 0 or key < 1 or key > #result then
      fail(label .. " must be a dense one-based list")
    end
  end
  return result
end

local function select_fixtures(fixtures, options)
  local offset = options.offset
  if offset == nil then offset = 0 end
  if type(offset) ~= "number" or offset % 1 ~= 0 or offset < 0 then
    fail("corpus execution offset must be a non-negative integer")
  end
  local limit = options.limit
  if limit ~= nil and (type(limit) ~= "number" or limit % 1 ~= 0 or limit <= 0) then
    fail("corpus execution limit must be a positive integer")
  end

  local case_names = dense_string_list(options.case_names, "corpus execution case selection")
  if #case_names > 0 then
    if offset ~= 0 or limit ~= nil then
      fail("corpus execution case selection cannot be combined with offset or limit")
    end
    local fixtures_by_name = {}
    for _, fixture in ipairs(fixtures) do fixtures_by_name[fixture.name] = fixture end
    local selected = {}
    local seen = {}
    for _, name in ipairs(case_names) do
      if seen[name] then
        fail("corpus execution selection contains duplicate case name: " .. name)
      end
      local fixture = fixtures_by_name[name]
      if fixture == nil then fail("selected corpus case not found in manifest: " .. name) end
      seen[name] = true
      selected[#selected + 1] = fixture
    end
    return selected
  end

  if offset >= #fixtures then
    fail("corpus execution offset " .. offset .. " is outside fixture count " .. #fixtures)
  end
  local selected_count = #fixtures - offset
  if limit ~= nil and limit < selected_count then selected_count = limit end
  local selected = {}
  for index = 1, selected_count do selected[index] = fixtures[offset + index] end
  return selected
end

local function failure_stage(value)
  if spec_parser.is_parse_error(value) or
      user_function_definition_parser.is_error(value) or
      staged_parser_registry.is_staged_parser_registry_error(value) then
    return "parse"
  end
  if spec_validator.is_validation_error(value) then return "validate" end
  if compiled_spec.is_compiled_spec_error(value) then return "compile" end
  if interpreter.is_runtime_interpreter_error(value) then return "execute" end
  return "unexpected"
end

local function execute_fixture(validation, fixture, options)
  local emitter
  local parse_result
  local ok, value_or_error = pcall(function()
    if options.trace_config ~= nil then
      emitter = trace.trace_emitter(options.trace_config, { stdout_writer = function() end })
    end
    local spec = user_function_definition_parser.parse_spec_with_staged_user_function_definitions(
      fixture.spec_source,
      nil,
      { trace = emitter }
    )
    spec_validator.validate_spec(spec, { trace = emitter })
    local compiled = compiled_spec.compile_spec(spec, { validate_source = false, trace = emitter })
    local engine = interpreter.runtime_engine(compiled, {
      spec_name = fixture.name,
      spec_path = join_path(join_path(validation.root, fixture.name), "input.spec"),
      trace = emitter,
    })
    parse_result = interpreter.runtime_parse(engine, fixture.input_text, { trace = emitter })
    return parse_result
  end)

  if not ok then
    local diagnostic
    if interpreter.is_runtime_interpreter_error(value_or_error) then
      diagnostic = value_or_error.diagnostic
    end
    return fixture_result(fixture, {
      actual_value = parse_result and copy_runtime_value(parse_result.value) or nil,
      actual_output = parse_result and copy_runtime_value(parse_result.output) or nil,
      matched = parse_result and parse_result.matched or nil,
      cursor_code_unit = parse_result and parse_result.cursor_code_unit or nil,
      cursor_char_offset = parse_result and parse_result.cursor_char_offset or nil,
      trace_lines = trace_lines(emitter),
      diagnostic = diagnostic,
      failure_stage = failure_stage(value_or_error),
      failure = tostring(value_or_error),
    })
  end

  local expected_output = json.array({ fixture.expected_json })
  local common = {
    actual_value = copy_runtime_value(parse_result.value),
    actual_output = copy_runtime_value(parse_result.output),
    matched = parse_result.matched,
    cursor_code_unit = parse_result.cursor_code_unit,
    cursor_char_offset = parse_result.cursor_char_offset,
    trace_lines = trace_lines(emitter),
  }
  if not parse_result.matched then
    common.failure_stage = "match"
    common.failure = "runtime did not match input; cursor_code_unit=" .. parse_result.cursor_code_unit
    return fixture_result(fixture, common)
  end
  if not json_equal(parse_result.output, expected_output) then
    common.failure_stage = "compare"
    common.failure =
      "output mismatch on input " .. format_json(fixture.input_text) .. "\n" ..
      "    expected (reference, wrapped): " .. format_json(expected_output) .. "\n" ..
      "    actual   (runtime_parse)       : " .. format_json(parse_result.output)
    return fixture_result(fixture, common)
  end
  return fixture_result(fixture, common)
end

function M.execute_corpus_fixtures(root, options)
  options = options or {}
  if type(options) ~= "table" then fail("corpus execution options must be a table") end
  interpreter.reject_removed_runtime_options(options)
  if options.trace_config ~= nil and not trace.is_trace_config(options.trace_config) then
    fail("corpus execution trace_config must be a LinkedSpecTraceConfig")
  end

  local validation = M.load_corpus_fixtures(root)
  local selected = select_fixtures(validation.fixtures, options)
  local results = {}
  for index, fixture in ipairs(selected) do
    results[index] = execute_fixture(validation, fixture, options)
  end
  return setmetatable({ validation = validation, results = results }, EXECUTION_RESULT_MT)
end

return M
