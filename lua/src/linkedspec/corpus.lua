local json = require("linkedspec.json")

local M = {}

local function fail(message)
  error(message, 0)
end

local function join_path(root, child)
  if root:sub(-1) == "/" then
    return root .. child
  end
  return root .. "/" .. child
end

local function read_utf8_file(path, label)
  local handle = io.open(path, "rb")
  if not handle then
    fail("required " .. label .. " file missing: " .. path)
  end
  local bytes = handle:read("*a")
  handle:close()
  local valid, invalid_position = json.validate_utf8(bytes)
  if not valid then
    fail(label .. " is not valid UTF-8 at byte " .. invalid_position .. ": " .. path)
  end
  return bytes
end

local function shell_quote(value)
  if value:find("\0", 1, true) then
    fail("corpus path contains a NUL byte")
  end
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function directory_exists(path)
  local command = "if [ -d " .. shell_quote(path) .. " ]; then printf 'yes'; fi"
  local handle = io.popen(command, "r")
  if not handle then
    return false
  end
  local output = handle:read("*a")
  local closed = handle:close()
  return closed ~= nil and closed ~= false and output == "yes"
end

local function directory_names(root)
  local command = "find " .. shell_quote(root) .. " -mindepth 1 -maxdepth 1 -type d -print0"
  local handle = io.popen(command, "r")
  if not handle then
    fail("unable to inspect corpus fixture directories: " .. root)
  end
  local output = handle:read("*a")
  local closed = handle:close()
  if closed == nil or closed == false then
    fail("unable to inspect corpus fixture directories: " .. root)
  end

  local names = {}
  local start = 1
  while start <= #output do
    local ending = output:find("\0", start, true)
    if not ending then
      fail("fixture directory inventory was not NUL-delimited")
    end
    local path = output:sub(start, ending - 1)
    local name = path:match("([^/]+)$")
    if not name then
      fail("invalid fixture directory path: " .. path)
    end
    names[#names + 1] = name
    start = ending + 1
  end
  table.sort(names)
  return names
end

local function required_integer(object, key, manifest_path)
  local value = object[key]
  if type(value) ~= "number" or value % 1 ~= 0 then
    fail("malformed corpus manifest " .. manifest_path .. ": field " .. key .. " must be an integer")
  end
  return value
end

local function required_string_array(object, key, manifest_path)
  local value = object[key]
  if json.kind(value) ~= "array" then
    fail("malformed corpus manifest " .. manifest_path .. ": field " .. key .. " must be an array")
  end
  for _, item in ipairs(value) do
    if type(item) ~= "string" then
      fail("malformed corpus manifest " .. manifest_path .. ": field " .. key .. " must contain only strings")
    end
  end
  return value
end

local function load_manifest(root)
  local manifest_path = join_path(root, "manifest.json")
  local source = read_utf8_file(manifest_path, "corpus manifest")
  local ok, decoded = pcall(json.decode, source)
  if not ok then
    fail("malformed corpus manifest " .. manifest_path .. ": " .. tostring(decoded))
  end
  if json.kind(decoded) ~= "harray" then
    fail("malformed corpus manifest " .. manifest_path .. ": top-level value must be an object")
  end

  local format = required_integer(decoded, "format", manifest_path)
  if format ~= 1 then
    fail("unsupported corpus manifest format " .. format .. " in " .. manifest_path)
  end
  local case_count = required_integer(decoded, "case_count", manifest_path)
  local cases = required_string_array(decoded, "cases", manifest_path)
  if case_count ~= #cases then
    fail("corpus manifest case_count=" .. case_count .. " does not match cases.len()=" .. #cases)
  end
  if case_count <= 0 then
    fail("corpus manifest must name at least one fixture")
  end

  local seen = {}
  for _, name in ipairs(cases) do
    if not name:match("^[A-Za-z0-9][A-Za-z0-9_.-]*$") then
      fail("invalid corpus manifest case name: " .. name)
    end
    if seen[name] then
      fail("corpus manifest contains duplicate case names")
    end
    seen[name] = true
  end

  return {
    format = format,
    case_count = case_count,
    cases = cases,
  }
end

local function assert_manifest_matches_directories(root, manifest)
  local actual_names = directory_names(root)
  local expected = {}
  local actual = {}
  for _, name in ipairs(manifest.cases) do
    expected[name] = true
  end
  for _, name in ipairs(actual_names) do
    actual[name] = true
  end

  local missing = {}
  local extra = {}
  for _, name in ipairs(manifest.cases) do
    if not actual[name] then
      missing[#missing + 1] = name
    end
  end
  for _, name in ipairs(actual_names) do
    if not expected[name] then
      extra[#extra + 1] = name
    end
  end
  if #missing > 0 or #extra > 0 then
    fail(
      "oracle corpus manifest drift\n" ..
      "missing fixture dirs: [" .. table.concat(missing, ", ") .. "]\n" ..
      "extra fixture dirs: [" .. table.concat(extra, ", ") .. "]\n" ..
      "regenerate with `perl tools/gen_oracle_corpus.pl` and stage the manifest plus fixture dirs"
    )
  end
end

local function load_fixture(root, case_name)
  local case_root = join_path(root, case_name)
  local spec_source = read_utf8_file(join_path(case_root, "input.spec"), "input.spec")
  local input_text = read_utf8_file(join_path(case_root, "input.txt"), "input.txt")
  local expected_source = read_utf8_file(join_path(case_root, "expected.json"), "expected.json")
  local ok, expected_json = pcall(json.decode, expected_source)
  if not ok then
    fail("malformed expected.json for corpus case " .. case_name .. ": " .. tostring(expected_json))
  end
  return {
    name = case_name,
    spec_source = spec_source,
    input_text = input_text,
    expected_json = expected_json,
  }
end

function M.load_corpus_fixtures(root)
  if type(root) ~= "string" or root == "" then
    fail("corpus path must be a non-empty string")
  end
  if not directory_exists(root) then
    fail("corpus directory missing: " .. root)
  end
  local manifest = load_manifest(root)
  assert_manifest_matches_directories(root, manifest)
  local fixtures = {}
  for index, case_name in ipairs(manifest.cases) do
    fixtures[index] = load_fixture(root, case_name)
  end
  return {
    root = root,
    manifest = manifest,
    fixtures = fixtures,
  }
end

return M
