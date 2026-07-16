local corpus = require("linkedspec.corpus")

local M = {}

local function write_help(io)
  io:write("LinkedSpec Lua corpus runner\n\n")
  io:write("Usage:\n")
  io:write("  corpus_runner.lua --corpus <path> [--execute]\n\n")
  io:write("Without --execute, validates strict UTF-8 fixture IO and expected JSON.\n")
  io:write("With --execute, runs the complete manifest through the native in-memory interpreter.\n")
end

local function write_validation_header(output, validation)
  output:write("corpus: ", validation.root, "\n")
  output:write("format: ", validation.manifest.format, "\n")
  output:write("fixtures: ", validation.manifest.case_count, "\n")
end

local function write_execution(output, execution)
  write_validation_header(output, execution.validation)
  for _, result in ipairs(execution.results) do
    if corpus.corpus_fixture_passed(result) then
      output:write("PASS ", result.name, "\n")
    else
      output:write(
        "FAIL ",
        result.name,
        " [",
        result.failure_stage or "unexpected",
        "]: ",
        result.failure or "unknown failure",
        "\n"
      )
    end
  end
  local passed = corpus.corpus_passed_count(execution)
  local failed = #corpus.corpus_failures(execution)
  output:write("summary: ", passed, " passed, ", failed, " failed\n")
  if failed == 0 then return 0 end
  return 1
end

function M.run(args, output, error_output)
  output = output or io.stdout
  error_output = error_output or io.stderr
  if #args == 0 then
    write_help(output)
    return 0
  end

  local corpus_path = nil
  local execute = false
  local errors = {}
  local index = 1
  while index <= #args do
    local argument = args[index]
    if argument == "--help" or argument == "-h" then
      write_help(output)
      return 0
    elseif argument == "--corpus" then
      if index == #args then
        errors[#errors + 1] = "--corpus requires a path"
        index = index + 1
      else
        corpus_path = args[index + 1]
        index = index + 2
      end
    elseif argument:sub(1, 9) == "--corpus=" then
      corpus_path = argument:sub(10)
      index = index + 1
    elseif argument == "--execute" then
      execute = true
      index = index + 1
    else
      errors[#errors + 1] = "unknown argument: " .. argument
      index = index + 1
    end
  end

  if corpus_path == nil or corpus_path == "" then
    errors[#errors + 1] = "--corpus <path> is required"
  end
  if #errors > 0 then
    error_output:write("error: ", table.concat(errors, "; "), "\n")
    return 2
  end

  local ok, result = pcall(function()
    if execute then return corpus.execute_corpus_fixtures(corpus_path) end
    return corpus.load_corpus_fixtures(corpus_path)
  end)
  if not ok then
    error_output:write("error: ", tostring(result), "\n")
    return 2
  end
  if execute then return write_execution(output, result) end
  write_validation_header(output, result)
  output:write("status: manifest validated; execution not requested\n")
  return 0
end

return M
