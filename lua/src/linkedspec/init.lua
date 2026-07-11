local corpus = require("linkedspec.corpus")
local json = require("linkedspec.json")
local spec_ast = require("linkedspec.spec_ast")
local spec_parser = require("linkedspec.spec_parser")
local spec_validator = require("linkedspec.spec_validator")
local function_shell = require("linkedspec.user_function_definition_shell")

local M = {}

M.PACKAGE_NAME = "linkedspec"
M.PACKAGE_VERSION = "0.1.0"
M.BACKEND_NAME = "lua"
M.PARITY_STATUS = "function_projection"
M.CLI_ENTRYPOINT = "lua/bin/linkedspec-lua"
M.CORPUS_RUNNER_ENTRYPOINT = "lua/bin/corpus_runner.lua"

local function copy_table(value)
  local result = {}
  for key, item in pairs(value) do
    result[key] = item
  end
  return result
end

function M.backend_name()
  return M.BACKEND_NAME
end

function M.cli_entrypoint()
  return M.CLI_ENTRYPOINT
end

function M.corpus_runner_entrypoint()
  return M.CORPUS_RUNNER_ENTRYPOINT
end

function M.runtime_implementation()
  if type(jit) == "table" and type(jit.version) == "string" then
    return "luajit"
  end
  return "puc-lua"
end

function M.backend_status()
  return copy_table({
    backend = M.BACKEND_NAME,
    package = M.PACKAGE_NAME,
    version = M.PACKAGE_VERSION,
    parity = M.PARITY_STATUS,
    runtime = M.runtime_implementation(),
    cli = M.CLI_ENTRYPOINT,
    corpus_runner = M.CORPUS_RUNNER_ENTRYPOINT,
  })
end

function M.cli_scaffold_result()
  return {
    exit_code = 2,
    stderr = "linkedspec-lua: backend scaffold; parser CLI is not implemented\n",
  }
end

M.json = json
M.load_corpus_fixtures = corpus.load_corpus_fixtures
M.spec_ast = spec_ast
M.parse_spec = spec_parser.parse_spec
M.is_spec_parse_error = spec_parser.is_parse_error
M.validate_spec = spec_validator.validate_spec
M.is_spec_validation_error = spec_validator.is_validation_error
M.project_user_function_definition_asts = function_shell.project
M.parse_spec_with_user_function_definition_asts = function_shell.parse_spec_with_asts
M.definition_nodes_from_user_function_definition_output = function_shell.definition_nodes_from_output
M.is_user_function_projection_error = function_shell.is_projection_error

return M
