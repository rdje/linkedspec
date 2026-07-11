#!/usr/bin/env lua

local function prepend_repo_module_path()
  local source = debug.getinfo(1, "S").source
  local script_path = source:sub(1, 1) == "@" and source:sub(2) or source
  local bin_dir = script_path:match("^(.*)[/\\][^/\\]+$")
  local lua_root = bin_dir and bin_dir:match("^(.*)[/\\]bin$")
  if not lua_root then
    io.stderr:write("linkedspec-lua corpus runner: unable to resolve repository module path\n")
    os.exit(2)
  end
  package.path = lua_root .. "/src/?.lua;" .. lua_root .. "/src/?/init.lua;" .. package.path
end

prepend_repo_module_path()
local linkedspec = require("linkedspec")
local result = linkedspec.corpus_runner_scaffold_result(arg)
io.stderr:write(result.stderr)
os.exit(result.exit_code)
