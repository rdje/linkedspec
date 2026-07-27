local linkedspec = require("linkedspec")

local temp_root = assert(os.getenv("TMPDIR"), "TMPDIR is required")
assert(temp_root ~= "", "TMPDIR must not be empty")
local probe_root = assert(
  os.getenv("LINKEDSPEC_LUA_STORAGE_PROBE_ROOT"),
  "LINKEDSPEC_LUA_STORAGE_PROBE_ROOT is required"
)
local normalized_temp = temp_root:gsub("/+$", "")
assert(probe_root:sub(1, #normalized_temp + 1) == normalized_temp .. "/",
  "Lua storage probe must be below routed TMPDIR")

local function write_file(path, value)
  local handle = assert(io.open(path, "wb"))
  assert(handle:write(value))
  assert(handle:close())
end

local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local value = assert(handle:read("*a"))
  assert(handle:close())
  return value
end

local compiled = linkedspec.compile_spec(linkedspec.parse_spec(table.concat({
  "Top::",
  " /x/",
  ' E { return("ssd") }',
}, "\n")))
local parsed = linkedspec.runtime_parse(linkedspec.runtime_engine(compiled), "x")
assert(parsed.value == "ssd", "native runtime did not execute the storage probe")

local generated_path = probe_root .. "/generated_parser.lua"
write_file(generated_path, linkedspec.emit_lua_source_v2(compiled, "generated/storage.spec"))
assert(read_file(generated_path):find("linkedspec%-generated%-source%-v2") ~= nil,
  "generated source contract marker is missing")

local trace_path = probe_root .. "/storage.trace"
local trace_config = linkedspec.with_trace_reset_file(linkedspec.with_trace_file(
  linkedspec.trace_config_enabled(linkedspec.TRACE_LOW),
  trace_path
))
local emitter = linkedspec.trace_emitter(trace_config)
linkedspec.emit_trace_line(emitter, linkedspec.TRACE_LOW, "lua-storage")
assert(read_file(trace_path) == "lua-storage\n", "trace output drifted")

io.write("[lua-project-data-runtime-test] PASS: generated source and trace use routed storage\n")
