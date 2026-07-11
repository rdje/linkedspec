local total = 0
local failed = 0

local function fail(message)
  error(message, 2)
end

local function assert_equal(actual, expected, label)
  if actual ~= expected then
    fail((label or "values differ") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
  end
end

local function test(name, operation)
  total = total + 1
  local ok, message = pcall(operation)
  if ok then
    io.stdout:write("ok ", total, " - ", name, "\n")
  else
    failed = failed + 1
    io.stdout:write("not ok ", total, " - ", name, "\n")
    io.stdout:write("# ", tostring(message), "\n")
  end
end

local linkedspec = require("linkedspec")

test("native module identity is exact", function()
  assert_equal(linkedspec.backend_name(), "lua", "backend name")
  assert_equal(linkedspec.cli_entrypoint(), "lua/bin/linkedspec-lua", "CLI entrypoint")
  assert_equal(
    linkedspec.corpus_runner_entrypoint(),
    "lua/bin/corpus_runner.lua",
    "corpus runner entrypoint"
  )
end)

test("backend status is a fresh structured value", function()
  local first = linkedspec.backend_status()
  local second = linkedspec.backend_status()
  assert_equal(first.backend, "lua", "status backend")
  assert_equal(first.package, "linkedspec", "status package")
  assert_equal(first.version, "0.1.0", "status version")
  assert_equal(first.parity, "scaffold", "status parity")
  assert_equal(first.runtime, linkedspec.runtime_implementation(), "status runtime")
  first.backend = "mutated"
  assert_equal(second.backend, "lua", "status copy isolation")
end)

test("parser CLI stays explicitly unavailable", function()
  local result = linkedspec.cli_scaffold_result({ "--help" })
  assert_equal(result.exit_code, 2, "CLI scaffold status")
  assert_equal(
    result.stderr,
    "linkedspec-lua: backend scaffold; parser CLI is not implemented\n",
    "CLI scaffold error"
  )
  assert_equal(linkedspec.parse_spec, nil, "parser API must not be faked")
end)

test("corpus runner stays explicitly unavailable", function()
  local result = linkedspec.corpus_runner_scaffold_result({ "--help" })
  assert_equal(result.exit_code, 2, "corpus scaffold status")
  assert_equal(
    result.stderr,
    "linkedspec-lua corpus runner: backend scaffold; corpus IO is not implemented\n",
    "corpus scaffold error"
  )
end)

io.stdout:write("1..", total, "\n")
if failed > 0 then
  os.exit(1)
end
