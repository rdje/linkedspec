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
  assert_equal(first.parity, "compiled_spec", "status parity")
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
 -> Child[1] .return(array("?child:", copy(array(Child))))
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
  assert_equal(body_kind(top, 2).fluent_chain[1].args, 'array("?child:", copy(array(Child)))', "nested args")
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
    'set(array(results), []); push(array(results), retv)\nreturn(copy(array(results)))'
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

  local nested_call = linkedspec.parse_action_expression("array(items = [value], copy(array(items)))")
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

local function registry_function(name, params, index, body_ast)
  local body_source = "return(value)"
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

test("user function invocation frames copy eager four-kind values into fresh stores", function()
  local definition = registry_function("bind_all", { "scalar", "items", "meta", "callback" }, 0)
  local registry = linkedspec.user_function_registry_from_functions({ definition })
  local source_items = json.array({ "a", json.harray({ nested = true }) })
  local source_meta = json.harray({ key = json.array({ 1, 2 }) })
  local source_block = linkedspec.parse_action_expression("{ return(value) }")
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

io.stdout:write("1..", total, "\n")
if failed > 0 then
  os.exit(1)
end
