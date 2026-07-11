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
  assert_equal(first.parity, "source_validation", "status parity")
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

io.stdout:write("1..", total, "\n")
if failed > 0 then
  os.exit(1)
end
