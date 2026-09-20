-- The managed wrapper supplies the checkout root; select this ABI's retained products.
local source_root = assert(os.getenv("LINKEDSPEC_REPO_ROOT"), "LINKEDSPEC_REPO_ROOT is required")
local native_root = assert(os.getenv("LINKEDSPEC_LUA_NATIVE_ROOT"), "LINKEDSPEC_LUA_NATIVE_ROOT is required")
package.path = source_root .. "/lua/src/?.lua;" .. source_root .. "/lua/src/?/init.lua"
package.cpath = native_root .. "/?.so"

local linkedspec = require("linkedspec")
local filesystem = require("linkedspec_filesystem_native")
local json = linkedspec.json

local function main()
  if #arg < 2 then
    error("Usage: parse_words.lua GRAMMAR INPUT [INPUT ...]", 0)
  end
  local loaded = linkedspec.load_and_compile_spec(
    linkedspec.path_spec_request(arg[1]),
    linkedspec.spec_load_options({ cwd = filesystem.current_directory(), search_roots = {} })
  )
  local engine = loaded:create_engine()
  for index = 2, #arg do
    -- Compile once, then execute independent inputs in this Lua process.
    local result = linkedspec.runtime_parse(engine, arg[index], { top_rule = "Top" })
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
  elseif linkedspec.is_runtime_interpreter_error(failure) then
    record = linkedspec.interpreter.to_json(failure)
    record.type = "runtime_error"
  else
    record = json.harray({ type = "consumer_error", detail = tostring(failure) })
  end
  io.stderr:write(json.encode(record), "\n")
  os.exit(1)
end
