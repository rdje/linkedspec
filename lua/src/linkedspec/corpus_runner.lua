local corpus = require("linkedspec.corpus")

local M = {}

local function write_help(io)
  io:write("LinkedSpec Lua corpus runner\n\n")
  io:write("Usage:\n")
  io:write("  corpus_runner.lua --corpus <path>\n\n")
  io:write("Validates strict UTF-8 fixture IO and expected JSON without executing parsers.\n")
end

function M.run(args, output, error_output)
  output = output or io.stdout
  error_output = error_output or io.stderr
  if #args == 0 then
    write_help(output)
    return 0
  end

  local corpus_path = nil
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
      errors[#errors + 1] = "--execute is unavailable until the Lua runtime corpus leaf"
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

  local ok, validation = pcall(corpus.load_corpus_fixtures, corpus_path)
  if not ok then
    error_output:write("error: ", tostring(validation), "\n")
    return 2
  end
  output:write("corpus: ", validation.root, "\n")
  output:write("format: ", validation.manifest.format, "\n")
  output:write("fixtures: ", validation.manifest.case_count, "\n")
  output:write("status: manifest validated; parser execution is not implemented\n")
  return 0
end

return M
