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
local scalar_numeric = require("linkedspec.scalar_numeric")

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
  assert_equal(first.parity, "runtime-numeric-reducers", "status parity")
  assert_equal(first.runtime, linkedspec.runtime_implementation(), "status runtime")
  first.backend = "mutated"
  assert_equal(second.backend, "lua", "status copy isolation")
end)

test("parser CLI stays unavailable while native parser API is explicit", function()
  local result = linkedspec.cli_scaffold_result({ "--help" })
  assert_equal(result.exit_code, 2, "CLI scaffold status")
  assert_equal(
    result.stderr,
    "linkedspec-lua: backend scaffold; parser CLI is not implemented\n",
    "CLI scaffold error"
  )
  assert_equal(type(linkedspec.parse_spec), "function", "native parser API")
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

local function body_kind(rule, index)
  return rule.body[index].kind
end

local function starts_with_top_level_function(source)
  for line in (source .. "\n"):gmatch("(.-)\n") do
    local text = line:match("^%s*(.-)%s*$")
    if text ~= "" and text:sub(1, 1) ~= "#" then
      return text:match("^fn%s") ~= nil
    end
  end
  return false
end

local function nul_delimited_paths(command)
  local handle = assert(io.popen(command, "r"))
  local output = handle:read("*a")
  assert(handle:close())
  local paths = {}
  local start = 1
  while start <= #output do
    local ending = assert(output:find("\0", start, true))
    paths[#paths + 1] = output:sub(start, ending - 1)
    start = ending + 1
  end
  table.sort(paths)
  return paths
end

local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local value = handle:read("*a")
  assert(handle:close())
  return value
end

test("source parser handles headers inline bodies and modes", function()
  local modes = {
    { "R1:AND", "And" },
    { "R2:OR+", "OrPlus" },
    { "R3::*", "Star" },
    { "R4:?", "Optional" },
    { "R5:AND{2,4}", "AndBounded" },
    { "R6:OR{3}", "OrBounded" },
    { "R7:&", "Single" },
    { "R8:|", "Pipe" },
  }
  for _, item in ipairs(modes) do
    local parsed = linkedspec.parse_spec(item[1] .. "\n /x/")
    assert_equal(parsed.rules[1].header.mode.name, item[2], item[1])
    assert_equal(ast.node_type(body_kind(parsed.rules[1], 1)), "RegexBodyElementKind", item[1] .. " regex")
  end
  local inline = linkedspec.parse_spec('Top:: /x/ I { return(entry_text()) } E.return("done")')
  assert_equal(#inline.rules[1].body, 3, "inline element count")
  assert_equal(ast.node_type(body_kind(inline.rules[1], 1)), "RegexBodyElementKind", "inline regex")
  assert_equal(ast.node_type(body_kind(inline.rules[1], 2)), "CodeBlockBodyElementKind", "inline block")
  assert_equal(body_kind(inline.rules[1], 3).code, 'return("done")', "inline fluent lifecycle")
end)

test("source parser keeps header-line regex slots", function()
  local single = linkedspec.parse_spec("Top::\n -> semi\n\nsemi : /;/")
  assert_equal(body_kind(ast.find_rule(single, "semi"), 1).pattern, ";", "single header regex")
  local pair = linkedspec.parse_spec("Top::\n -> bracket\n\nbracket : /\\(/ /\\)/")
  assert_equal(body_kind(ast.find_rule(pair, "bracket"), 1).pattern, "\\(", "first header regex")
  assert_equal(body_kind(ast.find_rule(pair, "bracket"), 2).pattern, "\\)", "second header regex")
end)

test("source parser handles action blind grouped indexed and fluent edges", function()
  local parsed = linkedspec.parse_spec([[
Top::->Child.push
 -> Child[1] .return(array("?child:", copy(Child)))
 -> A | B { return(entry_text()) }
 =>Helper.trim()

Child: /x/ /y/
Helper: /h/
]])
  local top = ast.top_rule(parsed)
  assert_equal(#top.body, 4, "top edge count")
  assert_equal(body_kind(top, 1).targets[1].label, "Child", "compact target")
  assert_equal(body_kind(top, 1).fluent_chain[1].method, "push", "compact fluent")
  assert_equal(body_kind(top, 2).targets[1].index, 1, "indexed target")
  assert_equal(body_kind(top, 2).fluent_chain[1].args, 'array("?child:", copy(Child))', "nested args")
  assert_equal(body_kind(top, 3).targets[2].label, "B", "grouped target")
  assert_equal(body_kind(top, 3).code, "return(entry_text())", "grouped code")
  assert_equal(body_kind(top, 4).target, "Helper", "blind target")
  assert_equal(body_kind(top, 4).fluent_chain[1].method, "trim", "blind fluent")
end)

test("source parser attaches multiline action fluent continuations", function()
  local parsed = linkedspec.parse_spec([[
Top::
 -> item
  .if(on)
    .push(item, out)
  .else()
    .return_undef()
  .endif()

item: /x/
]])
  local calls = body_kind(ast.top_rule(parsed), 1).fluent_chain
  assert_equal(#calls, 5, "continuation count")
  assert_equal(calls[1].method, "if", "first continuation")
  assert_equal(calls[2].args, "item, out", "continuation args")
  assert_equal(calls[5].method, "endif", "last continuation")
end)

test("source parser normalizes attached when otherwise blocks", function()
  local parsed = linkedspec.parse_spec([[
Top::
 -> Done.when(false) {
    return("bad")
 }.otherwise {
    return("fallback")
 }
 I.when(false) { set(out, "bad") } otherwise { set(out, "fallback") }

Done:
 /x/
]])
  local top = ast.top_rule(parsed)
  assert_contains(body_kind(top, 1).code, "when(false)", "action when")
  assert_contains(body_kind(top, 1).code, 'return("fallback")', "action otherwise")
  assert_contains(body_kind(top, 2).code, "otherwise", "lifecycle otherwise")
  assert_contains(body_kind(top, 2).code, 'set(out, "fallback")', "lifecycle fallback")
end)

test("source parser uses semicolons only between compact same-line statements", function()
  local parsed = linkedspec.parse_spec([[
Top::
 I.set(out, undef).set(out, "ok").return(out)
 /a/ E {
   set(out, "a")
   set(other, 'b')
   return(out)
 }
 /b/ EX { set(out, "a"); set(other, 'b'); return(out) }
]])
  local top = ast.top_rule(parsed)
  assert_equal(body_kind(top, 1).code, 'set(out, undef); set(out, "ok"); return(out)', "compact separators")
  assert_equal(
    body_kind(top, 3).code,
    'set(out, "a")\nset(other, \'b\')\nreturn(out)',
    "physical newline separators"
  )
  assert_equal(
    body_kind(top, 5).code,
    'set(out, "a"); set(other, \'b\'); return(out)',
    "same-line separators without trailing semicolon"
  )
end)

test("source parser handles multiline fluent arguments and quoted braces", function()
  local parsed = linkedspec.parse_spec([[
Top::
 I.return({
  "type" => "function_definition_error",
  "source_text" => entry_text()
 })
 /a/ I { print("literal { brace"); print('literal } brace') }
 /b/ E { return("ok") }
]])
  local top = ast.top_rule(parsed)
  assert_contains(body_kind(top, 1).code, '"source_text" => entry_text()', "multiline fluent argument")
  assert_contains(body_kind(top, 3).code, 'print("literal { brace")', "double-quoted brace")
  assert_contains(body_kind(top, 3).code, "print('literal } brace')", "single-quoted brace")
  assert_equal(ast.node_type(body_kind(top, 4)), "RegexBodyElementKind", "post-brace regex")
end)

test("source parser preserves raw lines and returns typed parse errors", function()
  local raw = linkedspec.parse_spec("Top::\n raw compatibility line")
  assert_equal(ast.node_type(body_kind(ast.top_rule(raw), 1)), "RawBodyElementKind", "raw fallback")
  local ok, parse_error = pcall(
    linkedspec.parse_spec,
    "fn normalize(value) { return(trim(value)) }\n\nTop::\n /x/"
  )
  assert_equal(ok, false, "top-level function rejection")
  assert_equal(linkedspec.is_spec_parse_error(parse_error), true, "typed parse error")
  assert_equal(parse_error.line, 1, "parse error line")
  local utf8_ok, utf8_error = pcall(linkedspec.parse_spec, "Top::\n /" .. string.char(0xFF) .. "/")
  assert_equal(utf8_ok, false, "invalid UTF-8 source rejection")
  assert_equal(linkedspec.is_spec_parse_error(utf8_error), true, "invalid UTF-8 typed error")
  assert_contains(utf8_error.message, "not valid UTF-8 at byte", "invalid UTF-8 position")
end)

test("source parser accepts every shipped spec", function()
  local paths = nul_delimited_paths("find specs -maxdepth 1 -type f -name '*.spec' -print0")
  if #paths == 0 then
    fail("shipped spec inventory is empty")
  end
  for _, path in ipairs(paths) do
    local parsed = linkedspec.parse_spec(read_file(path))
    if #parsed.rules == 0 then
      fail("shipped spec parsed without rules: " .. path)
    end
  end
end)

test("source parser accepts every rule-only corpus spec", function()
  local validation = linkedspec.load_corpus_fixtures("rust/linkedspec-runtime/tests/corpus")
  local parsed_count = 0
  local skipped_function_shells = 0
  for _, fixture in ipairs(validation.fixtures) do
    if starts_with_top_level_function(fixture.spec_source) then
      skipped_function_shells = skipped_function_shells + 1
    else
      local parsed = linkedspec.parse_spec(fixture.spec_source)
      if #parsed.rules == 0 then
        fail("corpus spec parsed without rules: " .. fixture.name)
      end
      parsed_count = parsed_count + 1
    end
  end
  if parsed_count <= 80 then
    fail("too few rule-only corpus specs parsed: " .. parsed_count)
  end
  if skipped_function_shells == 0 then
    fail("expected at least one staged function-shell corpus spec")
  end
end)

local function assert_validation_error(operation, expected, label)
  local ok, validation_error = pcall(operation)
  if ok then
    fail((label or "validation") .. ": expected an error")
  end
  assert_equal(linkedspec.is_spec_validation_error(validation_error), true, (label or "validation") .. " type")
  assert_contains(validation_error.message, expected, label)
end

local function validation_function(name, params, arity)
  return ast.function_definition({
    name = name,
    params = params,
    arity = arity == nil and #params or arity,
    body_source = "return(value)",
    source = "fn " .. name .. "(" .. table.concat(params, ", ") .. ") { return(value) }",
    source_span = ast.source_span({ line_start = 1, line_end = 1 }),
    body_span = ast.source_span({ line_start = 1, line_end = 1 }),
  })
end

local function spec_with_functions(functions)
  return ast.spec_file({
    functions = functions,
    rules = {
      ast.rule({
        header = ast.rule_header({
          label = "Top",
          is_top = true,
          mode = ast.default_rule_mode(),
          rest = "",
          line = 1,
        }),
        body = {
          ast.body_element({
            kind = ast.regex_body_kind({ pattern = "x" }),
            source = "/x/",
            line = 2,
          }),
        },
      }),
    },
  })
end

test("source validator checks top and duplicate rule labels", function()
  assert_validation_error(function()
    linkedspec.validate_spec(linkedspec.parse_spec("Top:\n /a/"))
  end, "no top rule", "missing top")
  assert_validation_error(function()
    linkedspec.validate_spec(linkedspec.parse_spec("Top::\n /a/\n\nTop:\n /b/"))
  end, "duplicate rule label", "duplicate rule")
end)

test("source validator checks edge families targets and slots", function()
  assert_validation_error(function()
    linkedspec.validate_spec(linkedspec.parse_spec([[
Top::
 /a/ -> A
 /b/ => B
A: /a/
B: /b/
]]))
  end, "mixes action", "mixed edges")
  assert_validation_error(function()
    linkedspec.validate_spec(linkedspec.parse_spec("Top::\n /a/ -> Ghost"))
  end, "undefined rule", "missing target")
  assert_validation_error(function()
    linkedspec.validate_spec(linkedspec.parse_spec("Top::\n /a/ -> Child[1]\n\nChild:\n /b/"))
  end, "regex slot 1", "bad target slot")
  assert_validation_error(function()
    linkedspec.validate_spec(linkedspec.parse_spec("Top::\n -> A | B\n\nA: /a/\nB: /b/"))
  end, "grouped action-edge targets", "grouped target block")
end)

test("source validator checks raw syntax and regex structure", function()
  assert_validation_error(function()
    linkedspec.validate_spec(linkedspec.parse_spec("Top::\n unsupported helper line"))
  end, "unrecognized body syntax", "raw syntax")
  assert_validation_error(function()
    linkedspec.validate_spec(linkedspec.parse_spec("Top::\n /[invalid/"))
  end, "invalid regex pattern", "regex structure")
end)

test("source validator supports strict unused-rule behavior", function()
  local parsed = linkedspec.parse_spec("Top::\n /a/ -> Child\n\nChild:\n /b/")
  assert_equal(linkedspec.validate_spec(parsed), nil, "non-strict validation")
  assert_validation_error(function()
    linkedspec.validate_spec(parsed, { strict_syntax = true })
  end, "unused rule(s) in strict mode: Top", "strict unused top")
  assert_equal(
    linkedspec.validate_spec(linkedspec.parse_spec("Top::\n /a/ -> Top"), { strict_syntax = true }),
    nil,
    "strict recursive top"
  )
end)

test("source validator locks all 239 helper and control names", function()
  local action_names = require("linkedspec.action_call_names")
  assert_equal(action_names.count(), 239, "current call-name count")
  assert_equal(action_names.is_known("trim"), true, "trim reservation")
  assert_equal(action_names.is_known("with"), true, "with reservation")
  assert_equal(action_names.is_known("otherwise"), true, "alias reservation")
  assert_equal(action_names.is_known("not_a_helper"), false, "unknown name")
end)

test("source validator checks function registry records", function()
  assert_equal(linkedspec.validate_spec(spec_with_functions({ validation_function("normalize", { "value" }) })), nil)
  assert_validation_error(function()
    linkedspec.validate_spec(spec_with_functions({
      validation_function("normalize", { "value" }),
      validation_function("normalize", { "other" }),
    }))
  end, "duplicate user function", "duplicate function")
  assert_validation_error(function()
    linkedspec.validate_spec(spec_with_functions({ validation_function("Top", { "value" }) }))
  end, "collides with rule label", "function rule collision")
  assert_validation_error(function()
    linkedspec.validate_spec(spec_with_functions({ validation_function("trim", { "value" }) }))
  end, "built-in helper", "function helper collision")
  assert_validation_error(function()
    linkedspec.validate_spec(spec_with_functions({ validation_function("normalize", { "value", "value" }) }))
  end, "duplicate parameter", "duplicate function param")
  assert_validation_error(function()
    linkedspec.validate_spec(spec_with_functions({ validation_function("normalize", { "ctx" }) }))
  end, "parameter 'ctx' is reserved", "reserved function param")
  assert_validation_error(function()
    linkedspec.validate_spec(spec_with_functions({ validation_function("normalize", { "value" }, 2) }))
  end, "does not match parameter count", "function arity")
end)

test("source validator accepts every shipped spec", function()
  local paths = nul_delimited_paths("find specs -maxdepth 1 -type f -name '*.spec' -print0")
  for _, path in ipairs(paths) do
    linkedspec.validate_spec(linkedspec.parse_spec(read_file(path)))
  end
end)

test("source validator accepts every rule-only corpus spec", function()
  local validation = linkedspec.load_corpus_fixtures("rust/linkedspec-runtime/tests/corpus")
  local validated_count = 0
  for _, fixture in ipairs(validation.fixtures) do
    if not starts_with_top_level_function(fixture.spec_source) then
      linkedspec.validate_spec(linkedspec.parse_spec(fixture.spec_source))
      validated_count = validated_count + 1
    end
  end
  assert_equal(validated_count, 102, "validated rule-only corpus count")
end)

local function utf8_character_count(value)
  local count = 0
  local position = 1
  while position <= #value do
    local first = value:byte(position)
    if first <= 0x7F then
      position = position + 1
    elseif first <= 0xDF then
      position = position + 2
    elseif first <= 0xEF then
      position = position + 3
    else
      position = position + 4
    end
    count = count + 1
  end
  return count
end

local function line_at_character_offset(source, offset)
  local line = 1
  local character_index = 0
  local position = 1
  while position <= #source and character_index < offset do
    local first = source:byte(position)
    local width = first <= 0x7F and 1 or (first <= 0xDF and 2 or (first <= 0xEF and 3 or 4))
    if source:sub(position, position + width - 1) == "\n" then
      line = line + 1
    end
    position = position + width
    character_index = character_index + 1
  end
  return line
end

local function definition_span(source, start_offset, end_offset)
  return json.harray({
    start = start_offset,
    ["end"] = end_offset,
    line_start = line_at_character_offset(source, start_offset),
    line_end = line_at_character_offset(source, end_offset),
  })
end

local function definition_node(source, name, params, body_source)
  local source_byte_start = assert(source:find("fn " .. name, 1, true))
  local body_byte_start = assert(source:find(body_source, source_byte_start, true))
  local body_byte_end = body_byte_start + #body_source
  local source_byte_end = assert(source:find("}", body_byte_end, true)) + 1
  local source_start = utf8_character_count(source:sub(1, source_byte_start - 1))
  local source_end = utf8_character_count(source:sub(1, source_byte_end - 1))
  local body_start = utf8_character_count(source:sub(1, body_byte_start - 1))
  local body_end = utf8_character_count(source:sub(1, body_byte_end - 1))
  local source_text = source:sub(source_byte_start, source_byte_end - 1)
  local source_span = definition_span(source, source_start, source_end)
  local body_span = definition_span(source, body_start, body_end)
  local typed_params = json.array(params)
  local pending_path = json.array({ "functions", "__pending_source_order__", "body_source" })
  return json.harray({
    type = "function_definition",
    kind = "user_function_definition",
    version = 1,
    name = name,
    params = typed_params,
    arity = #params,
    source_text = source_text,
    source_span = source_span,
    body_source = body_source,
    body_span = body_span,
    body_payload = json.harray({
      kind = "staged_payload",
      version = 1,
      node_kind = "function_definition",
      payload_kind = "function_body",
      parent_ast_path = pending_path,
      function_name = name,
      params = typed_params,
      arity = #params,
      text = body_source,
      source_span = body_span,
      provenance = json.array({ json.harray({ kind = "source_slice", source_span = body_span }) }),
    }),
    body_parse_job = json.harray({
      kind = "parse_job",
      version = 1,
      job_id = "parse_job:function_body:" .. name .. ":actionir-body.spec:action_block",
      parent_ast_path = pending_path,
      node_kind = "function_definition",
      payload_kind = "function_body",
      function_name = name,
      params = typed_params,
      arity = #params,
      text = body_source,
      source_span = body_span,
      parser_spec_id = "actionir-body.spec",
      top_rule = "action_block",
      result_policy = "replace_field",
      result_field = "body_ast",
      failure_policy = "fail",
      diagnostic_owner = "function_body",
    }),
  })
end

test("function shell projects spec-owned nodes with Unicode character spans", function()
  local source = table.concat({
    "# préface",
    'fn zero() {return("zero")}',
    "Top::",
    " /x/ -> Done { return(zero()) }",
    "",
    "Done:",
    " /[a-z]+/",
    "",
    "fn after(value) { return(value) }",
    "",
  }, "\n")
  local nodes = json.array({
    definition_node(source, "zero", {}, 'return("zero")'),
    definition_node(source, "after", { "value" }, " return(value) "),
  })

  local no_scan_ok, no_scan_error = pcall(
    linkedspec.parse_spec_with_user_function_definition_asts,
    source,
    json.array()
  )
  assert_equal(no_scan_ok, false, "no raw function scanner")
  assert_equal(linkedspec.is_spec_parse_error(no_scan_error), true, "no-scan parse error")

  local projection = linkedspec.project_user_function_definition_asts(source, nodes)
  assert_equal(#projection.functions, 2, "projected function count")
  assert_equal(projection.functions[1].name, "zero", "first function")
  assert_equal(projection.functions[2].name, "after", "second function")
  assert_contains(projection.stripped_source, "# préface", "Unicode source preservation")
  assert_contains(projection.stripped_source, "Top::", "rule source preservation")
  assert_equal(projection.stripped_source:find("fn zero", 1, true), nil, "function source stripped")
  local zero = projection.functions[1]
  assert_equal(zero.body_parse_job.parent_ast_path[2], "0", "normalized job path")
  assert_equal(zero.body_payload.parent_ast_path[2], "0", "normalized payload path")
  assert_contains(zero.body_parse_job.job_id, "functions.0.body_source", "normalized job id")
  assert_equal(zero.body_parse_job.version, 1, "job version")
  assert_equal(zero.body_ast, nil, "body AST stays undispatched")

  local parsed = linkedspec.parse_spec_with_user_function_definition_asts(source, nodes)
  assert_equal(#parsed.functions, 2, "composed functions")
  assert_equal(#parsed.rules, 2, "composed rules")
  assert_equal(linkedspec.validate_spec(parsed), nil, "composed validation")
end)

test("function shell rejects spec-produced error and drifting sidecars", function()
  local bad_source = "fn bad(value\nTop::\n /x/\n"
  local error_node = json.harray({
    type = "function_definition_error",
    kind = "user_function_definition_error",
    message = "invalid user function definition",
    source_text = "fn bad(value",
    source_span = definition_span(bad_source, 0, 12),
  })
  local error_ok, parse_error = pcall(
    linkedspec.project_user_function_definition_asts,
    bad_source,
    json.array({ error_node })
  )
  assert_equal(error_ok, false, "function error node rejection")
  assert_equal(linkedspec.is_spec_parse_error(parse_error), true, "function error parse type")
  assert_contains(parse_error.message, "parse error at line 1", "function error message")

  local source = 'fn zero() {return("zero")}\nTop::\n /x/\n'
  local node = definition_node(source, "zero", {}, 'return("zero")')
  node.body_parse_job.text = 'return("drift")'
  assert_error_contains(function()
    linkedspec.project_user_function_definition_asts(source, json.array({ node }))
  end, "body_parse_job text does not match body_source", "sidecar drift")
end)

test("function shell normalizes nested spec output shapes", function()
  local source = 'fn zero() {return("zero")}\nTop::\n /x/\n'
  local node = definition_node(source, "zero", {}, 'return("zero")')
  local direct = linkedspec.definition_nodes_from_user_function_definition_output(node)
  assert_equal(#direct, 1, "direct output shape")
  local wrapped = linkedspec.definition_nodes_from_user_function_definition_output(
    json.array({ json.array({ node }) })
  )
  assert_equal(#wrapped, 1, "nested output shape")
  assert_equal(wrapped[1].name, "zero", "nested output node")
  assert_error_contains(function()
    linkedspec.definition_nodes_from_user_function_definition_output("invalid")
  end, "unsupported output shape", "unsupported output")
end)

test("function shell rejects overlapping source spans", function()
  local source = 'fn zero() {return("zero")}\nTop::\n /x/\n'
  local node = definition_node(source, "zero", {}, 'return("zero")')
  assert_error_contains(function()
    linkedspec.project_user_function_definition_asts(source, json.array({ node, node }))
  end, "function definition spans overlap", "overlapping functions")
end)

test("ActionIR blocks use newline and same-line semicolon separators", function()
  local block = linkedspec.parse_action_block(
    'set(results, []); push(results, retv)\nreturn(copy(results))'
  )
  assert_equal(linkedspec.action_ast.node_type(block), "ActionBlock", "block type")
  assert_equal(#block.statements, 3, "statement count")
  assert_equal(block.statements[1].expr.name, "set", "first helper")
  assert_equal(block.statements[2].expr.name, "push", "same-line second helper")
  assert_equal(block.statements[3].expr.name, "return", "newline helper")
  for _, statement in ipairs(block.statements) do
    assert_equal(statement.drops_value, true, "statement value drop")
  end

  local newline_only = linkedspec.parse_action_block("first()\nsecond()\nthird()")
  assert_equal(#newline_only.statements, 3, "newline-only statements")
  assert_equal(newline_only.statements[3].source, "third()", "no trailing separator")

  local portable_newlines = linkedspec.parse_action_block("first()\r\nsecond()\rthird()")
  assert_equal(#portable_newlines.statements, 3, "CRLF and CR statements")
  assert_equal(portable_newlines.statements[2].source, "second()", "CR-delimited statement")
end)

test("ActionIR parses literals and all four LinkedSpec value kinds", function()
  local scalar = linkedspec.parse_action_expression("42.5")
  assert_equal(scalar.kind, "number", "scalar kind")
  assert_equal(scalar.value, 42.5, "decimal value")
  assert_equal(linkedspec.parse_action_expression("true").kind, "boolean", "boolean kind")
  assert_equal(linkedspec.parse_action_expression("undef").kind, "undef", "undef kind")

  local regex = linkedspec.parse_action_expression("/a\\\\sb/i")
  assert_equal(regex.kind, "regex", "regex kind")
  assert_equal(regex.pattern, "a\\\\sb", "regex payload")
  assert_equal(regex.flags, "i", "regex flags")

  local single_quoted = linkedspec.parse_action_expression([['"|\s']])
  assert_equal(single_quoted.kind, "string", "single-quoted kind")
  assert_equal(single_quoted.value, '"|\\s', "single-quoted value")
  assert_equal(single_quoted.quote, "'", "single-quote provenance")
  local substr_call = linkedspec.parse_action_expression([[substr(value, '"|\s', "", go)]])
  assert_equal(substr_call.kind, "call", "single-quoted helper call")
  assert_equal(substr_call.args[2].value.value, '"|\\s', "single-quoted helper argument")

  local array = linkedspec.parse_action_expression("[value, true, []]")
  assert_equal(array.kind, "array_literal", "array kind")
  assert_equal(#array.items, 3, "array item count")
  local harray = linkedspec.parse_action_expression('{ key : value, "fixed" : [value] }')
  assert_equal(harray.kind, "hash_literal", "harray kind")
  assert_equal(#harray.entries, 2, "harray entry count")
  local codeblock = linkedspec.parse_action_expression('{ set(x, "a"); x }')
  assert_equal(codeblock.kind, "block_value", "codeblock kind")
  assert_equal(#codeblock.block.statements, 2, "codeblock statement count")
end)

test("ActionIR parses access assignments nested calls and keyword arguments", function()
  local access = linkedspec.parse_action_expression('foo["a"][i][0]')
  assert_equal(access.kind, "nested_access", "nested access kind")
  assert_equal(access.base, "foo", "nested access base")
  assert_equal(#access.segments, 3, "nested access depth")
  assert_equal(access.segments[1].kind, "key", "key segment")
  assert_equal(access.segments[2].kind, "index", "index segment")

  assert_equal(linkedspec.parse_action_expression("items = [value]").kind, "assign_scalar", "scalar assignment")
  assert_equal(linkedspec.parse_action_expression("items += value").kind, "assign_array_append", "append assignment")
  assert_equal(
    linkedspec.parse_action_expression("meta[key] = { stage : value }").kind,
    "assign_hash_index",
    "hash assignment"
  )
  assert_equal(
    linkedspec.parse_action_expression('payload["children"][0]["name"] = value').kind,
    "assign_nested_access",
    "nested assignment"
  )

  local nested_call = linkedspec.parse_action_expression("array(items = [value], copy(items))")
  assert_equal(nested_call.kind, "call", "nested call kind")
  assert_equal(nested_call.args[1].value.kind, "assign_scalar", "assignment argument")
  assert_equal(nested_call.args[2].value.kind, "call", "nested call argument")
  local assignment_arg = linkedspec.parse_action_expression("helper(value, option=true)")
  assert_equal(assignment_arg.args[2].argument_kind, "positional", "assignment argument role")
  assert_equal(assignment_arg.args[2].value.kind, "assign_scalar", "assignment argument value")
  local keyword = linkedspec.action_ast.keyword_argument("option", assignment_arg.args[1].value)
  assert_equal(linkedspec.action_ast.node_type(keyword), "ActionArgument", "typed keyword argument")
  assert_equal(keyword.argument_kind, "keyword", "keyword constructor role")
  assert_equal(keyword.name, "option", "keyword constructor name")
end)

test("ActionIR final codeblock syntax is generic and structurally equivalent", function()
  local trailing = linkedspec.parse_action_expression("func_helper_method(value) { return(value) }")
  local explicit = linkedspec.parse_action_expression("func_helper_method(value, { return(value) })")
  assert_equal(trailing.kind, "call", "trailing helper kind")
  assert_equal(trailing.trailing_block_arg, true, "trailing helper marker")
  assert_equal(#trailing.args, #explicit.args, "equivalent argument count")
  assert_equal(trailing.args[#trailing.args].value.kind, "block_value", "trailing final argument")
  assert_equal(explicit.args[#explicit.args].value.kind, "block_value", "explicit final argument")
  assert_equal(
    trailing.args[#trailing.args].value.block.statements[1].expr.name,
    explicit.args[#explicit.args].value.block.statements[1].expr.name,
    "equivalent codeblock body"
  )

  local receiver = linkedspec.parse_action_expression('"x".func_helper_method() { return(value) }')
  local explicit_receiver = linkedspec.parse_action_expression('"x".func_helper_method({ return(value) })')
  assert_equal(receiver.kind, "fluent_chain", "receiver chain kind")
  assert_equal(receiver.calls[1].method, "func_helper_method", "generic receiver method")
  assert_equal(receiver.calls[1].receiver_trailing_block_arg, true, "receiver trailing marker")
  assert_equal(receiver.calls[1].args[1].value.kind, "block_value", "receiver final argument")
  assert_equal(#receiver.calls[1].args, #explicit_receiver.calls[1].args, "receiver equivalent argument count")
  assert_equal(explicit_receiver.calls[1].args[1].value.kind, "block_value", "explicit receiver final argument")

  local chain = linkedspec.parse_action_expression('(items += value).count()')
  assert_equal(chain.receiver.kind, "assign_array_append", "assignment receiver")
  assert_equal(chain.calls[1].method, "count", "receiver method")
end)

test("ActionIR parses attached controls and preserves unsupported structure", function()
  local branches = linkedspec.parse_action_block(
    'if(false) { set(out, "bad") } elseif(true) { set(out, "yes") } else { set(out, "no") }'
  )
  assert_equal(#branches.statements, 3, "branch count")
  assert_equal(branches.statements[1].expr.kind, "control_if", "if kind")
  assert_equal(branches.statements[2].expr.branch_role, "elseif", "elseif role")
  assert_equal(branches.statements[3].expr.kind, "control_else", "else kind")

  local while_node = linkedspec.parse_action_expression("while(flag) { next() }")
  assert_equal(while_node.kind, "control_while", "while kind")
  local switch_node = linkedspec.parse_action_expression(
    'switch(kind) { case("a") { return("hit") } default { return("miss") } }'
  )
  assert_equal(switch_node.kind, "control_switch", "switch kind")
  assert_equal(#switch_node.cases, 1, "case count")
  assert_equal(switch_node.default.kind, "control_default", "default kind")

  local raw = linkedspec.parse_action_expression("@invalid")
  assert_equal(raw.kind, "raw_perl", "raw structural kind")
  assert_equal(raw.reason, "unsupported_expression", "raw reason")
end)

test("ActionIR uses Unicode character spans and typed JSON projection", function()
  local chain = linkedspec.parse_action_expression('"é".trim()')
  assert_equal(chain.source_span.start, 0, "Unicode chain start")
  assert_equal(chain.source_span["end"], 10, "Unicode chain end")
  assert_equal(chain.receiver.source_span["end"], 3, "Unicode receiver end")
  local projected = linkedspec.action_ast.to_json(chain)
  assert_equal(json.kind(projected), "harray", "projected node kind")
  assert_equal(json.kind(projected.calls), "array", "projected list kind")
  assert_equal(json.decode(json.encode(projected)).kind, "fluent_chain", "projected JSON round-trip")

  assert_error_contains(function()
    linkedspec.parse_action_expression(string.char(0xC3))
  end, "not valid UTF-8", "invalid ActionIR UTF-8")
end)

test("ActionIR contracts resolve canonical helpers through nested nodes", function()
  local block = linkedspec.parse_action_block(table.concat({
    "set(out, +(1, 2))",
    'if(gt(out, 0)) { return(cat("ok", out)) }',
    '" x ".trim().with() { return(value) }',
  }, "\n"))
  local resolution = linkedspec.resolve_action_block_contracts(block)
  assert_equal(resolution.ok, true, "nested contract result")

  local by_source = {}
  for _, contract in ipairs(resolution.contracts) do
    by_source[contract.source_name] = contract
  end
  assert_equal(by_source.set.canonical_name, "set", "set contract")
  assert_equal(by_source["+"].canonical_name, "num_add", "numeric symbol canonicalization")
  assert_equal(by_source["+"].family, "numeric", "numeric family")
  assert_equal(linkedspec.action_contracts.canonicalized(by_source["+"]), true, "numeric canonicalized")
  assert_equal(by_source.gt.canonical_name, "num_gt", "numeric word canonicalization")
  assert_equal(by_source.gt.positional_arg_count, 2, "numeric argument count")
  assert_equal(by_source["if"].surface, "control", "control surface")
  assert_equal(by_source.trim.surface, "receiver_method", "receiver surface")
  assert_equal(by_source.with.family, "control", "trailing block family")
  assert_equal(#resolution.diagnostics, 0, "nested diagnostics")
end)

test("ActionIR contracts map structural assignments and current equals alias", function()
  local block = linkedspec.parse_action_block(
    'name = "ok"; items += name; meta[name] = [name]; ' ..
    'payload["children"][0]["name"] = name; =(other, "value")'
  )
  local resolution = linkedspec.resolve_action_block_contracts(block)
  assert_equal(resolution.ok, true, "assignment contract result")

  local canonical = {}
  for _, contract in ipairs(resolution.contracts) do
    canonical[contract.source_name] = contract.canonical_name
  end
  assert_equal(canonical["="], "set", "scalar assignment contract")
  assert_equal(canonical["+="], "push", "append assignment contract")
  assert_equal(canonical["[]="], "set_key", "hash assignment contract")
  assert_equal(canonical["nested_access="], "nested_access_assignment", "nested assignment contract")

  local equals_call
  for _, contract in ipairs(resolution.contracts) do
    if contract.source_name == "=" and contract.surface == "function" then
      equals_call = contract
    end
  end
  assert_equal(equals_call.canonical_name, "set", "equals helper alias")
  assert_equal(equals_call.positional_arg_count, 2, "equals helper arity")
end)

test("ActionIR contracts diagnose unknown helpers and raw fallback", function()
  local block = linkedspec.parse_action_block("mystery_helper(value); @invalid")
  local resolution = linkedspec.resolve_action_block_contracts(block)
  assert_equal(resolution.ok, false, "diagnostic result")
  assert_equal(#resolution.contracts, 0, "diagnostic contract count")
  assert_equal(#resolution.diagnostics, 2, "diagnostic count")
  assert_equal(resolution.diagnostics[1].code, "unknown_helper", "unknown diagnostic")
  assert_equal(resolution.diagnostics[1].helper_name, "mystery_helper", "unknown helper name")
  assert_equal(resolution.diagnostics[2].code, "raw_perl", "raw diagnostic")
  assert_contains(resolution.diagnostics[1].message, "canonical ActionIR helper contract", "generic diagnostic")
end)

test("ActionIR contracts share the exact current names and typed JSON", function()
  assert_equal(linkedspec.is_known_action_ir_call_name("cat"), true, "known string helper")
  assert_equal(linkedspec.is_known_action_ir_call_name("push_back"), true, "known array helper")
  assert_equal(linkedspec.is_known_action_ir_call_name("sorted_keys"), true, "known hash helper")
  assert_equal(linkedspec.is_known_action_ir_call_name("capture_until_boundary"), true, "known capture helper")
  assert_equal(linkedspec.is_known_action_ir_call_name("save_cursor"), true, "known runtime helper")
  assert_equal(linkedspec.is_known_action_ir_call_name("BACKTRACK"), false, "retired control")
  assert_equal(linkedspec.is_known_action_ir_call_name("mystery_helper"), false, "unknown name")
  assert_equal(linkedspec.canonical_action_helper_name(">="), "num_ge", "comparison alias")

  local resolution = linkedspec.resolve_action_expression_contracts(
    linkedspec.parse_action_expression("gt(value, 0)")
  )
  local projected = linkedspec.action_contracts.to_json(resolution)
  assert_equal(json.kind(projected), "harray", "contract JSON object")
  assert_equal(json.kind(projected.contracts), "array", "contract JSON list")
  assert_equal(projected.contracts[1].canonical_name, "num_gt", "contract JSON canonical name")
  assert_equal(projected.contracts[1].canonicalized, true, "contract JSON canonicalized")
  assert_equal(json.decode(json.encode(projected)).ok, true, "contract JSON round-trip")
end)

test("ActionIR contracts resolve registered functions before helper fallback", function()
  local registry = {
    resolve_call = function(_, name, arity)
      if name ~= "normalize" then
        return nil
      elseif arity == 2 then
        return { matched = true, arity_mismatch = false, expected_arities = { 2 } }
      end
      return { matched = false, arity_mismatch = true, expected_arities = { 2 } }
    end,
  }
  local block = linkedspec.parse_action_block(table.concat({
    'normalize("x") { return(value) }',
    'normalize("x")',
    'mystery("z")',
  }, "\n"))
  local resolution = linkedspec.resolve_action_block_contracts(block, { function_registry = registry })

  local normalize_contracts = {}
  for _, contract in ipairs(resolution.contracts) do
    if contract.source_name == "normalize" then
      normalize_contracts[#normalize_contracts + 1] = contract
    end
  end
  assert_equal(#normalize_contracts, 1, "matched user contract count")
  assert_equal(normalize_contracts[1].family, "user_function", "user function family")
  assert_equal(normalize_contracts[1].positional_arg_count, 2, "final codeblock counts as argument")
  assert_equal(resolution.diagnostics[1].code, "user_function_arity_mismatch", "user arity diagnostic")
  assert_contains(resolution.diagnostics[1].message, "expects arity 2, got 1", "user arity message")
  assert_equal(resolution.diagnostics[2].code, "unknown_helper", "post-registry unknown helper")

  assert_error_contains(function()
    linkedspec.resolve_action_expression_contracts(
      linkedspec.parse_action_expression("normalize(value)"),
      { function_registry = {} }
    )
  end, "must expose resolve_call", "registry interface")
end)

local function registry_function(name, params, index, body_ast, body_source_override)
  local body_source = body_source_override or "return(value)"
  local path = { "functions", tostring(index), "body_source" }
  return ast.function_definition({
    name = name,
    params = params,
    arity = #params,
    body_source = body_source,
    body_payload = json.harray({
      kind = "staged_payload",
      node_kind = "function_definition",
      payload_kind = "function_body",
      parent_ast_path = json.array(path),
      function_name = name,
      params = json.array(params),
      arity = #params,
      text = body_source,
    }),
    body_parse_job = ast.staged_parse_job({
      version = 1,
      job_id = "parse_job:function_body:functions." .. index .. ".body_source",
      parent_ast_path = path,
      node_kind = "function_definition",
      payload_kind = "function_body",
      function_name = name,
      params = params,
      arity = #params,
      text = body_source,
      source_span = ast.staged_source_span({ start = 0, ["end"] = #body_source, line_start = 1, line_end = 1 }),
      parser_spec_id = "actionir-body.spec",
      top_rule = "action_block",
      result_policy = "replace_field",
      result_field = "body_ast",
      failure_policy = "fail",
      diagnostic_owner = "function_body",
    }),
    body_ast = body_ast,
    source = "fn " .. name .. "(" .. table.concat(params, ", ") .. ") { " .. body_source .. " }",
    source_span = ast.source_span({ line_start = 1, line_end = 1 }),
    body_span = ast.source_span({ line_start = 1, line_end = 1 }),
  })
end

local function assert_registry_error(operation, expected, code, label)
  local ok, registry_error = pcall(operation)
  if ok then fail((label or "registry") .. ": expected an error") end
  assert_equal(
    linkedspec.user_function_registry.is_registry_error(registry_error),
    true,
    (label or "registry") .. " type"
  )
  assert_contains(registry_error.message, expected, label)
  if code then assert_equal(registry_error.code, code, (label or "registry") .. " code") end
  return registry_error
end

test("user function registry preserves order jobs definitions and exact arity", function()
  local body_ast = json.harray({ kind = "action_block", statements = json.array() })
  local zero = registry_function("zero", {}, 0, body_ast)
  local normalize = registry_function("normalize", { "value" }, 1)
  local registry = linkedspec.user_function_registry_from_functions({ zero, normalize })
  zero.body_source = "mutated_after_registry"

  assert_equal(linkedspec.user_function_registry.node_type(registry), "UserFunctionRegistry", "registry type")
  assert_equal(table.concat(registry:names(), ","), "zero,normalize", "registry order")
  assert_equal(#registry:body_parse_jobs(), 2, "body job count")
  assert_equal(registry:body_parse_jobs()[2].function_name, "normalize", "body job order")
  assert_equal(registry:has_name("zero"), true, "known function")
  assert_equal(registry:has_name("missing"), false, "missing function")

  local exact = registry:resolve_call("zero", 0)
  assert_equal(exact.matched, true, "exact match")
  assert_equal(exact.entry.index, 0, "zero-based entry index")
  assert_equal(exact.entry.definition.body_ast.kind, "action_block", "body AST preservation")
  assert_equal(exact.entry.definition.body_source, "return(value)", "definition snapshot")
  local mismatch = registry:resolve_call("normalize", 2)
  assert_equal(mismatch.name_known, true, "known mismatch")
  assert_equal(mismatch.arity_mismatch, true, "arity mismatch")
  assert_equal(mismatch.expected_arities[1], 1, "expected arity")
  assert_equal(registry:resolve_call("missing", 0).name_known, false, "missing resolution")

  local projected = linkedspec.user_function_registry.to_json(registry)
  assert_equal(json.kind(projected.functions), "array", "registry JSON functions")
  assert_equal(projected.functions[1].index, 0, "registry JSON index")
  assert_equal(json.kind(projected.body_parse_jobs), "array", "registry JSON jobs")
  local descriptor = linkedspec.user_function_registry.to_descriptor_json(exact.entry)
  assert_equal(descriptor.kind, "user_function_definition", "descriptor kind")
  assert_equal(descriptor.source_text, zero.source, "descriptor source")

  assert_registry_error(function()
    linkedspec.user_function_registry_from_functions({ zero, zero })
  end, "duplicate user function 'zero'", nil, "duplicate registry")
end)

test("user function registry stitches body AST without mutating the source spec", function()
  local definition = registry_function("normalize", { "value" }, 0)
  local spec = spec_with_functions({ definition })
  local body_ast = json.harray({
    kind = "action_block",
    statements = json.array({ json.harray({ kind = "action_stmt" }) }),
  })
  local stitched = linkedspec.stitch_function_body_ast(
    spec,
    "parse_job:function_body:functions.0.body_source",
    body_ast
  )
  assert_equal(spec.functions[1].body_ast, nil, "source spec unchanged")
  assert_equal(stitched.functions[1].body_ast.kind, "action_block", "stitched body AST")
  body_ast.kind = "mutated"
  assert_equal(stitched.functions[1].body_ast.kind, "action_block", "stitched defensive copy")
  assert_equal(stitched.rules[1].header.label, "Top", "rules preserved")

  local registry = linkedspec.user_function_registry_from_spec(stitched)
  local resolution = linkedspec.resolve_action_expression_contracts(
    linkedspec.parse_action_expression("normalize(value)"),
    { function_registry = registry }
  )
  assert_equal(resolution.ok, true, "concrete registry contract result")
  assert_equal(resolution.contracts[1].family, "user_function", "concrete registry precedence")

  assert_registry_error(function()
    linkedspec.stitch_function_body_ast(spec, "missing-job", json.harray({ kind = "action_block" }))
  end, "not found", nil, "missing stitch job")
end)

test("user function invocation frames copy supplied four-kind values into fresh stores", function()
  local definition = registry_function("bind_all", { "scalar", "items", "meta", "callback" }, 0)
  local registry = linkedspec.user_function_registry_from_functions({ definition })
  local source_items = json.array({ "a", json.harray({ nested = true }) })
  local source_meta = json.harray({ key = json.array({ 1, 2 }) })
  local source_block = linkedspec.parse_action_expression("{ return(value) }")
  assert_equal(linkedspec.runtime_value_kind(source_block), "codeblock", "supplied structural codeblock kind")
  local frame = linkedspec.prepare_user_function_invocation(
    registry,
    "bind_all",
    { "ready", source_items, source_meta, source_block }
  )

  assert_equal(linkedspec.user_function_registry.node_type(frame), "UserFunctionInvocationFrame", "frame type")
  assert_equal(frame.variables.scalar, "ready", "scalar binding")
  assert_equal(json.kind(frame.variables.items), "array", "array scalar binding")
  assert_equal(json.kind(frame.arrays.items), "array", "typed array store")
  assert_equal(json.kind(frame.harrays.meta), "harray", "typed harray store")
  assert_equal(frame.variables.callback.kind, "block_value", "codeblock binding")
  assert_equal(frame.variables.outside, nil, "no caller capture")
  assert_equal(frame.active_path[1], "bind_all", "active path")

  frame.arrays.items[1] = "changed"
  frame.harrays.meta.key[1] = 99
  frame.variables.callback.kind = "mutated"
  assert_equal(source_items[1], "a", "caller array isolated")
  assert_equal(source_meta.key[1], 1, "caller harray isolated")
  assert_equal(source_block.kind, "block_value", "caller codeblock isolated")
  local second = linkedspec.prepare_user_function_invocation(
    registry,
    "bind_all",
    { "ready", source_items, source_meta, source_block }
  )
  assert_equal(second.arrays.items[1], "a", "fresh array store")
  assert_equal(second.harrays.meta.key[1], 1, "fresh harray store")
end)

test("user function invocation frames diagnose arity unknown calls and recursion", function()
  local first = registry_function("first", { "value" }, 0)
  local registry = linkedspec.user_function_registry_from_functions({ first })
  assert_registry_error(function()
    linkedspec.prepare_user_function_invocation(registry, "first", {})
  end, "expects arity 1, got 0", "user_function_arity_mismatch", "frame arity")
  assert_registry_error(function()
    linkedspec.prepare_user_function_invocation(registry, "missing", {})
  end, "unknown user function", "unknown_user_function", "frame unknown")
  local recursion = assert_registry_error(function()
    linkedspec.prepare_user_function_invocation(
      registry,
      "first",
      { "value" },
      { "first", "second" },
      { rule_label = "Top" }
    )
  end, "first -> second -> first in rule Top", "user_function_recursion", "frame recursion")
  assert_equal(recursion.stage, "user_function_call", "recursion stage")
  assert_equal(recursion.summary, "Lua user function recursion failed", "recursion summary")
  assert_equal(recursion.rule_label, "Top", "recursion rule")
  assert_equal(recursion.handler_source_label, "lua_runtime:function:first", "recursion handler source")
end)

local function compiled_test_rule(label, is_top, mode, body)
  return ast.rule({
    header = ast.rule_header({
      label = label,
      is_top = is_top,
      mode = mode or ast.default_rule_mode(),
      rest = "",
      line = 1,
    }),
    body = body,
  })
end

local function sorted_keys(value)
  local keys = {}
  for key in pairs(value) do keys[#keys + 1] = key end
  table.sort(keys)
  return keys
end

local function sorted_values(value)
  local values = {}
  for index, item in ipairs(value) do values[index] = item end
  table.sort(values)
  return values
end

local function assert_compiled_error(operation, expected, label)
  local ok, compiled_error = pcall(operation)
  if ok then fail((label or "compiled spec") .. ": expected an error") end
  assert_equal(linkedspec.is_compiled_spec_error(compiled_error), true, (label or "compiled spec") .. " type")
  assert_contains(compiled_error.message, expected, label)
  return compiled_error
end

test("compiled spec preserves ordered rules modes dependencies and ActionIR payloads", function()
  local normalize = registry_function(
    "normalize",
    { "value" },
    0,
    json.harray({ kind = "action_block", statements = json.array() })
  )
  local top = compiled_test_rule("Top", true, ast.and_bounded_rule_mode({ min = 1, max = 2 }), {
    ast.body_element({ kind = ast.regex_body_kind({ pattern = "a" }), source = "/a/", line = 1 }),
    ast.body_element({
      kind = ast.action_edge_body_kind({
        targets = { ast.edge_target({ label = "Child", index = 0 }) },
        code = 'return(normalize(" x "))',
      }),
      source = '/a/ -> Child { return(normalize(" x ")) }',
      line = 1,
    }),
    ast.body_element({
      kind = ast.code_block_body_kind({ lifecycle = "I", code = "set(meta, { ok : true })" }),
      source = "I { set(meta, { ok : true }) }",
      line = 2,
    }),
    ast.body_element({
      kind = ast.plain_block_body_kind({ code = 'return("plain")' }),
      source = '{ return("plain") }',
      line = 3,
    }),
  })
  local child = compiled_test_rule("Child", false, nil, {
    ast.body_element({ kind = ast.regex_body_kind({ pattern = "x" }), source = "/x/", line = 4 }),
  })
  local source = ast.spec_file({ functions = { normalize }, rules = { top, child } })
  local compiled = linkedspec.compile_spec(source)

  assert_equal(linkedspec.compiled_spec.node_type(compiled), "CompiledSpec", "compiled type")
  assert_equal(table.concat(compiled.definition_order, ","), "Top,Child", "definition order")
  assert_equal(table.concat(compiled.compiled_rule_order, ","), "Top,Child", "compiled order")
  assert_equal(compiled:rule("Top").mode_metadata.name, "AndBounded", "mode name")
  assert_equal(compiled:rule("Top").mode_metadata.is_and, true, "mode and")
  assert_equal(compiled:rule("Top").mode_metadata.rep_min, 1, "mode minimum")
  assert_equal(compiled:rule("Top").mode_metadata.rep_max, 2, "mode maximum")
  assert_equal(compiled:rule("Top").action_edges[1].regex_index, 0, "same-line parent regex")
  assert_equal(compiled.dependency_regex_state.dependency_regex_map.Top.patterns[1], "x", "dependency pattern")

  local payloads = linkedspec.compiled_spec.action_payloads(compiled:rule("Top"))
  assert_equal(#payloads, 3, "action payload count")
  assert_equal(payloads[1].action_ast.kind, "action_block", "action AST")
  assert_equal(payloads[1].contracts.ok, true, "registry-aware contracts")
  assert_equal(payloads[1].contracts.contracts[2].family, "user_function", "registered contract")
  assert_equal(payloads[2].lifecycle, "I", "lifecycle identity")
  assert_equal(payloads[3].role, "plain_block", "plain payload role")

  top.header.label = "Mutated"
  top.body[1].kind.pattern = "mutated"
  assert_equal(compiled:rule("Top").label, "Top", "source rule snapshot")
  assert_equal(compiled:rule("Top").regex_patterns[1], "a", "source regex snapshot")
end)

test("compiled spec resolves child regex slots and keeps last definition order", function()
  local first_a = compiled_test_rule("A", true, nil, {
    ast.body_element({ kind = ast.regex_body_kind({ pattern = "old" }), source = "/old/", line = 1 }),
  })
  local b = compiled_test_rule("B", false, nil, {
    ast.body_element({
      kind = ast.action_edge_body_kind({ targets = { ast.edge_target({ label = "A", index = 0 }) } }),
      source = "-> A",
      line = 2,
    }),
  })
  local last_a = compiled_test_rule("A", false, nil, {
    ast.body_element({ kind = ast.regex_body_kind({ pattern = "new" }), source = "/new/", line = 3 }),
  })
  local compiled = linkedspec.compile_spec(
    ast.spec_file({ rules = { first_a, b, last_a } }),
    { validate_source = false }
  )

  assert_equal(table.concat(compiled.definition_order, ","), "A,B,A", "source definition order")
  assert_equal(table.concat(compiled.compiled_rule_order, ","), "B,A", "last definition order")
  assert_equal(compiled.redefined_rule_labels[1], "A", "redefined label")
  assert_equal(compiled:rule("A").regex_patterns[1], "new", "last definition wins")
  assert_equal(compiled:rule("B").regex_patterns[1], "new", "child pattern appended")
  assert_equal(compiled:rule("B").action_edges[1].regex_index, 0, "appended regex index")
  assert_equal(
    linkedspec.compiled_spec.to_json(compiled.dependency_regex_state).kind,
    "compiled_dependency_regex_state",
    "dependency state kind"
  )
end)

test("compiled descriptor matches the exact outward contract", function()
  local body_ast = json.harray({ kind = "action_block", statements = json.array() })
  local normalize = registry_function("normalize", { "value" }, 0, body_ast)
  local compiled = linkedspec.compile_spec(spec_with_functions({ normalize }))
  local descriptor = linkedspec.to_descriptor_json(compiled)
  local contract = json.decode(read_file("capability_conformance/outward_descriptor_contract.json"))

  assert_equal(
    table.concat(sorted_keys(descriptor), ","),
    table.concat(sorted_values(contract.top_level_keys), ","),
    "descriptor top-level keys"
  )
  for _, key in ipairs(contract.required_meta_keys) do
    if descriptor.meta[key] == nil then fail("descriptor missing meta key " .. key) end
  end
  for key, expected in pairs(contract.model_values) do
    assert_equal(descriptor.meta[key], expected, "descriptor model " .. key)
  end
  assert_equal(descriptor.spec.Top.handler.kind, "lua_interpreter_rule", "Lua handler identity")
  assert_equal(descriptor.spec.Top.handler.status, "compiled_state_only", "handler boundary")
  assert_equal(descriptor.meta.function_order[1], "normalize", "function order")
  assert_equal(descriptor.meta.function_count, 1, "function count")
  assert_equal(
    table.concat(sorted_keys(descriptor.functions.normalize), ","),
    table.concat(sorted_values(contract.function_record_keys), ","),
    "function record keys"
  )
  assert_equal(descriptor.functions.normalize.body_ast.kind, "action_block", "function body AST")
  assert_equal(json.decode(json.encode(descriptor)).meta.parse_mode, "seek", "descriptor JSON round-trip")
end)

test("compiled spec reports typed dependency failures after optional validation", function()
  local bad_slot = compiled_test_rule("Top", true, nil, {
    ast.body_element({
      kind = ast.action_edge_body_kind({ targets = { ast.edge_target({ label = "Child", index = 1 }) } }),
      source = "-> Child[1]",
      line = 1,
    }),
  })
  local child = compiled_test_rule("Child", false, nil, {
    ast.body_element({ kind = ast.regex_body_kind({ pattern = "x" }), source = "/x/", line = 2 }),
  })
  local slot_error = assert_compiled_error(function()
    linkedspec.compile_spec(ast.spec_file({ rules = { bad_slot, child } }), { validate_source = false })
  end, "regex slot 1", "compiled slot")
  assert_equal(slot_error.rule_label, "Top", "slot rule identity")
  assert_equal(slot_error.target_label, "Child", "slot target identity")

  local missing = compiled_test_rule("Top", true, nil, {
    ast.body_element({
      kind = ast.action_edge_body_kind({ targets = { ast.edge_target({ label = "Ghost", index = 0 }) } }),
      source = "-> Ghost",
      line = 1,
    }),
  })
  assert_compiled_error(function()
    linkedspec.compile_spec(ast.spec_file({ rules = { missing } }), { validate_source = false })
  end, "undefined rule 'Ghost'", "compiled missing")
end)

test("compile_spec consumes the public parsed source AST", function()
  local parsed = linkedspec.parse_spec([[
Top::
 /x/ -> Top {
   set_key(meta, 'kind', "parsed")
   return(meta)
 }
]])
  local compiled = linkedspec.compile_spec(parsed)
  local top = compiled:rule("Top")
  assert_equal(top.regex_patterns[1], "x", "parsed regex")
  assert_equal(top.action_edges[1].has_parent_regex, true, "parsed edge parent regex")
  assert_equal(top.action_edges[1].action_payload.action_ast.statements[1].expr.kind, "call", "parsed action AST")
  assert_equal(top.action_edges[1].action_payload.contracts.ok, true, "parsed action contracts")
end)

local function assert_runtime_regex_error(operation, expected, stage, label)
  local ok, regex_error = pcall(operation)
  if ok then fail((label or "runtime regex") .. ": expected an error") end
  assert_equal(linkedspec.is_runtime_regex_error(regex_error), true, (label or "runtime regex") .. " type")
  assert_contains(regex_error.message, expected, label)
  if stage then assert_equal(regex_error.stage, stage, (label or "runtime regex") .. " stage") end
  return regex_error
end

test("native PCRE2 adapter covers the governed regex dialect", function()
  assert_equal(linkedspec.runtime_regex_engine(), "pcre2-native", "runtime regex engine")
  assert_contains(linkedspec.runtime_regex_engine_version(), ".", "PCRE2 version")

  local inline = linkedspec.compile_runtime_regex_alternation({ "(?i)abc" })
  assert_equal(inline:consume_match("ABC", 0):text(), "ABC", "inline flags")
  local posix = linkedspec.compile_runtime_regex_alternation({ "[[:alpha:]]++" })
  assert_equal(posix:consume_match("éclair", 0):text(), "éclair", "POSIX and possessive")
  local named = linkedspec.compile_runtime_regex_alternation({ "(?P<word>\\w+)" })
  assert_equal(named:consume_match("value", 0):named_capture("word"), "value", "Python named capture")
  local recursive = linkedspec.compile_runtime_regex_alternation({ "(\\[(?:[^\\[\\]]++|(?R))*\\])" })
  assert_equal(recursive:consume_match("[a[b]c]", 0):text(), "[a[b]c]", "recursive pattern")
  local reset = linkedspec.compile_runtime_regex_alternation({ "prefix\\Kvalue" })
  local reset_match = reset:consume_match("prefixvalue", 0)
  assert_equal(reset_match:text(), "value", "match-start reset text")
  assert_equal(reset_match.byte_start, 6, "match-start reset offset")

  local negative_lookbehind = linkedspec.compile_runtime_regex_alternation({ [[(?<!\\)/]] })
  assert_equal(negative_lookbehind:seek_match("/", 0):text(), "/", "negative lookbehind match")
  assert_equal(negative_lookbehind:seek_match([[\/]], 0), nil, "negative lookbehind rejection")
  local positive_lookbehind = linkedspec.compile_runtime_regex_alternation({ [[(?<=a)b]] })
  assert_equal(positive_lookbehind:seek_match("ab", 0):text(), "b", "positive lookbehind match")
end)

test("runtime alternation preserves seek consume and source-order identity", function()
  local alternation = linkedspec.compile_runtime_regex_alternation({ "b.", "a." })
  local seek = alternation:match("zzab", 0, "seek")
  assert_equal(seek.alternative_index, 1, "earliest alternative")
  assert_equal(seek.byte_start, 2, "seek start")
  assert_equal(seek:text(), "ab", "seek text")
  assert_equal(alternation:match("zzab", 2, "consume").alternative_index, 1, "consume match")
  assert_equal(alternation:consume_match("zzab", 1), nil, "consume anchor")

  local tie = linkedspec.compile_runtime_regex_alternation({ "a.", "ab" }):seek_match("zzab", 0)
  assert_equal(tie.alternative_index, 0, "source-order tie break")
  local compiled = linkedspec.compile_spec(linkedspec.parse_spec("Top::\n /a/\n /b/\n"))
  local from_rule = linkedspec.compile_runtime_regex_alternation(compiled:rule("Top"))
  assert_equal(from_rule:consume_match("b", 0).alternative_index, 1, "compiled-rule alternatives")
end)

test("runtime matches expose compact captures and Unicode positions", function()
  local input = "é\nac"
  local alternation = linkedspec.compile_runtime_regex_alternation({
    "(?P<first>a)(b)?(?P<last>c)",
  })
  local match = alternation:seek_match(input, 0)
  assert_equal(match.byte_start, 3, "byte start")
  assert_equal(match.byte_end, 5, "byte end")
  assert_equal(match:char_start(), 2, "character start")
  assert_equal(match:char_end(), 4, "character end")
  assert_equal(match:char_length(), 2, "character length")
  assert_equal(match.groups[1], "ac", "whole group")
  assert_equal(match.groups[2], "a", "first group")
  assert_equal(match.groups[3], "", "non-participating group slot")
  assert_equal(match.groups[4], "c", "last group")
  assert_equal(table.concat(match.captures, ","), "a,c", "compacted captures")
  assert_equal(match.named.first, "a", "first named capture")
  assert_equal(match.named.last, "c", "last named capture")
  assert_equal(match:start_line_column().line, 2, "match line")
  assert_equal(match:start_line_column().column, 1, "match column")
  assert_equal(linkedspec.matching.byte_offset_to_char_offset(input, 3), 2, "byte-to-char offset")
  assert_equal(linkedspec.matching.char_offset_to_byte_offset(input, 2), 3, "char-to-byte offset")
  local projected = linkedspec.matching.to_json(match)
  assert_equal(json.decode(json.encode(projected)).named.last, "c", "matching JSON")
end)

test("runtime match registers separate entry local and zero-width presence", function()
  local zero = linkedspec.compile_runtime_regex_alternation({ "" }):consume_match("abc", 0)
  assert_equal(zero:is_zero_width(), true, "zero-width match")
  assert_equal(zero:made_progress_from(0), false, "zero-width progress")
  assert_equal(zero:is_zero_progress_from(0), true, "zero-progress identity")

  local initial = linkedspec.runtime_match_registers("abc")
  assert_equal(initial.entry_match, nil, "initial entry absence")
  assert_equal(initial.local_match, nil, "initial local absence")
  local matched = initial:with_local_match(zero)
  assert_equal(matched.entry_match, zero, "top entry seeded")
  assert_equal(matched.local_match, zero, "local match stored")
  assert_equal(matched:zero_progress_since(0), true, "register zero progress")
  local child = matched:enter_child()
  assert_equal(child.entry_match, zero, "child entry from caller local")
  assert_equal(child.local_match, nil, "child local starts absent")
  assert_equal(child.capture_start_byte, 0, "child capture anchor")
  local projected = linkedspec.matching.to_json(child)
  assert_equal(projected.entry_match.zero_width, true, "present zero-width entry")
  assert_equal(projected.local_match, nil, "absent local omitted")

  local advanced = matched:with_cursor_byte(2):with_capture_start_byte(1)
  assert_equal(advanced.cursor_byte, 2, "updated cursor")
  assert_equal(advanced.capture_start_byte, 1, "updated capture anchor")
  assert_equal(matched.cursor_byte, 0, "source registers unchanged")
end)

test("runtime matching returns typed dialect input and boundary failures", function()
  local compile_error = assert_runtime_regex_error(function()
    linkedspec.compile_runtime_regex_alternation({ "(" })
  end, "regex compile error for alternative 0", "regex_compile", "invalid regex")
  assert_equal(compile_error.alternative_index, 0, "compile alternative")

  local alternation = linkedspec.compile_runtime_regex_alternation({ "." })
  assert_runtime_regex_error(function()
    alternation:seek_match("é", 1)
  end, "not a UTF-8 character boundary", "regex_offset", "invalid boundary")
  assert_runtime_regex_error(function()
    alternation:seek_match(string.char(0xFF), 0)
  end, "not valid UTF-8", "regex_input", "invalid input")
  assert_runtime_regex_error(function()
    alternation:match("x", 0, "scan")
  end, "unsupported parse mode", "parse_mode", "invalid mode")

  local other_match = alternation:consume_match("x", 0)
  assert_runtime_regex_error(function()
    linkedspec.runtime_match_registers("y", { local_match = other_match })
  end, "does not belong to register input", nil, "foreign match")
end)

test("runtime interpreter repeats default rules and preserves direct result shape", function()
  local compiled = linkedspec.compile_spec(linkedspec.parse_spec("Top::\n /a/\n"))
  local result = linkedspec.runtime_parse(linkedspec.runtime_engine(compiled), "aaa")
  assert_equal(linkedspec.interpreter.node_type(result), "RuntimeParseResult", "parse result type")
  assert_equal(result.matched, true, "default matched")
  assert_equal(result.cursor_code_unit, 3, "default repeated cursor")
  assert_equal(result.cursor_char_offset, 3, "default character cursor")
  assert_equal(result.value, json.null, "default value")
  assert_equal(result.output[1], json.null, "one-value output wrapper")
  assert_equal(json.decode(json.encode(linkedspec.interpreter.to_json(result))).matched, true, "result JSON")

  local seek = linkedspec.runtime_parse(linkedspec.runtime_engine(compiled), "za")
  assert_equal(seek.cursor_code_unit, 2, "seek advances to match")
  local consume = linkedspec.runtime_parse(
    linkedspec.runtime_engine(compiled, { parse_mode = "consume" }),
    "za"
  )
  assert_equal(consume.matched, false, "consume stays anchored")
  assert_equal(consume.cursor_code_unit, 0, "consume cursor")
end)

test("runtime action edges dispatch children and publish retv", function()
  local source = [[
Top::
 /a/ -> Child
 E { return(retv) }

Child:
 /b/
 E { return("child") }
]]
  local result = linkedspec.runtime_execute(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source))),
    "ab"
  )
  assert_equal(result.matched, true, "action dispatch matched")
  assert_equal(result.value, "child", "retv result")
  assert_equal(result.cursor_code_unit, 2, "child cursor")
  assert_equal(result.output[1], "child", "direct output")

  local current_edge = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /a/ -> Child { return(retv) }

Child:
 /b/
 E { return("edge-child") }
]]))),
    "ab"
  )
  assert_equal(current_edge.value, "edge-child", "current-edge retv dispatch")
  assert_equal(current_edge.cursor_code_unit, 2, "current-edge child cursor")
end)

test("runtime blind AND and OR dispatch preserve mode behavior", function()
  local function terminal(label, pattern, value)
    return compiled_test_rule(label, false, ast.rule_mode("Single"), {
      ast.body_element({ kind = ast.regex_body_kind({ pattern = pattern }), source = "/" .. pattern .. "/", line = 1 }),
      ast.body_element({
        kind = ast.code_block_body_kind({ lifecycle = "LE", code = 'return("' .. value .. '")' }),
        source = 'LE { return("' .. value .. '") }',
        line = 2,
      }),
    })
  end
  local and_top = compiled_test_rule("Top", true, ast.rule_mode("And"), {
    ast.body_element({ kind = ast.blind_edge_body_kind({ target = "A" }), source = "=> A", line = 1 }),
    ast.body_element({ kind = ast.blind_edge_body_kind({ target = "B" }), source = "=> B", line = 2 }),
  })
  local and_spec = ast.spec_file({ rules = { and_top, terminal("A", "a", "A"), terminal("B", "b", "B") } })
  local and_result = linkedspec.runtime_parse(linkedspec.runtime_engine(linkedspec.compile_spec(and_spec)), "ab")
  assert_equal(and_result.matched, true, "blind AND matched")
  assert_equal(json.kind(and_result.value), "array", "blind AND value")
  assert_equal(table.concat(and_result.value, ","), "A,B", "blind AND child order")

  local or_top = compiled_test_rule("Top", true, ast.rule_mode("Or"), {
    ast.body_element({ kind = ast.blind_edge_body_kind({ target = "A" }), source = "=> A", line = 1 }),
    ast.body_element({ kind = ast.blind_edge_body_kind({ target = "B" }), source = "=> B", line = 2 }),
    ast.body_element({
      kind = ast.code_block_body_kind({ lifecycle = "E", code = "return(retv)" }),
      source = "E { return(retv) }",
      line = 3,
    }),
  })
  local or_spec = ast.spec_file({ rules = { or_top, terminal("A", "a", "A"), terminal("B", "b", "B") } })
  local or_result = linkedspec.runtime_parse(linkedspec.runtime_engine(linkedspec.compile_spec(or_spec)), "b")
  assert_equal(or_result.value, "B", "blind OR first success")
end)

test("runtime lifecycle order and local stores survive guarded repetition", function()
  local body = {}
  local function lifecycle_element(name, code, line)
    body[#body + 1] = ast.body_element({
      kind = ast.code_block_body_kind({ lifecycle = name, code = code }),
      source = name .. " { " .. code .. " }",
      line = line,
    })
  end
  lifecycle_element("I", 'set(state, "entered")', 1)
  lifecycle_element("LS", 'set(loop, "start")', 2)
  body[#body + 1] = ast.body_element({ kind = ast.regex_body_kind({ pattern = "a" }), source = "/a/", line = 3 })
  lifecycle_element("LE", "set(last, match_text())", 4)
  lifecycle_element("IT", 'set(iteration, "done")', 5)
  lifecycle_element("EX", 'set(extended, "done")', 6)
  lifecycle_element("LX", 'set(loop, "exit")', 7)
  lifecycle_element("E", "return(state)", 8)
  local spec = ast.spec_file({ rules = { compiled_test_rule("Top", true, ast.rule_mode("Plus"), body) } })
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(spec)),
    "a"
  )
  assert_equal(result.value, "entered", "local scalar store")
  local names = {}
  for index, event in ipairs(result.lifecycle_events) do names[index] = event.lifecycle end
  assert_equal(table.concat(names, ","), "I,LS,LE,IT,LS,EX,LX,E", "lifecycle order")
end)

test("runtime interpreter guards bounds recursion zero progress and unsupported helpers", function()
  local bounded = compiled_test_rule("Top", true, ast.or_bounded_rule_mode({ min = 2, max = 2 }), {
    ast.body_element({ kind = ast.regex_body_kind({ pattern = "a" }), source = "/a/", line = 1 }),
  })
  local ok, bounded_error = pcall(function()
    linkedspec.runtime_parse(
      linkedspec.runtime_engine(linkedspec.compile_spec(ast.spec_file({ rules = { bounded } }))),
      "a"
    )
  end)
  assert_equal(ok, false, "bounded failure")
  assert_equal(linkedspec.is_runtime_interpreter_error(bounded_error), true, "bounded typed error")
  assert_contains(bounded_error.message, "expected at least 2 matches", "bounded detail")

  local recursive = compiled_test_rule("Top", true, ast.rule_mode("Or"), {
    ast.body_element({ kind = ast.regex_body_kind({ pattern = "" }), source = "//", line = 1 }),
    ast.body_element({ kind = ast.blind_edge_body_kind({ target = "Top" }), source = "=> Top", line = 1 }),
  })
  local recursive_result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(
      ast.spec_file({ rules = { recursive } }),
      { validate_source = false }
    )),
    ""
  )
  assert_equal(recursive_result.matched, false, "recursion cutoff")

  local zero = compiled_test_rule("Top", true, ast.rule_mode("Star"), {
    ast.body_element({ kind = ast.regex_body_kind({ pattern = "" }), source = "//", line = 1 }),
  })
  local zero_result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(ast.spec_file({ rules = { zero } }))),
    ""
  )
  assert_equal(zero_result.matched, true, "zero-width match remains present")
  assert_equal(zero_result.cursor_code_unit, 0, "zero-progress cutoff")

  local unsupported = linkedspec.compile_spec(linkedspec.parse_spec("Top::\n /x/ E { invented_helper() }\n"))
  local helper_ok, helper_error = pcall(
    linkedspec.runtime_parse,
    linkedspec.runtime_engine(unsupported),
    "x"
  )
  assert_equal(helper_ok, false, "unsupported runtime helper")
  assert_equal(linkedspec.is_runtime_interpreter_error(helper_error), true, "unsupported typed error")
end)

test("runtime control and local stores match the cross-backend rule contract", function()
  local next_engine = linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /skip/ { next() }
 /keep/
 E { return(match_text()) }
]])))
  local next_result = linkedspec.runtime_parse(next_engine, "skipkeep")
  assert_equal(next_result.value, "keep", "next advances to the next rule iteration")
  assert_equal(next_result.cursor_code_unit, 8, "next preserves cursor progress")

  local scoped_engine = linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /a/ -> Child { set(shared, "parent") }
 E { return(shared) }

Child:
 /b/
 LE { set(shared, "child") }
 E { return(shared) }
]])))
  local scoped_result = linkedspec.runtime_parse(scoped_engine, "ab")
  assert_equal(scoped_result.value, "parent", "child local store does not leak into caller")

  local false_engine = linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /a/ -> Child

Child:
 /b/
 E { return(false) }
]])))
  local false_result = linkedspec.runtime_parse(false_engine, "ab")
  assert_equal(false_result.value, false, "false child return is not replaced by null")
  assert_equal(false_result.output[1], false, "false direct output is preserved")

  local exit_engine = linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /x/
 E { exit_now(7); return("unreachable") }
]])))
  local exit_ok, exit_error = pcall(linkedspec.runtime_parse, exit_engine, "x")
  assert_equal(exit_ok, false, "exit_now terminates immediately")
  assert_equal(linkedspec.is_runtime_interpreter_error(exit_error), true, "exit_now typed error")
  assert_equal(exit_error.message, "exit_now(7) in rule Top", "exit_now detail")
  assert_equal(exit_error.status, 7, "exit_now status")
end)

test("runtime core stores snapshots and checked access preserve typed values", function()
  local source = [[
Top::
 /x/
 I {
   scalar_value = false
   items = [1, { "name" : "old" }]
   meta = { "kind" : "base" }
   set(named_items, ["a"])
   set(named_meta, { "x" : 1 })
   items += 3
   meta["added"] = false
   items[1]["name"] = "new"
   items_snapshot = copy(items)
   meta_snapshot = copy(meta)
   items += 4
   meta["kind"] = "changed"
   items[8]["name"] = "forbidden"
 }
 E {
   return({
     "scalar_kind" : scalar_value,
     "items" : items,
     "meta" : meta,
     "items_snapshot" : items_snapshot,
     "meta_snapshot" : meta_snapshot,
     "named_items" : named_items,
     "named_meta" : named_meta,
     "nested" : items[1]["name"],
     "indexed" : meta["added"],
     "missing" : items[8]
   })
 }
]]
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source))),
    "x"
  )
  assert_equal(linkedspec.runtime_value_kind(result.value), "harray", "result harray kind")
  assert_equal(result.value.scalar_kind, false, "false scalar identity")
  assert_equal(json.kind(result.value.items), "array", "scalar-held array identity")
  assert_equal(#result.value.items, 4, "array append count")
  assert_equal(result.value.items[2].name, "new", "nested array-harray assignment")
  assert_equal(result.value.meta.kind, "changed", "hash-index assignment")
  assert_equal(result.value.meta.added, false, "false hash value")
  assert_equal(#result.value.items_snapshot, 3, "array snapshot isolation")
  assert_equal(result.value.meta_snapshot.kind, "base", "harray snapshot isolation")
  assert_equal(result.value.named_items[1], "a", "named array store")
  assert_equal(result.value.named_meta.x, 1, "named harray store")
  assert_equal(result.value.nested, "new", "nested access")
  assert_equal(result.value.indexed, false, "indexed false access")
  assert_equal(result.value.missing, json.null, "checked missing access")

  local eager_block_result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /x/
 I { callback = { return("later") } }
 E { return(callback) }
]]))),
    "x"
  )
  assert_equal(linkedspec.runtime_value_kind(eager_block_result.value), "scalar", "ordinary block is eager")
  assert_equal(eager_block_result.value, "later", "ordinary block returns its local payload")
  assert_equal(linkedspec.runtime_value_kind(json.null), "scalar", "null scalar kind")
  assert_equal(linkedspec.runtime_value_kind(json.array()), "array", "empty array kind")
end)

test("runtime entry and match helper families expose captures and Unicode positions", function()
  local source = [[
Top::
 /(?<name>\w+)=(\d+)/
 E {
   return({
     "entry_text" : entry_text(),
     "match_text" : match_text(),
     "entry_group_0" : entry_group(0),
     "match_group_1" : match_group(1),
     "entry_groups" : entry_groups(),
     "match_groups" : match_groups(),
     "entry_named" : entry_named(name),
     "match_named" : match_named(name),
     "entry_has" : entry_has(name),
     "match_has" : match_has(name),
     "entry_map" : entry_map(),
     "match_map" : match_map(),
     "entry_len" : entry_len(),
     "match_len" : match_len(),
     "entry_start" : entry_start_pos(),
     "entry_end" : entry_end_pos(),
     "match_start" : match_start_pos(),
     "match_end" : match_end_pos(),
     "entry_line" : entry_line(),
     "entry_col" : entry_col(),
     "entry_start_line" : entry_start_line(),
     "entry_start_col" : entry_start_col(),
     "entry_end_line" : entry_end_line(),
     "entry_end_col" : entry_end_col(),
     "match_line" : match_line(),
     "match_col" : match_col(),
     "match_start_line" : match_start_line(),
     "match_start_col" : match_start_col(),
     "match_end_line" : match_end_line(),
     "match_end_col" : match_end_col()
   })
 }
]]
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source))),
    "é\nkey=42"
  )
  assert_equal(result.value.entry_text, "key=42", "entry text")
  assert_equal(result.value.match_text, "key=42", "match text")
  assert_equal(result.value.entry_group_0, "key", "entry compact capture")
  assert_equal(result.value.match_group_1, "42", "match compact capture")
  assert_equal(table.concat(result.value.entry_groups, ","), "key,42", "entry capture list")
  assert_equal(table.concat(result.value.match_groups, ","), "key,42", "match capture list")
  assert_equal(result.value.entry_named, "key", "entry named capture")
  assert_equal(result.value.match_named, "key", "match named capture")
  assert_equal(result.value.entry_has, 1, "entry named presence")
  assert_equal(result.value.match_has, 1, "match named presence")
  assert_equal(result.value.entry_map.name, "key", "entry named map")
  assert_equal(result.value.match_map.name, "key", "match named map")
  assert_equal(result.value.entry_len, 6, "entry character length")
  assert_equal(result.value.match_len, 6, "match character length")
  assert_equal(result.value.entry_start, 2, "entry character start")
  assert_equal(result.value.entry_end, 8, "entry character end")
  assert_equal(result.value.match_start, 2, "match character start")
  assert_equal(result.value.match_end, 8, "match character end")
  assert_equal(result.value.entry_line, 2, "entry line alias")
  assert_equal(result.value.entry_col, 1, "entry column alias")
  assert_equal(result.value.entry_start_line, 2, "entry start line")
  assert_equal(result.value.entry_start_col, 1, "entry start column")
  assert_equal(result.value.entry_end_line, 2, "entry end line")
  assert_equal(result.value.entry_end_col, 7, "entry end column")
  assert_equal(result.value.match_line, 2, "match line alias")
  assert_equal(result.value.match_col, 1, "match column alias")
  assert_equal(result.value.match_start_line, 2, "match start line")
  assert_equal(result.value.match_start_col, 1, "match start column")
  assert_equal(result.value.match_end_line, 2, "match end line")
  assert_equal(result.value.match_end_col, 7, "match end column")
end)

test("runtime absent match helpers preserve null empty and origin distinctions", function()
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /x/
 I {
   return({
     "text" : match_text(),
     "group" : match_group(0),
     "groups" : match_groups(),
     "named" : match_named(name),
     "has" : match_has(name),
     "map" : match_map(),
     "len" : match_len(),
     "start" : match_start_pos(),
     "end" : match_end_pos(),
     "line" : match_line(),
     "col" : match_col()
   })
 }
]]))),
    "x"
  )
  assert_equal(result.value.text, json.null, "absent match text")
  assert_equal(result.value.group, json.null, "absent match group")
  assert_equal(json.kind(result.value.groups), "array", "absent groups type")
  assert_equal(#result.value.groups, 0, "absent groups empty")
  assert_equal(result.value.named, json.null, "absent named capture")
  assert_equal(result.value.has, 0, "absent named presence")
  assert_equal(json.kind(result.value.map), "harray", "absent map type")
  assert_equal(result.value.len, json.null, "absent match length")
  assert_equal(result.value.start, json.null, "absent start")
  assert_equal(result.value["end"], json.null, "absent end")
  assert_equal(result.value.line, 1, "absent line origin")
  assert_equal(result.value.col, 1, "absent column origin")
end)

test("runtime deterministic pure scalar string helpers and receivers preserve portable values", function()
  local source = [[
Top::
 /x/
 I {
   raw = " node-name_end "
 }
 E {
   return({
     "cat" : cat("n=", 2, false),
     "cat_null" : cat("n=", 2, false, undef),
     "cat_negative_zero" : cat(-0.0),
     "cat_aggregate_empty" : cat("x", [1], { "a" : 1 }, "y"),
     "coalesce_false" : coalesce(undef, false, "bad"),
     "coalesce_nonempty_zero" : coalesce_nonempty("", 0, "bad"),
     "coalesce_lazy" : coalesce("kept", invented_helper()),
     "defined" : is_defined(false),
     "undefined" : is_undefined(undef),
     "empty_null" : is_empty(undef),
     "empty_array" : is_empty([]),
     "empty_hash" : is_empty({}),
     "nonempty_false" : is_nonempty(false),
     "trim_unicode" : trim("   value   "),
     "length_unicode" : length("é😀"),
     "length_array" : length([1, 2]),
     "length_hash" : length({ "a" : 1, "b" : 2 }),
     "length_false" : length(false),
     "starts" : starts_with("éclair", "é"),
     "ends" : ends_with("éclair", "air"),
     "contains" : contains_substr("a😀b", "😀"),
     "replace" : replace_substr("aaaa", "aa", "b"),
     "replace_empty" : replace_substr("abc", "", "x"),
     "rm_prefix" : rm_prefix("node_name", "node_"),
     "rm_suffix" : rm_suffix("name_end", "_end"),
     "substr_unicode" : substr("aé😀z", 1, 2),
     "substr_rest" : substr("aé😀z", 2),
     "substr_negative" : substr("abc", -2, 2),
     "substr_past" : substr("abc", 9, 2),
     "str_eq" : str_eq("a", "a"),
     "str_ne" : str_ne("a", "b"),
     "str_gt" : str_gt("2", "10"),
     "str_ge" : str_ge("2", "2"),
     "str_lt" : str_lt("10", "2"),
     "str_le" : str_le("2", "2"),
     "str_null" : str_eq(undef, ""),
     "chain" : raw.trim().replace_substr("-", "_").rm_prefix("node_").rm_suffix("_end").cat("!"),
     "receiver_coalesce" : "".coalesce_nonempty(" fallback ").trim(),
     "terminal_continuation" : "abc".length().trim(),
     "trim_null" : trim(undef),
     "replace_null" : replace_substr(undef, "a", "b")
   })
 }
]]
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source))),
    "x"
  )
  assert_equal(result.value.cat, "n=20", "stable scalar cat conversion")
  assert_equal(result.value.cat_negative_zero, "0", "stable negative-zero conversion")
  assert_equal(result.value.cat_null, json.null, "null propagates through cat")
  assert_equal(result.value.cat_aggregate_empty, json.null, "aggregate propagates null through cat")
  assert_equal(result.value.coalesce_false, false, "coalesce preserves false")
  assert_equal(result.value.coalesce_nonempty_zero, 0, "coalesce_nonempty preserves zero")
  assert_equal(result.value.coalesce_lazy, "kept", "coalesce short-circuits unevaluated fallback")
  assert_equal(result.value.defined, true, "defined false predicate")
  assert_equal(result.value.undefined, true, "undefined null predicate")
  assert_equal(result.value.empty_null, true, "empty null predicate")
  assert_equal(result.value.empty_array, true, "empty array predicate")
  assert_equal(result.value.empty_hash, true, "empty hash predicate")
  assert_equal(result.value.nonempty_false, true, "false is a nonempty scalar")
  assert_equal(result.value.trim_unicode, "value", "Unicode whitespace trim")
  assert_equal(result.value.length_unicode, 2, "Unicode scalar length")
  assert_equal(result.value.length_array, 2, "array length")
  assert_equal(result.value.length_hash, 2, "harray length")
  assert_equal(result.value.length_false, 1, "boolean scalar text length")
  assert_equal(result.value.starts, 1, "literal Unicode prefix")
  assert_equal(result.value.ends, 1, "literal suffix")
  assert_equal(result.value.contains, 1, "literal Unicode containment")
  assert_equal(result.value.replace, "bb", "literal replace all")
  assert_equal(result.value.replace_empty, "abc", "empty literal replacement source")
  assert_equal(result.value.rm_prefix, "name", "literal prefix removal")
  assert_equal(result.value.rm_suffix, "name", "literal suffix removal")
  assert_equal(result.value.substr_unicode, "é😀", "Unicode substring")
  assert_equal(result.value.substr_rest, "😀z", "substring remainder")
  assert_equal(result.value.substr_negative, "ab", "negative substring clamp")
  assert_equal(result.value.substr_past, "", "past-end substring")
  assert_equal(result.value.str_eq, true, "string equality")
  assert_equal(result.value.str_ne, true, "string inequality")
  assert_equal(result.value.str_gt, true, "lexical string greater")
  assert_equal(result.value.str_ge, true, "lexical string greater-equal")
  assert_equal(result.value.str_lt, true, "lexical string less")
  assert_equal(result.value.str_le, true, "lexical string less-equal")
  assert_equal(result.value.str_null, json.null, "string comparison null propagation")
  assert_equal(result.value.chain, "name!", "string receiver composition")
  assert_equal(result.value.receiver_coalesce, "fallback", "lazy receiver coalesce composition")
  assert_equal(result.value.terminal_continuation, json.null, "terminal string chain rejection")
  assert_equal(result.value.trim_null, json.null, "trim null propagation")
  assert_equal(result.value.replace_null, json.null, "replace null propagation")
end)

test("cat and scalar receiver text match the neutral six-variant contract", function()
  local handle = assert(io.open("capability_conformance/scalar_text_contract.json", "rb"))
  local contract = json.decode(assert(handle:read("*a")))
  assert(handle:close())
  assert_equal(contract.format, 1, "scalar-text contract format")
  assert_equal(contract.contract_id, "linkedspec-scalar-text-v1", "scalar-text contract id")
  assert_equal(contract.policy.codeblock, json.null, "codeblock is non-text")
  assert_equal(contract.retired_names[1], "concat", "concat remains retired")

  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(contract.spec_source))),
    "xx"
  )
  for key, expected in pairs(contract.expected) do
    assert_equal(result.value[key], expected, "neutral scalar-text field " .. key)
  end
end)

test("helper regex flags and matches are strict in function and receiver form", function()
  local source = [[
Top::
 /x/
 E {
   return({
     "plain" : matches("prefix-42", /\d+$/),
     "case" : matches("AbC", /^abc$/i),
     "case_noops" : matches("AbC", /^abc$/igo),
     "multiline" : matches("x
Y", /^y$/im),
     "dotall" : matches("a
b", /^a.b$/s),
     "extended" : matches("a b", /^ a \s+ b $/x),
     "null" : matches(undef, /x/),
     "non_regex" : matches("abc", "abc"),
     "unknown_flag" : matches("abc", /^abc$/q),
     "invalid_pattern" : matches("abc", /(/),
     "receiver" : "AbC".matches(/^abc$/io),
     "terminal_chain" : "abc".matches(/a/).lowercase()
   })
 }
]]
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source))),
    "x"
  )
  assert_equal(result.value.plain, true, "plain helper regex searches")
  assert_equal(result.value.case, true, "case-insensitive helper regex")
  assert_equal(result.value.case_noops, true, "g and o are predicate no-ops")
  assert_equal(result.value.multiline, true, "multiline helper flag")
  assert_equal(result.value.dotall, true, "dotall helper flag")
  assert_equal(result.value.extended, true, "extended helper flag")
  assert_equal(result.value.null, false, "null helper input fails closed")
  assert_equal(result.value.non_regex, false, "non-regex pattern fails closed")
  assert_equal(result.value.unknown_flag, false, "unknown helper flag fails closed")
  assert_equal(result.value.invalid_pattern, false, "invalid helper pattern fails closed")
  assert_equal(result.value.receiver, true, "receiver matches uses the same adapter")
  assert_equal(result.value.terminal_chain, json.null, "matches ends string receiver chains")
end)

test("pure split preserves typed literal regex Unicode and receiver boundaries", function()
  local source = [[
Top::
 /x/
 E {
   raw = "a-b-"
   return({
     "literal" : split(",a,b,", ","),
     "regex" : split("a1b22c", /\d+/go),
     "case" : split("aXbxc", /x/i),
     "characters" : split("🙂a", ""),
     "zero_width" : split("abc", /(?=b)/),
     "receiver" : raw.split("-"),
     "invalid_pattern" : split("abc", /(/),
     "unknown_flag" : split("abc", /b/q),
     "null" : split(undef, ","),
     "non_text" : split(["a"], ","),
     "source_after" : raw,
     "slice" : substr("🙂abc", 1, 2),
     "literal_replace" : replace_substr("a-b-a", "a", "x")
   })
 }
]]
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source))),
    "x"
  ).value
  assert_equal(json.kind(result.literal), "array", "literal split returns typed array")
  assert_equal(#result.literal, 4, "literal split preserves leading and trailing empties")
  assert_equal(result.literal[1], "", "literal leading empty")
  assert_equal(result.literal[4], "", "literal trailing empty")
  assert_equal(table.concat(result.regex, "|"), "a|b|c", "regex split uses PCRE2")
  assert_equal(table.concat(result.case, "|"), "a|b|c", "regex split uses helper flags")
  assert_equal(#result.characters, 2, "empty delimiter splits Unicode characters")
  assert_equal(result.characters[1], "🙂", "Unicode split preserves scalar bytes")
  assert_equal(table.concat(result.zero_width, "|"), "a|bc", "zero-width regex split makes progress")
  assert_equal(#result.receiver, 3, "receiver split preserves trailing empty")
  assert_equal(result.receiver[3], "", "receiver split trailing field")
  assert_equal(#result.invalid_pattern, 0, "invalid regex split fails closed")
  assert_equal(#result.unknown_flag, 0, "unknown regex flag split fails closed")
  assert_equal(#result.null, 0, "null split returns empty array")
  assert_equal(#result.non_text, 0, "non-text split returns empty array")
  assert_equal(result.source_after, "a-b-", "pure receiver split does not mutate source")
  assert_equal(result.slice, "ab", "Unicode substr remains a distinct pure value")
  assert_equal(result.literal_replace, "x-b-x", "literal replacement remains non-regex")
end)

test("statement regex substitution mutates bare scalars and preserves pure substr", function()
  local source = [[
Top::
 /x/
 E {
   value = "\"bar baz\""
   numbered = "a12b34"
   first_only = "a1b2"
   letters = "AbA"
   zero_width = "🙂a"
   untouched = "abcdef"
   substr(value, '"|\s', "", go)
   regex_subst(numbered, /(\d+)/, "[$1:$0]", g)
   substr(first_only, /(\d+)/, "[$1]", o)
   substr(letters, /a/, "x", ig)
   regex_subst(zero_width, /(?=.)/, "-", g)
   substr(untouched, 1, 3)
   return({
     "value" : value,
     "numbered" : numbered,
     "first_only" : first_only,
     "letters" : letters,
     "zero_width" : zero_width,
     "untouched" : untouched,
     "slice" : substr(untouched, 1, 3)
   })
 }
]]
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source))),
    "x"
  ).value
  assert_equal(result.value, "barbaz", "string pattern and global/no-op flags mutate target")
  assert_equal(result.numbered, "a[12:12]b[34:34]", "$n and $0 replacements expand")
  assert_equal(result.first_only, "a[1]b2", "missing global flag replaces first match only")
  assert_equal(result.letters, "xbx", "regex literal and case-insensitive global flags compose")
  assert_equal(result.zero_width, "-🙂-a", "global zero-width substitution makes Unicode-safe progress")
  assert_equal(result.untouched, "abcdef", "discarded numeric substr remains pure")
  assert_equal(result.slice, "bcd", "value-form numeric substr still slices")

  local invalid_source = [[
Broken::
 /x/
 E { value = "abc"; regex_subst(value, "(", "", g) }
]]
  local ok, failure = pcall(function()
    linkedspec.runtime_parse(
      linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(invalid_source))),
      "x"
    )
  end)
  assert_equal(ok, false, "invalid statement regex fails")
  assert_equal(linkedspec.is_runtime_interpreter_error(failure), true, "invalid regex uses runtime diagnostic")
  assert_equal(failure.rule_label, "Broken", "invalid regex diagnostic attributes its rule")

  local flag_source = [[
Flagged::
 /x/
 E { value = "abc"; substr(value, /b/, "x", q) }
]]
  ok, failure = pcall(function()
    linkedspec.runtime_parse(
      linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(flag_source))),
      "x"
    )
  end)
  assert_equal(ok, false, "unknown statement regex flag fails")
  assert_equal(failure.rule_label, "Flagged", "unknown flag diagnostic attributes its rule")
end)

test("statement split distinguishes bare mutable and pure forms", function()
  local source = [[
Top::
 /x/
 E {
   raw = " left , right,,third "
   parts = ["stale"]
   scalar_parts = split("a,b", ",")
   split(parts, raw, /\s*,\s*/)
   split(literal_parts, ",a,", ",")
   split(scalar_parts, "ignored", ",")
   return({
     "parts" : copy(parts),
     "literal_parts" : copy(literal_parts),
     "scalar_parts" : scalar_parts,
     "raw_after" : raw,
     "pure" : split("x-y", "-")
   })
 }
]]
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source))),
    "x"
  ).value
  assert_equal(json.kind(result.parts), "array", "explicit target remains a typed array")
  assert_equal(table.concat(result.parts, "|"), " left|right||third ", "regex split replaces explicit target")
  assert_equal(#result.literal_parts, 3, "literal target split preserves empty fields")
  assert_equal(result.literal_parts[1], "", "literal target leading empty")
  assert_equal(result.literal_parts[3], "", "literal target trailing empty")
  assert_equal(table.concat(result.scalar_parts, "|"), "ignored", "bare three-argument split replaces target")
  assert_equal(result.raw_after, " left , right,,third ", "statement split leaves source scalar untouched")
  assert_equal(table.concat(result.pure, "|"), "x|y", "pure split value remains available")
end)

local function execute_uniform_binding_source(source, input)
  return linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source))),
    input or "xx"
  ).value
end

local function assert_json_equal(actual, expected, label)
  assert_equal(json.encode(actual), json.encode(expected), label)
end

local function uniform_binding_action_source(action)
  return "Top::\n /x/ -> Done { " .. action .. " }\nDone::\n /x/\n"
end

test("runtime eager blocks return last values and consume local return", function()
  local source = uniform_binding_action_source([[
items = [" raw "]
last_value = { set(x, "a"); x }
early_value = { set(y, "before"); return({ "stage" : y }); set(y, "after"); "bad" }
null_value = { return() }
trimmed = { trim_each(items); items[0] }
receiver_value = { [3, 1, 2] }.sorted().join_values(",")
return({
  "last" : last_value,
  "early" : early_value,
  "y_after" : y,
  "null" : null_value,
  "trimmed" : trimmed,
  "receiver" : receiver_value,
  "empty_hash" : {},
  "keyed_hash" : { "k" : "v" }
})
]])
  local result = execute_uniform_binding_source(source)
  assert_equal(result.last, "a", "final block expression is the value")
  assert_equal(json.kind(result.early), "harray", "local return preserves harray payload")
  assert_equal(result.early.stage, "before", "local return payload is exact")
  assert_equal(result.y_after, "before", "local return skips later block statements")
  assert_equal(result.null, json.null, "no-argument local return yields null")
  assert_equal(result.trimmed, "raw", "non-final dropped mutation executes before final value")
  assert_equal(result.receiver, "1,2,3", "yielded block value enters receiver dispatch")
  assert_equal(json.kind(result.empty_hash), "harray", "empty braces remain an harray")
  assert_equal(json.kind(result.keyed_hash), "harray", "keyed braces remain an harray")
  assert_equal(result.keyed_hash.k, "v", "keyed harray value is preserved")

  local trailing = linkedspec.parse_action_expression('with("x") { return(value) }')
  assert_equal(trailing.args[#trailing.args].value.kind, "block_value", "trailing block remains structural")
  assert_equal(#trailing.args[#trailing.args].value.block.statements, 1, "trailing block body remains inert")
end)

test("runtime inline value controls select one lazy payload", function()
  local source = uniform_binding_action_source([[
selector_calls = []
kind = "tag"
tag = "dynamic"
assigned = if(false, exit_now(7), elseif(true, { return("elseif") }), else(exit_now(8)))
subject_once = switch(
  { push(selector_calls, "seen"); kind },
  case(other, exit_now(9)),
  case(tag, { return("literal") }),
  default(exit_now(10))
)
dynamic = switch("dynamic", case(cat(tag, ""), "dynamic-hit"), default(exit_now(11)))
return({
  "true" : if(true, false, exit_now(12)),
  "null" : if(false, exit_now(13)),
  "plain" : if(0, exit_now(14), "fallback"),
  "zero_string" : if("0", exit_now(15), "zero"),
  "empty_array" : if([], "array-reference", exit_now(16)),
  "empty_harray" : if({}, "harray-reference", exit_now(17)),
  "assigned" : assigned,
  "subject_once" : subject_once,
  "selector_calls" : count(selector_calls),
  "dynamic" : dynamic,
  "switch_null" : switch("missing", case(tag, exit_now(18))),
  "switch_null_match" : switch(undef, case("", "null-match"), default(exit_now(19))),
  "switch_bool_number" : switch(false, case(0, "bool-number"), default(exit_now(20))),
  "switch_aggregate" : switch([], case("", exit_now(21)), default("aggregate-default"))
})
]])
  local result = execute_uniform_binding_source(source)
  assert_equal(result["true"], false, "selected false payload is preserved")
  assert_equal(result.null, json.null, "missing if fallback yields null")
  assert_equal(result.plain, "fallback", "plain fallback is selected lazily")
  assert_equal(result.zero_string, "zero", "Perl-oracle string zero is false")
  assert_equal(result.empty_array, "array-reference", "empty array value remains reference-truthful")
  assert_equal(result.empty_harray, "harray-reference", "empty harray value remains reference-truthful")
  assert_equal(result.assigned, "elseif", "selected elseif block returns locally")
  assert_equal(result.subject_once, "literal", "bare case label stays literal")
  assert_equal(result.selector_calls, 1, "switch subject evaluates exactly once")
  assert_equal(result.dynamic, "dynamic-hit", "compound case expression reads a binding")
  assert_equal(result.switch_null, json.null, "unmatched switch without default yields null")
  assert_equal(result.switch_null_match, "null-match", "null shares the governed empty scalar switch spelling")
  assert_equal(result.switch_bool_number, "bool-number", "false shares the governed numeric zero spelling")
  assert_equal(result.switch_aggregate, "aggregate-default", "aggregate values do not collapse to empty scalar text")

  local fluent = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /x/ -> Done.return(if(false, "bad", "fluent"))
Done::
 /x/
]]))),
    "xx"
  ).value
  assert_equal(fluent, "fluent", "inline control composes in fluent return")

  for _, malformed in ipairs({
    { source = "return(if())", helper = "if" },
    { source = 'return(if(false, "x", elseif(true, "y", "z")))', helper = "elseif" },
    { source = "return(switch())", helper = "switch" },
    { source = 'return(switch("x", case()))', helper = "case" },
  }) do
    local ok, failure = pcall(function()
      execute_uniform_binding_source(uniform_binding_action_source(malformed.source))
    end)
    assert_equal(ok, false, malformed.helper .. " malformed arity fails")
    assert_equal(linkedspec.is_runtime_interpreter_error(failure), true, malformed.helper .. " typed failure")
    assert_equal(failure.code, "helper_arity_mismatch", malformed.helper .. " generic arity code")
    assert_equal(failure.helper_name, malformed.helper, malformed.helper .. " diagnostic helper")
  end

  for _, structural_alias in ipairs({ "i", "elif", "when", "otherwise" }) do
    local ok, failure = pcall(function()
      execute_uniform_binding_source(uniform_binding_action_source(
        'return(' .. structural_alias .. '(true, "yes", "no"))'
      ))
    end)
    assert_equal(ok, false, structural_alias .. " does not become an inline value alias")
    assert_equal(failure.helper_name, structural_alias, structural_alias .. " stays source-attributed")
  end

  local unless_resolution = linkedspec.resolve_action_expression_contracts(
    linkedspec.parse_action_expression('unless(true, "yes", "no")')
  )
  assert_equal(unless_resolution.ok, false, "unless remains outside the governed helper surface")
  assert_equal(unless_resolution.diagnostics[1].code, "unknown_helper", "unless uses generic unknown diagnostic")
  assert_equal(unless_resolution.diagnostics[1].helper_name, "unless", "unless diagnostic stays source-attributed")
end)

test("runtime statement if controls execute one attached or marker branch", function()
  local source = uniform_binding_action_source([[
events = []
if(false) { exit_now(31) }
elseif(true) { push(events, "attached-elseif") }
elseif(exit_now(32)) { exit_now(33) }
else { exit_now(34) }
when(false) { exit_now(35) } otherwise { push(events, "attached-otherwise") }
when(true) {} otherwise { exit_now(36) }
push(events, "after-attached-empty")
i(false)
  exit_now(37)
elif(true)
  push(events, "marker-elif")
elseif(exit_now(38))
  exit_now(39)
else()
  exit_now(40)
endif()
if(false)
  exit_now(41)
else()
  push(events, "marker-else")
endif()
if(true)
elseif(exit_now(42))
  exit_now(43)
endif()
push(events, "after-marker-empty")
if(true)
  if(false)
    exit_now(44)
  else()
    push(events, "nested-marker")
  endif()
else()
  exit_now(45)
endif()
attached_value = { if(false) { return("bad") } elseif(true) { return("attached-local") } else { return("bad") } }
marker_value = { i(false); return("bad"); elif(true); return("marker-local"); else(); return("bad"); endif() }
return({ "events" : copy(events), "attached_value" : attached_value, "marker_value" : marker_value })
]])
  local result = execute_uniform_binding_source(source)
  assert_json_equal(result.events, json.decode([[
[
  "attached-elseif",
  "attached-otherwise",
  "after-attached-empty",
  "marker-elif",
  "marker-else",
  "after-marker-empty",
  "nested-marker"
]
]]), "attached and marker branches preserve ActionIR order")
  assert_equal(result.attached_value, "attached-local", "attached branch return stays block-local")
  assert_equal(result.marker_value, "marker-local", "marker branch return stays block-local")

  local action_return = execute_uniform_binding_source(uniform_binding_action_source([[
if(false)
  return("bad")
else()
  return("marker-action-return")
endif()
exit_now(46)
]]))
  assert_equal(action_return, "marker-action-return", "selected marker return exits the surrounding action block")

  for _, malformed in ipairs({
    { source = 'elseif(true); return("bad")', keyword = "elseif", reason = "orphaned branch or marker" },
    { source = 'otherwise(); return("bad")', keyword = "otherwise", reason = "orphaned branch or marker" },
    { source = 'endif(); return("bad")', keyword = "endif", reason = "orphaned branch or marker" },
    { source = 'if(true); return("bad")', keyword = "if", reason = "missing endif" },
    { source = 'if(false); else(); else(); endif()', keyword = "else", reason = "duplicate else" },
    { source = 'if(false); else(); elif(true); endif()', keyword = "elif", reason = "elseif follows else" },
    {
      source = 'if(false) { return("bad") } elseif(true); return("mixed"); endif()',
      keyword = "elseif",
      reason = "cannot mix attached and marker branches",
    },
    { source = 'i(true) { return("bad") }', keyword = "i", reason = "expected if/when" },
    {
      source = 'if(false) { return("bad") } elif(true) { return("bad") }',
      keyword = "elif",
      reason = "expected elseif",
    },
    { source = 'when(true); return("bad"); endif()', keyword = "when", reason = "expected if/i" },
    {
      source = 'if(false); otherwise(); return("bad"); endif()',
      keyword = "otherwise",
      reason = "expected else",
    },
    {
      source = 'if(true) {} else {} otherwise {}',
      keyword = "otherwise",
      reason = "duplicate else",
    },
    {
      source = 'if(false) {} else {} elseif(true) {}',
      keyword = "elseif",
      reason = "elseif follows else",
    },
  }) do
    local ok, failure = pcall(function()
      execute_uniform_binding_source(uniform_binding_action_source(malformed.source))
    end)
    assert_equal(ok, false, malformed.keyword .. " malformed control fails")
    assert_equal(linkedspec.is_runtime_interpreter_error(failure), true, malformed.keyword .. " typed control failure")
    assert_equal(failure.code, "malformed_statement_control", malformed.keyword .. " control diagnostic code")
    assert_equal(failure.control_keyword, malformed.keyword, malformed.keyword .. " diagnostic keyword")
    assert_equal(failure.reason, malformed.reason, malformed.keyword .. " diagnostic reason")
    assert_equal(failure.rule_label, "Top", malformed.keyword .. " diagnostic rule")
  end
end)

test("runtime statement switch controls select one attached or marker branch", function()
  local source = uniform_binding_action_source([[
events = []
subject_calls = []
kind = "b"
switch({ push(subject_calls, "attached"); kind }) {
  case(a) { exit_now(51) }
  case(b) { push(events, "attached-bare") }
  case(exit_now(52)) { exit_now(53) }
  default { exit_now(54) }
}
switch("dynamic") {
  case(cat("dyna", "mic")) { push(events, "attached-dynamic") }
  default { exit_now(55) }
}
switch(undef) { case("") { push(events, "attached-null") } default { exit_now(56) } }
switch(false) { case(0) { push(events, "attached-bool-number") } default { exit_now(57) } }
switch([]) { case("") { exit_now(58) } default { push(events, "attached-aggregate-default") } }
switch("missing") { case(no) { exit_now(59) } default {} }
push(events, "after-attached-empty")
switch({ push(subject_calls, "marker"); kind })
case(a)
  exit_now(60)
endcase()
case(b)
  push(events, "marker-bare")
endcase()
case(exit_now(61))
  exit_now(62)
endcase()
default()
  exit_now(63)
endswitch()
switch("outer")
case(outer)
  switch("inner")
  case(inner)
    push(events, "nested-marker-switch")
  endcase()
  default()
    exit_now(64)
  endswitch()
endcase()
default()
  exit_now(65)
endswitch()
switch("missing")
case(no)
  exit_now(66)
endcase()
default()
  push(events, "marker-default")
endswitch()
switch("outside")
  exit_now(68)
case(outside)
  push(events, "marker-outside-skipped")
endcase()
exit_now(69)
endswitch()
attached_value = { switch("yes") { case(no) { return("bad") } case(yes) { return("attached-local") } default { return("bad") } } }
marker_value = {
  switch("yes")
  case(no)
    return("bad")
  endcase()
  case(yes)
    return("marker-local")
  endcase()
  default()
    return("bad")
  endswitch()
}
return({
  "events" : copy(events),
  "subject_calls" : copy(subject_calls),
  "attached_value" : attached_value,
  "marker_value" : marker_value
})
]])
  local result = execute_uniform_binding_source(source)
  assert_json_equal(result.events, json.decode([[
[
  "attached-bare",
  "attached-dynamic",
  "attached-null",
  "attached-bool-number",
  "attached-aggregate-default",
  "after-attached-empty",
  "marker-bare",
  "nested-marker-switch",
  "marker-default",
  "marker-outside-skipped"
]
]]), "attached and marker switch branches preserve ActionIR order")
  assert_json_equal(result.subject_calls, json.decode('["attached","marker"]'), "switch subjects run once")
  assert_equal(result.attached_value, "attached-local", "attached switch return stays block-local")
  assert_equal(result.marker_value, "marker-local", "marker switch return stays block-local")

  for _, malformed in ipairs({
    { source = 'case(x); return("bad")', keyword = "case", reason = "orphaned branch or marker" },
    { source = 'default(); return("bad")', keyword = "default", reason = "orphaned branch or marker" },
    { source = 'endcase(); return("bad")', keyword = "endcase", reason = "orphaned branch or marker" },
    { source = 'endswitch(); return("bad")', keyword = "endswitch", reason = "orphaned branch or marker" },
    { source = 'switch(exit_now(67)); case(x); return("bad")', keyword = "switch", reason = "missing endswitch" },
    {
      source = 'switch(x); default(); return("bad"); default(); return("bad"); endswitch()',
      keyword = "default",
      reason = "duplicate default",
    },
    {
      source = 'switch(x); default(); return("bad"); case(x); return("bad"); endswitch()',
      keyword = "case",
      reason = "case follows default",
    },
    {
      source = 'switch(x); endcase(); default(); return("bad"); endswitch()',
      keyword = "endcase",
      reason = "endcase without open branch",
    },
    {
      source = 'switch(x); case(x); endcase(); endcase(); endswitch()',
      keyword = "endcase",
      reason = "endcase without open branch",
    },
    {
      source = 'switch(x); case(x) { return("bad") }; endswitch()',
      keyword = "case",
      reason = "cannot mix attached and marker branches",
    },
    {
      source = 'switch(x) { set(out, "bad"); default { return("bad") } }',
      keyword = "call",
      reason = "expected attached case/default branch",
    },
    {
      source = 'switch(x) { default { return("bad") } default { return("bad") } }',
      keyword = "default",
      reason = "duplicate default",
    },
    {
      source = 'switch(x) { default { return("bad") } case(x) { return("bad") } }',
      keyword = "case",
      reason = "case follows default",
    },
  }) do
    local ok, failure = pcall(function()
      execute_uniform_binding_source(uniform_binding_action_source(malformed.source))
    end)
    assert_equal(ok, false, malformed.keyword .. " malformed switch fails")
    assert_equal(linkedspec.is_runtime_interpreter_error(failure), true, malformed.keyword .. " typed switch failure")
    assert_equal(failure.code, "malformed_statement_control", malformed.keyword .. " switch diagnostic code")
    assert_equal(failure.control_keyword, malformed.keyword, malformed.keyword .. " switch diagnostic keyword")
    assert_equal(failure.reason, malformed.reason, malformed.keyword .. " switch diagnostic reason")
    assert_equal(failure.rule_label, "Top", malformed.keyword .. " switch diagnostic rule")
  end
end)

test("runtime attached while controls re-evaluate state and enforce bounded safety", function()
  local source = uniform_binding_action_source([[
events = []
condition_calls = []
count = 0
while({ push(condition_calls, count); num_lt(count, 3) }) {
  push(events, count)
  count = num_add(count, 1)
}
while(false) { exit_now(70) }
next_count = 0
while(num_lt(next_count, 3)) {
  next_count = num_add(next_count, 1)
  next()
  exit_now(71)
}
local_value = {
  local_count = 0
  while(num_lt(local_count, 3)) {
    local_count = num_add(local_count, 1)
    if(num_eq(local_count, 2)) { return(["local", local_count]) }
  }
  exit_now(72)
}
return({
  "events" : copy(events),
  "condition_calls" : copy(condition_calls),
  "count" : count,
  "next_count" : next_count,
  "local_value" : local_value
})
]])
  local result = execute_uniform_binding_source(source)
  assert_json_equal(result.events, json.decode("[0,1,2]"), "while body observes each prior condition state")
  assert_json_equal(
    result.condition_calls,
    json.decode("[0,1,2,3]"),
    "while condition re-evaluates once after the final body"
  )
  assert_equal(result.count, 3, "while body mutation reaches the next condition")
  assert_equal(result.next_count, 3, "next continues the attached while body")
  assert_json_equal(result.local_value, json.decode('["local",2]'), "while return stays expression-block local")

  local action_return = execute_uniform_binding_source(uniform_binding_action_source([[
while(true) {
  return("action-return")
  exit_now(73)
}
exit_now(74)
]]))
  assert_equal(action_return, "action-return", "while body return exits the surrounding action")

  local exact_limit = linkedspec.runtime_parse(
    linkedspec.runtime_engine(
      linkedspec.compile_spec(linkedspec.parse_spec(uniform_binding_action_source([[
count = 0
while(num_lt(count, 3)) { count = num_add(count, 1) }
return(count)
]]))),
      { max_iterations = 3 }
    ),
    "xx"
  ).value
  assert_equal(exact_limit, 3, "condition becoming false after the final allowed body succeeds")

  local ok, failure = pcall(function()
    linkedspec.runtime_parse(
      linkedspec.runtime_engine(
        linkedspec.compile_spec(linkedspec.parse_spec(uniform_binding_action_source([[
count = 0
while(num_lt(count, 4)) { count = num_add(count, 1) }
return(count)
]]))),
        { max_iterations = 3 }
      ),
      "xx"
    )
  end)
  assert_equal(ok, false, "truthful condition after the final allowed body fails")
  assert_equal(linkedspec.is_runtime_interpreter_error(failure), true, "while limit is a typed runtime failure")
  assert_equal(failure.code, "while_iteration_limit_exceeded", "while limit diagnostic code")
  assert_equal(failure.control_keyword, "while", "while limit diagnostic keyword")
  assert_equal(failure.action_kind, "control_while", "while limit diagnostic ActionIR kind")
  assert_equal(failure.max_iterations, 3, "while limit diagnostic threshold")
  assert_equal(failure.rule_label, "Top", "while limit diagnostic rule")
  assert_equal(
    failure.message,
    "LinkedSpec while iteration safety limit exceeded after 3 iterations",
    "while limit diagnostic message"
  )

  local bodyless_ok, bodyless_failure = pcall(function()
    execute_uniform_binding_source(uniform_binding_action_source('while(exit_now(75)); return("bad")'))
  end)
  assert_equal(bodyless_ok, false, "bodyless while fails before evaluating its condition")
  assert_equal(linkedspec.is_runtime_interpreter_error(bodyless_failure), true, "bodyless while failure is typed")
  assert_equal(bodyless_failure.code, "malformed_statement_control", "bodyless while diagnostic code")
  assert_equal(bodyless_failure.control_keyword, "while", "bodyless while diagnostic keyword")
  assert_equal(bodyless_failure.reason, "attached while requires a body", "bodyless while diagnostic reason")
  assert_equal(bodyless_failure.rule_label, "Top", "bodyless while diagnostic rule")
end)

test("Lua matches the neutral scalar numeric contract exactly", function()
  local contract = json.decode(read_file("capability_conformance/scalar_numeric_contract.json"))
  assert_equal(contract.format, 1, "scalar numeric contract format")
  assert_equal(contract.contract_id, scalar_numeric.CONTRACT_ID, "scalar numeric contract id")
  assert_equal(#contract.cases, 55, "scalar numeric contract cases")
  local actual = execute_uniform_binding_source(contract.spec_source)
  assert_json_equal(actual, contract.expected, "all scalar numeric cases")
end)

test("numeric aliases symbols and receiver chains share the scalar evaluator", function()
  local grouped_regex = linkedspec.parse_action_expression("/(foo),bar/")
  local class_regex = linkedspec.parse_action_expression("/([)])/")
  assert_equal(grouped_regex.kind, "regex", "grouped comma regex stays a regex")
  assert_equal(grouped_regex.pattern, "(foo),bar", "grouped comma regex payload")
  assert_equal(class_regex.kind, "regex", "class closing parenthesis stays a regex")
  assert_equal(class_regex.pattern, "([)])", "class closing parenthesis regex payload")
  local source = uniform_binding_action_source([[
score = -2.5
return({
  "word_abs" : abs(-4),
  "word_add" : add(1, 2, 3),
  "word_ceil" : ceil(-3.2),
  "word_clamp" : clamp(12, 0, 10),
  "word_div" : div(7, 2),
  "word_eq" : eq(2, 2),
  "word_floor" : floor(-3.2),
  "word_ge" : ge(2, 2),
  "word_gt" : gt(3, 2),
  "word_le" : le(2, 2),
  "word_lt" : lt(1, 2),
  "word_max" : max(2, 5, 3),
  "word_min" : min(2, 5, 3),
  "word_mod" : mod(7, 3),
  "word_mul" : mul(2, 3, 4),
  "word_ne" : ne(2, 3),
  "word_round" : round(-2.5),
  "word_sub" : sub(10, 3),
  "symbol_add" : +(2, 3),
  "symbol_sub" : -(5, 3),
  "symbol_mul" : *(3, 4),
  "symbol_div" : /(7, 2),
  "symbol_mod" : %(7, 3),
  "symbol_eq" : ==(2, 2),
  "symbol_ne" : !=(2, 3),
  "symbol_gt" : >(3, 2),
  "symbol_ge" : >=(2, 2),
  "symbol_lt" : <(1, 2),
  "symbol_le" : <=(2, 2),
  "integer_receiver" : 5.mod(2),
  "float_chain" : 3.5.floor().add(1),
  "bare_scalar_chain" : score.abs().mul(2),
  "comparison_receiver" : 5.gt(2),
  "terminal_eq" : 2.eq(2).add(1),
  "terminal_ne" : 2.ne(3).add(1),
  "terminal_gt" : 5.gt(2).add(1),
  "terminal_ge" : 2.ge(2).add(1),
  "terminal_lt" : 1.lt(2).add(1),
  "terminal_le" : 2.le(2).add(1)
})
]])
  local expected = json.decode([[
{
  "word_abs": 4, "word_add": 6, "word_ceil": -3, "word_clamp": 10,
  "word_div": 3.5, "word_eq": 1, "word_floor": -4, "word_ge": 1,
  "word_gt": 1, "word_le": 1, "word_lt": 1, "word_max": 5,
  "word_min": 2, "word_mod": 1, "word_mul": 24, "word_ne": 1,
  "word_round": -3, "word_sub": 7,
  "symbol_add": 5, "symbol_sub": 2, "symbol_mul": 12, "symbol_div": 3.5,
  "symbol_mod": 1, "symbol_eq": 1, "symbol_ne": 1, "symbol_gt": 1,
  "symbol_ge": 1, "symbol_lt": 1, "symbol_le": 1,
  "integer_receiver": 1, "float_chain": 4, "bare_scalar_chain": 5,
  "comparison_receiver": 1, "terminal_eq": null, "terminal_ne": null,
  "terminal_gt": null, "terminal_ge": null, "terminal_lt": null, "terminal_le": null
}
]])
  assert_json_equal(execute_uniform_binding_source(source), expected, "numeric call and receiver surfaces")
end)

test("numeric aggregate reducers preserve arrays and terminate receiver chains", function()
  local source = uniform_binding_action_source([[
scores = [1, "2", 5, 4]
empty = []
invalid = [1, true]
return({
  "explicit_sum" : num_sum([1, "2", 3]),
  "canonical_avg" : num_avg([2, 4, 6]),
  "canonical_range" : num_range([3, 9, 1, 7]),
  "canonical_max" : num_max([8, 3, 5]),
  "alias_sum" : sum([1, 2, 3]),
  "alias_min" : min([8, 3, 5]),
  "bare_avg" : avg(scores),
  "median_odd" : median([5, 1, 3]),
  "median_even" : num_median([4, 1, 3, 2]),
  "range" : range([3, 9, 1, 7]),
  "array_min" : num_min([8, 3, 5]),
  "array_max" : max([8, 3, 5]),
  "empty_sum" : sum(empty),
  "empty_avg" : avg(empty),
  "empty_median" : median(empty),
  "empty_range" : range(empty),
  "empty_min" : min(empty),
  "empty_max" : max(empty),
  "invalid_element" : sum(invalid),
  "invalid_kind" : sum(3),
  "wrong_arity" : sum([1], [2]),
  "source_after" : scores,
  "receiver_sum" : scores.sum(),
  "receiver_avg" : scores.avg(),
  "receiver_median" : scores.median(),
  "receiver_range" : scores.range(),
  "receiver_min" : scores.min(),
  "receiver_max" : scores.max(),
  "receiver_wrong_arity" : scores.sum(1),
  "receiver_terminal" : scores.sum().add(1)
})
]])
  local expected = json.decode([[
{
  "explicit_sum": 6, "canonical_avg": 4, "canonical_range": 8,
  "canonical_max": 8, "alias_sum": 6, "alias_min": 3,
  "bare_avg": 3, "median_odd": 3, "median_even": 2.5,
  "range": 8, "array_min": 3, "array_max": 8, "empty_sum": 0,
  "empty_avg": null, "empty_median": null, "empty_range": null,
  "empty_min": null, "empty_max": null, "invalid_element": null,
  "invalid_kind": null, "wrong_arity": null, "source_after": [1, "2", 5, 4],
  "receiver_sum": 12, "receiver_avg": 3, "receiver_median": 3,
  "receiver_range": 4, "receiver_min": 1, "receiver_max": 5,
  "receiver_wrong_arity": null, "receiver_terminal": null
}
]])
  assert_json_equal(execute_uniform_binding_source(source), expected, "numeric aggregate reducer surfaces")
end)

local function selector_diagnostic(surface, identifier)
  return "aggregate_selector_removed surface=" .. surface ..
    " identifier=" .. identifier .. " replacement=" .. identifier
end

local function assert_selector_compile_error(source, surface, identifier, label, spec_override)
  local ok, compile_error = pcall(function()
    return linkedspec.compile_spec(spec_override or linkedspec.parse_spec(source))
  end)
  assert_equal(ok, false, label .. " rejects")
  assert_equal(linkedspec.is_compiled_spec_error(compile_error), true, label .. " error type")
  assert_contains(compile_error.message, selector_diagnostic(surface, identifier), label .. " diagnostic")
  assert_equal(compile_error.code, "aggregate_selector_removed", label .. " code")
  assert_equal(compile_error.surface, surface, label .. " surface")
  assert_equal(compile_error.identifier, identifier, label .. " identifier")
  assert_equal(compile_error.replacement, identifier, label .. " replacement")
end

test("uniform-binding exact aggregate selectors fail compilation", function()
  local handle = assert(io.open("capability_conformance/uniform_binding_contract.json", "rb"))
  local contract = json.decode(assert(handle:read("*a")))
  assert(handle:close())
  for _, case in ipairs(contract.invalid_selector_cases) do
    assert_selector_compile_error(
      uniform_binding_action_source(case.source),
      case.surface,
      case.identifier,
      case.id
    )
  end
end)

test("uniform-binding dead fluent function and caller-mutated selectors reject", function()
  assert_selector_compile_error(
    uniform_binding_action_source("if(false) { return(array(items)) }; return([])"), -- selector-rejection fixture
    "array",
    "items",
    "dead selector"
  )
  assert_selector_compile_error(
    "Top::\n -> Done.return(hash(meta))\nDone::\n /x/\n", -- selector-rejection fixture
    "hash",
    "meta",
    "fluent selector"
  )

  local parsed = linkedspec.parse_spec(uniform_binding_action_source("return([])"))
  local definition = registry_function(
    "retired",
    {},
    0,
    nil,
    "return(array(items))" -- selector-rejection fixture
  )
  local function_spec = ast.spec_file({ functions = { definition }, rules = parsed.rules })
  assert_selector_compile_error("", "array", "items", "unused function selector", function_spec)

  local compiled = linkedspec.compile_spec(parsed)
  local payload = linkedspec.compiled_spec.action_payloads(compiled.rules_by_label.Top)[1]
  payload.action_ast = linkedspec.parse_action_block("array" .. "(items)") -- selector-rejection fixture: array(items)
  local ok, runtime_error = pcall(function() return linkedspec.runtime_engine(compiled) end)
  assert_equal(ok, false, "caller-mutated selector rejects")
  assert_equal(linkedspec.is_compiled_spec_error(runtime_error), true, "caller-mutated error type")
  assert_contains(runtime_error.message, selector_diagnostic("array", "items"), "caller-mutated diagnostic")
end)

test("uniform-binding retained aggregate constructors and literals execute", function()
  local result = execute_uniform_binding_source(uniform_binding_action_source([[
items = ["x"]
left = "l"
right = "r"
key = "key"
value = "r"
return([
  array(),
  array("items"),
  array(copy(items)),
  array(left, right),
  hash(),
  hash("key", value),
  [items],
  { key : value }
])
]]))
  assert_json_equal(result, json.array({
    json.array(),
    json.array({ "items" }),
    json.array({ json.array({ "x" }) }),
    json.array({ "l", "r" }),
    json.harray(),
    json.harray({ key = "r" }),
    json.array({ json.array({ "x" }) }),
    json.harray({ key = "r" }),
  }), "retained aggregate forms")
end)

test("uniform-binding future fixture executes", function()
  local handle = assert(io.open("capability_conformance/uniform_binding_contract.json", "rb"))
  local contract = json.decode(assert(handle:read("*a")))
  assert(handle:close())
  assert_equal(contract.contract_id, "linkedspec-uniform-binding-v1", "contract id")
  assert_json_equal(
    execute_uniform_binding_source(contract.fixture.spec_source, contract.fixture.input),
    contract.fixture.expected,
    "future fixture"
  )
end)

test("uniform-binding absent push and array-end mutation return independent updates", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   first_push = push(items, "a")
   second_push = push(items, "b")
   items += "c"
   after_push_back = items.push_back("d")
   after_push_front = items.push_front("z")
   after_pop_back = items.pop_back()
   after_pop_front = items.pop_front()
   count = items.push_back("e").count()
   return({
     "items" : items,
     "first_push" : first_push,
     "second_push" : second_push,
     "after_push_back" : after_push_back,
     "after_push_front" : after_push_front,
     "after_pop_back" : after_pop_back,
     "after_pop_front" : after_pop_front,
     "count" : count
   })
 }
Done::
 /x/
]])
  assert_json_equal(result, json.harray({
    items = json.array({ "a", "b", "c", "e" }),
    first_push = json.array({ "a" }),
    second_push = json.array({ "a", "b" }),
    after_push_back = json.array({ "a", "b", "c", "d" }),
    after_push_front = json.array({ "z", "a", "b", "c", "d" }),
    after_pop_back = json.array({ "z", "a", "b", "c" }),
    after_pop_front = json.array({ "a", "b", "c" }),
    count = 4,
  }), "updated arrays")
end)

test("uniform-binding registered rule keeps ambiguous push precedence", function()
  local result = execute_uniform_binding_source([[
Top::
 I { items = ["unchanged"]; outputs = [] }
 /x/ -> Done { pushed = push(items, outputs); return([items, outputs, pushed]) }
items::
 /x/ I { return("child-result") }
Done::
 /x/
]])
  assert_json_equal(result, json.array({
    json.array({ "unchanged" }),
    json.array({ "child-result" }),
    json.array({ "child-result" }),
  }), "static rule precedence")
end)

test("runtime child push reuses action edge and selects zero based results", function()
  local forms = execute_uniform_binding_source([[
Parent::
 I { set(explicit, []) }
 -> Child {
   push(Child)
   push(Child, explicit)
   push(Child, 1)
   push(Child, explicit, 0)
 }
 LX {
   return({
     "implicit" : copy(Parent),
     "explicit" : copy(explicit),
     "absent_rule" : copy(Other)
   })
 }

Child:
 /x/
 I { return(["zero", "one"]) }

Other: /z/
]], "x")
  assert_json_equal(forms, json.harray({
    implicit = json.array({ json.array({ "zero", "one" }), "one" }),
    explicit = json.array({ json.array({ "zero", "one" }), "zero" }),
    absent_rule = json.array(),
  }), "child push forms")
end)

test("runtime fluent child push fills implicit and explicit accumulators", function()
  local implicit = execute_uniform_binding_source([[
top::
 -> item .push
 E { return(copy(top)) }

item:
 /x/
 I { return(entry_text()) }
]], "xx")
  assert_json_equal(implicit, json.array({ "x", "x" }), "fluent implicit child push")

  local explicit = execute_uniform_binding_source([[
Top::
 I { set(out, []) }
 -> Item.push(out)
 E { return(copy(out)) }

Item:
 /x/
 I { return(entry_text()) }
]], "xx")
  assert_json_equal(explicit, json.array({ "x", "x" }), "fluent explicit child push")
end)

test("runtime child push rejects wrong kind explicit accumulator", function()
  local ok, failure = pcall(function()
    execute_uniform_binding_source([[
Parent::
 I { explicit = "text" }
 -> Child { push(Child, explicit) }

Child: /x/ I { return("child") }
]], "x")
  end)
  assert_equal(ok, false, "wrong-kind child push fails")
  assert_equal(linkedspec.is_runtime_interpreter_error(failure), true, "typed child push error")
  assert_equal(failure.code, "binding_kind_mismatch", "child push error code")
  assert_equal(failure.identifier, "explicit", "child push error identifier")
  assert_equal(failure.expected_kind, "array", "child push expected kind")
  assert_equal(failure.actual_kind, "scalar", "child push actual kind")
end)

test("uniform-binding mutable and pure split remain distinct", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   stored = split(parts, "a,b", ",")
   pure = split("c,d", ",")
   return({ "parts" : parts, "stored" : stored, "pure" : pure })
 }
Done::
 /x/
]])
  assert_json_equal(result, json.harray({
    parts = json.array({ "a", "b" }),
    stored = json.array({ "a", "b" }),
    pure = json.array({ "c", "d" }),
  }), "split forms")
end)

test("uniform-binding hash-index mutation returns the updated harray", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   updated = (meta["stage"] = "ok")
   snapshot = copy(meta)
   return({ "meta" : meta, "updated" : updated, "snapshot" : snapshot })
 }
Done::
 /x/
]])
  local expected = json.harray({ stage = "ok" })
  assert_json_equal(result, json.harray({
    meta = expected,
    updated = expected,
    snapshot = expected,
  }), "harray update")
end)

test("runtime named harray mutation shares one binding seam and preserves pure forms", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   set(existing, { "seed" : { "nested" : 1 } })
   set_key(existing, "statement", { "nested" : 2 })
   statement_snapshot = (existing["operator"] = { "nested" : 3 })
   set_key(created, "first", 1)
   direct_snapshot = (direct_created["first"] = { "nested" : 4 })
   set(indexed, ["a"])
   indexed_snapshot = (indexed[1] = "b")
   pure_call = set_key(existing, "pure_call", 5)
   pure_receiver = existing.set_key("pure_receiver", 6)
   existing["statement"]["nested"] = 9
   existing["later"] = 7
   direct_created["first"]["nested"] = 8
   indexed[0] = "changed"
   return({
     "existing" : existing,
     "created" : created,
     "direct_created" : direct_created,
     "statement_snapshot" : statement_snapshot,
     "direct_snapshot" : direct_snapshot,
     "indexed" : indexed,
     "indexed_snapshot" : indexed_snapshot,
     "pure_call" : pure_call,
     "pure_receiver" : pure_receiver
   })
 }
Done::
 /x/
]])
  assert_json_equal(result, json.harray({
    existing = json.harray({
      later = 7,
      operator = json.harray({ nested = 3 }),
      seed = json.harray({ nested = 1 }),
      statement = json.harray({ nested = 9 }),
    }),
    created = json.harray({ first = 1 }),
    direct_created = json.harray({ first = json.harray({ nested = 8 }) }),
    statement_snapshot = json.harray({
      operator = json.harray({ nested = 3 }),
      seed = json.harray({ nested = 1 }),
      statement = json.harray({ nested = 2 }),
    }),
    direct_snapshot = json.harray({ first = json.harray({ nested = 4 }) }),
    indexed = json.array({ "changed", "b" }),
    indexed_snapshot = json.array({ "a", "b" }),
    pure_call = json.harray({
      operator = json.harray({ nested = 3 }),
      pure_call = 5,
      seed = json.harray({ nested = 1 }),
      statement = json.harray({ nested = 2 }),
    }),
    pure_receiver = json.harray({
      operator = json.harray({ nested = 3 }),
      pure_receiver = 6,
      seed = json.harray({ nested = 1 }),
      statement = json.harray({ nested = 2 }),
    }),
  }), "named harray mutation")

  for _, case in ipairs({
    { source = [[
Top::
 /x/ -> Done { set(wrong, "text"); set_key(wrong, "key", 1) }
Done::
 /x/
]], actual_kind = "scalar" },
    { source = [[
Top::
 /x/ -> Done { set(wrong, 17); wrong["key"] = "value" }
Done::
 /x/
]], actual_kind = "scalar" },
    { source = [[
Top::
 /x/ -> Done { set(wrong, ["array"]); set_key(wrong, "key", "value") }
Done::
 /x/
]], actual_kind = "array" },
  }) do
    local ok, failure = pcall(function() execute_uniform_binding_source(case.source) end)
    assert_equal(ok, false, "wrong-kind harray mutation fails")
    assert_equal(linkedspec.is_runtime_interpreter_error(failure), true, "typed harray mutation error")
    assert_equal(failure.code, "binding_kind_mismatch", "harray mutation error code")
    assert_equal(failure.identifier, "wrong", "harray mutation error identifier")
    assert_equal(failure.expected_kind, "harray", "harray mutation expected kind")
    assert_equal(failure.actual_kind, case.actual_kind, "harray mutation actual kind")
  end
end)

test("uniform-binding unused values are dropped", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   set(items, ["a"])
   copy(items)
   updated = push(items, "b")
   return({ "items" : items, "updated" : updated })
 }
Done::
 /x/
]])
  local expected = json.array({ "a", "b" })
  assert_json_equal(result, json.harray({ items = expected, updated = expected }), "dropped values")
end)

test("uniform-binding bare collection statements rebind the typed array", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   trimmed = trim_each(set(words, [" a ", "", "b"]))
   trim_each(words)
   filter_nonempty(words)
   return({ "trimmed" : trimmed, "words" : words })
 }
Done::
 /x/
]])
  assert_json_equal(result, json.harray({
    trimmed = json.array({ "a", "", "b" }),
    words = json.array({ "a", "b" }),
  }), "collection rebinding")
end)

test("runtime copied array construction splices only explicit flat values", function()
  local result = execute_uniform_binding_source([=[
Top::
 /x/ -> Done {
   set(source, ["a", ["b"]])
   nested_call = array("tag", source)
   nested_literal = ["tag", copy(source)]
   call_splice = array("tag", flat_array(source), "tail")
   literal_splice = ["tag", flat(source), "tail"]
   receiver_splice = array("tag", source.flat(), "tail")
   concatenated = concat_arrays(["x"], ["y", "z"])
   flattened = flat_array(["p", "q"], "r", ["s"])
   snapshot = copy(source)
   source.push_back("c")
   ordered_call = array(set(step, 1), set(step, 2), step)
   ordered_literal = [set(step, 3), set(step, 4), step]
   return({
     "source" : source,
     "snapshot" : snapshot,
     "nested_call" : nested_call,
     "nested_literal" : nested_literal,
     "call_splice" : call_splice,
     "literal_splice" : literal_splice,
     "receiver_splice" : receiver_splice,
     "concatenated" : concatenated,
     "flattened" : flattened,
     "empty_array" : array(),
     "empty_flattened" : flat_array(),
     "empty_concatenated" : concat_arrays(),
     "missing_flat" : flat(),
     "missing_copy" : copy(),
     "ordered_call" : ordered_call,
     "ordered_literal" : ordered_literal
   })
 }
Done::
 /x/
]=])
  assert_json_equal(result, json.harray({
    source = json.array({ "a", json.array({ "b" }), "c" }),
    snapshot = json.array({ "a", json.array({ "b" }) }),
    nested_call = json.array({ "tag", json.array({ "a", json.array({ "b" }) }) }),
    nested_literal = json.array({ "tag", json.array({ "a", json.array({ "b" }) }) }),
    call_splice = json.array({ "tag", "a", json.array({ "b" }), "tail" }),
    literal_splice = json.array({ "tag", "a", json.array({ "b" }), "tail" }),
    receiver_splice = json.array({ "tag", "a", json.array({ "b" }), "tail" }),
    concatenated = json.array({ "x", "y", "z" }),
    flattened = json.array({ "p", "q", "r", "s" }),
    empty_array = json.array(),
    empty_flattened = json.array(),
    empty_concatenated = json.array(),
    missing_flat = json.array({ json.null }),
    missing_copy = json.null,
    ordered_call = json.array({ 1, 2, 2 }),
    ordered_literal = json.array({ 3, 4, 4 }),
  }), "copied array construction")
end)

test("runtime copied harray construction splices only explicit flat values", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   set(step, 0)
   set(source, { "b" : 2, "a" : { "nested" : 1 } })
   constructed = hash(
     "left",
     set(step, add(step, 1)),
     flat_hash(set(extra, { "x" : set(step, add(step, 1)) }))
   )
   nested = hash("payload", source)
   flat_copy = flat(source)
   flat_hash_copy = source.flat_hash()
   generic_splice = hash("kind", "root", flat(source))
   hash_splice = hash("kind", "root", source.flat_hash())
   positioned_splice = hash(flat_hash({ "a" : 1 }), "b", 2, flat({ "a" : 3 }), "c", 4)
   array_pair_splice = hash(flat(["p", 3, "missing"]))
   odd = hash("present", 1, "missing")
   call_list_splice = array("tag", flat_hash(source))
   literal_list_splice = ["tag", source.flat()]
   source["b"] = 9
   source["a"]["nested"] = 7
   extra["x"] = 99
   return({
     "step" : step,
     "constructed" : constructed,
     "nested" : nested,
     "flat_copy" : flat_copy,
     "flat_hash_copy" : flat_hash_copy,
     "generic_splice" : generic_splice,
     "hash_splice" : hash_splice,
     "positioned_splice" : positioned_splice,
     "array_pair_splice" : array_pair_splice,
     "odd" : odd,
     "call_list_splice" : call_list_splice,
     "literal_list_splice" : literal_list_splice,
     "source" : source,
     "extra" : extra
   })
 }
Done::
 /x/
]])
  local original = json.harray({ a = json.harray({ nested = 1 }), b = 2 })
  assert_json_equal(result, json.harray({
    step = 2,
    constructed = json.harray({ left = 1, x = 2 }),
    nested = json.harray({ payload = original }),
    flat_copy = original,
    flat_hash_copy = original,
    generic_splice = json.harray({ a = json.harray({ nested = 1 }), b = 2, kind = "root" }),
    hash_splice = json.harray({ a = json.harray({ nested = 1 }), b = 2, kind = "root" }),
    positioned_splice = json.harray({ a = 3, b = 2, c = 4 }),
    array_pair_splice = json.harray({ p = 3, missing = json.null }),
    odd = json.harray({ present = 1, missing = json.null }),
    call_list_splice = json.array({ "tag", "a", json.harray({ nested = 1 }), "b", 2 }),
    literal_list_splice = json.array({ "tag", "a", json.harray({ nested = 1 }), "b", 2 }),
    source = json.harray({ a = json.harray({ nested = 7 }), b = 9 }),
    extra = json.harray({ x = 99 }),
  }), "copied harray construction")
end)

test("runtime deterministic harray views preserve key order and copied values", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   set(meta, { "c" : 3, "a" : undef, "b" : { "nested" : 2 } })
   keys = sorted_keys(meta)
   values = meta.sorted_values()
   nested_from_chain = meta.sorted_values().drop_front().first()
   meta["b"]["nested"] = 9
   return({
     "count" : count_keys(meta),
     "receiver_count" : meta.count_keys(),
     "keys" : keys,
     "key_chain" : meta.sorted_keys().join_values(","),
     "values" : values,
     "nested_from_chain" : nested_from_chain,
     "has_null" : has_key(meta, "a"),
     "receiver_has" : meta.has_key("b"),
     "missing_key" : has_key(meta, "missing"),
     "missing_key_arg" : has_key(meta),
     "invalid_count" : count_keys("text"),
     "missing_count" : count_keys(),
     "invalid_keys" : sorted_keys(undef),
     "missing_values" : sorted_values(),
     "invalid_has" : has_key("text", "a"),
     "terminal_count" : meta.count_keys().add(1),
     "terminal_has" : meta.has_key("a").add(1),
     "meta" : meta
   })
 }
Done::
 /x/
]])
  assert_json_equal(result, json.harray({
    count = 3,
    receiver_count = 3,
    keys = json.array({ "a", "b", "c" }),
    key_chain = "a,b,c",
    values = json.array({ json.null, json.harray({ nested = 2 }), 3 }),
    nested_from_chain = json.harray({ nested = 2 }),
    has_null = 1,
    receiver_has = 1,
    missing_key = 0,
    missing_key_arg = 0,
    invalid_count = 0,
    missing_count = 0,
    invalid_keys = json.array(),
    missing_values = json.array(),
    invalid_has = 0,
    terminal_count = json.null,
    terminal_has = json.null,
    meta = json.harray({ a = json.null, b = json.harray({ nested = 9 }), c = 3 }),
  }), "deterministic harray views")
end)

test("runtime copied harray transforms preserve overrides isolation and receiver flow", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   set(base, {
     "b" : 2,
     "a" : { "nested" : 1 },
     "same" : "base",
     "old" : 7,
     "new" : 9,
     "drop" : 0,
     "null" : undef
   })
   set(overlay, { "c" : 3, "same" : "overlay", "a" : { "nested" : 4 } })
   merged = merge_hash(base, overlay)
   receiver_merged = base.merge_hash(overlay).drop_keys("drop").set_key("z", 5)
   value_set = set_key(base, "added", { "value" : 8 })
   renamed = rename_key(base, "old", "renamed")
   collision = rename_key(base, "old", "new")
   same_rename = rename_key(base, "old", "old")
   dropped = drop_keys(base, "drop", "missing")
   picked = pick_keys(base, "a", "same", "null", "missing")
   base["a"]["nested"] = 99
   overlay["a"]["nested"] = 88
   return({
     "merged" : merged,
     "merged_chain" : merged.sorted_keys().join_values(","),
     "receiver_merged" : receiver_merged,
     "receiver_chain" : base.rename_key("old", "renamed").drop_keys("drop").set_key("z", 5).sorted_keys().join_values(","),
     "value_set" : value_set,
     "renamed" : renamed,
     "collision" : collision,
     "same_rename" : same_rename,
     "dropped" : dropped,
     "picked" : picked,
     "source_base" : base,
     "source_overlay" : overlay,
     "source_has_added" : base.has_key("added"),
     "source_has_renamed" : base.has_key("renamed"),
     "invalid_set" : set_key("text", "x", 1),
     "missing_set_value" : set_key(base, "x"),
     "invalid_rename" : rename_key("text", "old", "new"),
     "missing_rename_value" : rename_key(base, "old"),
     "invalid_drop" : drop_keys("text", "x"),
     "missing_drop" : drop_keys(),
     "invalid_pick" : pick_keys("text", "x"),
     "missing_pick" : pick_keys(),
     "empty_pick" : pick_keys(base),
     "empty_merge" : merge_hash()
   })
 }
Done::
 /x/
]])
  assert_json_equal(result, json.harray({
    merged = json.harray({
      a = json.harray({ nested = 4 }),
      b = 2,
      c = 3,
      drop = 0,
      new = 9,
      null = json.null,
      old = 7,
      same = "overlay",
    }),
    merged_chain = "a,b,c,drop,new,null,old,same",
    receiver_merged = json.harray({
      a = json.harray({ nested = 4 }),
      b = 2,
      c = 3,
      new = 9,
      null = json.null,
      old = 7,
      same = "overlay",
      z = 5,
    }),
    receiver_chain = "a,b,new,null,renamed,same,z",
    value_set = json.harray({
      a = json.harray({ nested = 1 }),
      added = json.harray({ value = 8 }),
      b = 2,
      drop = 0,
      new = 9,
      null = json.null,
      old = 7,
      same = "base",
    }),
    renamed = json.harray({
      a = json.harray({ nested = 1 }),
      b = 2,
      drop = 0,
      new = 9,
      null = json.null,
      renamed = 7,
      same = "base",
    }),
    collision = json.harray({
      a = json.harray({ nested = 1 }),
      b = 2,
      drop = 0,
      new = 7,
      null = json.null,
      same = "base",
    }),
    same_rename = json.harray({
      a = json.harray({ nested = 1 }),
      b = 2,
      drop = 0,
      new = 9,
      null = json.null,
      old = 7,
      same = "base",
    }),
    dropped = json.harray({
      a = json.harray({ nested = 1 }),
      b = 2,
      new = 9,
      null = json.null,
      old = 7,
      same = "base",
    }),
    picked = json.harray({ a = json.harray({ nested = 1 }), null = json.null, same = "base" }),
    source_base = json.harray({
      a = json.harray({ nested = 99 }),
      b = 2,
      drop = 0,
      new = 9,
      null = json.null,
      old = 7,
      same = "base",
    }),
    source_overlay = json.harray({ a = json.harray({ nested = 88 }), c = 3, same = "overlay" }),
    source_has_added = 0,
    source_has_renamed = 0,
    invalid_set = "text",
    missing_set_value = json.null,
    invalid_rename = "text",
    missing_rename_value = json.null,
    invalid_drop = "text",
    missing_drop = json.null,
    invalid_pick = json.null,
    missing_pick = json.null,
    empty_pick = json.harray(),
    empty_merge = json.harray(),
  }), "copied harray transforms")
end)

test("runtime copied array selection ordering membership and uniqueness", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   set(items, ["b", "a", "c", "a"])
   source = copy(items)
   return({
     "count" : count(items),
     "first" : first(items),
     "last" : last(items),
     "take_default" : take(items),
     "take_two" : take(items, 2),
     "take_last_two" : take_last(items, 2),
     "drop_front_default" : drop_front(items),
     "drop_back_two" : drop_back(items, 2),
     "slice_width" : slice(items, 1, 2),
     "slice_tail" : slice(items, 2),
     "slice_past_end" : slice(items, 99, 2),
     "sorted" : sorted(items),
     "reversed_literal" : [1, 2, 3].reversed(),
     "contains" : contains(items, "a"),
     "missing_contains" : items.contains("z"),
     "index" : index_of(items, "c"),
     "missing_index" : items.index_of("z"),
     "uniq" : uniq(items),
     "chain" : items.sorted().drop_front(2).first(),
     "invalid_count_default" : items.take("bad"),
     "invalid_count" : count(undef),
     "invalid_first" : first("text"),
     "invalid_sorted" : sorted("text"),
     "source" : source,
     "items" : items
   })
 }
Done::
 /x/
]])
  assert_json_equal(result, json.harray({
    count = 4,
    first = "b",
    last = "a",
    take_default = json.array({ "b" }),
    take_two = json.array({ "b", "a" }),
    take_last_two = json.array({ "c", "a" }),
    drop_front_default = json.array({ "a", "c", "a" }),
    drop_back_two = json.array({ "b", "a" }),
    slice_width = json.array({ "a", "c" }),
    slice_tail = json.array({ "c", "a" }),
    slice_past_end = json.array(),
    sorted = json.array({ "a", "a", "b", "c" }),
    reversed_literal = json.array({ 3, 2, 1 }),
    contains = 1,
    missing_contains = 0,
    index = 2,
    missing_index = json.null,
    uniq = json.array({ "b", "a", "c" }),
    chain = "b",
    invalid_count_default = json.array({ "b" }),
    invalid_count = 0,
    invalid_first = json.null,
    invalid_sorted = json.array(),
    source = json.array({ "b", "a", "c", "a" }),
    items = json.array({ "b", "a", "c", "a" }),
  }), "copied array selection")
end)

test("runtime copied array transforms joins split pipelines and rebinding", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   set(source, [" A:A ", "", "c:d", "z:q", "AA"])
   snapshot = copy(source)
   pure_trim = trim_each(source)
   pure_split = split_each(source, ":")
   set(mutating, copy(source))
   trim_each(mutating)
   filter_nonempty(mutating)
   lowercase_each(mutating)
   split_each(mutating, ":")
   filter_match(mutating, /^[acd]/)
   uniq(mutating)
   uppercase_each(mutating)
   return({
     "source" : source,
     "snapshot" : snapshot,
     "pure_trim" : pure_trim,
     "pure_split" : pure_split,
     "mutating" : mutating,
     "direct_join" : join_values("|", ["a", 2, undef]),
     "receiver_join" : ["a", "b"].join_values("|"),
     "scalar_join" : join_values("-", "ab"),
     "missing_join" : join_values("|"),
     "null_join" : join_values("|", undef),
     "regex_split" : ["a, B", "c ,d"].split_each(/\s*,\s*/i),
     "regex_filter" : ["Alpha", "beta", "ALTO"].filter_match(/^a/i),
     "invalid_filter" : filter_match(["a"], "not-a-regex"),
     "invalid_transform" : trim_each("text"),
     "chain" : [" A ", "", "B"].trim_each().filter_nonempty().lowercase_each().join_values("|"),
     "terminal_join" : ["a"].join_values(",").uppercase()
   })
 }
Done::
 /x/
]])
  assert_json_equal(result, json.harray({
    source = json.array({ " A:A ", "", "c:d", "z:q", "AA" }),
    snapshot = json.array({ " A:A ", "", "c:d", "z:q", "AA" }),
    pure_trim = json.array({ "A:A", "", "c:d", "z:q", "AA" }),
    pure_split = json.array({ " A", "A ", "", "c", "d", "z", "q", "AA" }),
    mutating = json.array({ "A", "C", "D", "AA" }),
    direct_join = "a|2|",
    receiver_join = "a|b",
    scalar_join = "",
    missing_join = json.null,
    null_join = json.null,
    regex_split = json.array({ "a", "B", "c", "d" }),
    regex_filter = json.array({ "Alpha", "ALTO" }),
    invalid_filter = json.array(),
    invalid_transform = json.array(),
    chain = "a|b",
    terminal_join = json.null,
  }), "copied array transforms")
end)

test("runtime split tagged records preserves copied fields and pipelines", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   set(source_calls, 0)
   set(field_calls, 0)
   set(field, ["x"])
   set(meta, { "k" : "v" })
   tagged = split_tagged_records(
     cat("a,,b", substr(set(source_calls, add(source_calls, 1)), 0, 0)),
     ",",
     "?item:",
     set(field_calls, add(field_calls, 1)),
     field,
     meta
   )
   field.push_back("y")
   meta["k"] = "changed"
   return({
     "tagged" : tagged,
     "regex" : split_tagged_records("a, b", /\s*,\s*/o, "?node:", "field"),
     "receiver_count" : "a,b".split_tagged_records(",", "?item:").count(),
     "missing_tag" : split_tagged_records("a,b", ","),
     "invalid_source" : split_tagged_records(["a"], ",", "?item:"),
     "source_calls" : source_calls,
     "field_calls" : field_calls,
     "field" : field,
     "meta" : meta
   })
 }
Done::
 /x/
]])
  assert_json_equal(result, json.harray({
    tagged = json.array({
      json.array({ "?item:", "a", 1, json.array({ "x" }), json.harray({ k = "v" }) }),
      json.array({ "?item:", "", 1, json.array({ "x" }), json.harray({ k = "v" }) }),
      json.array({ "?item:", "b", 1, json.array({ "x" }), json.harray({ k = "v" }) }),
    }),
    regex = json.array({
      json.array({ "?node:", "a", "field" }),
      json.array({ "?node:", "b", "field" }),
    }),
    receiver_count = 2,
    missing_tag = json.array(),
    invalid_source = json.array(),
    source_calls = 1,
    field_calls = 1,
    field = json.array({ "x", "y" }),
    meta = json.harray({ k = "changed" }),
  }), "split tagged records")
end)

test("uniform-binding dropped array transform rejects wrong kind", function()
  local ok, failure = pcall(function()
    execute_uniform_binding_source([[
Top::
 /x/ -> Done { items = "text"; split_each(items, ":"); return(items) }
Done::
 /x/
]])
  end)
  assert_equal(ok, false, "wrong-kind transform fails")
  assert_equal(linkedspec.is_runtime_interpreter_error(failure), true, "typed transform error")
  assert_equal(failure.code, "binding_kind_mismatch", "transform error code")
  assert_equal(failure.identifier, "items", "transform error identifier")
  assert_equal(failure.expected_kind, "array", "transform expected kind")
  assert_equal(failure.actual_kind, "scalar", "transform actual kind")
end)

test("uniform-binding wrong-kind mutation reports neutral fields", function()
  local ok, failure = pcall(function()
    execute_uniform_binding_source([[
Top::
 /x/ -> Done { items = "text"; push(items, "x"); return(items) }
Done::
 /x/
]])
  end)
  assert_equal(ok, false, "wrong-kind push fails")
  assert_equal(linkedspec.is_runtime_interpreter_error(failure), true, "typed runtime error")
  assert_equal(failure.code, "binding_kind_mismatch", "error code")
  assert_equal(failure.identifier, "items", "error identifier")
  assert_equal(failure.expected_kind, "array", "expected kind")
  assert_equal(failure.actual_kind, "scalar", "actual kind")
end)

test("uniform-binding set returns the assigned value for receiver chaining", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   first = set(items, ["b", "a"]).sorted().first()
   return([first, items])
 }
Done::
 /x/
]])
  assert_json_equal(result, json.array({ "a", json.array({ "b", "a" }) }), "set chain")
end)

test("generated Unicode 17 casing matches all neutral fixtures and runtime paths", function()
  local handle = assert(io.open("capability_conformance/unicode_case_contract.json", "rb"))
  local contract = json.decode(assert(handle:read("*a")))
  assert(handle:close())
  local unicode_case = require("linkedspec.unicode_case_mapping")
  assert_equal(unicode_case.contract_id, contract.contract_id, "Unicode contract id")
  assert_equal(unicode_case.unicode_version, contract.unicode_version, "Unicode version")
  assert_equal(unicode_case.data_sha256, contract.data_sha256, "Unicode data digest")
  for _, fixture in ipairs(contract.fixtures) do
    assert_equal(unicode_case.lowercase(fixture.input), fixture.lower, fixture.id .. " direct lowercase")
    assert_equal(unicode_case.uppercase(fixture.input), fixture.upper, fixture.id .. " direct uppercase")
    local literal = json.encode(fixture.input)
    local source = "Top::\n /x/ -> Done { return([lowercase(" .. literal .. "), " .. literal ..
      ".lowercase(), uppercase(" .. literal .. "), " .. literal .. ".uppercase(), [" .. literal ..
      "].lowercase_each(), [" .. literal .. "].uppercase_each()]) }\n\nDone::\n /x/\n"
    local result = linkedspec.runtime_parse(
      linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source))),
      "xx"
    ).value
    assert_equal(result[1], fixture.lower, fixture.id .. " helper lowercase")
    assert_equal(result[2], fixture.lower, fixture.id .. " receiver lowercase")
    assert_equal(result[3], fixture.upper, fixture.id .. " helper uppercase")
    assert_equal(result[4], fixture.upper, fixture.id .. " receiver uppercase")
    assert_equal(result[5][1], fixture.lower, fixture.id .. " array lowercase")
    assert_equal(result[6][1], fixture.upper, fixture.id .. " array uppercase")
  end
end)

io.stdout:write("1..", total, "\n")
if failed > 0 then
  os.exit(1)
end
