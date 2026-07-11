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

local function assert_contains(actual, expected, label)
  if not tostring(actual):find(expected, 1, true) then
    fail((label or "text differs") .. ": expected to contain " .. expected .. ", got " .. tostring(actual))
  end
end

local function assert_error_contains(operation, expected, label)
  local ok, message = pcall(operation)
  if ok then
    fail((label or "operation") .. ": expected an error")
  end
  assert_contains(message, expected, label)
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
local corpus_runner = require("linkedspec.corpus_runner")
local json = linkedspec.json

local function shell_quote(value)
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function command_succeeded(command)
  local first, _, third = os.execute(command)
  if type(first) == "number" then
    return first == 0
  end
  return first == true and (third == nil or third == 0)
end

local function make_temp_directory()
  local handle = assert(io.popen("mktemp -d /private/tmp/linkedspec-lua-corpus.XXXXXX", "r"))
  local root = assert(handle:read("*l"))
  assert(handle:close())
  return root
end

local function write_file(path, value)
  local handle = assert(io.open(path, "wb"))
  assert(handle:write(value))
  assert(handle:close())
end

local function make_directory(path)
  if not command_succeeded("mkdir -p " .. shell_quote(path)) then
    fail("unable to create test directory: " .. path)
  end
end

local function with_temp_directory(operation)
  local root = make_temp_directory()
  local ok, message = pcall(operation, root)
  local cleaned = command_succeeded("rm -rf " .. shell_quote(root))
  if not cleaned then
    fail("unable to remove test directory: " .. root)
  end
  if not ok then
    error(message, 0)
  end
end

local function write_manifest(root, cases, options)
  options = options or {}
  local case_values = {}
  for index, name in ipairs(cases) do
    case_values[index] = name
  end
  local manifest = json.harray({
    format = options.format or 1,
    case_count = options.case_count or #cases,
    cases = json.array(case_values),
  })
  write_file(root .. "/manifest.json", json.encode(manifest))
end

local function write_fixture(root, name, options)
  options = options or {}
  local fixture = root .. "/" .. name
  make_directory(fixture)
  write_file(fixture .. "/input.spec", options.spec_source or "Top::\n /x/\n")
  write_file(fixture .. "/input.txt", options.input_text or "x")
  if options.expected_source ~= false then
    write_file(fixture .. "/expected.json", options.expected_source or '"ok"')
  end
end

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
  assert_equal(first.parity, "corpus_io", "status parity")
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

test("strict JSON preserves null array and harray identity", function()
  local value = json.decode('{"z":0,"a":[true,null,{"é":"😀"}]}')
  assert_equal(json.kind(value), "harray", "root JSON kind")
  assert_equal(json.kind(value.a), "array", "nested JSON kind")
  assert_equal(value.a[2], json.null, "JSON null sentinel")
  assert_equal(json.kind(value.a[3]), "harray", "nested harray kind")
  assert_equal(value.a[3]["é"], "😀", "Unicode value")
  assert_equal(json.encode(value), '{"a":[true,null,{"é":"😀"}],"z":0}', "canonical JSON")
end)

test("JSON Unicode escapes and strict UTF-8 are exact", function()
  assert_equal(json.decode('"\\uD83D\\uDE00"'), "😀", "surrogate pair")
  assert_error_contains(function()
    json.decode('"' .. string.char(0xC3) .. '"')
  end, "not valid UTF-8", "invalid UTF-8 JSON")
  assert_error_contains(function()
    json.decode('{"a":1,"a":2}')
  end, "duplicate object key", "duplicate key")
  assert_error_contains(function()
    json.decode('"\\uD83D"')
  end, "high surrogate", "unpaired surrogate")
  assert_error_contains(function()
    json.encode({ "ambiguous" })
  end, "plain Lua tables are ambiguous", "plain table encoding")
end)

test("checked-in corpus validates all 105 strict fixtures", function()
  local validation = linkedspec.load_corpus_fixtures("rust/linkedspec-runtime/tests/corpus")
  assert_equal(validation.manifest.format, 1, "manifest format")
  assert_equal(validation.manifest.case_count, 105, "manifest count")
  assert_equal(#validation.fixtures, 105, "fixture count")
  assert_equal(validation.fixtures[1].name, "proof_edge_array_literal", "first fixture")
  assert_equal(json.kind(validation.fixtures[1].expected_json), "array", "expected JSON kind")
end)

test("corpus runner validates but does not execute", function()
  local output_path = os.tmpname()
  local error_path = os.tmpname()
  local output = assert(io.open(output_path, "w+"))
  local error_output = assert(io.open(error_path, "w+"))
  local status = corpus_runner.run({ "--corpus", "rust/linkedspec-runtime/tests/corpus" }, output, error_output)
  output:seek("set", 0)
  error_output:seek("set", 0)
  local output_text = output:read("*a")
  local error_text = error_output:read("*a")
  output:close()
  error_output:close()
  os.remove(output_path)
  os.remove(error_path)
  assert_equal(status, 0, "corpus runner status")
  assert_contains(output_text, "fixtures: 105", "corpus runner count")
  assert_contains(output_text, "parser execution is not implemented", "execution boundary")
  assert_equal(error_text, "", "corpus runner stderr")
end)

test("corpus manifest rejects format names duplicates and count drift", function()
  assert_error_contains(function()
    linkedspec.load_corpus_fixtures("/private/tmp/linkedspec-lua-corpus-does-not-exist")
  end, "corpus directory missing", "missing corpus root")
  with_temp_directory(function(root)
    write_manifest(root, { "alpha" }, { format = 2 })
    write_fixture(root, "alpha")
    assert_error_contains(function()
      linkedspec.load_corpus_fixtures(root)
    end, "unsupported corpus manifest format 2", "manifest format")
  end)
  with_temp_directory(function(root)
    write_manifest(root, { "../bad" })
    assert_error_contains(function()
      linkedspec.load_corpus_fixtures(root)
    end, "invalid corpus manifest case name: ../bad", "manifest case name")
  end)
  with_temp_directory(function(root)
    write_manifest(root, { "alpha", "alpha" })
    assert_error_contains(function()
      linkedspec.load_corpus_fixtures(root)
    end, "duplicate case names", "duplicate cases")
  end)
  with_temp_directory(function(root)
    write_manifest(root, { "alpha" }, { case_count = 2 })
    write_fixture(root, "alpha")
    assert_error_contains(function()
      linkedspec.load_corpus_fixtures(root)
    end, "case_count=2 does not match cases.len()=1", "manifest count")
  end)
end)

test("corpus manifest rejects missing and stale fixture directories", function()
  with_temp_directory(function(root)
    write_manifest(root, { "alpha", "beta" })
    write_fixture(root, "alpha")
    assert_error_contains(function()
      linkedspec.load_corpus_fixtures(root)
    end, "missing fixture dirs: [beta]", "missing fixture")
  end)
  with_temp_directory(function(root)
    write_manifest(root, { "alpha" })
    write_fixture(root, "alpha")
    write_fixture(root, "stale")
    assert_error_contains(function()
      linkedspec.load_corpus_fixtures(root)
    end, "extra fixture dirs: [stale]", "stale fixture")
  end)
end)

test("corpus fixture files require strict UTF-8 and valid expected JSON", function()
  with_temp_directory(function(root)
    write_manifest(root, { "alpha" })
    write_fixture(root, "alpha", { expected_source = false })
    assert_error_contains(function()
      linkedspec.load_corpus_fixtures(root)
    end, "expected.json file missing", "missing expected JSON")
  end)
  with_temp_directory(function(root)
    write_manifest(root, { "alpha" })
    write_fixture(root, "alpha", { expected_source = "{" })
    assert_error_contains(function()
      linkedspec.load_corpus_fixtures(root)
    end, "malformed expected.json for corpus case alpha", "malformed expected JSON")
  end)
  with_temp_directory(function(root)
    write_manifest(root, { "alpha" })
    write_fixture(root, "alpha", { input_text = string.char(0xFF) })
    assert_error_contains(function()
      linkedspec.load_corpus_fixtures(root)
    end, "input.txt is not valid UTF-8 at byte 1", "invalid fixture UTF-8")
  end)
end)

io.stdout:write("1..", total, "\n")
if failed > 0 then
  os.exit(1)
end
