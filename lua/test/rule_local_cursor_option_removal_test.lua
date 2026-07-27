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
  local temp_root = assert(os.getenv("TMPDIR"), "TMPDIR is required")
  assert(temp_root ~= "", "TMPDIR must not be empty")
  local template = temp_root:gsub("/+$", "") .. "/linkedspec-lua-option-removal.XXXXXX"
  local handle = assert(io.popen("mktemp -d " .. shell_quote(template), "r"))
  local root = assert(handle:read("*l"))
  assert(handle:close())
  local ok, value = pcall(operation, root)
  local cleaned = command_succeeded("rm -rf " .. shell_quote(root))
  if not cleaned then error("unable to clean option-removal test directory", 0) end
  if not ok then error(value, 0) end
end

local function check_removed_failure(ok, failure, label)
  check_equal(ok, false, label .. " rejected")
  local typed = linkedspec.is_runtime_interpreter_error(failure)
  check_equal(typed, true, label .. " typed error")
  local diagnostic = typed and failure.diagnostic or nil
  check_equal(linkedspec.is_runtime_diagnostic(diagnostic), true, label .. " typed diagnostic")
  check_equal(diagnostic and diagnostic.stage, "prepare_options", label .. " stage")
  check_equal(diagnostic and diagnostic.code, "parse_mode_override_removed", label .. " code")
  check_equal(diagnostic and diagnostic.option_name, "parse_mode", label .. " option name")
  check_equal(
    diagnostic and diagnostic.detail,
    "cursor policy is derived from each rule (OR/default=seek, AND=consume)",
    label .. " detail"
  )
end

local function load_generated_module(source, name)
  local loader = loadstring or load
  local chunk, failure = loader(source, name)
  if chunk == nil then error(failure, 0) end
  return chunk()
end

local interpreter_source = read_file("lua/src/linkedspec/interpreter.lua")
local loader_source = read_file("lua/src/linkedspec/spec_loader.lua")
local corpus_source = read_file("lua/src/linkedspec/corpus.lua")
local emitter_source = read_file("lua/src/linkedspec/source_emitter.lua")
local cli_source = read_file("lua/src/linkedspec/primary_cli.lua")
local matching_source = read_file("lua/src/linkedspec/matching.lua")

check(interpreter_source:find("engine.parse_mode", 1, true) == nil, "engine cursor override removed")
check(interpreter_source:find("parse_mode_override_removed", 1, true) ~= nil, "runtime owns removal code")
check(loader_source:find("parse_mode", 1, true) == nil, "loader is cursor-option free")
check(corpus_source:find("parse_mode", 1, true) == nil, "corpus is cursor-option free")
check(emitter_source:find("parse_mode", 1, true) == nil, "emitter is cursor-option free")
check(cli_source:find("--parse-mode MODE", 1, true) == nil, "help omits retired flag")
check(cli_source:find("options.parse_mode", 1, true) == nil, "CLI execution has no cursor override")
check(cli_source:find('option == "--parse-mode"', 1, true) ~= nil, "CLI recognizes retired flag")
check(matching_source:find("function M.runtime_match", 1, true) ~= nil, "low-level runtime matcher remains")
check(matching_source:find("function M.seek_match", 1, true) ~= nil, "low-level seek matcher remains")
check(matching_source:find("function M.consume_match", 1, true) ~= nil, "low-level consume matcher remains")
check(
  matching_source:find("function M.parse_mode_from_name", 1, true) ~= nil,
  "low-level mode parser remains"
)

local source = [[
Top::AND
 /x/ -> Top { return("hit") }
]]
local compiled = linkedspec.compile_spec(linkedspec.parse_spec(source))
local intrinsic = linkedspec.runtime_parse(linkedspec.runtime_engine(compiled), "prefix x")
check_equal(json.encode(intrinsic.value), "null", "AND remains intrinsically consume")

local engine_snake_ok, engine_snake = capture(function()
  return linkedspec.runtime_engine(compiled, {
    parse_mode = "seek",
    spec_name = "option-removal.spec",
  })
end)
check_removed_failure(engine_snake_ok, engine_snake, "engine snake-case option")
check_equal(
  engine_snake and engine_snake.diagnostic and engine_snake.diagnostic.spec_name,
  "option-removal.spec",
  "engine removal retains logical identity"
)

local engine_camel_ok, engine_camel = capture(function()
  return linkedspec.runtime_engine(compiled, { parseMode = "consume" })
end)
check_removed_failure(engine_camel_ok, engine_camel, "engine camel-case option")

local engine = linkedspec.runtime_engine(compiled, { spec_name = "parse-option.spec" })
local parse_snake_ok, parse_snake = capture(function()
  return linkedspec.runtime_parse(engine, "prefix x", { parse_mode = "seek" })
end)
check_removed_failure(parse_snake_ok, parse_snake, "parse snake-case option")
check_equal(
  parse_snake and parse_snake.diagnostic and parse_snake.diagnostic.spec_name,
  "parse-option.spec",
  "parse removal retains engine identity"
)

local parse_camel_ok, parse_camel = capture(function()
  return linkedspec.runtime_parse_with_trace(
    engine,
    "prefix x",
    linkedspec.trace_config_enabled(linkedspec.TRACE_LOW),
    { parseMode = "consume", stdout_writer = function() end }
  )
end)
check_removed_failure(parse_camel_ok, parse_camel, "traced parse camel-case option")

with_temp_directory(function(root)
  local path = root .. "/option-removal.spec"
  write_file(path, source)
  local loaded = linkedspec.load_and_compile_spec(
    linkedspec.path_spec_request("option-removal.spec"),
    linkedspec.spec_load_options({ cwd = root, search_roots = {} })
  )
  local loaded_ok, loaded_failure = capture(function()
    return loaded:create_engine({ parse_mode = "seek" })
  end)
  check_removed_failure(loaded_ok, loaded_failure, "loaded engine option")
  check_equal(
    loaded_failure and loaded_failure.diagnostic and loaded_failure.diagnostic.spec_path,
    path,
    "loaded removal retains resolved path"
  )

  local corpus_snake_ok, corpus_snake = capture(function()
    return linkedspec.execute_corpus_fixtures(root .. "/missing-corpus", { parse_mode = "seek" })
  end)
  check_removed_failure(corpus_snake_ok, corpus_snake, "corpus snake-case option before load")

  local corpus_camel_ok, corpus_camel = capture(function()
    return linkedspec.execute_corpus_fixtures(root .. "/missing-corpus", { parseMode = "consume" })
  end)
  check_removed_failure(corpus_camel_ok, corpus_camel, "corpus camel-case option before load")
end)

local plan = linkedspec.build_generated_rule_plan(compiled)
local direct_ok, direct_failure = capture(function()
  return linkedspec.execute_generated_parser_v2(
    compiled,
    plan,
    "prefix x",
    "option-removal-direct.spec",
    { parse_mode = "seek" }
  )
end)
check_removed_failure(direct_ok, direct_failure, "generated direct option")

local emitted = load_generated_module(
  linkedspec.emit_lua_source_v2(compiled, "option-removal-emitted.spec"),
  "@option-removal-emitted.lua"
)
local emitted_ok, emitted_failure = capture(function()
  return emitted.execute_with_trace(
    "prefix x",
    linkedspec.trace_config_enabled(linkedspec.TRACE_LOW),
    { parseMode = "consume", stdout_writer = function() end }
  )
end)
check_removed_failure(emitted_ok, emitted_failure, "generated emitted traced option")

local removed_message = "--parse-mode has been removed; " ..
  "cursor policy is derived from each rule (OR/default=seek, AND=consume)"
local retired = linkedspec.run_primary_cli({
  "--inline-spec",
  "not a spec",
  "--input-file",
  "missing-input.txt",
  "--parse-mode",
  "consume",
})
check_equal(retired.exit_code, 2, "retired CLI flag exit")
check_equal(retired.stdout, "", "retired CLI flag stdout")
check_equal(retired.stderr:match("^[^\n]+"), "linkedspec: " .. removed_message, "retired CLI first line")

local retired_inline = linkedspec.run_primary_cli({ "--parse-mode=seek" })
check_equal(retired_inline.exit_code, 2, "retired inline CLI flag exit")
check_equal(retired_inline.stderr:match("^[^\n]+"), "linkedspec: " .. removed_message, "retired inline first line")

local help = linkedspec.run_primary_cli({ "--help" })
check_equal(help.exit_code, 0, "help exit")
check(help.stdout:find("--parse-mode", 1, true) == nil, "help output omits retired flag")
check_equal(help.stderr, "", "help stderr")

local top_source = [[
Top::
 /x/
 I { return("top") }

Alternate:
 /x/
 I { return("alternate") }
]]
local selected = linkedspec.run_primary_cli({
  "--inline-spec",
  top_source,
  "--input",
  "x",
  "--top-rule",
  "Alternate",
})
check_equal(selected.exit_code, 0, "top-rule remains accepted")
check_equal(selected.stdout, '"alternate"\n', "top-rule remains higher priority than Rule::")
check_equal(selected.stderr, "", "top-rule stderr")

local traced = linkedspec.run_primary_cli({
  "--inline-spec",
  top_source,
  "--input",
  "x",
  "--trace",
  "medium",
})
check_equal(traced.exit_code, 0, "medium trace exit")
check_contains(traced.stdout, "request source=inline input=literal top_rule=<default>", "request trace shape")
check(traced.stdout:find("parse_mode", 1, true) == nil, "request trace omits cursor option")
check_equal(traced.stderr, "", "medium trace stderr")

local alternation = linkedspec.compile_runtime_regex_alternation({ "x" })
check_equal(alternation:seek_match("prefix x", 0):text(), "x", "low-level seek remains")
check_equal(alternation:consume_match("prefix x", 0), nil, "low-level consume remains anchored")

if #failures == 0 then
  io.stdout:write("rule-local cursor option removal: ", assertions, " assertions passed\n")
else
  io.stderr:write("rule-local cursor option removal: ", #failures, " of ", assertions, " assertions failed\n")
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
