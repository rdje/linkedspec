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
local ast = linkedspec.spec_ast

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

test("source AST round-trips with neutral fields and provenance", function()
  local payload = json.harray({ kind = "action_block" })
  local job = ast.staged_parse_job({
    job_id = "parse_job:function_body:functions.0.body_source",
    parent_ast_path = { "functions", "0", "body_source" },
    node_kind = "function_definition",
    payload_kind = "action_block",
    text = "return(trim(value))",
    source_span = ast.staged_source_span({ start = 10, ["end"] = 28, line_start = 1, line_end = 1 }),
    parser_spec_id = "actionir-body.spec",
    top_rule = "action_block",
    result_policy = "replace_field",
    result_field = "body_ast",
    failure_policy = "diagnostic",
  })
  local function_definition = ast.function_definition({
    name = "normalize",
    params = { "value" },
    arity = 1,
    body_source = "return(trim(value))",
    body_payload = payload,
    body_parse_job = job,
    body_ast = json.harray({ kind = "code_block", statements = json.array() }),
    source = "fn normalize(value) { return(trim(value)) }",
    source_span = ast.source_span({ line_start = 1, line_end = 1 }),
    body_span = ast.source_span({ line_start = 1, line_end = 1 }),
  })
  local minimal_function = ast.function_definition({
    name = "noop",
    params = {},
    arity = 0,
    body_source = "return()",
    source = "fn noop() { return() }",
    source_span = ast.source_span({ line_start = 2, line_end = 2 }),
    body_span = ast.source_span({ line_start = 2, line_end = 2 }),
  })
  payload.kind = "mutated"
  local mode = ast.and_bounded_rule_mode({ min = 1, max = 2 })
  local spec = ast.spec_file({
    functions = { function_definition, minimal_function },
    rules = {
      ast.rule({
        header = ast.rule_header({
          label = "Top",
          is_top = true,
          mode = mode,
          rest = "/x/ -> Child[0] { return(normalize(retv)) }",
          line = 2,
        }),
        body = {
          ast.body_element({
            kind = ast.regex_body_kind({ pattern = "x" }),
            source = "/x/",
            line = 2,
          }),
          ast.body_element({
            kind = ast.action_edge_body_kind({
              targets = { ast.edge_target({ label = "Child" }) },
              code = "return(normalize(retv))",
              fluent_chain = { ast.fluent_call({ method = "push", args = "" }) },
            }),
            source = "-> Child[0] { return(normalize(retv)) }.push",
            line = 2,
          }),
          ast.body_element({
            kind = ast.code_block_body_kind({ lifecycle = "I", code = "set(count, 0)" }),
            source = "I { set(count, 0) }",
            line = 3,
          }),
        },
      }),
    },
  })

  local projected = ast.to_json(spec)
  local encoded = json.encode(projected)
  local decoded = ast.from_json("SpecFile", json.decode(encoded))
  assert_equal(ast.node_type(decoded), "SpecFile", "spec node type")
  assert_equal(decoded.functions[1].body_payload.kind, "action_block", "payload defensive copy")
  assert_equal(decoded.functions[1].body_parse_job.job_id, job.job_id, "parse-job provenance")
  assert_equal(decoded.functions[2].body_parse_job, nil, "optional parse job")
  assert_equal(decoded.functions[2].body_payload, nil, "optional body payload")
  assert_equal(ast.top_rule(decoded).header.label, "Top", "top rule")
  assert_equal(ast.find_rule(decoded, "Top").header.mode.name, "AndBounded", "find rule")
  assert_equal(ast.rule_mode_is_and(ast.top_rule(decoded).header.mode), true, "AND mode")
  assert_equal(ast.rule_mode_rep_min(ast.top_rule(decoded).header.mode), 1, "mode minimum")
  assert_equal(ast.rule_mode_rep_max(ast.top_rule(decoded).header.mode), 2, "mode maximum")
  assert_equal(ast.node_type(decoded.rules[1].body[3].kind), "CodeBlockBodyElementKind", "codeblock identity")
  assert_equal(json.encode(ast.to_json(decoded)), encoded, "lossless AST JSON")
end)

test("source AST covers every body element variant", function()
  local call = ast.fluent_call({ method = "push", args = "value" })
  local target = ast.edge_target({ label = "Child", index = 2 })
  local kinds = {
    ast.regex_body_kind({ pattern = "x" }),
    ast.action_edge_body_kind({ targets = { target }, fluent_chain = { call } }),
    ast.blind_edge_body_kind({ target = "Child", fluent_chain = { call } }),
    ast.code_block_body_kind({ lifecycle = "E", code = "return(retv)" }),
    ast.plain_block_body_kind({ code = "return(retv)" }),
    ast.split_marker_body_kind({ marker = "---" }),
    ast.lifecycle_marker_body_kind({ marker = "I" }),
    ast.fluent_chain_body_kind({ calls = { call } }),
    ast.conditional_body_kind({ word = "if" }),
    ast.raw_body_kind({ text = "legacy" }),
  }
  for index, kind in ipairs(kinds) do
    local element = ast.body_element({ kind = kind, source = "source", line = index })
    local decoded = ast.from_json("BodyElement", json.decode(json.encode(ast.to_json(element))))
    assert_equal(ast.node_type(decoded.kind), ast.node_type(kind), "body kind " .. index)
  end
end)

test("source AST rejects malformed types and unsupported variants", function()
  assert_error_contains(function()
    ast.rule_mode("Unknown")
  end, "unsupported rule mode Unknown", "unknown rule mode")
  assert_error_contains(function()
    ast.from_json("BodyElementKind", json.harray({ kind = "unknown" }))
  end, "unsupported body element kind unknown", "unknown body kind")
  assert_error_contains(function()
    ast.spec_file({ rules = { "not a rule" } })
  end, "must contain only Rule nodes", "typed rule list")
  assert_error_contains(function()
    ast.spec_file({ rules = { [2] = "sparse" } })
  end, "contiguous one-based integer indexes", "dense rule list")
  assert_error_contains(function()
    ast.function_definition({
      name = "bad",
      params = {},
      arity = 0,
      body_source = "",
      body_payload = {},
      source = "fn bad() {}",
      source_span = ast.source_span({ line_start = 1, line_end = 1 }),
      body_span = ast.source_span({ line_start = 1, line_end = 1 }),
    })
  end, "must be a typed JSON value", "ambiguous payload")
end)

io.stdout:write("1..", total, "\n")
if failed > 0 then
  os.exit(1)
end
