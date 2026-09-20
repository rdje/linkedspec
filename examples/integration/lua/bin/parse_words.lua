-- The managed wrapper supplies the checkout root; select this ABI's retained products.
local source_root = assert(os.getenv("LINKEDSPEC_REPO_ROOT"), "LINKEDSPEC_REPO_ROOT is required")
local native_root = assert(os.getenv("LINKEDSPEC_LUA_NATIVE_ROOT"), "LINKEDSPEC_LUA_NATIVE_ROOT is required")
package.path = source_root .. "/lua/src/?.lua;" .. source_root .. "/lua/src/?/init.lua"
package.cpath = native_root .. "/?.so"

local linkedspec = require("linkedspec")
local filesystem = require("linkedspec_filesystem_native")
local json = linkedspec.json

local function main()
  local first = 1
  local diagnostics = arg[first] == "--diagnostics"
  if diagnostics then first = first + 1 end
  if arg[first] == "--" then first = first + 1 end
  if #arg - first + 1 < 2 then
    error("Usage: parse_words.lua [--diagnostics] [--] GRAMMAR INPUT [INPUT ...]", 0)
  end
  -- This JSON adapter keeps diagnostic events separate from optional parser tracing.
  local quiet_trace = linkedspec.trace_emitter(linkedspec.trace_config_disabled())
  local loaded = linkedspec.load_and_compile_spec(
    linkedspec.path_spec_request(arg[first]),
    linkedspec.spec_load_options({ cwd = filesystem.current_directory(), search_roots = {}, trace = quiet_trace })
  )
  local engine = loaded:create_engine()
  local options = { top_rule = "Top", trace = quiet_trace }
  if diagnostics then
    options.diagnostic_sink = function(event)
      local record = linkedspec.interpreter.to_json(event)
      record.type = "diagnostic_output"
      io.stderr:write(json.encode(record), "\n")
    end
  end
  for index = first + 1, #arg do
    -- Compile once, then execute independent inputs in this Lua process.
    local result = linkedspec.runtime_parse(engine, arg[index], options)
    local value = result.value
    if value == nil then value = json.null end
    io.stdout:write(json.encode(value), "\n")
  end
end

local ok, failure = pcall(main)
if not ok then
  local record
  if linkedspec.is_spec_pipeline_error(failure) then
    record = linkedspec.spec_pipeline_error_to_json(failure)
  elseif linkedspec.is_runtime_exit_now(failure) then
    record = linkedspec.interpreter.to_json(failure)
    record.type = "runtime_exit_now"
  elseif linkedspec.is_runtime_interpreter_error(failure) then
    record = linkedspec.interpreter.to_json(failure)
    record.type = "runtime_error"
    -- The standard projection contains message/diagnostic; retain these public error fields too.
    for _, name in ipairs({ "code", "helper_name", "expected_arity", "actual_arity" }) do
      if failure[name] ~= nil then record[name] = failure[name] end
    end
  else
    record = json.harray({ type = "consumer_error", detail = tostring(failure) })
  end
  io.stderr:write(json.encode(record), "\n")
  os.exit(1)
end
